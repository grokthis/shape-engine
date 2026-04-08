shape lib.base64 : lib {
  type: lib
  layer: 3
  """
// Base64 encode/decode — pure shape-lang on byte primitives.
// Standard base64 alphabet (RFC 4648).

fn _b64_char(n) {
  if n < 26 { auto chr(n + 65) }
  if n < 52 { auto chr(n - 26 + 97) }
  if n < 62 { auto chr(n - 52 + 48) }
  if n == 62 { auto "+" }
  auto "/"
}

fn _b64_val(c) {
  let n = ord(c)
  if n >= 65 { if n <= 90 { auto n - 65 } }
  if n >= 97 { if n <= 122 { auto n - 97 + 26 } }
  if n >= 48 { if n <= 57 { auto n - 48 + 52 } }
  if c == "+" { auto 62 }
  if c == "/" { auto 63 }
  auto 0
}

fn base64_encode(buf) {
  let n = len(buf)
  let out = ""
  let i = 0
  while i < n {
    let b0 = byte_get(buf, i)
    let b1 = 0
    let b2 = 0
    if i + 1 < n { let b1 = byte_get(buf, i + 1) }
    if i + 2 < n { let b2 = byte_get(buf, i + 2) }
    let out = out + _b64_char(bit_shr(b0, 2))
    let out = out + _b64_char(bit_or(bit_shl(bit_and(b0, 3), 4), bit_shr(b1, 4)))
    if i + 1 < n {
      let out = out + _b64_char(bit_or(bit_shl(bit_and(b1, 0x0F), 2), bit_shr(b2, 6)))
    }
    if i + 1 >= n { let out = out + "=" }
    if i + 2 < n {
      let out = out + _b64_char(bit_and(b2, 0x3F))
    }
    if i + 2 >= n { let out = out + "=" }
    let i = i + 3
  }
  auto out
}

fn base64_decode(s) {
  let n = len(s)
  let out = bytes(0)
  let i = 0
  while i < n {
    let c0 = at(s, i)
    let c1 = at(s, i + 1)
    let c2 = at(s, i + 2)
    let c3 = at(s, i + 3)
    let v0 = _b64_val(c0)
    let v1 = _b64_val(c1)
    let b0 = bit_or(bit_shl(v0, 2), bit_shr(v1, 4))
    let out = bytes_concat(out, bytes_from([b0]))
    if c2 != "=" {
      let v2 = _b64_val(c2)
      let b1 = bit_and(bit_or(bit_shl(v1, 4), bit_shr(v2, 2)), 0xFF)
      let out = bytes_concat(out, bytes_from([b1]))
      if c3 != "=" {
        let v3 = _b64_val(c3)
        let b2 = bit_and(bit_or(bit_shl(v2, 6), v3), 0xFF)
        let out = bytes_concat(out, bytes_from([b2]))
      }
    }
    let i = i + 4
  }
  auto out
}

fn base64_encode_string(s) {
  auto base64_encode(string_to_bytes(s))
}

fn base64_decode_string(s) {
  auto bytes_to_string(base64_decode(s))
}
"""
}
