shape os.container.commit : os.container {
  type: exec
  layer: 4
  """
// container commit <id> <name>
//
// Save a container's current state as a named shape.
// The committed shape includes: stack config, memory snapshot,
// register state, program, mounts, env. Everything needed
// to resume exactly where the container stopped.
//
// Unlike Docker images: no layers, no diffs, no registry.
// A committed container is a shape. It lives in the graph.
// It can be deps'd, edited, propagated. It IS the image.
//
// Examples:
//   container commit c01 my-app-v1
//   container run shape-engine my-app-v1        # resume from snapshot
//   container commit c02 dev-environment
//   container run riscv64 dev-environment       # different stack, same state

let id = arg0
let name = arg1
let cid = "os.container.instances." + id

if !exists(cid) {
  print("Error: container " + id + " not found")
  flag
}

let dst = "os.container.images." + name
add_shape(dst, "container-image", content(cid), 4)

// Copy all dimensions
set_dim(dst, "stack", dim(cid, "stack"))
set_dim(dst, "program", dim(cid, "program"))
set_dim(dst, "memory", dim(cid, "memory"))
set_dim(dst, "cycles", dim(cid, "cycles"))
set_dim(dst, "committed_from", id)

print("Committed " + id + " as " + name)
  """
}
