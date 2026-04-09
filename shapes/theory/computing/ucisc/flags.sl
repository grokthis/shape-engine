shape theory.computing.ucisc.flags : theory.computing.ucisc {
  type: structure
  layer: 0
  """
// uCISC Flags Register (16 bits).
//
//   HRB0 000S 000I OCNZ
//
// Control flags (read/write):
//   H (bit 15): Halt. Stops all execution.
//   R (bit 14): Resume. Processor halts, waits for interrupt,
//               then resumes. Used for power-efficient waiting.
//   B (bit 13): Blocked memory writable. When set, the
//               processor can write to blocked memory regions.
//   S (bit 9):  Signed mode. Controls whether ALU operations
//               treat operands as signed (1) or unsigned (0).
//               Affects: shr (sign extension), add, sub, mult.
//
// Status flags (set by ALU, read-only):
//   I (bit 8):  Interrupt. Set when interrupt condition occurs.
//   O (bit 3):  Overflow. Set when arithmetic overflows.
//   C (bit 2):  Carry. Set when arithmetic produces carry.
//   N (bit 1):  Negative. Set when result is negative.
//   Z (bit 0):  Zero. Set when result is zero.
//
// Only non-copy ALU operations set status flags. Copy operations
// leave flags unchanged. This separation is critical: it allows
// testing a condition and then conditionally copying based on
// the same flags without the copy disturbing them.
//
// The signed mode flag (S) is unique to uCISC: it controls ALU
// behavior at the instruction level, not the data level. The
// same data can be treated as signed or unsigned by changing
// one flag. No separate signed/unsigned instruction variants.
//
// Derives from: theory.computing.ucisc
  """
}
