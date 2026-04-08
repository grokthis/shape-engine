shape lib.zip : lib {
  type: lib
  layer: 3
  """
// ZIP format — pure shape-lang on byte primitives.
// Uses Store method (no compression). XLSX/DOCX work fine uncompressed.

fn _zip_local_header(name, data) {
  // Local file header: signature + version + flags + method + time + date +
  // crc32 + compressed size + uncompressed size + name len + extra len + name
  let name_bytes = string_to_bytes(name)
  let name_len = len(name_bytes)
  let data_len = len(data)
  let crc = crc32(data)
  let hdr = bytes(30)
  let hdr = write_u32_le(hdr, 0, 0x04034b50)
  let hdr = write_u16_le(hdr, 4, 20)
  let hdr = write_u16_le(hdr, 6, 0)
  let hdr = write_u16_le(hdr, 8, 0)
  let hdr = write_u16_le(hdr, 10, 0)
  let hdr = write_u16_le(hdr, 12, 0)
  let hdr = write_u32_le(hdr, 14, crc)
  let hdr = write_u32_le(hdr, 18, data_len)
  let hdr = write_u32_le(hdr, 22, data_len)
  let hdr = write_u16_le(hdr, 26, name_len)
  let hdr = write_u16_le(hdr, 28, 0)
  auto bytes_concat(bytes_concat(hdr, name_bytes), data)
}

fn _zip_central_entry(name, data, local_offset) {
  let name_bytes = string_to_bytes(name)
  let name_len = len(name_bytes)
  let data_len = len(data)
  let crc = crc32(data)
  let hdr = bytes(46)
  let hdr = write_u32_le(hdr, 0, 0x02014b50)
  let hdr = write_u16_le(hdr, 4, 20)
  let hdr = write_u16_le(hdr, 6, 20)
  let hdr = write_u16_le(hdr, 8, 0)
  let hdr = write_u16_le(hdr, 10, 0)
  let hdr = write_u16_le(hdr, 12, 0)
  let hdr = write_u16_le(hdr, 14, 0)
  let hdr = write_u32_le(hdr, 16, crc)
  let hdr = write_u32_le(hdr, 20, data_len)
  let hdr = write_u32_le(hdr, 24, data_len)
  let hdr = write_u16_le(hdr, 28, name_len)
  let hdr = write_u16_le(hdr, 30, 0)
  let hdr = write_u16_le(hdr, 32, 0)
  let hdr = write_u16_le(hdr, 34, 0)
  let hdr = write_u16_le(hdr, 36, 0)
  let hdr = write_u32_le(hdr, 38, 0)
  let hdr = write_u32_le(hdr, 42, local_offset)
  auto bytes_concat(hdr, name_bytes)
}

fn zip_create(entries) {
  // entries = [[name, content_string], ...]
  // Returns bytes (the ZIP file).
  let body = bytes(0)
  let central = bytes(0)
  let count = 0
  let i = 0
  while i < len(entries) {
    let entry = at(entries, i)
    let i = i + 1
    let name = at(entry, 0)
    let content = at(entry, 1)
    let data = string_to_bytes(content)
    let offset = len(body)
    let local = _zip_local_header(name, data)
    let body = bytes_concat(body, local)
    let centry = _zip_central_entry(name, data, offset)
    let central = bytes_concat(central, centry)
    let count = count + 1
  }
  let central_offset = len(body)
  let central_size = len(central)
  // End of central directory record
  let eocd = bytes(22)
  let eocd = write_u32_le(eocd, 0, 0x06054b50)
  let eocd = write_u16_le(eocd, 4, 0)
  let eocd = write_u16_le(eocd, 6, 0)
  let eocd = write_u16_le(eocd, 8, count)
  let eocd = write_u16_le(eocd, 10, count)
  let eocd = write_u32_le(eocd, 12, central_size)
  let eocd = write_u32_le(eocd, 16, central_offset)
  let eocd = write_u16_le(eocd, 20, 0)
  auto bytes_concat(bytes_concat(body, central), eocd)
}

fn zip_extract(buf) {
  // Parse ZIP, return [[name, content_string], ...]
  // Find end-of-central-directory (last 22+ bytes).
  let blen = len(buf)
  let eocd_off = blen - 22
  // Scan backward for EOCD signature.
  while eocd_off >= 0 {
    if read_u32_le(buf, eocd_off) == 0x06054b50 { break }
    let eocd_off = eocd_off - 1
  }
  if eocd_off < 0 { auto [] }
  let count = read_u16_le(buf, eocd_off + 8)
  let cd_offset = read_u32_le(buf, eocd_off + 16)
  let entries = []
  let off = cd_offset
  let i = 0
  while i < count {
    let i = i + 1
    if read_u32_le(buf, off) != 0x02014b50 { break }
    let comp_size = read_u32_le(buf, off + 20)
    let uncomp_size = read_u32_le(buf, off + 24)
    let name_len = read_u16_le(buf, off + 28)
    let extra_len = read_u16_le(buf, off + 30)
    let comment_len = read_u16_le(buf, off + 32)
    let local_offset = read_u32_le(buf, off + 42)
    let name = bytes_to_string(bytes_slice(buf, off + 46, off + 46 + name_len))
    // Read data from local file header.
    let local_name_len = read_u16_le(buf, local_offset + 26)
    let local_extra_len = read_u16_le(buf, local_offset + 28)
    let data_start = local_offset + 30 + local_name_len + local_extra_len
    let data = bytes_to_string(bytes_slice(buf, data_start, data_start + uncomp_size))
    let entries = append(entries, [name, data])
    let off = off + 46 + name_len + extra_len + comment_len
  }
  auto entries
}
"""
}
