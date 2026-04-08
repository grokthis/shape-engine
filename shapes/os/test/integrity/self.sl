shape os.test.integrity.self : os.test {
  type: test
  layer: 4
  desc: "Test suite can test itself"
  """
// The test framework shapes exist.
assert_true(exists("os.test"), "test root exists")
assert_true(exists("os.shell.cmd.test"), "test command exists")
assert_eq(dim("os.shell.cmd.test", "type"), "exec", "test command is exec")

// Test shapes have required dimensions.
let suites = children("os.test")
let test_count = 0
for s in suites {
  if s != "result" && s != "history" {
    let tests = children("os.test." + s)
    for t in tests {
      let full = "os.test." + s + "." + t
      assert_eq(dim(full, "type"), "test", "test shape has type=test: " + full)
      assert_neq(dim(full, "desc"), "", "test shape has desc: " + full)
      set test_count = test_count + 1
    }
  }
}
assert_gt(test_count, 20, "test suite has > 20 tests (got " + test_count + ")")
"""
}
