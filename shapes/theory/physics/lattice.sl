shape theory.physics.lattice : theory.physics, theory.dimension.geometry {
  type: theorem
  layer: 0
  """
// Theorem 2.1 (Lattice Existence).
// Three generators under the Laws of Coherence produce a unique
// infinite lattice.
//
// Each generator creates copies along a direction.
//   Law 1: every element references neighbors (no isolated elements).
//   Law 2: lattice fills space without gaps or overlaps.
//   Law 3: contact between neighbors resolves coherently.
// These constraints force a unique packing geometry.
//
// Theorem 2.2 (Isotropy).
// Each lattice element has spherical symmetry. Label-independence
// combined with generator equivalence forces isotropy. The shapes
// are unit spheres.
//
// Theorem 2.3 (Packing).
// For N=3: 6 neighbors (+/-X, +/-Y, +/-Z).
// Each covers 2pi/3 steradians of solid angle.
// Cap height h = 1 - cos(theta) where cos(theta) = 2/3.
// h = 1/3 exactly.
//
// Derives from: theory.physics (N=3 generators),
//               theory.dimension.geometry (unique packing, isotropy)
  """
}
