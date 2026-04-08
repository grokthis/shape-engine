shape os.handler.api.status {
  type: handler
  layer: 4
  """
let sc = shape_count()
let tk = global_tick()
let result = map_new()
set result = map_set(result, "shapes", sc)
set result = map_set(result, "tick", tk)
set result = map_set(result, "status", "ok")
print(json_encode(result))
"""
}
