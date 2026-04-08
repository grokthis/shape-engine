package shape

import (
	"testing"
)

func TestBinaryRoundTrip(t *testing.T) {
	shapes := []*Shape{
		{
			ID:   "engine",
			Tick: 42,
			Character: Character{
				Dimensions: map[string]string{
					"type":  "type",
					"name":  "Engine",
					"layer": "3",
				},
				Content: "The composition layer.",
			},
			Structure: Structure{
				Transformation: Transformation{
					Deps: []ID{"shape", "engine.trace"},
				},
				Emergence: Emergence{
					Layer: 3,
					From:  []ID{"shape", "engine.trace"},
				},
			},
		},
		{
			ID:   "engine.edit",
			Tick: 42,
			Character: Character{
				Dimensions: map[string]string{
					"type":  "func",
					"name":  "Edit",
					"layer": "3",
				},
				Content: "Modifies a shape's character and propagates the wave.",
			},
			Structure: Structure{
				Transformation: Transformation{
					Fn:   "engine.Propagation",
					Deps: []ID{"engine", "engine.propagate", "engine.trace"},
				},
				Emergence: Emergence{
					Layer: 3,
					From:  []ID{"engine"},
				},
			},
		},
		{
			ID:   "shape",
			Tick: 0,
			Character: Character{
				Dimensions: map[string]string{
					"type":  "axiom",
					"layer": "0",
				},
				Content: "The irreducible primitive.",
			},
			Structure: Structure{
				Emergence: Emergence{
					Layer:    0,
					Produces: []ID{"engine"},
				},
			},
		},
	}

	data, err := MarshalGraph(42, shapes)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	tick, got, err := UnmarshalGraph(data)
	if err != nil {
		t.Fatalf("unmarshal: %v", err)
	}

	if tick != 42 {
		t.Errorf("tick = %d, want 42", tick)
	}

	if len(got) != 3 {
		t.Fatalf("got %d shapes, want 3", len(got))
	}

	// Shapes are sorted by ID in the binary
	// engine, engine.edit, shape
	assertShape(t, got[0], "engine", 42, 3, "The composition layer.")
	assertShape(t, got[1], "engine.edit", 42, 3, "Modifies a shape's character and propagates the wave.")
	assertShape(t, got[2], "shape", 0, 0, "The irreducible primitive.")

	// Check deps
	if len(got[0].Structure.Transformation.Deps) != 2 {
		t.Errorf("engine deps = %d, want 2", len(got[0].Structure.Transformation.Deps))
	}
	if got[1].Structure.Transformation.Fn != "engine.Propagation" {
		t.Errorf("edit fn = %q, want engine.Propagation", got[1].Structure.Transformation.Fn)
	}

	// Check emergence
	if len(got[2].Structure.Emergence.Produces) != 1 || got[2].Structure.Emergence.Produces[0] != "engine" {
		t.Errorf("shape produces = %v, want [engine]", got[2].Structure.Emergence.Produces)
	}

	// Check dimensions
	if got[0].Character.Dimensions["name"] != "Engine" {
		t.Errorf("engine name = %q, want Engine", got[0].Character.Dimensions["name"])
	}
}

func TestBinaryRoundTripWithPermissions(t *testing.T) {
	shapes := []*Shape{
		{
			ID:   "user.ash.post.1",
			Tick: 100,
			Character: Character{
				Content: "A post about shapes.",
			},
			Structure: Structure{
				Transformation: Transformation{
					Deps: []ID{"user.ash"},
				},
				Permissions: Permissions{
					Blocked:    []ID{"user.troll"},
					Visibility: []string{"public"},
					Warning:    "Permission withdrawn.",
				},
			},
		},
	}

	data, err := MarshalGraph(100, shapes)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	tick, got, err := UnmarshalGraph(data)
	if err != nil {
		t.Fatalf("unmarshal: %v", err)
	}

	if tick != 100 {
		t.Errorf("tick = %d, want 100", tick)
	}

	s := got[0]
	if len(s.Structure.Permissions.Blocked) != 1 || s.Structure.Permissions.Blocked[0] != "user.troll" {
		t.Errorf("blocked = %v, want [user.troll]", s.Structure.Permissions.Blocked)
	}
	if s.Structure.Permissions.Warning != "Permission withdrawn." {
		t.Errorf("warning = %q", s.Structure.Permissions.Warning)
	}
}

func TestBinaryRoundTripWithConstraints(t *testing.T) {
	shapes := []*Shape{
		{
			ID: "test.constrained",
			Structure: Structure{
				Transformation: Transformation{
					Constraints: []Constraint{
						{Law: 1, Status: Satisfied, Note: "all refs close"},
						{Law: 3, Status: Violated, Note: "contradiction found"},
					},
				},
			},
		},
	}

	data, err := MarshalGraph(0, shapes)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	_, got, err := UnmarshalGraph(data)
	if err != nil {
		t.Fatalf("unmarshal: %v", err)
	}

	cs := got[0].Structure.Transformation.Constraints
	if len(cs) != 2 {
		t.Fatalf("constraints = %d, want 2", len(cs))
	}
	if cs[0].Law != 1 || cs[0].Status != Satisfied || cs[0].Note != "all refs close" {
		t.Errorf("constraint 0 = %+v", cs[0])
	}
	if cs[1].Law != 3 || cs[1].Status != Violated {
		t.Errorf("constraint 1 = %+v", cs[1])
	}
}

func TestBinaryEmptyGraph(t *testing.T) {
	data, err := MarshalGraph(0, nil)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	tick, shapes, err := UnmarshalGraph(data)
	if err != nil {
		t.Fatalf("unmarshal: %v", err)
	}

	if tick != 0 {
		t.Errorf("tick = %d, want 0", tick)
	}
	if len(shapes) != 0 {
		t.Errorf("shapes = %d, want 0", len(shapes))
	}
}

func TestBinaryBadMagic(t *testing.T) {
	_, _, err := UnmarshalGraph([]byte("NOPE"))
	if err == nil {
		t.Fatal("expected error for bad magic")
	}
}

func TestBinaryTruncated(t *testing.T) {
	_, _, err := UnmarshalGraph([]byte("SH"))
	if err == nil {
		t.Fatal("expected error for truncated data")
	}
}

func TestBinaryDeterministic(t *testing.T) {
	shapes := []*Shape{
		{ID: "b", Character: Character{Dimensions: map[string]string{"z": "1", "a": "2"}}},
		{ID: "a", Character: Character{Dimensions: map[string]string{"z": "1", "a": "2"}}},
	}

	d1, _ := MarshalGraph(0, shapes)
	d2, _ := MarshalGraph(0, shapes)

	if len(d1) != len(d2) {
		t.Fatal("different lengths")
	}
	for i := range d1 {
		if d1[i] != d2[i] {
			t.Fatalf("differ at byte %d", i)
		}
	}
}

func assertShape(t *testing.T, s *Shape, id ID, tick uint64, layer int, content string) {
	t.Helper()
	if s.ID != id {
		t.Errorf("id = %q, want %q", s.ID, id)
	}
	if s.Tick != tick {
		t.Errorf("%s tick = %d, want %d", id, s.Tick, tick)
	}
	if s.Structure.Emergence.Layer != layer {
		t.Errorf("%s layer = %d, want %d", id, s.Structure.Emergence.Layer, layer)
	}
	if s.Character.Content != content {
		t.Errorf("%s content = %q, want %q", id, s.Character.Content, content)
	}
}
