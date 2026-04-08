shape os.shell.cmd.mkdir {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("mkdir: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  add_shape(id, "", "")
  print(id)
}
"""
}
