shape os.doc.cmd.validate : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "validate"
  summary: "Run coherence check on all shapes (Laws 0-3)."
  see_also: "law.persistence, law.reference, law.conservation, law.consistency, cmd.status"
  """
== DESCRIPTION ==
Checks every shape in the graph for structural coherence.
Reports violations of any of the four laws. A clean validate
means the system is coherent.

== EXAMPLES ==
  validate                # check everything
"""
}
