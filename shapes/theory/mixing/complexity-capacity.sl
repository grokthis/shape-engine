shape theory.mixing.complexity-capacity : theory.mixing.pythagorean {
  type: definition
  layer: 0
  """
// Definitions 9.8-9.10, Theorems 9.11-9.18.
//
// Structural complexity: c_theta = p*sin(theta).
//   Character amplitude in the source direction.
//   Measures what the shape IS.
//
// Structural capacity: s_theta = p*cos(theta).
//   Character amplitude in the destination direction.
//   Measures what the shape COULD BECOME.
//
// Rigidity ratio: tan(theta) = c_theta / s_theta.
//   At tan(theta)=1: equal complexity and capacity.
//   Above 1: increasingly rigid. Below 1: increasingly flexible.
//
// Theorem 9.11 (Source-Destination Tradeoff):
//   At fixed p, increasing one necessarily decreases the other.
//   The tradeoff is geometric: perpendicular components.
//
// Theorem 9.12 (Absolute at Fixed Scope):
//   Both larger c_theta and s_theta requires larger p.
//   The tradeoff cannot be circumvented within a given structure.
//
// Theorem 9.17 (Conservation of Organization):
//   p^2 = s_theta^2 + c_theta^2 holds across the moment sequence.
//
// Derives from: theory.mixing.pythagorean
  """
}
