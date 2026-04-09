shape theory.computing.stack.isa.ucisc : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// uCISC as composable substrate.
//
//   addr_bits: 16 (word-addressed, 64K words = 128KB)
//   data_bits: 16
//   endian: big (word-oriented, no byte order issue)
//   clock_hz: implementation-dependent (FPGA: ~50-100 MHz)
//   regs: {r1,r2,r3,r5,r6,r7: 16, pc: 16, flags: 16,
//          banking: 16, interrupt: 16}
//   vectors: {reset: 0x0000, interrupt: via interrupt register}
//
// uCISC in the composition stack:
//   compose(physics, fpga(ucisc), ucisc-os)
//     uCISC on FPGA running its own OS. Native speed.
//
//   compose(physics, arm64, ucisc-emu, ucisc-os)
//     uCISC emulated on ARM64. Fast emulation.
//
//   compose(physics, arm64, go, shape-engine, ucisc-emu, ucisc-os)
//     uCISC emulated on the shape engine. Shape recognition
//     can collapse uCISC loops to formulas.
//
// The uCISC architecture is structurally clean: one instruction
// format, every instruction conditional, no hidden state.
// This makes it an ideal emulation target: the decode is
// trivial (one 32-bit word, fixed format) and the execution
// has no implicit side effects to track.
//
// Full architecture spec: shapes/theory/computing/ucisc/*.sl
// Source repo: github.com/grokthis/ucisc
//
// Derives from: theory.computing.stack.substrate
  """
}
