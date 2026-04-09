package lang

import (
	"testing"
)

func TestParseGoLoop(t *testing.T) {
	src := `
s := 0
for i := 0; i < 1000; i++ {
	s += i
}
`
	prog, err := ParseGo(src)
	if err != nil {
		t.Fatal(err)
	}
	if len(prog.Stmts) != 2 {
		t.Fatalf("stmts: %d, want 2", len(prog.Stmts))
	}
	if prog.Stmts[0].nodeType() != "let" {
		t.Errorf("stmt 0: %s, want let", prog.Stmts[0].nodeType())
	}
	if prog.Stmts[1].nodeType() != "for" {
		t.Errorf("stmt 1: %s, want for", prog.Stmts[1].nodeType())
	}

	// Eval it through the shape engine.
	eng := testEngine()
	_, err = Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
}

func TestParseGoNested(t *testing.T) {
	src := `
s := 0
for i := 0; i < 10; i++ {
	for j := 0; j < 10; j++ {
		s++
	}
}
`
	prog, err := ParseGo(src)
	if err != nil {
		t.Fatal(err)
	}

	eng := testEngine()
	_, err = Eval(prog, eng, "")
	if err != nil {
		t.Fatal(err)
	}
}

// The original Go benchmark, word for word, running on the shape engine.
func BenchmarkGoOnShapes_Loop1000(b *testing.B) {
	// This is the EXACT Go code from BenchmarkNativeLoop1000.
	src := `
s := 0
for j := 0; j < 1000; j++ {
	s += j
}
`
	prog, err := ParseGo(src)
	if err != nil {
		b.Fatal(err)
	}
	eng := testEngine()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

func BenchmarkGoOnShapes_Nested10x10(b *testing.B) {
	src := `
s := 0
for j := 0; j < 10; j++ {
	for k := 0; k < 10; k++ {
		s++
	}
}
`
	prog, err := ParseGo(src)
	if err != nil {
		b.Fatal(err)
	}
	eng := testEngine()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

func BenchmarkGoOnShapes_Simple(b *testing.B) {
	src := `
x := (1 + 2) * 3 - 4 / 2
`
	prog, err := ParseGo(src)
	if err != nil {
		b.Fatal(err)
	}
	eng := testEngine()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}
