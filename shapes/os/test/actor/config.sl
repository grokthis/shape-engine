shape os.test.actor.config : os.test {
  type: test
  layer: 4
  desc: "Tick economy config shapes exist"
  """
assert_true(exists("os.config.ticks"), "tick config exists")
assert_true(exists("os.config.ticks.per_sp"), "ticks per SP config exists")
assert_true(exists("os.config.ticks.monthly_base"), "monthly base config exists")
assert_true(exists("os.config.ticks.min_subscription_sp"), "min subscription config exists")

// Values are sensible.
let per_sp = content("os.config.ticks.per_sp")
assert_neq(per_sp, "", "ticks per SP has value")
assert_neq(per_sp, "0", "ticks per SP is nonzero")

let monthly = content("os.config.ticks.monthly_base")
assert_neq(monthly, "", "monthly base has value")
"""
}
