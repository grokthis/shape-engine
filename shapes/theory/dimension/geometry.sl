shape theory.dimension.geometry : theory.dimension.generator, theory.coherence.law1, theory.coherence.law2, theory.coherence.law3 {
  type: theorem
  layer: 0
  """
// Theorems 8.11-8.13 (Coherence Constrains Geometry).
//
// Theorem 8.11 (Balanced Reference):
// Persistent lattice structures have balanced reference: each shape
// references neighbors in both directions along each generator.
// Symmetry is structurally required. There is no genuinely
// unidirectional structure.
//
// Theorem 8.12 (Generator Equivalence Implies Isotropy):
// When generators are interchangeable, persistence structure is
// isotropic: the fundamental shape has spherical symmetry.
// 1D: symmetric interval. 2D: circle. 3D: sphere.
// The sphere is the unique geometry that achieves equivalence
// among generators.
//
// Theorem 8.13 (Unique Packing):
// For a given number of equivalent generators, the coherence
// constraints determine a unique self-consistent packing geometry.
// No gaps (Law 1). No contradiction (Law 2). Contact (Law 3).
// 2N neighbors, solid angle 4pi/2N each. No free parameter remains.
//
// Example: 3 generators -> 6 neighbors, 2pi/3 steradians each,
// cap height h = 1/3, internal space exists.
//
// Derives from: theory.dimension.generator, all three relational laws
  """
}
