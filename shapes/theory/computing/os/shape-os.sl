shape theory.computing.os.shape-os : theory.computing.os, theory.coherence, theory.emergence, theory.fractal {
  type: system
  layer: 0
  """
// Shape OS: The Operating System as Shape System.
//
// A conventional OS manages processes, files, and devices as
// separate abstractions. Shape OS has one abstraction: the shape.
// Everything is a shape. Processes, files, devices, windows,
// network connections, users, permissions. One primitive.
//
// This is not a metaphor. The shape engine evaluates shapes.
// The OS IS the shape engine running on hardware.
//
// THE KERNEL: the shape engine itself.
//   The kernel is the transformation law evaluator.
//   Every tick, for every shape in the system:
//     M' = f(C, S)
//   where C is the shape's current character (state) and S is
//   its structure (deps, permissions, transformation function).
//   The kernel evaluates all shapes, propagates changes (waves),
//   validates coherence, and persists the result.
//
// SHAPES REPLACE PROCESSES:
//   A running program is a shape with executable content.
//   Its structure: deps (libraries, resources), permissions,
//     transformation function (the code).
//   Its character: current state (variables, stack, heap).
//   Execution: the kernel evaluates the shape's transformation
//     function each tick. The shape transforms.
//   Multiple shapes execute concurrently (multi-core).
//   Shape isolation: each shape's context is its deps.
//     It cannot reference shapes not in its deps.
//     This is Law 1 enforced by the kernel.
//
// SHAPES REPLACE FILES:
//   A file is a shape with content but no executable transformation.
//   Its structure: type, permissions, parent directory.
//   Its character: the content (bytes, text, image, whatever).
//   The filesystem is a shape tree: directories are shapes whose
//   character is a list of child shapes.
//   Everything in the namespace is a shape. The namespace IS the
//   shape graph.
//
// SHAPES REPLACE DEVICES:
//   A device is a shape with hardware-backed transformation.
//   Its structure: device type, capabilities, driver.
//   Its character: device state (registers, buffers).
//   Reading a device: access the shape's character.
//   Writing a device: mutate the shape's character.
//   The driver is the shape's transformation function.
//
// SHAPES REPLACE WINDOWS:
//   A window is a shape with visual content.
//   Its structure: position, size, z-order, parent.
//   Its character: the rendered framebuffer region.
//   The compositor is the engine's render pass: composing
//   all visible shapes into the display framebuffer.
//   Window management IS shape management.
//
// THE SHAPE GRAPH:
//   All shapes form a directed acyclic graph (the deps graph).
//   The root is the kernel shape.
//   Children are system shapes (hardware, filesystem, network).
//   User shapes are leaves, depending on system shapes.
//   The graph IS the system. There is no separate "process table"
//   or "filesystem tree" or "device list." There is one graph.
//
// PERSISTENCE:
//   Every shape is persisted to storage on every tick (or on
//   change, with journaling for crash recovery).
//   Power off + power on: the shape graph is loaded from storage.
//   Every shape resumes from its last persisted state.
//   No "boot to empty" unless the store is empty.
//   The system persists structurally: it IS its shape graph.
//
// COHERENCE AS SECURITY:
//   Permissions are structural: each shape declares who can
//   read/write/execute it (the permissions field in structure).
//   The kernel enforces permissions at every access.
//   A shape cannot access another shape outside its deps.
//   A shape cannot modify another shape without write permission.
//   Security is not a layer added on top. It is Law 1 + Law 3:
//   references must be authorized, and incompatible access
//   must resolve (deny or grant).
//
// WAVE PROPAGATION:
//   When a shape changes, the change propagates to dependents.
//   The kernel walks the deps graph and re-evaluates affected
//   shapes. This is wave propagation: a change at one node
//   ripples through the graph to all nodes that reference it.
//   This IS the engine's core loop: edit -> propagate -> validate.
//   Conventional OS equivalent: inotify + signal + redraw.
//   In Shape OS: one mechanism for all of it.
//
// THE SHELL:
//   The shell is a shape whose transformation function reads
//   user input (keyboard events) and evaluates shape-lang.
//   It is the human-computer contact boundary.
//   Every command creates, reads, edits, or removes shapes.
//   There is no "command vs file vs process" distinction.
//   Everything is a shape operation.
//
// Derives from: theory.computing.os (conventional OS concepts),
//               theory.coherence (Laws as security/integrity),
//               theory.emergence (shapes compose into systems),
//               theory.fractal (coherence at every layer)
  """
}
