shape os.test.lang.maps : os.test {
  type: test
  layer: 3
  desc: "Map operations work correctly"
  """
// --- map_new / map_set / map_get ---
let m = map_new()
assert_eq(type(m), "map", "map_new: type is map")
set m = map_set(m, "name", "alice")
set m = map_set(m, "age", 30)
assert_eq(map_get(m, "name"), "alice", "map_get: string value")
assert_eq(map_get(m, "age"), 30, "map_get: int value")
assert_eq(map_get(m, "missing", "default"), "default", "map_get: default value")

// --- map_has ---
assert_true(map_has(m, "name"), "map_has: exists")
assert_true(!map_has(m, "missing"), "map_has: not exists")

// --- map_keys / map_values ---
let keys = sort_list(map_keys(m))
assert_eq(len(keys), 2, "map_keys: count")
assert_eq(index(keys, 0), "age", "map_keys: sorted first")
assert_eq(index(keys, 1), "name", "map_keys: sorted second")

let vals = map_values(m)
assert_eq(len(vals), 2, "map_values: count")

// --- map_delete ---
let m2 = map_delete(m, "age")
assert_true(!map_has(m2, "age"), "map_delete: removed")
assert_true(map_has(m2, "name"), "map_delete: other preserved")

// --- map_merge ---
let m3 = map_new()
set m3 = map_set(m3, "color", "blue")
set m3 = map_set(m3, "name", "bob")
let merged = map_merge(m, m3)
assert_eq(map_get(merged, "color"), "blue", "map_merge: new key")
assert_eq(map_get(merged, "name"), "bob", "map_merge: overwritten")
assert_eq(map_get(merged, "age"), 30, "map_merge: preserved")

// --- map with map literal ---
let m4 = {"x": 1, "y": 2, "z": 3}
assert_eq(map_get(m4, "x"), 1, "map literal: x")
assert_eq(map_get(m4, "z"), 3, "map literal: z")
assert_eq(len(map_keys(m4)), 3, "map literal: key count")
"""
}
