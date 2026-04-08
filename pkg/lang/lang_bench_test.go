package lang

import (
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/engine"
	"github.com/ashbuilds/shape-engine/pkg/shape"
)

func benchEval(b *testing.B, code string) {
	eng := engine.New()
	prog, err := Parse(code)
	if err != nil {
		b.Fatal(err)
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

// --- Parse ---

func BenchmarkParseLet(b *testing.B) {
	code := `let x = 42`
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Parse(code)
	}
}

func BenchmarkParseShape(b *testing.B) {
	code := `shape bench.test { type: test layer: 3 "hello world" }`
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Parse(code)
	}
}

func BenchmarkParseComplex(b *testing.B) {
	code := `
let total = 0
for i in range(10) {
  if i > 5 {
    set total = total + i * 2
  } else {
    set total = total + i
  }
}
print(total)
`
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Parse(code)
	}
}

// --- Eval: Arithmetic ---

func BenchmarkEvalAdd(b *testing.B)        { benchEval(b, `let x = 1 + 2`) }
func BenchmarkEvalMul(b *testing.B)        { benchEval(b, `let x = 6 * 7`) }
func BenchmarkEvalDiv(b *testing.B)        { benchEval(b, `let x = 100 / 7`) }
func BenchmarkEvalComplex(b *testing.B)    { benchEval(b, `let x = (1 + 2) * 3 - 4 / 2`) }

// --- Eval: String ---

func BenchmarkEvalStringConcat(b *testing.B)   { benchEval(b, `let x = "hello" + " " + "world"`) }
func BenchmarkEvalStringContains(b *testing.B) { benchEval(b, `let x = contains("hello world", "world")`) }
func BenchmarkEvalStringSplit(b *testing.B)     { benchEval(b, `let x = split("a,b,c,d,e", ",")`) }
func BenchmarkEvalStringReplace(b *testing.B)   { benchEval(b, `let x = replace("hello world", "world", "shape")`) }

// --- Eval: Control flow ---

func BenchmarkEvalLoop10(b *testing.B) {
	benchEval(b, `
let s = 0
for i in range(10) {
  set s = s + i
}
`)
}

func BenchmarkEvalLoop100(b *testing.B) {
	benchEval(b, `
let s = 0
for i in range(100) {
  set s = s + i
}
`)
}

func BenchmarkEvalLoop1000(b *testing.B) {
	benchEval(b, `
let s = 0
for i in range(1000) {
  set s = s + i
}
`)
}

func BenchmarkEvalNestedLoop(b *testing.B) {
	benchEval(b, `
let s = 0
for i in range(10) {
  for j in range(10) {
    set s = s + 1
  }
}
`)
}

func BenchmarkEvalIf(b *testing.B) {
	benchEval(b, `
let x = 42
if x > 10 {
  let y = x * 2
} else {
  let y = x + 1
}
`)
}

func BenchmarkEvalWhile(b *testing.B) {
	benchEval(b, `
let i = 0
while i < 100 {
  set i = i + 1
}
`)
}

// --- Eval: Shape operations ---

func BenchmarkEvalShapeExists(b *testing.B) {
	eng := engine.New()
	eng.AddShape(shapeForBench("bench.a"))
	prog, _ := Parse(`let x = exists("bench.a")`)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

func BenchmarkEvalShapeContent(b *testing.B) {
	eng := engine.New()
	eng.AddShape(shapeForBenchContent("bench.a", "hello world this is content"))
	prog, _ := Parse(`let x = content("bench.a")`)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

func BenchmarkEvalChildren(b *testing.B) {
	eng := engine.New()
	for i := 0; i < 50; i++ {
		eng.AddShape(shapeForBench("bench.child." + string(rune('a'+i%26)) + string(rune('0'+i/26))))
	}
	prog, _ := Parse(`let x = children("bench.child")`)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Eval(prog, eng, "")
	}
}

// --- Eval: List operations ---

func BenchmarkEvalListSort(b *testing.B) {
	benchEval(b, `let x = sort_list(["z","m","a","r","b","k","d","w","c","f"])`)
}

func BenchmarkEvalListAppend(b *testing.B) {
	benchEval(b, `
let l = []
for i in range(100) {
  set l = append(l, i)
}
`)
}

// --- Eval: Map operations ---

func BenchmarkEvalMapOps(b *testing.B) {
	benchEval(b, `
let m = map_new()
set m = map_set(m, "a", 1)
set m = map_set(m, "b", 2)
set m = map_set(m, "c", 3)
let v = map_get(m, "b")
`)
}

// --- Eval: Math builtins ---

func BenchmarkEvalPow(b *testing.B)   { benchEval(b, `let x = pow(2, 20)`) }
func BenchmarkEvalSum(b *testing.B)   { benchEval(b, `let x = sum([1,2,3,4,5,6,7,8,9,10])`) }
func BenchmarkEvalAbs(b *testing.B) {
	benchEval(b, "let n = 0 - 42\nlet x = abs(n)")
}
func BenchmarkEvalRound(b *testing.B) { benchEval(b, `let x = round(3.14159, 2)`) }

// --- Boot simulation ---

func BenchmarkBootShapes100(b *testing.B) {
	shapes := make([]string, 100)
	for i := range shapes {
		shapes[i] = `shape boot.s` + string(rune('a'+i%26)) + string(rune('0'+i/26)) + ` { type: test layer: 3 "content" }`
	}
	progs := make([]*Program, len(shapes))
	for i, s := range shapes {
		progs[i], _ = Parse(s)
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng := engine.New()
		for _, p := range progs {
			Eval(p, eng, "")
		}
	}
}

// helpers

func shapeForBench(id string) *shape.Shape {
	return &shape.Shape{ID: shape.ID(id)}
}

func shapeForBenchContent(id, content string) *shape.Shape {
	return &shape.Shape{ID: shape.ID(id), Character: shape.Character{Content: content}}
}
