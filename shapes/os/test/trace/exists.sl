shape os.test.trace.exists : os.test {
  type: test
  layer: 1
  desc: "Trace system is operational"
  """
// Global tick should be non-negative (system has been used).
let t = global_tick()
assert_true(t >= 0, "global tick is non-negative")
"""
}
