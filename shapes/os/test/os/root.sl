shape os.test.os.root : os.test {
  type: test
  layer: 4
  desc: "OS root shape exists with correct structure"
  """
assert_true(exists("os"), "os root exists")
assert_eq(dim("os", "type"), "system", "os type is system")
assert_eq(layer("os"), 4, "os is layer 4")
"""
}
