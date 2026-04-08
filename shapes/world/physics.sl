// Physics: simulation as wave propagation.
//
// Gravity IS a force shape that propagates to all bodies.
// Collision IS a contact shape that resolves by the laws of coherence.
// A rigid body IS a shape with mass, velocity, and position.
// Physics stepping IS one tick of wave propagation through all bodies.
//
// The physics engine doesn't simulate. It propagates. Same mechanism
// as the shape engine's wave propagation through dependents.
// A force IS a wave. A collision IS a contact resolution.
// Conservation of momentum IS Law 2 (conservation).
// Objects can't overlap IS Law 3 (consistency).

shape world.physics : world {
  type: system
  layer: 5
  "Physics. Forces, collisions, constraints. All wave propagation."
}

shape world.physics.body : world.physics {
  type: data
  layer: 5
  """
// A rigid body.
// Dimensions:
//   position: "x,y,z"
//   velocity: "vx,vy,vz"
//   mass: number (0 = static/infinite mass)
//   restitution: bounciness (0-1)
//   shape: "sphere,radius" or "box,hx,hy,hz"
"""
}

shape world.physics.step : world.physics {
  type: exec
  layer: 5
  """
// Advance physics by one timestep.
// dt: time step in milliseconds.
//
// For each body:
//   1. Apply gravity: velocity.y -= 9.81 * dt
//   2. Integrate: position += velocity * dt
//   3. Detect collisions (ground plane at y=0 for now)
//   4. Resolve: reflect velocity, apply restitution
//
// This IS one tick of wave propagation.
// Gravity IS a wave from the ground to all bodies.
// Collision IS a contact wave between two bodies.

let bodies = children("world.physics.body")
let gravity = 10  // simplified, integer

for name in bodies {
  let bid = "world.physics.body." + name
  let pos = dim(bid, "position")
  let vel = dim(bid, "velocity")
  let mass = to_int(dim(bid, "mass"))
  let bounce = to_int(dim(bid, "restitution"))

  if mass > 0 {
    let pp = split(pos, ",")
    let vp = split(vel, ",")
    let px = to_int(index(pp, 0))
    let py = to_int(index(pp, 1))
    let pz = to_int(index(pp, 2))
    let vx = to_int(index(vp, 0))
    let vy = to_int(index(vp, 1))
    let vz = to_int(index(vp, 2))

    // Gravity.
    set vy = vy - gravity * dt / 1000

    // Integrate.
    set px = px + vx * dt / 1000
    set py = py + vy * dt / 1000
    set pz = pz + vz * dt / 1000

    // Ground collision (y=0 plane).
    if py < 0 {
      set py = 0
      set vy = 0 - vy * bounce / 100
    }

    set_dim(bid, "position", to_string(px) + "," + to_string(py) + "," + to_string(pz))
    set_dim(bid, "velocity", to_string(vx) + "," + to_string(vy) + "," + to_string(vz))
  }
}
"""
}
