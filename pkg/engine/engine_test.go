// Layer 3 tests. The composition layer.
// Tests build on Layers 0-2 (shape, trace, dimension, transform).
package engine

import (
	"fmt"
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/transform"
)

// testEngine creates an engine in system mode for testing.
func testEngine() *Engine {
	eng := New()
	eng.SetActor("system")
	return eng
}

// --- mockTransform ---

type mockTransform struct {
	name    string
	result  transform.PropagationResult
	content string
	err     error
}

func (m *mockTransform) Name() string { return m.name }
func (m *mockTransform) Apply(c shape.Character, s shape.Structure) (shape.Character, error) {
	return c, nil
}
func (m *mockTransform) Propagate(change transform.Change, self *shape.Shape) (transform.PropagationResult, string, error) {
	return m.result, m.content, m.err
}

// --- New ---

func TestNew(t *testing.T) {
	eng := testEngine()
	if eng == nil {
		t.Fatal("New returned nil")
	}
	if eng.ShapeCount() != 0 {
		t.Error("new engine should have 0 shapes")
	}
}

// --- AddShape / GetShape ---

func TestAddAndGet(t *testing.T) {
	eng := testEngine()
	s := &shape.Shape{
		ID: "test.a",
		Character: shape.Character{
			Content: "hello",
		},
	}
	eng.AddShapeUnchecked(s)

	got, ok := eng.GetShape("test.a")
	if !ok {
		t.Fatal("shape not found after add")
	}
	if got.Character.Content != "hello" {
		t.Error("content mismatch")
	}
}

func TestGetMissing(t *testing.T) {
	eng := testEngine()
	_, ok := eng.GetShape("nonexistent")
	if ok {
		t.Error("should not find non-existent shape")
	}
}

func TestAddOverwrites(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "test.a", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{ID: "test.a", Character: shape.Character{Content: "v2"}})

	got, _ := eng.GetShape("test.a")
	if got.Character.Content != "v2" {
		t.Error("second add should overwrite")
	}
	if eng.ShapeCount() != 1 {
		t.Errorf("count: %d, want 1", eng.ShapeCount())
	}
}

// --- Shapes ---

func TestShapes(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a"})
	eng.AddShapeUnchecked(&shape.Shape{ID: "b"})
	eng.AddShapeUnchecked(&shape.Shape{ID: "c"})

	shapes := eng.Shapes()
	if len(shapes) != 3 {
		t.Errorf("shapes: %d, want 3", len(shapes))
	}
}

// --- Dependents index ---

func TestDependentsIndex(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "base"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "derived",
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Deps: []shape.ID{"base"},
			},
		},
	})

	deps := eng.Dependents("base")
	if len(deps) != 1 {
		t.Fatalf("dependents: %d, want 1", len(deps))
	}
	if deps[0] != "derived" {
		t.Errorf("dependent: %s", deps[0])
	}
}

func TestDependentsEmpty(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "lonely"})
	deps := eng.Dependents("lonely")
	if len(deps) != 0 {
		t.Errorf("lonely shape should have 0 dependents, got %d", len(deps))
	}
}

func TestDependentsMultiple(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "base"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "d1",
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"base"}}},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "d2",
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"base"}}},
	})

	deps := eng.Dependents("base")
	if len(deps) != 2 {
		t.Errorf("dependents: %d, want 2", len(deps))
	}
}

// --- Edit ---

func TestEdit(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "test.a",
		Character: shape.Character{Content: "original"},
		Structure: shape.Structure{Emergence: shape.Emergence{Layer: 1}},
	})

	report, err := eng.Edit("test.a", "modified")
	if err != nil {
		t.Fatal(err)
	}

	got, _ := eng.GetShape("test.a")
	if got.Character.Content != "modified" {
		t.Error("content should be modified")
	}

	if report.Edited != "test.a" {
		t.Errorf("edited: %s", report.Edited)
	}

	// No dependents.
	if len(report.AutoUpdated) != 0 {
		t.Errorf("auto: %d, want 0", len(report.AutoUpdated))
	}
	if len(report.NewerAvailable) != 0 {
		t.Errorf("newer: %d, want 0", len(report.NewerAvailable))
	}
}

func TestEditNonExistent(t *testing.T) {
	eng := testEngine()
	_, err := eng.Edit("nonexistent", "new content")
	if err == nil {
		t.Error("edit of non-existent shape should error")
	}
}

func TestEditPropagatesAutomatically(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name:    "test.Auto",
		result:  transform.AutoUpdate,
		content: "auto-updated",
	})

	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "base",
		Character: shape.Character{Content: "v1"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "derived",
		Character: shape.Character{Content: "original"},
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Fn:   "test.Auto",
				Deps: []shape.ID{"base"},
			},
		},
	})

	report, err := eng.Edit("base", "v2")
	if err != nil {
		t.Fatal(err)
	}

	// Edit should have propagated automatically.
	if len(report.AutoUpdated) != 1 || report.AutoUpdated[0] != "derived" {
		t.Errorf("auto: %v, want [derived]", report.AutoUpdated)
	}

	got, _ := eng.GetShape("derived")
	if got.Character.Content != "auto-updated" {
		t.Errorf("content: %s, want auto-updated", got.Character.Content)
	}
}

func TestEditPropagatesCascades(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name:    "test.Auto",
		result:  transform.AutoUpdate,
		content: "cascaded",
	})

	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "b",
		Character: shape.Character{Content: "original"},
		Structure: shape.Structure{Transformation: shape.Transformation{
			Fn: "test.Auto", Deps: []shape.ID{"a"},
		}},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "c",
		Character: shape.Character{Content: "original"},
		Structure: shape.Structure{Transformation: shape.Transformation{
			Fn: "test.Auto", Deps: []shape.ID{"b"},
		}},
	})

	report, err := eng.Edit("a", "v2")
	if err != nil {
		t.Fatal(err)
	}

	// Both b and c should be auto-updated (cascade).
	if len(report.AutoUpdated) != 2 {
		t.Errorf("auto: %d, want 2", len(report.AutoUpdated))
	}

	gotC, _ := eng.GetShape("c")
	if gotC.Character.Content != "cascaded" {
		t.Error("c should be auto-updated via cascade")
	}
}

func TestEditNewerAvailableContinuesCascade(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name:   "test.Flag",
		result: transform.FlagForReview,
	})
	eng.RegisterTransform(&mockTransform{
		name:    "test.Auto",
		result:  transform.AutoUpdate,
		content: "reached-via-cascade",
	})

	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "b",
		Structure: shape.Structure{Transformation: shape.Transformation{
			Fn: "test.Flag", Deps: []shape.ID{"a"},
		}},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "c",
		Character: shape.Character{Content: "original"},
		Structure: shape.Structure{Transformation: shape.Transformation{
			Fn: "test.Auto", Deps: []shape.ID{"b"},
		}},
	})

	report, err := eng.Edit("a", "v2")
	if err != nil {
		t.Fatal(err)
	}

	// b has newer available. Wave continues: c gets auto-updated.
	if len(report.NewerAvailable) != 1 || report.NewerAvailable[0] != "b" {
		t.Errorf("newer: %v, want [b]", report.NewerAvailable)
	}
	if len(report.AutoUpdated) != 1 || report.AutoUpdated[0] != "c" {
		t.Errorf("auto: %v, want [c] (wave continues past newer-available)", report.AutoUpdated)
	}

	gotC, _ := eng.GetShape("c")
	if gotC.Character.Content != "reached-via-cascade" {
		t.Errorf("c should be updated via cascade, got: %s", gotC.Character.Content)
	}
}

func TestEditAdvancesTick(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "test.a",
		Character: shape.Character{Content: "v1"},
	})

	eng.Edit("test.a", "v2")

	status := eng.Status()
	if status.Tick != 1 {
		t.Errorf("tick: %d, want 1", status.Tick)
	}
}

func TestEditNewerAvailableWithNoFn(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "base", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "derived",
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"base"}}},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "transitive",
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"derived"}}},
	})

	report, err := eng.Edit("base", "v2")
	if err != nil {
		t.Fatal(err)
	}

	// derived has no Fn: newer available. Wave continues to transitive
	// (also no Fn: also newer available). Both learn about the change.
	if len(report.NewerAvailable) != 2 {
		t.Errorf("newer: %d, want 2 (wave continues through all)", len(report.NewerAvailable))
	}
}


// --- Propagate ---

func TestPropagateAutoUpdate(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name:    "test.Auto",
		result:  transform.AutoUpdate,
		content: "auto-updated content",
	})

	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "base",
		Character: shape.Character{Content: "changed"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "derived",
		Character: shape.Character{Content: "original"},
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Fn:   "test.Auto",
				Deps: []shape.ID{"base"},
			},
		},
	})

	report, err := eng.Propagate("base")
	if err != nil {
		t.Fatal(err)
	}
	if len(report.AutoUpdated) != 1 || report.AutoUpdated[0] != "derived" {
		t.Errorf("auto: %v", report.AutoUpdated)
	}
	if len(report.NewerAvailable) != 0 {
		t.Errorf("newer: %v", report.NewerAvailable)
	}

	got, _ := eng.GetShape("derived")
	if got.Character.Content != "auto-updated content" {
		t.Errorf("content: %s", got.Character.Content)
	}
}

func TestPropagateNewerAvailable(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name:   "test.Flag",
		result: transform.FlagForReview,
	})

	eng.AddShapeUnchecked(&shape.Shape{ID: "base"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "derived",
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Fn:   "test.Flag",
				Deps: []shape.ID{"base"},
			},
		},
	})

	report, err := eng.Propagate("base")
	if err != nil {
		t.Fatal(err)
	}
	if len(report.AutoUpdated) != 0 {
		t.Errorf("auto: %v", report.AutoUpdated)
	}
	if len(report.NewerAvailable) != 1 || report.NewerAvailable[0] != "derived" {
		t.Errorf("newer: %v", report.NewerAvailable)
	}
}

func TestPropagateNoChange(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name:   "test.NoOp",
		result: transform.NoChange,
	})

	eng.AddShapeUnchecked(&shape.Shape{ID: "base"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "derived",
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Fn:   "test.NoOp",
				Deps: []shape.ID{"base"},
			},
		},
	})

	report, err := eng.Propagate("base")
	if err != nil {
		t.Fatal(err)
	}
	if len(report.AutoUpdated) != 0 {
		t.Errorf("auto: %v", report.AutoUpdated)
	}
	if len(report.NewerAvailable) != 0 {
		t.Errorf("newer: %v", report.NewerAvailable)
	}
}

func TestPropagateNonExistent(t *testing.T) {
	eng := testEngine()
	_, err := eng.Propagate("nonexistent")
	if err == nil {
		t.Error("propagate on non-existent shape should error")
	}
}

func TestPropagateMissingTransform(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "base"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "derived",
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Fn:   "nonexistent.Transform",
				Deps: []shape.ID{"base"},
			},
		},
	})

	report, err := eng.Propagate("base")
	if err != nil {
		t.Fatal(err)
	}
	if len(report.NewerAvailable) != 1 {
		t.Errorf("newer: %d, want 1", len(report.NewerAvailable))
	}
}

func TestPropagateNoFn(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "base"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "derived",
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Deps: []shape.ID{"base"},
			},
		},
	})

	report, err := eng.Propagate("base")
	if err != nil {
		t.Fatal(err)
	}
	if len(report.NewerAvailable) != 1 {
		t.Errorf("no-fn dependent should show newer available, got %d", len(report.NewerAvailable))
	}
}

func TestPropagateTransformError(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name: "test.Error",
		err:  fmt.Errorf("transform failed"),
	})

	eng.AddShapeUnchecked(&shape.Shape{ID: "base"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "derived",
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Fn:   "test.Error",
				Deps: []shape.ID{"base"},
			},
		},
	})

	report, err := eng.Propagate("base")
	if err != nil {
		t.Fatal(err)
	}
	if len(report.NewerAvailable) != 1 {
		t.Errorf("transform error should mark newer available, got %d", len(report.NewerAvailable))
	}
}

// --- Validate ---

func TestValidateCoherent(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "b",
		Structure: shape.Structure{
			Transformation: shape.Transformation{Deps: []shape.ID{"a"}},
		},
	})

	result := eng.Validate()
	if !result.IsCoherent() {
		t.Error("should be coherent")
	}
}

func TestValidateDanglingDep(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "orphan",
		Structure: shape.Structure{
			Transformation: shape.Transformation{Deps: []shape.ID{"nonexistent"}},
		},
	})

	result := eng.Validate()
	if result.IsCoherent() {
		t.Error("should not be coherent: dangling dep")
	}
	if len(result.DanglingDeps) != 1 {
		t.Errorf("dangling deps: %d, want 1", len(result.DanglingDeps))
	}
	if result.DanglingDeps[0].Shape != "orphan" {
		t.Error("wrong shape in dangling dep")
	}
	if result.DanglingDeps[0].Dep != "nonexistent" {
		t.Error("wrong dep in dangling dep")
	}
}

func TestValidateDanglingFrom(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "layer3.thing",
		Structure: shape.Structure{
			Emergence: shape.Emergence{
				Layer: 3,
				From:  []shape.ID{"layer2.missing"},
			},
		},
	})

	result := eng.Validate()
	if result.IsCoherent() {
		t.Error("should not be coherent: dangling emergence.from")
	}
	if len(result.DanglingDeps) != 1 {
		t.Errorf("dangling deps: %d", len(result.DanglingDeps))
	}
}

func TestValidateMissingTransform(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "test.a",
		Structure: shape.Structure{
			Transformation: shape.Transformation{Fn: "nonexistent.Transform"},
		},
	})

	result := eng.Validate()
	if result.IsCoherent() {
		t.Error("should not be coherent: missing transform")
	}
	if len(result.MissingTransforms) != 1 {
		t.Errorf("missing transforms: %d", len(result.MissingTransforms))
	}
}

func TestValidateRegisteredTransformIsOK(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{name: "test.Exists"})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "test.a",
		Structure: shape.Structure{
			Transformation: shape.Transformation{Fn: "test.Exists"},
		},
	})

	result := eng.Validate()
	if !result.IsCoherent() {
		t.Error("should be coherent: transform is registered")
	}
}

// --- Status ---

func TestStatusEmpty(t *testing.T) {
	eng := testEngine()
	status := eng.Status()
	if status.TotalShapes != 0 {
		t.Error("empty engine should have 0 shapes")
	}
	if status.Tick != 0 {
		t.Error("empty engine should have tick 0")
	}
}

func TestStatusAfterEdits(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "l1.a",
		Character: shape.Character{Content: "v1"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "l2.b",
		Character: shape.Character{Content: "v1"},
	})

	eng.Edit("l1.a", "v2")
	eng.Edit("l2.b", "v2")

	status := eng.Status()
	if status.TotalShapes != 2 {
		t.Errorf("total shapes: %d", status.TotalShapes)
	}
	if status.Tick != 2 {
		t.Errorf("tick: %d, want 2", status.Tick)
	}
}

// --- Cycle handling ---

func TestPropagateCycleHandling(t *testing.T) {
	eng := testEngine()
	// Create a cycle: a -> b -> a (shouldn't infinite loop).
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "a",
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"b"}}},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "b",
		Character: shape.Character{Content: "v1"},
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"a"}}},
	})

	// This should not hang. Cycle is broken by visited set.
	report, err := eng.Edit("b", "v2")
	if err != nil {
		t.Fatal(err)
	}
	// a depends on b (no Fn): newer available. Wave continues to a's dependents.
	// b depends on a, but b is already visited. Cycle broken.
	if len(report.NewerAvailable) != 1 {
		t.Errorf("newer: %d, want 1 (cycle should not infinite loop)", len(report.NewerAvailable))
	}
}

// --- RegisterTransform ---

func TestRegisterTransform(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{name: "test.Mock"})

	fn, ok := eng.Registry().Get("test.Mock")
	if !ok {
		t.Fatal("registered transform not found")
	}
	if fn.Name() != "test.Mock" {
		t.Error("name mismatch")
	}
}

// --- Tick ---

func TestTickStartsAtZero(t *testing.T) {
	eng := testEngine()
	if eng.Tick() != 0 {
		t.Errorf("initial tick: %d, want 0", eng.Tick())
	}
}

func TestTickIncrementsOnEdit(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{ID: "b", Character: shape.Character{Content: "v1"}})

	eng.Edit("a", "v2")
	if eng.Tick() != 1 {
		t.Errorf("tick after first edit: %d, want 1", eng.Tick())
	}

	eng.Edit("b", "v2")
	if eng.Tick() != 2 {
		t.Errorf("tick after second edit: %d, want 2", eng.Tick())
	}
}

func TestTickStampsEditedShape(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})

	if s, _ := eng.GetShape("a"); s.Tick != 0 {
		t.Error("shape tick should be 0 before edit")
	}

	eng.Edit("a", "v2")
	s, _ := eng.GetShape("a")
	if s.Tick != 1 {
		t.Errorf("shape tick after edit: %d, want 1", s.Tick)
	}
}

func TestTickStampsAutoUpdated(t *testing.T) {
	eng := testEngine()
	eng.RegisterTransform(&mockTransform{
		name:    "test.Auto",
		result:  transform.AutoUpdate,
		content: "updated",
	})

	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "b",
		Structure: shape.Structure{Transformation: shape.Transformation{
			Fn: "test.Auto", Deps: []shape.ID{"a"},
		}},
	})

	report, _ := eng.Edit("a", "v2")
	if report.Tick != 1 {
		t.Errorf("report tick: %d, want 1", report.Tick)
	}

	b, _ := eng.GetShape("b")
	if b.Tick != 1 {
		t.Errorf("auto-updated shape tick: %d, want 1", b.Tick)
	}
}

func TestTickStampsNewerAvailable(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "b",
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"a"}}},
	})

	eng.Edit("a", "v2")

	b, _ := eng.GetShape("b")
	if b.Tick != 1 {
		t.Errorf("newer-available shape tick: %d, want 1", b.Tick)
	}
}

// --- Block / Permissions ---

func TestBlockAddsToPermissions(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "creator.post",
		Character: shape.Character{Content: "my work"},
	})

	report, err := eng.Block("creator.post", "troll.user", "withdrawn: harassment")
	if err != nil {
		t.Fatal(err)
	}

	s, _ := eng.GetShape("creator.post")
	if len(s.Structure.Permissions.Blocked) != 1 {
		t.Fatal("should have 1 blocked user")
	}
	if s.Structure.Permissions.Blocked[0] != "troll.user" {
		t.Error("blocked user mismatch")
	}
	if s.Structure.Permissions.Warning != "withdrawn: harassment" {
		t.Error("warning mismatch")
	}
	if report.Tick != 1 {
		t.Errorf("block tick: %d, want 1", report.Tick)
	}
}

func TestBlockPropagatesWithdrawal(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "creator.post",
		Character: shape.Character{Content: "original work"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "troll.derivative",
		Character: shape.Character{
			Content:    "built on creator's work",
			Dimensions: map[string]string{"author": "troll.user"},
		},
		Structure: shape.Structure{Transformation: shape.Transformation{
			Deps: []shape.ID{"creator.post"},
		}},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "innocent.downstream",
		Character: shape.Character{
			Content:    "built on troll's work",
			Dimensions: map[string]string{"author": "innocent.user"},
		},
		Structure: shape.Structure{Transformation: shape.Transformation{
			Deps: []shape.ID{"troll.derivative"},
		}},
	})

	report, err := eng.Block("creator.post", "troll.user", "")
	if err != nil {
		t.Fatal(err)
	}

	// Troll's derivative should be withdrawn.
	if len(report.Withdrawn) != 1 {
		t.Fatalf("withdrawn: %d, want 1", len(report.Withdrawn))
	}
	if report.Withdrawn[0] != "troll.derivative" {
		t.Errorf("withdrawn shape: %s", report.Withdrawn[0])
	}

	// Innocent downstream should NOT be withdrawn (different author).
	for _, w := range report.Withdrawn {
		if w == "innocent.downstream" {
			t.Error("innocent downstream should not be withdrawn")
		}
	}
}

func TestBlockNonExistent(t *testing.T) {
	eng := testEngine()
	_, err := eng.Block("nonexistent", "troll", "")
	if err == nil {
		t.Error("block on non-existent shape should error")
	}
}

func TestBlockMultiple(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "creator.post",
		Character: shape.Character{Content: "work"},
	})

	eng.Block("creator.post", "troll1", "")
	eng.Block("creator.post", "troll2", "")

	s, _ := eng.GetShape("creator.post")
	if len(s.Structure.Permissions.Blocked) != 2 {
		t.Errorf("blocked: %d, want 2", len(s.Structure.Permissions.Blocked))
	}
}

func TestBlockTickStampsWithdrawn(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "creator.post",
		Character: shape.Character{Content: "work"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "troll.deriv",
		Character: shape.Character{
			Dimensions: map[string]string{"author": "troll"},
		},
		Structure: shape.Structure{Transformation: shape.Transformation{
			Deps: []shape.ID{"creator.post"},
		}},
	})

	eng.Block("creator.post", "troll", "")

	d, _ := eng.GetShape("troll.deriv")
	if d.Tick != 1 {
		t.Errorf("withdrawn shape tick: %d, want 1", d.Tick)
	}
}

// --- Trace Moments ---

func TestMomentsRecordedOnAdd(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a"})
	eng.AddShapeUnchecked(&shape.Shape{ID: "b"})

	if eng.MomentCount() != 2 {
		t.Errorf("moments: %d, want 2", eng.MomentCount())
	}
	m, ok := eng.MomentAt(0)
	if !ok {
		t.Fatal("moment 0 not found")
	}
	if m.Action != "add" {
		t.Errorf("action: %s, want add", m.Action)
	}
	if m.Target != "a" {
		t.Errorf("target: %s, want a", m.Target)
	}
}

func TestMomentsRecordedOnEdit(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})

	eng.Edit("a", "v2")

	// 1 add + 1 edit = 2 moments
	if eng.MomentCount() != 2 {
		t.Errorf("moments: %d, want 2", eng.MomentCount())
	}
	m, _ := eng.MomentAt(1)
	if m.Action != "edit" {
		t.Errorf("action: %s, want edit", m.Action)
	}
	if m.Report == nil {
		t.Fatal("edit moment should have report")
	}
	if m.Report.Edited != "a" {
		t.Errorf("report.edited: %s, want a", m.Report.Edited)
	}
}

func TestMomentsRecordedOnBlock(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "post", Character: shape.Character{Content: "work"}})

	eng.Block("post", "troll", "bad")

	m, _ := eng.MomentAt(1)
	if m.Action != "block" {
		t.Errorf("action: %s, want block", m.Action)
	}
}

func TestMomentsRecordedOnRemove(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a"})
	_ = eng.RemoveShape("a")

	if eng.MomentCount() != 2 {
		t.Errorf("moments: %d, want 2 (add + remove)", eng.MomentCount())
	}
	m, _ := eng.MomentAt(1)
	if m.Action != "remove" {
		t.Errorf("action: %s, want remove", m.Action)
	}
}

func TestMomentActorTracking(t *testing.T) {
	eng := testEngine()
	eng.SetActor("user.alice")
	eng.AddShapeUnchecked(&shape.Shape{ID: "user.alice.a", Character: shape.Character{Content: "v1"}})
	eng.Edit("user.alice.a", "v2")

	m, _ := eng.MomentAt(1)
	if m.Actor != "user.alice" {
		t.Errorf("actor: %s, want user.alice", m.Actor)
	}
}

func TestMomentWavePropagation(t *testing.T) {
	eng := testEngine()
	eng.AddShapeUnchecked(&shape.Shape{ID: "a", Character: shape.Character{Content: "v1"}})
	eng.AddShapeUnchecked(&shape.Shape{
		ID: "b",
		Structure: shape.Structure{Transformation: shape.Transformation{Deps: []shape.ID{"a"}}},
	})

	eng.Edit("a", "v2")

	m, _ := eng.MomentAt(2) // add a, add b, edit a
	if m.Report == nil {
		t.Fatal("edit moment should have report")
	}
	if len(m.Report.NewerAvailable) != 1 {
		t.Errorf("newer: %d, want 1", len(m.Report.NewerAvailable))
	}
}

func TestMomentAtOutOfBounds(t *testing.T) {
	eng := testEngine()
	_, ok := eng.MomentAt(-1)
	if ok {
		t.Error("negative index should return false")
	}
	_, ok = eng.MomentAt(0)
	if ok {
		t.Error("empty trace at 0 should return false")
	}
}
