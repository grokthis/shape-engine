shape os.doc.cmd.find : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "find <pattern>"
  summary: "Search shapes by ID pattern."
  see_also: "cmd.grep, cmd.ls"
  """
== DESCRIPTION ==
Searches all shape IDs for the given pattern (substring match).

== EXAMPLES ==
  find edit               # all shapes with 'edit' in the ID
  find os.config          # all config shapes
"""
}
