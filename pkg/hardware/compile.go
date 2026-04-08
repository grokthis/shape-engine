// compile.go decomposes shape-lang AST into gate subgraphs.
//
// Each AST node becomes one or more gates in the lattice.
// The shape content is not one gate with a hash. It is a subgraph
// where each operation is a gate connected by data dependencies.
//
// This is the fourth projection of shape structure:
//   Disk:   shape -> bytes
//   Memory: shape -> Go struct
//   Gates:  shape -> LUT config (top-level, hash)
//   Circuit: shape content -> gate subgraph (this file)
package hardware

import (
	"fmt"

	"github.com/ashbuilds/shape-engine/pkg/lang"
)

// Gate is a single unit in the decomposed circuit.
type Gate struct {
	ID     string   // Unique gate ID within the subgraph.
	Kind   string   // Gate type: const, reg, alu, mux, iter, call, output.
	Op     string   // Operation: +, -, *, /, %, ==, !=, <, >, etc.
	Value  string   // For constants: the literal value.
	Inputs []string // Gate IDs this gate reads from.
	Width  int      // Data width in bits.
}

// Circuit is a decomposed shape: the content as a graph of gates.
type Circuit struct {
	ShapeID string
	Gates   []*Gate
	Outputs []string // Gate IDs that produce output.
	nextID  int
}

func newCircuit(shapeID string) *Circuit {
	return &Circuit{ShapeID: shapeID}
}

func (c *Circuit) addGate(kind, op, value string, inputs []string) string {
	id := fmt.Sprintf("%s.g%d", c.ShapeID, c.nextID)
	c.nextID++
	c.Gates = append(c.Gates, &Gate{
		ID:     id,
		Kind:   kind,
		Op:     op,
		Value:  value,
		Inputs: inputs,
		Width:  8, // Default, can be widened.
	})
	return id
}

// CompileShape decomposes a shape's content into a circuit of gates.
// Returns nil if the shape has no executable content.
func CompileShape(shapeID, content string) (*Circuit, error) {
	if content == "" {
		return nil, nil
	}

	prog, err := lang.Parse(content)
	if err != nil {
		return nil, fmt.Errorf("parse %s: %w", shapeID, err)
	}

	c := newCircuit(shapeID)
	for _, stmt := range prog.Stmts {
		if err := c.compileStmt(stmt); err != nil {
			return nil, err
		}
	}

	return c, nil
}

func (c *Circuit) compileStmt(node lang.Node) error {
	switch n := node.(type) {
	case *lang.LetStmt:
		gid, err := c.compileExpr(n.Expr)
		if err != nil {
			return err
		}
		// Let creates a named register.
		c.addGate("reg", "let", n.Name, []string{gid})
		return nil

	case *lang.SetStmt:
		gid, err := c.compileExpr(n.Expr)
		if err != nil {
			return err
		}
		// Set updates a named register.
		c.addGate("reg", "set", n.Name, []string{gid})
		return nil

	case *lang.ExprStmt:
		gid, err := c.compileExpr(n.Expr)
		if err != nil {
			return err
		}
		// Expression statement: the result is an output if it's a call to print/write.
		if call, ok := n.Expr.(*lang.CallExpr); ok {
			if call.Fn == "print" || call.Fn == "write" {
				c.Outputs = append(c.Outputs, gid)
			}
		}
		return nil

	case *lang.IfStmt:
		condGate, err := c.compileExpr(n.Cond)
		if err != nil {
			return err
		}

		// Compile then branch.
		thenStart := len(c.Gates)
		for _, s := range n.Then {
			if err := c.compileStmt(s); err != nil {
				return err
			}
		}
		thenEnd := len(c.Gates) - 1

		// Compile else branch.
		elseStart := len(c.Gates)
		for _, s := range n.Else {
			if err := c.compileStmt(s); err != nil {
				return err
			}
		}
		elseEnd := len(c.Gates) - 1

		// Mux gate selects between branches based on condition.
		inputs := []string{condGate}
		if thenEnd >= thenStart {
			inputs = append(inputs, c.Gates[thenEnd].ID)
		}
		if elseEnd >= elseStart {
			inputs = append(inputs, c.Gates[elseEnd].ID)
		}
		c.addGate("mux", "if", "", inputs)
		return nil

	case *lang.ForStmt:
		iterGate, err := c.compileExpr(n.Iter)
		if err != nil {
			return err
		}

		// Iterator gate: feeds elements to body, collects results.
		iterID := c.addGate("iter", "for", n.Name, []string{iterGate})

		// Compile body.
		for _, s := range n.Body {
			if err := c.compileStmt(s); err != nil {
				return err
			}
		}

		// Feedback: last body gate feeds back to iterator.
		if len(c.Gates) > 0 {
			lastGate := c.Gates[len(c.Gates)-1]
			c.addGate("feedback", "for_back", "", []string{iterID, lastGate.ID})
		}
		return nil

	case *lang.WhileStmt:
		condGate, err := c.compileExpr(n.Cond)
		if err != nil {
			return err
		}

		loopID := c.addGate("loop", "while", "", []string{condGate})

		for _, s := range n.Body {
			if err := c.compileStmt(s); err != nil {
				return err
			}
		}

		// Feedback from body to condition re-evaluation.
		if len(c.Gates) > 0 {
			lastGate := c.Gates[len(c.Gates)-1]
			c.addGate("feedback", "while_back", "", []string{loopID, lastGate.ID})
		}
		return nil

	case *lang.EditStmt:
		gid, err := c.compileExpr(n.Expr)
		if err != nil {
			return err
		}
		c.addGate("output", "edit", n.ID, []string{gid})
		c.Outputs = append(c.Outputs, c.Gates[len(c.Gates)-1].ID)
		return nil

	case *lang.ReturnStmt:
		if n.Expr != nil {
			gid, err := c.compileExpr(n.Expr)
			if err != nil {
				return err
			}
			c.addGate("output", n.Result, "", []string{gid})
		} else {
			c.addGate("output", n.Result, "", nil)
		}
		return nil

	case *lang.BreakStmt:
		c.addGate("control", "break", "", nil)
		return nil

	case *lang.ShapeDecl:
		// Shape declarations are structural, not computational.
		// They become top-level gates, not subgraph gates.
		return nil

	default:
		// Unknown statement type, skip.
		return nil
	}
}

func (c *Circuit) compileExpr(expr lang.Expr) (string, error) {
	switch e := expr.(type) {
	case *lang.IntLit:
		return c.addGate("const", "int", fmt.Sprintf("%d", e.Value), nil), nil

	case *lang.FloatLit:
		return c.addGate("const", "float", fmt.Sprintf("%g", e.Value), nil), nil

	case *lang.StringLit:
		return c.addGate("const", "string", e.Value, nil), nil

	case *lang.Ident:
		if e.Name == "true" {
			return c.addGate("const", "bool", "1", nil), nil
		}
		if e.Name == "false" {
			return c.addGate("const", "bool", "0", nil), nil
		}
		// Variable reference: reads from named register.
		return c.addGate("reg_read", "ident", e.Name, nil), nil

	case *lang.BinOp:
		left, err := c.compileExpr(e.Left)
		if err != nil {
			return "", err
		}
		right, err := c.compileExpr(e.Right)
		if err != nil {
			return "", err
		}
		return c.addGate("alu", e.Op, "", []string{left, right}), nil

	case *lang.UnaryOp:
		operand, err := c.compileExpr(e.Operand)
		if err != nil {
			return "", err
		}
		return c.addGate("alu", e.Op, "", []string{operand}), nil

	case *lang.CallExpr:
		var argGates []string
		for _, arg := range e.Args {
			gid, err := c.compileExpr(arg)
			if err != nil {
				return "", err
			}
			argGates = append(argGates, gid)
		}
		return c.addGate("call", e.Fn, "", argGates), nil

	case *lang.ListLit:
		var elemGates []string
		for _, elem := range e.Elems {
			gid, err := c.compileExpr(elem)
			if err != nil {
				return "", err
			}
			elemGates = append(elemGates, gid)
		}
		return c.addGate("aggregate", "list", "", elemGates), nil

	case *lang.MapLit:
		var inputs []string
		for i, val := range e.Vals {
			keyGate := c.addGate("const", "string", e.Keys[i], nil)
			valGate, err := c.compileExpr(val)
			if err != nil {
				return "", err
			}
			inputs = append(inputs, keyGate, valGate)
		}
		return c.addGate("aggregate", "map", "", inputs), nil

	case *lang.QueryExpr:
		if e.Pattern != "" {
			return c.addGate("call", "query", e.Pattern, nil), nil
		}
		if e.Filter != nil {
			filterGate, err := c.compileExpr(e.Filter)
			if err != nil {
				return "", err
			}
			return c.addGate("call", "query_filter", "", []string{filterGate}), nil
		}
		return c.addGate("const", "nil", "", nil), nil

	default:
		return c.addGate("const", "nil", "", nil), nil
	}
}

// TotalGateCount returns the total number of gates across all circuits.
func TotalGateCount(circuits []*Circuit) int {
	total := 0
	for _, c := range circuits {
		if c != nil {
			total += len(c.Gates)
		}
	}
	return total
}
