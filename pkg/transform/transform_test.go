// Layer 2 tests. Transform registry and the propagation trichotomy.
package transform

import (
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/shape"
)

// mockTransform implements TransformFn for testing.
type mockTransform struct {
	name      string
	applyErr  error
	propResult PropagationResult
	propContent string
	propErr    error
}

func (m *mockTransform) Name() string { return m.name }
func (m *mockTransform) Apply(c shape.Character, s shape.Structure) (shape.Character, error) {
	if m.applyErr != nil {
		return c, m.applyErr
	}
	c.Content = "[transformed] " + c.Content
	return c, nil
}
func (m *mockTransform) Propagate(change Change, self *shape.Shape) (PropagationResult, string, error) {
	return m.propResult, m.propContent, m.propErr
}

func TestNewRegistry(t *testing.T) {
	r := NewRegistry()
	if r == nil {
		t.Fatal("NewRegistry returned nil")
	}
}

func TestRegisterAndGet(t *testing.T) {
	r := NewRegistry()
	fn := &mockTransform{name: "test.Mock"}
	r.Register(fn)

	got, ok := r.Get("test.Mock")
	if !ok {
		t.Fatal("registered transform not found")
	}
	if got.Name() != "test.Mock" {
		t.Errorf("name: %s", got.Name())
	}
}

func TestGetMissing(t *testing.T) {
	r := NewRegistry()
	_, ok := r.Get("nonexistent")
	if ok {
		t.Error("should not find unregistered transform")
	}
}

func TestRegisterOverwrites(t *testing.T) {
	r := NewRegistry()
	fn1 := &mockTransform{name: "test.Same", propResult: NoChange}
	fn2 := &mockTransform{name: "test.Same", propResult: FlagForReview}
	r.Register(fn1)
	r.Register(fn2) // overwrites

	got, _ := r.Get("test.Same")
	result, _, _ := got.Propagate(Change{}, nil)
	if result != FlagForReview {
		t.Error("second registration should overwrite first")
	}
}

func TestPropagationTrichotomy(t *testing.T) {
	// The three possible outcomes. No fourth option (Theorem 6.3).
	if NoChange != 0 {
		t.Error("NoChange should be 0")
	}
	if AutoUpdate != 1 {
		t.Error("AutoUpdate should be 1")
	}
	if FlagForReview != 2 {
		t.Error("FlagForReview should be 2")
	}
}

func TestApply(t *testing.T) {
	fn := &mockTransform{name: "test.Apply"}
	c := shape.Character{Content: "hello"}
	s := shape.Structure{}

	result, err := fn.Apply(c, s)
	if err != nil {
		t.Fatal(err)
	}
	if result.Content != "[transformed] hello" {
		t.Errorf("content: %s", result.Content)
	}
}

func TestChangeStruct(t *testing.T) {
	c := Change{
		Source:          "test.source",
		PreviousContent: "old",
		NewContent:      "new",
	}
	if c.Source != "test.source" {
		t.Error("source mismatch")
	}
	if c.PreviousContent != "old" {
		t.Error("previous content mismatch")
	}
	if c.NewContent != "new" {
		t.Error("new content mismatch")
	}
}
