shape os.test.wm.single_handlers : os.test {
  type: test
  layer: 4
  desc: "Floating WM has no duplicate document event handlers"
  """
let script = content("os.wm.floating.script")

// Count document-level mouseup handlers.
let mouseup_parts = split(script, "document.addEventListener('mouseup'")
assert_eq(len(mouseup_parts) - 1, "1", "exactly 1 document mouseup handler")

// Count document-level keydown handlers.
let keydown_parts = split(script, "document.addEventListener('keydown'")
assert_eq(len(keydown_parts) - 1, "1", "exactly 1 document keydown handler")

// Count document-level mousemove handlers.
let mousemove_parts = split(script, "document.addEventListener('mousemove'")
assert_eq(len(mousemove_parts) - 1, "2", "exactly 2 document mousemove handlers (drag + snap)")
"""
}
