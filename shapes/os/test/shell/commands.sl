shape os.test.shell.commands : os.test {
  type: test
  layer: 4
  desc: "All shell commands exist as exec shapes"
  """
let cmds = split("pwd,cd,ls,tree,find,grep,cat,info,mkdir,rm,cp,mv,echo,edit,deps,dependents,wave,validate,status,tick,trace,env,export,history,alias,clear,config,help,run,open,ancestry,test,whoami,login,account,audit,agent,event,notify,clip,ask", ",")
for cmd in cmds {
  let id = "os.shell.cmd." + cmd
  assert_true(exists(id), "command exists: " + cmd)
  assert_eq(dim(id, "type"), "exec", "command is exec type: " + cmd)
}
"""
}
