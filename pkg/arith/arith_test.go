package arith

import (
	"testing"
)

func TestFromInt(t *testing.T) {
	n := FromInt(42)
	if n.ToInt() != 42 {
		t.Errorf("got %d, want 42", n.ToInt())
	}
	if n.String() != "42" {
		t.Errorf("got %s, want 42", n.String())
	}
}

func TestAddIntegers(t *testing.T) {
	a := FromInt(100)
	b := FromInt(200)
	c := a.Add(b)
	if c.ToInt() != 300 {
		t.Errorf("100 + 200 = %d", c.ToInt())
	}
	if c.IsRat {
		t.Error("int + int should be int")
	}
}

func TestSubIntegers(t *testing.T) {
	a := FromInt(10)
	b := FromInt(3)
	c := a.Sub(b)
	if c.ToInt() != 7 {
		t.Errorf("10 - 3 = %d", c.ToInt())
	}
}

func TestMulIntegers(t *testing.T) {
	a := FromInt(6)
	b := FromInt(7)
	c := a.Mul(b)
	if c.ToInt() != 42 {
		t.Errorf("6 * 7 = %d", c.ToInt())
	}
}

func TestDivExact(t *testing.T) {
	a := FromInt(10)
	b := FromInt(5)
	c := a.Div(b)
	if c.ToInt() != 2 {
		t.Errorf("10 / 5 = %d", c.ToInt())
	}
	if c.IsRat {
		t.Error("exact division should be int")
	}
}

func TestDivRational(t *testing.T) {
	a := FromInt(1)
	b := FromInt(3)
	c := a.Div(b)
	if !c.IsRat {
		t.Error("1/3 should be rational")
	}
	// 1/3 * 3 should be exactly 1
	d := c.Mul(b)
	if !d.Eq(a) {
		t.Errorf("1/3 * 3 = %s, want 1", d.ExactString())
	}
}

func TestDivByZero(t *testing.T) {
	a := FromInt(10)
	b := FromInt(0)
	c := a.Div(b)
	if c.ToInt() != 0 {
		t.Errorf("10 / 0 = %d, want 0", c.ToInt())
	}
}

func TestArbitraryPrecisionAdd(t *testing.T) {
	// 10^50 + 10^50 = 2 * 10^50
	a := FromInt(1).Pow(FromInt(50))
	ten := FromInt(10)
	big := ten.Pow(FromInt(50))
	sum := big.Add(big)
	twoTen50 := FromInt(2).Mul(ten.Pow(FromInt(50)))
	if !sum.Eq(twoTen50) {
		t.Errorf("10^50 + 10^50 != 2*10^50")
	}
	_ = a
}

func TestArbitraryPrecisionMul(t *testing.T) {
	// 2^100 * 2^100 = 2^200
	two := FromInt(2)
	a := two.Pow(FromInt(100))
	b := a.Mul(a)
	expected := two.Pow(FromInt(200))
	if !b.Eq(expected) {
		t.Errorf("2^100 * 2^100 != 2^200")
	}
}

func TestFromFloat(t *testing.T) {
	n := FromFloat(3.14)
	if n.ToFloat64() != 3.14 {
		t.Errorf("got %f, want 3.14", n.ToFloat64())
	}
}

func TestRationalPreservesPrecision(t *testing.T) {
	// 1/7 + 1/7 + 1/7 + 1/7 + 1/7 + 1/7 + 1/7 = 1
	seventh := FromInt(1).Div(FromInt(7))
	sum := FromInt(0)
	for i := 0; i < 7; i++ {
		sum = sum.Add(seventh)
	}
	if !sum.Eq(FromInt(1)) {
		t.Errorf("7 * (1/7) = %s, want 1", sum.ExactString())
	}
}

func TestExactDecimalArithmetic(t *testing.T) {
	// 1/10 + 2/10 = 3/10 exactly. No float64 involved.
	a := FromInt(1).Div(FromInt(10))
	b := FromInt(2).Div(FromInt(10))
	c := a.Add(b)
	expected := FromInt(3).Div(FromInt(10))
	if !c.Eq(expected) {
		t.Errorf("1/10 + 2/10 = %s, want 3/10 (%s)", c.ExactString(), expected.ExactString())
	}
	// This is the test that float64 FAILS: 0.1 + 0.2 != 0.3 in IEEE 754.
	// With exact rationals, it works.
}

func TestFromFloatRoundtrip(t *testing.T) {
	// FromFloat is lossy (inherits float64 precision).
	// But the NUMBER stays exact after that point.
	n := FromFloat(3.14)
	doubled := n.Add(n)
	expected := FromFloat(6.28)
	if !doubled.Eq(expected) {
		t.Errorf("3.14 + 3.14 = %s, want 6.28", doubled.ExactString())
	}
}

func TestAbs(t *testing.T) {
	if FromInt(-5).Abs().ToInt() != 5 {
		t.Error("abs(-5) != 5")
	}
	if FromInt(5).Abs().ToInt() != 5 {
		t.Error("abs(5) != 5")
	}
}

func TestPow(t *testing.T) {
	if FromInt(2).Pow(FromInt(10)).ToInt() != 1024 {
		t.Error("2^10 != 1024")
	}
	if FromInt(2).Pow(FromInt(0)).ToInt() != 1 {
		t.Error("2^0 != 1")
	}
}

func TestNegativePow(t *testing.T) {
	// 2^-1 = 1/2
	n := FromInt(2).Pow(FromInt(-1))
	if !n.IsRat {
		t.Error("2^-1 should be rational")
	}
	half := FromInt(1).Div(FromInt(2))
	if !n.Eq(half) {
		t.Errorf("2^-1 = %s, want 1/2", n.ExactString())
	}
}

func TestComparison(t *testing.T) {
	if !FromInt(5).Gt(FromInt(3)) {
		t.Error("5 > 3")
	}
	if !FromInt(3).Lt(FromInt(5)) {
		t.Error("3 < 5")
	}
	if !FromInt(5).Eq(FromInt(5)) {
		t.Error("5 == 5")
	}
}

func TestRound(t *testing.T) {
	third := FromInt(1).Div(FromInt(3))
	r := Round(third, 2)
	if Format(r, 2) != "0.33" {
		t.Errorf("round(1/3, 2) = %s, want 0.33", Format(r, 2))
	}
}

func TestFloorCeil(t *testing.T) {
	half := FromInt(3).Div(FromInt(2))
	if Floor(half).ToInt() != 1 {
		t.Errorf("floor(3/2) = %d, want 1", Floor(half).ToInt())
	}
	if Ceil(half).ToInt() != 2 {
		t.Errorf("ceil(3/2) = %d, want 2", Ceil(half).ToInt())
	}

	negHalf := FromInt(-3).Div(FromInt(2))
	if Floor(negHalf).ToInt() != -2 {
		t.Errorf("floor(-3/2) = %d, want -2", Floor(negHalf).ToInt())
	}
	if Ceil(negHalf).ToInt() != -1 {
		t.Errorf("ceil(-3/2) = %d, want -1", Ceil(negHalf).ToInt())
	}
}

func TestMod(t *testing.T) {
	if FromInt(10).Mod(FromInt(3)).ToInt() != 1 {
		t.Error("10 % 3 != 1")
	}
	if FromInt(10).Mod(FromInt(0)).ToInt() != 0 {
		t.Error("10 % 0 != 0")
	}
}

func TestFormat(t *testing.T) {
	if Format(FromInt(42), 10) != "42" {
		t.Error("format int")
	}
	third := FromInt(1).Div(FromInt(3))
	s := Format(third, 4)
	if s != "0.3333" {
		t.Errorf("format 1/3 = %s, want 0.3333", s)
	}
}
