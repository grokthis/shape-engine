shape theory.computing.stack : theory.computing, theory.emergence.composition, theory.fractal {
  type: system
  layer: 0
  """
// Composable Computation Stacks.
//
// A computation stack is a chain of emergence layers from the
// persistence axiom to the running system. Each layer implements
// a substrate that the layer above runs on.
//
// The stack is composable: any layer can run on any layer below
// it, to arbitrary depth. Each composition is an emergent shape
// (Theorem 6.2) whose structure is the combined stack.
//
//   stack = compose(layer_0, layer_1, ..., layer_n)
//
// where layer_0 is the physical substrate and layer_n is the
// application. Each layer_i provides the substrate for layer_i+1.
//
// Every layer implements one interface: the substrate.
//   read(addr) -> value     Read memory/state
//   write(addr, value)      Write memory/state
//   step() -> cycles        Execute one instruction, return cost
//   reset()                 Initialize to known state
//   interrupt(vector)       Deliver interrupt
//
// A layer consumes the substrate below it (runs on it) and
// provides a substrate above it (hosts the next layer).
// The composition is recursive: a stack IS a substrate.
//
// The bottom layer is always physics:
//   theory.computing.stack.physics
// It provides the real substrate: actual voltage transitions
// in actual silicon on the actual Planck lattice.
//
// The top layer is always the application:
//   Shape OS, a game, a benchmark, whatever runs.
//
// Between them: any number of architecture layers.
//
// Examples:
//   compose(physics, arm64, go, shape-engine, shape-os)
//     The current system. Physics -> ARM64 -> Go runtime ->
//     shape engine -> Shape OS.
//
//   compose(physics, riscv64, shape-engine, shape-os)
//     Shape OS on RISC-V. Physics -> RISC-V -> shape engine ->
//     Shape OS.
//
//   compose(physics, arm64, go, mos6502-emu, c64-kernal)
//     C64 emulated on ARM64. Physics -> ARM64 -> Go -> 6502
//     emulator -> C64 KERNAL.
//
//   compose(physics, arm64, go, shape-engine, riscv-emu,
//           shape-engine, shape-os)
//     Shape OS on emulated RISC-V on the shape engine on ARM64.
//     Seven layers deep. Each layer is a concrete substrate.
//
//   compose(physics, x86-avx512, shape-engine, arm64-emu,
//           shape-engine, mos6502-emu, c64-sid)
//     A C64 SID chip emulated on a 6502 emulated on a shape
//     engine emulated on ARM64 emulated on a shape engine
//     running on x86 with AVX-512. Six layers, four ISAs.
//
// The performance at each layer:
//   Each emulation layer multiplies latency by the emulation
//   overhead of that layer. A 6502 instruction on a shape engine
//   on ARM64 costs: (6502 decode cost) * (shape engine overhead)
//   * (ARM64 native cost).
//
//   But: structural recognition (compute time dilation) can
//   collapse layers. If the shape engine recognizes that the
//   6502 loop IS a Gauss sum, the 6502 layer disappears.
//   The recognition crosses layer boundaries. The structure
//   doesn't care how many emulation layers it's wrapped in.
//
// Derives from: theory.computing,
//               theory.emergence.composition,
//               theory.fractal (coherence at every layer)
  """
}
