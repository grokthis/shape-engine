shape os.error.shape : os.error {
  type: definition
  layer: 4
  """
// Error Shape Structure.
//
// An error shape has these dimensions:
//   type: error
//   phase: parse | eval | propagate | validate | boot | syscall
//   message: human-readable error text
//   source: shape ID that failed
//   line: line number (0 if not applicable)
//   tick: global tick when error occurred
//
// The error shape's content is the full diagnostic:
//   [parse] theory.prior-reference: line 3: unexpected '-' in identifier
//   derivation: theory.axiom -> theory.shape -> theory.continuity
//     -> theory.structure -> theory.character -> theory.prior-reference
//   content (first 200 chars):
//     shape theory.prior-reference : theory.continuity, ...
//
// The error shape's deps are:
//   [0]: the failing shape (if it exists)
//   [1]: the parent shape (if it exists)
// This gives the derivation trace through the normal dep mechanism.
  """
}
