shape os.shell.cmd.run {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("run: need shape-lang source or shape-id")
} else {
  if exists(resolve(prefix, arg0)) {
    let src = content(resolve(prefix, arg0))
    print("(executing " + resolve(prefix, arg0) + ")")
  }
}
"""
}
