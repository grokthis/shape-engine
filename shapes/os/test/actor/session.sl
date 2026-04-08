shape os.test.actor.session : os.test {
  type: test
  layer: 4
  desc: "Actor can be set and read"
  """
// Set a test actor and verify.
let prev = actor()
set_actor("user.test")
assert_eq(actor(), "user.test", "actor was set")
// Restore.
if prev != "" {
  set_actor(prev)
} else {
  set_actor("")
}
"""
}
