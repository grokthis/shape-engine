shape os.doc.app.shell : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Terminal + interactive shell"
  summary: "A Linux-style shell operating on the shape graph."
  see_also: "cmd.ls, cmd.cd, cmd.cat, concept.shape"
  """
== DESCRIPTION ==
The shell is a REPL that operates on the shape engine.
It provides Unix-familiar commands (ls, cd, cat, grep, find)
adapted for the shape graph, plus shape-native commands
(deps, wave, validate, trace).

== KEYBOARD SHORTCUTS ==
  Up/Down    history navigation
  Tab        command completion

== COMMANDS ==
Type 'help' for a summary of available commands.
Type 'man <command>' for detailed documentation.

== PIPING ==
Commands compose via |:
  ls | grep edit
  deps engine | tree

== SEE ALSO ==
Use 'man' to browse all commands.
"""
}
