shape os.test.engine.edit : os.test {
  type: test
  layer: 3
  desc: "Edit creates trace moments"
  """
// Create a test shape, edit it, verify tick advances.
let tick_before = global_tick()
add_shape("os.test._scratch", "test", "before")
set_content("os.test._scratch", "after")
let tick_after = global_tick()
assert_eq(content("os.test._scratch"), "after", "edit updated content")
// Clean up.
remove("os.test._scratch")
"""
}
