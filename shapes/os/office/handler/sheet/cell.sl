shape os.office.handler.sheet.cell : os.office.sheet {
  type: handler
  layer: 4
  """
// POST /office/sheet/{id}/cell → create/update cell shape
// scope: id = sheet prefix, cell = cell ref (e.g. "A1"), value, format, formula
use "lib.json"
let cell_id = id + "." + cell
let fmt = default(format, "general")
let cnt = value

add_shape(cell_id, "cell", cnt)
set_dim(cell_id, "col", substring(cell, 0, 1))
set_dim(cell_id, "row", substring(cell, 1))
set_dim(cell_id, "format", fmt)
add_dep(cell_id, id)

if formula != "" {
  set_content(cell_id, formula)
  set_dim(cell_id, "format", "formula")
}

print("{\"status\":\"ok\",\"cell\":\"" + json_escape(cell_id) + "\"}")
"""
}
