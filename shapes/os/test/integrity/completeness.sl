shape os.test.integrity.completeness : os.test {
  type: test
  layer: 4
  desc: "All OS subsystems exist"
  """
let subsystems = split("os.shell,os.config,os.session,os.server,os.render,os.test", ",")
for ss in subsystems {
  assert_true(exists(ss), "subsystem exists: " + ss)
}
"""
}
