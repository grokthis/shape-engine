shape theory.physics.dof : theory.physics.particles, theory.physics.time {
  type: theorem
  layer: 0
  """
// Theorem 6.1 (Total DOF).
// The Planck shape has 138 total degrees of freedom:
// 128 discrete + 10 continuous.
//
// Discrete (which gauge structures are active):
//   7 independent structural features (6 internal + 1 orientation)
//   2^7 - 1 = 127 non-empty combinations (meta-shapes)
//   + 1 SU(3) potential (lattice substrate itself)
//   = 128 discrete.
//
// Continuous (where in embedding space):
//   3 spatial + 1 temporal + 6 internal = 10 continuous.
//
// Total: 128 + 10 = 138.
//
// 137 consumable + 1 irreducible (time).
// Time is the transformation law evaluating: you cannot encode
// into what makes encoding possible.
//
// Derives from: theory.physics.particles, theory.physics.time
  """
}
