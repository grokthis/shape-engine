shape os.test.lang.lists_full : os.test {
  type: test
  layer: 3
  desc: "Complete list function coverage"
  """
// --- len ---
assert_eq(len([]), 0, "len: empty list")
assert_eq(len([1, 2, 3]), 3, "len: 3 elements")
assert_eq(len("hello"), 5, "len: string")
assert_eq(len(""), 0, "len: empty string")

// --- sort_list ---
let unsorted = ["c", "a", "b"]
let sorted = sort_list(unsorted)
assert_eq(index(sorted, 0), "a", "sort_list: first")
assert_eq(index(sorted, 1), "b", "sort_list: second")
assert_eq(index(sorted, 2), "c", "sort_list: third")
assert_eq(len(sort_list([])), 0, "sort_list: empty")

// --- append ---
let base = [1, 2]
let extended = append(base, 3)
assert_eq(len(extended), 3, "append: length grows")
assert_eq(index(extended, 2), 3, "append: new element")
let from_empty = append([], "x")
assert_eq(len(from_empty), 1, "append: from empty")

// --- head ---
let nums = [10, 20, 30, 40, 50]
let first3 = head(nums, 3)
assert_eq(len(first3), 3, "head: count")
assert_eq(index(first3, 0), 10, "head: first")
assert_eq(index(first3, 2), 30, "head: last")
let headAll = head(nums, 10)
assert_eq(len(headAll), 5, "head: more than length")
assert_eq(len(head(nums, 0)), 0, "head: zero")

// --- tail ---
let last2 = tail(nums, 2)
assert_eq(len(last2), 2, "tail: count")
assert_eq(index(last2, 0), 40, "tail: first")
assert_eq(index(last2, 1), 50, "tail: last")
let tailAll = tail(nums, 10)
assert_eq(len(tailAll), 5, "tail: more than length")
assert_eq(len(tail(nums, 0)), 0, "tail: zero")

// --- index ---
assert_eq(index(nums, 0), 10, "index: first")
assert_eq(index(nums, 4), 50, "index: last")

// --- range ---
let r5 = range(5)
assert_eq(len(r5), 5, "range(5): length")
assert_eq(index(r5, 0), 0, "range(5): starts at 0")
assert_eq(index(r5, 4), 4, "range(5): ends at 4")

let r2_5 = range(2, 5)
assert_eq(len(r2_5), 3, "range(2,5): length")
assert_eq(index(r2_5, 0), 2, "range(2,5): starts at 2")
assert_eq(index(r2_5, 2), 4, "range(2,5): ends at 4")

assert_eq(len(range(0)), 0, "range(0): empty")
assert_eq(len(range(5, 5)), 0, "range(5,5): empty")
assert_eq(len(range(5, 3)), 0, "range(5,3): reversed empty")

// --- at (list variant) ---
assert_eq(at(nums, 0), 10, "at list: first")
assert_eq(at(nums, 4), 50, "at list: last")
"""
}
