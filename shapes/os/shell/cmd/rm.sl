shape os.shell.cmd.rm {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("rm: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let dt = dependents(id)
    if len(dt) > 0 {
      print("rm: " + id + " has " + len(dt) + " dependents (Law 2)")
    } else {
      remove(id)
      print("removed: " + id)
    }
  }
}
"""
}
