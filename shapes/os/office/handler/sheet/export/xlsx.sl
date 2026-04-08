shape os.office.handler.sheet.export.xlsx : os.office.sheet {
  type: handler
  layer: 4
  """
// GET /office/sheet/{id}/export/xlsx → base64 XLSX (ZIP of XML)
// scope: id = sheet prefix
use "lib.xml"
use "lib.zip"
use "lib.base64"
let prefix = id + "."
let shapes = shapes_under(id)

// Build shared strings and sheet XML.
let strings_xml = ""
let str_count = 0
let rows_xml = ""
let current_row = 0
let row_xml = ""

let i = 0
let n = len(shapes)
while i < n {
  let sid = at(shapes, i)
  let i = i + 1
  if !starts_with(sid, prefix) { continue }
  if dim(sid, "type") != "cell" { continue }
  let ref = substring(sid, len(prefix))
  let val = content(sid)

  // Each cell uses inline string.
  let cell_row = to_int(substring(ref, 1))
  if cell_row != current_row {
    if current_row > 0 {
      let rows_xml = rows_xml + row_xml + "</row>"
    }
    let row_xml = "<row r=\"" + to_string(cell_row) + "\">"
    let current_row = cell_row
  }
  let row_xml = row_xml + "<c r=\"" + xml_escape(ref) + "\" t=\"inlineStr\"><is><t>" + xml_escape(val) + "</t></is></c>"
}
if current_row > 0 {
  let rows_xml = rows_xml + row_xml + "</row>"
}

let sheet_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"><sheetData>" + rows_xml + "</sheetData></worksheet>"

let content_types = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/><Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/></Types>"

let rels = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/></Relationships>"

let wb_rels = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/></Relationships>"

let workbook = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"><sheets><sheet name=\"Sheet1\" sheetId=\"1\" r:id=\"rId1\"/></sheets></workbook>"

let entries = [["[Content_Types].xml", content_types], ["_rels/.rels", rels], ["xl/_rels/workbook.xml.rels", wb_rels], ["xl/workbook.xml", workbook], ["xl/worksheets/sheet1.xml", sheet_xml]]

print(base64_encode(zip_create(entries)))
"""
}
