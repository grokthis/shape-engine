shape theory.computing.os.shape-os-layers : theory.computing.os.shape-os {
  type: structure
  layer: 0
  """
// Shape OS Layer Map.
//
// The actual shape engine running on the idealized hardware,
// mapped to the existing shapes/ directory structure.
//
// Layer 0: law.sl
//   The Laws of Coherence as kernel invariants.
//   law.persistence: validate() checks all shapes every tick.
//   law.reference: propagate() follows deps on change.
//   law.conservation: rm checks dependents before removal.
//   law.consistency: block propagates incompatibility.
//   These are not abstract principles. They are kernel code.
//   The kernel IS the laws.
//
// Layer 1: hardware/
//   Hardware abstraction shapes.
//   hardware.cpu: the pipeline, registers, ALU.
//   hardware.math: arithmetic operations (add, sub, mul, div).
//   hardware.float: floating-point unit.
//   hardware.compile: Verilog projection for FPGA/ASIC.
//   Each hardware shape wraps a device driver.
//   Accessing hardware = accessing shapes.
//
// Layer 2: shape.sl
//   The shape primitive itself.
//   shape.structure: deps, emergence layer, permissions.
//   shape.character: dimensions, content.
//   shape.tick: global tick at last modification.
//   The irreducible data model. Everything is this.
//
// Layer 3: engine/
//   The shape engine: the kernel's core.
//   engine.store: persistence (load/save shape graph to SSD).
//   engine.lang: shape-lang (parse, eval, syscall).
//   engine.transform: the transformation law evaluator.
//   engine.propagate: wave propagation on deps graph.
//   engine.validate: coherence checking every tick.
//   engine.edit: mutation with propagation.
//   engine.block: permission enforcement.
//   engine.trace: history (every change recorded).
//   engine.report: introspection (query system state).
//
// Layer 4: os/
//   The operating system shapes.
//   os.shell: the command-line interface.
//   os.config: system configuration shapes.
//   os.wm: window manager (compositor).
//   os.render: structural rendering (shape -> pixels).
//   os.font: text rendering.
//   os.theme: visual theme shapes.
//   os.event: input event handling.
//   os.handler: event dispatch.
//   os.session: user session state.
//   os.notify: notification system.
//   os.agent: LLM integration (the AI assistant IS a shape).
//
// Layer 5: user.sl, app/, world/
//   User workspace. Everything the user creates.
//   app.browser: web browser (network + rendering).
//   app.desktop: desktop environment.
//   app.editor: text/shape editor.
//   app.shell: interactive shell.
//   app.chat: messaging.
//   app.docs: documentation viewer.
//   user.sl: the user's workspace root.
//   world/: worldbuilding, conlang, creative content.
//
// The layer numbers match the shape engine's emergence layers.
// Layer 0 constrains everything. Layer 5 is unconstrained
// within the laws. Each layer emerges from the one below.
// The entire stack: from transistor to tweet, one primitive.
//
// Derives from: theory.computing.os.shape-os
  """
}
