shape theory.computing.stack.isa.fpga : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// FPGA as composable substrate.
//
// An FPGA is a substrate that becomes any other substrate.
// It is the hardware implementation of stack composition:
// load a bitstream and the FPGA IS that architecture.
//
//   addr_bits: defined by bitstream
//   data_bits: defined by bitstream
//   endian: defined by bitstream
//   clock_hz: 100M-500M (fabric dependent)
//   regs: defined by bitstream (LUT-based flip-flops)
//   vectors: defined by bitstream
//
// An FPGA loaded with a 6502 bitstream IS a 6502.
// An FPGA loaded with a RISC-V bitstream IS a RISC-V.
// An FPGA loaded with the shape-gate bitstream IS a shape machine.
//
// The shape-gate projection:
//   Each shape -> one LUT (content) + one flip-flop (state)
//   Connections -> routing fabric
//   Wave propagation -> electrical signal propagation
//   The OS IS the hardware configuration.
//
// FPGA in the composition stack:
//   compose(physics, fpga(mos6502), c64-kernal)
//     A real 6502 on an FPGA running the C64 KERNAL.
//     No emulation overhead. Cycle-accurate at gate speed.
//
//   compose(physics, fpga(shape-gate), shape-os)
//     Shape OS running on shape gates on an FPGA.
//     The emulation layer disappears entirely.
//     The OS IS the bitstream.
//
//   compose(physics, fpga(riscv), linux)
//     Linux on a RISC-V soft core on an FPGA.
//
// The FPGA is the universal substrate: it can become any
// architecture, and the resulting architecture runs at
// hardware speed, not emulation speed. The FPGA substrate
// eliminates the emulation overhead for any single target ISA.
//
// Derives from: theory.computing.stack.substrate
  """
}
