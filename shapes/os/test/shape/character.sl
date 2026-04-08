shape os.test.shape.character : os.test {
  type: test
  layer: 0
  desc: "Shape character has dimensions and content"
  """
// Every shape has a character with at least type.
let t = dim("shape", "type")
assert_neq(t, "", "shape has type dimension")
let c = content("shape")
assert_neq(c, "", "shape has content")
"""
}
