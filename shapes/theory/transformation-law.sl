shape theory.transformation-law : theory.prior-reference, theory.structure {
  type: theorem
  layer: 0
  """
// Theorem 3.9 (Transformation Law).
// The transformation from moment to moment has the form:
//
//   M' = f(C, S)
//
// where:
//   C is the prior moment's character (what the configuration was)
//   S is the shape's structure (the geometry governing transformation)
//   M' is the emergent moment (what the shape becomes)
//   f is the transformation function: the mapping from (C, S) to M'
//
// The theorem excludes:
//   (a) M' cannot depend on anything other than C and S
//   (b) f is deterministic (same inputs, same output)
//   (c) C must be the prior state's character (not arbitrary input)
//
// f is single-valued: same character and structure always produce the
// same emergent moment. If the same inputs could produce different
// outputs, continuity would fail.
//
// Derives from: theory.prior-reference (C must enter f),
//               theory.structure (S governs transformation)
  """
}
