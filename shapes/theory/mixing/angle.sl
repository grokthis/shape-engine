shape theory.mixing.angle : theory.mixing.pythagorean {
  type: definition
  layer: 0
  """
// Definition 9.6 (Structural Mixing Angle).
// The structural mixing angle theta is defined by:
//   sin^n(theta) = c/p
//
// where n counts the independent conservation constraints:
//   n=1: single conservation. sin(theta) = c/p.
//     Shape-preserving transition or isolated branch.
//     c_theta = p*sin(theta) = c.
//   n=2: two constraints. sin^2(theta) = c/p.
//     Full shape junction (breaking or combining).
//   n>=3: multi-step junctions. sin^n(theta) = c/p.
//
// The conservation constraint count n is determined by the structure
// of the transformation, not by convention.
//
// Theorem 9.7: For any persistent shape with distinguishing
// character, 0 < theta < pi/2. At theta=0, no source. At theta=pi/2,
// no destination. Both excluded for shapes with distinguishing character.
// The minimal shape has theta=0.
//
// Derives from: theory.mixing.pythagorean
  """
}
