shape os.doc.concept.wave : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "wave — propagation"
  summary: "When a shape changes, the wave propagates through dependents."
  see_also: "concept.shape, cmd.wave, cmd.edit"
  """
== DESCRIPTION ==
When you edit a shape, every shape that depends on it is affected.
This is wave propagation. The engine computes the wave: which
shapes would change if this shape changed.

Transforms can be auto-update, flag-for-review, or no-change.
The wave respects layer boundaries and trace locks.

== EXAMPLES ==
  wave shape              # what depends on the shape primitive?
  edit engine.edit "..."  # edit triggers propagation
"""
}
