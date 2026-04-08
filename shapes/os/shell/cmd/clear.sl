shape os.shell.cmd.clear {
  type: exec
  layer: 4
  """
write("\033[2J\033[H")
"""
}
