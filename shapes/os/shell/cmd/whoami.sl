shape os.shell.cmd.whoami {
  type: exec
  layer: 4
  """
let user = actor()
if user == "" {
  print("anonymous (no session actor set)")
  print("use: login <user-id> to set session actor")
} else {
  print(user)
  if exists(user) {
    let name = dim(user, "name")
    if name != "" {
      print("  name: " + name)
    }
    let acct = dim(user, "account_type")
    if acct != "" {
      print("  account: " + acct)
    }
  }
  // Show tick balance.
  let balance_id = user + ".ticks.balance"
  let spent_id = user + ".ticks.spent"
  if exists(balance_id) {
    print("  ticks remaining: " + content(balance_id))
  }
  if exists(spent_id) {
    print("  ticks spent:     " + content(spent_id))
  }
}
"""
}
