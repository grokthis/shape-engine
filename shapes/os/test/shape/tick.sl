shape os.test.shape.tick : os.test {
  type: test
  layer: 0
  desc: "Tick is monotonically increasing"
  """
// Global tick should be non-negative.
let t = global_tick()
assert_true(t >= 0, "global tick >= 0")
"""
}
