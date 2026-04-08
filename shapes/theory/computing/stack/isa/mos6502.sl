shape theory.computing.stack.isa.mos6502 : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// MOS 6502 as composable substrate.
//
//   addr_bits: 16
//   data_bits: 8
//   endian: little
//   clock_hz: 1022727 (NTSC) / 985248 (PAL)
//   regs: {A: 8, X: 8, Y: 8, SP: 8, P: 8, PC: 16}
//   vectors: {reset: $FFFC, nmi: $FFFA, irq: $FFFE}
//
// step(): decode opcode at mem[PC], execute, return 2-7 cycles.
// Cycle-accurate: page-cross penalties, bad-line stealing.
//
// Variants:
//   6502:  Original (Apple II, Atari)
//   6510:  + I/O port at $0000/$0001 (C64)
//   65C02: + BRA, PHX/PLX, STZ, etc. (Apple IIc)
//   2A03:  + audio, - decimal mode (NES)
//
// The 6502 runs inside any substrate that provides 64KB of
// addressable memory. Compose it with:
//   compose(physics, arm64, mos6502-emu)  - emulated on ARM64
//   compose(physics, fpga, mos6502-gate)  - synthesized to gates
//   compose(physics, riscv, mos6502-emu)  - emulated on RISC-V
//
// Assembly shim: shim/shape_mos6502.s (ARM64 host)
//
// Derives from: theory.computing.stack.substrate
  """
}
