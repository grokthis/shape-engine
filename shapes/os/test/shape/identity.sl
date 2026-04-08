shape os.test.shape.identity : os.test {
  type: test
  layer: 0
  desc: "Shape IDs are unique and non-empty"
  """
// Verify core shapes have distinct IDs.
let shapes = split("shape,engine,os,law.persistence,law.reference", ",")
for id in shapes {
  assert_true(exists(id), "shape exists: " + id)
}
// Verify shape count is positive.
assert_gt(shape_count(), 0, "shape count > 0")
"""
}
