shape os.container.stop : os.container {
  type: exec
  layer: 4
  """
// container stop <id> [--timeout <seconds>]
//
// Stop a running container. Sends graceful shutdown signal
// to the top layer, waits for exit, then checkpoints state.
//
// If --timeout expires before graceful shutdown, force-kills.

let id = arg0
let cid = "os.container.instances." + id

if !exists(cid) {
  print("Error: container " + id + " not found")
  flag
}

let status = dim(cid, "status")
if status != "running" {
  print("Error: container " + id + " is not running (status: " + status + ")")
  flag
}

set_dim(cid, "status", "stopped")
print("Container " + id + " stopped")
  """
}
