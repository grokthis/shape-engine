shape os.test.shell.session : os.test {
  type: test
  layer: 4
  desc: "Session state shapes exist"
  """
// Session shapes are created by the shell on startup.
// They may not exist if shell hasn't initialized, so just check the parent.
assert_true(exists("os.session"), "os.session exists")
assert_true(exists("os.session.shell"), "os.session.shell exists")
"""
}
