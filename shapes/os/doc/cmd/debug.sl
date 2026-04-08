shape os.doc.cmd.debug : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "debug <shape-id>"
  summary: "Trace dependency graph and find incoherence."
  see_also: "trace, validate, benchmark"
  """
== DESCRIPTION ==
Walks the dependency graph from the given shape, checks each
coherence law, and reports the first violation found.

Shows: shape info, all dependencies (with OK/DANGLING status),
all dependents (marking test shapes), content checks, tick freshness.

== EXAMPLES ==
  debug law.persistence
  debug os.shell.cmd.ls
"""
}
