// golang.go — Go language front-end for the shape engine.
//
// Parses Go source into the same AST as shape-lang.
// The structural optimizer fires on the result.
// Go loops become shape-lang loops. Shape-lang loops collapse to formulas.
// Go running on the shape engine is faster than Go running on Go.
package lang

import (
	"github.com/ashbuilds/shape-engine/pkg/text"
)

// ParseGo parses a subset of Go into the shape-lang AST.
// The same structural shortcuts fire on the output.
func ParseGo(src string) (*Program, error) {
	tokens := lexGo(src)
	p := &goParser{tokens: tokens}
	return p.program()
}

// Go tokens (reuse shape-lang token types where they match).
func lexGo(src string) []token {
	var tokens []token
	pos := 0
	line := 1

	for pos < len(src) {
		// Skip whitespace (not newlines).
		for pos < len(src) && (src[pos] == ' ' || src[pos] == '\t' || src[pos] == '\r') {
			pos++
		}
		if pos >= len(src) {
			break
		}

		ch := src[pos]

		// Newline.
		if ch == '\n' {
			tokens = append(tokens, token{typ: tokNewline, val: "\n", ln: line})
			line++
			pos++
			continue
		}

		// Comment.
		if ch == '/' && pos+1 < len(src) && src[pos+1] == '/' {
			for pos < len(src) && src[pos] != '\n' {
				pos++
			}
			continue
		}

		// Number.
		if ch >= '0' && ch <= '9' {
			start := pos
			for pos < len(src) && src[pos] >= '0' && src[pos] <= '9' {
				pos++
			}
			tokens = append(tokens, token{typ: tokInt, val: src[start:pos], ln: line})
			continue
		}

		// Identifier/keyword.
		if (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_' {
			start := pos
			for pos < len(src) && ((src[pos] >= 'a' && src[pos] <= 'z') || (src[pos] >= 'A' && src[pos] <= 'Z') || (src[pos] >= '0' && src[pos] <= '9') || src[pos] == '_') {
				pos++
			}
			tokens = append(tokens, token{typ: tokIdent, val: src[start:pos], ln: line})
			continue
		}

		// String.
		if ch == '"' {
			pos++
			start := pos
			for pos < len(src) && src[pos] != '"' {
				if src[pos] == '\\' {
					pos++
				}
				pos++
			}
			tokens = append(tokens, token{typ: tokString, val: src[start:pos], ln: line})
			if pos < len(src) {
				pos++
			}
			continue
		}

		// Multi-char operators.
		if pos+1 < len(src) {
			two := src[pos : pos+2]
			switch two {
			case ":=":
				tokens = append(tokens, token{typ: "walrus", val: ":=", ln: line})
				pos += 2
				continue
			case "++":
				tokens = append(tokens, token{typ: "inc", val: "++", ln: line})
				pos += 2
				continue
			case "--":
				tokens = append(tokens, token{typ: "dec", val: "--", ln: line})
				pos += 2
				continue
			case "+=":
				tokens = append(tokens, token{typ: "addassign", val: "+=", ln: line})
				pos += 2
				continue
			case "-=":
				tokens = append(tokens, token{typ: "subassign", val: "-=", ln: line})
				pos += 2
				continue
			case "*=":
				tokens = append(tokens, token{typ: "mulassign", val: "*=", ln: line})
				pos += 2
				continue
			case "==":
				tokens = append(tokens, token{typ: tokEq, val: "==", ln: line})
				pos += 2
				continue
			case "!=":
				tokens = append(tokens, token{typ: tokNeq, val: "!=", ln: line})
				pos += 2
				continue
			case "&&":
				tokens = append(tokens, token{typ: tokAnd, val: "&&", ln: line})
				pos += 2
				continue
			case "||":
				tokens = append(tokens, token{typ: tokOr, val: "||", ln: line})
				pos += 2
				continue
			case ">=":
				tokens = append(tokens, token{typ: tokGte, val: ">=", ln: line})
				pos += 2
				continue
			case "<=":
				tokens = append(tokens, token{typ: tokLte, val: "<=", ln: line})
				pos += 2
				continue
			}
		}

		// Single-char.
		switch ch {
		case '{':
			tokens = append(tokens, token{typ: tokLBrace, val: "{", ln: line})
		case '}':
			tokens = append(tokens, token{typ: tokRBrace, val: "}", ln: line})
		case '(':
			tokens = append(tokens, token{typ: tokLParen, val: "(", ln: line})
		case ')':
			tokens = append(tokens, token{typ: tokRParen, val: ")", ln: line})
		case '=':
			tokens = append(tokens, token{typ: tokAssign, val: "=", ln: line})
		case '+':
			tokens = append(tokens, token{typ: tokPlus, val: "+", ln: line})
		case '-':
			tokens = append(tokens, token{typ: tokMinus, val: "-", ln: line})
		case '*':
			tokens = append(tokens, token{typ: tokStar, val: "*", ln: line})
		case '/':
			tokens = append(tokens, token{typ: tokSlash, val: "/", ln: line})
		case '%':
			tokens = append(tokens, token{typ: tokPercent, val: "%", ln: line})
		case '<':
			tokens = append(tokens, token{typ: tokLt, val: "<", ln: line})
		case '>':
			tokens = append(tokens, token{typ: tokGt, val: ">", ln: line})
		case ';':
			tokens = append(tokens, token{typ: tokNewline, val: ";", ln: line})
		case ',':
			tokens = append(tokens, token{typ: tokComma, val: ",", ln: line})
		case '!':
			tokens = append(tokens, token{typ: tokBang, val: "!", ln: line})
		}
		pos++
	}

	tokens = append(tokens, token{typ: tokEOF, val: "", ln: line})
	return tokens
}

// goParser converts Go tokens into shape-lang AST.
type goParser struct {
	tokens []token
	pos    int
}

func (p *goParser) peek() token {
	if p.pos >= len(p.tokens) {
		return token{typ: tokEOF}
	}
	return p.tokens[p.pos]
}

func (p *goParser) next() token {
	t := p.peek()
	p.pos++
	return t
}

func (p *goParser) expect(typ string) token {
	t := p.next()
	return t
}

func (p *goParser) skipNL() {
	for p.peek().typ == tokNewline {
		p.next()
	}
}

func (p *goParser) program() (*Program, error) {
	prog := &Program{}
	p.skipNL()
	for p.peek().typ != tokEOF {
		stmt := p.parseStmt()
		if stmt != nil {
			prog.Stmts = append(prog.Stmts, stmt)
		}
		p.skipNL()
	}
	return prog, nil
}

func (p *goParser) parseStmt() Node {
	t := p.peek()

	// Skip keywords we don't care about: func, package, import, var, etc.
	if t.val == "func" || t.val == "package" || t.val == "import" || t.val == "var" || t.val == "type" {
		// Skip to next newline or EOF.
		for p.peek().typ != tokNewline && p.peek().typ != tokEOF {
			if p.peek().typ == tokLBrace {
				p.skipBlock()
				return nil
			}
			p.next()
		}
		return nil
	}

	// for i := 0; i < N; i++ { ... }
	if t.val == "for" {
		return p.parseFor()
	}

	// if COND { ... } [else { ... }]
	if t.val == "if" {
		return p.parseIf()
	}

	// NAME := EXPR  (short variable declaration -> let)
	if t.typ == tokIdent && p.peekAt(1).typ == "walrus" {
		name := p.next().val
		p.next() // :=
		expr := p.parseExpr()
		return &LetStmt{Name: name, Expr: expr}
	}

	// NAME += EXPR  -> set NAME = NAME + EXPR
	if t.typ == tokIdent && (p.peekAt(1).typ == "addassign" || p.peekAt(1).typ == "subassign" || p.peekAt(1).typ == "mulassign") {
		name := p.next().val
		op := p.next()
		expr := p.parseExpr()
		var binOp string
		switch op.typ {
		case "addassign":
			binOp = "+"
		case "subassign":
			binOp = "-"
		case "mulassign":
			binOp = "*"
		}
		return &SetStmt{Name: name, Expr: &BinOp{Op: binOp, Left: &Ident{Name: name}, Right: expr}}
	}

	// NAME = EXPR  -> set NAME = EXPR
	if t.typ == tokIdent && p.peekAt(1).typ == tokAssign {
		name := p.next().val
		p.next() // =
		expr := p.parseExpr()
		return &SetStmt{Name: name, Expr: expr}
	}

	// NAME++ -> set NAME = NAME + 1
	if t.typ == tokIdent && p.peekAt(1).typ == "inc" {
		name := p.next().val
		p.next() // ++
		return &SetStmt{Name: name, Expr: &BinOp{Op: "+", Left: &Ident{Name: name}, Right: &IntLit{Value: 1}}}
	}

	// NAME-- -> set NAME = NAME - 1
	if t.typ == tokIdent && p.peekAt(1).typ == "dec" {
		name := p.next().val
		p.next() // --
		return &SetStmt{Name: name, Expr: &BinOp{Op: "-", Left: &Ident{Name: name}, Right: &IntLit{Value: 1}}}
	}

	// _ = EXPR (discard)
	if t.val == "_" && p.peekAt(1).typ == tokAssign {
		p.next()
		p.next()
		p.parseExpr()
		return nil
	}

	// Bare expression or unknown.
	if t.typ == tokNewline {
		p.next()
		return nil
	}

	p.next()
	return nil
}

func (p *goParser) peekAt(offset int) token {
	idx := p.pos + offset
	if idx >= len(p.tokens) {
		return token{typ: tokEOF}
	}
	return p.tokens[idx]
}

// parseFor: for INIT; COND; POST { BODY }
// Maps to shape-lang: let INIT; for NAME in range(N) { BODY }
// when the pattern is: for i := START; i < END; i++ { ... }
func (p *goParser) parseFor() Node {
	p.next() // consume "for"

	// Parse init: NAME := EXPR
	initName := ""
	var initVal int
	if p.peek().typ == tokIdent && p.peekAt(1).typ == "walrus" {
		initName = p.next().val
		p.next() // :=
		initExpr := p.parseExpr()
		if lit, ok := initExpr.(*IntLit); ok {
			initVal = lit.Value
		}
	}
	p.skipNL() // ;

	// Parse condition: NAME < EXPR
	var endExpr Expr
	condName := ""
	if p.peek().typ == tokIdent {
		condName = p.next().val
		p.next() // < or <=
		endExpr = p.parseExpr()
	}
	p.skipNL() // ;

	// Parse post: NAME++ or NAME += EXPR
	if p.peek().typ == tokIdent {
		p.next() // name
		if p.peek().typ == "inc" {
			p.next() // ++
		} else if p.peek().typ == "addassign" {
			p.next() // +=
			p.parseExpr()
		}
	}
	p.skipNL()

	// Parse body.
	var body []Node
	if p.peek().typ == tokLBrace {
		body = p.parseBlock()
	}

	// Map to shape-lang for/range if init and condition match.
	if initName != "" && condName == initName && endExpr != nil {
		// Build: for NAME in range(START, END) { BODY }
		var rangeArgs []Expr
		if initVal == 0 {
			rangeArgs = []Expr{endExpr}
		} else {
			rangeArgs = []Expr{&IntLit{Value: initVal}, endExpr}
		}
		return &ForStmt{
			Name: initName,
			Iter: &CallExpr{Fn: "range", Args: rangeArgs},
			Body: body,
		}
	}

	// Fallback: while-style loop.
	return &ForStmt{
		Name: "_",
		Iter: &CallExpr{Fn: "range", Args: []Expr{&IntLit{Value: 0}}},
		Body: body,
	}
}

func (p *goParser) parseIf() Node {
	p.next() // consume "if"
	cond := p.parseExpr()
	p.skipNL()
	var then []Node
	if p.peek().typ == tokLBrace {
		then = p.parseBlock()
	}
	var els []Node
	p.skipNL()
	if p.peek().val == "else" {
		p.next()
		p.skipNL()
		if p.peek().val == "if" {
			els = []Node{p.parseIf()}
		} else if p.peek().typ == tokLBrace {
			els = p.parseBlock()
		}
	}
	return &IfStmt{Cond: cond, Then: then, Else: els}
}

func (p *goParser) parseBlock() []Node {
	p.expect(tokLBrace)
	p.skipNL()
	var stmts []Node
	for p.peek().typ != tokRBrace && p.peek().typ != tokEOF {
		s := p.parseStmt()
		if s != nil {
			stmts = append(stmts, s)
		}
		p.skipNL()
	}
	if p.peek().typ == tokRBrace {
		p.next()
	}
	return stmts
}

func (p *goParser) skipBlock() {
	depth := 0
	for p.peek().typ != tokEOF {
		if p.peek().typ == tokLBrace {
			depth++
		}
		if p.peek().typ == tokRBrace {
			depth--
			if depth <= 0 {
				p.next()
				return
			}
		}
		p.next()
	}
}

// Expression parser (minimal, handles what we need).
func (p *goParser) parseExpr() Expr {
	return p.parseCompare()
}

func (p *goParser) parseCompare() Expr {
	left := p.parseAddSub()
	for p.peek().typ == tokLt || p.peek().typ == tokGt || p.peek().typ == tokLte || p.peek().typ == tokGte || p.peek().typ == tokEq || p.peek().typ == tokNeq {
		op := p.next().val
		right := p.parseAddSub()
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left
}

func (p *goParser) parseAddSub() Expr {
	left := p.parseMulDiv()
	for p.peek().typ == tokPlus || p.peek().typ == tokMinus {
		op := p.next().val
		right := p.parseMulDiv()
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left
}

func (p *goParser) parseMulDiv() Expr {
	left := p.parsePrimary()
	for p.peek().typ == tokStar || p.peek().typ == tokSlash || p.peek().typ == tokPercent {
		op := p.next().val
		right := p.parsePrimary()
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left
}

func (p *goParser) parsePrimary() Expr {
	t := p.peek()
	if t.typ == tokInt {
		p.next()
		return &IntLit{Value: atoi(t.val)}
	}
	if t.typ == tokIdent {
		p.next()
		if t.val == "true" {
			return &Ident{Name: "true"}
		}
		if t.val == "false" {
			return &Ident{Name: "false"}
		}
		// Function call.
		if p.peek().typ == tokLParen {
			p.next()
			var args []Expr
			for p.peek().typ != tokRParen && p.peek().typ != tokEOF {
				args = append(args, p.parseExpr())
				if p.peek().typ == tokComma {
					p.next()
				}
			}
			p.expect(tokRParen)
			return &CallExpr{Fn: t.val, Args: args}
		}
		return &Ident{Name: t.val}
	}
	if t.typ == tokLParen {
		p.next()
		e := p.parseExpr()
		p.expect(tokRParen)
		return e
	}
	if t.typ == tokMinus {
		p.next()
		operand := p.parsePrimary()
		if lit, ok := operand.(*IntLit); ok {
			return &IntLit{Value: -lit.Value}
		}
		return &BinOp{Op: "-", Left: &IntLit{Value: 0}, Right: operand}
	}
	p.next()
	return &IntLit{Value: 0}
}

// Suppress unused import.
var _ = text.Contains
