shape os.test.shell.identity : os.test {
  type: test
  layer: 4
  desc: "Identity and economy commands exist"
  """
let cmds = split("whoami,login,account,audit", ",")
for cmd in cmds {
  let id = "os.shell.cmd." + cmd
  assert_true(exists(id), "command exists: " + cmd)
  assert_eq(dim(id, "type"), "exec", "command is exec: " + cmd)
}
"""
}
