shape os.office.handler.doc.export.docx : os.office.doc {
  type: handler
  layer: 4
  """
// GET /office/doc/{id}/export/docx → base64 DOCX (ZIP of XML)
// scope: id = doc prefix
use "lib.xml"
use "lib.zip"
use "lib.base64"
let prefix = id + "."
let shapes = shapes_under(id)

// Build document body XML from blocks and runs.
let body_xml = ""
let i = 0
let n = len(shapes)
while i < n {
  let sid = at(shapes, i)
  let i = i + 1
  if !starts_with(sid, prefix) { continue }
  if dim(sid, "type") != "block" { continue }
  let bt = default(dim(sid, "block_type"), "paragraph")

  // Collect runs.
  let runs_xml = ""
  let j = 0
  while j < n {
    let rid = at(shapes, j)
    let j = j + 1
    if !starts_with(rid, sid + ".") { continue }
    if dim(rid, "type") != "run" { continue }
    let txt = xml_escape(content(rid))
    let rpr = ""
    if dim(rid, "bold") == "true" { let rpr = rpr + "<w:b/>" }
    if dim(rid, "italic") == "true" { let rpr = rpr + "<w:i/>" }
    if rpr != "" { let rpr = "<w:rPr>" + rpr + "</w:rPr>" }
    let runs_xml = runs_xml + "<w:r>" + rpr + "<w:t xml:space=\"preserve\">" + txt + "</w:t></w:r>"
  }

  let ppr = ""
  if bt == "heading" {
    let level = default(dim(sid, "level"), "1")
    let ppr = "<w:pPr><w:pStyle w:val=\"Heading" + level + "\"/></w:pPr>"
  }
  let body_xml = body_xml + "<w:p>" + ppr + runs_xml + "</w:p>"
}

let doc_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:document xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:body>" + body_xml + "</w:body></w:document>"

let content_types = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/></Types>"

let rels = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/></Relationships>"

let entries = [["[Content_Types].xml", content_types], ["_rels/.rels", rels], ["word/document.xml", doc_xml]]

print(base64_encode(zip_create(entries)))
"""
}
