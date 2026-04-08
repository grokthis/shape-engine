shape os.doc.cmd.echo : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "echo <text> > <id>"
  summary: "Set shape content via redirect."
  see_also: "cmd.edit, cmd.cat"
  """
== DESCRIPTION ==
Sets a shape's content using shell redirect syntax.

== EXAMPLES ==
  echo "hello world" > user.greeting
"""
}
