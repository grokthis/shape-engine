shape os.doc.cmd.tree : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "tree [prefix]"
  summary: "Recursive tree view of shapes under prefix."
  see_also: "cmd.ls, cmd.find"
  """
== DESCRIPTION ==
Shows all shapes under the given prefix (or current prefix)
as an indented tree. Useful for exploring the shape hierarchy.

== EXAMPLES ==
  tree                    # tree from current prefix
  tree os.config          # all config shapes
"""
}
