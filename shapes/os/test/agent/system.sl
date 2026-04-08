shape os.test.agent.system : os.test {
  type: test
  layer: 3
  desc: "Agent system shapes exist"
  """
assert_true(exists("os.agent"), "os.agent exists")
assert_true(exists("os.agent.registry"), "os.agent.registry exists")
assert_true(dim("os.agent", "type") == "system", "os.agent type is system")
"""
}
