package lang

import (
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/engine"
)

// === Correctness ===

func TestParsePythonLoop(t *testing.T) {
	prog, err := ParsePython(`
s = 0
for i in range(1000):
    s += i
`)
	if err != nil {
		t.Fatal(err)
	}
	if len(prog.Stmts) != 2 {
		t.Fatalf("stmts: %d, want 2", len(prog.Stmts))
	}

	eng := engine.New()
	result, fused := tryFuseStatic("s", 0, prog.Stmts[1].(*ForStmt))
	if !fused {
		t.Fatal("expected fusion")
	}
	if result != 499500 {
		t.Errorf("result: %d, want 499500", result)
	}
	_ = eng
}

func TestParseRubyLoop(t *testing.T) {
	prog, err := ParseRuby(`
s = 0
(0...1000).each { |i| s += i }
`)
	if err != nil {
		t.Fatal(err)
	}
	if len(prog.Stmts) != 2 {
		t.Fatalf("stmts: %d, want 2", len(prog.Stmts))
	}

	result, fused := tryFuseStatic("s", 0, prog.Stmts[1].(*ForStmt))
	if !fused {
		t.Fatal("expected fusion")
	}
	if result != 499500 {
		t.Errorf("result: %d, want 499500", result)
	}
}

// === The polyglot benchmark ===
// Same computation, four languages, one formula.

func BenchmarkPolyglot_Go(b *testing.B) {
	prog, _ := ParseGo(`
s := 0
for j := 0; j < 1000; j++ {
	s += j
}
`)
	eng := engine.New()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

func BenchmarkPolyglot_ShapeLang(b *testing.B) {
	prog, _ := Parse(`
let s = 0
for i in range(1000) {
  set s = s + i
}
`)
	eng := engine.New()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

func BenchmarkPolyglot_Python(b *testing.B) {
	prog, _ := ParsePython(`
s = 0
for i in range(1000):
    s += i
`)
	eng := engine.New()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

func BenchmarkPolyglot_Ruby(b *testing.B) {
	prog, _ := ParseRuby(`
s = 0
(0...1000).each { |i| s += i }
`)
	eng := engine.New()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}
