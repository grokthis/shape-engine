shape theory.computing.stack.stdio : theory.computing.stack.syscall {
  type: unit
  layer: 0
  """
// Standard I/O Passthrough.
//
// Three file descriptors, always connected to the base process:
//   fd 0: stdin   (read from host terminal / pipe)
//   fd 1: stdout  (write to host terminal / pipe)
//   fd 2: stderr  (write to host terminal / pipe)
//
// These are opened before the stack boots. They persist across
// all layers. They are invariant references (Law 1): every
// layer can write to stdout and it appears on the same terminal.
//
// How stdout works through a 5-layer stack:
//
//   Layer 4 (Shape OS):
//     print("hello")
//     -> shape-lang evaluator calls engine.Print()
//
//   Layer 3 (shape engine):
//     engine.Print() -> syscall(1, 1, "hello", 5)
//     The shape engine intercepts print as a write syscall.
//     It does NOT pass through layers 2, 1, 0 for emulation.
//     It calls the Go runtime's os.Stdout.Write() directly.
//
//   Layer 2 (Go runtime):
//     os.Stdout.Write([]byte("hello"))
//     Go calls the host OS write(2) syscall.
//
//   Layer 1 (ARM64):
//     SVC #0 with x8=64 (Linux write), x0=1, x1=buf, x2=5.
//     Kernel handles it.
//
//   Layer 0 (physics):
//     Electrons flow through UART/terminal/PTY.
//     "hello" appears on screen.
//
// The path from layer 4 to the screen: 4 -> 3 -> 2 -> 1 -> 0.
// But layers 3, 2, 1, 0 are NOT emulation. They are the native
// execution path of the base process. The syscall passthrough
// exits the emulation at layer 3 and uses the native path.
//
// If the stack were deeper:
//   Layer 7 (SID player on emulated 6502):
//     ecall with A=1 (print), X/Y = pointer to "Playing: song.sid"
//     -> substrate intercepts BRK
//     -> reads A, X, Y from emulated 6502 registers
//     -> copies string from emulated 6502 memory
//     -> calls base engine's Print() directly
//     -> appears on host stdout
//
//   Layers 6, 5, 4, 3 are NOT involved. The syscall jumps from
//   layer 7 directly to the base. This is the passthrough.
//
// For stdin (reading input):
//   The base engine reads from the host's stdin.
//   The result is placed in the calling layer's memory.
//   read(0, buf, len) -> base reads host stdin -> copies bytes
//   into the calling layer's address space at `buf`.
//   The address translation is layer-specific: the substrate
//   knows how to write into its guest's memory.
//
// Derives from: theory.computing.stack.syscall
  """
}
