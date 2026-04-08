// Scene graph: spatial hierarchy of shapes.
//
// The scene IS a tree of nodes. Each node IS a shape with:
//   - transform: position, rotation, scale (mat4)
//   - children: other scene nodes
//   - mesh: geometry (vertices + indices)
//   - material: color, texture, shader
//
// Rendering the scene IS walking the tree and propagating transforms.
// A parent's transform IS multiplied into every child's transform.
// This IS wave propagation through the scene graph.

shape world.scene : world {
  type: system
  layer: 5
  deps: [hardware.gpu.pipeline]
  "Scene graph. Spatial hierarchy. Transform propagation."
}

shape world.scene.node : world.scene {
  type: exec
  layer: 5
  """
// A scene node. The building block of worlds.
//
// Dimensions:
//   position: "x,y,z"
//   rotation: "rx,ry,rz" (Euler angles, degrees)
//   scale: "sx,sy,sz"
//   mesh: shape ID of the mesh
//   material: shape ID of the material
//   visible: "true" or "false"
//
// Children are shapes that depend on this node.
// Moving the parent moves all children (wave propagation).
//
// The node IS its transform. The transform IS the relationship
// between the node and its parent. The scene graph IS the
// composition of all these relationships.
"""
}

shape world.scene.mesh : world.scene {
  type: data
  layer: 5
  """
// A mesh: vertices + triangles.
//
// Vertices: shapes under mesh_id.v.N with content "x,y,z"
// Triangles: shapes under mesh_id.t.N with content "v0,v1,v2"
//   where v0,v1,v2 are vertex indices.
//
// Primitive meshes:
//   cube: 8 vertices, 12 triangles
//   plane: 4 vertices, 2 triangles
//   sphere: N*M vertices, 2*N*M triangles (UV sphere)
"""
}

shape world.scene.mesh.cube : world.scene.mesh {
  type: exec
  layer: 5
  """
// Create a unit cube mesh as shapes.
// 8 vertices, 12 triangles (2 per face).

let id = mesh_id

// Vertices: corners of [-1,1] cube.
add_shape(id + ".v.0", "vertex", "-1,-1,-1", 5)
add_shape(id + ".v.1", "vertex", "1,-1,-1", 5)
add_shape(id + ".v.2", "vertex", "1,1,-1", 5)
add_shape(id + ".v.3", "vertex", "-1,1,-1", 5)
add_shape(id + ".v.4", "vertex", "-1,-1,1", 5)
add_shape(id + ".v.5", "vertex", "1,-1,1", 5)
add_shape(id + ".v.6", "vertex", "1,1,1", 5)
add_shape(id + ".v.7", "vertex", "-1,1,1", 5)

// Triangles: 2 per face, 6 faces = 12 triangles.
// Front face (z=-1)
add_shape(id + ".t.0", "triangle", "0,1,2", 5)
add_shape(id + ".t.1", "triangle", "0,2,3", 5)
// Back face (z=1)
add_shape(id + ".t.2", "triangle", "5,4,7", 5)
add_shape(id + ".t.3", "triangle", "5,7,6", 5)
// Left face (x=-1)
add_shape(id + ".t.4", "triangle", "4,0,3", 5)
add_shape(id + ".t.5", "triangle", "4,3,7", 5)
// Right face (x=1)
add_shape(id + ".t.6", "triangle", "1,5,6", 5)
add_shape(id + ".t.7", "triangle", "1,6,2", 5)
// Top face (y=1)
add_shape(id + ".t.8", "triangle", "3,2,6", 5)
add_shape(id + ".t.9", "triangle", "3,6,7", 5)
// Bottom face (y=-1)
add_shape(id + ".t.10", "triangle", "4,5,1", 5)
add_shape(id + ".t.11", "triangle", "4,1,0", 5)

print("Created cube: 8 vertices, 12 triangles")
"""
}

shape world.scene.mesh.plane : world.scene.mesh {
  type: exec
  layer: 5
  """
// Create a unit plane mesh (XZ plane, Y=0).
let id = mesh_id
add_shape(id + ".v.0", "vertex", "-1,0,-1", 5)
add_shape(id + ".v.1", "vertex", "1,0,-1", 5)
add_shape(id + ".v.2", "vertex", "1,0,1", 5)
add_shape(id + ".v.3", "vertex", "-1,0,1", 5)
add_shape(id + ".t.0", "triangle", "0,1,2", 5)
add_shape(id + ".t.1", "triangle", "0,2,3", 5)
print("Created plane: 4 vertices, 2 triangles")
"""
}
