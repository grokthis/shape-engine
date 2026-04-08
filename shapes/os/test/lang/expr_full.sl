shape os.test.lang.expr_full : os.test {
  type: test
  layer: 3
  desc: "Complete expression and operator coverage"
  """
// --- arithmetic ---
assert_eq(1 + 2, 3, "add: basic")
assert_eq(10 - 7, 3, "sub: basic")
assert_eq(3 * 4, 12, "mul: basic")
assert_eq(15 / 4, 3, "div: integer truncation")
assert_eq(10 % 3, 1, "mod: basic")
assert_eq(0 + 0, 0, "add: zeros")
assert_eq(-3 + 5, 2, "add: negative")
assert_eq(-3 * -2, 6, "mul: neg * neg")

// --- string concatenation ---
assert_eq("a" + "b", "ab", "concat: strings")
assert_eq("" + "x", "x", "concat: empty + string")
assert_eq("x" + "", "x", "concat: string + empty")
assert_eq("" + "", "", "concat: empty + empty")

// --- comparison operators ---
assert_true(1 == 1, "eq: int")
assert_true("a" == "a", "eq: string")
assert_true(true == true, "eq: bool")
assert_true(1 != 2, "neq: int")
assert_true("a" != "b", "neq: string")
assert_true(true != false, "neq: bool")

assert_true(2 > 1, "gt: true")
assert_true(!(1 > 2), "gt: false")
assert_true(!(1 > 1), "gt: equal")
assert_true(1 < 2, "lt: true")
assert_true(!(2 < 1), "lt: false")
assert_true(!(1 < 1), "lt: equal")
assert_true(2 >= 2, "gte: equal")
assert_true(3 >= 2, "gte: greater")
assert_true(!(1 >= 2), "gte: less")
assert_true(2 <= 2, "lte: equal")
assert_true(1 <= 2, "lte: less")
assert_true(!(3 <= 2), "lte: greater")

// --- logical operators ---
assert_true(true && true, "and: T && T")
assert_true(!(true && false), "and: T && F")
assert_true(!(false && true), "and: F && T")
assert_true(!(false && false), "and: F && F")
assert_true(true || false, "or: T || F")
assert_true(false || true, "or: F || T")
assert_true(true || true, "or: T || T")
assert_true(!(false || false), "or: F || F")

// --- unary not ---
assert_true(!false, "not: false")
assert_true(!!true, "not: double negation")
assert_eq(!true, false, "not: true")

// --- operator precedence ---
assert_eq(2 + 3 * 4, 14, "precedence: * before +")
assert_eq((2 + 3) * 4, 20, "precedence: parens override")
assert_true(1 + 1 == 2, "precedence: + before ==")
assert_true(true || false && false, "precedence: && before ||")

// --- in operator ---
let items = ["a", "b", "c"]
assert_true("b" in items, "in: found")
assert_true(!("d" in items), "in: not found")

// --- string comparison ---
assert_true("abc" < "abd", "string lt")
assert_true("abd" > "abc", "string gt")
assert_true("abc" == "abc", "string eq")
assert_true("abc" <= "abc", "string lte eq")
assert_true("abc" >= "abc", "string gte eq")
"""
}
