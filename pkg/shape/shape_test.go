// Layer 0 tests. The axiom must be solid.
package shape

import (
	"encoding/json"
	"testing"
)

// --- Shape construction ---

func TestShapeZeroValue(t *testing.T) {
	var s Shape
	if s.ID != "" {
		t.Error("zero-value ID should be empty")
	}
	if s.Character.Content != "" {
		t.Error("zero-value content should be empty")
	}
	if s.Character.Dimensions != nil {
		t.Error("zero-value dimensions should be nil")
	}
	if s.Structure.Emergence.Layer != 0 {
		t.Error("zero-value layer should be 0")
	}
	if len(s.Structure.Transformation.Deps) != 0 {
		t.Error("zero-value deps should be empty")
	}
}

func TestShapeIdentity(t *testing.T) {
	a := Shape{ID: "test.a"}
	b := Shape{ID: "test.a"}
	c := Shape{ID: "test.b"}

	if a.ID != b.ID {
		t.Error("same ID should be equal")
	}
	if a.ID == c.ID {
		t.Error("different ID should not be equal")
	}
}

func TestIDHierarchy(t *testing.T) {
	id := ID("user.ash.shape-engine.pkg.shape")
	if id == "" {
		t.Error("ID should not be empty")
	}
	// IDs are dot-separated, string type, no validation at this layer.
	// That's correct: the axiom is minimal.
}

// --- Character ---

func TestCharacterDimensions(t *testing.T) {
	c := Character{
		Dimensions: map[string]string{
			"type": "func",
			"name": "NewWidget",
		},
		Content: "func NewWidget() {}",
	}
	if c.Dimensions["type"] != "func" {
		t.Error("dimension lookup failed")
	}
	if c.Content != "func NewWidget() {}" {
		t.Error("content mismatch")
	}
}

func TestCharacterNilDimensions(t *testing.T) {
	c := Character{}
	// nil map read returns zero value, doesn't panic.
	if c.Dimensions["anything"] != "" {
		t.Error("nil map lookup should return empty string")
	}
}

// --- Structure ---

func TestTransformationDeps(t *testing.T) {
	s := Shape{
		ID: "test.derived",
		Structure: Structure{
			Transformation: Transformation{
				Fn:   "paper.FormalDerivation",
				Deps: []ID{"test.axiom", "test.definition"},
			},
		},
	}
	if len(s.Structure.Transformation.Deps) != 2 {
		t.Errorf("expected 2 deps, got %d", len(s.Structure.Transformation.Deps))
	}
	if s.Structure.Transformation.Fn != "paper.FormalDerivation" {
		t.Error("transform function name mismatch")
	}
}

func TestConstraintValues(t *testing.T) {
	c := Constraint{Law: 1, Status: Satisfied, Note: "all refs close"}
	if c.Law != 1 {
		t.Error("law should be 1")
	}
	if c.Status != Satisfied {
		t.Error("status should be satisfied")
	}
}

func TestEmergence(t *testing.T) {
	e := Emergence{
		Layer:    3,
		From:     []ID{"layer2.a", "layer2.b"},
		Produces: []ID{"layer4.x"},
	}
	if e.Layer != 3 {
		t.Error("layer mismatch")
	}
	if len(e.From) != 2 {
		t.Errorf("expected 2 From, got %d", len(e.From))
	}
	if len(e.Produces) != 1 {
		t.Errorf("expected 1 Produces, got %d", len(e.Produces))
	}
}

// --- Serialization round-trips ---

func TestJSONRoundTrip(t *testing.T) {
	s := Shape{
		ID: "test.roundtrip",
		Character: Character{
			Dimensions: map[string]string{"type": "axiom", "name": "persistence"},
			Content:    "What persists must cohere.",
		},
		Structure: Structure{
			Transformation: Transformation{
				Fn:   "paper.FormalDerivation",
				Deps: []ID{"test.dep1", "test.dep2"},
				Constraints: []Constraint{
					{Law: 0, Status: Satisfied},
					{Law: 1, Status: Unchecked, Note: "pending"},
				},
			},
			Emergence: Emergence{
				Layer:    2,
				From:     []ID{"layer1.root"},
				Produces: []ID{"layer3.derived"},
			},
		},
	}

	data, err := json.Marshal(s)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	var s2 Shape
	if err := json.Unmarshal(data, &s2); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}

	if s2.ID != s.ID {
		t.Errorf("ID: got %q, want %q", s2.ID, s.ID)
	}
	if s2.Character.Content != s.Character.Content {
		t.Errorf("content mismatch")
	}
	if len(s2.Character.Dimensions) != 2 {
		t.Errorf("dimensions: got %d, want 2", len(s2.Character.Dimensions))
	}
	if s2.Character.Dimensions["type"] != "axiom" {
		t.Error("dimension type mismatch")
	}
	if s2.Structure.Transformation.Fn != "paper.FormalDerivation" {
		t.Error("transform fn mismatch")
	}
	if len(s2.Structure.Transformation.Deps) != 2 {
		t.Errorf("deps: got %d, want 2", len(s2.Structure.Transformation.Deps))
	}
	if len(s2.Structure.Transformation.Constraints) != 2 {
		t.Errorf("constraints: got %d, want 2", len(s2.Structure.Transformation.Constraints))
	}
	if s2.Structure.Emergence.Layer != 2 {
		t.Errorf("layer: got %d, want 2", s2.Structure.Emergence.Layer)
	}
	if len(s2.Structure.Emergence.From) != 1 {
		t.Errorf("from: got %d, want 1", len(s2.Structure.Emergence.From))
	}
	if len(s2.Structure.Emergence.Produces) != 1 {
		t.Errorf("produces: got %d, want 1", len(s2.Structure.Emergence.Produces))
	}
}

func TestJSONEmptyShape(t *testing.T) {
	s := Shape{ID: "empty"}
	data, err := json.Marshal(s)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	var s2 Shape
	if err := json.Unmarshal(data, &s2); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if s2.ID != "empty" {
		t.Errorf("ID: got %q", s2.ID)
	}
	// Nil maps should round-trip cleanly (omitempty).
	if s2.Character.Dimensions != nil && len(s2.Character.Dimensions) != 0 {
		t.Error("empty dimensions should round-trip as nil or empty")
	}
}

// --- Edge cases ---

func TestIDWithSpecialCharacters(t *testing.T) {
	// IDs with hyphens, numbers, underscores are valid.
	ids := []ID{
		"user.ash-kid",
		"vol8.08a.part3",
		"layer_0.axiom",
		"a.b.c.d.e.f.g",
		"single",
	}
	for _, id := range ids {
		s := Shape{ID: id}
		data, _ := json.Marshal(s)
		var s2 Shape
		json.Unmarshal(data, &s2)
		if s2.ID != id {
			t.Errorf("ID round-trip failed: got %q, want %q", s2.ID, id)
		}
	}
}

func TestConstraintLawRange(t *testing.T) {
	// Laws 0-3 are valid. The axiom doesn't enforce this (it's just a number).
	// Enforcement is at the engine layer.
	for law := 0; law <= 3; law++ {
		c := Constraint{Law: law, Status: Satisfied}
		if c.Law != law {
			t.Errorf("law %d round-trip failed", law)
		}
	}
}
