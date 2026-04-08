package store

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/shape"
)

func TestBinaryStoreRoundTrip(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "test.shape")
	s := NewBinaryStore(path)

	shapes := map[shape.ID]*shape.Shape{
		"a": {
			ID:   "a",
			Tick: 5,
			Character: shape.Character{
				Content: "shape a",
			},
			Structure: shape.Structure{
				Emergence: shape.Emergence{Layer: 0},
			},
		},
		"b": {
			ID:   "b",
			Tick: 5,
			Character: shape.Character{
				Content: "shape b",
			},
			Structure: shape.Structure{
				Transformation: shape.Transformation{
					Deps: []shape.ID{"a"},
				},
				Emergence: shape.Emergence{Layer: 1, From: []shape.ID{"a"}},
			},
		},
	}

	if err := s.Save(5, shapes); err != nil {
		t.Fatalf("save: %v", err)
	}

	tick, got, err := s.Load()
	if err != nil {
		t.Fatalf("load: %v", err)
	}

	if tick != 5 {
		t.Errorf("tick = %d, want 5", tick)
	}
	if len(got) != 2 {
		t.Fatalf("got %d shapes, want 2", len(got))
	}
	if got["a"].Character.Content != "shape a" {
		t.Errorf("a content = %q", got["a"].Character.Content)
	}
	if got["b"].Structure.Transformation.Deps[0] != "a" {
		t.Errorf("b deps = %v", got["b"].Structure.Transformation.Deps)
	}
}

func TestBinaryStoreLoadNonexistent(t *testing.T) {
	s := NewBinaryStore("/tmp/nonexistent.shape")
	tick, shapes, err := s.Load()
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if tick != 0 {
		t.Errorf("tick = %d, want 0", tick)
	}
	if len(shapes) != 0 {
		t.Errorf("shapes = %d, want 0", len(shapes))
	}
}

func TestBinaryStoreAtomicWrite(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "test.shape")
	s := NewBinaryStore(path)

	// Save once
	shapes := map[shape.ID]*shape.Shape{
		"x": {ID: "x", Character: shape.Character{Content: "first"}},
	}
	if err := s.Save(1, shapes); err != nil {
		t.Fatalf("save 1: %v", err)
	}

	// No temp file should remain
	_, err := os.Stat(path + ".tmp")
	if !os.IsNotExist(err) {
		t.Error("temp file still exists after save")
	}

	// Save again, verify overwrite
	shapes["x"].Character.Content = "second"
	if err := s.Save(2, shapes); err != nil {
		t.Fatalf("save 2: %v", err)
	}

	tick, got, err := s.Load()
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if tick != 2 {
		t.Errorf("tick = %d, want 2", tick)
	}
	if got["x"].Character.Content != "second" {
		t.Errorf("content = %q, want second", got["x"].Character.Content)
	}
}
