shape os.test.law.reference : os.test {
  type: test
  layer: 0
  desc: "All references close or point to invariants (Law 1)"
  """
// Law 1: No dangling references. validate() checks all deps.
let result = validate()
assert_true(!contains(result, "INCOHERENT"), "all references resolve: " + result)
"""
}
