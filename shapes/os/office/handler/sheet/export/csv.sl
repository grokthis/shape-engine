shape os.office.handler.sheet.export.csv : os.office.sheet {
  type: handler
  layer: 4
  """
// GET /office/sheet/{id}/export/csv → CSV text
// scope: id = sheet prefix
let prefix = id + "."
let shapes = shapes_under(id)

// Find max row and col.
let max_row = 0
let max_col = 0
let i = 0
let n = len(shapes)
while i < n {
  let sid = at(shapes, i)
  let i = i + 1
  if !starts_with(sid, prefix) { continue }
  if dim(sid, "type") != "cell" { continue }
  let ref = substring(sid, len(prefix))
  let col = ord(at(ref, 0)) - 64
  let row = to_int(substring(ref, 1))
  if row > max_row { let max_row = row }
  if col > max_col { let max_col = col }
}

// Build CSV row by row.
let row = 1
while row <= max_row {
  let line = ""
  let col = 1
  while col <= max_col {
    let ref = chr(col + 64) + to_string(row)
    let cell_id = id + "." + ref
    let val = content(cell_id)
    if contains(val, ",") {
      let val = "\"" + replace(val, "\"", "\"\"") + "\""
    }
    if col > 1 {
      let line = line + ","
    }
    let line = line + val
    let col = col + 1
  }
  print(line)
  let row = row + 1
}
"""
}
