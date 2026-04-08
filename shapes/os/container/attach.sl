shape os.container.attach : os.container {
  type: exec
  layer: 4
  """
// container attach <id>
//
// Attach stdin/stdout/stderr to a running container.
// Ctrl-C to detach (container keeps running).

let id = arg0
let cid = "os.container.instances." + id

if !exists(cid) {
  print("Error: container " + id + " not found")
  flag
}

let status = dim(cid, "status")
if status != "running" {
  print("Error: container " + id + " is not running")
  flag
}

print("Attached to " + id + ". Ctrl-C to detach.")
// Passthrough: host stdin -> container stdin
//              container stdout -> host stdout
  """
}
