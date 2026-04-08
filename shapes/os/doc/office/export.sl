shape os.doc.office.export : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Export formats"
  summary: "XLSX, DOCX, CSV, and PDF export documentation."
  """
# Export Formats

## XLSX (Excel)

SpreadsheetML XML in a ZIP container. Cell values are written as inline
strings. Formatting is minimal (default Calibri 11pt).

## DOCX (Word)

WordprocessingML XML in a ZIP container. Paragraphs become `<w:p>` elements,
headings get a `Heading1` style. Runs carry text content.

## CSV

Plain text, comma-separated. Values containing commas or quotes are escaped.

## PDF

Direct byte generation with Helvetica text. Single page, 72pt margins.
Headings render at 24pt, body at 12pt.

## Import

XLSX and DOCX files can be imported via:
- Web: POST `/office/import` with multipart form
- The parser reads sheet1.xml (XLSX) or word/document.xml (DOCX)
- Shapes are created under the specified prefix
"""
}
