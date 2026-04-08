shape os.test.lang.bytes : os.test {
  type: test
  layer: 3
  desc: "Byte buffer and bitwise operations"
  """
// --- bytes / byte_get / byte_set ---
let buf = bytes(4)
assert_eq(type(buf), "bytes", "bytes: type")
assert_eq(byte_get(buf, 0), 0, "bytes: initialized to zero")

set buf = byte_set(buf, 0, 65)
set buf = byte_set(buf, 1, 66)
assert_eq(byte_get(buf, 0), 65, "byte_set/get: 65")
assert_eq(byte_get(buf, 1), 66, "byte_set/get: 66")

// --- bytes_from ---
let buf2 = bytes_from([72, 101, 108, 108, 111])
assert_eq(byte_get(buf2, 0), 72, "bytes_from: H")
assert_eq(byte_get(buf2, 4), 111, "bytes_from: o")

// --- string_to_bytes / bytes_to_string ---
let sbuf = string_to_bytes("Hello")
assert_eq(byte_get(sbuf, 0), 72, "string_to_bytes: H=72")
assert_eq(bytes_to_string(sbuf), "Hello", "bytes_to_string: roundtrip")

// --- bytes_slice ---
let sliced = bytes_slice(sbuf, 1, 4)
assert_eq(bytes_to_string(sliced), "ell", "bytes_slice: middle")

// --- bytes_concat ---
let a = string_to_bytes("Hel")
let b = string_to_bytes("lo")
let joined = bytes_concat(a, b)
assert_eq(bytes_to_string(joined), "Hello", "bytes_concat: join")

// --- crc32 ---
let data = string_to_bytes("test")
let checksum = crc32(data)
assert_true(checksum > 0, "crc32: nonzero")
// CRC32 of "test" is 3632233996 (0xD87F7E0C)
assert_eq(checksum, 3632233996, "crc32: known value")

// --- endian read/write ---
let ebuf = bytes(8)
set ebuf = write_u16_le(ebuf, 0, 256)
assert_eq(read_u16_le(ebuf, 0), 256, "u16_le: roundtrip")
assert_eq(byte_get(ebuf, 0), 0, "u16_le: low byte")
assert_eq(byte_get(ebuf, 1), 1, "u16_le: high byte")

set ebuf = write_u16_be(ebuf, 2, 256)
assert_eq(read_u16_be(ebuf, 2), 256, "u16_be: roundtrip")
assert_eq(byte_get(ebuf, 2), 1, "u16_be: high byte first")
assert_eq(byte_get(ebuf, 3), 0, "u16_be: low byte second")

set ebuf = write_u32_le(ebuf, 0, 65536)
assert_eq(read_u32_le(ebuf, 0), 65536, "u32_le: roundtrip")

set ebuf = write_u32_be(ebuf, 4, 65536)
assert_eq(read_u32_be(ebuf, 4), 65536, "u32_be: roundtrip")

// --- signed read ---
let sbuf2 = bytes(4)
set sbuf2 = write_u16_be(sbuf2, 0, 65535)
let signed = read_i16_be(sbuf2, 0)
assert_eq(signed, -1, "i16_be: 0xFFFF = -1")

// --- bitwise ---
assert_eq(bit_and(0xFF, 0x0F), 0x0F, "bit_and")
assert_eq(bit_or(0xF0, 0x0F), 0xFF, "bit_or")
assert_eq(bit_xor(0xFF, 0x0F), 0xF0, "bit_xor")
assert_eq(bit_shl(1, 8), 256, "bit_shl: 1 << 8")
assert_eq(bit_shr(256, 8), 1, "bit_shr: 256 >> 8")
assert_eq(bit_and(bit_not(0), 0xFF), 0xFF, "bit_not: low byte")
assert_eq(bit_shl(1, 0), 1, "bit_shl: shift 0")
assert_eq(bit_shr(1, 0), 1, "bit_shr: shift 0")
assert_eq(bit_xor(42, 42), 0, "bit_xor: self = 0")
assert_eq(bit_or(0, 0), 0, "bit_or: zeros")
assert_eq(bit_and(0, 0xFF), 0, "bit_and: zero mask")
"""
}
