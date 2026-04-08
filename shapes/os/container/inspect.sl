shape os.container.inspect : os.container {
  type: exec
  layer: 4
  """
// container inspect <id>
//
// Show detailed container state.

let id = arg0
let cid = "os.container.instances." + id

if !exists(cid) {
  print("Error: container " + id + " not found")
  flag
}

print("Container: " + id)
print("====================")
print("Stack:     " + dim(cid, "stack"))
print("Program:   " + dim(cid, "program"))
print("Status:    " + dim(cid, "status"))
print("Cycles:    " + dim(cid, "cycles"))
print("Memory:    " + dim(cid, "memory"))
print("Restart:   " + dim(cid, "restart"))
print("")
print("Mounts:")
let mounts = children(cid + ".mounts")
for m in mounts {
  print("  " + content(cid + ".mounts." + m))
}
print("")
print("Env:")
let envs = children(cid + ".env")
for e in envs {
  print("  " + e + "=" + content(cid + ".env." + e))
}
  """
}
