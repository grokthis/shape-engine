shape os.test.lang.shapes_full : os.test {
  type: test
  layer: 3
  desc: "Shape mutation and graph operations"
  """
// --- exists ---
assert_true(exists("law.persistence"), "exists: law.persistence")
assert_true(!exists("nonexistent.shape.xyz"), "exists: nonexistent")

// --- content ---
let c = content("law.persistence")
assert_true(contains(c, "check_persistence"), "content: has fn")
assert_eq(content("nonexistent.xyz"), "", "content: nonexistent returns empty")

// --- dim / dims ---
assert_eq(dim("law.persistence", "type"), "law", "dim: type")
assert_eq(dim("law.persistence", "layer"), "0", "dim: layer")
assert_eq(dim("law.persistence", "nonexistent"), "", "dim: missing key")

let d = dims("law.persistence")
assert_true(contains(d, "type"), "dims: contains type")

// --- children ---
let lawChildren = children("law")
assert_true(len(lawChildren) >= 4, "children: law has >= 4")
assert_true("persistence" in lawChildren, "children: includes persistence")
assert_true("reference" in lawChildren, "children: includes reference")
assert_true("conservation" in lawChildren, "children: includes conservation")
assert_true("consistency" in lawChildren, "children: includes consistency")

// --- layer ---
assert_eq(layer("law.persistence"), 0, "layer: law is 0")
assert_true(layer("os.shell.cmd.ls") > 0, "layer: shell cmd > 0")

// --- depth ---
assert_true(depth("law") < depth("law.persistence"), "depth: child deeper")

// --- ancestry ---
let anc = ancestry("os.shell.cmd.ls")
assert_true(len(anc) > 0, "ancestry: has ancestors")

// --- deps / dependents ---
let lawDeps = deps("law.persistence")
assert_true(type(lawDeps) == "list" || type(lawDeps) == "shapes", "deps: returns list")

// --- add_shape / set_content / set_dim / remove ---
add_shape("os.test._temp_shape", "exec", "print(42)", 4)
assert_true(exists("os.test._temp_shape"), "add_shape: created")
assert_eq(content("os.test._temp_shape"), "print(42)", "add_shape: content")
assert_eq(dim("os.test._temp_shape", "type"), "exec", "add_shape: type dim")

set_content("os.test._temp_shape", "print(99)")
assert_eq(content("os.test._temp_shape"), "print(99)", "set_content: updated")

set_dim("os.test._temp_shape", "color", "blue")
assert_eq(dim("os.test._temp_shape", "color"), "blue", "set_dim: new dim")

remove("os.test._temp_shape")
assert_true(!exists("os.test._temp_shape"), "remove: deleted")

// --- shapes_under ---
let osShapes = shapes_under("os.test.lang")
assert_true(len(osShapes) > 0, "shapes_under: finds shapes")

// --- shape_count ---
assert_true(shape_count() > 100, "shape_count: > 100")

// --- resolve ---
assert_eq(resolve("os.shell", "cmd.ls"), "os.shell.cmd.ls", "resolve: basic")
assert_eq(resolve("os.shell.cmd", ".."), "os.shell", "resolve: parent")

// --- parent ---
assert_eq(parent("os.shell.cmd.ls"), "os.shell.cmd", "parent: basic")
assert_eq(parent("law"), "", "parent: root")

// --- shape_to_map ---
let sm = shape_to_map("law.persistence")
assert_eq(type(sm), "map", "shape_to_map: returns map")
assert_true(map_has(sm, "id"), "shape_to_map: has id")
"""
}
