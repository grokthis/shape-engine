shape os.test.os.themes : os.test {
  type: test
  layer: 4
  desc: "All themes exist and contain CSS"
  """
let themes = split("tokyo-night,solarized-dark,dracula,nord,gruvbox,catppuccin", ",")
for t in themes {
  let id = "os.theme." + t
  assert_true(exists(id), "theme exists: " + t)
  let css = content(id)
  assert_true(contains(css, ":root"), "theme has :root CSS: " + t)
  assert_true(contains(css, "--bg"), "theme has --bg var: " + t)
}
"""
}
