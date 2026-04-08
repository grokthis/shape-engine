shape os.doc.cmd.ls : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "ls [prefix]"
  summary: "List shapes at current or given prefix."
  see_also: "cmd.cd, cmd.tree, cmd.find"
  """
== DESCRIPTION ==
Lists child shapes at the current prefix (or a given prefix).
Shows the shape ID segments directly under the prefix.

== EXAMPLES ==
  ls                      # list at current prefix
  ls os.shell.cmd         # list all shell commands
  ls engine               # list engine children
"""
}
