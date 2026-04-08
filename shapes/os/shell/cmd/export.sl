shape os.shell.cmd.export {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("export: need KEY=VALUE")
} else {
  let parts = split(arg0, "=")
  if len(parts) < 2 {
    print("export: need KEY=VALUE")
  } else {
    let key = index(parts, 0)
    let val = index(parts, 1)
    set_dim("os.session.shell.env", key, val)
    print(key + "=" + val)
  }
}
"""
}
