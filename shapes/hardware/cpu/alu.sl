// ALU: the arithmetic/logic unit as shapes.
//
// Each operation is a shape. The ALU is a shape that selects
// which operation to propagate based on the opcode.
// On hardware: a mux feeding operation subgraphs.
// In the engine: a switch on the opcode dimension.

shape hardware.cpu.alu : hardware.cpu {
  type: unit
  layer: 1
  """
// Execute an ALU operation.
// Inputs: op (string), a (int), b (int)
// Output: result (int), flags (zero, negative, carry, overflow)
//
// Operations:
//   add, sub, mul, div, mod    - arithmetic
//   and, or, xor, not, shl, shr - bitwise
//   eq, lt, gt, lte, gte       - comparison
//   abs, neg                   - unary

let result = 0
let zero = false
let negative = false

if op == "add" {
  set result = a + b
} else if op == "sub" {
  set result = a - b
} else if op == "mul" {
  set result = a * b
} else if op == "div" {
  if b != 0 { set result = a / b }
} else if op == "mod" {
  if b != 0 { set result = a % b }
} else if op == "and" {
  set result = bit_and(a, b)
} else if op == "or" {
  set result = bit_or(a, b)
} else if op == "xor" {
  set result = bit_xor(a, b)
} else if op == "not" {
  set result = bit_not(a)
} else if op == "shl" {
  set result = bit_shl(a, b)
} else if op == "shr" {
  set result = bit_shr(a, b)
} else if op == "eq" {
  set result = if_val(a == b, 1, 0)
} else if op == "lt" {
  set result = if_val(a < b, 1, 0)
} else if op == "gt" {
  set result = if_val(a > b, 1, 0)
} else if op == "lte" {
  set result = if_val(a <= b, 1, 0)
} else if op == "gte" {
  set result = if_val(a >= b, 1, 0)
} else if op == "abs" {
  set result = abs(a)
} else if op == "neg" {
  set result = 0 - a
}

set zero = result == 0
set negative = result < 0
"""
}
