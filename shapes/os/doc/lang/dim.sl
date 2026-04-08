shape os.doc.lang.dim : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "dim(id, key)"
  summary: "Read a dimension value from a shape."
  see_also: "lang.content, lang.exists"
  """
== DESCRIPTION ==
Returns the value of a specific dimension key on the given shape.

== EXAMPLES ==
  dim("os.shell.cmd.ls", "type")    // returns "exec"
  dim("engine", "layer")
"""
}
