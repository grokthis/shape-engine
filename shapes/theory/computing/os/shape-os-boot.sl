shape theory.computing.os.shape-os-boot : theory.computing.os.shape-os, theory.computing.boot {
  type: structure
  layer: 0
  """
// Shape OS Boot Sequence.
//
// POWER BUTTON PRESSED:
//   PSU activates. Voltages stabilize. Reset released.
//   CPU begins executing at reset vector.
//
// FIRMWARE:
//   POST: hardware coherence check (same as conventional).
//   Firmware locates the shape store on the boot device.
//   The shape store is the persistent shape graph: a file
//   containing every shape's structure and character.
//
// SHAPE ENGINE LOAD:
//   Firmware loads the engine (layer 3) into memory.
//   The engine is the kernel. It is a binary that:
//     1. Opens the shape store.
//     2. Loads the shape graph into memory (DRAM).
//     3. Begins tick evaluation.
//
// FIRST TICK:
//   Engine evaluates all shapes marked 'exec' (type: exec).
//   These are startup shapes: they run on first tick.
//   _preamble.sl: system documentation (no-op).
//   hardware.compile: if FPGA target, project hardware shapes
//     to Verilog and configure FPGA.
//   os shapes with init functions: start services.
//
// HARDWARE INIT:
//   Engine evaluates hardware/ shapes.
//   Each hardware shape's transformation function initializes
//   its device (same role as device drivers).
//   Display initialized: framebuffer allocated, mode set.
//   Input initialized: keyboard/mouse/touch active.
//   Network initialized: link up, DHCP, address acquired.
//   Storage initialized: shape store mounted read-write.
//
// OS INIT:
//   Engine evaluates os/ shapes.
//   os.config loaded: system settings.
//   os.session started: user session.
//   os.wm started: window manager begins compositing.
//   os.render started: structural renderer active.
//   os.shell started: command line ready.
//   os.agent started: LLM assistant available.
//
// DESKTOP READY:
//   The compositor renders the desktop.
//   The shell accepts input.
//   The system is fully coherent.
//   Total boot time: shape store load + one tick evaluation.
//   Cold boot: ~2-5 seconds (SSD read + init).
//   Warm boot (resume from suspend): ~100ms (DRAM preserved).
//
// EVERY SUBSEQUENT TICK:
//   Engine evaluates all shapes whose deps have changed.
//   Only changed shapes and their dependents are re-evaluated.
//   Unchanged shapes are skipped (no wasted work).
//   This is incremental evaluation: the engine only recomputes
//   what the wave propagation touches.
//
// SHUTDOWN:
//   Engine persists all shapes to store (sync).
//   Engine closes store.
//   ACPI power off.
//   Next boot: load the same graph. All state preserved.
//   No "unsaved changes" possible: everything is always saved.
//
// Derives from: theory.computing.os.shape-os, theory.computing.boot
  """
}
