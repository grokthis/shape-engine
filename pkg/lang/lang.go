// Package lang is the shape language.
//
// Programs ARE shapes. A shape-lang source file declares shapes,
// transforms, mutations, and queries. Loading a file adds shapes
// to the engine. Execution IS wave propagation.
//
// Syntax (derived from the 10 structural primitives):
//
//	// Shape declaration
//	shape engine.edit : engine, engine.propagate {
//	  type: func
//	  name: Edit
//	  layer: 3
//	  fn: propagation
//	  "Modifies a shape's character and propagates the wave."
//	}
//
//	// Transform (propagation logic)
//	fn propagation(change, self) {
//	  if contains(change.content, self.content) {
//	    auto "updated: " + change.content
//	  }
//	  flag
//	}
//
//	// Edit (triggers wave)
//	edit axiom "new content"
//
//	// Query
//	let shapes = query engine.*
//
//	// Assert coherence
//	assert law1 engine.edit
//
// The source file itself decomposes into shapes:
//
//	program.sl        → shape "program"
//	  shape decl      → shape "program.engine.edit" (the declared shape)
//	  fn decl         → shape "program.fn.propagation" (transform shape)
//	  edit stmt       → shape "program.edit.0" (mutation shape)
//
// Every syntactic element is a shape. The AST is a shape graph.
package lang

import "github.com/ashbuilds/shape-engine/pkg/shape"

// Node is an AST node. Every node becomes a shape.
type Node interface {
	nodeType() string
}

// Program is a sequence of declarations and statements.
type Program struct {
	Stmts []Node
}

func (p *Program) nodeType() string { return "program" }

// ShapeDecl declares a shape.
//
//	shape <id> [: dep1, dep2] {
//	  <key>: <value>
//	  ...
//	  "<content>"
//	}
type ShapeDecl struct {
	ID      string
	Deps    []string
	Dims    map[string]string
	Content string
	Layer   int
	Fn      string
	From    []string
	Produce []string
}

func (s *ShapeDecl) nodeType() string { return "shape" }

// FnDecl declares a transform function.
//
//	fn <name>(change, self) {
//	  <body>
//	}
type FnDecl struct {
	Name   string
	Params []string // ["change", "self"]
	Body   []Node
}

func (f *FnDecl) nodeType() string { return "fn" }

// EditStmt mutates a shape's content.
//
//	edit <id> <expr>
type EditStmt struct {
	ID   string
	Expr Expr
}

func (e *EditStmt) nodeType() string { return "edit" }

// LetStmt binds a name to an expression.
//
//	let <name> = <expr>
type LetStmt struct {
	Name string
	Expr Expr
}

func (l *LetStmt) nodeType() string { return "let" }

// AssertStmt checks a coherence law.
//
//	assert <law> <id>
type AssertStmt struct {
	Law int
	ID  string
}

func (a *AssertStmt) nodeType() string { return "assert" }

// BlockStmt withdraws permission.
//
//	block <author> from <shape>
type BlockStmt struct {
	Author  string
	ShapeID string
	Warning string
}

func (b *BlockStmt) nodeType() string { return "block" }

// UseStmt imports another source file.
//
//	use "<path>"
type UseStmt struct {
	Path string
}

func (u *UseStmt) nodeType() string { return "use" }

// IfStmt is conditional logic (in fn bodies).
//
//	if <cond> { ... } [else { ... }]
type IfStmt struct {
	Cond Expr
	Then []Node
	Else []Node
}

func (i *IfStmt) nodeType() string { return "if" }

// ForStmt iterates (in fn bodies).
//
//	for <name> in <expr> { ... }
type ForStmt struct {
	Name string
	Iter Expr
	Body []Node
}

func (f *ForStmt) nodeType() string { return "for" }

// WhileStmt loops while a condition is true.
//
//	while <cond> { ... }
type WhileStmt struct {
	Cond Expr
	Body []Node
}

func (w *WhileStmt) nodeType() string { return "while" }

// BreakStmt exits the current loop.
type BreakStmt struct{}

func (b *BreakStmt) nodeType() string { return "break" }

// ReturnStmt is the propagation result (in fn bodies).
//
//	auto <expr>    → AutoUpdate with content
//	flag           → FlagForReview
//	absorb         → NoChange
type ReturnStmt struct {
	Result string // "auto", "flag", "absorb"
	Expr   Expr   // content expression (auto only)
}

func (r *ReturnStmt) nodeType() string { return "return" }

// SetStmt mutates an existing variable binding.
//
//	set <name> = <expr>
type SetStmt struct {
	Name string
	Expr Expr
}

func (s *SetStmt) nodeType() string { return "set" }

// DilateStmt is a time dilation prefix.
//
//	dilate <multiple> <stmt>
//
// Runs the inner statement with time dilated by the given factor.
// N inner mutations share one outer tick.
type DilateStmt struct {
	Multiple Expr
	Body     Node
}

func (d *DilateStmt) nodeType() string { return "dilate" }

// ExprStmt wraps an expression as a statement (e.g. bare function call).
type ExprStmt struct {
	Expr Expr
}

func (e *ExprStmt) nodeType() string { return "expr" }

// --- Expressions ---

// Expr is a value expression.
type Expr interface {
	exprType() string
}

// StringLit is a string literal.
type StringLit struct {
	Value string
}

func (s *StringLit) exprType() string { return "string" }

// IntLit is an integer literal.
type IntLit struct {
	Value int
}

func (i *IntLit) exprType() string { return "int" }

// FloatLit is a floating-point literal.
type FloatLit struct {
	Value float64
}

func (f *FloatLit) exprType() string { return "float" }

// Ident is a name reference.
//
//	change.source, self.content, self.dims.type
type Ident struct {
	Name string
}

func (i *Ident) exprType() string { return "ident" }

// ListLit is a list literal: [a, b, c]
type ListLit struct {
	Elems []Expr
}

func (l *ListLit) exprType() string { return "list" }

// MapLit is a map literal: {key: expr, key2: expr2}
type MapLit struct {
	Keys []string
	Vals []Expr
}

func (m *MapLit) exprType() string { return "map" }

// BinOp is a binary operation.
//
//	+  (string concat)
//	== (equality)
//	!= (inequality)
//	in (membership)
//	&& (and)
//	|| (or)
type BinOp struct {
	Op    string
	Left  Expr
	Right Expr
}

func (b *BinOp) exprType() string { return "binop" }

// UnaryOp is a unary operation.
//
//	! (not)
type UnaryOp struct {
	Op      string
	Operand Expr
}

func (u *UnaryOp) exprType() string { return "unary" }

// CallExpr is a function call.
//
//	contains(a, b)
//	len(list)
type CallExpr struct {
	Fn   string
	Args []Expr
}

func (c *CallExpr) exprType() string { return "call" }

// QueryExpr finds shapes by pattern.
//
//	query engine.*
//	query type == "func"
type QueryExpr struct {
	Pattern string // glob pattern or ""
	Filter  Expr   // optional filter expression
}

func (q *QueryExpr) exprType() string { return "query" }

// --- Shape conversion ---

// ToShape converts a ShapeDecl to a shape.Shape.
func (d *ShapeDecl) ToShape() *shape.Shape {
	dims := make(map[string]string, len(d.Dims))
	for k, v := range d.Dims {
		dims[k] = v
	}

	s := &shape.Shape{
		ID: shape.ID(d.ID),
		Character: shape.Character{
			Dimensions: dims,
			Content:    d.Content,
		},
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Fn: d.Fn,
			},
			Emergence: shape.Emergence{
				Layer: d.Layer,
			},
		},
	}

	for _, dep := range d.Deps {
		s.Structure.Transformation.Deps = append(s.Structure.Transformation.Deps, shape.ID(dep))
	}
	for _, from := range d.From {
		s.Structure.Emergence.From = append(s.Structure.Emergence.From, shape.ID(from))
	}
	for _, prod := range d.Produce {
		s.Structure.Emergence.Produces = append(s.Structure.Emergence.Produces, shape.ID(prod))
	}

	return s
}
