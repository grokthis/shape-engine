shape os.test.engine.children : os.test {
  type: test
  layer: 3
  desc: "Children enumeration works"
  """
let ch = children("os")
assert_true(len(ch) > 0, "os has children")
// os should have shell, config, session, etc.
let found_shell = false
for c in ch {
  if c == "shell" {
    set found_shell = true
  }
}
assert_true(found_shell, "os has shell child")
"""
}
