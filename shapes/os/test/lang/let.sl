shape os.test.lang.let : os.test {
  type: test
  layer: 3
  desc: "Variable binding works"
  """
let x = 42
assert_eq(x, 42, "let binding")
set x = 99
assert_eq(x, 99, "set updates binding")
let s = "hello"
assert_eq(len(s), 5, "string length")
"""
}
