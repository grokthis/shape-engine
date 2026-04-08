shape os.shell.cmd.open {
  type: exec
  layer: 4
  """
if arg0 == "" {
  navigate("/")
} else if arg0 == "desktop" {
  navigate("/desktop")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    // Try as a prefix tree
    navigate("/tree/" + id)
  } else {
    navigate("/s/" + id)
  }
}
"""
}
