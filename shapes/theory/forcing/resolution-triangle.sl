shape theory.forcing.resolution-triangle : theory.forcing.collapse, theory.coherence.law2, theory.coherence.law3 {
  type: theorem
  layer: 0
  """
// Theorem 11.7 (Resolution Triangle).
// Let A and B be incompatible shapes at positions in canopy space.
//   1. Draw line AB between canopy positions.
//   2. Find perpendicular from canopy center O to AB. Let F be the
//      foot, h the perpendicular distance.
//   3. Third vertex C lies on perpendicular through O, at distance
//      2h from AB, opposite side from O. C is the excluded component:
//      structural content orthogonal to the A-B incompatibility axis.
//   4. Triangle ABC is the resolution triangle.
//   5. Fold smaller right triangle onto larger. Overlap = incompatible
//      components that annihilate. Remainder = resolution product.
//   6. Resolution product is a new point on AB at the foot, offset
//      by remaining length.
//
// Theorem 11.8 (Resolution Conserves): total persistence magnitude
// is conserved. What annihilates along the incompatibility axis is
// balanced by what survives.
//
// Theorem 11.9 (Anchor Migration): anchor shapes can lose status
// through gradual coherent transformation.
//
// Theorem 11.10 (Active Resolution): resolution is continuous.
// A shape system is a resolution engine.
//
// Derives from: theory.forcing.collapse, theory.coherence.law2,
//               theory.coherence.law3
  """
}
