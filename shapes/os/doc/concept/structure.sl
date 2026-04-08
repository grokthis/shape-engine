shape os.doc.concept.structure : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "structure — the geometry"
  summary: "Dependencies, emergence layer, permissions. The invariant part governing transformation."
  see_also: "concept.shape, concept.character, cmd.deps, cmd.wave"
  """
== DESCRIPTION ==
Structure governs how a shape transforms. It has:
  - Transformation: dependencies (what this shape depends on),
    transform function (fn)
  - Emergence: layer number, what it emerged from
  - Permissions: who can edit

Structure is what makes a shape coherent. Breaking structure
breaks coherence (Law 0).

== EXAMPLES ==
  deps engine             # see structure: what engine depends on
  wave engine             # see propagation path
"""
}
