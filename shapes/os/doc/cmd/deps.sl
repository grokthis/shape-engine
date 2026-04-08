shape os.doc.cmd.deps : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "deps <id>"
  summary: "Show what a shape depends on."
  see_also: "cmd.dependents, cmd.wave, cmd.info"
  """
== DESCRIPTION ==
Lists all dependencies of a shape: what it was derived from,
what it references. These are the edges in the shape graph.

== EXAMPLES ==
  deps engine.edit        # what does engine.edit depend on?
  deps os.shell.cmd.ls    # command dependencies
"""
}
