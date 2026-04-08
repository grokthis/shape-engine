shape os.test.lang.for : os.test {
  type: test
  layer: 3
  desc: "Loops work"
  """
let sum = 0
for i in range(1, 5) {
  set sum = sum + i
}
assert_eq(sum, 10, "for loop sum 1..4 = 10")
"""
}
