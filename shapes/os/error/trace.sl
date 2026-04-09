shape os.error.trace : os.error {
  type: exec
  layer: 4
  """
// Error Trace: the derivation structure as stack trace.
//
// Traditional stack trace:
//   main() at main.go:42
//   -> handleRequest() at server.go:156
//   -> renderShape() at render.go:89
//   -> parse() at parser.go:234  <-- error here
//
// Shape error trace:
//   theory.axiom (layer 0)
//   -> theory.shape (layer 0)
//   -> theory.continuity (layer 0)
//   -> theory.prior-reference (layer 0)  <-- error here
//     phase: parse
//     message: unexpected '-' in identifier at position 23
//     tick: 0 (during boot)
//
// The shape trace IS the derivation chain. It is not constructed
// at error time; it already exists in the dep graph. Walking the
// deps from the errored shape back to the root IS the trace.
//
// For runtime errors (eval phase), the trace also includes:
//   - The shape-lang call stack at the time of error
//   - The current scope (variable bindings)
//   - The AST node that failed
//
// This is more information than a traditional stack trace because
// the structure encodes the full derivation, not just the call path.
//
// Usage:
//   errors trace <id>    Show full derivation trace for an error
//   errors trace --all   Show traces for all errors
  """
}
