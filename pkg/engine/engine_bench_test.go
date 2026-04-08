package engine

import (
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/transform"
)

// --- Core operations ---

func BenchmarkAddShape(b *testing.B) {
	eng := New()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		s := &shape.Shape{ID: shape.ID("bench." + string(rune('a'+i%26)) + string(rune('0'+i%10)))}
		eng.AddShape(s)
	}
}

func BenchmarkGetShape(b *testing.B) {
	eng := New()
	for i := 0; i < 1000; i++ {
		eng.AddShape(&shape.Shape{ID: shape.ID("bench." + string(rune('a'+i%26)) + string(rune('0'+i/26%10)))})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.GetShape("bench.m5")
	}
}

func BenchmarkEdit(b *testing.B) {
	eng := New()
	eng.AddShape(&shape.Shape{ID: "bench.target", Character: shape.Character{Content: "v0"}})
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("bench.target", "v1")
	}
}

func BenchmarkEditWithPropagation(b *testing.B) {
	eng := New()
	eng.RegisterTransform(&mockTransform{name: "bench.Auto", result: transform.AutoUpdate, content: "updated"})
	eng.AddShape(&shape.Shape{ID: "base", Character: shape.Character{Content: "v0"}})
	for i := 0; i < 10; i++ {
		eng.AddShape(&shape.Shape{
			ID: shape.ID("dep." + string(rune('a'+i))),
			Structure: shape.Structure{Transformation: shape.Transformation{
				Fn: "bench.Auto", Deps: []shape.ID{"base"},
			}},
		})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("base", "v1")
	}
}

func BenchmarkEditCascade(b *testing.B) {
	eng := New()
	eng.RegisterTransform(&mockTransform{name: "bench.Auto", result: transform.AutoUpdate, content: "cascaded"})
	// Chain: a -> b -> c -> d -> e (depth 5)
	eng.AddShape(&shape.Shape{ID: "chain.a", Character: shape.Character{Content: "v0"}})
	for i := 1; i < 5; i++ {
		prev := shape.ID("chain." + string(rune('a'+i-1)))
		cur := shape.ID("chain." + string(rune('a'+i)))
		eng.AddShape(&shape.Shape{
			ID: cur,
			Structure: shape.Structure{Transformation: shape.Transformation{
				Fn: "bench.Auto", Deps: []shape.ID{prev},
			}},
		})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("chain.a", "v1")
	}
}

func BenchmarkValidate(b *testing.B) {
	eng := New()
	for i := 0; i < 100; i++ {
		eng.AddShape(&shape.Shape{ID: shape.ID("val." + string(rune('a'+i%26)) + string(rune('0'+i/26)))})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Validate()
	}
}

func BenchmarkMomentAppend(b *testing.B) {
	eng := New()
	eng.AddShape(&shape.Shape{ID: "bench.a", Character: shape.Character{Content: "v0"}})
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("bench.a", "v1")
	}
	b.ReportMetric(float64(eng.MomentCount()), "moments")
}

// --- Scaling ---

func BenchmarkAddShape100(b *testing.B)  { benchAddN(b, 100) }
func BenchmarkAddShape1000(b *testing.B) { benchAddN(b, 1000) }

func benchAddN(b *testing.B, n int) {
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng := New()
		for j := 0; j < n; j++ {
			eng.AddShape(&shape.Shape{ID: shape.ID("s" + string(rune(j)))})
		}
	}
}

func BenchmarkPropagationWidth10(b *testing.B)  { benchPropWidth(b, 10) }
func BenchmarkPropagationWidth100(b *testing.B) { benchPropWidth(b, 100) }

func benchPropWidth(b *testing.B, width int) {
	eng := New()
	eng.AddShape(&shape.Shape{ID: "root", Character: shape.Character{Content: "v0"}})
	for i := 0; i < width; i++ {
		eng.AddShape(&shape.Shape{
			ID:        shape.ID("dep." + string(rune(i))),
			Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"root"}}},
		})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("root", "v1")
	}
}

func BenchmarkPropagationDepth5(b *testing.B)  { benchPropDepth(b, 5) }
func BenchmarkPropagationDepth20(b *testing.B) { benchPropDepth(b, 20) }

func benchPropDepth(b *testing.B, depth int) {
	eng := New()
	eng.AddShape(&shape.Shape{ID: "d.0", Character: shape.Character{Content: "v0"}})
	for i := 1; i < depth; i++ {
		eng.AddShape(&shape.Shape{
			ID:        shape.ID("d." + string(rune(i))),
			Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{shape.ID("d." + string(rune(i-1)))}}},
		})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("d.0", "v1")
	}
}
