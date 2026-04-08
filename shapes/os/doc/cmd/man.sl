shape os.doc.cmd.man : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "man [topic]"
  summary: "Display manual page for a command, concept, or law."
  see_also: "cmd.help"
  """
== DESCRIPTION ==
Displays the full manual page for a topic. Topics are looked up
under os.doc.cmd.*, os.doc.concept.*, os.doc.lang.*, os.doc.law.*,
and os.doc.engine.*.

With no argument, lists all available manual pages.

== EXAMPLES ==
  man ls                  # manual for ls command
  man law.0               # manual for Law 0
  man shape               # manual for the shape concept
"""
}
