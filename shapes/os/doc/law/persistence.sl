shape os.doc.law.persistence : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "Law 0: Persistence"
  summary: "A shape persists stably only if its structure is coherent."
  see_also: "law.1, law.2, law.3"
  """
== DESCRIPTION ==
Law 0 is the axiom. Everything else derives from it.
A shape persists only if its structure is coherent. Incoherence
dissolves. This is not a rule imposed from outside. It is the
definition of what it means to persist.

== IMPLICATIONS ==
When you edit a shape and break a reference, the system detects it.
When you create structure from nothing (no deps), Law 2 catches it.
When contradictions exist in contact, Law 3 flags them.
All three are consequences of Law 0.

== EXAMPLES ==
  validate              # check all shapes for coherence
  status                # see current engine state
"""
}
