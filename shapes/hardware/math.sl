// Integer arithmetic as shape subgraphs.
//
// All math derives from add and shift. Multiply is repeated add.
// Divide is repeated subtract. These ARE the gate subgraphs.
// No FPU needed. The math IS the lattice.

shape hardware.math : hardware {
  type: axiom
  layer: 0
  "Arithmetic from persistence. Add is the minimal change operation: two shapes combine to produce a third that persists."
}

shape hardware.math.add : hardware.math {
  type: gate
  layer: 1
  width: 8
  """
// Ripple-carry adder: N shape-gates in series.
// Gate i: full_adder(a[i], b[i], carry_in) -> (sum[i], carry_out)
// carry_out of gate i connects to carry_in of gate i+1.
// Total gates: N (one per bit).
// Propagation delay: N gate delays (carry chain).
//
// For width W: W gates, W cycles to complete.
fn add(a, b) {
  let carry = 0
  let result = bytes(len(a))
  for i in range(len(a)) {
    let s = byte_get(a, i) + byte_get(b, i) + carry
    set result = byte_set(result, i, bit_and(s, 0xFF))
    set carry = bit_shr(s, 8)
  }
  result
}
"""
}

shape hardware.math.sub : hardware.math {
  type: gate
  layer: 1
  deps: [hardware.math.add]
  """
// Subtraction: add with two's complement.
// Negate b (invert + add 1), then add.
// Gates: N (invert) + N (add) + N (add with a) = 3N.
fn sub(a, b) {
  let neg_b = bytes(len(b))
  let carry = 1
  for i in range(len(b)) {
    let inv = bit_xor(byte_get(b, i), 0xFF)
    let s = inv + carry
    set neg_b = byte_set(neg_b, i, bit_and(s, 0xFF))
    set carry = bit_shr(s, 8)
  }
  add(a, neg_b)
}
"""
}

shape hardware.math.shift : hardware.math {
  type: gate
  layer: 1
  """
// Barrel shifter: log2(N) layers of muxes.
// Each layer shifts by 2^k if the k-th bit of the shift amount is set.
// Gates: N * log2(N) (mux per bit per layer).
fn shl(a, n) {
  let result = a
  let shift = n
  let bit = 1
  while bit <= shift {
    if bit_and(shift, bit) != 0 {
      set result = bytes_concat(bytes(bit), bytes_slice(result, 0, len(result) - bit))
    }
    set bit = bit * 2
  }
  result
}
"""
}

shape hardware.math.mul : hardware.math {
  type: gate
  layer: 2
  deps: [hardware.math.add, hardware.math.shift]
  """
// Multiply: shift-and-add.
// For each bit of b that is set, shift a left by that bit position
// and add to accumulator.
// Gates: N * (N shift + N add) = O(N^2).
// On the lattice: N parallel shift subgraphs feeding N adders.
fn mul(a, b) {
  let acc = bytes(len(a) + len(b))
  for i in range(len(b) * 8) {
    if bit_and(byte_get(b, i / 8), bit_shl(1, mod(i, 8))) != 0 {
      let shifted = shl(a, i)
      set acc = add(acc, shifted)
    }
  }
  acc
}
"""
}

shape hardware.math.div : hardware.math {
  type: gate
  layer: 2
  deps: [hardware.math.sub, hardware.math.shift]
  """
// Division: long division via repeated subtraction with shifting.
// For each bit position from high to low:
//   if remainder >= (divisor << bit), subtract and set quotient bit.
// Gates: O(N^2) (N iterations, each with compare + subtract).
fn div(a, b) {
  let quotient = bytes(len(a))
  let remainder = a
  for i in range(len(a) * 8 - 1, -1) {
    let shifted = shl(b, i)
    // Compare: try subtract, check if result is non-negative.
    let diff = sub(remainder, shifted)
    if byte_get(diff, len(diff) - 1) < 128 {
      // Non-negative: divisor fits.
      set remainder = diff
      let byte_idx = i / 8
      let bit_idx = mod(i, 8)
      set quotient = byte_set(quotient, byte_idx,
        bit_or(byte_get(quotient, byte_idx), bit_shl(1, bit_idx)))
    }
  }
  quotient
}
"""
}

shape hardware.math.compare : hardware.math {
  type: gate
  layer: 1
  deps: [hardware.math.sub]
  """
// Compare: subtract and check sign bit.
// a < b  iff  (a - b) has sign bit set.
// a == b iff  (a - b) == 0.
// Gates: N (subtract) + N (zero check) = 2N.
fn compare(a, b) {
  let diff = sub(a, b)
  let sign = bit_and(byte_get(diff, len(diff) - 1), 128)
  let zero = 1
  for i in range(len(diff)) {
    if byte_get(diff, i) != 0 {
      set zero = 0
    }
  }
  // Returns: -1 if a < b, 0 if a == b, 1 if a > b.
  if zero == 1 { 0 }
  else if sign != 0 { -1 }
  else { 1 }
}
"""
}
