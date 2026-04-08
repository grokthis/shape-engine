shape theory.computing.stack.isa.shape-engine : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// The Shape Engine as composable substrate.
//
//   addr_bits: unbounded (shape IDs are strings, not integers)
//   data_bits: unbounded (arbitrary precision arithmetic)
//   endian: n/a (structural, not byte-oriented)
//   clock_hz: ~3700000 (3.7 MIPS measured on M1 Pro)
//   regs: {shapes: map[ID]Shape, tick: uint64, trace: []Moment}
//   vectors: {boot: shapes with type=exec, interrupt: onMutate}
//
// The shape engine is a substrate with unique properties:
//
// 1. Addresses are names, not numbers.
//    read("law.persistence") instead of read(0x1000).
//    The address space is a tree, not a flat array.
//    This is why the shape engine has O(1) children lookup.
//
// 2. Data is arbitrary precision.
//    No overflow. No truncation. No float imprecision.
//    1/3 + 1/3 + 1/3 = 1 exactly.
//
// 3. Step is wave propagation.
//    Editing one shape propagates changes to all dependents.
//    A single `step()` can touch hundreds of shapes.
//    The shape engine's step is not one instruction: it is
//    one structural transformation with cascading consequences.
//
// 4. Structural recognition collapses computation.
//    The Gauss sum benchmark: O(n) loop recognized as O(1)
//    formula. The recognition crosses layer boundaries.
//    A 6502 loop running on the shape engine can be recognized
//    and collapsed, even though the 6502 ISA has no concept
//    of formula collapse.
//
// The shape engine as a substrate layer:
//   compose(physics, arm64, go-runtime, shape-engine, ...)
//   compose(physics, riscv, go-runtime, shape-engine, ...)
//   compose(physics, x86-64, go-runtime, shape-engine, ...)
//
// The shape engine running ON the shape engine:
//   compose(physics, arm64, go, shape-engine, shape-engine-emu, ...)
//   The inner shape engine is a program running on the outer.
//   The outer recognizes the inner's patterns and collapses them.
//   This is the compounding effect: shape engines stack.
//
// Derives from: theory.computing.stack.substrate
  """
}
