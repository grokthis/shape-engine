shape theory.computing.ucisc.alu : theory.computing.ucisc {
  type: structure
  layer: 0
  """
// uCISC ALU Operations (4-bit opcode, 16 operations).
//
// Every instruction performs an ALU operation. There is no
// separate "move" vs "compute" distinction. A copy IS an ALU
// operation (opcode 0x0). This is structural: every instruction
// transforms. The transformation may be identity (copy), but
// it is always explicit.
//
// Bit operations (carry=0, overflow=0):
//   0x0 copy:  D = S                  Identity transform.
//   0x1 and:   D = D & S              Bitwise AND.
//   0x2 or:    D = D | S              Bitwise OR.
//   0x3 xor:   D = D ^ S              Bitwise XOR.
//   0x4 inv:   D = ~S                 Bitwise NOT.
//   0x5 shl:   D = D << S             Shift left, zero extend.
//   0x6 shr:   D = D >> S             Shift right, signed-aware.
//
// Byte operations (carry=0, overflow=0):
//   0x7 swap:  D = swap_bytes(S)      Swap MSB and LSB.
//   0x8 msb:   D = S & 0xFF00         Extract high byte.
//   0x9 lsb:   D = S & 0x00FF         Extract low byte.
//
// Arithmetic (carry and overflow set):
//   0xA add:   D = D + S              Add (signed-aware).
//   0xB sub:   D = D - S              Subtract (signed-aware).
//   0xC mult:  D = (D * S) & 0xFFFF   Multiply, low word.
//   0xD multh: D = (D * S) >> 16      Multiply, high word.
//   0xE addc:  D = D + S + carry      Add with carry.
//   0xF (reserved)
//
// Note: for 2-argument ops, destination is first argument.
// sub computes D - S, not S - D. This is consistent:
// the destination shape is transformed by the source shape.
//
// Only non-copy operations set flags. Copy never modifies flags.
// This allows multiple conditional branches on the same result:
// compute once, then copy-with-effect multiple times.
//
// Derives from: theory.computing.ucisc
  """
}
