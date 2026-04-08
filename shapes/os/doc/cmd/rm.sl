shape os.doc.cmd.rm : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "rm <id>"
  summary: "Delete shape (fails if other shapes depend on it)."
  see_also: "cmd.mkdir, cmd.dependents"
  """
== DESCRIPTION ==
Removes a shape from the graph. Fails if any other shapes
depend on it (Law 1: references must close).

== EXAMPLES ==
  rm user.temp            # remove if no dependents
  dependents user.temp    # check first
"""
}
