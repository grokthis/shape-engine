shape os.doc.cmd.mkdir : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "mkdir <id>"
  summary: "Create an empty shape."
  see_also: "cmd.rm, cmd.cp, cmd.mv"
  """
== DESCRIPTION ==
Creates a new empty shape at the given ID. The parent shape
must exist (Law 2: no structure from nothing).

== EXAMPLES ==
  mkdir user.project      # create under user
"""
}
