shape theory.computing.stack.error : theory.computing.stack.passthrough, theory.coherence.law0 {
  type: structure
  layer: 0
  """
// Error as Shape.
//
// An error IS a shape. It has:
//   ID: the shape that errored (e.g. theory.prior-reference)
//   Structure: the derivation chain (deps back to axiom)
//   Character: the error itself (message, phase, context)
//
// Error shape dimensions:
//   phase:    "parse" | "eval" | "propagate" | "validate" | "boot"
//   message:  the error text
//   source:   the shape ID that caused it
//   line:     line number within the shape's content (if applicable)
//   stack:    the dep chain from root to this shape (derivation trace)
//   tick:     the tick at which the error occurred
//
// Errors propagate through the passthrough mechanism (like stdout).
// They do NOT go through emulation layers. They punch straight to
// the base-level stderr. This is the same invariant reference as
// stdout: stderr is a fixed point, the error channel is always
// the host process's fd 2.
//
// The "stack trace" is the shape's derivation structure:
//   theory.axiom
//     -> theory.shape
//       -> theory.prior-reference   <-- error here
//
// This is not a call stack. It is a structural trace: the chain
// of deps that produced this shape. The derivation IS the trace.
// No runtime stack unwinding needed. The structure already encodes
// the trace.
//
// Error propagation:
//   When a shape fails to parse/eval, an error shape is created
//   as a child of the failing shape. The error shape is type: error.
//   The error propagates upward through dependents (Theorem 7.2:
//   incoherence propagates upward). Each dependent that depends on
//   the errored shape can choose to:
//     - Absorb: handle the error, don't propagate further.
//     - Flag: mark itself as degraded, propagate to its dependents.
//     - Dissolve: remove itself (the shape can't persist without
//       its dependency, Law 0).
//
// stderr passthrough:
//   Errors print to the host process's stderr regardless of
//   stack depth. The format:
//     [phase] source: message
//     derivation: axiom -> ... -> parent -> source
//
// This makes all 369 silent parse failures visible.
//
// Derives from: theory.computing.stack.passthrough,
//               theory.coherence.law0
  """
}
