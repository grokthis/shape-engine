shape os.test.engine.layers : os.test {
  type: test
  layer: 3
  desc: "Layer structure is correct"
  """
// Layer 0 shapes (laws).
assert_eq(layer("law.persistence"), 0, "law.persistence is layer 0")
// Layer 3 shapes (engine).
assert_eq(layer("engine"), 3, "engine is layer 3")
// Layer 4 shapes (OS).
assert_eq(layer("os"), 4, "os is layer 4")
"""
}
