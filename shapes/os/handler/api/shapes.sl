shape os.handler.api.shapes {
  type: handler
  layer: 4
  """
let prefix = q_prefix
let result = []
let all = shapes_under(prefix)
for s in all {
  let m = shape_to_map(s)
  set result = append(result, m)
}
print(json_encode(result))
"""
}
