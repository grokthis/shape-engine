shape os.doc.cmd.ask : os.doc {
  type: doc
  layer: 4
  section: 1
  synopsis: "ask <question>"
  summary: "Ask the LLM agent to construct shapes. The agent emits shape-lang."
  see_also: "cmd.agent"
  """
== DESCRIPTION ==
Sends a request to the LLM agent. The agent reads the system prompt
(os.agent.llm.prompt), calls the LLM API, and evaluates the
shape-lang response. Each step is recorded as a shape.

Requires an API key in os.config.llm.api_key (set via Settings).

== OPTIONS ==
  ask <question>          start an agent task
  ask status              show current/last task
  ask steps <task-id>     show steps for a task

== EXAMPLES ==
  ask "create a shape for my project"
  ask status
"""
}
