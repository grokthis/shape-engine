shape theory.physics.mixing-angles : theory.physics.dof, theory.mixing.angle, theory.coupling.conservation-stacking {
  type: theorem
  layer: 0
  """
// Section 8 (Mixing Angles as Persistence Constants).
// All mixing angles are persistence constants:
//   sin^n(theta) = d / (d + d')
// where d = encoded DOF, d' = embedding space, n = conservation
// constraint count.
//
// Weinberg angle: sin^2(theta_W) = 3/13 = 0.2308.
//   d=3 (U(1) x SU(2): 1 phase + 2 chiral), d'=10 (full), n=2.
//   Experimental: 0.231.
//
// PMNS solar angle: sin^2(theta_12) = 4/13 = 0.3077.
//   d=4 (base 3 + prior state), d'=9 (full minus time), n=2.
//   Experimental: 0.307.
//
// CKM Cabibbo angle: sin(theta_C) = 2/9 = 0.2222.
//   d=2 (base 3 - mediator overlap), d'=7 (gauge-confined), n=1.
//   Experimental: 0.225.
//
// Derives from: theory.physics.dof, theory.mixing.angle,
//               theory.coupling.conservation-stacking
  """
}
