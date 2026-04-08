shape os.shell.cmd.import {
  type: exec
  layer: 4
  """
// import <filename> as <prefix>
// File upload happens through the web UI at /office/import
let filename = default(arg1, "")
if filename == "" {
  print("Usage: import <filename> as <prefix>")
  print("  import budget.xlsx as user.sheet.budget")
  print("  import report.docx as user.doc.report")
  print("")
  print("For file upload, use the web interface: POST /office/import")
}
if filename != "" {
  print("File import requires the web interface.")
  print("POST /office/import with multipart form data:")
  print("  file: the .xlsx or .docx file")
  print("  prefix: target shape prefix (e.g. user.sheet.budget)")
  navigate("/office/import")
}
"""
}
