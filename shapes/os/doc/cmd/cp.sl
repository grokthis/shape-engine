shape os.doc.cmd.cp : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "cp <src> <dst>"
  summary: "Clone a shape to a new ID."
  see_also: "cmd.mv, cmd.mkdir"
  """
== DESCRIPTION ==
Copies a shape's character to a new ID. The new shape gets
the same dimensions and content but a fresh structure.

== EXAMPLES ==
  cp user.template user.new-project
"""
}
