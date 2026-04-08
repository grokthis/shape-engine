shape os.test.lang.math : os.test {
  type: test
  layer: 3
  desc: "Math functions work correctly for all cases"
  """
// --- sum ---
assert_eq(sum([1, 2, 3]), 6, "sum: integers")
assert_eq(sum([]), 0, "sum: empty list")
assert_eq(sum([10]), 10, "sum: single element")
assert_eq(sum([-1, 1]), 0, "sum: cancellation")

// --- avg ---
assert_eq(avg([2, 4, 6]), 4, "avg: integers")
assert_eq(avg([10]), 10, "avg: single")

// --- min_num / max_num ---
assert_eq(min_num([3, 1, 2]), 1, "min_num: basic")
assert_eq(min_num([5]), 5, "min_num: single")
assert_eq(min_num([-3, -1, -2]), -3, "min_num: negatives")
assert_eq(max_num([3, 1, 2]), 3, "max_num: basic")
assert_eq(max_num([5]), 5, "max_num: single")
assert_eq(max_num([-3, -1, -2]), -1, "max_num: negatives")

// --- abs ---
assert_eq(abs(5), 5, "abs: positive")
assert_eq(abs(-5), 5, "abs: negative")
assert_eq(abs(0), 0, "abs: zero")

// --- round ---
assert_eq(round(3.7), 4, "round: up")
assert_eq(round(3.2), 3, "round: down")
assert_eq(round(3.14159, 2), 3.14, "round: 2 places")

// --- floor / ceil ---
assert_eq(floor(3.7), 3, "floor: basic")
assert_eq(floor(3.0), 3, "floor: exact")
assert_eq(floor(-1.5), -2, "floor: negative")
assert_eq(ceil(3.2), 4, "ceil: basic")
assert_eq(ceil(3.0), 3, "ceil: exact")
assert_eq(ceil(-1.5), -1, "ceil: negative")

// --- pow ---
assert_eq(pow(2, 3), 8, "pow: 2^3")
assert_eq(pow(2, 0), 1, "pow: x^0")
assert_eq(pow(10, 1), 10, "pow: x^1")
assert_eq(pow(5, 2), 25, "pow: 5^2")

// --- mod ---
assert_eq(mod(10, 3), 1, "mod: basic")
assert_eq(mod(9, 3), 0, "mod: exact")
assert_eq(mod(7, 2), 1, "mod: odd")
assert_eq(mod(0, 5), 0, "mod: zero")

// --- arithmetic operators ---
assert_eq(1 + 2, 3, "add: int")
assert_eq(10 - 3, 7, "sub: int")
assert_eq(4 * 5, 20, "mul: int")
assert_eq(10 / 3, 3, "div: int truncates")
assert_eq(10 % 3, 1, "mod operator")
assert_eq(-5 + 3, -2, "negative add")
"""
}
