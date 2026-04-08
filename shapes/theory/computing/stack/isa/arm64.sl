shape theory.computing.stack.isa.arm64 : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// ARM64 (AArch64) as composable substrate.
//
//   addr_bits: 48 (virtual), 52 (physical)
//   data_bits: 64
//   endian: little (configurable)
//   clock_hz: 600M-3500M (varies by implementation)
//   regs: {x0-x30: 64, sp: 64, pc: 64, pstate: 32,
//          v0-v31: 128 (NEON/FP)}
//   vectors: {reset: implementation defined, VBAR_EL1 + offset}
//
// Implementations:
//   Cortex-A53/55: in-order, low power (Raspberry Pi, phones)
//   Cortex-A72/76/78: out-of-order (servers, flagship phones)
//   Apple M1/M2/M3/M4: wide out-of-order, 8-wide decode
//   Graviton: AWS server chips
//   Neoverse: ARM server cores
//
// Assembly shim: shim/shape_arm64.s (native on Apple Silicon)
//
// Derives from: theory.computing.stack.substrate
  """
}
