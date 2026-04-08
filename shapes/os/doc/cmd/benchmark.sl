shape os.doc.cmd.benchmark : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "benchmark"
  summary: "Compute benchmark report from trace moments."
  see_also: "trace, debug, status"
  """
== DESCRIPTION ==
Analyzes the trace log to produce a benchmark report. All data is
computed after the fact from the structural trace, not measured
during execution.

Shows: moment counts by action type, wave propagation statistics
(total auto-updated, total flagged, max/avg wave width), and
shape graph statistics.

== EXAMPLES ==
  benchmark
"""
}
