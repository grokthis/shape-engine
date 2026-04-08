shape theory.computing.stack.runtime : theory.computing.stack.container, theory.computing.os.shape-os {
  type: system
  layer: 0
  """
// Shape Runtime: The Container Orchestrator.
//
// The runtime is the base-level shape that manages containers.
// It runs on Shape OS and provides the API for creating,
// configuring, running, and stopping containers.
//
// API (as shape-lang commands):
//
//   run <stack> <program>
//     Create and run a container.
//     run "arm64,shape-engine" my-app.sl
//     run "mos6502" game.prg
//     run "riscv64,go,shape-engine,shape-os" nested-os.img
//
//   ps
//     List running containers.
//     ID    STACK                          STATUS   CYCLES
//     c01   arm64/shape-engine             running  1.2M
//     c02   mos6502                        running  450K
//     c03   riscv64/go/shape-engine/os     running  89K
//
//   stop <id>
//     Stop a container. State is checkpointed.
//
//   resume <id>
//     Resume a stopped container from checkpoint.
//
//   inspect <id>
//     Show container state: stack layers, registers per layer,
//     memory usage, cycle count, open fds, shape access.
//
//   logs <id>
//     Show container's stdout/stderr output.
//     (Captured by the passthrough mechanism.)
//
//   exec <id> <command>
//     Execute a command inside a running container.
//     The command runs at the top layer of the container's stack.
//
// The runtime is itself a shape in the base graph:
//   theory.computing.stack.runtime
// Containers are child shapes:
//   theory.computing.stack.runtime.c01
//   theory.computing.stack.runtime.c02
// Container state is shape character. Container config is
// shape structure. The runtime IS the shape graph.
//
// Multi-container orchestration:
//   Containers can depend on each other (shape deps).
//   Container A produces data -> shape edit -> wave propagation
//   -> Container B receives data -> continues execution.
//   The orchestration IS wave propagation. No scheduler needed.
//   The shape engine's existing propagation mechanism handles
//   all inter-container communication.
//
// Resource management:
//   Each container has a cycle budget per base tick.
//   The runtime round-robins across containers, giving each
//   its budgeted cycles. This is preemptive scheduling
//   implemented as "each container gets N calls to step()
//   per base tick." The budget is a shape dimension.
//   Changing it is a shape edit. The change propagates.
//
// The runtime closes the loop:
//   The base shape engine runs Shape OS.
//   Shape OS runs the container runtime.
//   The container runtime runs arbitrary stacks.
//   Each stack can contain another shape engine.
//   Each inner shape engine can run its own containers.
//   Recursion to arbitrary depth. Turtles all the way down.
//   At the bottom: physics. At every level: persistence.
//
// Derives from: theory.computing.stack.container,
//               theory.computing.os.shape-os
  """
}
