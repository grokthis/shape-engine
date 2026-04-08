shape os.shell.cmd.account {
  type: exec
  layer: 4
  """
let user = actor()
if user == "" {
  print("not logged in. use: login <user-id>")
} else {
  print("Account: " + user)
  print(repeat("-", 40))

  // Tick balance.
  let balance_id = user + ".ticks.balance"
  let spent_id = user + ".ticks.spent"
  let balance = "0"
  let spent = "0"
  if exists(balance_id) {
    set balance = content(balance_id)
  }
  if exists(spent_id) {
    set spent = content(spent_id)
  }
  print("Ticks remaining:  " + balance)
  print("Ticks spent:      " + spent)

  // Config.
  let per_sp = content("os.config.ticks.per_sp")
  let monthly = content("os.config.ticks.monthly_base")
  let min_sub = content("os.config.ticks.min_subscription_sp")
  print("")
  print("Tick Economy:")
  print("  Rate:           " + per_sp + " ticks per SP")
  print("  Monthly base:   " + monthly + " ticks")
  print("  Min subscription: " + min_sub + " SP/month")

  // Trace audit: count moments by this actor.
  print("")
  print("Audit Trail:")
  let layers = range(0, 6)
  let total_moments = 0
  for l in layers {
    let mc = moments(l)
    let actor_moments = 0
    for i in range(0, mc) {
      let a = moment_actor(l, i)
      if a == user {
        set actor_moments = actor_moments + 1
      }
    }
    if actor_moments > 0 {
      print("  Layer " + l + ": " + actor_moments + " moments")
      set total_moments = total_moments + actor_moments
    }
  }
  if total_moments == 0 {
    print("  No traced moments yet.")
  } else {
    print("  Total: " + total_moments + " moments")
  }
}
"""
}
