package transform

import "github.com/ashbuilds/shape-engine/pkg/shape"

// PropagationResult describes what happens when a dependency changes.
// The trichotomy: NoChange, AutoUpdate, FlagForReview. No fourth option
// is coherent (Theorem 6.3).
type PropagationResult int

const (
	// NoChange means the dependency change doesn't affect this shape.
	NoChange PropagationResult = iota

	// AutoUpdate means the transform can compute the new state automatically.
	AutoUpdate

	// FlagForReview means the shape is stale and needs manual review.
	FlagForReview
)

// Change describes what changed in a dependency.
type Change struct {
	Source          shape.ID
	PreviousContent string
	NewContent      string
}

// TransformFn is the interface every transformation function implements.
// This is the f in M' = f(C, S). Structure contains functions (Theorem 6.1).
type TransformFn interface {
	// Name returns the qualified name of this transform.
	Name() string

	// Apply performs the transformation: given character C and structure S,
	// produce M'.
	Apply(c shape.Character, s shape.Structure) (shape.Character, error)

	// Propagate determines what happens when a dependency changes.
	// Returns the propagation result and, for AutoUpdate, the new content.
	Propagate(change Change, self *shape.Shape) (PropagationResult, string, error)
}

// Registry holds registered transform functions by name.
type Registry struct {
	transforms map[string]TransformFn
}

// NewRegistry creates an empty transform registry.
func NewRegistry() *Registry {
	return &Registry{
		transforms: make(map[string]TransformFn),
	}
}

// Register adds a transform function to the registry.
func (r *Registry) Register(fn TransformFn) {
	r.transforms[fn.Name()] = fn
}

// Get retrieves a transform function by name.
func (r *Registry) Get(name string) (TransformFn, bool) {
	fn, ok := r.transforms[name]
	return fn, ok
}
