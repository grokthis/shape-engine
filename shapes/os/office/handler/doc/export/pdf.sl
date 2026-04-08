shape os.office.handler.doc.export.pdf : os.office.doc {
  type: handler
  layer: 4
  """
// GET /office/doc/{id}/export/pdf → base64 PDF
// scope: id = doc prefix
use "lib.pdf"
use "lib.base64"
let prefix = id + "."
let shapes = shapes_under(id)

// Build block list for pdf_create.
let blocks = []
let i = 0
let n = len(shapes)
while i < n {
  let sid = at(shapes, i)
  let i = i + 1
  if !starts_with(sid, prefix) { continue }
  if dim(sid, "type") != "block" { continue }
  let bt = default(dim(sid, "block_type"), "paragraph")

  // Collect run text.
  let text = ""
  let j = 0
  while j < n {
    let rid = at(shapes, j)
    let j = j + 1
    if !starts_with(rid, sid + ".") { continue }
    if dim(rid, "type") != "run" { continue }
    let text = text + content(rid)
  }
  let blocks = append(blocks, [bt, text])
}

print(base64_encode(pdf_create(blocks)))
"""
}
