shape os.test.law.consistency : os.test {
  type: test
  layer: 0
  desc: "No contradictions in contact (Law 3)"
  """
// Law 3: No blocked shapes in a clean system state.
// The validate function checks structural consistency.
let result = validate()
assert_true(!contains(result, "INCOHERENT"), "no structural contradictions")
"""
}
