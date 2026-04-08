shape os.test.os.server : os.test {
  type: test
  layer: 4
  desc: "Server shape exists"
  """
assert_true(exists("os.server"), "os.server exists")
assert_eq(dim("os.server", "type"), "system", "server is system type")
"""
}
