shape theory.computing.ucisc : theory.computing {
  type: system
  layer: 0
  """
// uCISC: A People-First Computer.
//
// 16-bit word-addressed architecture. One instruction format.
// 6 general registers + 4 special registers. 64K word address space.
// Memory-mapped device I/O. Banking for dual address spaces.
//
// Design philosophy: a single person can understand the entire
// thing. Fully transparent. Connected to the hardware.
// No hidden state. No microcode. No pipeline hazards.
// The programmer sees exactly what the machine does.
//
// This IS a shape architecture: every instruction is a
// transformation M' = f(C, S) where C is the register/memory
// state and S is the instruction encoding. The instruction
// format encodes source, destination, operation, condition,
// and increment in a single 32-bit word. No multi-cycle
// decode. No implicit state changes. What you write is what
// the machine does.
//
// Derives from: theory.computing
  """
}
