shape theory.computing.arithmetic : theory.computing.gates {
  type: structure
  layer: 0
  """
// Layer 3: Arithmetic and Combinational Circuits.
//
// Half adder: XOR + AND. Adds two 1-bit inputs.
//   Sum = A XOR B. Carry = A AND B.
//
// Full adder: two half adders + OR. Adds three 1-bit inputs
//   (A, B, carry-in). Sum and carry-out.
//   The building block of multi-bit addition.
//
// Ripple carry adder: N full adders chained.
//   Carry ripples from LSB to MSB. Simple but slow:
//   delay = O(N) gate delays. For 64-bit: 64 carry propagations.
//
// Carry lookahead adder: compute carries in parallel.
//   Generate: G_i = A_i AND B_i (this bit produces a carry).
//   Propagate: P_i = A_i XOR B_i (this bit propagates a carry).
//   C_i = G_i OR (P_i AND C_{i-1}).
//   Expand recursively: O(log N) delay. For 64-bit: ~6 levels.
//
// Subtractor: adder + complement. A - B = A + (~B) + 1.
//   Two's complement: invert B, set carry-in = 1.
//
// Multiplier: array of AND gates + adder tree.
//   Partial products: A_i AND B_j for each bit pair.
//   Sum partial products with carry-save adders.
//   Wallace tree: O(log N) depth adder tree.
//   Final carry-propagate add for the result.
//   64x64 -> 128-bit result.
//
// Divider: iterative subtract-and-shift or SRT algorithm.
//   Slower than multiplication. Typically multi-cycle.
//
// Comparator: subtract and check sign bit + zero flag.
//   A < B: sign bit = 1. A = B: zero flag = 1. A > B: both 0.
//
// Multiplexer (MUX): select one of N inputs.
//   2:1 MUX: (A AND ~sel) OR (B AND sel).
//   N:1 MUX: tree of 2:1 MUX. Selects with log2(N) control bits.
//   The hardware if-then-else.
//
// Decoder: N-bit input -> 2^N one-hot output.
//   Exactly one output line active for each input value.
//   Used for memory addressing and instruction decoding.
//
// Barrel shifter: shift input by any amount in one cycle.
//   log2(N) layers of MUX. Each layer shifts by 2^k or not.
//   For 64-bit: 6 layers, each a 64-wide MUX.
//
// ALU (Arithmetic Logic Unit): the computational core.
//   Inputs: two 64-bit operands + operation select.
//   Operations: ADD, SUB, AND, OR, XOR, NOT, SLT, shift.
//   Output: 64-bit result + flags (zero, negative, carry, overflow).
//   The ALU is a MUX selecting among operation results.
//   Each operation is computed in parallel; the MUX picks one.
//
// Derives from: theory.computing.gates
  """
}
