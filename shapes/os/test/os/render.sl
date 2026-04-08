shape os.test.os.render : os.test {
  type: test
  layer: 4
  desc: "Render shapes exist for all apps"
  """
// Terminal renderer.
assert_true(exists("os.render.terminal.style"), "terminal style exists")
assert_true(exists("os.render.terminal.script"), "terminal script exists")
// Settings renderer.
assert_true(exists("os.render.settings.style"), "settings style exists")
assert_true(exists("os.render.settings.script"), "settings script exists")
// Editor renderer.
assert_true(exists("os.render.editor.style"), "editor style exists")
assert_true(exists("os.render.editor.script"), "editor script exists")
"""
}
