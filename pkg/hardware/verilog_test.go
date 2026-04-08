package hardware

import (
	"bytes"
	"strings"
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/shape"
)

func TestPlaceEmpty(t *testing.T) {
	p := Place(nil)
	if len(p.IDs) != 0 {
		t.Error("empty placement should have 0 IDs")
	}
}

func TestPlaceSorted(t *testing.T) {
	shapes := []*shape.Shape{
		{ID: "c"},
		{ID: "a"},
		{ID: "b"},
	}
	p := Place(shapes)
	if p.IDs[0] != "a" || p.IDs[1] != "b" || p.IDs[2] != "c" {
		t.Errorf("IDs not sorted: %v", p.IDs)
	}
}

func TestPlaceGridDimensions(t *testing.T) {
	shapes := make([]*shape.Shape, 10)
	for i := range shapes {
		shapes[i] = &shape.Shape{ID: shape.ID(string(rune('a' + i)))}
	}
	p := Place(shapes)
	if p.Rows*p.Cols < 10 {
		t.Errorf("grid too small: %dx%d = %d < 10", p.Rows, p.Cols, p.Rows*p.Cols)
	}
}

func TestGenerateMinimal(t *testing.T) {
	shapes := []*shape.Shape{
		{ID: "law", Character: shape.Character{Content: "axiom"}},
		{ID: "law.persistence", Character: shape.Character{Content: "persist"},
			Structure: shape.Structure{Transformation: shape.Transformation{
				Deps: []shape.ID{"law"},
			}}},
	}

	var buf bytes.Buffer
	err := Generate(&buf, shapes, DefaultConfig())
	if err != nil {
		t.Fatal(err)
	}

	out := buf.String()

	// Should contain module declaration.
	if !strings.Contains(out, "module shape_os") {
		t.Error("missing module declaration")
	}

	// Should contain shape_lattice instantiation.
	if !strings.Contains(out, "shape_lattice #(") {
		t.Error("missing lattice instantiation")
	}

	// Should list both shapes in placement comments.
	if !strings.Contains(out, "law.persistence") {
		t.Error("missing law.persistence in output")
	}

	// Should have connection from law.persistence -> law.
	if !strings.Contains(out, "law.persistence -> law") {
		t.Error("missing dependency connection")
	}

	// Should end with endmodule.
	if !strings.Contains(out, "endmodule") {
		t.Error("missing endmodule")
	}
}

func TestGenerateUnusedGatesFilled(t *testing.T) {
	shapes := []*shape.Shape{
		{ID: "a"},
	}

	var buf bytes.Buffer
	Generate(&buf, shapes, DefaultConfig())
	out := buf.String()

	// Grid is at least 1x1, unused gates should have zero config.
	if !strings.Contains(out, "// unused") {
		// Only one shape in a 1x1 grid has no unused gates, that's fine.
		// But in a larger grid there would be.
		if strings.Contains(out, "NUM_GATES     = 1") {
			return // 1x1 grid, no unused
		}
		t.Error("expected unused gate markers")
	}
}

func TestHashContentDeterministic(t *testing.T) {
	h1 := hashContent("hello", 8)
	h2 := hashContent("hello", 8)
	if h1 != h2 {
		t.Error("hash not deterministic")
	}
}

func TestHashContentDifferent(t *testing.T) {
	h1 := hashContent("hello", 8)
	h2 := hashContent("world", 8)
	if h1 == h2 {
		t.Error("different content should (likely) hash differently")
	}
}
