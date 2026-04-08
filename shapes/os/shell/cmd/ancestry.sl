shape os.shell.cmd.ancestry {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("ancestry: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let chain = ancestry(id)
    let d = depth(id)
    print(id + " (depth " + d + ")")
    print("")
    let path = id
    for ancestor in chain {
      let name = if_val(ancestor == "", "/", ancestor)
      let t = ""
      if exists(ancestor) {
        set t = " [" + dim(ancestor, "type") + "]"
      }
      print("  " + name + t)
    }
  }
}
"""
}
