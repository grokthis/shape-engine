shape os.test.lang.expr : os.test {
  type: test
  layer: 3
  desc: "Expressions evaluate correctly"
  """
assert_eq(1 + 2, 3, "1 + 2 = 3")
assert_eq("hello" + " " + "world", "hello world", "string concat")
assert_true(1 == 1, "equality")
assert_true(1 != 2, "inequality")
assert_true(true && true, "logical and")
assert_true(true || false, "logical or")
"""
}
