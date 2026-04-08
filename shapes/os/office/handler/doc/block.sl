shape os.office.handler.doc.block : os.office.doc {
  type: handler
  layer: 4
  """
// POST /office/doc/{id}/block → add/edit block
// scope: id = doc prefix, block_type, order, block_content
use "lib.json"
let bid = id + ".b." + order
add_shape(bid, "block", "")
set_dim(bid, "block_type", block_type)
set_dim(bid, "order", order)
add_dep(bid, id)

// Add default run if content provided.
if block_content != "" {
  let rid = bid + ".r.001"
  add_shape(rid, "run", block_content)
  add_dep(rid, bid)
}

print("{\"status\":\"ok\",\"block\":\"" + json_escape(bid) + "\"}")
"""
}
