// polyglot.go — Multi-language front-ends for the shape engine.
//
// Each parser maps a language's syntax onto the same AST.
// The structural optimizer fires on all of them identically.
// Same formula, different lens.
package lang

// ParsePython parses a subset of Python into the shape-lang AST.
// Handles: x = EXPR, for x in range(N): body, x += EXPR
func ParsePython(src string) (*Program, error) {
	p := &pyParser{src: src, pos: 0, line: 1}
	return p.program()
}

type pyParser struct {
	src  string
	pos  int
	line int
}

func (p *pyParser) program() (*Program, error) {
	prog := &Program{}
	p.skipWS()
	for p.pos < len(p.src) {
		stmt := p.parseStmt(0)
		if stmt != nil {
			prog.Stmts = append(prog.Stmts, stmt)
		}
		p.skipWS()
	}
	return prog, nil
}

func (p *pyParser) skipWS() {
	for p.pos < len(p.src) && (p.src[p.pos] == ' ' || p.src[p.pos] == '\t' || p.src[p.pos] == '\r' || p.src[p.pos] == '\n') {
		if p.src[p.pos] == '\n' {
			p.line++
		}
		p.pos++
	}
	// Skip comments.
	if p.pos < len(p.src) && p.src[p.pos] == '#' {
		for p.pos < len(p.src) && p.src[p.pos] != '\n' {
			p.pos++
		}
		p.skipWS()
	}
}

func (p *pyParser) parseStmt(indent int) Node {
	p.skipWS()
	if p.pos >= len(p.src) {
		return nil
	}

	// for NAME in EXPR:
	if p.matchWord("for") {
		name := p.readIdent()
		p.matchWord("in")
		iter := p.parseExpr()
		p.expect(':')
		p.skipWS()
		var body []Node
		for {
			p.skipWS()
			if p.pos >= len(p.src) {
				break
			}
			// Check indentation: body must be indented more.
			// Simple heuristic: if next char is not space/tab after newline, stop.
			if !p.atIndented(indent) {
				break
			}
			s := p.parseStmt(indent + 1)
			if s != nil {
				body = append(body, s)
			}
		}
		return &ForStmt{Name: name, Iter: iter, Body: body}
	}

	// NAME = EXPR (assignment -> let on first use)
	// NAME += EXPR -> set NAME = NAME + EXPR
	start := p.pos
	name := p.readIdent()
	if name == "" {
		p.pos = start
		return nil
	}
	p.skipInlineWS()

	if p.pos+1 < len(p.src) && p.src[p.pos] == '+' && p.src[p.pos+1] == '=' {
		p.pos += 2
		p.skipInlineWS()
		expr := p.parseExpr()
		return &SetStmt{Name: name, Expr: &BinOp{Op: "+", Left: &Ident{Name: name}, Right: expr}}
	}
	if p.pos+1 < len(p.src) && p.src[p.pos] == '-' && p.src[p.pos+1] == '=' {
		p.pos += 2
		p.skipInlineWS()
		expr := p.parseExpr()
		return &SetStmt{Name: name, Expr: &BinOp{Op: "-", Left: &Ident{Name: name}, Right: expr}}
	}
	if p.pos < len(p.src) && p.src[p.pos] == '=' && (p.pos+1 >= len(p.src) || p.src[p.pos+1] != '=') {
		p.pos++
		p.skipInlineWS()
		expr := p.parseExpr()
		return &LetStmt{Name: name, Expr: expr}
	}

	p.pos = start
	return nil
}

func (p *pyParser) atIndented(minIndent int) bool {
	// Look backwards for the newline, count spaces.
	i := p.pos
	if i > 0 && (p.src[i] == ' ' || p.src[i] == '\t') {
		return true
	}
	// If we're at a non-space character and minIndent > 0, check if there was indentation.
	if minIndent > 0 {
		// Scan backwards to the newline.
		j := p.pos - 1
		for j >= 0 && p.src[j] != '\n' {
			j--
		}
		spaces := p.pos - j - 1
		return spaces > 0
	}
	return true
}

func (p *pyParser) parseExpr() Expr {
	left := p.parsePrimary()
	p.skipInlineWS()
	for p.pos < len(p.src) {
		op := byte(0)
		if p.src[p.pos] == '+' {
			op = '+'
		} else if p.src[p.pos] == '-' {
			op = '-'
		} else if p.src[p.pos] == '*' {
			op = '*'
		} else {
			break
		}
		if p.pos+1 < len(p.src) && p.src[p.pos+1] == '=' {
			break // += is not a binary op here
		}
		p.pos++
		p.skipInlineWS()
		right := p.parsePrimary()
		left = &BinOp{Op: string(op), Left: left, Right: right}
		p.skipInlineWS()
	}
	return left
}

func (p *pyParser) parsePrimary() Expr {
	p.skipInlineWS()
	if p.pos >= len(p.src) {
		return &IntLit{Value: 0}
	}
	// Number.
	if p.src[p.pos] >= '0' && p.src[p.pos] <= '9' {
		start := p.pos
		for p.pos < len(p.src) && p.src[p.pos] >= '0' && p.src[p.pos] <= '9' {
			p.pos++
		}
		return &IntLit{Value: atoi(p.src[start:p.pos])}
	}
	// Ident or function call.
	name := p.readIdent()
	if name == "" {
		return &IntLit{Value: 0}
	}
	p.skipInlineWS()
	if p.pos < len(p.src) && p.src[p.pos] == '(' {
		p.pos++ // (
		var args []Expr
		for p.pos < len(p.src) && p.src[p.pos] != ')' {
			p.skipInlineWS()
			args = append(args, p.parseExpr())
			p.skipInlineWS()
			if p.pos < len(p.src) && p.src[p.pos] == ',' {
				p.pos++
			}
		}
		if p.pos < len(p.src) {
			p.pos++ // )
		}
		return &CallExpr{Fn: name, Args: args}
	}
	return &Ident{Name: name}
}

func (p *pyParser) readIdent() string {
	start := p.pos
	for p.pos < len(p.src) && (isIdentChar(p.src[p.pos]) || (p.pos > start && p.src[p.pos] >= '0' && p.src[p.pos] <= '9')) {
		p.pos++
	}
	return p.src[start:p.pos]
}

func isIdentChar(c byte) bool {
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
}

func (p *pyParser) skipInlineWS() {
	for p.pos < len(p.src) && (p.src[p.pos] == ' ' || p.src[p.pos] == '\t') {
		p.pos++
	}
}

func (p *pyParser) matchWord(word string) bool {
	p.skipInlineWS()
	if p.pos+len(word) <= len(p.src) && p.src[p.pos:p.pos+len(word)] == word {
		after := p.pos + len(word)
		if after >= len(p.src) || !isIdentChar(p.src[after]) {
			p.pos = after
			p.skipInlineWS()
			return true
		}
	}
	return false
}

func (p *pyParser) expect(c byte) {
	p.skipInlineWS()
	if p.pos < len(p.src) && p.src[p.pos] == c {
		p.pos++
	}
}

// ParseRuby parses a subset of Ruby into the shape-lang AST.
// Handles: x = EXPR, (0...N).each { |x| body }, x += EXPR
func ParseRuby(src string) (*Program, error) {
	p := &rbParser{src: src, pos: 0}
	return p.program()
}

type rbParser struct {
	src string
	pos int
}

func (p *rbParser) program() (*Program, error) {
	prog := &Program{}
	p.skipWS()
	for p.pos < len(p.src) {
		stmt := p.parseStmt()
		if stmt != nil {
			prog.Stmts = append(prog.Stmts, stmt)
		}
		p.skipWS()
	}
	return prog, nil
}

func (p *rbParser) skipWS() {
	for p.pos < len(p.src) && (p.src[p.pos] == ' ' || p.src[p.pos] == '\t' || p.src[p.pos] == '\r' || p.src[p.pos] == '\n') {
		p.pos++
	}
	if p.pos < len(p.src) && p.src[p.pos] == '#' {
		for p.pos < len(p.src) && p.src[p.pos] != '\n' {
			p.pos++
		}
		p.skipWS()
	}
}

func (p *rbParser) parseStmt() Node {
	p.skipWS()
	if p.pos >= len(p.src) {
		return nil
	}

	// (START...END).each { |VAR| body }
	if p.pos < len(p.src) && p.src[p.pos] == '(' {
		return p.parseEachLoop()
	}

	// N.times { body } or N.times { |i| body }
	start := p.pos
	name := p.readIdent()
	if name == "" {
		// Try number
		n := p.readInt()
		if n >= 0 {
			p.skipWS()
			if p.matchStr(".times") {
				return p.parseTimesLoop(n)
			}
		}
		p.pos = start
		return nil
	}
	p.skipWS()

	// name += expr
	if p.pos+1 < len(p.src) && p.src[p.pos] == '+' && p.src[p.pos+1] == '=' {
		p.pos += 2
		p.skipWS()
		expr := p.parseExpr()
		return &SetStmt{Name: name, Expr: &BinOp{Op: "+", Left: &Ident{Name: name}, Right: expr}}
	}

	// name = expr
	if p.pos < len(p.src) && p.src[p.pos] == '=' && (p.pos+1 >= len(p.src) || p.src[p.pos+1] != '=') {
		p.pos++
		p.skipWS()
		expr := p.parseExpr()
		return &LetStmt{Name: name, Expr: expr}
	}

	p.pos = start
	return nil
}

func (p *rbParser) parseEachLoop() Node {
	p.pos++ // (
	p.skipWS()
	startVal := p.readInt()
	p.skipWS()
	// ... or ..
	dots := 0
	for p.pos < len(p.src) && p.src[p.pos] == '.' {
		dots++
		p.pos++
	}
	p.skipWS()
	endVal := p.readInt()
	p.skipWS()
	if p.pos < len(p.src) && p.src[p.pos] == ')' {
		p.pos++
	}
	p.skipWS()
	p.matchStr(".each")
	p.skipWS()

	// { |var| body }
	if p.pos < len(p.src) && p.src[p.pos] == '{' {
		p.pos++
	}
	p.skipWS()
	varName := "i"
	if p.pos < len(p.src) && p.src[p.pos] == '|' {
		p.pos++
		varName = p.readIdent()
		if p.pos < len(p.src) && p.src[p.pos] == '|' {
			p.pos++
		}
	}
	p.skipWS()
	var body []Node
	for p.pos < len(p.src) && p.src[p.pos] != '}' {
		s := p.parseStmt()
		if s != nil {
			body = append(body, s)
		}
		p.skipWS()
		// Skip semicolons.
		for p.pos < len(p.src) && p.src[p.pos] == ';' {
			p.pos++
			p.skipWS()
		}
	}
	if p.pos < len(p.src) {
		p.pos++ // }
	}

	// Exclusive range (...) means end is not included.
	actualEnd := endVal
	if dots == 2 {
		actualEnd = endVal + 1 // .. is inclusive
	}
	// ... is exclusive (default for shape-lang range)

	var rangeArgs []Expr
	if startVal == 0 {
		rangeArgs = []Expr{&IntLit{Value: actualEnd}}
	} else {
		rangeArgs = []Expr{&IntLit{Value: startVal}, &IntLit{Value: actualEnd}}
	}
	return &ForStmt{
		Name: varName,
		Iter: &CallExpr{Fn: "range", Args: rangeArgs},
		Body: body,
	}
}

func (p *rbParser) parseTimesLoop(n int) Node {
	p.skipWS()
	if p.pos < len(p.src) && p.src[p.pos] == '{' {
		p.pos++
	}
	p.skipWS()
	varName := "_"
	if p.pos < len(p.src) && p.src[p.pos] == '|' {
		p.pos++
		varName = p.readIdent()
		if p.pos < len(p.src) && p.src[p.pos] == '|' {
			p.pos++
		}
	}
	p.skipWS()
	var body []Node
	for p.pos < len(p.src) && p.src[p.pos] != '}' {
		s := p.parseStmt()
		if s != nil {
			body = append(body, s)
		}
		p.skipWS()
		for p.pos < len(p.src) && p.src[p.pos] == ';' {
			p.pos++
			p.skipWS()
		}
	}
	if p.pos < len(p.src) {
		p.pos++ // }
	}
	return &ForStmt{
		Name: varName,
		Iter: &CallExpr{Fn: "range", Args: []Expr{&IntLit{Value: n}}},
		Body: body,
	}
}

func (p *rbParser) parseExpr() Expr {
	left := p.parsePrimary()
	p.skipWS()
	for p.pos < len(p.src) && (p.src[p.pos] == '+' || p.src[p.pos] == '-' || p.src[p.pos] == '*') {
		if p.pos+1 < len(p.src) && p.src[p.pos+1] == '=' {
			break
		}
		op := string(p.src[p.pos])
		p.pos++
		p.skipWS()
		right := p.parsePrimary()
		left = &BinOp{Op: op, Left: left, Right: right}
		p.skipWS()
	}
	return left
}

func (p *rbParser) parsePrimary() Expr {
	p.skipWS()
	if p.pos < len(p.src) && p.src[p.pos] >= '0' && p.src[p.pos] <= '9' {
		return &IntLit{Value: p.readInt()}
	}
	name := p.readIdent()
	if name != "" {
		return &Ident{Name: name}
	}
	return &IntLit{Value: 0}
}

func (p *rbParser) readIdent() string {
	start := p.pos
	for p.pos < len(p.src) && (isIdentChar(p.src[p.pos]) || (p.pos > start && p.src[p.pos] >= '0' && p.src[p.pos] <= '9')) {
		p.pos++
	}
	return p.src[start:p.pos]
}

func (p *rbParser) readInt() int {
	if p.pos >= len(p.src) || p.src[p.pos] < '0' || p.src[p.pos] > '9' {
		return -1
	}
	n := 0
	for p.pos < len(p.src) && p.src[p.pos] >= '0' && p.src[p.pos] <= '9' {
		n = n*10 + int(p.src[p.pos]-'0')
		p.pos++
	}
	return n
}

func (p *rbParser) matchStr(s string) bool {
	if p.pos+len(s) <= len(p.src) && p.src[p.pos:p.pos+len(s)] == s {
		p.pos += len(s)
		return true
	}
	return false
}
