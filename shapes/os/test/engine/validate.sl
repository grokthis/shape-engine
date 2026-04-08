shape os.test.engine.validate : os.test {
  type: test
  layer: 3
  desc: "Engine validates as coherent"
  """
let result = validate()
assert_true(!contains(result, "INCOHERENT"), "engine is coherent: " + result)
"""
}
