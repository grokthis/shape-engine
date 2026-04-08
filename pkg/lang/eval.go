// Evaluator for shape-lang. Execution IS wave propagation.
//
// A shape-lang program decomposes into the shape graph:
//
//	program.sl → shape "program" (the program itself)
//	  shape engine.edit {...} → adds shape "engine.edit" to engine
//	  fn propagation(...) → registers transform, adds shape "program.fn.propagation"
//	  edit axiom "new" → calls engine.Edit(), adds shape "program.edit.0"
//	  let x = query ... → binds x in scope, adds shape "program.let.x"
//
// Every syntactic element persists as a shape. The AST is a shape graph.
// Loading a file IS adding shapes. Running a file IS propagating waves.
//
// Builtin functions are the syscall interface — the boundary between the
// shape machine (Go) and userspace (shape-lang). Everything above this
// layer can be changed from within the running system.
package lang

import (
	"errors"
	"fmt"
	"sync"

	"github.com/ashbuilds/shape-engine/pkg/arith"
	"github.com/ashbuilds/shape-engine/pkg/engine"
	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/text"
	"github.com/ashbuilds/shape-engine/pkg/transform"
)

// errBreak is a sentinel used to unwind from break statements.
var errBreak = errors.New("break")

// Eval executes a parsed program against an engine.
// The program itself is decomposed into shapes. Returns output text.
func Eval(prog *Program, eng *engine.Engine, ns string) (string, error) {
	return EvalWithScope(prog, eng, ns, nil)
}

// evalPool reuses evaluator objects to avoid allocation.
var evalPool = &sync.Pool{
	New: func() interface{} {
		return &evaluator{
			scope: make(map[string]value, 16),
			fns:   make(map[string]*FnDecl, 4),
		}
	},
}

// EvalWithScope executes a program with initial variable bindings.
// Used by the shell to pass args and context to command shapes.
func EvalWithScope(prog *Program, eng *engine.Engine, ns string, scope map[string]string) (string, error) {
	ev := evalPool.Get().(*evaluator)
	ev.eng = eng
	ev.ns = ns
	ev.edits = 0
	ev.out.Reset()
	// Clear scope (reuse the map).
	for k := range ev.scope {
		delete(ev.scope, k)
	}
	for k := range ev.fns {
		delete(ev.fns, k)
	}
	for k, v := range scope {
		ev.scope[k] = strVal(v)
	}
	result, err := ev.run(prog)
	evalPool.Put(ev)
	return result, err
}

// value is a runtime value during evaluation.
type value struct {
	kind    string // "string", "int", "float", "bool", "list", "shapes", "bytes", "map", "nil"
	str     string
	num     int            // fast-path integer (kept in sync with n)
	flt     float64        // display-only (computed from n when needed)
	n       *arith.Number  // arbitrary-precision numeric value
	boolean bool
	list    []value
	shapes  []*shape.Shape
	buf     []byte            // bytes value: raw byte buffer
	mp      map[string]value  // map value
}

func strVal(s string) value     { return value{kind: "string", str: s} }
func intVal(n int) value        { return value{kind: "int", num: n} } // n field created lazily
func floatVal(f float64) value  { return value{kind: "float", flt: f, n: arith.FromFloat(f)} }
func boolVal(b bool) value      { return value{kind: "bool", boolean: b} }
func nilVal() value             { return value{kind: "nil"} }
func listVal(l []value) value   { return value{kind: "list", list: l} }
func bytesVal(b []byte) value   { return value{kind: "bytes", buf: b} }
func mapVal(m map[string]value) value { return value{kind: "map", mp: m} }
func shapesVal(s []*shape.Shape) value {
	return value{kind: "shapes", shapes: s}
}

// numVal creates a value from an arbitrary-precision number.
func numVal(n *arith.Number) value {
	if n.IsInt() {
		return value{kind: "int", num: n.ToInt(), n: n}
	}
	return value{kind: "float", flt: n.ToFloat64(), n: n}
}

// arithNum returns the arbitrary-precision number for this value.
func (v value) arithNum() *arith.Number {
	if v.n != nil {
		return v.n
	}
	switch v.kind {
	case "int":
		return arith.FromInt(v.num)
	case "float":
		return arith.FromFloat(v.flt)
	case "string":
		return arith.FromString(v.str)
	default:
		return arith.FromInt(0)
	}
}

// asFloat coerces a value to float64.
func (v value) asFloat() float64 {
	switch v.kind {
	case "float":
		return v.flt
	case "int":
		return float64(v.num)
	case "string":
		return arith.FromString(v.str).ToFloat64()
	default:
		return 0
	}
}

func (v value) String() string {
	switch v.kind {
	case "string":
		return v.str
	case "int":
		return fmt.Sprintf("%d", v.num)
	case "float":
		if v.n != nil {
			return arith.Format(v.n, 10)
		}
		return arith.Format(arith.FromFloat(v.flt), 10)
	case "bool":
		if v.boolean {
			return "true"
		}
		return "false"
	case "list":
		parts := make([]string, len(v.list))
		for i, e := range v.list {
			parts[i] = e.String()
		}
		return text.Join(parts, "\n")
	case "shapes":
		ids := make([]string, len(v.shapes))
		for i, s := range v.shapes {
			ids[i] = string(s.ID)
		}
		return text.Join(ids, "\n")
	case "bytes":
		return fmt.Sprintf("<bytes:%d>", len(v.buf))
	case "map":
		var parts []string
		for k, mv := range v.mp {
			parts = append(parts, k+": "+mv.String())
		}
		text.Sort(parts)
		return "{" + text.Join(parts, ", ") + "}"
	default:
		return ""
	}
}

func (v value) truthy() bool {
	switch v.kind {
	case "bool":
		return v.boolean
	case "string":
		return v.str != ""
	case "int":
		return v.num != 0
	case "float":
		return v.flt != 0
	case "list":
		return len(v.list) > 0
	case "shapes":
		return len(v.shapes) > 0
	case "bytes":
		return len(v.buf) > 0
	case "map":
		return len(v.mp) > 0
	default:
		return false
	}
}

// registers is a flat-array scope for tight loops. Zero allocation.
const maxRegs = 16

type registers struct {
	names [maxRegs]string
	vals  [maxRegs]value
	count int
}

func (r *registers) bind(name string) int {
	for i := 0; i < r.count; i++ {
		if r.names[i] == name {
			return i
		}
	}
	if r.count >= maxRegs {
		return -1
	}
	idx := r.count
	r.names[idx] = name
	r.count++
	return idx
}

// evaluator runs a program against an engine.
type evaluator struct {
	eng   *engine.Engine
	ns    string // namespace prefix for program shapes (e.g. "program")
	scope map[string]value
	fns   map[string]*FnDecl
	out   text.Builder
	edits int             // counter for anonymous edit shapes
	used  map[string]bool // tracks use'd shapes to prevent cycles
	regs  registers       // flat register file for tight paths
}

func (ev *evaluator) run(prog *Program) (string, error) {
	// Decompose the program itself as a shape.
	if ev.ns != "" {
		ev.eng.AddShape(&shape.Shape{
			ID: shape.ID(ev.ns),
			Character: shape.Character{
				Dimensions: map[string]string{"type": "program"},
			},
			Structure: shape.Structure{
				Emergence: shape.Emergence{Layer: 4},
			},
		})
	}

	stmts := prog.Stmts
	for i := 0; i < len(stmts); i++ {
		// Structural fusion: let ACC = INIT; for I in range(N) { set ACC = ACC op EXPR }
		// Fuse to a single register computation. Zero scope map access.
		if i+1 < len(stmts) {
			if letStmt, ok := stmts[i].(*LetStmt); ok {
				if intLit, ok := letStmt.Expr.(*IntLit); ok {
					if forStmt, ok := stmts[i+1].(*ForStmt); ok {
						if result, fused := ev.tryFuseLetFor(letStmt.Name, int64(intLit.Value), forStmt); fused {
							ev.scope[letStmt.Name] = intVal(int(result))
							i++ // skip the for statement
							continue
						}
					}
				}
			}
		}
		if err := ev.execTop(stmts[i]); err != nil {
			return ev.out.String(), err
		}
	}
	return ev.out.String(), nil
}

// tryFuseLetFor detects let+for accumulator patterns and computes
// the result as pure arithmetic. No scope map, no value boxing.
// Returns (result, true) if fused, (0, false) if not.
func (ev *evaluator) tryFuseLetFor(accName string, init int64, forStmt *ForStmt) (int64, bool) {
	// Must be for I in range(N) or range(A, B)
	call, ok := forStmt.Iter.(*CallExpr)
	if !ok || call.Fn != "range" || len(call.Args) < 1 {
		return 0, false
	}
	// Must have exactly one body statement: set ACC = ACC op EXPR
	if len(forStmt.Body) != 1 {
		return 0, false
	}
	setStmt, ok := forStmt.Body[0].(*SetStmt)
	if !ok || setStmt.Name != accName {
		return 0, false
	}
	binop, ok := setStmt.Expr.(*BinOp)
	if !ok {
		return 0, false
	}
	ident, ok := binop.Left.(*Ident)
	if !ok || ident.Name != accName {
		return 0, false
	}
	op := binop.Op
	if op != "+" && op != "-" {
		return 0, false
	}

	// Evaluate range args
	var start, end int64
	sv, err := ev.evalExpr(call.Args[0])
	if err != nil {
		return 0, false
	}
	if len(call.Args) >= 2 {
		ev2, err := ev.evalExpr(call.Args[1])
		if err != nil {
			return 0, false
		}
		start, end = int64(sv.num), int64(ev2.num)
	} else {
		end = int64(sv.num)
	}
	count := end - start

	// Right side: counter variable or constant?
	if rident, ok := binop.Right.(*Ident); ok && rident.Name == forStmt.Name {
		// set acc = acc +/- i → Gauss sum
		sum := count * (start + end - 1) / 2
		if op == "+" {
			return init + sum, true
		}
		return init - sum, true
	}
	if intlit, ok := binop.Right.(*IntLit); ok {
		// set acc = acc +/- const → multiply
		if op == "+" {
			return init + count*int64(intlit.Value), true
		}
		return init - count*int64(intlit.Value), true
	}
	return 0, false
}

func (ev *evaluator) execTop(node Node) error {
	switch n := node.(type) {
	case *ShapeDecl:
		return ev.execShapeDecl(n)
	case *FnDecl:
		return ev.execFnDecl(n)
	case *EditStmt:
		return ev.execEdit(n)
	case *LetStmt:
		return ev.execLet(n)
	case *SetStmt:
		return ev.execSet(n)
	case *AssertStmt:
		return ev.execAssert(n)
	case *BlockStmt:
		return ev.execBlock(n)
	case *UseStmt:
		return ev.execUse(n)
	case *IfStmt:
		return ev.execTopIf(n)
	case *ForStmt:
		return ev.execTopFor(n)
	case *WhileStmt:
		return ev.execTopWhile(n)
	case *ReturnStmt:
		// Return at top level: used by exec shapes to produce output.
		if n.Expr != nil {
			v, err := ev.evalExpr(n.Expr)
			if err != nil {
				return err
			}
			if s := v.String(); s != "" {
				ev.out.WriteString(s)
				ev.out.WriteByte('\n')
			}
		}
		return nil
	case *ExprStmt:
		v, err := ev.evalExpr(n.Expr)
		if err != nil {
			return err
		}
		if s := v.String(); s != "" {
			ev.out.WriteString(s)
			ev.out.WriteByte('\n')
		}
		return nil
	default:
		return nil
	}
}

// execTopIf handles if at top level (outside fn body).
func (ev *evaluator) execTopIf(n *IfStmt) error {
	cond, err := ev.evalExpr(n.Cond)
	if err != nil {
		return err
	}
	var branch []Node
	if cond.truthy() {
		branch = n.Then
	} else {
		branch = n.Else
	}
	for _, stmt := range branch {
		if err := ev.execTop(stmt); err != nil {
			return err
		}
	}
	return nil
}

// execTopFor handles for at top level (outside fn body).
func (ev *evaluator) execTopFor(n *ForStmt) error {
	// Structural shortcut: for NAME in range(N) or range(A, B)
	// uses a native counter. No list materialization, no allocation per step.
	if call, ok := n.Iter.(*CallExpr); ok && call.Fn == "range" {
		start, end := 0, 0
		if len(call.Args) == 1 {
			v, err := ev.evalExpr(call.Args[0])
			if err != nil {
				return err
			}
			end = v.num
		} else if len(call.Args) >= 2 {
			sv, err := ev.evalExpr(call.Args[0])
			if err != nil {
				return err
			}
			ev2, err := ev.evalExpr(call.Args[1])
			if err != nil {
				return err
			}
			start, end = sv.num, ev2.num
		}

		// Pre-locate the counter in scope. Write once, then mutate via pointer.
		counter := intVal(start)
		ev.scope[n.Name] = counter

		// Detect accumulator pattern in body: set ACC = ACC op (COUNTER or CONST)
		// If matched, run as pure native loop with zero map ops per iteration.
		if len(n.Body) == 1 {
			if setStmt, ok := n.Body[0].(*SetStmt); ok {
				if binop, ok := setStmt.Expr.(*BinOp); ok {
					if ident, ok := binop.Left.(*Ident); ok && ident.Name == setStmt.Name {
						op := binop.Op
						if op == "+" || op == "-" || op == "*" {
							accVal, hasAcc := ev.scope[setStmt.Name]
							if hasAcc && accVal.kind == "int" {
								// Right side: loop variable or constant?
								useCounter := false
								constVal := 0
								if rident, ok := binop.Right.(*Ident); ok && rident.Name == n.Name {
									useCounter = true
								} else if intlit, ok := binop.Right.(*IntLit); ok {
									constVal = intlit.Value
								} else {
									goto generalLoop
								}
								a := accVal.num
								count := end - start
								if !useCounter {
									// Structural collapse: the loop IS arithmetic.
									// for i in range(n) { acc += c } = acc + n*c
									// for i in range(n) { acc -= c } = acc - n*c
									// for i in range(n) { acc *= c } = acc * c^n
									switch op {
									case "+":
										a += count * constVal
									case "-":
										a -= count * constVal
									case "*":
										cv := constVal
										for ci := 0; ci < count; ci++ {
											a *= cv
										}
									}
								} else {
									// Counter accumulator: sum/product of range.
									switch op {
									case "+":
										// sum(start..end-1) = count*(start+end-1)/2
										a += count * (start + end - 1) / 2
									case "-":
										a -= count * (start + end - 1) / 2
									case "*":
										for i := start; i < end; i++ {
											a *= i
										}
									}
								}
								ev.scope[setStmt.Name] = intVal(a)
								ev.scope[n.Name] = intVal(end - 1)
								return nil
							}
						}
					}
				}
			}
		}

	generalLoop:

		// General range loop with counter mutation.
		for i := start; i < end; i++ {
			counter.num = i
			counter.n = nil
			ev.scope[n.Name] = counter
			for _, stmt := range n.Body {
				err := ev.execTop(stmt)
				if errors.Is(err, errBreak) {
					return nil
				}
				if err != nil {
					return err
				}
			}
		}
		return nil
	}

	iter, err := ev.evalExpr(n.Iter)
	if err != nil {
		return err
	}
	items := ev.valueToItems(iter)
	for _, item := range items {
		ev.scope[n.Name] = item
		for _, stmt := range n.Body {
			err := ev.execTop(stmt)
			if errors.Is(err, errBreak) {
				return nil
			}
			if err != nil {
				return err
			}
		}
	}
	return nil
}

// execTopWhile handles while at top level.
func (ev *evaluator) execTopWhile(n *WhileStmt) error {
	// Structural shortcut: while COND where COND is a comparison
	// involving a scope variable. Evaluate the condition using
	// the fast int path when possible.
	for {
		cond, err := ev.evalExpr(n.Cond)
		if err != nil {
			return err
		}
		if !cond.truthy() {
			break
		}
		for _, stmt := range n.Body {
			err := ev.execTop(stmt)
			if errors.Is(err, errBreak) {
				return nil
			}
			if err != nil {
				return err
			}
		}
	}
	return nil
}

// execShapeDecl adds a shape to the engine.
func (ev *evaluator) execShapeDecl(d *ShapeDecl) error {
	s := d.ToShape()
	ev.eng.AddShape(s)
	return nil
}

// execFnDecl registers a transform function AND decomposes it as a shape.
// Also makes the function callable from shape-lang.
func (ev *evaluator) execFnDecl(d *FnDecl) error {
	ev.fns[d.Name] = d

	// Register as engine transform.
	ev.eng.RegisterTransform(&langTransform{
		name: d.Name,
		decl: d,
		ev:   ev,
	})

	// Decompose: the fn declaration becomes a shape.
	if ev.ns != "" {
		ev.eng.AddShape(&shape.Shape{
			ID: shape.ID(ev.ns + ".fn." + d.Name),
			Character: shape.Character{
				Dimensions: map[string]string{
					"type":   "fn",
					"params": text.Join(d.Params, ", "),
				},
			},
			Structure: shape.Structure{
				Emergence: shape.Emergence{Layer: 4},
			},
		})
	}

	return nil
}

// execEdit calls engine.Edit and propagates the wave.
func (ev *evaluator) execEdit(e *EditStmt) error {
	v, err := ev.evalExpr(e.Expr)
	if err != nil {
		return err
	}

	report, err := ev.eng.Edit(shape.ID(e.ID), v.String())
	if err != nil {
		return err
	}

	// Decompose: the edit statement becomes a shape.
	if ev.ns != "" {
		ev.eng.AddShape(&shape.Shape{
			ID: shape.ID(fmt.Sprintf("%s.edit.%d", ev.ns, ev.edits)),
			Character: shape.Character{
				Dimensions: map[string]string{
					"type":   "edit",
					"target": e.ID,
				},
				Content: v.String(),
			},
			Structure: shape.Structure{
				Transformation: shape.Transformation{
					Deps: []shape.ID{shape.ID(e.ID)},
				},
				Emergence: shape.Emergence{Layer: 4},
			},
		})
		ev.edits++
	}

	if report != nil && (len(report.AutoUpdated) > 0 || len(report.NewerAvailable) > 0) {
		ev.out.WriteString(fmt.Sprintf("wave t%d: %d auto-updated, %d flagged\n",
			report.Tick, len(report.AutoUpdated), len(report.NewerAvailable)))
	}

	return nil
}

// execLet binds a name in scope.
func (ev *evaluator) execLet(l *LetStmt) error {
	v, err := ev.evalExpr(l.Expr)
	if err != nil {
		return err
	}
	ev.scope[l.Name] = v
	return nil
}

// execSet mutates an existing variable binding.
func (ev *evaluator) execSet(s *SetStmt) error {
	// Structural shortcut: set NAME = NAME op EXPR where both are ints.
	// Mutate the accumulator in place. No allocation.
	if binop, ok := s.Expr.(*BinOp); ok {
		if ident, ok := binop.Left.(*Ident); ok && ident.Name == s.Name {
			if existing, ok := ev.scope[s.Name]; ok && existing.kind == "int" {
				right, err := ev.evalExpr(binop.Right)
				if err != nil {
					return err
				}
				if right.kind == "int" {
					switch binop.Op {
					case "+":
						existing.num += right.num
						existing.n = nil
						ev.scope[s.Name] = existing
						return nil
					case "-":
						existing.num -= right.num
						existing.n = nil
						ev.scope[s.Name] = existing
						return nil
					case "*":
						existing.num *= right.num
						existing.n = nil
						ev.scope[s.Name] = existing
						return nil
					}
				}
			}
		}
	}

	// Structural shortcut: set NAME = append(NAME, item).
	// Grow the list in place. No copy.
	if call, ok := s.Expr.(*CallExpr); ok && call.Fn == "append" && len(call.Args) == 2 {
		if ident, ok := call.Args[0].(*Ident); ok && ident.Name == s.Name {
			if existing, ok := ev.scope[s.Name]; ok && existing.kind == "list" {
				item, err := ev.evalExpr(call.Args[1])
				if err != nil {
					return err
				}
				existing.list = append(existing.list, item)
				ev.scope[s.Name] = existing
				return nil
			}
		}
	}

	v, err := ev.evalExpr(s.Expr)
	if err != nil {
		return err
	}
	ev.scope[s.Name] = v
	return nil
}

// execAssert checks a coherence law.
func (ev *evaluator) execAssert(a *AssertStmt) error {
	s, ok := ev.eng.GetShape(shape.ID(a.ID))
	if !ok {
		return fmt.Errorf("assert: shape not found: %s", a.ID)
	}

	switch a.Law {
	case 0:
		ev.out.WriteString(fmt.Sprintf("assert law0 %s: ok (persists)\n", a.ID))
	case 1:
		for _, dep := range s.Structure.Transformation.Deps {
			if _, ok := ev.eng.GetShape(dep); !ok {
				return fmt.Errorf("assert law1 %s: dangling ref %s", a.ID, dep)
			}
		}
		ev.out.WriteString(fmt.Sprintf("assert law1 %s: ok (refs close)\n", a.ID))
	case 2:
		if len(s.Character.Dimensions) == 0 && s.Character.Content == "" {
			return fmt.Errorf("assert law2 %s: empty shape (no structure)", a.ID)
		}
		ev.out.WriteString(fmt.Sprintf("assert law2 %s: ok (has structure)\n", a.ID))
	case 3:
		if len(s.Structure.Permissions.Blocked) > 0 {
			return fmt.Errorf("assert law3 %s: has blocked authors (contradiction in contact)", a.ID)
		}
		ev.out.WriteString(fmt.Sprintf("assert law3 %s: ok (no contradictions)\n", a.ID))
	default:
		return fmt.Errorf("assert: unknown law %d", a.Law)
	}
	return nil
}

func (ev *evaluator) execBlock(b *BlockStmt) error {
	_, err := ev.eng.Block(shape.ID(b.ShapeID), shape.ID(b.Author), b.Warning)
	return err
}

func (ev *evaluator) execUse(u *UseStmt) error {
	// Record the dependency as a shape.
	if ev.ns != "" {
		ev.eng.AddShape(&shape.Shape{
			ID: shape.ID(ev.ns + ".use." + sanitizeID(u.Path)),
			Character: shape.Character{
				Dimensions: map[string]string{"type": "use", "path": u.Path},
			},
			Structure: shape.Structure{
				Emergence: shape.Emergence{Layer: 4},
			},
		})
	}

	// Load the referenced shape's content and evaluate it in this scope.
	// This makes fn definitions from library shapes available to the caller.
	sh, ok := ev.eng.GetShape(shape.ID(u.Path))
	if !ok {
		return nil // Shape not found; silent (might be a file path use).
	}
	if sh.Character.Content == "" {
		return nil
	}

	// Prevent infinite recursion.
	if ev.used == nil {
		ev.used = make(map[string]bool)
	}
	if ev.used[u.Path] {
		return nil
	}
	ev.used[u.Path] = true

	prog, err := Parse(sh.Character.Content)
	if err != nil {
		return fmt.Errorf("use %s: %w", u.Path, err)
	}

	// Evaluate in the current evaluator so fn defs register here.
	_, err = ev.run(prog)
	return err
}

// --- Expression evaluation ---

func (ev *evaluator) evalExpr(expr Expr) (value, error) {
	switch e := expr.(type) {
	case *StringLit:
		return strVal(e.Value), nil
	case *IntLit:
		return intVal(e.Value), nil
	case *FloatLit:
		return floatVal(e.Value), nil
	case *Ident:
		return ev.resolveIdent(e.Name)
	case *ListLit:
		elems := make([]value, len(e.Elems))
		for i, el := range e.Elems {
			v, err := ev.evalExpr(el)
			if err != nil {
				return nilVal(), err
			}
			elems[i] = v
		}
		return listVal(elems), nil
	case *MapLit:
		m := make(map[string]value, len(e.Keys))
		for i, k := range e.Keys {
			v, err := ev.evalExpr(e.Vals[i])
			if err != nil {
				return nilVal(), err
			}
			m[k] = v
		}
		return mapVal(m), nil
	case *BinOp:
		return ev.evalBinOp(e)
	case *UnaryOp:
		operand, err := ev.evalExpr(e.Operand)
		if err != nil {
			return nilVal(), err
		}
		if e.Op == "!" {
			return boolVal(!operand.truthy()), nil
		}
		return nilVal(), fmt.Errorf("unknown unary op: %s", e.Op)
	case *CallExpr:
		return ev.evalCall(e)
	case *QueryExpr:
		return ev.evalQuery(e)
	default:
		return nilVal(), fmt.Errorf("unknown expression type: %T", expr)
	}
}

func (ev *evaluator) resolveIdent(name string) (value, error) {
	if v, ok := ev.scope[name]; ok {
		return v, nil
	}
	if s, ok := ev.eng.GetShape(shape.ID(name)); ok {
		return strVal(s.Character.Content), nil
	}
	if name == "true" {
		return boolVal(true), nil
	}
	if name == "false" {
		return boolVal(false), nil
	}
	return nilVal(), nil
}

func (ev *evaluator) evalBinOp(b *BinOp) (value, error) {
	left, err := ev.evalExpr(b.Left)
	if err != nil {
		return nilVal(), err
	}
	right, err := ev.evalExpr(b.Right)
	if err != nil {
		return nilVal(), err
	}

	// Helper: true if either operand is float.
	eitherFloat := left.kind == "float" || right.kind == "float"

	switch b.Op {
	case "+":
		if eitherFloat {
			return floatVal(left.asFloat() + right.asFloat()), nil
		}
		if left.kind == "int" && right.kind == "int" {
			return intVal(left.num + right.num), nil
		}
		return strVal(left.String() + right.String()), nil
	case "-":
		if eitherFloat {
			return floatVal(left.asFloat() - right.asFloat()), nil
		}
		return intVal(left.num - right.num), nil
	case "*":
		if eitherFloat {
			return floatVal(left.asFloat() * right.asFloat()), nil
		}
		return intVal(left.num * right.num), nil
	case "/":
		if left.kind == "int" && right.kind == "int" {
			if right.num == 0 {
				return intVal(0), nil
			}
			return intVal(left.num / right.num), nil
		}
		return numVal(left.arithNum().Div(right.arithNum())), nil
	case "%":
		if left.kind == "int" && right.kind == "int" {
			if right.num == 0 {
				return intVal(0), nil
			}
			return intVal(left.num % right.num), nil
		}
		return numVal(left.arithNum().Mod(right.arithNum())), nil
	case "==":
		if eitherFloat {
			return boolVal(left.asFloat() == right.asFloat()), nil
		}
		return boolVal(left.String() == right.String()), nil
	case "!=":
		if eitherFloat {
			return boolVal(left.asFloat() != right.asFloat()), nil
		}
		return boolVal(left.String() != right.String()), nil
	case "&&":
		return boolVal(left.truthy() && right.truthy()), nil
	case "||":
		return boolVal(left.truthy() || right.truthy()), nil
	case "in":
		return ev.evalIn(left, right), nil
	case ">":
		if eitherFloat {
			return boolVal(left.asFloat() > right.asFloat()), nil
		}
		return boolVal(left.num > right.num), nil
	case "<":
		if eitherFloat {
			return boolVal(left.asFloat() < right.asFloat()), nil
		}
		return boolVal(left.num < right.num), nil
	case ">=":
		if eitherFloat {
			return boolVal(left.asFloat() >= right.asFloat()), nil
		}
		return boolVal(left.num >= right.num), nil
	case "<=":
		if eitherFloat {
			return boolVal(left.asFloat() <= right.asFloat()), nil
		}
		return boolVal(left.num <= right.num), nil
	default:
		return nilVal(), fmt.Errorf("unknown operator: %s", b.Op)
	}
}

func (ev *evaluator) evalIn(needle, haystack value) value {
	switch haystack.kind {
	case "string":
		return boolVal(text.Contains(haystack.str, needle.String()))
	case "list":
		target := needle.String()
		for _, elem := range haystack.list {
			if elem.String() == target {
				return boolVal(true)
			}
		}
		return boolVal(false)
	case "shapes":
		target := needle.String()
		for _, s := range haystack.shapes {
			if string(s.ID) == target {
				return boolVal(true)
			}
		}
		return boolVal(false)
	default:
		return boolVal(false)
	}
}

// --- Builtin functions (syscalls) ---
//
// These are the kernel interface. Everything above can be shape-lang.
// Shape I/O: content, dim, dims, deps, dependents, layer, from, produces, ancestry, depth, tick, children, exists
// Mutation:  add_shape, remove, set_content, set_dim
// Strings:   contains, split, join, has_prefix, has_suffix, replace, trim, repeat, substr
// Lists:     len, sort_list, append, head, tail, range, index
// Control:   default, if_val
// Output:    print
// Engine:    validate, status

func (ev *evaluator) evalCall(c *CallExpr) (value, error) {
	args := make([]value, len(c.Args))
	for i, a := range c.Args {
		v, err := ev.evalExpr(a)
		if err != nil {
			return nilVal(), err
		}
		args[i] = v
	}

	switch c.Fn {

	// --- Output ---

	case "print":
		for i, a := range args {
			if i > 0 {
				ev.out.WriteByte(' ')
			}
			ev.out.WriteString(a.String())
		}
		ev.out.WriteByte('\n')
		return nilVal(), nil

	case "write":
		// Like print but no trailing newline.
		for _, a := range args {
			ev.out.WriteString(a.String())
		}
		return nilVal(), nil

	case "navigate":
		// Signal the host to open a URL in a new tab.
		// The \x00NAV: prefix is intercepted by the WebSocket handler.
		// In stdin mode, the shell strips it and prints the URL.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("navigate: need URL")
		}
		ev.out.WriteString("\x00NAV:" + args[0].String() + "\n")
		return nilVal(), nil

	// --- Shape I/O ---

	case "content":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("content: need 1 arg")
		}
		s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		if !ok {
			return strVal(""), nil
		}
		return strVal(s.Character.Content), nil

	case "dim":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("dim: need 2 args (id, key)")
		}
		s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		if !ok {
			return strVal(""), nil
		}
		return strVal(s.Character.Dimensions[args[1].String()]), nil

	case "dims":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("dims: need 1 arg")
		}
		s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		if !ok {
			return nilVal(), nil
		}
		keys := make([]string, 0, len(s.Character.Dimensions))
		for k := range s.Character.Dimensions {
			keys = append(keys, k)
		}
		text.Sort(keys)
		maxKey := 0
		for _, k := range keys {
			if len(k) > maxKey {
				maxKey = len(k)
			}
		}
		var parts []string
		for _, k := range keys {
			parts = append(parts, fmt.Sprintf("%-*s  %s", maxKey, k, s.Character.Dimensions[k]))
		}
		return strVal(text.Join(parts, "\n")), nil

	case "deps":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("deps: need 1 arg")
		}
		s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		if !ok {
			return listVal(nil), nil
		}
		depIDs := make([]value, len(s.Structure.Transformation.Deps))
		for i, d := range s.Structure.Transformation.Deps {
			depIDs[i] = strVal(string(d))
		}
		return listVal(depIDs), nil

	case "dependents":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("dependents: need 1 arg")
		}
		depIDs := ev.eng.Dependents(shape.ID(args[0].String()))
		vals := make([]value, len(depIDs))
		for i, d := range depIDs {
			vals[i] = strVal(string(d))
		}
		return listVal(vals), nil

	case "layer":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("layer: need 1 arg")
		}
		s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		if !ok {
			return intVal(0), nil
		}
		return intVal(s.Structure.Emergence.Layer), nil

	case "from":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("from: need shape id")
		}
		id := shape.ID(args[0].String())
		s, ok := ev.eng.GetShape(id)
		if !ok {
			return listVal(nil), nil
		}
		var items []value
		for _, f := range s.Structure.Emergence.From {
			items = append(items, strVal(string(f)))
		}
		return listVal(items), nil

	case "produces":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("produces: need shape id")
		}
		id := shape.ID(args[0].String())
		s, ok := ev.eng.GetShape(id)
		if !ok {
			return listVal(nil), nil
		}
		var items []value
		for _, p := range s.Structure.Emergence.Produces {
			items = append(items, strVal(string(p)))
		}
		return listVal(items), nil

	case "ancestry":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("ancestry: need shape id")
		}
		id := args[0].String()
		var chain []value
		for {
			dot := text.LastIndex(id, ".")
			if dot < 0 {
				chain = append(chain, strVal(""))
				break
			}
			id = id[:dot]
			chain = append(chain, strVal(id))
		}
		return listVal(chain), nil

	case "depth":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("depth: need shape id")
		}
		id := args[0].String()
		if id == "" {
			return intVal(0), nil
		}
		return intVal(text.Count(id, ".") + 1), nil

	case "tick":
		if len(args) >= 1 {
			s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
			if !ok {
				return intVal(0), nil
			}
			return intVal(int(s.Tick)), nil
		}
		return intVal(int(ev.eng.Tick())), nil

	case "exists":
		if len(args) < 1 {
			return boolVal(false), nil
		}
		_, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		return boolVal(ok), nil

	case "children":
		// children(prefix) → list of next-level segment strings.
		// O(1) lookup from engine's children index.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("children: need 1 arg")
		}
		prefix := args[0].String()
		kids := ev.eng.Children(prefix)
		segments := make([]value, 0, len(kids))
		seen := make(map[string]bool, len(kids))
		for _, seg := range kids {
			if seg != "" && !seen[seg] {
				seen[seg] = true
				segments = append(segments, strVal(seg))
			}
		}
		return listVal(segments), nil

	case "shapes_under":
		// shapes_under(prefix) → list of all shape IDs under prefix.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("shapes_under: need 1 arg")
		}
		prefix := args[0].String()
		var ids []value
		for _, s := range ev.eng.Shapes() {
			id := string(s.ID)
			if prefix == "" || id == prefix || text.HasPrefix(id, prefix+".") {
				ids = append(ids, strVal(id))
			}
		}
		return listVal(ids), nil

	case "shape_count":
		return intVal(ev.eng.ShapeCount()), nil

	// --- Shape mutation ---

	case "add_shape":
		// add_shape(id, type, content) or add_shape(id, type, content, layer)
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("add_shape: need at least 2 args (id, type)")
		}
		id := args[0].String()
		typ := args[1].String()
		cnt := ""
		if len(args) >= 3 {
			cnt = args[2].String()
		}
		lay := 0
		if len(args) >= 4 {
			lay = args[3].num
		}
		ev.eng.AddShape(&shape.Shape{
			ID: shape.ID(id),
			Character: shape.Character{
				Dimensions: map[string]string{"type": typ},
				Content:    cnt,
			},
			Structure: shape.Structure{
				Emergence: shape.Emergence{Layer: lay},
			},
		})
		return nilVal(), nil

	case "add_dep":
		// add_dep(shape_id, dep_id) → adds a dependency to a shape.
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("add_dep: need (shape_id, dep_id)")
		}
		sid := shape.ID(args[0].String())
		did := shape.ID(args[1].String())
		s, ok := ev.eng.GetShape(sid)
		if !ok {
			return nilVal(), fmt.Errorf("add_dep: shape %s not found", sid)
		}
		// Avoid duplicate deps.
		for _, d := range s.Structure.Transformation.Deps {
			if d == did {
				return nilVal(), nil
			}
		}
		s.Structure.Transformation.Deps = append(s.Structure.Transformation.Deps, did)
		ev.eng.AddShape(s)
		return nilVal(), nil

	case "remove":
		// remove(id) → removes shape. Returns bool (success).
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("remove: need 1 arg")
		}
		id := shape.ID(args[0].String())
		// Check for dependents (Law 2).
		deps := ev.eng.Dependents(id)
		if len(deps) > 0 {
			return boolVal(false), fmt.Errorf("remove: %s has %d dependents (Law 2)", id, len(deps))
		}
		ev.eng.RemoveShape(id)
		return boolVal(true), nil

	case "set_content":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("set_content: need 2 args (id, content)")
		}
		id := shape.ID(args[0].String())
		s, ok := ev.eng.GetShape(id)
		if !ok {
			return nilVal(), fmt.Errorf("set_content: shape not found: %s", id)
		}
		s.Character.Content = args[1].String()
		ev.eng.AddShape(s)
		return nilVal(), nil

	case "set_dim":
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("set_dim: need 3 args (id, key, value)")
		}
		id := shape.ID(args[0].String())
		s, ok := ev.eng.GetShape(id)
		if !ok {
			return nilVal(), fmt.Errorf("set_dim: shape not found: %s", id)
		}
		if s.Character.Dimensions == nil {
			s.Character.Dimensions = make(map[string]string)
		}
		s.Character.Dimensions[args[1].String()] = args[2].String()
		ev.eng.AddShape(s)
		return nilVal(), nil

	// --- String operations ---

	case "contains":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("contains: need 2 args")
		}
		return boolVal(text.Contains(args[0].String(), args[1].String())), nil

	case "starts_with":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("starts_with: need 2 args")
		}
		return boolVal(text.HasPrefix(args[0].String(), args[1].String())), nil

	case "ends_with":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("ends_with: need 2 args")
		}
		return boolVal(text.HasSuffix(args[0].String(), args[1].String())), nil

	case "substring":
		// substring(str, start) or substring(str, start, end)
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("substring: need at least 2 args")
		}
		s := args[0].String()
		start := args[1].num
		if start < 0 {
			start = 0
		}
		if start >= len(s) {
			return strVal(""), nil
		}
		if len(args) >= 3 {
			end := args[2].num
			if end > len(s) {
				end = len(s)
			}
			if end <= start {
				return strVal(""), nil
			}
			return strVal(s[start:end]), nil
		}
		return strVal(s[start:]), nil

	case "index_of":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("index_of: need 2 args")
		}
		return intVal(text.Index(args[0].String(), args[1].String())), nil

	case "at":
		// at(list_or_string, index)
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("at: need 2 args")
		}
		idx := args[1].num
		if args[0].kind == "list" {
			if idx < 0 || idx >= len(args[0].list) {
				return nilVal(), nil
			}
			return args[0].list[idx], nil
		}
		s := args[0].String()
		if idx < 0 || idx >= len(s) {
			return strVal(""), nil
		}
		return strVal(string(s[idx])), nil

	case "split":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("split: need 2 args (str, sep)")
		}
		parts := text.Split(args[0].String(), args[1].String())
		vals := make([]value, len(parts))
		for i, p := range parts {
			vals[i] = strVal(p)
		}
		return listVal(vals), nil

	case "join":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("join: need 2 args (list, sep)")
		}
		sep := args[1].String()
		var parts []string
		switch args[0].kind {
		case "list":
			for _, v := range args[0].list {
				parts = append(parts, v.String())
			}
		case "shapes":
			for _, s := range args[0].shapes {
				parts = append(parts, string(s.ID))
			}
		default:
			return strVal(args[0].String()), nil
		}
		return strVal(text.Join(parts, sep)), nil

	case "has_prefix":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("has_prefix: need 2 args")
		}
		return boolVal(text.HasPrefix(args[0].String(), args[1].String())), nil

	case "has_suffix":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("has_suffix: need 2 args")
		}
		return boolVal(text.HasSuffix(args[0].String(), args[1].String())), nil

	case "replace":
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("replace: need 3 args (str, old, new)")
		}
		return strVal(text.ReplaceAll(args[0].String(), args[1].String(), args[2].String())), nil

	case "trim":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("trim: need 1 arg")
		}
		return strVal(text.TrimSpace(args[0].String())), nil

	case "repeat":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("repeat: need 2 args (str, n)")
		}
		return strVal(text.Repeat(args[0].String(), args[1].num)), nil

	case "substr":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("substr: need 2-3 args (str, start, [end])")
		}
		s := args[0].String()
		start := args[1].num
		if start < 0 {
			start = 0
		}
		if start > len(s) {
			return strVal(""), nil
		}
		if len(args) >= 3 {
			end := args[2].num
			if end > len(s) {
				end = len(s)
			}
			if end <= start {
				return strVal(""), nil
			}
			return strVal(s[start:end]), nil
		}
		return strVal(s[start:]), nil

	case "upper":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(text.ToUpper(args[0].String())), nil

	case "lower":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(text.ToLower(args[0].String())), nil

	case "pad_right":
		// pad_right(str, width) → right-pad with spaces.
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("pad_right: need 2 args")
		}
		s := args[0].String()
		width := args[1].num
		if len(s) >= width {
			return strVal(s), nil
		}
		return strVal(s + text.Repeat(" ", width-len(s))), nil

	case "pad_left":
		// pad_left(str, width) → left-pad with spaces.
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("pad_left: need 2 args")
		}
		s := args[0].String()
		width := args[1].num
		if len(s) >= width {
			return strVal(s), nil
		}
		return strVal(text.Repeat(" ", width-len(s)) + s), nil

	case "max_len":
		// max_len(list) → length of longest string in list.
		if len(args) < 1 || args[0].kind != "list" {
			return intVal(0), nil
		}
		m := 0
		for _, v := range args[0].list {
			if l := len(v.String()); l > m {
				m = l
			}
		}
		return intVal(m), nil

	// --- List operations ---

	case "len":
		if len(args) < 1 {
			return intVal(0), nil
		}
		switch args[0].kind {
		case "list":
			return intVal(len(args[0].list)), nil
		case "shapes":
			return intVal(len(args[0].shapes)), nil
		case "string":
			return intVal(len(args[0].str)), nil
		case "bytes":
			return intVal(len(args[0].buf)), nil
		case "map":
			return intVal(len(args[0].mp)), nil
		default:
			return intVal(0), nil
		}

	case "sort_list":
		if len(args) < 1 {
			return listVal(nil), nil
		}
		if args[0].kind != "list" {
			return args[0], nil
		}
		sorted := make([]value, len(args[0].list))
		copy(sorted, args[0].list)
		// Insertion sort by string representation.
		for si := 1; si < len(sorted); si++ {
			key := sorted[si]
			sj := si - 1
			for sj >= 0 && sorted[sj].String() > key.String() {
				sorted[sj+1] = sorted[sj]
				sj--
			}
			sorted[sj+1] = key
		}
		return listVal(sorted), nil

	case "append":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("append: need 2 args (list, item)")
		}
		var list []value
		if args[0].kind == "list" {
			list = make([]value, len(args[0].list))
			copy(list, args[0].list)
		}
		list = append(list, args[1])
		return listVal(list), nil

	case "head":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("head: need 2 args (list, n)")
		}
		if args[0].kind != "list" {
			return args[0], nil
		}
		n := args[1].num
		if n > len(args[0].list) {
			n = len(args[0].list)
		}
		if n < 0 {
			n = 0
		}
		return listVal(args[0].list[:n]), nil

	case "tail":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("tail: need 2 args (list, n)")
		}
		if args[0].kind != "list" {
			return args[0], nil
		}
		n := args[1].num
		total := len(args[0].list)
		if n > total {
			n = total
		}
		return listVal(args[0].list[total-n:]), nil

	case "index":
		// index(list, i) → element at index i.
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("index: need 2 args (list, i)")
		}
		if args[0].kind != "list" {
			return nilVal(), nil
		}
		i := args[1].num
		if i < 0 || i >= len(args[0].list) {
			return nilVal(), nil
		}
		return args[0].list[i], nil

	case "range":
		// range(n) → [0, 1, ..., n-1]
		// range(a, b) → [a, a+1, ..., b-1]
		if len(args) < 1 {
			return listVal(nil), nil
		}
		start := 0
		end := args[0].num
		if len(args) >= 2 {
			start = args[0].num
			end = args[1].num
		}
		if end <= start {
			return listVal(nil), nil
		}
		vals := make([]value, end-start)
		for i := start; i < end; i++ {
			vals[i-start] = intVal(i)
		}
		return listVal(vals), nil

	// --- Control flow ---

	case "default":
		// default(a, b) → a if truthy, else b.
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("default: need 2 args")
		}
		if args[0].truthy() {
			return args[0], nil
		}
		return args[1], nil

	case "if_val":
		// if_val(cond, then, else) → then if cond truthy, else else.
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("if_val: need 3 args")
		}
		if args[0].truthy() {
			return args[1], nil
		}
		return args[2], nil

	// --- Type conversion ---

	case "type":
		if len(args) < 1 {
			return strVal("nil"), nil
		}
		return strVal(args[0].kind), nil

	case "to_int":
		if len(args) < 1 {
			return intVal(0), nil
		}
		return intVal(atoi(args[0].String())), nil

	case "to_string":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(args[0].String()), nil

	case "to_float":
		if len(args) < 1 {
			return floatVal(0), nil
		}
		return floatVal(args[0].asFloat()), nil

	// --- Math builtins ---

	case "sum":
		if len(args) < 1 || args[0].kind != "list" {
			return floatVal(0), nil
		}
		total := 0.0
		allInt := true
		for _, v := range args[0].list {
			total += v.asFloat()
			if v.kind != "int" {
				allInt = false
			}
		}
		if allInt {
			return intVal(int(total)), nil
		}
		return floatVal(total), nil

	case "avg":
		if len(args) < 1 || args[0].kind != "list" || len(args[0].list) == 0 {
			return floatVal(0), nil
		}
		total := 0.0
		for _, v := range args[0].list {
			total += v.asFloat()
		}
		return floatVal(total / float64(len(args[0].list))), nil

	case "min_num":
		if len(args) < 1 || args[0].kind != "list" || len(args[0].list) == 0 {
			return floatVal(0), nil
		}
		m := args[0].list[0].asFloat()
		for _, v := range args[0].list[1:] {
			if f := v.asFloat(); f < m {
				m = f
			}
		}
		return floatVal(m), nil

	case "max_num":
		if len(args) < 1 || args[0].kind != "list" || len(args[0].list) == 0 {
			return floatVal(0), nil
		}
		m := args[0].list[0].asFloat()
		for _, v := range args[0].list[1:] {
			if f := v.asFloat(); f > m {
				m = f
			}
		}
		return floatVal(m), nil

	case "abs":
		if len(args) < 1 {
			return intVal(0), nil
		}
		if args[0].kind == "int" {
			n := args[0].num
			if n < 0 { n = -n }
			return intVal(n), nil
		}
		return numVal(args[0].arithNum().Abs()), nil

	case "round":
		if len(args) < 1 {
			return intVal(0), nil
		}
		places := 0
		if len(args) >= 2 {
			places = args[1].num
		}
		// Fast path: int with 0 places is already rounded.
		if args[0].kind == "int" && places == 0 {
			return args[0], nil
		}
		// Fast path: use float64 math for small values.
		if args[0].n == nil {
			f := args[0].asFloat()
			shift := 1.0
			for p := 0; p < places; p++ { shift *= 10 }
			rounded := float64(int(f*shift+0.5)) / shift
			return floatVal(rounded), nil
		}
		return numVal(arith.Round(args[0].arithNum(), places)), nil

	case "floor":
		if len(args) < 1 {
			return intVal(0), nil
		}
		if args[0].kind == "int" { return args[0], nil }
		return numVal(arith.Floor(args[0].arithNum())), nil

	case "ceil":
		if len(args) < 1 {
			return intVal(0), nil
		}
		if args[0].kind == "int" { return args[0], nil }
		return numVal(arith.Ceil(args[0].arithNum())), nil

	case "pow":
		if len(args) < 2 {
			return intVal(0), nil
		}
		// Fast path: small int base and exponent.
		if args[0].kind == "int" && args[1].kind == "int" && args[1].num >= 0 && args[1].num <= 62 {
			result := 1
			base := args[0].num
			exp := args[1].num
			for e := 0; e < exp; e++ {
				result *= base
			}
			return intVal(result), nil
		}
		return numVal(args[0].arithNum().Pow(args[1].arithNum())), nil

	case "mod":
		if len(args) < 2 {
			return intVal(0), nil
		}
		return numVal(args[0].arithNum().Mod(args[1].arithNum())), nil

	// --- Path operations ---

	case "resolve":
		// resolve(base, path) → resolved shape path.
		// Handles ~ as home prefix (from scope variable "home").
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("resolve: need 2 args (base, path)")
		}
		path := args[1].String()
		if path == "~" {
			if h, ok := ev.scope["home"]; ok && h.String() != "" {
				return strVal(h.String()), nil
			}
			return strVal(""), nil
		}
		if text.HasPrefix(path, "~/") {
			home := ""
			if h, ok := ev.scope["home"]; ok {
				home = h.String()
			}
			rest := path[2:]
			if home == "" {
				return strVal(rest), nil
			}
			return strVal(home + "." + rest), nil
		}
		return strVal(resolvePath(args[0].String(), path)), nil

	case "parent":
		// parent(path) → parent path ("a.b.c" → "a.b").
		if len(args) < 1 {
			return strVal(""), nil
		}
		s := args[0].String()
		i := text.LastIndex(s, ".")
		if i < 0 {
			return strVal(""), nil
		}
		return strVal(s[:i]), nil

	// --- Engine ---

	case "validate":
		result := ev.eng.Validate()
		if result.IsCoherent() {
			return strVal(fmt.Sprintf("coherent (%d shapes)", ev.eng.ShapeCount())), nil
		}
		var out text.Builder
		out.WriteString("INCOHERENT:\n")
		maxID := 0
		for _, d := range result.DanglingDeps {
			if len(string(d.Shape)) > maxID {
				maxID = len(string(d.Shape))
			}
		}
		for _, m := range result.MissingTransforms {
			if len(string(m.Shape)) > maxID {
				maxID = len(string(m.Shape))
			}
		}
		for _, d := range result.DanglingDeps {
			out.WriteString(fmt.Sprintf("  Law 1:   %-*s -> %s (dangling)\n", maxID, d.Shape, d.Dep))
		}
		for _, m := range result.MissingTransforms {
			out.WriteString(fmt.Sprintf("  Missing: %-*s requires %s\n", maxID, m.Shape, m.Transform))
		}
		return strVal(out.String()), nil

	case "status":
		st := ev.eng.Status()
		return strVal(fmt.Sprintf("Shapes:   %d\nTick:     %d\n", st.TotalShapes, st.Tick)), nil

	// --- Testing ---

	case "assert_true":
		// assert_true(condition, message) — fails if condition is false.
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("assert_true: need (condition, message)")
		}
		if !args[0].truthy() {
			return nilVal(), fmt.Errorf("FAIL: %s", args[1].String())
		}
		return strVal("PASS"), nil

	case "assert_eq":
		// assert_eq(a, b, message) — fails if a != b.
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("assert_eq: need (a, b, message)")
		}
		if args[0].String() != args[1].String() {
			return nilVal(), fmt.Errorf("FAIL: %s (got %q, want %q)", args[2].String(), args[0].String(), args[1].String())
		}
		return strVal("PASS"), nil

	case "assert_neq":
		// assert_neq(a, b, message) — fails if a == b.
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("assert_neq: need (a, b, message)")
		}
		if args[0].String() == args[1].String() {
			return nilVal(), fmt.Errorf("FAIL: %s (got %q, should differ)", args[2].String(), args[0].String())
		}
		return strVal("PASS"), nil

	case "assert_contains":
		// assert_contains(haystack, needle, message) — fails if needle not in haystack.
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("assert_contains: need (haystack, needle, message)")
		}
		if !text.Contains(args[0].String(), args[1].String()) {
			return nilVal(), fmt.Errorf("FAIL: %s (string %q not found in %q)", args[2].String(), args[1].String(), args[0].String())
		}
		return strVal("PASS"), nil

	case "assert_gt":
		// assert_gt(a, b, message) — fails if a <= b (integer comparison).
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("assert_gt: need (a, b, message)")
		}
		if args[0].num <= args[1].num {
			return nilVal(), fmt.Errorf("FAIL: %s (got %d, want > %d)", args[2].String(), args[0].num, args[1].num)
		}
		return strVal("PASS"), nil

	case "render":
		// render(id) or render(id, scope_map) — evaluate a shape's content
		// in a sandboxed evaluator and return the output.
		// This is how shapes compose: a parent shape renders its children
		// by calling render() on each child and composing the results.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("render: need shape ID")
		}
		id := args[0].String()
		sh, ok := ev.eng.GetShape(shape.ID(id))
		if !ok {
			return strVal(""), nil
		}
		if sh.Character.Content == "" {
			return strVal(""), nil
		}
		renderProg, renderErr := Parse(sh.Character.Content)
		if renderErr != nil {
			// Parse failed: content is raw (HTML/CSS/JS), return as-is.
			return strVal(sh.Character.Content), nil
		}
		// If no executable statements, return raw content.
		hasExec := false
		for _, stmt := range renderProg.Stmts {
			if stmt.nodeType() != "shape" {
				hasExec = true
				break
			}
		}
		if !hasExec {
			return strVal(sh.Character.Content), nil
		}
		renderEv := &evaluator{
			eng:   ev.eng,
			scope: make(map[string]value),
			fns:   make(map[string]*FnDecl),
		}
		// Copy parent scope.
		for k, v := range ev.scope {
			renderEv.scope[k] = v
		}
		// Apply scope map if provided.
		if len(args) >= 2 && args[1].kind == "map" {
			for k, v := range args[1].mp {
				if k != "_map" {
					renderEv.scope[k] = v
				}
			}
		}
		_, renderErr = renderEv.run(renderProg)
		if renderErr != nil {
			return strVal(""), nil
		}
		return strVal(renderEv.out.String()), nil

	case "test_shape":
		// test_shape(id) — run a test shape in a sandboxed evaluator.
		// Returns "PASS" or "FAIL: error message".
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("test_shape: need shape ID")
		}
		id := args[0].String()
		sh, ok := ev.eng.GetShape(shape.ID(id))
		if !ok {
			return strVal("FAIL: shape not found: " + id), nil
		}
		if sh.Character.Content == "" {
			return strVal("FAIL: empty test shape: " + id), nil
		}
		prog, err := Parse(sh.Character.Content)
		if err != nil {
			return strVal("FAIL: parse error: " + err.Error()), nil
		}
		testEv := &evaluator{
			eng:   ev.eng,
			scope: make(map[string]value),
			fns:   make(map[string]*FnDecl),
		}
		// Copy parent scope so tests see prefix etc.
		for k, v := range ev.scope {
			testEv.scope[k] = v
		}
		_, err = testEv.run(prog)
		if err != nil {
			return strVal("FAIL: " + err.Error()), nil
		}
		return strVal("PASS"), nil

	case "test_shapes_under":
		// test_shapes_under(prefix) — find all test shapes under prefix, run each.
		// Returns list of [id, result] pairs as formatted string.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("test_shapes_under: need prefix")
		}
		prefix := args[0].String()
		verbose := len(args) >= 2 && args[1].truthy()

		var results []value
		passed := 0
		failed := 0
		var failDetails text.Builder

		for _, s := range ev.eng.Shapes() {
			id := string(s.ID)
			if !text.HasPrefix(id, prefix+".") && id != prefix {
				continue
			}
			if s.Character.Dimensions["type"] != "test" {
				continue
			}
			if s.Character.Content == "" {
				continue
			}

			prog, err := Parse(s.Character.Content)
			if err != nil {
				failed++
				failDetails.WriteString(fmt.Sprintf("  FAIL  %s\n        parse: %s\n", id, err))
				results = append(results, strVal("FAIL:"+id))
				continue
			}

			testEv := &evaluator{
				eng:   ev.eng,
				scope: make(map[string]value),
				fns:   make(map[string]*FnDecl),
			}
			for k, v := range ev.scope {
				testEv.scope[k] = v
			}

			_, err = testEv.run(prog)
			if err != nil {
				failed++
				// Extract short name from ID.
				short := id
				if i := text.LastIndex(id, "."); i >= 0 {
					short = id[i+1:]
				}
				failDetails.WriteString(fmt.Sprintf("  FAIL  %-24s %s\n", short, err))
				results = append(results, strVal("FAIL:"+id))
			} else {
				passed++
				if verbose {
					short := id
					if i := text.LastIndex(id, "."); i >= 0 {
						short = id[i+1:]
					}
					desc := s.Character.Dimensions["desc"]
					if desc == "" {
						desc = short
					}
					ev.out.WriteString(fmt.Sprintf("  PASS  %-24s %s\n", short, desc))
				}
				results = append(results, strVal("PASS:"+id))
			}
		}

		if failDetails.Len() > 0 {
			ev.out.WriteString(failDetails.String())
		}

		return listVal([]value{intVal(passed), intVal(failed)}), nil

	// --- Moment Navigation & Trace ---

	case "actor":
		// actor() — return the current session actor.
		return strVal(ev.eng.Actor()), nil

	case "set_actor":
		// set_actor(user_id) — set the current session actor.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("set_actor: need user ID")
		}
		ev.eng.SetActor(args[0].String())
		return strVal(args[0].String()), nil

	case "shape_tick":
		// shape_tick(id) — return the tick when this shape was last modified.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("shape_tick: need shape ID")
		}
		s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		if !ok {
			return intVal(0), nil
		}
		return intVal(int(s.Tick)), nil

	case "global_tick":
		// global_tick() — return current global tick.
		return intVal(int(ev.eng.Tick())), nil

	case "ticks_between":
		// ticks_between(id_a, id_b) — structural distance: |tick_a - tick_b|.
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("ticks_between: need (id_a, id_b)")
		}
		var tickA, tickB int
		if s, ok := ev.eng.GetShape(shape.ID(args[0].String())); ok {
			tickA = int(s.Tick)
		}
		if s, ok := ev.eng.GetShape(shape.ID(args[1].String())); ok {
			tickB = int(s.Tick)
		}
		diff := tickA - tickB
		if diff < 0 {
			diff = -diff
		}
		return intVal(diff), nil

	case "is_latest":
		// is_latest(id) — true if shape's tick equals the global tick.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("is_latest: need shape ID")
		}
		s, ok := ev.eng.GetShape(shape.ID(args[0].String()))
		if !ok {
			return boolVal(false), nil
		}
		return boolVal(s.Tick == ev.eng.Tick()), nil

	// --- Trace moments ---

	case "moments":
		// moments() → total moment count.
		// moments(action) → count of moments with given action.
		if len(args) >= 1 {
			filter := args[0].String()
			count := 0
			for _, m := range ev.eng.Moments() {
				if m.Action == filter {
					count++
				}
			}
			return intVal(count), nil
		}
		return intVal(ev.eng.MomentCount()), nil

	case "moment_at":
		// moment_at(index) → map {tick, actor, action, target}
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("moment_at: need index")
		}
		m, ok := ev.eng.MomentAt(args[0].num)
		if !ok {
			return nilVal(), nil
		}
		result := map[string]value{
			"tick":   intVal(int(m.Tick)),
			"actor":  strVal(m.Actor),
			"action": strVal(m.Action),
			"target": strVal(string(m.Target)),
		}
		return mapVal(result), nil

	case "moment_action":
		// moment_action(index) → action string
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("moment_action: need index")
		}
		m, ok := ev.eng.MomentAt(args[0].num)
		if !ok {
			return strVal(""), nil
		}
		return strVal(m.Action), nil

	case "moment_target":
		// moment_target(index) → target shape ID
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("moment_target: need index")
		}
		m, ok := ev.eng.MomentAt(args[0].num)
		if !ok {
			return strVal(""), nil
		}
		return strVal(string(m.Target)), nil

	case "moment_actor":
		// moment_actor(index) → actor string
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("moment_actor: need index")
		}
		m, ok := ev.eng.MomentAt(args[0].num)
		if !ok {
			return strVal(""), nil
		}
		return strVal(m.Actor), nil

	case "moment_tick":
		// moment_tick(index) → tick at moment
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("moment_tick: need index")
		}
		m, ok := ev.eng.MomentAt(args[0].num)
		if !ok {
			return intVal(0), nil
		}
		return intVal(int(m.Tick)), nil

	case "moment_wave":
		// moment_wave(index) → map with wave details (auto_updated, flagged, etc.)
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("moment_wave: need index")
		}
		m, ok := ev.eng.MomentAt(args[0].num)
		if !ok {
			return nilVal(), nil
		}
		if m.Report == nil {
			return mapVal(map[string]value{}), nil
		}
		autoList := make([]value, len(m.Report.AutoUpdated))
		for i, id := range m.Report.AutoUpdated {
			autoList[i] = strVal(string(id))
		}
		flagList := make([]value, len(m.Report.NewerAvailable))
		for i, id := range m.Report.NewerAvailable {
			flagList[i] = strVal(string(id))
		}
		lockList := make([]value, len(m.Report.Locked))
		for i, id := range m.Report.Locked {
			lockList[i] = strVal(string(id))
		}
		withdrawList := make([]value, len(m.Report.Withdrawn))
		for i, id := range m.Report.Withdrawn {
			withdrawList[i] = strVal(string(id))
		}
		result := map[string]value{
			"auto_updated":    listVal(autoList),
			"newer_available": listVal(flagList),
			"locked":          listVal(lockList),
			"withdrawn":       listVal(withdrawList),
		}
		return mapVal(result), nil

	case "llm_call":
		// llm_call(context) → calls LLM with system prompt from os.agent.llm.prompt,
		// returns the raw response text. Each call is one moment.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("llm_call: need (context)")
		}
		return ev.llmCall(args[0].String())

	case "llm_step":
		// llm_step(task_id) → runs one agent step.
		// Reads context from task shape, calls LLM, evaluates response as shape-lang,
		// updates step count, returns step output.
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("llm_step: need (task_id)")
		}
		return ev.llmStep(args[0].String())

	case "llm_ready":
		// llm_ready() → returns "true" if LLM client is configured.
		ext, ok := ev.eng.GetExt("llm")
		if !ok {
			return boolVal(false), nil
		}
		type readyChecker interface{ Ready() bool }
		if rc, ok := ext.(readyChecker); ok {
			return boolVal(rc.Ready()), nil
		}
		return boolVal(false), nil

	// --- Hardware-level primitives (substrate boundary) ---
	// Only host OS calls, byte manipulation, and CPU-instruction equivalents.
	// All format knowledge (ZIP, PDF, TTF, base64, JSON/XML escape) is in
	// shape-lang library shapes, not here.

	// -- Unicode primitives --

	case "chr":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(string(rune(args[0].num))), nil

	case "ord":
		if len(args) < 1 || args[0].String() == "" {
			return intVal(0), nil
		}
		r := []rune(args[0].String())
		return intVal(int(r[0])), nil

	// -- Host OS file I/O --

	case "file_read":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("file_read: need path")
		}
		s, err := fileRead(args[0].String())
		if err != nil {
			return nilVal(), fmt.Errorf("file_read: %w", err)
		}
		return strVal(s), nil

	case "file_read_bytes":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("file_read_bytes: need path")
		}
		data, err := fileReadBytes(args[0].String())
		if err != nil {
			return nilVal(), fmt.Errorf("file_read_bytes: %w", err)
		}
		return bytesVal(data), nil

	case "file_write":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("file_write: need (path, content)")
		}
		if err := fileWrite(args[0].String(), args[1].String()); err != nil {
			return nilVal(), fmt.Errorf("file_write: %w", err)
		}
		return strVal("ok"), nil

	case "file_write_bytes":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("file_write_bytes: need (path, bytes)")
		}
		var data []byte
		if args[1].kind == "bytes" {
			data = args[1].buf
		} else {
			data = []byte(args[1].String())
		}
		if err := fileWriteBytes(args[0].String(), data); err != nil {
			return nilVal(), fmt.Errorf("file_write_bytes: %w", err)
		}
		return strVal("ok"), nil

	// -- Byte buffer primitives --

	case "bytes":
		// bytes(n) → zero-filled buffer of n bytes.
		if len(args) < 1 {
			return bytesVal(nil), nil
		}
		return bytesVal(make([]byte, args[0].num)), nil

	case "bytes_from":
		// bytes_from(list_of_ints) → buffer from byte values.
		if len(args) < 1 {
			return bytesVal(nil), nil
		}
		if args[0].kind == "list" {
			buf := make([]byte, len(args[0].list))
			for i, v := range args[0].list {
				buf[i] = byte(v.num & 0xFF)
			}
			return bytesVal(buf), nil
		}
		return bytesVal(nil), nil

	case "byte_get":
		// byte_get(buf, offset) → int (0-255).
		if len(args) < 2 || args[0].kind != "bytes" {
			return intVal(0), nil
		}
		off := args[1].num
		if off < 0 || off >= len(args[0].buf) {
			return intVal(0), nil
		}
		return intVal(int(args[0].buf[off])), nil

	case "byte_set":
		// byte_set(buf, offset, val) → new buffer with byte set.
		if len(args) < 3 || args[0].kind != "bytes" {
			return bytesVal(nil), nil
		}
		off := args[1].num
		if off < 0 || off >= len(args[0].buf) {
			return bytesVal(args[0].buf), nil
		}
		out := make([]byte, len(args[0].buf))
		copy(out, args[0].buf)
		out[off] = byte(args[2].num & 0xFF)
		return bytesVal(out), nil

	case "bytes_slice":
		// bytes_slice(buf, start, end) → sub-buffer.
		if len(args) < 3 || args[0].kind != "bytes" {
			return bytesVal(nil), nil
		}
		start := args[1].num
		end := args[2].num
		if start < 0 {
			start = 0
		}
		if end > len(args[0].buf) {
			end = len(args[0].buf)
		}
		if start >= end {
			return bytesVal(nil), nil
		}
		out := make([]byte, end-start)
		copy(out, args[0].buf[start:end])
		return bytesVal(out), nil

	case "bytes_concat":
		// bytes_concat(a, b) → new buffer joining a and b.
		if len(args) < 2 {
			return bytesVal(nil), nil
		}
		var a, b []byte
		if args[0].kind == "bytes" {
			a = args[0].buf
		}
		if args[1].kind == "bytes" {
			b = args[1].buf
		}
		out := make([]byte, len(a)+len(b))
		copy(out, a)
		copy(out[len(a):], b)
		return bytesVal(out), nil

	case "string_to_bytes":
		// string_to_bytes(s) → bytes (UTF-8 encoded).
		if len(args) < 1 {
			return bytesVal(nil), nil
		}
		return bytesVal([]byte(args[0].String())), nil

	case "bytes_to_string":
		// bytes_to_string(buf) → string (UTF-8 interpreted).
		if len(args) < 1 || args[0].kind != "bytes" {
			return strVal(""), nil
		}
		return strVal(string(args[0].buf)), nil

	// -- Multi-byte integer read/write (endian conversion) --

	case "read_u16_le":
		if len(args) < 2 || args[0].kind != "bytes" {
			return intVal(0), nil
		}
		return intVal(readU16LE(args[0].buf, args[1].num)), nil

	case "read_u16_be":
		if len(args) < 2 || args[0].kind != "bytes" {
			return intVal(0), nil
		}
		return intVal(readU16BE(args[0].buf, args[1].num)), nil

	case "read_u32_le":
		if len(args) < 2 || args[0].kind != "bytes" {
			return intVal(0), nil
		}
		return intVal(readU32LE(args[0].buf, args[1].num)), nil

	case "read_u32_be":
		if len(args) < 2 || args[0].kind != "bytes" {
			return intVal(0), nil
		}
		return intVal(readU32BE(args[0].buf, args[1].num)), nil

	case "read_i16_be":
		if len(args) < 2 || args[0].kind != "bytes" {
			return intVal(0), nil
		}
		return intVal(readI16BE(args[0].buf, args[1].num)), nil

	case "write_u16_le":
		if len(args) < 3 || args[0].kind != "bytes" {
			return bytesVal(nil), nil
		}
		return bytesVal(writeU16LE(args[0].buf, args[1].num, args[2].num)), nil

	case "write_u32_le":
		if len(args) < 3 || args[0].kind != "bytes" {
			return bytesVal(nil), nil
		}
		return bytesVal(writeU32LE(args[0].buf, args[1].num, args[2].num)), nil

	case "write_u16_be":
		if len(args) < 3 || args[0].kind != "bytes" {
			return bytesVal(nil), nil
		}
		return bytesVal(writeU16BE(args[0].buf, args[1].num, args[2].num)), nil

	case "write_u32_be":
		if len(args) < 3 || args[0].kind != "bytes" {
			return bytesVal(nil), nil
		}
		return bytesVal(writeU32BE(args[0].buf, args[1].num, args[2].num)), nil

	// -- CRC32 (hardware instruction equivalent) --

	case "crc32":
		if len(args) < 1 || args[0].kind != "bytes" {
			return intVal(0), nil
		}
		return intVal(int(crc32Checksum(args[0].buf))), nil

	// -- Bitwise integer operations (CPU instructions) --

	case "bit_and":
		if len(args) < 2 {
			return intVal(0), nil
		}
		return intVal(args[0].num & args[1].num), nil

	case "bit_or":
		if len(args) < 2 {
			return intVal(0), nil
		}
		return intVal(args[0].num | args[1].num), nil

	case "bit_xor":
		if len(args) < 2 {
			return intVal(0), nil
		}
		return intVal(args[0].num ^ args[1].num), nil

	case "bit_not":
		if len(args) < 1 {
			return intVal(0), nil
		}
		return intVal(^args[0].num), nil

	case "bit_shl":
		if len(args) < 2 {
			return intVal(0), nil
		}
		return intVal(args[0].num << uint(args[1].num)), nil

	case "bit_shr":
		if len(args) < 2 {
			return intVal(0), nil
		}
		return intVal(int(uint(args[0].num) >> uint(args[1].num))), nil

	// --- Map operations ---

	case "map_new":
		return mapVal(make(map[string]value)), nil

	case "map_get":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("map_get: need map and key")
		}
		if args[0].kind != "map" {
			return nilVal(), nil
		}
		v, ok := args[0].mp[args[1].String()]
		if !ok {
			if len(args) > 2 {
				return args[2], nil
			}
			return nilVal(), nil
		}
		return v, nil

	case "map_set":
		if len(args) < 3 {
			return nilVal(), fmt.Errorf("map_set: need map, key, value")
		}
		m := args[0]
		if m.kind != "map" {
			m = mapVal(make(map[string]value))
		}
		newMap := make(map[string]value, len(m.mp)+1)
		for mk, mv := range m.mp {
			newMap[mk] = mv
		}
		newMap[args[1].String()] = args[2]
		return mapVal(newMap), nil

	case "map_keys":
		if len(args) < 1 {
			return listVal(nil), nil
		}
		if args[0].kind != "map" {
			return listVal(nil), nil
		}
		var keys []value
		for k := range args[0].mp {
			keys = append(keys, strVal(k))
		}
		// Insertion sort keys by string value.
		for si := 1; si < len(keys); si++ {
			key := keys[si]
			sj := si - 1
			for sj >= 0 && keys[sj].str > key.str {
				keys[sj+1] = keys[sj]
				sj--
			}
			keys[sj+1] = key
		}
		return listVal(keys), nil

	case "map_values":
		if len(args) < 1 {
			return listVal(nil), nil
		}
		if args[0].kind != "map" {
			return listVal(nil), nil
		}
		var ks []string
		for k := range args[0].mp {
			ks = append(ks, k)
		}
		text.Sort(ks)
		var vals []value
		for _, k := range ks {
			vals = append(vals, args[0].mp[k])
		}
		return listVal(vals), nil

	case "map_has":
		if len(args) < 2 {
			return boolVal(false), nil
		}
		if args[0].kind != "map" {
			return boolVal(false), nil
		}
		_, ok := args[0].mp[args[1].String()]
		return boolVal(ok), nil

	case "map_delete":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("map_delete: need map and key")
		}
		if args[0].kind != "map" {
			return args[0], nil
		}
		newMap := make(map[string]value, len(args[0].mp))
		for mk, mv := range args[0].mp {
			newMap[mk] = mv
		}
		delete(newMap, args[1].String())
		return mapVal(newMap), nil

	case "map_merge":
		if len(args) < 2 {
			return nilVal(), fmt.Errorf("map_merge: need two maps")
		}
		newMap := make(map[string]value)
		if args[0].kind == "map" {
			for k, v := range args[0].mp {
				newMap[k] = v
			}
		}
		if args[1].kind == "map" {
			for k, v := range args[1].mp {
				newMap[k] = v
			}
		}
		return mapVal(newMap), nil

	// --- JSON ---

	case "json_encode":
		if len(args) < 1 {
			return strVal("null"), nil
		}
		return strVal(jsonEncode(args[0])), nil

	case "json_decode":
		if len(args) < 1 {
			return nilVal(), fmt.Errorf("json_decode: need string")
		}
		result, err := jsonDecode(args[0].String())
		if err != nil {
			return nilVal(), err
		}
		return result, nil

	// --- Time / env / URL ---

	case "time_now":
		return intVal(int(timeNow())), nil

	case "time_ms":
		return intVal(int(timeMs())), nil

	case "env_get":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(envGet(args[0].String())), nil

	case "url_encode":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(urlEncode(args[0].String())), nil

	case "url_decode":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(urlDecode(args[0].String())), nil

	// --- Crypto ---

	case "sha256":
		if len(args) < 1 {
			return strVal(""), nil
		}
		return strVal(cryptoHash(args[0].String())), nil

	case "ed25519_keygen":
		pub, priv := cryptoKeygen()
		m := map[string]value{"public": strVal(pub), "private": strVal(priv)}
		return mapVal(m), nil

	case "ed25519_sign":
		if len(args) < 2 {
			return strVal(""), fmt.Errorf("ed25519_sign: need data and private key")
		}
		sig, err := cryptoSign(args[0].String(), args[1].String())
		if err != nil {
			return strVal(""), err
		}
		return strVal(sig), nil

	case "ed25519_verify":
		if len(args) < 3 {
			return boolVal(false), nil
		}
		return boolVal(cryptoVerify(args[0].String(), args[1].String(), args[2].String())), nil

	// --- Shape to map ---

	case "shape_to_map":
		// Returns a map matching the Go JSON structure so JS clients work unchanged.
		// {id, character: {dimensions: {...}, content: "..."}, structure: {transformation: {deps: [...], fn: ""}, emergence: {layer: N, from: [...]}}}
		if len(args) < 1 {
			return nilVal(), nil
		}
		id := args[0].String()
		s, ok := ev.eng.GetShape(shape.ID(id))
		if !ok {
			return nilVal(), nil
		}
		dims := make(map[string]value)
		for k, dv := range s.Character.Dimensions {
			dims[k] = strVal(dv)
		}
		character := map[string]value{
			"dimensions": mapVal(dims),
			"content":    strVal(s.Character.Content),
		}
		var depsList []value
		for _, d := range s.Structure.Transformation.Deps {
			depsList = append(depsList, strVal(string(d)))
		}
		var fromList []value
		for _, f := range s.Structure.Emergence.From {
			fromList = append(fromList, strVal(string(f)))
		}
		transformation := map[string]value{
			"deps": listVal(depsList),
			"fn":   strVal(s.Structure.Transformation.Fn),
		}
		emergence := map[string]value{
			"layer": intVal(s.Structure.Emergence.Layer),
			"from":  listVal(fromList),
		}
		structure := map[string]value{
			"transformation": mapVal(transformation),
			"emergence":      mapVal(emergence),
		}
		m := map[string]value{
			"id":        strVal(string(s.ID)),
			"character": mapVal(character),
			"structure": mapVal(structure),
		}
		return mapVal(m), nil

	default:
		// User-defined functions.
		if fn, ok := ev.fns[c.Fn]; ok {
			return ev.callUserFn(fn, args)
		}
		return nilVal(), fmt.Errorf("unknown function: %s", c.Fn)
	}
}

// callUserFn calls a shape-lang fn declaration with args.
func (ev *evaluator) callUserFn(fn *FnDecl, args []value) (value, error) {
	scope := make(map[string]value)
	for i, param := range fn.Params {
		if i < len(args) {
			scope[param] = args[i]
		} else {
			scope[param] = nilVal()
		}
	}
	result, content, err := ev.execBody(fn.Body, scope)
	if err != nil {
		return nilVal(), err
	}
	if result == "auto" {
		return content, nil
	}
	return nilVal(), nil
}

// evalQuery finds shapes by pattern or filter.
func (ev *evaluator) evalQuery(q *QueryExpr) (value, error) {
	all := ev.eng.Shapes()

	if q.Pattern != "" {
		var matched []*shape.Shape
		for _, s := range all {
			if matchGlob(q.Pattern, string(s.ID)) {
				matched = append(matched, s)
			}
		}
		return shapesVal(matched), nil
	}

	if q.Filter != nil {
		var matched []*shape.Shape
		for _, s := range all {
			ev.scope["self"] = strVal(string(s.ID))
			v, err := ev.evalExpr(q.Filter)
			if err != nil {
				continue
			}
			if v.truthy() {
				matched = append(matched, s)
			}
		}
		delete(ev.scope, "self")
		return shapesVal(matched), nil
	}

	return shapesVal(all), nil
}

// --- fn body execution (for transforms and user functions) ---

// execBody runs a fn body with the given scope bindings.
// Returns the propagation result and any content.
// execBodyStmt executes a single statement in the current scope (no scope copy).
// Used by while loops so variable mutations persist across iterations.
func (ev *evaluator) execBodyStmt(stmt Node) (string, value, error) {
	switch n := stmt.(type) {
	case *ReturnStmt:
		if n.Expr != nil {
			v, err := ev.evalExpr(n.Expr)
			if err != nil {
				return n.Result, nilVal(), err
			}
			return n.Result, v, nil
		}
		return n.Result, nilVal(), nil
	case *LetStmt:
		v, err := ev.evalExpr(n.Expr)
		if err != nil {
			return "", nilVal(), err
		}
		ev.scope[n.Name] = v
	case *SetStmt:
		v, err := ev.evalExpr(n.Expr)
		if err != nil {
			return "", nilVal(), err
		}
		ev.scope[n.Name] = v
	case *BreakStmt:
		return "", nilVal(), errBreak
	case *IfStmt:
		cond, err := ev.evalExpr(n.Cond)
		if err != nil {
			return "", nilVal(), err
		}
		var branch []Node
		if cond.truthy() {
			branch = n.Then
		} else {
			branch = n.Else
		}
		for _, bs := range branch {
			r, v, e := ev.execBodyStmt(bs)
			if e != nil {
				return "", nilVal(), e
			}
			if r == "auto" || r == "flag" {
				return r, v, nil
			}
		}
	case *WhileStmt:
		whileLoop:
		for {
			cond, err := ev.evalExpr(n.Cond)
			if err != nil {
				return "", nilVal(), err
			}
			if !cond.truthy() {
				break
			}
			for _, ws := range n.Body {
				r, v, e := ev.execBodyStmt(ws)
				if errors.Is(e, errBreak) {
					break whileLoop
				}
				if e != nil {
					return "", nilVal(), e
				}
				if r == "auto" || r == "flag" {
					return r, v, nil
				}
			}
		}
	case *ForStmt:
		iter, err := ev.evalExpr(n.Iter)
		if err != nil {
			return "", nilVal(), err
		}
		items := ev.valueToItems(iter)
		for _, item := range items {
			ev.scope[n.Name] = item
			for _, fs := range n.Body {
				r, v, e := ev.execBodyStmt(fs)
				if errors.Is(e, errBreak) {
					return "", nilVal(), nil
				}
				if e != nil {
					return "", nilVal(), e
				}
				if r == "auto" || r == "flag" {
					return r, v, nil
				}
			}
		}
	case *ExprStmt:
		_, err := ev.evalExpr(n.Expr)
		if err != nil {
			return "", nilVal(), err
		}
	default:
		// For anything else, fall back to execBody (creates new scope)
		return ev.execBody([]Node{stmt}, nil)
	}
	return "", nilVal(), nil
}

func (ev *evaluator) execBody(body []Node, scope map[string]value) (string, value, error) {
	oldScope := ev.scope
	ev.scope = make(map[string]value, len(oldScope)+len(scope))
	for k, v := range oldScope {
		ev.scope[k] = v
	}
	for k, v := range scope {
		ev.scope[k] = v
	}
	defer func() { ev.scope = oldScope }()

	for _, stmt := range body {
		switch n := stmt.(type) {
		case *ReturnStmt:
			if n.Expr != nil {
				v, err := ev.evalExpr(n.Expr)
				if err != nil {
					return n.Result, nilVal(), err
				}
				return n.Result, v, nil
			}
			return n.Result, nilVal(), nil

		case *IfStmt:
			cond, err := ev.evalExpr(n.Cond)
			if err != nil {
				return "", nilVal(), err
			}
			var branch []Node
			if cond.truthy() {
				branch = n.Then
			} else {
				branch = n.Else
			}
			if len(branch) > 0 {
				result, v, err := ev.execBody(branch, nil)
				if err != nil {
					return "", nilVal(), err
				}
				if result == "auto" || result == "flag" {
					return result, v, nil
				}
			}

		case *ForStmt:
			iter, err := ev.evalExpr(n.Iter)
			if err != nil {
				return "", nilVal(), err
			}
			items := ev.valueToItems(iter)
			forLoop:
			for _, item := range items {
				ev.scope[n.Name] = item
				for _, fs := range n.Body {
					r, v, e := ev.execBodyStmt(fs)
					if errors.Is(e, errBreak) {
						break forLoop
					}
					if e != nil {
						return "", nilVal(), e
					}
					if r == "auto" || r == "flag" {
						return r, v, nil
					}
				}
			}

		case *WhileStmt:
			whileLoop:
			for {
				cond, err := ev.evalExpr(n.Cond)
				if err != nil {
					return "", nilVal(), err
				}
				if !cond.truthy() {
					break
				}
				for _, ws := range n.Body {
					r, v, e := ev.execBodyStmt(ws)
					if errors.Is(e, errBreak) {
						break whileLoop
					}
					if e != nil {
						return "", nilVal(), e
					}
					if r == "auto" || r == "flag" {
						return r, v, nil
					}
				}
			}

		case *BreakStmt:
			return "", nilVal(), errBreak

		case *LetStmt:
			v, err := ev.evalExpr(n.Expr)
			if err != nil {
				return "", nilVal(), err
			}
			ev.scope[n.Name] = v

		case *SetStmt:
			v, err := ev.evalExpr(n.Expr)
			if err != nil {
				return "", nilVal(), err
			}
			ev.scope[n.Name] = v

		case *EditStmt:
			if err := ev.execEdit(n); err != nil {
				return "", nilVal(), err
			}

		case *ExprStmt:
			v, err := ev.evalExpr(n.Expr)
			if err != nil {
				return "", nilVal(), err
			}
			if s := v.String(); s != "" {
				ev.out.WriteString(s)
				ev.out.WriteByte('\n')
			}

		case *ShapeDecl:
			if err := ev.execShapeDecl(n); err != nil {
				return "", nilVal(), err
			}
		}
	}

	return "absorb", nilVal(), nil
}

// valueToItems converts a value to a list of items for iteration.
func (ev *evaluator) valueToItems(v value) []value {
	switch v.kind {
	case "list":
		return v.list
	case "shapes":
		items := make([]value, len(v.shapes))
		for i, s := range v.shapes {
			items[i] = strVal(string(s.ID))
		}
		return items
	case "string":
		if v.str == "" {
			return nil
		}
		// Iterate over lines if multiline, else chars.
		if text.Contains(v.str, "\n") {
			lines := text.Split(v.str, "\n")
			items := make([]value, len(lines))
			for i, l := range lines {
				items[i] = strVal(l)
			}
			return items
		}
		return []value{v}
	default:
		return nil
	}
}

// --- langTransform bridges shape-lang fn declarations to the transform interface ---

type langTransform struct {
	name string
	decl *FnDecl
	ev   *evaluator
}

func (t *langTransform) Name() string { return t.name }

func (t *langTransform) Apply(c shape.Character, s shape.Structure) (shape.Character, error) {
	return c, nil
}

func (t *langTransform) Propagate(change transform.Change, self *shape.Shape) (transform.PropagationResult, string, error) {
	scope := map[string]value{
		"change":          strVal(change.NewContent),
		"change.source":   strVal(string(change.Source)),
		"change.content":  strVal(change.NewContent),
		"change.previous": strVal(change.PreviousContent),
		"self":            strVal(string(self.ID)),
		"self.content":    strVal(self.Character.Content),
		"self.id":         strVal(string(self.ID)),
	}
	for k, v := range self.Character.Dimensions {
		scope["self.dims."+k] = strVal(v)
	}

	result, content, err := t.ev.execBody(t.decl.Body, scope)
	if err != nil {
		return transform.FlagForReview, "", err
	}

	switch result {
	case "auto":
		return transform.AutoUpdate, content.String(), nil
	case "flag":
		return transform.FlagForReview, "", nil
	default:
		return transform.NoChange, "", nil
	}
}

// --- Utilities ---

// matchGlob matches a simple glob pattern against a string.
func matchGlob(pattern, s string) bool {
	if text.HasSuffix(pattern, ".*") {
		prefix := pattern[:len(pattern)-2]
		return text.HasPrefix(s, prefix+".")
	}
	if text.HasPrefix(pattern, "*") {
		return text.HasSuffix(s, pattern[1:])
	}
	return pattern == s
}

// resolvePath resolves a relative shape path against a base.
func resolvePath(base, path string) string {
	if path == "" {
		return base
	}
	if path == "/" {
		return ""
	}
	if text.HasPrefix(path, "/") {
		return path[1:]
	}
	if path == ".." {
		i := text.LastIndex(base, ".")
		if i < 0 {
			return ""
		}
		return base[:i]
	}
	if text.HasPrefix(path, "../") {
		parent := ""
		if i := text.LastIndex(base, "."); i >= 0 {
			parent = base[:i]
		}
		rest := path[3:]
		if parent == "" {
			return rest
		}
		return parent + "." + rest
	}
	if base == "" {
		return path
	}
	return base + "." + path
}

func sanitizeID(path string) string {
	return text.Replace(path, "/", ".", "\\", ".", ".sl", "", " ", "-")
}

// --- LLM agent interface ---
//
// The LLM emits shape-lang. Each call is a moment. The protocol:
// 1. System prompt from os.agent.llm.prompt (cached on provider)
// 2. Context: task state + graph snapshot + instructions
// 3. Response: shape-lang code to evaluate
// 4. Step shape records what happened
// 5. If response sets os.agent.llm.task.{id}.status != "complete", loop continues

// directCaller is the duck-typed interface for LLM calls.
// pkg/llm.Adapter implements this without eval.go importing it.
type directCaller interface {
	Ready() bool
	Call(system, context string) (content string, stopReason string, inputToks int, outputToks int, err error)
}

func (ev *evaluator) llmCall(context string) (value, error) {
	ext, ok := ev.eng.GetExt("llm")
	if !ok {
		return nilVal(), fmt.Errorf("LLM not configured. Set ANTHROPIC_API_KEY or os.config.llm.api_key")
	}

	dc, ok := ext.(directCaller)
	if !ok {
		return nilVal(), fmt.Errorf("LLM extension missing Call method")
	}

	// System prompt from shape.
	system := ""
	if s, ok := ev.eng.GetShape("os.agent.llm.prompt"); ok {
		system = s.Character.Content
	}
	if system == "" {
		return nilVal(), fmt.Errorf("no system prompt (os.agent.llm.prompt is empty)")
	}

	content, _, _, _, err := dc.Call(system, context)
	if err != nil {
		return nilVal(), fmt.Errorf("llm_call: %w", err)
	}

	return strVal(content), nil
}

func (ev *evaluator) llmStep(taskID string) (value, error) {
	// Read task shape for context.
	taskShapeID := shape.ID(taskID)
	task, ok := ev.eng.GetShape(taskShapeID)
	if !ok {
		return nilVal(), fmt.Errorf("task shape not found: %s", taskID)
	}

	// Build context from task state.
	stepNum := task.Character.Dimensions["step"]
	if stepNum == "" {
		stepNum = "0"
	}
	goal := task.Character.Dimensions["goal"]
	context := task.Character.Content
	if context == "" {
		context = "Goal: " + goal + "\nStep: " + stepNum + "\nBegin."
	}

	// Call LLM.
	responseText, err := ev.llmCall(context)
	if err != nil {
		return nilVal(), err
	}

	code := responseText.String()

	// Extract shape-lang from response (may be wrapped in code fences).
	code = extractShapeLang(code)

	// Create step shape to record this moment.
	n := 0
	for _, s := range ev.eng.Shapes() {
		if text.HasPrefix(string(s.ID), taskID+".step.") {
			n++
		}
	}
	stepID := fmt.Sprintf("%s.step.%d", taskID, n+1)
	ev.eng.AddShape(&shape.Shape{
		ID: shape.ID(stepID),
		Character: shape.Character{
			Dimensions: map[string]string{
				"type": "agent-step",
				"step": fmt.Sprintf("%d", n+1),
			},
			Content: code,
		},
		Structure: shape.Structure{
			Transformation: shape.Transformation{Deps: []shape.ID{taskShapeID}},
			Emergence:      shape.Emergence{Layer: 4},
		},
	})

	// Evaluate the shape-lang code the LLM produced.
	prog, err := Parse(code)
	if err != nil {
		// Record parse error but don't fail the step.
		ev.eng.Edit(shape.ID(stepID), "PARSE ERROR: "+err.Error()+"\n\n"+code)
		return strVal("step " + fmt.Sprintf("%d", n+1) + ": parse error: " + err.Error()), nil
	}

	out, err := EvalWithScope(prog, ev.eng, "", ev.scopeAsMap())
	if err != nil {
		ev.eng.Edit(shape.ID(stepID), "EVAL ERROR: "+err.Error()+"\n\n"+code)
		return strVal("step " + fmt.Sprintf("%d", n+1) + ": eval error: " + err.Error()), nil
	}

	// Update task step counter.
	task, _ = ev.eng.GetShape(taskShapeID)
	task.Character.Dimensions["step"] = fmt.Sprintf("%d", n+1)
	ev.eng.AddShape(task)

	return strVal(out), nil
}

// scopeAsMap converts the evaluator's current scope to a string map.
func (ev *evaluator) scopeAsMap() map[string]string {
	m := make(map[string]string, len(ev.scope))
	for k, v := range ev.scope {
		m[k] = v.String()
	}
	return m
}

// extractShapeLang strips code fences from LLM output.
// LLMs often wrap code in ```shape-lang ... ``` or ```sl ... ```.
func extractShapeLang(s string) string {
	// Try to find fenced code block.
	markers := []string{"```shape-lang", "```sl", "```shapelang", "```"}
	for _, marker := range markers {
		start := text.Index(s, marker)
		if start < 0 {
			continue
		}
		after := s[start+len(marker):]
		// Skip to end of the opening fence line.
		nl := text.Index(after, "\n")
		if nl < 0 {
			continue
		}
		after = after[nl+1:]
		// Find closing fence.
		end := text.Index(after, "```")
		if end < 0 {
			return after
		}
		return after[:end]
	}
	return s
}
