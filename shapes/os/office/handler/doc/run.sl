shape os.office.handler.doc.run : os.office.doc {
  type: handler
  layer: 4
  """
// POST /office/doc/{id}/run → add/edit run
// scope: id = doc prefix, block (e.g. "b.001"), run_id (e.g. "r.001"), run_content
use "lib.json"
let rid = id + "." + block + "." + run_id
add_shape(rid, "run", run_content)
add_dep(rid, id + "." + block)

print("{\"status\":\"ok\",\"run\":\"" + json_escape(rid) + "\"}")
"""
}
