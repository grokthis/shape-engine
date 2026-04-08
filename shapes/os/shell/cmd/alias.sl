shape os.shell.cmd.alias {
  type: exec
  layer: 4
  """
if arg0 == "" {
  let d = dims("os.session.shell.aliases")
  if d == "" {
    print("(no aliases)")
  } else {
    print(d)
  }
} else {
  let parts = split(arg0, "=")
  if len(parts) < 2 {
    print("alias: need NAME=COMMAND")
  } else {
    let name = index(parts, 0)
    let cmd = index(parts, 1)
    set_dim("os.session.shell.aliases", name, cmd)
    print(name + " -> " + cmd)
  }
}
"""
}
