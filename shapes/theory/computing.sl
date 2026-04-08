shape theory.computing : theory.physics.lattice, theory.chemistry.properties, theory.transformation-law {
  type: system
  layer: 0
  """
// A Complete Computer from Persistence Structure.
//
// A computer is a shape that implements the transformation law
// M' = f(C, S) in silicon. The transformation law is universal;
// the computer makes it programmable: S is changeable (software),
// not fixed. This is the structural content of general-purpose
// computation.
//
// Architecture layers (emergence hierarchy):
//   0. Silicon: doped semiconductor, electron flow
//   1. Transistor: voltage-controlled switch (the minimal gate)
//   2. Logic gates: NOT, NAND, NOR, AND, OR, XOR
//   3. Arithmetic: adder, multiplexer, decoder, comparator, ALU
//   4. Sequential: flip-flop, register, counter (memory elements)
//   5. Functional: register file, memory array, cache line
//   6. Datapath: pipeline stages, buses, forwarding
//   7. Control: instruction decoder, control unit, hazard detection
//   8. Processor: CPU core, cache hierarchy, MMU
//   9. System: memory controller, I/O controller, interrupt, bus
//  10. Computer: power supply, clock, boot sequence, peripherals
//
// Each layer is emergent composition (Theorem 6.2): the composite
// has properties absent from its components. A flip-flop stores
// a bit; no individual gate stores anything. A pipeline executes
// instructions; no individual stage does.
//
// The idealized architecture: 64-bit RISC, 5-stage pipeline,
// 3-level cache, virtual memory, interrupt-driven I/O.
// Modern in capability, clean in structure.
//
// Derives from: theory.physics.lattice (spatial substrate),
//               theory.chemistry.properties (silicon chemistry),
//               theory.transformation-law (what computation IS)
  """
}
