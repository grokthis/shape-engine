shape theory.computing.stack.container : theory.computing.stack.passthrough, theory.computing.stack.syscall, theory.computing.stack.stdio {
  type: system
  layer: 0
  """
// Container Execution Model.
//
// A shape container is a composed stack with passthrough I/O.
// Execution is isolated (each layer has its own address space).
// I/O is shared (syscalls go to the base).
//
// This is Docker semantics implemented structurally:
//
//   ISOLATION (what the container controls):
//     Memory: each layer has its own address space.
//       The 6502 layer sees 64KB. The ARM64 layer sees 256TB.
//       Neither can access the other's memory directly.
//     Execution: each layer runs its own ISA.
//       Instructions are decoded by that layer's substrate.
//     State: each layer has its own registers, PC, flags.
//       A crash in one layer doesn't corrupt another layer's
//       state (unless the crash is in the substrate itself).
//
//   PASSTHROUGH (what goes to the base):
//     stdout/stderr: write(1, ...) goes to host stdout.
//     stdin: read(0, ...) reads from host stdin.
//     Files: open/read/write/close go to host filesystem.
//     Shapes: shape_get/edit/add go to base shape graph.
//     Clock: clock_gettime reads the real tick counter.
//     Exit: exit(code) terminates the entire stack.
//
//   CONFIGURABLE (per container):
//     Filesystem visibility: which host paths are accessible.
//     Shape visibility: which shapes the container can see/edit.
//     Network: passthrough, bridged, or none.
//     Capabilities: which syscalls are allowed.
//     Resource limits: max memory, max cycles per tick.
//
// Container lifecycle:
//
//   1. CREATE: compose the stack layers.
//      container = compose(physics, arm64, riscv-emu, shape-engine, app)
//      Each layer is initialized but not running.
//
//   2. CONFIGURE: set passthrough policy.
//      container.stdio = passthrough     (stdout to host)
//      container.fs = {"/data": "/host/data"}  (mount)
//      container.shapes = ["user.*"]     (shape access)
//      container.caps = [0,1,2,3,4,5,9]  (allowed syscalls)
//      container.limits = {mem: "64MB", cycles: 10000000}
//
//   3. BOOT: reset all layers, load program into top layer.
//      container.reset()
//      container.load(program)
//
//   4. RUN: execute until exit or limit.
//      while !container.exited:
//        container.step()
//        if container.cycles > limit: kill
//
//   5. STOP: save state or discard.
//      container.save()  -> checkpoint to shape store
//      container.kill()  -> discard state
//
// Multiple containers can run simultaneously on the same base
// engine. Each has its own stack, own memory, own execution.
// They share the base shape graph through shape syscalls.
// This is structural isolation (Definition 16.18): shapes held
// in reference without mutual forcing.
//
// Container-to-container communication:
//   Through shared shapes. Container A edits a shape.
//   Container B reads it. The base engine's wave propagation
//   delivers the change. This is IPC through the shape graph.
//   No special mechanism needed. The graph IS the communication.
//
// Derives from: theory.computing.stack.passthrough,
//               theory.computing.stack.syscall,
//               theory.computing.stack.stdio
  """
}
