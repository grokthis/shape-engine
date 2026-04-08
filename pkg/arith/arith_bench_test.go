package arith

import "testing"

func BenchmarkAddSmall(b *testing.B) {
	a, c := FromInt(42), FromInt(17)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		a.Add(c)
	}
}

func BenchmarkMulSmall(b *testing.B) {
	a, c := FromInt(42), FromInt(17)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		a.Mul(c)
	}
}

func BenchmarkDivExact(b *testing.B) {
	a, c := FromInt(100), FromInt(5)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		a.Div(c)
	}
}

func BenchmarkDivRational(b *testing.B) {
	a, c := FromInt(1), FromInt(3)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		a.Div(c)
	}
}

func BenchmarkPowSmall(b *testing.B) {
	base, exp := FromInt(2), FromInt(20)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		base.Pow(exp)
	}
}

func BenchmarkPowLarge(b *testing.B) {
	base, exp := FromInt(2), FromInt(1000)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		base.Pow(exp)
	}
}

func BenchmarkAddLarge(b *testing.B) {
	a := FromInt(2).Pow(FromInt(500))
	c := FromInt(3).Pow(FromInt(300))
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		a.Add(c)
	}
}

func BenchmarkMulLarge(b *testing.B) {
	a := FromInt(2).Pow(FromInt(500))
	c := FromInt(3).Pow(FromInt(300))
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		a.Mul(c)
	}
}

func BenchmarkRationalPrecision(b *testing.B) {
	// Sum 1/1 + 1/2 + 1/3 + ... + 1/100
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		sum := FromInt(0)
		for j := 1; j <= 100; j++ {
			sum = sum.Add(FromInt(1).Div(FromInt(j)))
		}
	}
}

func BenchmarkFormat(b *testing.B) {
	n := FromInt(1).Div(FromInt(7))
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Format(n, 10)
	}
}
