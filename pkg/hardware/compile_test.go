package hardware

import (
	"testing"
)

func TestCompileEmpty(t *testing.T) {
	c, err := CompileShape("test", "")
	if err != nil {
		t.Fatal(err)
	}
	if c != nil {
		t.Error("empty content should return nil circuit")
	}
}

func TestCompileLet(t *testing.T) {
	c, err := CompileShape("test", `let x = 42`)
	if err != nil {
		t.Fatal(err)
	}
	if c == nil {
		t.Fatal("expected circuit")
	}
	// Should have: const(42) -> reg(x)
	if len(c.Gates) != 2 {
		t.Fatalf("gates: %d, want 2", len(c.Gates))
	}
	if c.Gates[0].Kind != "const" || c.Gates[0].Value != "42" {
		t.Errorf("gate 0: %s %s, want const 42", c.Gates[0].Kind, c.Gates[0].Value)
	}
	if c.Gates[1].Kind != "reg" || c.Gates[1].Value != "x" {
		t.Errorf("gate 1: %s %s, want reg x", c.Gates[1].Kind, c.Gates[1].Value)
	}
}

func TestCompileBinOp(t *testing.T) {
	c, err := CompileShape("test", `let y = 1 + 2`)
	if err != nil {
		t.Fatal(err)
	}
	// const(1), const(2), alu(+), reg(y) = 4 gates
	if len(c.Gates) != 4 {
		t.Fatalf("gates: %d, want 4", len(c.Gates))
	}
	if c.Gates[2].Kind != "alu" || c.Gates[2].Op != "+" {
		t.Errorf("gate 2: %s %s, want alu +", c.Gates[2].Kind, c.Gates[2].Op)
	}
	if len(c.Gates[2].Inputs) != 2 {
		t.Errorf("alu inputs: %d, want 2", len(c.Gates[2].Inputs))
	}
}

func TestCompileFunctionCall(t *testing.T) {
	c, err := CompileShape("test", `print("hello")`)
	if err != nil {
		t.Fatal(err)
	}
	// const("hello"), call(print) = 2 gates
	if len(c.Gates) != 2 {
		t.Fatalf("gates: %d, want 2", len(c.Gates))
	}
	if c.Gates[1].Kind != "call" || c.Gates[1].Op != "print" {
		t.Errorf("gate 1: %s %s, want call print", c.Gates[1].Kind, c.Gates[1].Op)
	}
	if len(c.Outputs) != 1 {
		t.Errorf("outputs: %d, want 1 (print is output)", len(c.Outputs))
	}
}

func TestCompileIf(t *testing.T) {
	c, err := CompileShape("test", `
if true {
  print("yes")
} else {
  print("no")
}
`)
	if err != nil {
		t.Fatal(err)
	}
	// Should have: const(true), const("yes"), call(print), const("no"), call(print), mux
	hasAlu := false
	hasMux := false
	for _, g := range c.Gates {
		if g.Kind == "alu" {
			hasAlu = true
		}
		if g.Kind == "mux" {
			hasMux = true
		}
	}
	if !hasMux {
		t.Error("if statement should produce a mux gate")
	}
	_ = hasAlu
}

func TestCompileFor(t *testing.T) {
	c, err := CompileShape("test", `
for i in range(3) {
  print(i)
}
`)
	if err != nil {
		t.Fatal(err)
	}
	hasIter := false
	hasFeedback := false
	for _, g := range c.Gates {
		if g.Kind == "iter" {
			hasIter = true
		}
		if g.Kind == "feedback" {
			hasFeedback = true
		}
	}
	if !hasIter {
		t.Error("for loop should produce an iter gate")
	}
	if !hasFeedback {
		t.Error("for loop should produce a feedback gate")
	}
}

func TestCompileNestedExpr(t *testing.T) {
	c, err := CompileShape("test", `let z = (1 + 2) * 3`)
	if err != nil {
		t.Fatal(err)
	}
	// const(1), const(2), alu(+), const(3), alu(*), reg(z) = 6 gates
	if len(c.Gates) != 6 {
		t.Fatalf("gates: %d, want 6", len(c.Gates))
	}
}

func TestCompileRealShape(t *testing.T) {
	// Compile a real shell command shape.
	content := `
let target = default(arg0, prefix)
let segs = sort_list(children(target))
for seg in segs {
  let full = if_val(target == "", seg, target + "." + seg)
  let t = dim(full, "type")
  print(pad_right(seg, 10) + pad_right(t, 10))
}
`
	c, err := CompileShape("os.shell.cmd.ls", content)
	if err != nil {
		t.Fatal(err)
	}
	if c == nil {
		t.Fatal("expected circuit for ls command")
	}
	if len(c.Gates) < 10 {
		t.Errorf("ls should decompose into 10+ gates, got %d", len(c.Gates))
	}
	t.Logf("os.shell.cmd.ls decomposes into %d gates", len(c.Gates))
}

func TestTotalGateCount(t *testing.T) {
	c1, _ := CompileShape("a", `let x = 1`)
	c2, _ := CompileShape("b", `let y = 2 + 3`)
	total := TotalGateCount([]*Circuit{c1, c2})
	// c1: 2 gates, c2: 4 gates = 6
	if total != 6 {
		t.Errorf("total: %d, want 6", total)
	}
}
