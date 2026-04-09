shape theory.computing.ucisc.effects : theory.computing.ucisc {
  type: structure
  layer: 0
  """
// uCISC Effect Codes (3-bit, 8 conditions).
//
// Effects control whether the instruction's result is stored.
// The ALU always computes. The effect determines whether the
// result persists. This IS Law 0: the result persists only if
// the coherence condition is met.
//
// Every instruction is conditional. There is no separate
// "branch" instruction. A branch is a copy to PC with an
// effect condition. An unconditional move is effect=4 (always).
// Conditional execution is the default, not a special case.
//
//   0 (zero):     Store if zero flag set.
//   1 (nonzero):  Store if zero flag clear.
//   2 (negative): Store if negative flag set.
//   3 (positive): Store if negative flag clear.
//   4 (always):   Store unconditionally.
//   5 (overflow): Store if overflow flag set.
//   6 (interrupt): Store if interrupt flag set.
//   7 (flags):    Don't store. Just set flags.
//
// Effect 7 is the "test" operation: compute the ALU result,
// set flags, but discard the result. Used for comparisons.
//
// Branching example:
//   sub &r1, val/0, flags  // compare r1 to 0 (set flags)
//   copy val/target, pc, zero  // jump if r1 was zero
//   copy val/other, pc, negative  // jump if r1 was negative
//
// The copy instructions don't change flags (only non-copy ops
// set flags), so both conditionals test the same sub result.
//
// Derives from: theory.computing.ucisc
  """
}
