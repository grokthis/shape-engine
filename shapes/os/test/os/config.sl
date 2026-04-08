shape os.test.os.config : os.test {
  type: test
  layer: 4
  desc: "Config shapes exist and have valid references"
  """
assert_true(exists("os.config"), "os.config exists")
assert_true(exists("os.config.desktop.theme"), "theme config exists")
assert_true(exists("os.config.desktop.wm"), "WM config exists")

// Theme reference should point to an existing theme shape.
let theme_ref = content("os.config.desktop.theme")
assert_neq(theme_ref, "", "theme config has reference")
assert_true(exists(theme_ref), "theme reference resolves: " + theme_ref)

// WM reference should point to an existing WM shape.
let wm_ref = content("os.config.desktop.wm")
assert_neq(wm_ref, "", "WM config has reference")
// WM prefix should have style and script children.
assert_true(exists(wm_ref + ".style"), "WM has style: " + wm_ref + ".style")
assert_true(exists(wm_ref + ".script"), "WM has script: " + wm_ref + ".script")
"""
}
