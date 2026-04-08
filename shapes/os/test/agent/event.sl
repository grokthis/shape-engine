shape os.test.agent.event : os.test {
  type: test
  layer: 3
  desc: "Event and notification system shapes exist"
  """
assert_true(exists("os.event"), "os.event exists")
assert_true(exists("os.notify"), "os.notify exists")
assert_true(exists("os.notify.queue"), "os.notify.queue exists")
assert_true(exists("os.clipboard"), "os.clipboard exists")
"""
}
