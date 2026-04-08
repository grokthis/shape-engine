shape os.test.actor.moment : os.test {
  type: test
  layer: 4
  desc: "Moment actor field is structurally readable"
  """
// Verify the moment_actor syscall reads the Actor field on moments.
// Actor recording happens when the kernel (engine.Edit) creates trace
// moments. Here we verify the structural read path works.
let layers = range(0, 6)
let total_moments = 0
for l in layers {
  let mc = moments(l)
  set total_moments = total_moments + mc
  for i in range(0, mc) {
    // moment_actor returns "" for moments without an actor (pre-login).
    // The call itself should not error.
    let a = moment_actor(l, i)
    // Actor is either "" or a valid string. Never nil.
    assert_true(a != "nil", "moment actor is never nil at L" + l + " M" + i)
  }
}
// The actor() syscall should work.
let current = actor()
// actor is "" when not logged in, which is fine.
assert_true(current == "" || contains(current, "user"), "actor is empty or user-prefixed")
"""
}
