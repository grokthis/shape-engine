shape os.test.trace.branch_state : os.test {
  type: test
  layer: 1
  desc: "Active branch is valid for all layers"
  """
let layers = range(0, 6)
for l in layers {
  let mc = moments(l)
  if mc > 0 {
    let active = trace_active_branch(l)
    // Active branch should be "" (main) or a valid branch name.
    // If it's not empty, the branch should exist.
    if active != "" {
      let branches = trace_branches(l)
      let found = false
      for b in branches {
        if b == active {
          set found = true
        }
      }
      assert_true(found, "active branch exists at layer " + l + ": " + active)
    }
  }
}
"""
}
