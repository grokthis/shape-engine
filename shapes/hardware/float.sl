// Arbitrary-precision floating point as shapes.
//
// A float is three shapes connected:
//   sign:     1 bit (0 = positive, 1 = negative)
//   mantissa: N-byte integer (arbitrary precision)
//   exponent: M-byte signed integer (arbitrary range)
//
// value = (-1)^sign * mantissa * 2^exponent
//
// No IEEE 754. No fixed width. Precision is a parameter of the shape.
// The operations are structural: subgraphs of integer operations
// with exponent alignment.

shape hardware.float : hardware.math {
  type: structure
  layer: 3
  deps: [hardware.math.add, hardware.math.sub, hardware.math.mul, hardware.math.div, hardware.math.shift, hardware.math.compare]
  """
// Float representation:
//   bytes 0..N-1:   mantissa (big integer, unsigned)
//   bytes N..N+M-1: exponent (signed integer)
//   byte  N+M:      sign (0 or 1)
//   byte  N+M+1:    mantissa width N
//   byte  N+M+2:    exponent width M
//
// Default: N=4, M=2 (32-bit mantissa, 16-bit exponent range).
// Can grow to any size.

fn float_new(mantissa_width, exponent_width) {
  let total = mantissa_width + exponent_width + 3
  let buf = bytes(total)
  set buf = byte_set(buf, mantissa_width + exponent_width + 1, mantissa_width)
  set buf = byte_set(buf, mantissa_width + exponent_width + 2, exponent_width)
  buf
}

fn float_from_int(n, precision) {
  let f = float_new(precision, 2)
  // Store integer as mantissa with exponent 0.
  let mw = precision
  for i in range(mw) {
    set f = byte_set(f, i, bit_and(bit_shr(n, i * 8), 0xFF))
  }
  // Sign.
  if n < 0 {
    set f = byte_set(f, mw + 2, 1)
    // Negate mantissa.
    let carry = 1
    for i in range(mw) {
      let v = bit_xor(byte_get(f, i), 0xFF) + carry
      set f = byte_set(f, i, bit_and(v, 0xFF))
      set carry = bit_shr(v, 8)
    }
  }
  f
}
"""
}

shape hardware.float.add : hardware.float {
  type: gate
  layer: 3
  """
// Float addition: align exponents, then add mantissas.
//
// 1. Compare exponents. Shift the smaller-exponent mantissa right
//    by the difference.
// 2. Add mantissas (handling signs).
// 3. Normalize: shift mantissa until leading bit is set, adjust exponent.
//
// Gates: exponent compare (2M) + mantissa shift (N*log2(N)) +
//        mantissa add (N) + normalize (N*log2(N)) = O(N*log2(N)).
fn float_add(a, b) {
  let mw_a = byte_get(a, len(a) - 2)
  let mw_b = byte_get(b, len(b) - 2)
  let ew_a = byte_get(a, len(a) - 1)

  // Extract exponents.
  let exp_a = 0
  for i in range(ew_a) {
    set exp_a = exp_a + bit_shl(byte_get(a, mw_a + i), i * 8)
  }
  let exp_b = 0
  for i in range(ew_a) {
    set exp_b = exp_b + bit_shl(byte_get(b, mw_b + i), i * 8)
  }

  // Align: shift mantissa of smaller exponent right.
  let shift = abs(exp_a - exp_b)
  // After alignment, add mantissas using integer add.
  // Result exponent = max(exp_a, exp_b).
  // Sign handling: if signs differ, subtract instead.
  let sign_a = byte_get(a, mw_a + ew_a)
  let sign_b = byte_get(b, mw_b + ew_a)

  if sign_a == sign_b {
    // Same sign: add mantissas, keep sign.
    auto "add mantissas"
  } else {
    // Different sign: subtract smaller from larger, keep larger's sign.
    auto "subtract mantissas"
  }
}
"""
}

shape hardware.float.mul : hardware.float {
  type: gate
  layer: 3
  """
// Float multiplication: multiply mantissas, add exponents.
//
// result.mantissa = a.mantissa * b.mantissa
// result.exponent = a.exponent + b.exponent
// result.sign = a.sign XOR b.sign
//
// Gates: mantissa mul (N^2) + exponent add (M) + sign XOR (1).
// This is why multiplication is more expensive than addition.
fn float_mul(a, b) {
  // Sign: XOR.
  let mw = byte_get(a, len(a) - 2)
  let ew = byte_get(a, len(a) - 1)
  let sign = bit_xor(byte_get(a, mw + ew), byte_get(b, mw + ew))

  // Exponent: add.
  // Mantissa: integer multiply (shift-and-add subgraph).
  // Normalize result.
  auto "mul"
}
"""
}

shape hardware.float.div : hardware.float {
  type: gate
  layer: 3
  """
// Float division: divide mantissas, subtract exponents.
//
// result.mantissa = a.mantissa / b.mantissa
// result.exponent = a.exponent - b.exponent
// result.sign = a.sign XOR b.sign
//
// Gates: mantissa div (N^2) + exponent sub (M) + sign XOR (1).
fn float_div(a, b) {
  auto "div"
}
"""
}
