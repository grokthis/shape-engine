shape os.test.lang.control : os.test {
  type: test
  layer: 3
  desc: "Control flow: if/else, for, while, break"
  """
// --- if/else ---
let x = 0
if true {
  set x = 1
}
assert_eq(x, 1, "if: true branch")

set x = 0
if false {
  set x = 1
} else {
  set x = 2
}
assert_eq(x, 2, "if/else: else branch")

// --- if/else if/else ---
set x = 0
let val = 5
if val > 10 {
  set x = 1
} else if val > 3 {
  set x = 2
} else {
  set x = 3
}
assert_eq(x, 2, "if/else if: middle branch")

// --- for loop ---
let total = 0
for i in range(5) {
  set total = total + i
}
assert_eq(total, 10, "for: sum 0..4 = 10")

// --- for over list ---
let words = ["a", "b", "c"]
let concat = ""
for w in words {
  set concat = concat + w
}
assert_eq(concat, "abc", "for: list iteration")

// --- while loop ---
let count = 0
while count < 5 {
  set count = count + 1
}
assert_eq(count, 5, "while: basic loop")

// --- while with break ---
set count = 0
while true {
  set count = count + 1
  if count == 3 {
    break
  }
}
assert_eq(count, 3, "while/break: exits at 3")

// --- nested loops ---
let sum = 0
for i in range(3) {
  for j in range(3) {
    set sum = sum + 1
  }
}
assert_eq(sum, 9, "nested for: 3x3 = 9")

// --- let / set scoping ---
let a = 10
set a = a + 5
assert_eq(a, 15, "let/set: mutation")
"""
}
