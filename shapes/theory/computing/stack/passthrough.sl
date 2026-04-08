shape theory.computing.stack.passthrough : theory.computing.stack.compose, theory.coherence.law1 {
  type: structure
  layer: 0
  """
// I/O Passthrough: Execution Through the Stack, I/O to the Base.
//
// In a composed stack, there are two kinds of operations:
//
//   Computation: goes through every layer.
//     add r1, r2, r3 -> decoded by layer N ISA -> reads registers
//     from layer N memory -> which is emulated by layer N-1 ->
//     which is emulated by layer N-2 -> ... -> physics.
//     Every layer participates. Full emulation overhead.
//
//   I/O: punches straight to the base.
//     print("hello") -> syscall at layer N -> immediately
//     delivered to the base-level process's stdout.
//     Intermediate layers are skipped. Zero emulation overhead
//     for the I/O path itself.
//
// This is structurally sound because I/O targets are invariant
// from the perspective of the emulation layers. Stdout IS the
// host process's file descriptor 1. It doesn't change when you
// add or remove emulation layers. It is a Law 1 invariant
// reference: the I/O target is a fixed point (like empty_s).
// Referencing it directly is always safe.
//
// The Docker analogy:
//   Container execution: isolated, namespaced, layered.
//   Container I/O: stdin/stdout/stderr go to the host.
//   Container filesystem: can be overlaid or passthrough.
//   Container network: can be bridged or passthrough.
//
// Shape stack:
//   Stack execution: each layer emulates the one above.
//   Stack I/O: syscalls go to the base shape engine.
//   Stack memory: each layer has its own address space.
//   Stack interrupts: can be forwarded or passthrough.
//
// Derives from: theory.computing.stack.compose,
//               theory.coherence.law1 (invariant reference)
  """
}
