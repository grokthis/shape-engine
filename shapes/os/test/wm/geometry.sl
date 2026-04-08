shape os.test.wm.geometry : os.test {
  type: test
  layer: 4
  desc: "Floating WM persists window geometry to shapes"
  """
let script = content("os.wm.floating.script")
assert_true(contains(script, "saveWindowGeometry"), "geometry save function exists")
assert_true(contains(script, "/desktop/window/geometry"), "geometry API endpoint used")
assert_true(contains(script, "saveWindowGeometryDebounced"), "debounced save exists")
"""
}
