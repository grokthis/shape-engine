shape theory.computing.ucisc.instruction : theory.computing.ucisc {
  type: structure
  layer: 0
  """
// uCISC Instruction Format (32 bits).
//
// Every instruction is one 32-bit word. No variable length.
// No multi-word instructions. No prefixes.
//
// Non-memory destination:
//   SSSS DDDD  M EEE AAAA  IIIIIIII IIIIIIII
//   [src] [dst] [inc] [eff] [alu]   [16-bit immediate]
//
// Memory destination:
//   SSSS DDDD  M EEE AAAA  OOOO IIII IIIIIIII
//   [src] [dst] [inc] [eff] [alu] [4-bit offset] [12-bit imm]
//
// Fields:
//   S (4): source register/mode
//   D (4): destination register/mode
//   M (1): increment mode (0=none, 1=push/pop)
//   E (3): effect (conditional execution)
//   A (4): ALU operation
//   I (16 or 12): immediate value
//   O (4): memory offset (memory destinations only)
//
// The instruction format IS the shape decomposition:
//   Source = what enters the transformation (C)
//   Destination = where the result goes (M')
//   ALU operation = the transformation function (f)
//   Effect = coherence condition (Law 0: does this persist?)
//   Increment = structural side effect (stack manipulation)
//   Immediate = character constant
//
// Derives from: theory.computing.ucisc
  """
}
