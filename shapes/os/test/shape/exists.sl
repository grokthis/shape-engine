shape os.test.shape.exists : os.test {
  type: test
  layer: 0
  desc: "Shape primitive exists in the graph"
  """
assert_true(exists("shape"), "shape primitive exists")
assert_true(exists("shape.character"), "shape.character exists")
assert_true(exists("shape.structure"), "shape.structure exists")
assert_true(exists("shape.tick"), "shape.tick exists")
"""
}
