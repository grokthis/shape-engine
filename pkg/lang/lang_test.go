package lang

import (
	"math"
	"strings"
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/engine"
	"github.com/ashbuilds/shape-engine/pkg/shape"
)

func TestLexBasic(t *testing.T) {
	tokens := lex(`shape engine.edit : engine {
  type: func
  "hello"
}`)
	var types []string
	for _, tok := range tokens {
		if tok.typ != tokNewline {
			types = append(types, tok.typ+":"+tok.val)
		}
	}
	if len(types) < 5 {
		t.Fatalf("expected at least 5 tokens, got %d: %v", len(types), types)
	}
	if types[0] != "ident:shape" {
		t.Errorf("first token: %s", types[0])
	}
	if types[1] != "ident:engine.edit" {
		t.Errorf("second token: %s", types[1])
	}
}

func TestLexOperators(t *testing.T) {
	tokens := lex(`a == b && c != d || !e`)
	var vals []string
	for _, tok := range tokens {
		if tok.typ != tokEOF {
			vals = append(vals, tok.val)
		}
	}
	expected := []string{"a", "==", "b", "&&", "c", "!=", "d", "||", "!", "e"}
	if len(vals) != len(expected) {
		t.Fatalf("expected %d tokens, got %d: %v", len(expected), len(vals), vals)
	}
	for i, v := range vals {
		if v != expected[i] {
			t.Errorf("token %d: got %q, want %q", i, v, expected[i])
		}
	}
}

func TestParseShapeDecl(t *testing.T) {
	prog, err := Parse(`shape engine.edit : engine, engine.propagate {
  type: func
  name: Edit
  layer: 3
  fn: propagation
  "Modifies a shape's character."
}`)
	if err != nil {
		t.Fatal(err)
	}
	if len(prog.Stmts) != 1 {
		t.Fatalf("expected 1 stmt, got %d", len(prog.Stmts))
	}
	decl, ok := prog.Stmts[0].(*ShapeDecl)
	if !ok {
		t.Fatalf("expected ShapeDecl, got %T", prog.Stmts[0])
	}
	if decl.ID != "engine.edit" {
		t.Errorf("ID = %q", decl.ID)
	}
	if len(decl.Deps) != 2 {
		t.Errorf("deps = %v", decl.Deps)
	}
	if decl.Dims["type"] != "func" {
		t.Errorf("type dim = %q", decl.Dims["type"])
	}
	if decl.Layer != 3 {
		t.Errorf("layer = %d", decl.Layer)
	}
	if decl.Fn != "propagation" {
		t.Errorf("fn = %q", decl.Fn)
	}
	if decl.Content != "Modifies a shape's character." {
		t.Errorf("content = %q", decl.Content)
	}
}

func TestParseFnDecl(t *testing.T) {
	prog, err := Parse(`fn propagation(change, self) {
  if contains(change.content, self.content) {
    auto "updated: " + change.content
  }
  flag
}`)
	if err != nil {
		t.Fatal(err)
	}
	if len(prog.Stmts) != 1 {
		t.Fatalf("expected 1 stmt, got %d", len(prog.Stmts))
	}
	fn, ok := prog.Stmts[0].(*FnDecl)
	if !ok {
		t.Fatalf("expected FnDecl, got %T", prog.Stmts[0])
	}
	if fn.Name != "propagation" {
		t.Errorf("name = %q", fn.Name)
	}
	if len(fn.Params) != 2 {
		t.Errorf("params = %v", fn.Params)
	}
	if len(fn.Body) != 2 {
		t.Errorf("body has %d stmts", len(fn.Body))
	}
}

func TestParseEditStmt(t *testing.T) {
	prog, err := Parse(`edit axiom "new content"`)
	if err != nil {
		t.Fatal(err)
	}
	if len(prog.Stmts) != 1 {
		t.Fatalf("expected 1 stmt, got %d", len(prog.Stmts))
	}
	edit, ok := prog.Stmts[0].(*EditStmt)
	if !ok {
		t.Fatalf("expected EditStmt, got %T", prog.Stmts[0])
	}
	if edit.ID != "axiom" {
		t.Errorf("ID = %q", edit.ID)
	}
}

func TestParseLetStmt(t *testing.T) {
	prog, err := Parse(`let shapes = query engine.*`)
	if err != nil {
		t.Fatal(err)
	}
	if len(prog.Stmts) != 1 {
		t.Fatalf("expected 1 stmt, got %d", len(prog.Stmts))
	}
	let, ok := prog.Stmts[0].(*LetStmt)
	if !ok {
		t.Fatalf("expected LetStmt, got %T", prog.Stmts[0])
	}
	if let.Name != "shapes" {
		t.Errorf("name = %q", let.Name)
	}
	q, ok := let.Expr.(*QueryExpr)
	if !ok {
		t.Fatalf("expected QueryExpr, got %T", let.Expr)
	}
	if q.Pattern != "engine.*" {
		t.Errorf("pattern = %q", q.Pattern)
	}
}

func TestParseAssert(t *testing.T) {
	prog, err := Parse(`assert law1 engine.edit`)
	if err != nil {
		t.Fatal(err)
	}
	a, ok := prog.Stmts[0].(*AssertStmt)
	if !ok {
		t.Fatalf("expected AssertStmt, got %T", prog.Stmts[0])
	}
	if a.Law != 1 {
		t.Errorf("law = %d", a.Law)
	}
	if a.ID != "engine.edit" {
		t.Errorf("ID = %q", a.ID)
	}
}

func TestParseBlock(t *testing.T) {
	prog, err := Parse(`block alice from engine.core "content warning"`)
	if err != nil {
		t.Fatal(err)
	}
	b, ok := prog.Stmts[0].(*BlockStmt)
	if !ok {
		t.Fatalf("expected BlockStmt, got %T", prog.Stmts[0])
	}
	if b.Author != "alice" || b.ShapeID != "engine.core" || b.Warning != "content warning" {
		t.Errorf("block = %+v", b)
	}
}

func TestParseUse(t *testing.T) {
	prog, err := Parse(`use "lib/transforms.sl"`)
	if err != nil {
		t.Fatal(err)
	}
	u, ok := prog.Stmts[0].(*UseStmt)
	if !ok {
		t.Fatalf("expected UseStmt, got %T", prog.Stmts[0])
	}
	if u.Path != "lib/transforms.sl" {
		t.Errorf("path = %q", u.Path)
	}
}

func TestParseForStmt(t *testing.T) {
	prog, err := Parse(`fn walk(change, self) {
  for s in query engine.* {
    auto s
  }
}`)
	if err != nil {
		t.Fatal(err)
	}
	fn := prog.Stmts[0].(*FnDecl)
	forStmt, ok := fn.Body[0].(*ForStmt)
	if !ok {
		t.Fatalf("expected ForStmt, got %T", fn.Body[0])
	}
	if forStmt.Name != "s" {
		t.Errorf("name = %q", forStmt.Name)
	}
}

func TestEvalShapeDecl(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`shape test.alpha {
  type: concept
  layer: 2
  "the first shape"
}`)
	if err != nil {
		t.Fatal(err)
	}

	_, err = Eval(prog, eng, "test-program")
	if err != nil {
		t.Fatal(err)
	}

	s, ok := eng.GetShape("test.alpha")
	if !ok {
		t.Fatal("shape test.alpha not found")
	}
	if s.Character.Content != "the first shape" {
		t.Errorf("content = %q", s.Character.Content)
	}
	if s.Character.Dimensions["type"] != "concept" {
		t.Errorf("type = %q", s.Character.Dimensions["type"])
	}
	if s.Structure.Emergence.Layer != 2 {
		t.Errorf("layer = %d", s.Structure.Emergence.Layer)
	}

	// Program shape should exist (decomposition).
	if _, ok := eng.GetShape("test-program"); !ok {
		t.Error("program shape not found")
	}
}

func TestEvalEdit(t *testing.T) {
	eng := engine.New()
	eng.AddShape(&shape.Shape{
		ID: "target",
		Character: shape.Character{
			Dimensions: map[string]string{"type": "data"},
			Content:    "old content",
		},
	})

	prog, err := Parse(`edit target "new content"`)
	if err != nil {
		t.Fatal(err)
	}

	_, err = Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}

	s, ok := eng.GetShape("target")
	if !ok {
		t.Fatal("target not found")
	}
	if s.Character.Content != "new content" {
		t.Errorf("content = %q", s.Character.Content)
	}
}

func TestEvalQuery(t *testing.T) {
	eng := engine.New()
	addShape(eng, "engine.edit", "func", 3)
	addShape(eng, "engine.propagate", "func", 3)
	addShape(eng, "other.thing", "data", 1)

	prog, err := Parse(`let results = query engine.*`)
	if err != nil {
		t.Fatal(err)
	}

	_, err = Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
}

func TestEvalFnTransform(t *testing.T) {
	eng := engine.New()

	src := `
shape base {
  type: data
  layer: 0
  "hello"
}

shape derived : base {
  type: data
  layer: 1
  fn: echo
  "old"
}

fn echo(change, self) {
  auto "echo: " + change.content
}

edit base "world"
`
	prog, err := Parse(src)
	if err != nil {
		t.Fatal(err)
	}

	out, err := Eval(prog, eng, "test")
	if err != nil {
		t.Fatal(err)
	}

	s, ok := eng.GetShape("derived")
	if !ok {
		t.Fatal("derived not found")
	}
	if s.Character.Content != "echo: world" {
		t.Errorf("derived content = %q, want %q", s.Character.Content, "echo: world")
	}

	if !strings.Contains(out, "auto-updated") {
		t.Errorf("output = %q, expected wave report", out)
	}

	// Fn decomposed as a shape.
	if _, ok := eng.GetShape("test.fn.echo"); !ok {
		t.Error("fn shape not found")
	}
}

func TestEvalAssert(t *testing.T) {
	eng := engine.New()
	addShape(eng, "test.shape", "concept", 1)

	prog, err := Parse(`assert law0 test.shape`)
	if err != nil {
		t.Fatal(err)
	}

	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "ok") {
		t.Errorf("output = %q, expected ok", out)
	}
}

func TestEvalConditionalTransform(t *testing.T) {
	eng := engine.New()

	src := `
shape source {
  type: data
  layer: 0
  "important update"
}

shape watcher : source {
  type: observer
  layer: 1
  fn: selective
  "watching"
}

fn selective(change, self) {
  if contains(change.content, "important") {
    auto "noticed: " + change.content
  }
  absorb
}

edit source "important update v2"
`
	prog, err := Parse(src)
	if err != nil {
		t.Fatal(err)
	}

	_, err = Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}

	s, _ := eng.GetShape("watcher")
	if s.Character.Content != "noticed: important update v2" {
		t.Errorf("content = %q", s.Character.Content)
	}
}

func TestEvalAbsorb(t *testing.T) {
	eng := engine.New()

	src := `
shape source {
  type: data
  layer: 0
  "boring change"
}

shape watcher : source {
  type: observer
  layer: 1
  fn: selective
  "original"
}

fn selective(change, self) {
  if contains(change.content, "important") {
    auto "noticed: " + change.content
  }
  absorb
}

edit source "still boring"
`
	prog, err := Parse(src)
	if err != nil {
		t.Fatal(err)
	}

	_, err = Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}

	s, _ := eng.GetShape("watcher")
	if s.Character.Content != "original" {
		t.Errorf("content should be unchanged, got %q", s.Character.Content)
	}
}

func TestProgramDecomposition(t *testing.T) {
	eng := engine.New()

	src := `
shape test.a {
  type: concept
  "first"
}

fn myTransform(change, self) {
  flag
}

let x = query test.*

edit test.a "updated"
`
	prog, err := Parse(src)
	if err != nil {
		t.Fatal(err)
	}

	_, err = Eval(prog, eng, "myprogram")
	if err != nil {
		t.Fatal(err)
	}

	if _, ok := eng.GetShape("myprogram"); !ok {
		t.Error("program shape missing")
	}
	if _, ok := eng.GetShape("myprogram.fn.myTransform"); !ok {
		t.Error("fn shape missing")
	}
	if _, ok := eng.GetShape("myprogram.edit.0"); !ok {
		t.Error("edit shape missing")
	}
}

func TestMatchGlob(t *testing.T) {
	tests := []struct {
		pattern, s string
		want       bool
	}{
		{"engine.*", "engine.edit", true},
		{"engine.*", "engine.propagate", true},
		{"engine.*", "other.thing", false},
		{"engine.*", "engine", false},
		{"*edit", "engine.edit", true},
		{"exact.match", "exact.match", true},
		{"exact.match", "other", false},
	}
	for _, tt := range tests {
		got := matchGlob(tt.pattern, tt.s)
		if got != tt.want {
			t.Errorf("matchGlob(%q, %q) = %v, want %v", tt.pattern, tt.s, got, tt.want)
		}
	}
}

func TestLexFloat(t *testing.T) {
	tokens := lex(`3.14`)
	if tokens[0].typ != tokFloat || tokens[0].val != "3.14" {
		t.Errorf("expected float:3.14, got %s:%s", tokens[0].typ, tokens[0].val)
	}
}

func TestLexMathOperators(t *testing.T) {
	tokens := lex(`2 * 3 / 4 % 5`)
	var vals []string
	for _, tok := range tokens {
		if tok.typ != tokEOF {
			vals = append(vals, tok.val)
		}
	}
	expected := []string{"2", "*", "3", "/", "4", "%", "5"}
	if len(vals) != len(expected) {
		t.Fatalf("expected %d tokens, got %d: %v", len(expected), len(vals), vals)
	}
	for i, v := range vals {
		if v != expected[i] {
			t.Errorf("token %d: got %q, want %q", i, v, expected[i])
		}
	}
}

func TestEvalMultiply(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`let x = 3 * 4`)
	if err != nil {
		t.Fatal(err)
	}
	_, err = Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
}

func TestEvalMathPrecedence(t *testing.T) {
	eng := engine.New()
	// 2 + 3 * 4 should be 14, not 20.
	prog, err := Parse(`print(2 + 3 * 4)`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "14") {
		t.Errorf("expected 14, got %q", out)
	}
}

func TestEvalFloatDivision(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(10.0 / 3)`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "3.333") {
		t.Errorf("expected ~3.333, got %q", out)
	}
}

func TestEvalFloatMultiply(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(3 * 4.5)`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "13.5") {
		t.Errorf("expected 13.5, got %q", out)
	}
}

func TestEvalModulo(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(17 % 5)`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "2") {
		t.Errorf("expected 2, got %q", out)
	}
}

func TestEvalSum(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(sum([1, 2, 3]))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "6") {
		t.Errorf("expected 6, got %q", out)
	}
}

func TestEvalAvg(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(avg([2, 4, 6]))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "4") {
		t.Errorf("expected 4, got %q", out)
	}
}

func TestEvalRound(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(round(3.14159, 2))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "3.14") {
		t.Errorf("expected 3.14, got %q", out)
	}
}

func TestEvalFloorCeil(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(floor(3.7))
print(ceil(3.2))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "3") {
		t.Errorf("expected floor=3, got %q", out)
	}
	if !strings.Contains(out, "4") {
		t.Errorf("expected ceil=4, got %q", out)
	}
}

func TestEvalPow(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(pow(2, 10))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "1024") {
		t.Errorf("expected 1024, got %q", out)
	}
}

func TestEvalAbs(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(abs(0 - 5))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "5") {
		t.Errorf("expected 5, got %q", out)
	}
}

func TestEvalMinMaxNum(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(min_num([5, 2, 8, 1]))
print(max_num([5, 2, 8, 1]))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "1") {
		t.Errorf("expected min=1, got %q", out)
	}
	if !strings.Contains(out, "8") {
		t.Errorf("expected max=8, got %q", out)
	}
}

// Ensure float contagion: int op float → float.
func TestEvalFloatContagion(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`let x = 5 + 1.5
print(x)`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "6.5") {
		t.Errorf("expected 6.5, got %q", out)
	}
}

// Suppress unused import warning for math.
var _ = math.Pi

// --- Byte primitives ---

func evalPrint(t *testing.T, eng *engine.Engine, code string) string {
	t.Helper()
	prog, err := Parse("print(" + code + ")")
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	return strings.TrimSpace(out)
}

func TestChrOrd(t *testing.T) {
	eng := engine.New()
	result := evalPrint(t, eng, `chr(65)`)
	if result != "A" {
		t.Errorf("chr(65) = %q, want A", result)
	}
	result2 := evalPrint(t, eng, `ord("A")`)
	if result2 != "65" {
		t.Errorf("ord(A) = %q, want 65", result2)
	}
}

func TestHexLiterals(t *testing.T) {
	eng := engine.New()
	result := evalPrint(t, eng, `0xFF`)
	if result != "255" {
		t.Errorf("0xFF = %q, want 255", result)
	}
	result2 := evalPrint(t, eng, `0x504B`)
	if result2 != "20555" {
		t.Errorf("0x504B = %q, want 20555", result2)
	}
}

func TestBytesCreate(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let b = bytes(4)
print(len(b))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "4") {
		t.Errorf("expected len=4, got %q", out)
	}
}

func TestBytesReadWrite(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let b = bytes(4)
let b = byte_set(b, 0, 0x50)
let b = byte_set(b, 1, 0x4B)
print(byte_get(b, 0))
print(byte_get(b, 1))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "80") || !strings.Contains(out, "75") {
		t.Errorf("expected 80 and 75, got %q", out)
	}
}

func TestBytesConcat(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let a = string_to_bytes("hello")
let b = string_to_bytes(" world")
let c = bytes_concat(a, b)
print(bytes_to_string(c))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "hello world") {
		t.Errorf("expected 'hello world', got %q", out)
	}
}

func TestBytesU32LE(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let b = bytes(4)
let b = write_u32_le(b, 0, 0x04034b50)
print(read_u32_le(b, 0))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	// 0x04034b50 = 67324752
	if !strings.Contains(out, "67324752") {
		t.Errorf("expected 67324752, got %q", out)
	}
}

func TestCRC32(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let b = string_to_bytes("hello")
print(crc32(b))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	// CRC32 of "hello" = 907060870
	if !strings.Contains(out, "907060870") {
		t.Errorf("expected 907060870, got %q", out)
	}
}

func TestBitwiseOps(t *testing.T) {
	eng := engine.New()
	result := evalPrint(t, eng, `bit_and(0xFF, 0x0F)`)
	if result != "15" {
		t.Errorf("bit_and(0xFF, 0x0F) = %q, want 15", result)
	}
	result2 := evalPrint(t, eng, `bit_or(0xF0, 0x0F)`)
	if result2 != "255" {
		t.Errorf("bit_or(0xF0, 0x0F) = %q, want 255", result2)
	}
	result3 := evalPrint(t, eng, `bit_shl(1, 8)`)
	if result3 != "256" {
		t.Errorf("bit_shl(1, 8) = %q, want 256", result3)
	}
}

func TestBytesSlice(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let b = string_to_bytes("hello world")
let s = bytes_slice(b, 6, 11)
print(bytes_to_string(s))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "world") {
		t.Errorf("expected 'world', got %q", out)
	}
}

func TestLibBase64RoundTrip(t *testing.T) {
	eng := engine.New()
	// Add the lib.base64 shape.
	eng.AddShape(&shape.Shape{
		ID: shape.ID("lib.base64"),
		Character: shape.Character{
			Dimensions: map[string]string{"type": "lib"},
			Content: `
fn _b64_char(n) {
  if n < 26 { auto chr(n + 65) }
  if n < 52 { auto chr(n - 26 + 97) }
  if n < 62 { auto chr(n - 52 + 48) }
  if n == 62 { auto "+" }
  auto "/"
}
fn _b64_val(c) {
  let n = ord(c)
  if n >= 65 { if n <= 90 { auto n - 65 } }
  if n >= 97 { if n <= 122 { auto n - 97 + 26 } }
  if n >= 48 { if n <= 57 { auto n - 48 + 52 } }
  if c == "+" { auto 62 }
  if c == "/" { auto 63 }
  auto 0
}
fn base64_encode(buf) {
  let n = len(buf)
  let out = ""
  let i = 0
  while i < n {
    let b0 = byte_get(buf, i)
    let b1 = 0
    let b2 = 0
    if i + 1 < n { let b1 = byte_get(buf, i + 1) }
    if i + 2 < n { let b2 = byte_get(buf, i + 2) }
    let out = out + _b64_char(bit_shr(b0, 2))
    let out = out + _b64_char(bit_or(bit_shl(bit_and(b0, 3), 4), bit_shr(b1, 4)))
    if i + 1 < n {
      let out = out + _b64_char(bit_or(bit_shl(bit_and(b1, 0x0F), 2), bit_shr(b2, 6)))
    }
    if i + 1 >= n { let out = out + "=" }
    if i + 2 < n {
      let out = out + _b64_char(bit_and(b2, 0x3F))
    }
    if i + 2 >= n { let out = out + "=" }
    let i = i + 3
  }
  auto out
}
fn base64_decode(s) {
  let n = len(s)
  let out = bytes(0)
  let i = 0
  while i < n {
    let c0 = at(s, i)
    let c1 = at(s, i + 1)
    let c2 = at(s, i + 2)
    let c3 = at(s, i + 3)
    let v0 = _b64_val(c0)
    let v1 = _b64_val(c1)
    let b0 = bit_or(bit_shl(v0, 2), bit_shr(v1, 4))
    let out = bytes_concat(out, bytes_from([b0]))
    if c2 != "=" {
      let v2 = _b64_val(c2)
      let b1 = bit_and(bit_or(bit_shl(v1, 4), bit_shr(v2, 2)), 0xFF)
      let out = bytes_concat(out, bytes_from([b1]))
      if c3 != "=" {
        let v3 = _b64_val(c3)
        let b2 = bit_and(bit_or(bit_shl(v2, 6), v3), 0xFF)
        let out = bytes_concat(out, bytes_from([b2]))
      }
    }
    let i = i + 4
  }
  auto out
}
`,
		},
	})

	prog, err := Parse(`
use "lib.base64"
let original = string_to_bytes("Hello, World!")
let encoded = base64_encode(original)
print(encoded)
let decoded = base64_decode(encoded)
print(bytes_to_string(decoded))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "SGVsbG8sIFdvcmxkIQ==") {
		t.Errorf("expected base64 encoding, got %q", out)
	}
	if !strings.Contains(out, "Hello, World!") {
		t.Errorf("expected decoded text, got %q", out)
	}
}

func TestLibZipRoundTrip(t *testing.T) {
	eng := engine.New()
	// Add lib.zip shape with minimal zip_create/zip_extract.
	eng.AddShape(&shape.Shape{
		ID: shape.ID("lib.zip"),
		Character: shape.Character{
			Dimensions: map[string]string{"type": "lib"},
			Content: `
fn _zip_local_header(name, data) {
  let name_bytes = string_to_bytes(name)
  let name_len = len(name_bytes)
  let data_len = len(data)
  let crc = crc32(data)
  let hdr = bytes(30)
  let hdr = write_u32_le(hdr, 0, 0x04034b50)
  let hdr = write_u16_le(hdr, 4, 20)
  let hdr = write_u16_le(hdr, 8, 0)
  let hdr = write_u32_le(hdr, 14, crc)
  let hdr = write_u32_le(hdr, 18, data_len)
  let hdr = write_u32_le(hdr, 22, data_len)
  let hdr = write_u16_le(hdr, 26, name_len)
  let hdr = write_u16_le(hdr, 28, 0)
  auto bytes_concat(bytes_concat(hdr, name_bytes), data)
}
fn _zip_central_entry(name, data, local_offset) {
  let name_bytes = string_to_bytes(name)
  let name_len = len(name_bytes)
  let data_len = len(data)
  let crc = crc32(data)
  let hdr = bytes(46)
  let hdr = write_u32_le(hdr, 0, 0x02014b50)
  let hdr = write_u16_le(hdr, 4, 20)
  let hdr = write_u16_le(hdr, 6, 20)
  let hdr = write_u32_le(hdr, 16, crc)
  let hdr = write_u32_le(hdr, 20, data_len)
  let hdr = write_u32_le(hdr, 24, data_len)
  let hdr = write_u16_le(hdr, 28, name_len)
  let hdr = write_u32_le(hdr, 42, local_offset)
  auto bytes_concat(hdr, name_bytes)
}
fn zip_create(entries) {
  let body = bytes(0)
  let central = bytes(0)
  let count = 0
  let i = 0
  while i < len(entries) {
    let entry = at(entries, i)
    let i = i + 1
    let name = at(entry, 0)
    let content = at(entry, 1)
    let data = string_to_bytes(content)
    let offset = len(body)
    let local = _zip_local_header(name, data)
    let body = bytes_concat(body, local)
    let centry = _zip_central_entry(name, data, offset)
    let central = bytes_concat(central, centry)
    let count = count + 1
  }
  let central_offset = len(body)
  let central_size = len(central)
  let eocd = bytes(22)
  let eocd = write_u32_le(eocd, 0, 0x06054b50)
  let eocd = write_u16_le(eocd, 8, count)
  let eocd = write_u16_le(eocd, 10, count)
  let eocd = write_u32_le(eocd, 12, central_size)
  let eocd = write_u32_le(eocd, 16, central_offset)
  auto bytes_concat(bytes_concat(body, central), eocd)
}
fn zip_extract(buf) {
  let blen = len(buf)
  let eocd_off = blen - 22
  while eocd_off >= 0 {
    if read_u32_le(buf, eocd_off) == 0x06054b50 { break }
    let eocd_off = eocd_off - 1
  }
  if eocd_off < 0 { auto [] }
  let count = read_u16_le(buf, eocd_off + 8)
  let cd_offset = read_u32_le(buf, eocd_off + 16)
  let entries = []
  let off = cd_offset
  let i = 0
  while i < count {
    let i = i + 1
    if read_u32_le(buf, off) != 0x02014b50 { break }
    let uncomp_size = read_u32_le(buf, off + 24)
    let name_len = read_u16_le(buf, off + 28)
    let extra_len = read_u16_le(buf, off + 30)
    let comment_len = read_u16_le(buf, off + 32)
    let local_offset = read_u32_le(buf, off + 42)
    let name = bytes_to_string(bytes_slice(buf, off + 46, off + 46 + name_len))
    let local_name_len = read_u16_le(buf, local_offset + 26)
    let local_extra_len = read_u16_le(buf, local_offset + 28)
    let data_start = local_offset + 30 + local_name_len + local_extra_len
    let data = bytes_to_string(bytes_slice(buf, data_start, data_start + uncomp_size))
    let entries = append(entries, [name, data])
    let off = off + 46 + name_len + extra_len + comment_len
  }
  auto entries
}
`,
		},
	})

	prog, err := Parse(`
use "lib.zip"
let z = zip_create([["test.txt", "hello world"], ["other.txt", "goodbye"]])
let entries = zip_extract(z)
print(len(entries))
let e0 = at(entries, 0)
print(at(e0, 0))
print(at(e0, 1))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "2") {
		t.Errorf("expected 2 entries, got %q", out)
	}
	if !strings.Contains(out, "test.txt") {
		t.Errorf("expected test.txt, got %q", out)
	}
	if !strings.Contains(out, "hello world") {
		t.Errorf("expected hello world, got %q", out)
	}
}

func TestUseLoadsShapeFns(t *testing.T) {
	eng := engine.New()
	// Add a library shape with a function definition.
	eng.AddShape(&shape.Shape{
		ID: shape.ID("test.lib.math"),
		Character: shape.Character{
			Dimensions: map[string]string{"type": "lib"},
			Content:    `fn double(x) { auto x * 2 }`,
		},
	})
	prog, err := Parse(`
use "test.lib.math"
print(double(21))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "42") {
		t.Errorf("expected 42, got %q", out)
	}
}

// --- Map builtins ---

func TestMapLiteral(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let m = {name: "alice", age: "30"}
print(map_get(m, "name"))
print(map_get(m, "age"))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "alice") {
		t.Errorf("expected alice, got %q", out)
	}
	if !strings.Contains(out, "30") {
		t.Errorf("expected 30, got %q", out)
	}
}

func TestMapSetAndKeys(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let m = map_new()
let m = map_set(m, "x", 1)
let m = map_set(m, "y", 2)
print(len(m))
print(map_has(m, "x"))
print(map_has(m, "z"))
let ks = map_keys(m)
print(at(ks, 0))
print(at(ks, 1))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "2") {
		t.Errorf("expected len=2, got %q", out)
	}
	if !strings.Contains(out, "true") {
		t.Errorf("expected has x=true, got %q", out)
	}
	if !strings.Contains(out, "false") {
		t.Errorf("expected has z=false, got %q", out)
	}
	// keys are sorted: x, y
	if !strings.Contains(out, "x") || !strings.Contains(out, "y") {
		t.Errorf("expected keys x and y, got %q", out)
	}
}

func TestMapDelete(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let m = {a: "1", b: "2", c: "3"}
let m = map_delete(m, "b")
print(len(m))
print(map_has(m, "b"))
print(map_has(m, "a"))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "2") {
		t.Errorf("expected len=2 after delete, got %q", out)
	}
}

func TestMapMerge(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let a = {x: "1"}
let b = {y: "2", x: "99"}
let c = map_merge(a, b)
print(len(c))
print(map_get(c, "x"))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "2") {
		t.Errorf("expected len=2, got %q", out)
	}
	// b wins on "x"
	if !strings.Contains(out, "99") {
		t.Errorf("expected x=99 (b wins merge), got %q", out)
	}
}

func TestMapGetDefault(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let m = {key: "val"}
print(map_get(m, "missing", "default_val"))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "default_val") {
		t.Errorf("expected default_val, got %q", out)
	}
}

func TestMapValues(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let m = {a: "10", b: "20"}
let vs = map_values(m)
print(len(vs))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "2") {
		t.Errorf("expected 2 values, got %q", out)
	}
}

// --- JSON builtins ---

func TestJSONEncodeDecodeRoundTrip(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let m = {name: "alice", score: 42}
let j = json_encode(m)
print(j)
let m2 = json_decode(j)
print(map_get(m2, "name"))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "alice") {
		t.Errorf("expected alice in output, got %q", out)
	}
	if !strings.Contains(out, "42") {
		t.Errorf("expected 42 in output, got %q", out)
	}
}

func TestJSONEncodeList(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(json_encode([1, 2, 3]))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "[1,2,3]") {
		t.Errorf("expected [1,2,3], got %q", out)
	}
}

func TestJSONDecodeList(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let lst = json_decode("[10,20,30]")
print(len(lst))
print(at(lst, 1))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "3") {
		t.Errorf("expected len=3, got %q", out)
	}
	if !strings.Contains(out, "20") {
		t.Errorf("expected element 20, got %q", out)
	}
}

// --- Time / env / URL builtins ---

func TestTimeNow(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let ts = time_now()
print(ts > 0)
let ms = time_ms()
print(ms > 0)
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "true") {
		t.Errorf("expected timestamps > 0, got %q", out)
	}
}

func TestURLEncoDecode(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let encoded = url_encode("hello world & more")
let decoded = url_decode(encoded)
print(decoded)
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "hello world & more") {
		t.Errorf("expected decoded URL, got %q", out)
	}
}

// --- Crypto builtins ---

func TestSHA256(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`print(sha256("hello"))`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	// SHA256 of "hello" is 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
	if !strings.Contains(out, "2cf24dba") {
		t.Errorf("expected sha256 of 'hello', got %q", out)
	}
}

func TestEd25519KeygenSignVerify(t *testing.T) {
	eng := engine.New()
	prog, err := Parse(`
let kp = ed25519_keygen()
let pub = map_get(kp, "public")
let priv = map_get(kp, "private")
let sig = ed25519_sign("hello world", priv)
let ok = ed25519_verify("hello world", sig, pub)
print(ok)
let bad = ed25519_verify("tampered", sig, pub)
print(bad)
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	lines := strings.Split(strings.TrimSpace(out), "\n")
	if len(lines) < 2 {
		t.Fatalf("expected 2 lines, got %q", out)
	}
	if lines[0] != "true" {
		t.Errorf("expected valid sig to verify=true, got %q", lines[0])
	}
	if lines[1] != "false" {
		t.Errorf("expected tampered sig to verify=false, got %q", lines[1])
	}
}

// --- Shape to map ---

func TestShapeToMap(t *testing.T) {
	eng := engine.New()
	eng.AddShape(&shape.Shape{
		ID: "test.shape.foo",
		Character: shape.Character{
			Content:    "the content",
			Dimensions: map[string]string{"type": "data"},
		},
		Structure: shape.Structure{
			Emergence: shape.Emergence{Layer: 2},
		},
	})
	prog, err := Parse(`
let m = shape_to_map("test.shape.foo")
print(map_get(m, "id"))
let ch = map_get(m, "character")
print(map_get(ch, "content"))
let st = map_get(m, "structure")
let em = map_get(st, "emergence")
print(map_get(em, "layer"))
`)
	if err != nil {
		t.Fatal(err)
	}
	out, err := Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out, "test.shape.foo") {
		t.Errorf("expected shape id, got %q", out)
	}
	if !strings.Contains(out, "the content") {
		t.Errorf("expected content, got %q", out)
	}
	if !strings.Contains(out, "2") {
		t.Errorf("expected layer 2, got %q", out)
	}
}

// --- helpers ---

func addShape(eng *engine.Engine, id, typ string, layer int) {
	eng.AddShape(&shape.Shape{
		ID: shape.ID(id),
		Character: shape.Character{
			Dimensions: map[string]string{"type": typ},
		},
		Structure: shape.Structure{
			Emergence: shape.Emergence{Layer: layer},
		},
	})
}
