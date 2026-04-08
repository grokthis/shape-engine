shape os.test.law.conservation : os.test {
  type: test
  layer: 0
  desc: "No structure from nothing (Law 2)"
  """
// Law 2: Every core system shape has structure (type dimension).
let core_prefixes = split("law,shape,engine,os", ",")
for pfx in core_prefixes {
  assert_true(exists(pfx), "core shape exists: " + pfx)
  let t = dim(pfx, "type")
  assert_neq(t, "", "core shape has type: " + pfx)
}
"""
}
