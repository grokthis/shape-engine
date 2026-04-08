shape os.doc.cmd.wave : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "wave <id>"
  summary: "Show what would change if this shape changed."
  see_also: "cmd.deps, cmd.dependents, cmd.edit"
  """
== DESCRIPTION ==
Computes and displays the propagation wave: all shapes that
would be affected if this shape were edited. Shows the cascade
through the dependency graph.

== EXAMPLES ==
  wave shape              # massive cascade
  wave user.config        # smaller local wave
"""
}
