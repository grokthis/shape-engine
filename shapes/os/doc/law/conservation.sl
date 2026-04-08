shape os.doc.law.conservation : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "Law 2: Conservation"
  summary: "No structure from nothing, no destruction into nothing."
  see_also: "law.persistence, law.reference, law.consistency, cmd.mkdir, cmd.rm"
  """
== DESCRIPTION ==
Structure is conserved. You cannot create a shape from nothing.
Every non-foundational shape must declare dependencies: where
it came from, what it depends on.

You cannot destroy structure into nothing either. If other shapes
depend on a shape, removing it would break their references (Law 1).

== EXAMPLES ==
  mkdir user.project     # requires parent 'user' to exist
  rm user.project        # fails if anything depends on it
"""
}
