shape os.office.handler.sheet.data : os.office.sheet {
  type: handler
  layer: 4
  """
// GET /office/sheet/{id}/data → JSON grid
// scope: id = sheet prefix
use "lib.json"
let prefix = id + "."
let shapes = shapes_under(id)

// Read root metadata.
let rows = default(dim(id, "rows"), "100")
let cols = default(dim(id, "cols"), "26")

// Collect cells into JSON.
let cell_json = ""
let first = 1
let i = 0
let n = len(shapes)
while i < n {
  let sid = at(shapes, i)
  let i = i + 1
  if !starts_with(sid, prefix) { continue }
  if dim(sid, "type") != "cell" { continue }
  let ref = substring(sid, len(prefix))
  let val = content(sid)
  let fmt = default(dim(sid, "format"), "general")
  let entry = "\"" + json_escape(ref) + "\":{\"value\":\"" + json_escape(val) + "\",\"format\":\"" + json_escape(fmt) + "\""
  if fmt == "formula" {
    let computed = default(dim(sid, "value"), val)
    let entry = entry + ",\"formula\":\"" + json_escape(val) + "\",\"value\":\"" + json_escape(computed) + "\""
  }
  let entry = entry + "}"
  if first == 0 {
    let cell_json = cell_json + "," + entry
  }
  if first == 1 {
    let cell_json = entry
    let first = 0
  }
}

print("{\"id\":\"" + json_escape(id) + "\",\"rows\":" + rows + ",\"cols\":" + cols + ",\"cells\":{" + cell_json + "}}")
"""
}
