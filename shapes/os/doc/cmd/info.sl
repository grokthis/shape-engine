shape os.doc.cmd.info : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "info <id>"
  summary: "Full shape dump including structure, deps, layer, tick."
  see_also: "cmd.cat, cmd.deps"
  """
== DESCRIPTION ==
Shows everything about a shape: character (dimensions + content),
structure (deps, emergence, permissions), and tick.

== EXAMPLES ==
  info engine             # full dump
  info os.shell.cmd.ls    # see how a command is structured
"""
}
