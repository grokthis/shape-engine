shape lib.ttf : lib {
  type: lib
  layer: 3
  """
// TTF metadata parsing — pure shape-lang on byte primitives.

fn ttf_info(buf) {
  // Parse TTF/TrueType font file, return [[key, value], ...]
  if len(buf) < 12 { auto [] }
  let scaler = read_u32_be(buf, 0)
  if scaler != 0x00010000 {
    if scaler != 0x74727565 { auto [] }
  }
  let num_tables = read_u16_be(buf, 4)
  if len(buf) < 12 + num_tables * 16 { auto [] }
  // Build table directory: find offsets for head, hhea, OS/2, name.
  let result = [["weight", "400"], ["style", "regular"]]
  let head_off = 0
  let hhea_off = 0
  let os2_off = 0
  let name_off = 0
  let name_len = 0
  let i = 0
  while i < num_tables {
    let off = 12 + i * 16
    let tag = bytes_to_string(bytes_slice(buf, off, off + 4))
    let toff = read_u32_be(buf, off + 8)
    let tlen = read_u32_be(buf, off + 12)
    if tag == "head" { let head_off = toff }
    if tag == "hhea" { let hhea_off = toff }
    if tag == "OS/2" { let os2_off = toff }
    if tag == "name" { let name_off = toff; let name_len = tlen }
    let i = i + 1
  }
  // head: unitsPerEm at offset+18
  if head_off > 0 {
    if head_off + 54 <= len(buf) {
      let upm = read_u16_be(buf, head_off + 18)
      let result = append(result, ["units_per_em", to_string(upm)])
    }
  }
  // hhea: ascent(+4), descent(+6), lineGap(+8)
  if hhea_off > 0 {
    if hhea_off + 36 <= len(buf) {
      let result = append(result, ["ascent", to_string(read_i16_be(buf, hhea_off + 4))])
      let result = append(result, ["descent", to_string(read_i16_be(buf, hhea_off + 6))])
      let result = append(result, ["line_gap", to_string(read_i16_be(buf, hhea_off + 8))])
    }
  }
  // OS/2: weight at offset+4
  if os2_off > 0 {
    if os2_off + 8 <= len(buf) {
      let w = read_u16_be(buf, os2_off + 4)
      // Update result[0]
      let result = append(result, ["weight_class", to_string(w)])
    }
  }
  // name: family(nameID=1), style(nameID=2)
  if name_off > 0 {
    if name_off + 6 <= len(buf) {
      let count = read_u16_be(buf, name_off + 2)
      let str_offset = read_u16_be(buf, name_off + 4)
      let j = 0
      while j < count {
        let rec = name_off + 6 + j * 12
        let j = j + 1
        if rec + 12 > len(buf) { break }
        let platform = read_u16_be(buf, rec)
        let name_id = read_u16_be(buf, rec + 6)
        let slen = read_u16_be(buf, rec + 8)
        let soff = read_u16_be(buf, rec + 10)
        let abs_off = name_off + str_offset + soff
        if abs_off + slen > len(buf) { continue }
        // Platform 1 = Macintosh (ASCII), platform 3 = Windows (UTF-16BE).
        if platform == 1 {
          let s = bytes_to_string(bytes_slice(buf, abs_off, abs_off + slen))
          if name_id == 1 { let result = append(result, ["family", s]) }
          if name_id == 2 { let result = append(result, ["style_name", s]) }
        }
        if platform == 3 {
          // Decode UTF-16BE: pairs of bytes → characters.
          let s = ""
          let k = 0
          while k < slen {
            let cp = read_u16_be(buf, abs_off + k)
            let s = s + chr(cp)
            let k = k + 2
          }
          if name_id == 1 { let result = append(result, ["family", s]) }
          if name_id == 2 { let result = append(result, ["style_name", s]) }
        }
      }
    }
  }
  auto result
}
"""
}
