shape os.container.rm : os.container {
  type: exec
  layer: 4
  """
// container rm <id> [--force / -f]
//
// Remove a stopped container. With --force, stop and remove.

let id = arg0
let cid = "os.container.instances." + id

if !exists(cid) {
  print("Error: container " + id + " not found")
  flag
}

let status = dim(cid, "status")
if status == "running" {
  if has_flag("force") || has_flag("f") {
    set_dim(cid, "status", "stopped")
  } else {
    print("Error: container " + id + " is running. Use --force to stop and remove.")
    flag
  }
}

// Remove container shape and all child shapes
let kids = children(cid)
for kid in kids {
  rm(cid + "." + kid)
}
rm(cid)
print("Container " + id + " removed")
  """
}
