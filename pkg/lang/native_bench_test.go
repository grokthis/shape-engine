package lang

// Native Go baselines for comparison with shape-lang eval.
// These measure the same operations in pure Go to show
// the overhead of the shape-lang interpreter.

import "testing"

func BenchmarkNativeAdd(b *testing.B) {
	for i := 0; i < b.N; i++ {
		x := 1 + 2
		_ = x
	}
}

func BenchmarkNativeMul(b *testing.B) {
	for i := 0; i < b.N; i++ {
		x := 6 * 7
		_ = x
	}
}

func BenchmarkNativeDiv(b *testing.B) {
	for i := 0; i < b.N; i++ {
		x := 100 / 7
		_ = x
	}
}

func BenchmarkNativeComplex(b *testing.B) {
	for i := 0; i < b.N; i++ {
		x := (1+2)*3 - 4/2
		_ = x
	}
}

func BenchmarkNativeLoop1000(b *testing.B) {
	for i := 0; i < b.N; i++ {
		s := 0
		for j := 0; j < 1000; j++ {
			s += j
		}
		_ = s
	}
}

func BenchmarkNativeNestedLoop(b *testing.B) {
	for i := 0; i < b.N; i++ {
		s := 0
		for j := 0; j < 10; j++ {
			for k := 0; k < 10; k++ {
				s++
			}
		}
		_ = s
	}
}

func BenchmarkNativeListAppend100(b *testing.B) {
	for i := 0; i < b.N; i++ {
		l := make([]int, 0)
		for j := 0; j < 100; j++ {
			l = append(l, j)
		}
		_ = l
	}
}

func BenchmarkNativeStringConcat(b *testing.B) {
	for i := 0; i < b.N; i++ {
		x := "hello" + " " + "world"
		_ = x
	}
}

func BenchmarkNativeMapOps(b *testing.B) {
	for i := 0; i < b.N; i++ {
		m := make(map[string]int)
		m["a"] = 1
		m["b"] = 2
		m["c"] = 3
		_ = m["b"]
	}
}

func BenchmarkNativePow(b *testing.B) {
	for i := 0; i < b.N; i++ {
		result := 1
		for j := 0; j < 20; j++ {
			result *= 2
		}
		_ = result
	}
}

func BenchmarkNativeIf(b *testing.B) {
	for i := 0; i < b.N; i++ {
		x := 42
		var y int
		if x > 10 {
			y = x * 2
		} else {
			y = x + 1
		}
		_ = y
	}
}
