package lang

import (
	"fmt"
	"strconv"
	"strings"
)

// Token types.
const (
	tokEOF     = "eof"
	tokIdent   = "ident"
	tokString  = "string"
	tokInt     = "int"
	tokLBrace  = "{"
	tokRBrace  = "}"
	tokLBrack  = "["
	tokRBrack  = "]"
	tokLParen  = "("
	tokRParen  = ")"
	tokColon   = ":"
	tokComma   = ","
	tokDot     = "."
	tokEq      = "=="
	tokNeq     = "!="
	tokAssign  = "="
	tokPlus    = "+"
	tokBang    = "!"
	tokAnd     = "&&"
	tokOr      = "||"
	tokGt      = ">"
	tokLt      = "<"
	tokGte     = ">="
	tokLte     = "<="
	tokMinus   = "-"
	tokStar    = "*"
	tokSlash   = "/"
	tokPercent = "%"
	tokFloat   = "float"
	tokNewline = "nl"
)

// Keywords that are also identifiers.
var keywords = map[string]bool{
	"shape": true, "fn": true, "edit": true, "let": true, "set": true,
	"if": true, "else": true, "for": true, "in": true, "while": true, "break": true,
	"auto": true, "flag": true, "absorb": true,
	"assert": true, "block": true, "from": true, "use": true,
	"query": true, "true": true, "false": true,
}

type token struct {
	typ string
	val string
	ln  int
}

// lexer breaks source into tokens.
type lexer struct {
	src    []rune
	pos    int
	line   int
	tokens []token
}

func lex(src string) []token {
	l := &lexer{src: []rune(src), line: 1}
	l.run()
	return l.tokens
}

func (l *lexer) run() {
	for l.pos < len(l.src) {
		l.skipSpaces()
		if l.pos >= len(l.src) {
			break
		}

		ch := l.src[l.pos]

		// Comment.
		if ch == '/' && l.pos+1 < len(l.src) && l.src[l.pos+1] == '/' {
			for l.pos < len(l.src) && l.src[l.pos] != '\n' {
				l.pos++
			}
			continue
		}

		// Newline.
		if ch == '\n' {
			l.emit(tokNewline, "\n")
			l.line++
			l.pos++
			continue
		}

		// String literal.
		if ch == '"' {
			l.lexString()
			continue
		}

		// Number.
		if ch >= '0' && ch <= '9' {
			l.lexNumber()
			continue
		}

		// Identifier or keyword.
		if isIdentStart(ch) {
			l.lexIdent()
			continue
		}

		// Two-character operators.
		if l.pos+1 < len(l.src) {
			two := string(l.src[l.pos : l.pos+2])
			switch two {
			case "==":
				l.emit(tokEq, two)
				l.pos += 2
				continue
			case "!=":
				l.emit(tokNeq, two)
				l.pos += 2
				continue
			case "&&":
				l.emit(tokAnd, two)
				l.pos += 2
				continue
			case "||":
				l.emit(tokOr, two)
				l.pos += 2
				continue
			case ">=":
				l.emit(tokGte, two)
				l.pos += 2
				continue
			case "<=":
				l.emit(tokLte, two)
				l.pos += 2
				continue
			}
		}

		// Single-character tokens.
		switch ch {
		case '{':
			l.emit(tokLBrace, "{")
		case '}':
			l.emit(tokRBrace, "}")
		case '[':
			l.emit(tokLBrack, "[")
		case ']':
			l.emit(tokRBrack, "]")
		case '(':
			l.emit(tokLParen, "(")
		case ')':
			l.emit(tokRParen, ")")
		case ':':
			l.emit(tokColon, ":")
		case ',':
			l.emit(tokComma, ",")
		case '.':
			l.emit(tokDot, ".")
		case '=':
			l.emit(tokAssign, "=")
		case '+':
			l.emit(tokPlus, "+")
		case '-':
			l.emit(tokMinus, "-")
		case '*':
			l.emit(tokStar, "*")
		case '/':
			l.emit(tokSlash, "/")
		case '%':
			l.emit(tokPercent, "%")
		case '>':
			l.emit(tokGt, ">")
		case '<':
			l.emit(tokLt, "<")
		case '!':
			l.emit(tokBang, "!")
		default:
			// Skip unknown.
		}
		l.pos++
	}
	l.emit(tokEOF, "")
}

func (l *lexer) skipSpaces() {
	for l.pos < len(l.src) && (l.src[l.pos] == ' ' || l.src[l.pos] == '\t' || l.src[l.pos] == '\r') {
		l.pos++
	}
}

func (l *lexer) emit(typ, val string) {
	l.tokens = append(l.tokens, token{typ: typ, val: val, ln: l.line})
}

func (l *lexer) lexString() {
	l.pos++ // skip opening "

	// Triple-quote string: """..."""
	if l.pos+1 < len(l.src) && l.src[l.pos] == '"' && l.src[l.pos+1] == '"' {
		l.pos += 2 // skip remaining ""
		var buf strings.Builder
		for l.pos < len(l.src) {
			if l.pos+2 < len(l.src) && l.src[l.pos] == '"' && l.src[l.pos+1] == '"' && l.src[l.pos+2] == '"' {
				l.pos += 3
				// Trim leading newline if present.
				s := buf.String()
				if len(s) > 0 && s[0] == '\n' {
					s = s[1:]
				}
				l.emit(tokString, s)
				return
			}
			if l.src[l.pos] == '\n' {
				l.line++
			}
			buf.WriteRune(l.src[l.pos])
			l.pos++
		}
		l.emit(tokString, buf.String())
		return
	}

	var buf strings.Builder
	for l.pos < len(l.src) && l.src[l.pos] != '"' {
		if l.src[l.pos] == '\\' && l.pos+1 < len(l.src) {
			l.pos++
			switch l.src[l.pos] {
			case 'n':
				buf.WriteByte('\n')
			case 't':
				buf.WriteByte('\t')
			case '"':
				buf.WriteByte('"')
			case '\\':
				buf.WriteByte('\\')
			default:
				buf.WriteRune(l.src[l.pos])
			}
		} else {
			if l.src[l.pos] == '\n' {
				l.line++
			}
			buf.WriteRune(l.src[l.pos])
		}
		l.pos++
	}
	if l.pos < len(l.src) {
		l.pos++ // skip closing "
	}
	l.emit(tokString, buf.String())
}

func (l *lexer) lexNumber() {
	start := l.pos
	// Hex literal: 0x...
	if l.pos+1 < len(l.src) && l.src[l.pos] == '0' && (l.src[l.pos+1] == 'x' || l.src[l.pos+1] == 'X') {
		l.pos += 2
		for l.pos < len(l.src) && isHexDigit(l.src[l.pos]) {
			l.pos++
		}
		l.emit(tokInt, string(l.src[start:l.pos]))
		return
	}
	for l.pos < len(l.src) && l.src[l.pos] >= '0' && l.src[l.pos] <= '9' {
		l.pos++
	}
	// Float: digits followed by '.' and more digits.
	if l.pos < len(l.src) && l.src[l.pos] == '.' && l.pos+1 < len(l.src) && l.src[l.pos+1] >= '0' && l.src[l.pos+1] <= '9' {
		l.pos++ // skip '.'
		for l.pos < len(l.src) && l.src[l.pos] >= '0' && l.src[l.pos] <= '9' {
			l.pos++
		}
		l.emit(tokFloat, string(l.src[start:l.pos]))
		return
	}
	l.emit(tokInt, string(l.src[start:l.pos]))
}

func isHexDigit(c rune) bool {
	return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

func (l *lexer) lexIdent() {
	start := l.pos
	for l.pos < len(l.src) && isIdentPart(l.src[l.pos]) {
		l.pos++
	}
	// Include dot-separated segments as one ident (shape IDs).
	for l.pos < len(l.src) && l.src[l.pos] == '.' && l.pos+1 < len(l.src) && isIdentStart(l.src[l.pos+1]) {
		l.pos++ // skip dot
		for l.pos < len(l.src) && isIdentPart(l.src[l.pos]) {
			l.pos++
		}
	}
	// Glob wildcard at end: engine.*
	if l.pos < len(l.src) && l.src[l.pos] == '.' && l.pos+1 < len(l.src) && l.src[l.pos+1] == '*' {
		l.pos += 2
	}
	val := string(l.src[start:l.pos])
	l.emit(tokIdent, val)
}

func isIdentStart(ch rune) bool {
	return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

func isIdentPart(ch rune) bool {
	return isIdentStart(ch) || (ch >= '0' && ch <= '9') || ch == '-'
}

// --- Parser ---

// parser builds AST from tokens.
type parser struct {
	tokens []token
	pos    int
}

// Parse parses shape-lang source into a Program.
func Parse(src string) (*Program, error) {
	tokens := lex(src)
	p := &parser{tokens: tokens}
	return p.program()
}

func (p *parser) peek() token {
	if p.pos >= len(p.tokens) {
		return token{typ: tokEOF}
	}
	return p.tokens[p.pos]
}

func (p *parser) next() token {
	t := p.peek()
	p.pos++
	return t
}

func (p *parser) expect(typ string) (token, error) {
	t := p.next()
	if t.typ != typ {
		return t, fmt.Errorf("line %d: expected %s, got %s (%q)", t.ln, typ, t.typ, t.val)
	}
	return t, nil
}

func (p *parser) skipNewlines() {
	for p.peek().typ == tokNewline {
		p.next()
	}
}

func (p *parser) atEnd() bool {
	return p.peek().typ == tokEOF
}

func (p *parser) program() (*Program, error) {
	prog := &Program{}
	p.skipNewlines()

	for !p.atEnd() {
		stmt, err := p.topLevel()
		if err != nil {
			return nil, err
		}
		if stmt != nil {
			prog.Stmts = append(prog.Stmts, stmt)
		}
		p.skipNewlines()
	}

	return prog, nil
}

func (p *parser) topLevel() (Node, error) {
	t := p.peek()
	switch t.val {
	case "shape":
		return p.parseShape()
	case "fn":
		return p.parseFn()
	case "edit":
		return p.parseEdit()
	case "let":
		return p.parseLet()
	case "set":
		return p.parseSet()
	case "if":
		return p.parseIf()
	case "for":
		return p.parseFor()
	case "while":
		return p.parseWhile()
	case "auto":
		p.next()
		var expr Expr
		if p.peek().typ != tokNewline && p.peek().typ != tokRBrace && !p.atEnd() {
			var err error
			expr, err = p.parseExpr()
			if err != nil {
				return nil, err
			}
		}
		return &ReturnStmt{Result: "auto", Expr: expr}, nil
	case "assert":
		return p.parseAssert()
	case "block":
		return p.parseBlock()
	case "use":
		return p.parseUse()
	default:
		// Expression statement.
		if t.typ == tokIdent || t.typ == tokString {
			return p.parseExprStmt()
		}
		if t.typ == tokNewline {
			p.next()
			return nil, nil
		}
		return nil, fmt.Errorf("line %d: unexpected %s (%q)", t.ln, t.typ, t.val)
	}
}

// parseShape: shape <id> [: dep1, dep2] { ... }
func (p *parser) parseShape() (*ShapeDecl, error) {
	p.next() // consume "shape"

	idTok, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}
	decl := &ShapeDecl{
		ID:   idTok.val,
		Dims: make(map[string]string),
	}

	// Optional deps: shape foo : bar, baz {
	if p.peek().typ == tokColon {
		p.next() // consume ":"
		for {
			dep, err := p.expect(tokIdent)
			if err != nil {
				return nil, err
			}
			decl.Deps = append(decl.Deps, dep.val)
			if p.peek().typ != tokComma {
				break
			}
			p.next() // consume ","
		}
	}

	p.skipNewlines()
	if _, err := p.expect(tokLBrace); err != nil {
		return nil, err
	}
	p.skipNewlines()

	// Body: key: value pairs and string literals.
	for p.peek().typ != tokRBrace && !p.atEnd() {
		if p.peek().typ == tokString {
			// Bare string = content.
			decl.Content = p.next().val
			p.skipNewlines()
			continue
		}

		if p.peek().typ != tokIdent {
			p.skipNewlines()
			continue
		}

		key := p.next().val
		if _, err := p.expect(tokColon); err != nil {
			return nil, err
		}

		// Special structural keys.
		switch key {
		case "layer":
			val := p.next()
			decl.Layer = atoi(val.val)
		case "fn":
			val, err := p.expect(tokIdent)
			if err != nil {
				return nil, err
			}
			decl.Fn = val.val
		case "deps":
			ids, err := p.parseIDList()
			if err != nil {
				return nil, err
			}
			decl.Deps = append(decl.Deps, ids...)
		case "from":
			ids, err := p.parseIDList()
			if err != nil {
				return nil, err
			}
			decl.From = ids
		case "produces":
			ids, err := p.parseIDList()
			if err != nil {
				return nil, err
			}
			decl.Produce = ids
		case "content":
			val, err := p.expect(tokString)
			if err != nil {
				return nil, err
			}
			decl.Content = val.val
		default:
			// Regular dimension: consume all tokens until newline.
			// This handles values like "/api/shapes", "text/html; charset=utf-8",
			// "/api/deps/{id...}", etc. without requiring quotes.
			// Track brace depth so {id...} inside a value doesn't end the shape.
			var valParts []string
			braceDepth := 0
			for !p.atEnd() {
				tk := p.peek()
				if tk.typ == tokNewline && braceDepth == 0 {
					break
				}
				if tk.typ == tokLBrace {
					braceDepth++
				}
				if tk.typ == tokRBrace {
					if braceDepth > 0 {
						braceDepth--
					} else {
						break // end of shape body
					}
				}
				valParts = append(valParts, p.next().val)
			}
			decl.Dims[key] = strings.Join(valParts, "")
		}
		p.skipNewlines()
	}

	if _, err := p.expect(tokRBrace); err != nil {
		return nil, err
	}

	return decl, nil
}

// parseFn: fn <name>(params) { body }
func (p *parser) parseFn() (*FnDecl, error) {
	p.next() // consume "fn"

	name, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}
	decl := &FnDecl{Name: name.val}

	if _, err := p.expect(tokLParen); err != nil {
		return nil, err
	}

	// Parameters.
	for p.peek().typ != tokRParen && !p.atEnd() {
		param, err := p.expect(tokIdent)
		if err != nil {
			return nil, err
		}
		decl.Params = append(decl.Params, param.val)
		if p.peek().typ == tokComma {
			p.next()
		}
	}
	if _, err := p.expect(tokRParen); err != nil {
		return nil, err
	}

	p.skipNewlines()
	body, err := p.parseBlock_()
	if err != nil {
		return nil, err
	}
	decl.Body = body

	return decl, nil
}

// parseBlock_ parses { stmt* }
func (p *parser) parseBlock_() ([]Node, error) {
	if _, err := p.expect(tokLBrace); err != nil {
		return nil, err
	}
	p.skipNewlines()

	var stmts []Node
	for p.peek().typ != tokRBrace && !p.atEnd() {
		stmt, err := p.parseBodyStmt()
		if err != nil {
			return nil, err
		}
		if stmt != nil {
			stmts = append(stmts, stmt)
		}
		p.skipNewlines()
	}

	if _, err := p.expect(tokRBrace); err != nil {
		return nil, err
	}
	return stmts, nil
}

// parseBodyStmt parses a statement inside a fn body.
func (p *parser) parseBodyStmt() (Node, error) {
	t := p.peek()
	switch t.val {
	case "if":
		return p.parseIf()
	case "for":
		return p.parseFor()
	case "while":
		return p.parseWhile()
	case "break":
		p.next()
		return &BreakStmt{}, nil
	case "auto":
		p.next()
		var expr Expr
		if p.peek().typ != tokNewline && p.peek().typ != tokRBrace {
			var err error
			expr, err = p.parseExpr()
			if err != nil {
				return nil, err
			}
		}
		return &ReturnStmt{Result: "auto", Expr: expr}, nil
	case "flag":
		p.next()
		return &ReturnStmt{Result: "flag"}, nil
	case "absorb":
		p.next()
		return &ReturnStmt{Result: "absorb"}, nil
	case "let":
		return p.parseLet()
	case "set":
		return p.parseSet()
	case "edit":
		return p.parseEdit()
	default:
		if t.typ == tokNewline {
			p.next()
			return nil, nil
		}
		return p.parseExprStmt()
	}
}

// parseIf: if <expr> { ... } [else { ... }]
func (p *parser) parseIf() (*IfStmt, error) {
	p.next() // consume "if"

	cond, err := p.parseExpr()
	if err != nil {
		return nil, err
	}

	p.skipNewlines()
	then, err := p.parseBlock_()
	if err != nil {
		return nil, err
	}

	var els []Node
	p.skipNewlines()
	if p.peek().val == "else" {
		p.next()
		p.skipNewlines()
		if p.peek().val == "if" {
			// else if
			inner, err := p.parseIf()
			if err != nil {
				return nil, err
			}
			els = []Node{inner}
		} else {
			els, err = p.parseBlock_()
			if err != nil {
				return nil, err
			}
		}
	}

	return &IfStmt{Cond: cond, Then: then, Else: els}, nil
}

// parseFor: for <name> in <expr> { ... }
func (p *parser) parseFor() (*ForStmt, error) {
	p.next() // consume "for"

	name, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}

	inTok, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}
	if inTok.val != "in" {
		return nil, fmt.Errorf("line %d: expected 'in', got %q", inTok.ln, inTok.val)
	}

	iter, err := p.parseExpr()
	if err != nil {
		return nil, err
	}

	p.skipNewlines()
	body, err := p.parseBlock_()
	if err != nil {
		return nil, err
	}

	return &ForStmt{Name: name.val, Iter: iter, Body: body}, nil
}

// parseWhile: while <expr> { ... }
func (p *parser) parseWhile() (*WhileStmt, error) {
	p.next() // consume "while"

	cond, err := p.parseExpr()
	if err != nil {
		return nil, err
	}

	p.skipNewlines()
	body, err := p.parseBlock_()
	if err != nil {
		return nil, err
	}

	return &WhileStmt{Cond: cond, Body: body}, nil
}

// parseEdit: edit <id> <expr>
func (p *parser) parseEdit() (*EditStmt, error) {
	p.next() // consume "edit"

	id, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}

	expr, err := p.parseExpr()
	if err != nil {
		return nil, err
	}

	return &EditStmt{ID: id.val, Expr: expr}, nil
}

// parseLet: let <name> = <expr>
func (p *parser) parseLet() (*LetStmt, error) {
	p.next() // consume "let"

	name, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}

	if _, err := p.expect(tokAssign); err != nil {
		return nil, err
	}

	expr, err := p.parseExpr()
	if err != nil {
		return nil, err
	}

	return &LetStmt{Name: name.val, Expr: expr}, nil
}

// parseSet: set <name> = <expr>
func (p *parser) parseSet() (*SetStmt, error) {
	p.next() // consume "set"

	name, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}

	if _, err := p.expect(tokAssign); err != nil {
		return nil, err
	}

	expr, err := p.parseExpr()
	if err != nil {
		return nil, err
	}

	return &SetStmt{Name: name.val, Expr: expr}, nil
}

// parseAssert: assert law<N> <id>
func (p *parser) parseAssert() (*AssertStmt, error) {
	p.next() // consume "assert"

	lawTok, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}
	law := 0
	if len(lawTok.val) > 3 && lawTok.val[:3] == "law" {
		law = atoi(lawTok.val[3:])
	}

	id, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}

	return &AssertStmt{Law: law, ID: id.val}, nil
}

// parseBlock (stmt): block <author> from <shape> ["warning"]
func (p *parser) parseBlock() (*BlockStmt, error) {
	p.next() // consume "block"

	author, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}

	fromTok, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}
	if fromTok.val != "from" {
		return nil, fmt.Errorf("line %d: expected 'from', got %q", fromTok.ln, fromTok.val)
	}

	shapeID, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}

	var warning string
	if p.peek().typ == tokString {
		warning = p.next().val
	}

	return &BlockStmt{Author: author.val, ShapeID: shapeID.val, Warning: warning}, nil
}

// parseUse: use "<path>"
func (p *parser) parseUse() (*UseStmt, error) {
	p.next() // consume "use"

	path, err := p.expect(tokString)
	if err != nil {
		return nil, err
	}

	return &UseStmt{Path: path.val}, nil
}

func (p *parser) parseExprStmt() (*ExprStmt, error) {
	expr, err := p.parseExpr()
	if err != nil {
		return nil, err
	}
	return &ExprStmt{Expr: expr}, nil
}

// --- Expression parsing (precedence climbing) ---

func (p *parser) parseExpr() (Expr, error) {
	return p.parseOr()
}

func (p *parser) parseOr() (Expr, error) {
	left, err := p.parseAnd()
	if err != nil {
		return nil, err
	}
	for p.peek().typ == tokOr {
		op := p.next().val
		right, err := p.parseAnd()
		if err != nil {
			return nil, err
		}
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left, nil
}

func (p *parser) parseAnd() (Expr, error) {
	left, err := p.parseEquality()
	if err != nil {
		return nil, err
	}
	for p.peek().typ == tokAnd {
		op := p.next().val
		right, err := p.parseEquality()
		if err != nil {
			return nil, err
		}
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left, nil
}

func (p *parser) parseEquality() (Expr, error) {
	left, err := p.parseComparison()
	if err != nil {
		return nil, err
	}
	for p.peek().typ == tokEq || p.peek().typ == tokNeq {
		op := p.next().val
		right, err := p.parseComparison()
		if err != nil {
			return nil, err
		}
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	// "in" as infix: <expr> in <expr>
	if p.peek().val == "in" {
		p.next()
		right, err := p.parseComparison()
		if err != nil {
			return nil, err
		}
		left = &BinOp{Op: "in", Left: left, Right: right}
	}
	return left, nil
}

func (p *parser) parseComparison() (Expr, error) {
	left, err := p.parseAdditive()
	if err != nil {
		return nil, err
	}
	for p.peek().typ == tokGt || p.peek().typ == tokLt || p.peek().typ == tokGte || p.peek().typ == tokLte {
		op := p.next().val
		right, err := p.parseAdditive()
		if err != nil {
			return nil, err
		}
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left, nil
}

func (p *parser) parseAdditive() (Expr, error) {
	left, err := p.parseMultiplicative()
	if err != nil {
		return nil, err
	}
	for p.peek().typ == tokPlus || p.peek().typ == tokMinus {
		op := p.next().val
		right, err := p.parseMultiplicative()
		if err != nil {
			return nil, err
		}
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left, nil
}

func (p *parser) parseMultiplicative() (Expr, error) {
	left, err := p.parseUnary()
	if err != nil {
		return nil, err
	}
	for p.peek().typ == tokStar || p.peek().typ == tokSlash || p.peek().typ == tokPercent {
		op := p.next().val
		right, err := p.parseUnary()
		if err != nil {
			return nil, err
		}
		left = &BinOp{Op: op, Left: left, Right: right}
	}
	return left, nil
}

func (p *parser) parseUnary() (Expr, error) {
	if p.peek().typ == tokBang {
		op := p.next().val
		operand, err := p.parsePrimary()
		if err != nil {
			return nil, err
		}
		return &UnaryOp{Op: op, Operand: operand}, nil
	}
	return p.parsePrimary()
}

func (p *parser) parsePrimary() (Expr, error) {
	t := p.peek()

	switch t.typ {
	case tokString:
		p.next()
		return &StringLit{Value: t.val}, nil

	case tokInt:
		p.next()
		return &IntLit{Value: atoi(t.val)}, nil

	case tokFloat:
		p.next()
		f, _ := strconv.ParseFloat(t.val, 64)
		return &FloatLit{Value: f}, nil

	case tokLBrack:
		return p.parseListLit()

	case tokLBrace:
		return p.parseMapLit()

	case tokLParen:
		p.next()
		expr, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		if _, err := p.expect(tokRParen); err != nil {
			return nil, err
		}
		return expr, nil

	case tokIdent:
		// Check for query keyword.
		if t.val == "query" {
			return p.parseQuery()
		}
		if t.val == "true" {
			p.next()
			return &Ident{Name: "true"}, nil
		}
		if t.val == "false" {
			p.next()
			return &Ident{Name: "false"}, nil
		}

		p.next()
		name := t.val

		// Function call: name(args)
		if p.peek().typ == tokLParen {
			p.next() // consume "("
			var args []Expr
			for p.peek().typ != tokRParen && !p.atEnd() {
				arg, err := p.parseExpr()
				if err != nil {
					return nil, err
				}
				args = append(args, arg)
				if p.peek().typ == tokComma {
					p.next()
				}
			}
			if _, err := p.expect(tokRParen); err != nil {
				return nil, err
			}
			return &CallExpr{Fn: name, Args: args}, nil
		}

		return &Ident{Name: name}, nil

	default:
		return nil, fmt.Errorf("line %d: unexpected token in expression: %s (%q)", t.ln, t.typ, t.val)
	}
}

func (p *parser) parseListLit() (*ListLit, error) {
	p.next() // consume "["
	var elems []Expr
	for p.peek().typ != tokRBrack && !p.atEnd() {
		elem, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		elems = append(elems, elem)
		if p.peek().typ == tokComma {
			p.next()
		}
	}
	if _, err := p.expect(tokRBrack); err != nil {
		return nil, err
	}
	return &ListLit{Elems: elems}, nil
}

func (p *parser) parseMapLit() (*MapLit, error) {
	p.next() // consume "{"
	p.skipNewlines()
	var keys []string
	var vals []Expr
	for p.peek().typ != tokRBrace && !p.atEnd() {
		// key: value
		keyTok := p.peek()
		if keyTok.typ != tokIdent && keyTok.typ != tokString {
			return nil, fmt.Errorf("line %d: expected map key, got %s", keyTok.ln, keyTok.typ)
		}
		p.next()
		key := keyTok.val
		if _, err := p.expect(tokColon); err != nil {
			return nil, fmt.Errorf("line %d: expected ':' after map key", keyTok.ln)
		}
		val, err := p.parseExpr()
		if err != nil {
			return nil, err
		}
		keys = append(keys, key)
		vals = append(vals, val)
		p.skipNewlines()
		if p.peek().typ == tokComma {
			p.next()
			p.skipNewlines()
		}
	}
	if _, err := p.expect(tokRBrace); err != nil {
		return nil, err
	}
	return &MapLit{Keys: keys, Vals: vals}, nil
}

func (p *parser) parseQuery() (*QueryExpr, error) {
	p.next() // consume "query"

	t := p.peek()
	if t.typ == tokIdent && strings.ContainsAny(t.val, ".*") {
		// Glob pattern: query engine.*
		p.next()
		return &QueryExpr{Pattern: t.val}, nil
	}

	// Filter expression: query type == "func"
	filter, err := p.parseExpr()
	if err != nil {
		return nil, err
	}
	return &QueryExpr{Filter: filter}, nil
}

func (p *parser) parseIDList() ([]string, error) {
	// [id1, id2, id3] or id1, id2
	if p.peek().typ == tokLBrack {
		p.next() // consume "["
		var ids []string
		for p.peek().typ != tokRBrack && !p.atEnd() {
			id, err := p.expect(tokIdent)
			if err != nil {
				return nil, err
			}
			ids = append(ids, id.val)
			if p.peek().typ == tokComma {
				p.next()
			}
		}
		if _, err := p.expect(tokRBrack); err != nil {
			return nil, err
		}
		return ids, nil
	}

	// Single ID.
	id, err := p.expect(tokIdent)
	if err != nil {
		return nil, err
	}
	return []string{id.val}, nil
}

func atoi(s string) int {
	if len(s) > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X') {
		n, _ := strconv.ParseInt(s[2:], 16, 64)
		return int(n)
	}
	n := 0
	for _, ch := range s {
		if ch >= '0' && ch <= '9' {
			n = n*10 + int(ch-'0')
		}
	}
	return n
}
