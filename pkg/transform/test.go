// TestTransform auto-runs test shapes when their dependencies change.
//
// When a shape with type=test depends on another shape and that shape
// changes, the wave reaches the test. The transform evaluates the test
// content and records the result as a constraint on the test shape:
//   - Law 0, satisfied: test passed
//   - Law 0, violated: test failed (note contains the error)
//
// The test IS part of the structure. It runs on every mutation.
package transform

import (
	"github.com/ashbuilds/shape-engine/pkg/shape"
)

// TestTransform handles propagation for shapes with type=test.
// The Eval function is injected by the application layer (cmd/shape)
// because evaluation requires the lang package which would create
// an import cycle.
type TestTransform struct {
	// Eval runs shape-lang code and returns (output, error).
	// The application layer wires this to lang.Eval.
	Eval func(source string, content string) (string, error)
}

func (t *TestTransform) Name() string { return "shape.Test" }

func (t *TestTransform) Apply(c shape.Character, s shape.Structure) (shape.Character, error) {
	return c, nil
}

// Propagate runs the test when a dependency changes.
// Returns AutoUpdate with the test result as new content annotation.
func (t *TestTransform) Propagate(change Change, self *shape.Shape) (PropagationResult, string, error) {
	if t.Eval == nil {
		return FlagForReview, "", nil
	}

	// Only run if this shape is actually a test.
	if self.Character.Dimensions["type"] != "test" {
		return NoChange, "", nil
	}

	content := self.Character.Content
	if content == "" {
		return NoChange, "", nil
	}

	// Run the test.
	_, err := t.Eval(string(self.ID), content)

	if err != nil {
		// Test failed: record as violated constraint.
		self.Structure.Transformation.Constraints = []shape.Constraint{{
			Law:    0,
			Status: shape.Violated,
			Note:   err.Error(),
		}}
		return AutoUpdate, content, nil
	}

	// Test passed: record as satisfied constraint.
	self.Structure.Transformation.Constraints = []shape.Constraint{{
		Law:    0,
		Status: shape.Satisfied,
		Note:   "pass",
	}}
	return AutoUpdate, content, nil
}
