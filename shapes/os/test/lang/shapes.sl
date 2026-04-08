shape os.test.lang.shapes : os.test {
  type: test
  layer: 3
  desc: "Shape I/O builtins work"
  """
assert_neq(content("os"), "", "content reads shape")
assert_neq(dim("os", "type"), "", "dim reads dimension")
assert_true(exists("os"), "exists returns true for existing")
assert_true(!exists("nonexistent.xyz"), "exists returns false for missing")
assert_gt(shape_count(), 0, "shape_count > 0")
"""
}
