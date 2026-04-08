shape os.doc.cmd.test : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "test [suite] [-v] [--list|--history|--coverage|--moments|--branch]"
  summary: "Run structural tests. Tests are shapes that assert predicates over the graph."
  see_also: "cmd.validate, cmd.status"
  """
== DESCRIPTION ==
Runs the structural test suite. Each test is a shape under os.test.*
that evaluates shape-lang assertions against the live graph.

== OPTIONS ==
  test                    run all test suites
  test law                run only the law suite
  test -v                 verbose output
  test --list             list all test shapes
  test --history          show test execution history
  test --coverage         structural coverage report
  test --moments [N]      show last N moments
  test --branch           show trace branch state

== EXAMPLES ==
  test                    # run all 50 tests
  test engine -v          # verbose engine tests
  test --list             # see what's tested
"""
}
