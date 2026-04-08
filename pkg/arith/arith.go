// Package arith provides arbitrary-precision arithmetic for shape-lang.
//
// All numbers in the shape system are arbitrary precision. There is no
// float64. A Number is either an exact integer (big.Int) or an exact
// rational (big.Rat = numerator/denominator, both big.Int).
//
// This mirrors the hardware math: integers are byte buffers of arbitrary
// width, floats are mantissa + exponent (which is a rational). The Go
// shim uses the same math the shapes define and the hardware implements.
//
// Division of integers that doesn't divide evenly produces a rational.
// Rationals propagate: int + rat = rat. This preserves precision.
// Display rounds to a configurable number of decimal places.
package arith

import (
	"fmt"
	"math/big"
	"strings"
)

// Number is an arbitrary-precision numeric value.
// It is either an exact integer or an exact rational.
type Number struct {
	IsRat bool
	Int   *big.Int // Used when IsRat is false.
	Rat   *big.Rat // Used when IsRat is true.
}

// --- Constructors ---

// FromInt creates a Number from a Go int.
func FromInt(n int) *Number {
	return &Number{Int: big.NewInt(int64(n))}
}

// FromInt64 creates a Number from an int64.
func FromInt64(n int64) *Number {
	return &Number{Int: big.NewInt(n)}
}

// FromFloat creates a Number from a float64.
// Converts to exact rational representation.
func FromFloat(f float64) *Number {
	r := new(big.Rat).SetFloat64(f)
	if r == nil {
		// Inf/NaN: fall back to zero.
		return &Number{Int: big.NewInt(0)}
	}
	// If denominator is 1, store as integer.
	if r.IsInt() {
		return &Number{Int: new(big.Int).Set(r.Num())}
	}
	return &Number{IsRat: true, Rat: r}
}

// FromString parses a number from a string.
func FromString(s string) *Number {
	s = strings.TrimSpace(s)
	if s == "" {
		return FromInt(0)
	}

	// Try integer first.
	if i, ok := new(big.Int).SetString(s, 0); ok {
		return &Number{Int: i}
	}

	// Try rational (e.g. "3/4").
	if r, ok := new(big.Rat).SetString(s); ok {
		if r.IsInt() {
			return &Number{Int: new(big.Int).Set(r.Num())}
		}
		return &Number{IsRat: true, Rat: r}
	}

	// Try float notation.
	if r := new(big.Rat); true {
		if _, ok := r.SetString(s); ok {
			if r.IsInt() {
				return &Number{Int: new(big.Int).Set(r.Num())}
			}
			return &Number{IsRat: true, Rat: r}
		}
	}

	return FromInt(0)
}

// --- Accessors ---

// ToInt returns the number as a Go int (truncated for rationals).
func (n *Number) ToInt() int {
	if n.IsRat {
		// Truncate: integer part of rational.
		q := new(big.Int).Quo(n.Rat.Num(), n.Rat.Denom())
		return int(q.Int64())
	}
	return int(n.Int.Int64())
}

// ToFloat64 returns the number as a float64 (lossy for large values).
func (n *Number) ToFloat64() float64 {
	if n.IsRat {
		f, _ := n.Rat.Float64()
		return f
	}
	return float64(n.Int.Int64())
}

// IsZero returns true if the number is zero.
func (n *Number) IsZero() bool {
	if n.IsRat {
		return n.Rat.Sign() == 0
	}
	return n.Int.Sign() == 0
}

// Sign returns -1, 0, or 1.
func (n *Number) Sign() int {
	if n.IsRat {
		return n.Rat.Sign()
	}
	return n.Int.Sign()
}

// IsInt returns true if this is an exact integer.
func (n *Number) IsInt() bool {
	return !n.IsRat
}

// String returns the decimal representation.
func (n *Number) String() string {
	if n.IsRat {
		return n.Rat.FloatString(10)
	}
	return n.Int.String()
}

// ExactString returns the exact representation (fraction for rationals).
func (n *Number) ExactString() string {
	if n.IsRat {
		return n.Rat.RatString()
	}
	return n.Int.String()
}

// --- Arithmetic ---

func (n *Number) rat() *big.Rat {
	if n.IsRat {
		return new(big.Rat).Set(n.Rat)
	}
	return new(big.Rat).SetInt(n.Int)
}

func resultRat(r *big.Rat) *Number {
	if r.IsInt() {
		return &Number{Int: new(big.Int).Set(r.Num())}
	}
	return &Number{IsRat: true, Rat: r}
}

// Add returns n + m.
func (n *Number) Add(m *Number) *Number {
	if !n.IsRat && !m.IsRat {
		return &Number{Int: new(big.Int).Add(n.Int, m.Int)}
	}
	return resultRat(new(big.Rat).Add(n.rat(), m.rat()))
}

// Sub returns n - m.
func (n *Number) Sub(m *Number) *Number {
	if !n.IsRat && !m.IsRat {
		return &Number{Int: new(big.Int).Sub(n.Int, m.Int)}
	}
	return resultRat(new(big.Rat).Sub(n.rat(), m.rat()))
}

// Mul returns n * m.
func (n *Number) Mul(m *Number) *Number {
	if !n.IsRat && !m.IsRat {
		return &Number{Int: new(big.Int).Mul(n.Int, m.Int)}
	}
	return resultRat(new(big.Rat).Mul(n.rat(), m.rat()))
}

// Div returns n / m. Integer division that doesn't divide evenly produces a rational.
func (n *Number) Div(m *Number) *Number {
	if m.IsZero() {
		return FromInt(0)
	}
	if !n.IsRat && !m.IsRat {
		// Check if it divides evenly.
		q, rem := new(big.Int).QuoRem(n.Int, m.Int, new(big.Int))
		if rem.Sign() == 0 {
			return &Number{Int: q}
		}
		// Doesn't divide evenly: produce rational.
		return resultRat(new(big.Rat).Quo(n.rat(), m.rat()))
	}
	return resultRat(new(big.Rat).Quo(n.rat(), m.rat()))
}

// IntDiv returns integer division (truncated toward zero).
func (n *Number) IntDiv(m *Number) *Number {
	if m.IsZero() {
		return FromInt(0)
	}
	if !n.IsRat && !m.IsRat {
		return &Number{Int: new(big.Int).Quo(n.Int, m.Int)}
	}
	// Convert to ints and divide.
	ni := new(big.Int).Quo(n.rat().Num(), n.rat().Denom())
	mi := new(big.Int).Quo(m.rat().Num(), m.rat().Denom())
	if mi.Sign() == 0 {
		return FromInt(0)
	}
	return &Number{Int: new(big.Int).Quo(ni, mi)}
}

// Mod returns n % m.
func (n *Number) Mod(m *Number) *Number {
	if m.IsZero() {
		return FromInt(0)
	}
	if !n.IsRat && !m.IsRat {
		return &Number{Int: new(big.Int).Rem(n.Int, m.Int)}
	}
	ni := new(big.Int).Quo(n.rat().Num(), n.rat().Denom())
	mi := new(big.Int).Quo(m.rat().Num(), m.rat().Denom())
	if mi.Sign() == 0 {
		return FromInt(0)
	}
	return &Number{Int: new(big.Int).Rem(ni, mi)}
}

// Abs returns |n|.
func (n *Number) Abs() *Number {
	if n.IsRat {
		return resultRat(new(big.Rat).Abs(n.Rat))
	}
	return &Number{Int: new(big.Int).Abs(n.Int)}
}

// Neg returns -n.
func (n *Number) Neg() *Number {
	if n.IsRat {
		return resultRat(new(big.Rat).Neg(n.Rat))
	}
	return &Number{Int: new(big.Int).Neg(n.Int)}
}

// Pow returns n^exp (integer exponent only).
func (n *Number) Pow(exp *Number) *Number {
	e := exp.ToInt()
	if e < 0 {
		// Negative exponent: 1/n^|e|
		base := n.Pow(FromInt(-e))
		return FromInt(1).Div(base)
	}
	if !n.IsRat {
		return &Number{Int: new(big.Int).Exp(n.Int, big.NewInt(int64(e)), nil)}
	}
	// Rational base: raise num and denom separately.
	num := new(big.Int).Exp(n.Rat.Num(), big.NewInt(int64(e)), nil)
	den := new(big.Int).Exp(n.Rat.Denom(), big.NewInt(int64(e)), nil)
	return resultRat(new(big.Rat).SetFrac(num, den))
}

// --- Comparison ---

// Cmp returns -1, 0, or 1.
func (n *Number) Cmp(m *Number) int {
	if !n.IsRat && !m.IsRat {
		return n.Int.Cmp(m.Int)
	}
	return n.rat().Cmp(m.rat())
}

// Eq returns true if n == m.
func (n *Number) Eq(m *Number) bool { return n.Cmp(m) == 0 }

// Lt returns true if n < m.
func (n *Number) Lt(m *Number) bool { return n.Cmp(m) < 0 }

// Gt returns true if n > m.
func (n *Number) Gt(m *Number) bool { return n.Cmp(m) > 0 }

// --- Rounding (returns integer) ---

// Round rounds to the nearest integer (or to n decimal places).
func Round(n *Number, places int) *Number {
	if !n.IsRat && places == 0 {
		return &Number{Int: new(big.Int).Set(n.Int)}
	}
	// Multiply by 10^places, round, divide back.
	scale := new(big.Int).Exp(big.NewInt(10), big.NewInt(int64(places)), nil)
	scaled := new(big.Rat).Mul(n.rat(), new(big.Rat).SetInt(scale))
	// Round: add 0.5 (or -0.5) then truncate.
	half := new(big.Rat).SetFrac(big.NewInt(1), big.NewInt(2))
	if scaled.Sign() < 0 {
		half.Neg(half)
	}
	scaled.Add(scaled, half)
	truncated := new(big.Int).Quo(scaled.Num(), scaled.Denom())
	result := new(big.Rat).SetFrac(truncated, scale)
	return resultRat(result)
}

// Floor returns the largest integer <= n.
func Floor(n *Number) *Number {
	if !n.IsRat {
		return &Number{Int: new(big.Int).Set(n.Int)}
	}
	q := new(big.Int).Quo(n.Rat.Num(), n.Rat.Denom())
	// If negative and not exact, subtract 1.
	if n.Rat.Sign() < 0 {
		rem := new(big.Int).Rem(n.Rat.Num(), n.Rat.Denom())
		if rem.Sign() != 0 {
			q.Sub(q, big.NewInt(1))
		}
	}
	return &Number{Int: q}
}

// Ceil returns the smallest integer >= n.
func Ceil(n *Number) *Number {
	if !n.IsRat {
		return &Number{Int: new(big.Int).Set(n.Int)}
	}
	q := new(big.Int).Quo(n.Rat.Num(), n.Rat.Denom())
	// If positive and not exact, add 1.
	if n.Rat.Sign() > 0 {
		rem := new(big.Int).Rem(n.Rat.Num(), n.Rat.Denom())
		if rem.Sign() != 0 {
			q.Add(q, big.NewInt(1))
		}
	}
	return &Number{Int: q}
}

// --- Display ---

// Format returns a display string with up to maxDecimals places.
func Format(n *Number, maxDecimals int) string {
	if !n.IsRat {
		return n.Int.String()
	}
	s := n.Rat.FloatString(maxDecimals)
	// Trim trailing zeros after decimal point.
	if strings.Contains(s, ".") {
		s = strings.TrimRight(s, "0")
		s = strings.TrimRight(s, ".")
	}
	return s
}

// FormatFixed returns exactly `places` decimal digits.
func FormatFixed(n *Number, places int) string {
	if !n.IsRat {
		if places == 0 {
			return n.Int.String()
		}
		return fmt.Sprintf("%s.%s", n.Int.String(), strings.Repeat("0", places))
	}
	return n.Rat.FloatString(places)
}
