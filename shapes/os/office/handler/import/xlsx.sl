shape os.office.handler.import.xlsx : os.office {
  type: handler
  layer: 4
  """
// POST /office/import (xlsx) → import shapes from base64 XLSX
// scope: prefix, file_data (base64)
use "lib.zip"
use "lib.base64"
use "lib.json"
let entries = zip_extract(base64_decode(file_data))

// Find sheet1.xml.
let sheet_content = ""
let i = 0
while i < len(entries) {
  let entry = at(entries, i)
  let i = i + 1
  let name = at(entry, 0)
  if contains(name, "sheet1.xml") {
    let sheet_content = at(entry, 1)
  }
}

if sheet_content == "" {
  print("{\"error\":\"no sheet1.xml found\"}")
}

if sheet_content != "" {
  // Create sheet root.
  add_shape(prefix, "sheet", "")
  set_dim(prefix, "title", "Imported")

  // Parse cells from XML (simple: find <c r="XX"> and <v> or <t> elements).
  let parts = split(sheet_content, "<c ")
  let j = 1
  while j < len(parts) {
    let part = at(parts, j)
    let j = j + 1
    // Extract ref: r="XX"
    let ref_start = index_of(part, "r=\"")
    if ref_start >= 0 {
      let ref_rest = substring(part, ref_start + 3)
      let ref_end = index_of(ref_rest, "\"")
      let ref = substring(ref_rest, 0, ref_end)

      // Extract value from <v>...</v> or <t>...</t>.
      let val = ""
      let v_start = index_of(part, "<v>")
      if v_start >= 0 {
        let v_rest = substring(part, v_start + 3)
        let v_end = index_of(v_rest, "</v>")
        let val = substring(v_rest, 0, v_end)
      }
      let t_start = index_of(part, "<t>")
      if t_start >= 0 {
        let t_rest = substring(part, t_start + 3)
        let t_end = index_of(t_rest, "</t>")
        let val = substring(t_rest, 0, t_end)
      }

      if ref != "" {
        let cell_id = prefix + "." + ref
        add_shape(cell_id, "cell", val)
        set_dim(cell_id, "col", substring(ref, 0, 1))
        set_dim(cell_id, "row", substring(ref, 1))
        set_dim(cell_id, "format", "general")
        add_dep(cell_id, prefix)
      }
    }
  }

  print("{\"status\":\"ok\",\"prefix\":\"" + json_escape(prefix) + "\"}")
}
"""
}
