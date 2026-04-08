shape os.doc.concept.tick : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "tick — global counter"
  summary: "Monotonic counter incremented on every mutation. Every shape records when it last changed."
  see_also: "cmd.tick, cmd.status"
  """
== DESCRIPTION ==
The tick is a global monotonic counter. Every mutation increments
it. Every shape records its tick: when it was last modified.

Ticks provide causal ordering. If shape A has tick 5 and shape B
has tick 7, B was modified more recently.

== EXAMPLES ==
  tick                    # current global tick
  cat engine.edit         # shows tick field
"""
}
