shape os.doc.cmd.cd : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "cd [prefix]"
  summary: "Change current prefix. Use .. to go up, / for root."
  see_also: "cmd.pwd, cmd.ls, cmd.tree"
  """
== DESCRIPTION ==
Changes the current shape prefix. All relative IDs are resolved
under this prefix.

== EXAMPLES ==
  cd engine               # prefix is now engine
  cd ..                   # go up one level
  cd /                    # go to root
  cd os.shell             # absolute path
"""
}
