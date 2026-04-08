shape os.test.wm.snap : os.test {
  type: test
  layer: 4
  desc: "Floating WM handles snap in mouseup"
  """
// The floating WM script must exist and contain snap logic.
assert_true(exists("os.wm.floating.script"), "floating WM script exists")
let script = content("os.wm.floating.script")

// Snap functions must be defined.
assert_true(contains(script, "getSnapZone"), "getSnapZone defined")
assert_true(contains(script, "snapRect"), "snapRect defined")
assert_true(contains(script, "snapZone"), "snapZone variable used")

// The mouseup handler must reference snapZone (snap is handled in mouseup).
// Split on mouseup to find handlers, then check the first handler has snap.
let parts = split(script, "addEventListener('mouseup'")
// parts[0] = before first mouseup, parts[1] = first handler body, etc.
let handler_count = len(parts) - 1
assert_eq(handler_count, "1", "exactly 1 mouseup handler (got " + handler_count + ")")

// The single mouseup handler must contain snap logic.
assert_true(contains(parts[1], "snapZone"), "mouseup handler checks snapZone")
assert_true(contains(parts[1], "snapRect"), "mouseup handler calls snapRect")
"""
}
