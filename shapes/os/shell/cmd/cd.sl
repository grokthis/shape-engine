shape os.shell.cmd.cd {
  type: exec
  layer: 4
  """
let target = default(arg0, "~")
let resolved = resolve(prefix, target)
set_content("os.session.shell.prefix", resolved)
"""
}
