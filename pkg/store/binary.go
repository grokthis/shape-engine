package store

import (
	"fmt"
	"os"

	"github.com/ashbuilds/shape-engine/pkg/shape"
)

// BinaryStore persists the entire shape graph as a single binary file.
// One file. All state. Changes always written to disk.
type BinaryStore struct {
	path string
}

// NewBinaryStore creates a store backed by a single .shape file.
func NewBinaryStore(path string) *BinaryStore {
	return &BinaryStore{path: path}
}

// Path returns the file path.
func (s *BinaryStore) Path() string {
	return s.path
}

// Save writes the entire graph to disk atomically.
// Write to temp file, then rename. No partial writes.
func (s *BinaryStore) Save(tick uint64, shapes map[shape.ID]*shape.Shape) error {
	list := make([]*shape.Shape, 0, len(shapes))
	for _, sh := range shapes {
		list = append(list, sh)
	}

	data, err := shape.MarshalGraph(tick, list)
	if err != nil {
		return fmt.Errorf("marshaling graph: %w", err)
	}

	tmp := s.path + ".tmp"
	if err := os.WriteFile(tmp, data, 0644); err != nil {
		return fmt.Errorf("writing temp file: %w", err)
	}

	if err := os.Rename(tmp, s.path); err != nil {
		return fmt.Errorf("renaming to %s: %w", s.path, err)
	}

	return nil
}

// Load reads the entire graph from disk.
// Returns the global tick and all shapes indexed by ID.
func (s *BinaryStore) Load() (uint64, map[shape.ID]*shape.Shape, error) {
	data, err := os.ReadFile(s.path)
	if err != nil {
		if os.IsNotExist(err) {
			return 0, make(map[shape.ID]*shape.Shape), nil
		}
		return 0, nil, fmt.Errorf("reading %s: %w", s.path, err)
	}

	tick, list, err := shape.UnmarshalGraph(data)
	if err != nil {
		return 0, nil, fmt.Errorf("unmarshaling %s: %w", s.path, err)
	}

	shapes := make(map[shape.ID]*shape.Shape, len(list))
	for _, sh := range list {
		shapes[sh.ID] = sh
	}

	return tick, shapes, nil
}
