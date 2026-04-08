shape os.test.engine.get : os.test {
  type: test
  layer: 3
  desc: "GetShape returns existing shapes"
  """
assert_true(exists("engine"), "engine shape exists")
assert_true(exists("os"), "os shape exists")
assert_true(exists("os.shell"), "os.shell exists")
assert_true(!exists("nonexistent.shape.id.xyz"), "nonexistent shape does not exist")
"""
}
