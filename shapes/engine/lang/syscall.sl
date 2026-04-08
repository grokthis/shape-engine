shape engine.lang.syscall : engine.lang {
  type: system
  layer: 3
  """
// The kernel interface. Everything below this is Go (the shape machine).
// Everything above can be rewritten in shape-lang.
//
// Shape I/O:    content, dim, dims, deps, dependents, layer, from,
//               produces, ancestry, depth, tick, exists, children,
//               shapes_under, shape_count
// Mutation:     add_shape, add_dep, remove, set_content, set_dim
// Strings:      contains, starts_with, ends_with, substring, index_of,
//               at, split, join, has_prefix, has_suffix, replace, trim,
//               repeat, substr, upper, lower, pad_right, pad_left
// Lists:        len, sort_list, append, head, tail, index, range
// Math:         sum, avg, min_num, max_num, abs, round, floor, ceil,
//               pow, mod, to_float
// Control:      default, if_val
// Types:        type, to_int, to_string
// Paths:        resolve, parent
// Output:       print, write, navigate
// Engine:       validate, status
// Unicode:      chr, ord
// Host OS:      file_read, file_read_bytes, file_write, file_write_bytes
// Bytes:        bytes, bytes_from, byte_get, byte_set, bytes_slice,
//               bytes_concat, string_to_bytes, bytes_to_string
// Endian:       read_u16_le, read_u16_be, read_u32_le, read_u32_be,
//               read_i16_be, write_u16_le, write_u32_le,
//               write_u16_be, write_u32_be
// Bitwise:      bit_and, bit_or, bit_xor, bit_not, bit_shl, bit_shr
// Hash:         crc32
// Modules:      use (loads shape fn definitions into current scope)
"""
}
