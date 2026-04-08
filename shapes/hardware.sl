// Hardware layer: shape theory projected onto gates.
//
// The FPGA IS a shape lattice. Each LUT is a shape.
// Configuration IS character. Routing IS structure.
// Flip-flop state IS the tick.
//
// This file derives the minimal shape-gate: the smallest
// hardware unit that persists and propagates.

shape hardware {
  type: axiom
  layer: 0
  "Hardware projection of persistence. A shape-gate is the physical encoding of: change + persistence = shape."
}

shape hardware.gate : hardware {
  type: primitive
  layer: 0
  """
// The minimal shape-gate.
//
// Inputs:  wave_in[N]    -- one per dependency
// Outputs: wave_out      -- to all dependents
// State:   content[W]    -- the character (LUT truth table)
//          tick[T]       -- structural position (flip-flop counter)
//          coherent      -- 1 if all deps resolved, 0 if dangling
//
// Behavior (one clock cycle):
//   1. If any wave_in is high:
//      a. Read content register (this is the transform)
//      b. Apply transform to incoming data
//      c. Write result to content register (append: old value persists in trace RAM)
//      d. Increment tick
//      e. Assert wave_out (propagate to dependents)
//   2. If no wave_in: hold. Persistence without change.
//
// This is Law 0 in silicon: the gate persists stably because
// its flip-flop holds state. When a wave arrives, it changes
// while maintaining continuity (the tick links old to new).
//
// Cost: 1 slice (4-8 LUTs + flip-flops) per shape-gate.
// A 200K LUT FPGA holds ~25,000 shape-gates.
"""
}

shape hardware.lattice : hardware {
  type: structure
  layer: 1
  """
// A shape lattice is N shape-gates connected by their wave lines.
//
// The routing fabric IS the dependency graph:
//   gate.wave_out -> dependent.wave_in
//
// Wave propagation is physical: electrical signal propagation
// through the routing fabric. Speed is limited by wire delay,
// not instruction fetch. A wave crosses the entire lattice in
// nanoseconds, not microseconds.
//
// The lattice is append-only: each gate has a small trace RAM
// (block RAM slice) that logs every moment. The trace IS the
// structure. You can reconstruct any prior state by reading
// the trace back to any tick.
//
// Topology: the dot-separated namespace maps to physical position.
//   law.persistence -> row 0, column 0
//   law.reference   -> row 0, column 1
//   engine.trace    -> row 1, column 0
//   os.shell.cmd.ls -> row 4, column N
//
// Locality: shapes that reference each other are placed nearby.
// This minimizes routing delay. The shape compiler handles placement.
"""
}

shape hardware.projection : hardware {
  type: structure
  layer: 2
  """
// Projection from shape-lang to hardware.
//
// Three projections exist, all equivalent:
//   Disk:   shape -> binary format (pkg/store/binary.go)
//   Memory: shape -> Go struct (pkg/shape/shape.go)
//   FPGA:   shape -> LUT configuration (hardware.gate)
//
// The FPGA projection maps:
//   Shape.ID        -> physical position in lattice
//   Shape.Character  -> LUT truth table + register content
//   Shape.Structure  -> routing connections
//   Shape.Tick       -> flip-flop counter value
//   Transform.Fn     -> the LUT function itself
//   Transform.Deps   -> wave_in connections
//   Dependents       -> wave_out fan-out
//
// Compilation: .sl file -> parse -> shape graph -> place & route -> bitstream
// This is the same pipeline as Verilog synthesis, but the input
// is shapes instead of RTL.
"""
}
