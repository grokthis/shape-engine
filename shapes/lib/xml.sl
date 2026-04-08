shape lib.xml : lib {
  type: lib
  layer: 3
  """
// XML text escaping — pure shape-lang.

fn xml_escape(s) {
  let out = ""
  let i = 0
  let n = len(s)
  while i < n {
    let c = at(s, i)
    let i = i + 1
    if c == "&" { let out = out + "&amp;" }
    if c == "<" { let out = out + "&lt;" }
    if c == ">" { let out = out + "&gt;" }
    if c == "\"" { let out = out + "&quot;" }
    if c == "'" { let out = out + "&#39;" }
    if c != "&" {
      if c != "<" {
        if c != ">" {
          if c != "\"" {
            if c != "'" {
              let out = out + c
            }
          }
        }
      }
    }
  }
  auto out
}
"""
}
