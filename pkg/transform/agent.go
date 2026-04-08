package transform

import (
	"github.com/ashbuilds/shape-engine/pkg/shape"
)

// AgentTransform executes an agent shape's content when its deps change.
// An agent is just a shape that watches other shapes. When a watched shape
// gets a new moment, the agent's handler fires. The handler is shape-lang
// stored in the agent shape's content.
//
// To create an agent, declare a shape with:
//   - type: agent
//   - fn: agent.exec (this transform)
//   - deps on the shapes to watch
//   - content = shape-lang handler
//
// The handler receives the change source in its scope as "source" and
// the new content as "change". The handler's output replaces the agent's
// content (the agent's state).
type AgentTransform struct {
	// Eval is the function that evaluates shape-lang.
	// Injected by the caller to avoid circular dependency with pkg/lang.
	Eval func(source string, content string, eng interface{}) (string, error)
}

// Name returns "agent.exec".
func (a *AgentTransform) Name() string {
	return "agent.exec"
}

// Apply is a no-op — agents don't transform on direct edit.
func (a *AgentTransform) Apply(c shape.Character, s shape.Structure) (shape.Character, error) {
	return c, nil
}

// Propagate fires the agent's handler when a dependency changes.
func (a *AgentTransform) Propagate(change Change, self *shape.Shape) (PropagationResult, string, error) {
	handler := self.Character.Content
	if handler == "" {
		return NoChange, "", nil
	}

	// If no evaluator is wired up, just flag for review.
	if a.Eval == nil {
		return FlagForReview, "", nil
	}

	// Execute the handler. The source ID and change content are available
	// to the handler through the evaluator's scope.
	output, err := a.Eval(string(change.Source), handler, nil)
	if err != nil {
		// Agent errors don't block propagation. The agent shape gets
		// updated with the error as state.
		return AutoUpdate, "error: " + err.Error(), nil
	}

	// Agent state = last output. This is the agent's "memory" between events.
	if output != "" {
		return AutoUpdate, output, nil
	}
	return NoChange, "", nil
}
