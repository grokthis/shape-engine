shape os.doc.law.reference : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "Law 1: Stable Reference"
  summary: "References must close, point to invariants, or be bounded."
  see_also: "law.persistence, law.conservation, law.consistency, cmd.deps, cmd.dependents"
  """
== DESCRIPTION ==
Every reference in the system must resolve. Dangling references
are incoherent and trigger dissolution (Law 0).

References can close (point to something that exists), point to
invariants (the axiom, foundational shapes), or be bounded
(scoped to a specific context).

== EXAMPLES ==
  deps engine.edit       # see what engine.edit references
  dependents shape       # see what depends on the shape primitive
"""
}
