shape os.doc.law.consistency : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "Law 3: Consistency"
  summary: "Coupled incompatible shapes must resolve or trigger dissolution."
  see_also: "law.persistence, law.reference, law.conservation, cmd.validate"
  """
== DESCRIPTION ==
Contradictions in contact cannot persist. When two shapes in the
same context make incompatible claims, they must resolve or one
dissolves.

The validation system checks for contradictions across the graph.
The wave propagation system ensures changes cascade correctly.

== EXAMPLES ==
  validate               # detect contradictions
  wave engine            # see what would change
"""
}
