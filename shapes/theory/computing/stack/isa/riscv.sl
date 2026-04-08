shape theory.computing.stack.isa.riscv : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// RISC-V as composable substrate.
//
// Base:
//   RV32I:  addr_bits: 32, data_bits: 32
//   RV64I:  addr_bits: 64, data_bits: 64
//   endian: little
//   regs: {x0(zero)-x31: 32/64, pc: 32/64}
//   vectors: {reset: implementation defined, mtvec for traps}
//
// Extensions (composable, each adds capability):
//   M: multiply/divide (MUL, DIV, REM)
//   A: atomics (LR/SC, AMO)
//   F: single-precision float (f0-f31: 32-bit)
//   D: double-precision float (f0-f31: 64-bit)
//   C: compressed instructions (16-bit encoding)
//   V: vector (scalable SIMD, VLEN hardware-defined)
//   B: bit manipulation
//   Zicsr: CSR access
//   Zifencei: instruction fence
//
// Standard profiles:
//   RV32G = RV32IMAFD (general purpose 32-bit)
//   RV64G = RV64IMAFD (general purpose 64-bit)
//   RV64GC = RV64G + C (compressed, most common Linux target)
//   RV64GCV = RV64GC + V (with vectors)
//
// RISC-V is itself composable: extensions are structural
// additions to the ISA. Each extension adds instructions
// without changing existing ones. This is emergence:
// M extends I, A extends IM, V extends IMA.
//
// Assembly shims:
//   shim/shape_riscv32i.s   (base 32-bit, shift-and-add multiply)
//   shim/shape_riscv64i.s   (base 64-bit)
//   shim/shape_riscv_m.s    (with hardware multiply)
//   shim/shape_riscv_a.s    (with atomics)
//   shim/shape_riscv_v.s    (with vectors)
//
// Derives from: theory.computing.stack.substrate
  """
}
