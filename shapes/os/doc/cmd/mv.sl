shape os.doc.cmd.mv : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "mv <src> <dst>"
  summary: "Move/rename a shape, updating references."
  see_also: "cmd.cp, cmd.rm"
  """
== DESCRIPTION ==
Renames a shape. Updates any shapes that depend on the old ID
to point to the new ID.

== EXAMPLES ==
  mv user.draft user.final
"""
}
