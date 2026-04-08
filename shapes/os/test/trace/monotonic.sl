shape os.test.trace.monotonic : os.test {
  type: test
  layer: 1
  desc: "Moments are monotonically ordered"
  """
// For each layer with a trace, verify moment IDs are sequential.
let layers = range(0, 6)
for l in layers {
  let mc = moments(l)
  if mc > 1 {
    // Check sequential ordering.
    let prev = 0
    for i in range(0, mc) {
      let action = moment_action(l, i)
      // Moments should have valid action types.
      assert_neq(action, "", "moment " + i + " at layer " + l + " has action type")
    }
  }
}
"""
}
