shape os.office.handler.doc.data : os.office.doc {
  type: handler
  layer: 4
  """
// GET /office/doc/{id}/data → JSON document structure
// scope: id = doc prefix
use "lib.json"
let prefix = id + "."
let shapes = shapes_under(id)
let title = default(dim(id, "title"), "")

// Collect blocks and runs.
let blocks_json = ""
let block_count = 0
let i = 0
let n = len(shapes)
while i < n {
  let sid = at(shapes, i)
  let i = i + 1
  if !starts_with(sid, prefix) { continue }
  let rel = substring(sid, len(prefix))
  let typ = dim(sid, "type")

  // Block shapes: id like prefix.b.NNN
  if typ == "block" {
    let bt = default(dim(sid, "block_type"), "paragraph")
    let order = default(dim(sid, "order"), "000")

    // Collect runs under this block.
    let runs_json = ""
    let run_count = 0
    let j = 0
    while j < n {
      let rid = at(shapes, j)
      let j = j + 1
      if !starts_with(rid, sid + ".") { continue }
      if dim(rid, "type") != "run" { continue }
      let rcnt = content(rid)
      let run_entry = "{\"id\":\"" + json_escape(rid) + "\",\"content\":\"" + json_escape(rcnt) + "\"}"
      if run_count > 0 {
        let runs_json = runs_json + "," + run_entry
      }
      if run_count == 0 {
        let runs_json = run_entry
      }
      let run_count = run_count + 1
    }

    let block_entry = "{\"id\":\"" + json_escape(sid) + "\",\"type\":\"" + json_escape(bt) + "\",\"order\":\"" + json_escape(order) + "\",\"runs\":[" + runs_json + "]}"
    if block_count > 0 {
      let blocks_json = blocks_json + "," + block_entry
    }
    if block_count == 0 {
      let blocks_json = block_entry
    }
    let block_count = block_count + 1
  }
}

print("{\"id\":\"" + json_escape(id) + "\",\"title\":\"" + json_escape(title) + "\",\"blocks\":[" + blocks_json + "]}")
"""
}
