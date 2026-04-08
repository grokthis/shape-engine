shape os.agent.tick_logger : os.agent.registry {
  type: agent
  fn: agent.exec
  layer: 3
  """
// Tick logger: records global tick on every mutation.
let t = global_tick()
concat("last_event: ", source, " at tick ", to_string(t))
"""
}
