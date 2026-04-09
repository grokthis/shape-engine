// Package shape is the axiom. Everything in the engine is a Shape.
//
// This package imports nothing. It is the irreducible primitive from which
// everything else emerges. This implements M' = f(C, S) from [1].
package shape

// Shape is the core primitive. Everything in the engine is a Shape.
type Shape struct {
	ID        ID        `yaml:"id" json:"id"`
	Character Character `yaml:"character" json:"character"`
	Structure Structure `yaml:"structure" json:"structure"`

	// Tick is the global tick at which this shape was last modified.
	// Every edit to any shape increments the global tick. This shape's
	// tick records when it was last touched (directly or by propagation).
	// Zero means the shape has never been through an edit cycle.
	Tick uint64 `yaml:"tick,omitempty" json:"tick,omitempty"`

	// Hash is the structural identity of this moment. Computed once when the
	// shape is created or mutated. Encodes ID, content, dimensions, layer,
	// and tick — everything that makes this moment this moment. Never
	// invalidated: when the shape changes, a new hash is born with it.
	Hash [32]byte `yaml:"-" json:"-"`
}

// ID is a hierarchical identifier. Components are dot-separated.
// Example: "vol8.08a.part3.polarization"
type ID string

// Character is what changes: a map of dimension coordinates plus content.
type Character struct {
	// Dimensions maps dimension IDs to coordinate values.
	// Example: {"topic": "08a", "part": "3", "section": "polarization"}
	Dimensions map[string]string `yaml:"dimensions,omitempty" json:"dimensions,omitempty"`

	// Content is the actual text, math, or data at this position.
	Content string `yaml:"content,omitempty" json:"content,omitempty"`
}

// Structure is the geometry governing transformation. It has three components:
// transformation (self-transformation), emergence (position in the stack),
// and permissions (who may derive from this shape).
type Structure struct {
	Transformation Transformation `yaml:"transformation" json:"transformation"`
	Emergence      Emergence      `yaml:"emergence" json:"emergence"`
	Permissions    Permissions    `yaml:"permissions,omitempty" json:"permissions,omitempty"`
}

// Permissions controls who may create new shapes that depend on this one.
// The creator has structural power: they decide who can build on their work.
type Permissions struct {
	// Blocked lists author IDs whose future derivations are withdrawn.
	// Existing shapes persist (Law 2) but are flagged with a content warning.
	// The wave propagates the withdrawal through all downstream dependents.
	Blocked []ID `yaml:"blocked,omitempty" json:"blocked,omitempty"`

	// Visibility controls who can see this shape.
	// Empty means public. "author" means only the author.
	// Can list specific user IDs for selective sharing.
	Visibility []string `yaml:"visibility,omitempty" json:"visibility,omitempty"`

	// Warning is a content notice attached by the creator when blocking.
	// Propagated to all downstream shapes authored by blocked users.
	// Displayed as a click-through before viewing.
	Warning string `yaml:"warning,omitempty" json:"warning,omitempty"`
}

// Transformation defines how this shape transforms when its context changes.
type Transformation struct {
	// Fn is the transform function reference. Domain-qualified.
	// Example: "paper.FormalDerivation", "conlang.SoundChange"
	Fn string `yaml:"fn,omitempty" json:"fn,omitempty"`

	// Deps are the shapes this one derives from.
	Deps []ID `yaml:"deps,omitempty" json:"deps,omitempty"`

	// Constraints are coherence requirements on this shape.
	Constraints []Constraint `yaml:"constraints,omitempty" json:"constraints,omitempty"`
}

// ConstraintStatus is the coherence state of a constraint.
type ConstraintStatus string

const (
	Satisfied ConstraintStatus = "satisfied"
	Violated  ConstraintStatus = "violated"
	Unchecked ConstraintStatus = "unchecked"
)

// Constraint is a coherence requirement.
type Constraint struct {
	Law    int              `yaml:"law" json:"law"` // 0, 1, 2, or 3
	Status ConstraintStatus `yaml:"status" json:"status"`
	Note   string           `yaml:"note,omitempty" json:"note,omitempty"`
}

// Emergence defines where this shape sits in the emergence stack.
type Emergence struct {
	// Layer is the emergence level.
	Layer int `yaml:"layer" json:"layer"`

	// From are the shapes this emerges from (layer below).
	From []ID `yaml:"from,omitempty" json:"from,omitempty"`

	// Produces are the shapes that emerge from this (layer above).
	Produces []ID `yaml:"produces,omitempty" json:"produces,omitempty"`
}
