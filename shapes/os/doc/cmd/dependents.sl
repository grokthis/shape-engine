shape os.doc.cmd.dependents : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "dependents <id>"
  summary: "Show what depends on this shape (reverse deps)."
  see_also: "cmd.deps, cmd.wave"
  """
== DESCRIPTION ==
Lists all shapes that depend on the given shape. If you edit
this shape, all dependents will be affected by the wave.

== EXAMPLES ==
  dependents shape        # everything derived from shape
  dependents law          # what depends on the law?
"""
}
