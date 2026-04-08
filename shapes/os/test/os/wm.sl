shape os.test.os.wm : os.test {
  type: test
  layer: 4
  desc: "Window managers exist with style and script"
  """
let wms = split("tiling,floating", ",")
for w in wms {
  let base = "os.wm." + w
  assert_true(exists(base), "WM exists: " + w)
  assert_true(exists(base + ".style"), "WM has style: " + w)
  assert_true(exists(base + ".script"), "WM has script: " + w)
  assert_neq(content(base + ".style"), "", "WM style has CSS: " + w)
  assert_neq(content(base + ".script"), "", "WM script has JS: " + w)
}
"""
}
