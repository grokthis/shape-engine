shape os.test.lang.json : os.test {
  type: test
  layer: 3
  desc: "JSON encode/decode roundtrip"
  """
// --- json_encode: primitives ---
assert_eq(json_encode(42), "42", "json_encode: int")
assert_eq(json_encode("hello"), "\"hello\"", "json_encode: string")
assert_eq(json_encode(true), "true", "json_encode: bool true")
assert_eq(json_encode(false), "false", "json_encode: bool false")

// --- json_encode: list ---
let encoded = json_encode([1, 2, 3])
assert_true(contains(encoded, "1"), "json_encode list: has 1")
assert_true(contains(encoded, "3"), "json_encode list: has 3")

// --- json_encode: map ---
let m = map_new()
set m = map_set(m, "name", "alice")
set m = map_set(m, "age", 30)
let mapJson = json_encode(m)
assert_true(contains(mapJson, "alice"), "json_encode map: has value")
assert_true(contains(mapJson, "name"), "json_encode map: has key")

// --- json_decode: object ---
let obj = json_decode("{\"x\":1,\"y\":\"two\"}")
assert_eq(map_get(obj, "x"), 1, "json_decode: int value")
assert_eq(map_get(obj, "y"), "two", "json_decode: string value")

// --- json_decode: array ---
let arr = json_decode("[10,20,30]")
assert_eq(type(arr), "list", "json_decode array: type")
assert_eq(len(arr), 3, "json_decode array: length")
assert_eq(index(arr, 0), 10, "json_decode array: first")

// --- roundtrip ---
let orig = {"key": "value", "num": 42}
let rt = json_decode(json_encode(orig))
assert_eq(map_get(rt, "key"), "value", "roundtrip: string")
assert_eq(map_get(rt, "num"), 42, "roundtrip: int")

// --- json_decode: nested ---
let nested = json_decode("{\"a\":{\"b\":99}}")
let inner = map_get(nested, "a")
assert_eq(map_get(inner, "b"), 99, "json_decode: nested access")
"""
}
