shape os.test.engine.shapes : os.test {
  type: test
  layer: 3
  desc: "Engine contains expected shape count"
  """
let count = shape_count()
// OS should have many shapes (laws + engine + os + shell + tests).
assert_gt(count, 50, "engine has > 50 shapes (got " + count + ")")
"""
}
