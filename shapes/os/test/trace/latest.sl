shape os.test.trace.latest : os.test {
  type: test
  layer: 1
  desc: "Core shapes are at latest version on execution branch"
  """
// Key structural shapes should be at their latest version.
let core = split("os,engine,shape,os.shell,os.config", ",")
for id in core {
  if exists(id) {
    let latest = is_latest(id)
    assert_true(latest, "shape is at latest version: " + id)
  }
}
"""
}
