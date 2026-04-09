shape os.debug : os {
  type: system
  layer: 4
  """
// Debug Mode.
//
// When --debug is set, the engine prints every operation:
//   [eval] shape_id: entering
//   [call] shapes_under("os.app") -> 9 results
//   [get]  os.app.shell -> found
//   [edit] os.app.shell.content = "..."
//   [prop] os.app.shell -> 3 dependents
//   [cond] if x == 0 -> true
//   [loop] for i in range(10): iteration 3
//   [ret]  auto "result"
//
// Debug is a process-level flag: debug()
// Returns true if --debug was passed on launch.
//
// In shape-lang code:
//   if debug() { print("[debug] my message") }
//
// The engine itself checks this flag in every builtin:
//   shapes_under, deps, dependents, content, dim, exists,
//   set_content, set_dim, add_shape, rm, etc.
//
// The output IS the trace. The trace IS the debug.
// No separate debug tool needed. The execution is the explanation.
  """
}
