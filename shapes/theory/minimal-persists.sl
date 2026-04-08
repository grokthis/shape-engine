shape theory.minimal-persists : theory.minimal, theory.self-reference, theory.transformation-law {
  type: theorem
  layer: 0
  """
// Proposition 4.4 (The Minimal Shape Persists).
// empty_s satisfies all persistence conditions: it references its
// prior character, continuity holds trivially (M' = M), and its
// context is well-defined.
//
// Self-reference: by Theorem 3.7 (all shapes do).
// Continuity: M' = M, so the shape is identical across every
// transformation.
// Context: only contact is with itself. Self-contact is well-defined
// because the transformation law is well-defined for any shape with
// structure and character. Since nothing changes, the transformation
// cannot fail.
//
// Derives from: theory.minimal, theory.self-reference,
//               theory.transformation-law
  """
}
