shape os.shell.cmd.login {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("login: need user ID (e.g. login user.ash)")
} else {
  // Use absolute ID if it starts with "user.", otherwise resolve.
  let user_id = arg0
  if !has_prefix(arg0, "user.") {
    set user_id = "user." + arg0
  }
  set_actor(user_id)
  print("session actor: " + user_id)

  // Ensure tick accounting shapes exist.
  let balance_id = user_id + ".ticks.balance"
  let spent_id = user_id + ".ticks.spent"
  if !exists(balance_id) {
    // New user gets the monthly base ticks.
    let base = content("os.config.ticks.monthly_base")
    add_shape(balance_id, "account", base)
    add_shape(spent_id, "account", "0")
    print("  initialized tick balance: " + base)
  }
}
"""
}
