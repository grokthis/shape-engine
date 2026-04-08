shape os.container.exec : os.container {
  type: exec
  layer: 4
  """
// container exec <id> <command> [args...]
//
// Execute a command inside a running container.
// The command runs at the top layer of the container's stack.
//
// Examples:
//   container exec c01 ls
//   container exec c01 cat law.persistence
//   container exec c01 shape-lang "print(1+1)"

let id = arg0
let cmd = arg1
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

// Execute command in container context
print("[" + id + "] $ " + cmd)
// The command is evaluated in the container's shape context.
// Passthrough: output goes to host stdout.
  """
}
