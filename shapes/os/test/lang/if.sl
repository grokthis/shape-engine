shape os.test.lang.if : os.test {
  type: test
  layer: 3
  desc: "Conditionals work"
  """
let result = ""
if true {
  set result = "yes"
} else {
  set result = "no"
}
assert_eq(result, "yes", "if true branch")

if false {
  set result = "wrong"
} else {
  set result = "right"
}
assert_eq(result, "right", "if false branch")
"""
}
