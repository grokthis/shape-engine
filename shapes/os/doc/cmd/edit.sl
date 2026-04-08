shape os.doc.cmd.edit : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "edit <id> <content>"
  summary: "Edit shape content and propagate the wave."
  see_also: "cmd.echo, cmd.cat, cmd.wave"
  """
== DESCRIPTION ==
Sets a shape's content and triggers wave propagation through
all dependents. This is the primary mutation operation.

== EXAMPLES ==
  edit engine.desc "The shape engine."
"""
}
