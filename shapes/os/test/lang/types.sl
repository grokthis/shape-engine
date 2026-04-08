shape os.test.lang.types : os.test {
  type: test
  layer: 3
  desc: "Type system and conversions"
  """
// --- type() ---
assert_eq(type(42), "int", "type: int")
assert_eq(type("hello"), "string", "type: string")
assert_eq(type(true), "bool", "type: bool")
assert_eq(type([1, 2]), "list", "type: list")
assert_eq(type(3.14), "float", "type: float")
let m = map_new()
assert_eq(type(m), "map", "type: map")

// --- to_int ---
assert_eq(to_int("42"), 42, "to_int: string")
assert_eq(to_int("0"), 0, "to_int: zero string")
assert_eq(to_int(""), 0, "to_int: empty string")

// --- to_string ---
assert_eq(to_string(42), "42", "to_string: int")
assert_eq(to_string(true), "true", "to_string: bool true")
assert_eq(to_string(false), "false", "to_string: bool false")
assert_eq(to_string("hi"), "hi", "to_string: string passthrough")

// --- to_float ---
assert_eq(type(to_float(42)), "float", "to_float: int becomes float")
assert_eq(type(to_float("3.14")), "float", "to_float: string becomes float")

// --- default ---
assert_eq(default("hello", "fallback"), "hello", "default: truthy returns first")
assert_eq(default("", "fallback"), "fallback", "default: empty string is falsy")
assert_eq(default(0, 99), 99, "default: zero is falsy")
assert_eq(default(false, true), true, "default: false is falsy")
assert_eq(default(42, 0), 42, "default: nonzero is truthy")

// --- if_val ---
assert_eq(if_val(true, "yes", "no"), "yes", "if_val: true")
assert_eq(if_val(false, "yes", "no"), "no", "if_val: false")
assert_eq(if_val(1, "one", "zero"), "one", "if_val: truthy int")
assert_eq(if_val(0, "one", "zero"), "zero", "if_val: falsy int")
assert_eq(if_val("x", "has", "empty"), "has", "if_val: truthy string")
assert_eq(if_val("", "has", "empty"), "empty", "if_val: falsy string")
"""
}
