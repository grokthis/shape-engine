// Entity: things in the world.
//
// An entity IS a shape with components. Components are child shapes.
// Entity-component-system IS the shape graph:
//   Entity = parent shape
//   Component = child shapes (position, mesh, physics, script, etc.)
//   System = wave propagation through all entities with a given component
//
// The ECS pattern IS the shape pattern. They're the same thing.
// The shape engine IS an ECS engine. We didn't add ECS. It was always there.

shape world.entity : world {
  type: system
  layer: 5
  "Entities. Characters, objects, particles. Components are shapes."
}

shape world.entity.create : world.entity {
  type: exec
  layer: 5
  """
// Create an entity with components.
// name: entity name (becomes world.entity.NAME)
// components: comma-separated list of component types.
//
// Each component type creates a child shape:
//   transform -> position, rotation, scale
//   mesh -> geometry reference
//   physics -> rigid body
//   script -> behavior (shape-lang code)
//   light -> point/directional/spot
//   camera -> projection + view
//   audio -> sound source
//   particle -> emitter settings

let eid = "world.entity." + name
add_shape(eid, "entity", "", 5)

let comps = split(components, ",")
for comp in comps {
  let cname = trim(comp)
  if cname == "transform" {
    add_shape(eid + ".transform", "component", "", 5)
    set_dim(eid + ".transform", "position", "0,0,0")
    set_dim(eid + ".transform", "rotation", "0,0,0")
    set_dim(eid + ".transform", "scale", "1,1,1")
  } else if cname == "mesh" {
    add_shape(eid + ".mesh", "component", "", 5)
    set_dim(eid + ".mesh", "ref", "")
  } else if cname == "physics" {
    add_shape(eid + ".physics", "component", "", 5)
    set_dim(eid + ".physics", "velocity", "0,0,0")
    set_dim(eid + ".physics", "mass", "1")
    set_dim(eid + ".physics", "restitution", "50")
  } else if cname == "light" {
    add_shape(eid + ".light", "component", "", 5)
    set_dim(eid + ".light", "type", "point")
    set_dim(eid + ".light", "color", "255,255,255")
    set_dim(eid + ".light", "intensity", "100")
  } else if cname == "camera" {
    add_shape(eid + ".camera", "component", "", 5)
    set_dim(eid + ".camera", "fov", "60")
    set_dim(eid + ".camera", "near", "1")
    set_dim(eid + ".camera", "far", "1000")
  } else if cname == "script" {
    add_shape(eid + ".script", "component", "", 5)
  } else if cname == "audio" {
    add_shape(eid + ".audio", "component", "", 5)
    set_dim(eid + ".audio", "ref", "")
    set_dim(eid + ".audio", "playing", "false")
  } else {
    add_shape(eid + "." + cname, "component", "", 5)
  }
}

print("Created entity: " + eid + " with " + to_string(len(comps)) + " components")
"""
}
