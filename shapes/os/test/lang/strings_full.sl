shape os.test.lang.strings_full : os.test {
  type: test
  layer: 3
  desc: "Complete string function coverage"
  """
// --- contains ---
assert_true(contains("hello world", "world"), "contains: found")
assert_true(!contains("hello", "xyz"), "contains: not found")
assert_true(contains("", ""), "contains: empty in empty")
assert_true(contains("abc", ""), "contains: empty needle")

// --- starts_with / has_prefix ---
assert_true(starts_with("hello", "hel"), "starts_with: match")
assert_true(!starts_with("hello", "xyz"), "starts_with: no match")
assert_true(starts_with("hello", ""), "starts_with: empty prefix")
assert_true(starts_with("", ""), "starts_with: both empty")
assert_true(has_prefix("abcdef", "abc"), "has_prefix: match")
assert_true(!has_prefix("abcdef", "xyz"), "has_prefix: no match")

// --- ends_with / has_suffix ---
assert_true(ends_with("hello", "llo"), "ends_with: match")
assert_true(!ends_with("hello", "xyz"), "ends_with: no match")
assert_true(ends_with("hello", ""), "ends_with: empty suffix")
assert_true(has_suffix("abcdef", "def"), "has_suffix: match")
assert_true(!has_suffix("abcdef", "xyz"), "has_suffix: no match")

// --- substring ---
assert_eq(substring("hello", 1), "ello", "substring: from 1")
assert_eq(substring("hello", 0), "hello", "substring: from 0")
assert_eq(substring("hello", 5), "", "substring: past end")
assert_eq(substring("hello", 1, 3), "el", "substring: range")
assert_eq(substring("hello", 0, 0), "", "substring: zero range")
assert_eq(substring("hello", 3, 1), "", "substring: reversed range")

// --- substr (alias) ---
assert_eq(substr("abcdef", 2), "cdef", "substr: from 2")
assert_eq(substr("abcdef", 2, 4), "cd", "substr: range")
assert_eq(substr("abcdef", 10), "", "substr: past end")

// --- index_of ---
assert_eq(index_of("hello", "ll"), 2, "index_of: found")
assert_eq(index_of("hello", "xyz"), -1, "index_of: not found")
assert_eq(index_of("hello", ""), 0, "index_of: empty needle")

// --- at ---
assert_eq(at("hello", 0), "h", "at string: index 0")
assert_eq(at("hello", 4), "o", "at string: last")
assert_eq(at("hello", 5), "", "at string: out of bounds")
assert_eq(at("hello", -1), "", "at string: negative")
let list = split("a,b,c", ",")
assert_eq(at(list, 0), "a", "at list: index 0")
assert_eq(at(list, 2), "c", "at list: index 2")

// --- split / join ---
let parts = split("one::two::three", "::")
assert_eq(len(parts), 3, "split: count")
assert_eq(index(parts, 0), "one", "split: first")
assert_eq(index(parts, 2), "three", "split: last")
assert_eq(join(parts, ","), "one,two,three", "join: rejoin")
let single = split("nosep", ",")
assert_eq(len(single), 1, "split: no separator")
assert_eq(index(single, 0), "nosep", "split: no sep value")

// --- replace ---
assert_eq(replace("aabbcc", "bb", "XX"), "aaXXcc", "replace: middle")
assert_eq(replace("aaa", "a", "b"), "bbb", "replace: all occurrences")
assert_eq(replace("hello", "xyz", "!"), "hello", "replace: no match")

// --- trim ---
assert_eq(trim("  hello  "), "hello", "trim: spaces")
assert_eq(trim("hello"), "hello", "trim: no whitespace")
assert_eq(trim(""), "", "trim: empty")

// --- repeat ---
assert_eq(repeat("ab", 3), "ababab", "repeat: 3x")
assert_eq(repeat("x", 0), "", "repeat: 0x")
assert_eq(repeat("", 5), "", "repeat: empty string")

// --- upper / lower ---
assert_eq(upper("hello"), "HELLO", "upper")
assert_eq(upper("Hello World"), "HELLO WORLD", "upper: mixed")
assert_eq(upper(""), "", "upper: empty")
assert_eq(lower("HELLO"), "hello", "lower")
assert_eq(lower("Hello World"), "hello world", "lower: mixed")
assert_eq(lower(""), "", "lower: empty")

// --- pad_right / pad_left ---
assert_eq(len(pad_right("hi", 10)), 10, "pad_right: length")
assert_true(starts_with(pad_right("hi", 10), "hi"), "pad_right: content preserved")
assert_eq(pad_right("toolong", 3), "toolong", "pad_right: no truncate")
assert_eq(len(pad_left("hi", 10)), 10, "pad_left: length")
assert_true(ends_with(pad_left("hi", 10), "hi"), "pad_left: content preserved")
assert_eq(pad_left("toolong", 3), "toolong", "pad_left: no truncate")

// --- max_len ---
let words = split("cat,elephant,dog", ",")
assert_eq(max_len(words), 8, "max_len: longest")
let empty_list = split("", ",")
assert_eq(max_len(empty_list), 0, "max_len: empty strings")

// --- chr / ord ---
assert_eq(chr(65), "A", "chr: A")
assert_eq(chr(97), "a", "chr: a")
assert_eq(chr(48), "0", "chr: 0")
assert_eq(ord("A"), 65, "ord: A")
assert_eq(ord("a"), 97, "ord: a")
assert_eq(ord("0"), 48, "ord: 0")
"""
}
