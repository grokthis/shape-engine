shape os.test.trace.timestamps : os.test {
  type: test
  layer: 1
  desc: "Wall clock timestamps are present on moments"
  """
// Any layer with moments should have timestamps.
let layers = range(0, 6)
for l in layers {
  let mc = moments(l)
  if mc > 0 {
    let ts = moment_ts(l, 0)
    assert_neq(ts, "", "first moment at layer " + l + " has timestamp")
    // Timestamp should look like ISO format.
    assert_true(contains(ts, "T"), "timestamp is ISO format at layer " + l)
  }
}
"""
}
