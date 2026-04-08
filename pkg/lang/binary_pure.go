// Pure computation helpers: endian conversion, CRC32.
// No OS dependencies. Compiles on all targets including WASM.
package lang

import (
	"encoding/binary"
	"hash/crc32"
)

func crc32Checksum(data []byte) uint32 {
	return crc32.ChecksumIEEE(data)
}

func readU16LE(buf []byte, off int) int {
	if off+2 > len(buf) {
		return 0
	}
	return int(binary.LittleEndian.Uint16(buf[off : off+2]))
}

func readU16BE(buf []byte, off int) int {
	if off+2 > len(buf) {
		return 0
	}
	return int(binary.BigEndian.Uint16(buf[off : off+2]))
}

func readU32LE(buf []byte, off int) int {
	if off+4 > len(buf) {
		return 0
	}
	return int(binary.LittleEndian.Uint32(buf[off : off+4]))
}

func readU32BE(buf []byte, off int) int {
	if off+4 > len(buf) {
		return 0
	}
	return int(binary.BigEndian.Uint32(buf[off : off+4]))
}

func readI16BE(buf []byte, off int) int {
	if off+2 > len(buf) {
		return 0
	}
	return int(int16(binary.BigEndian.Uint16(buf[off : off+2])))
}

func writeU16LE(buf []byte, off, val int) []byte {
	out := make([]byte, len(buf))
	copy(out, buf)
	if off+2 <= len(out) {
		binary.LittleEndian.PutUint16(out[off:off+2], uint16(val))
	}
	return out
}

func writeU32LE(buf []byte, off, val int) []byte {
	out := make([]byte, len(buf))
	copy(out, buf)
	if off+4 <= len(out) {
		binary.LittleEndian.PutUint32(out[off:off+4], uint32(val))
	}
	return out
}

func writeU16BE(buf []byte, off, val int) []byte {
	out := make([]byte, len(buf))
	copy(out, buf)
	if off+2 <= len(out) {
		binary.BigEndian.PutUint16(out[off:off+2], uint16(val))
	}
	return out
}

func writeU32BE(buf []byte, off, val int) []byte {
	out := make([]byte, len(buf))
	copy(out, buf)
	if off+4 <= len(out) {
		binary.BigEndian.PutUint32(out[off:off+4], uint32(val))
	}
	return out
}
