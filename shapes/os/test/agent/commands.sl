shape os.test.agent.commands : os.test {
  type: test
  layer: 3
  desc: "Agent/event shell commands exist"
  """
assert_true(exists("os.shell.cmd.agent"), "agent command exists")
assert_true(exists("os.shell.cmd.event"), "event command exists")
assert_true(exists("os.shell.cmd.notify"), "notify command exists")
assert_true(exists("os.shell.cmd.clip"), "clip command exists")
"""
}
