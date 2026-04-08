shape theory.computing.stack.examples : theory.computing.stack.compose, theory.computing.stack.isa.arm64, theory.computing.stack.isa.riscv, theory.computing.stack.isa.x86, theory.computing.stack.isa.mos6502, theory.computing.stack.isa.shape-engine, theory.computing.stack.isa.fpga, theory.computing.stack.physics {
  type: definition
  layer: 0
  """
// Example Composition Stacks.
//
// Each stack is a complete derivation from the persistence axiom
// to a running system. The notation:
//   axiom -> physics -> [layer1] -> [layer2] -> ... -> [top]
//
// === Current system ===
//
// stack.current = compose(
//   physics,           // Planck lattice -> silicon -> M1 Pro
//   arm64,             // AArch64, 3.2 GHz, 10 cores
//   go-runtime,        // Go 1.22, compiled to ARM64
//   shape-engine,      // 3.7 MIPS, 556 shapes
//   shape-os           // Laws -> hardware -> engine -> os -> user
// )
// Depth: 5 layers. Overhead: ~540x over native.
// But: structural recognition collapses inner loops to O(1).
//
// === C64 on current hardware ===
//
// stack.c64-emulated = compose(
//   physics,
//   arm64,
//   mos6502-emu,       // shim/shape_mos6502.s, cycle-accurate
//   c64-system         // VIC-II + SID + CIA + PLA + 64KB
// )
// Depth: 4. Speed: ~100 MHz effective 6502 clock.
// 100x faster than real C64 hardware.
//
// === C64 on FPGA ===
//
// stack.c64-fpga = compose(
//   physics,
//   fpga(mos6510),     // 6510 synthesized to gates
//   c64-system         // VIC-II + SID + CIA + PLA, all in gates
// )
// Depth: 3. Speed: 1 MHz (cycle-accurate, gate-speed).
// Indistinguishable from original hardware.
//
// === Shape OS on RISC-V ===
//
// stack.shape-riscv = compose(
//   physics,
//   riscv64gc,          // RV64GC, 1 GHz
//   go-runtime,
//   shape-engine,
//   shape-os
// )
// Depth: 5. Same as current but on RISC-V.
//
// === Shape OS on emulated RISC-V on x86 ===
//
// stack.shape-riscv-on-x86 = compose(
//   physics,
//   x86-avx512,         // Sapphire Rapids, 4 GHz
//   riscv-emu,           // RISC-V emulator in C
//   go-runtime,
//   shape-engine,
//   shape-os
// )
// Depth: 6. RISC-V emulated on x86 running Shape OS.
//
// === Recursive shape engine ===
//
// stack.recursive = compose(
//   physics,
//   arm64,
//   go-runtime,
//   shape-engine,       // outer engine
//   shape-engine-emu,   // inner engine (emulated by outer)
//   shape-os            // OS on inner engine
// )
// Depth: 6. Shape OS on shape engine on shape engine.
// The outer engine can recognize patterns in the inner engine
// and collapse them. Two levels of structural recognition.
//
// === Maximum depth (absurd but valid) ===
//
// stack.deep = compose(
//   physics,
//   arm64,
//   go-runtime,
//   shape-engine,       // L1 shape engine
//   riscv-emu,           // emulated RISC-V
//   go-runtime,         // Go on emulated RISC-V
//   shape-engine,       // L2 shape engine
//   mos6502-emu,         // emulated 6502
//   c64-system,         // C64 on emulated 6502
//   sid-player           // SID music player
// )
// Depth: 10. A C64 SID player running on a 6502 emulated by
// a shape engine running on RISC-V emulated by a shape engine
// running on ARM64 running on physics.
//
// Every layer is concrete. Every layer has a shim or shape
// that implements the substrate interface. The music plays.
// It just plays slowly.
//
// Unless the shape engine recognizes the SID's waveform
// generation as a formula. Then the 6502 loop disappears,
// the RISC-V loop disappears, and the SID outputs its
// waveform at O(1) per sample. Compute time dilation
// across 10 layers.
//
// Derives from: all ISA substrates + compose + physics
  """
}
