shape os.test.lang.strings : os.test {
  type: test
  layer: 3
  desc: "String builtins work"
  """
assert_true(contains("hello world", "world"), "contains")
assert_true(has_prefix("hello", "hel"), "has_prefix")
assert_true(has_suffix("hello", "llo"), "has_suffix")
assert_eq(replace("foo bar", "bar", "baz"), "foo baz", "replace")
assert_eq(upper("hello"), "HELLO", "upper")
assert_eq(lower("HELLO"), "hello", "lower")
assert_eq(trim("  hi  "), "hi", "trim")
let parts = split("a,b,c", ",")
assert_eq(len(parts), 3, "split produces 3 parts")
assert_eq(join(parts, "-"), "a-b-c", "join")
"""
}
