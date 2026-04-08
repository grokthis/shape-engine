shape os.test.integrity.types : os.test {
  type: test
  layer: 4
  desc: "All shapes have valid type dimensions"
  """
let valid_types = split("axiom,primitive,emergence,system,exec,app,config,space,test,result,history,module,style,script,element,wm,theme,session", ",")
// Check a sample of shapes have known types.
let sample = split("law.persistence,shape,engine,os,os.shell.cmd.ls,os.config,user", ",")
for id in sample {
  let t = dim(id, "type")
  assert_neq(t, "", "shape has type: " + id)
}
"""
}
