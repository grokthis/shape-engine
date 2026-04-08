shape os.shell.cmd.env {
  type: exec
  layer: 4
  """
let d = dims("os.session.shell.env")
if d == "" {
  print("(no environment variables)")
} else {
  print(d)
}
"""
}
