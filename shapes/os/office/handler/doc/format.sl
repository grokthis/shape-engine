shape os.office.handler.doc.format : os.office.doc {
  type: handler
  layer: 4
  """
// POST /office/doc/{id}/format → apply formatting to a run
// scope: format_run_id, format_dims (comma-sep "key=value" pairs)
let pairs = split(format_dims, ",")
let i = 0
while i < len(pairs) {
  let pair = at(pairs, i)
  let i = i + 1
  let kv = split(pair, "=")
  if len(kv) == 2 {
    set_dim(format_run_id, at(kv, 0), at(kv, 1))
  }
}
print("{\"status\":\"ok\"}")
"""
}
