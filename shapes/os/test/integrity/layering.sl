shape os.test.integrity.layering : os.test {
  type: test
  layer: 4
  desc: "Shapes respect layer hierarchy"
  """
// Laws should be layer 0.
let laws = split("law.persistence,law.reference,law.conservation,law.consistency", ",")
for l in laws {
  assert_eq(layer(l), 0, l + " is layer 0")
}
// Engine should be layer 3.
assert_eq(layer("engine"), 3, "engine is layer 3")
// OS should be layer 4.
assert_eq(layer("os"), 4, "os is layer 4")
// Tests should have layer assignments.
assert_eq(layer("os.test"), 4, "os.test is layer 4")
"""
}
