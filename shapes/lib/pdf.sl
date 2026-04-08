shape lib.pdf : lib {
  type: lib
  layer: 3
  """
// PDF generation — pure shape-lang. Mostly string building with offset tracking.

fn _pdf_escape(text) {
  let out = ""
  let i = 0
  while i < len(text) {
    let c = at(text, i)
    let i = i + 1
    if c == "\\" { let out = out + "\\\\" }
    if c == "(" { let out = out + "\\(" }
    if c == ")" { let out = out + "\\)" }
    if c != "\\" {
      if c != "(" {
        if c != ")" {
          let out = out + c
        }
      }
    }
  }
  auto out
}

fn _pad10(n) {
  let s = to_string(n)
  while len(s) < 10 { let s = "0" + s }
  auto s
}

fn pdf_create(blocks) {
  // blocks = [[type, text], ...] where type is "heading" or "paragraph".
  // Returns bytes (the PDF file).
  let stream = "BT\n/F1 12 Tf\n"
  let y = 750
  let i = 0
  while i < len(blocks) {
    let block = at(blocks, i)
    let i = i + 1
    let btype = at(block, 0)
    let text = at(block, 1)
    let font_size = 12
    if btype == "heading" { let font_size = 24 }
    let stream = stream + "/F1 " + to_string(font_size) + " Tf\n"
    let stream = stream + "1 0 0 1 72 " + to_string(y) + " Tm\n(" + _pdf_escape(text) + ") Tj\n"
    let y = y - font_size - 6
    if y < 72 { break }
  }
  let stream = stream + "ET\n"
  let stream_len = len(stream)
  let pdf = "%PDF-1.4\n"
  let off1 = len(pdf)
  let pdf = pdf + "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n"
  let off2 = len(pdf)
  let pdf = pdf + "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n"
  let off3 = len(pdf)
  let pdf = pdf + "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\nendobj\n"
  let off4 = len(pdf)
  let pdf = pdf + "4 0 obj\n<< /Length " + to_string(stream_len) + " >>\nstream\n" + stream + "\nendstream\nendobj\n"
  let off5 = len(pdf)
  let pdf = pdf + "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n"
  let xref_off = len(pdf)
  let pdf = pdf + "xref\n0 6\n0000000000 65535 f \n"
  let pdf = pdf + _pad10(off1) + " 00000 n \n"
  let pdf = pdf + _pad10(off2) + " 00000 n \n"
  let pdf = pdf + _pad10(off3) + " 00000 n \n"
  let pdf = pdf + _pad10(off4) + " 00000 n \n"
  let pdf = pdf + _pad10(off5) + " 00000 n \n"
  let pdf = pdf + "trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n" + to_string(xref_off) + "\n%%EOF\n"
  auto string_to_bytes(pdf)
}
"""
}
