shape lib.json : lib {
  type: lib
  layer: 3
  """
// JSON string escaping — pure shape-lang.

fn json_escape(s) {
  let out = ""
  let i = 0
  let n = len(s)
  while i < n {
    let c = at(s, i)
    let i = i + 1
    let code = ord(c)
    if c == "\\" { let out = out + "\\\\" }
    if c != "\\" {
      if c == "\"" { let out = out + "\\\"" }
      if c != "\"" {
        if code == 10 { let out = out + "\\n" }
        if code == 13 { let out = out + "\\r" }
        if code == 9 { let out = out + "\\t" }
        if code != 10 {
          if code != 13 {
            if code != 9 {
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
