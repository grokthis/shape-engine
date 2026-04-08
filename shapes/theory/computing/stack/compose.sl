shape theory.computing.stack.compose : theory.computing.stack.substrate, theory.emergence.composition {
  type: theorem
  layer: 0
  """
// Stack Composition.
//
// compose(L0, L1, ..., Ln) produces a computation stack where
// each layer Li runs on the substrate provided by L(i-1).
//
// The composition is itself a substrate: the composed stack
// implements the substrate interface. This means stacks can
// be composed into larger stacks.
//
//   compose(A, B) is a substrate.
//   compose(compose(A, B), C) = compose(A, B, C).
//   compose is associative (Theorem 17.2, category axioms).
//
// How composition works:
//
//   Layer i's `step()` calls layer (i-1)'s `read()` and `write()`
//   to access its memory. Layer (i-1) may in turn call layer
//   (i-2)'s operations. Each call adds latency proportional to
//   the emulation overhead of that layer.
//
//   The composed `step()` at the top level:
//     1. Top layer decodes its instruction (in its ISA).
//     2. Instruction needs memory -> calls next layer's read/write.
//     3. That layer translates the address and accesses its memory.
//     4. If that layer is also emulated, it calls the next layer.
//     5. Eventually reaches the physical substrate (real hardware).
//     6. Result propagates back up through each layer.
//
// Cycle accounting:
//   Each layer tracks its own cycle count.
//   The composed cycle count is the product:
//     total_cycles = product(layer_i.cycles_per_op)
//   A 6502 instruction (6 cycles) on a shape engine (270 ns/instr)
//   on ARM64 (0.3 ns/cycle): 6 * 270 / 0.3 = 5400 ARM64 cycles
//   = ~1.6 microseconds per 6502 instruction.
//   At 1 MHz 6502 clock: ~625x slower than real hardware.
//   But: structural recognition can collapse the 6502 layer.
//
// Memory mapping:
//   Each layer maps its address space onto the layer below.
//   The mapping can be:
//     Identity: 1:1 (native execution on bare metal).
//     Offset: base + addr (process in virtual memory).
//     Banked: different regions map differently (C64 PLA).
//     Translated: page table lookup (MMU/virtual memory).
//
// Interrupt forwarding:
//   Physical interrupts arrive at the bottom layer.
//   Each layer decides whether to forward up or handle:
//     Timer interrupt: bottom layer handles, forwards tick to
//       the next layer if it needs to be informed.
//     Keyboard interrupt: forwarded up to whatever layer owns
//       the input handler (usually the OS layer).
//
// The stack is the emergence hierarchy of computation.
// Each layer is an emergence level (Theorem 7.1). The laws
// of coherence apply at every level. A crash at any layer
// is incoherence (Law 0) at that level, which may propagate
// up (Theorem 7.2) or be contained (if higher layers handle it).
//
// Derives from: theory.computing.stack.substrate,
//               theory.emergence.composition
  """
}
