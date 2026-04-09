shape theory.computing.ucisc.memory : theory.computing.ucisc {
  type: structure
  layer: 0
  """
// uCISC Memory Model.
//
// 64K word address space (0x0000 - 0xFFFF).
// Each address is a 16-bit word (not byte). Total: 128KB.
//
// Two address spaces, switchable per register via banking:
//   Local memory: directly attached to processor. Fast.
//     Instructions always load from local memory.
//     r1, r2, r3 always address local memory.
//   Device memory: memory-mapped I/O and device block memory.
//     r5, r6, r7 address device memory when banked.
//
// Banking register (4.reg):
//   Bit 1: r1 banked (1=device, 0=local)
//   Bit 2: r2 banked
//   Bit 3: r3 banked
//   Bit 5: r5 banked
//   Bit 6: r6 banked
//   Bit 7: r7 banked
//
// Device memory map:
//   0x0000-0x0FFF: Device control space.
//     256 devices x 16 words each.
//     Device N control at (N * 0x10).
//     Offset 0: device ID (read-only).
//     Offset 1: flags (MSB) | type (LSB, read-only).
//     Offsets 2-15: device-specific registers.
//
//   0x1000-0xFFFF: Device block memory.
//     Devices 16-255 get 256 words each.
//     Device N block at (N * 0x100).
//
// Stack: uses any register as stack pointer.
//   Push: decrement register, then store (increment mode M=1).
//   Pop: load, then increment register (increment mode M=1).
//   Convention: r1 is stack pointer, grows downward from 0x0000
//   (wraps to 0xFFFF on first push).
//
// The memory model is two flat spaces with register-controlled
// switching. No MMU. No page tables. No protection rings.
// The programmer sees exactly what the hardware sees.
//
// Derives from: theory.computing.ucisc
  """
}
