shape os.test.lang.trace : os.test {
  type: test
  layer: 3
  desc: "Moment/trace and assertion functions"
  """
// --- global_tick ---
let gt = global_tick()
assert_true(gt > 0, "global_tick: positive")

// --- shape_tick ---
let st = shape_tick("law.persistence")
assert_true(st > 0, "shape_tick: law has tick")

// --- is_latest ---
// After boot, all shapes should be at latest tick
assert_true(is_latest("law.persistence"), "is_latest: law is latest")

// --- ticks_between ---
let tb = ticks_between("law.persistence", "law.reference")
assert_true(type(tb) == "int", "ticks_between: returns int")

// --- actor ---
let a = actor()
assert_true(type(a) == "string", "actor: returns string")

// --- set_actor ---
set_actor("test_user_42")
assert_eq(actor(), "test_user_42", "set_actor: updated")
// Reset
set_actor("")

// --- assert_neq ---
assert_neq(1, 2, "assert_neq: different ints")
assert_neq("a", "b", "assert_neq: different strings")
assert_neq(true, false, "assert_neq: different bools")

// --- assert_contains ---
assert_contains("hello world", "world", "assert_contains: found")
assert_contains("abcdef", "cd", "assert_contains: middle")

// --- assert_gt ---
assert_gt(5, 3, "assert_gt: 5 > 3")
assert_gt(100, 0, "assert_gt: 100 > 0")
"""
}
