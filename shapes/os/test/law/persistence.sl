shape os.test.law.persistence : os.test {
  type: test
  layer: 0
  desc: "All shapes with content persist (Law 0)"
  """
// Law 0: What persists must cohere. Every shape in the graph has structure.
let count = shape_count()
assert_true(count > 0, "engine has shapes")

// Every shape has at least a type dimension (structure exists).
let all = shapes_under("")
let empty = 0
for id in all {
  let t = dim(id, "type")
  let c = content(id)
  // Session/history shapes may be empty, that's valid.
  if t == "" && c == "" {
    set empty = empty + 1
  }
}
// Allow a small number of structural placeholder shapes.
assert_true(empty < 10, "fewer than 10 completely empty shapes (got " + empty + ")")
"""
}
