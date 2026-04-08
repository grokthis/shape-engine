shape os.test.shell.nav : os.test {
  type: test
  layer: 4
  desc: "Navigation shapes exist (pwd, cd, ls)"
  """
// Verify navigation commands have content (shape-lang source).
assert_neq(content("os.shell.cmd.pwd"), "", "pwd has source")
assert_neq(content("os.shell.cmd.cd"), "", "cd has source")
assert_neq(content("os.shell.cmd.ls"), "", "ls has source")
assert_neq(content("os.shell.cmd.tree"), "", "tree has source")
"""
}
