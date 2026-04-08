shape theory.safe-reference : theory.minimal {
  type: theorem
  layer: 0
  """
// Theorem 4.5 (Safe Reference).
// empty_s never changes (Theorem 4.2). Therefore any shape whose
// transformation depends on empty_s will never encounter a change
// in what empty_s presents: empty_s returns the same character at
// every moment. A reference to empty_s can never produce a surprise.
//
// Derives from: theory.minimal (fixed point property)
  """
}
