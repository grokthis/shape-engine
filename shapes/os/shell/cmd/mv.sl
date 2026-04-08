shape os.shell.cmd.mv {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("mv: need <src> <dst>")
} else if arg1 == "" {
  print("mv: need <dst>")
} else {
  let src = resolve(prefix, arg0)
  let dst = resolve(prefix, arg1)
  if !exists(src) {
    print("shape not found: " + src)
  } else {
    let dt = dependents(src)
    if len(dt) > 0 {
      print("mv: " + src + " has dependents, cannot move (Law 2)")
    } else {
      let t = dim(src, "type")
      let c = content(src)
      let l = layer(src)
      add_shape(dst, t, c, l)
      remove(src)
      print(src + " -> " + dst)
    }
  }
}
"""
}
