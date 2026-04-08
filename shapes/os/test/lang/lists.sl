shape os.test.lang.lists : os.test {
  type: test
  layer: 3
  desc: "List operations work"
  """
let l = split("c,a,b", ",")
assert_eq(len(l), 3, "list length")
assert_eq(index(l, 0), "c", "index 0")
let sorted = sort_list(l)
assert_eq(index(sorted, 0), "a", "sort_list")
"""
}
