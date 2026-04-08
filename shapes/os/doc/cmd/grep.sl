shape os.doc.cmd.grep : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "grep <pattern>"
  summary: "Search shape content for pattern."
  see_also: "cmd.find, cmd.cat"
  """
== DESCRIPTION ==
Searches the content of all shapes for the given pattern.
Returns matching shape IDs with context.

== EXAMPLES ==
  grep propagat           # find shapes mentioning propagation
  grep "type: exec"       # find executable shapes (via dims)
"""
}
