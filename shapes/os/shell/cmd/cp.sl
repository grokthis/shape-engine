shape os.shell.cmd.cp {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("cp: need <src> <dst>")
} else if arg1 == "" {
  print("cp: need <dst>")
} else {
  let src = resolve(prefix, arg0)
  let dst = resolve(prefix, arg1)
  if !exists(src) {
    print("shape not found: " + src)
  } else {
    let t = dim(src, "type")
    let c = content(src)
    let l = layer(src)
    add_shape(dst, t, c, l)
    print(src + " -> " + dst)
  }
}
"""
}
