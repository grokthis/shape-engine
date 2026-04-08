// Package engine is the composition layer. The engine runtime emerges
// from shapes, traces, transforms, and dimensions: it composes them
// into a functioning system.
package engine

import (
	"fmt"
	"sync"

	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/transform"
)

// Moment is a single entry in the trace log. Every mutation produces a Moment.
// Moments are append-only and form the complete audit trail.
type Moment struct {
	Tick   uint64   `json:"tick"`
	Actor  string   `json:"actor,omitempty"`
	Action string   `json:"action"` // "edit", "add", "remove", "block"
	Target shape.ID `json:"target"`
	// Report is the propagation result (nil for add/remove).
	Report *PropagationReport `json:"report,omitempty"`
}

// Engine is the shape engine runtime.
type Engine struct {
	mu sync.RWMutex

	// Shapes indexed by ID.
	shapes map[shape.ID]*shape.Shape

	// Transform function registry.
	transforms *transform.Registry

	// Reverse dependency index: for each shape, which shapes depend on it.
	dependents map[shape.ID][]shape.ID

	// tick is the global tick counter. Every Edit increments this.
	// Every shape touched by the wave gets stamped with the current tick.
	// This is a structural position, not a timestamp.
	tick uint64

	// actor is the user shape ID of the current session.
	// Every trace moment is structurally connected to the actor.
	// This is the audit trail: attention costs ticks.
	actor string

	// trace is the append-only log of all mutations. Every AddShape, Edit,
	// Remove, and Block produces a Moment. The trace is the complete history:
	// any prior state can be reconstructed from it.
	trace []Moment

	// onMutate is called after every mutation (AddShape, Edit, Block).
	// The engine is unlocked when this fires. Used for auto-persistence.
	onMutate func()

	// ext holds extension objects (LLM client, etc.) without import coupling.
	// Keys are package paths, values are typed by the caller.
	ext map[string]interface{}
}

// New creates a new engine with an empty structure.
func New() *Engine {
	return &Engine{
		shapes:     make(map[shape.ID]*shape.Shape),
		transforms: transform.NewRegistry(),
		dependents: make(map[shape.ID][]shape.ID),
		ext:        make(map[string]interface{}),
	}
}

// RegisterTransform adds a transform function to the engine.
func (e *Engine) RegisterTransform(fn transform.TransformFn) {
	e.transforms.Register(fn)
}

// Registry returns the engine's transform registry for bulk registration.
func (e *Engine) Registry() *transform.Registry {
	return e.transforms
}

// SetExt stores an extension object on the engine.
func (e *Engine) SetExt(key string, val interface{}) {
	e.ext[key] = val
}

// GetExt retrieves an extension object by key.
func (e *Engine) GetExt(key string) (interface{}, bool) {
	v, ok := e.ext[key]
	return v, ok
}

// OnMutate registers a callback fired after every mutation.
// Used by cmd/shape to auto-persist to the shape file.
func (e *Engine) OnMutate(fn func()) {
	e.onMutate = fn
}

func (e *Engine) notifyMutate() {
	if e.onMutate != nil {
		e.onMutate()
	}
}

// recordMoment appends a moment to the trace. Must be called with lock held.
func (e *Engine) recordMoment(action string, target shape.ID, report *PropagationReport) {
	e.trace = append(e.trace, Moment{
		Tick:   e.tick,
		Actor:  e.actor,
		Action: action,
		Target: target,
		Report: report,
	})
}

// Moments returns the complete trace log.
func (e *Engine) Moments() []Moment {
	e.mu.RLock()
	defer e.mu.RUnlock()
	cp := make([]Moment, len(e.trace))
	copy(cp, e.trace)
	return cp
}

// MomentCount returns the number of trace moments.
func (e *Engine) MomentCount() int {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return len(e.trace)
}

// MomentAt returns the moment at the given index.
func (e *Engine) MomentAt(idx int) (Moment, bool) {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if idx < 0 || idx >= len(e.trace) {
		return Moment{}, false
	}
	return e.trace[idx], true
}

// SetActor sets the current user for all subsequent operations.
// Every trace moment will be structurally connected to this actor.
func (e *Engine) SetActor(userID string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.actor = userID
}

// Actor returns the current user shape ID.
func (e *Engine) Actor() string {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.actor
}

// AddShape adds a shape to the engine and indexes its dependencies.
func (e *Engine) AddShape(s *shape.Shape) {
	e.mu.Lock()
	e.shapes[s.ID] = s

	// Index reverse dependencies
	for _, dep := range s.Structure.Transformation.Deps {
		e.dependents[dep] = append(e.dependents[dep], s.ID)
	}
	e.recordMoment("add", s.ID, nil)
	e.mu.Unlock()

	e.notifyMutate()
}

// RemoveShape removes a shape from the engine.
// Does not check for dependents — caller must enforce Law 2.
func (e *Engine) RemoveShape(id shape.ID) {
	e.mu.Lock()
	delete(e.shapes, id)
	delete(e.dependents, id)
	e.recordMoment("remove", id, nil)
	e.mu.Unlock()
	e.notifyMutate()
}

// GetShape retrieves a shape by ID.
func (e *Engine) GetShape(id shape.ID) (*shape.Shape, bool) {
	e.mu.RLock()
	defer e.mu.RUnlock()
	s, ok := e.shapes[id]
	return s, ok
}

// PropagationReport is the complete result of an edit: the wave that
// propagated through the structure. Every dependent is accounted for.
type PropagationReport struct {
	// Tick is the global tick at which this wave occurred.
	Tick uint64 `json:"tick"`

	// Edited is the shape that was directly modified.
	Edited shape.ID `json:"edited"`

	// AutoUpdated lists shapes whose transforms handled the change.
	// These shapes are now on the latest version.
	AutoUpdated []shape.ID `json:"auto_updated,omitempty"`

	// NewerAvailable lists shapes where a dependency has a newer version.
	// The shape still coheres with the version it references. This is
	// informational: a green flag, not an error. The wave continues past these.
	NewerAvailable []shape.ID `json:"newer_available,omitempty"`

	// Locked lists shapes that were skipped due to trace locks.
	Locked []shape.ID `json:"locked,omitempty"`

	// Withdrawn lists shapes authored by blocked users that are now flagged.
	// These shapes persist (Law 2) but carry a content warning from the
	// creator who withdrew permission.
	Withdrawn []shape.ID `json:"withdrawn,omitempty"`
}

// Edit modifies a shape's character, records the change in the trace,
// and propagates the wave through all dependents recursively.
// The wave never stops: AutoUpdate updates and cascades, NewerAvailable
// marks and cascades, NoChange absorbs. The system is always in a known
// state after Edit returns.
func (e *Engine) Edit(id shape.ID, newContent string) (*PropagationReport, error) {
	e.mu.Lock()

	s, ok := e.shapes[id]
	if !ok {
		e.mu.Unlock()
		return nil, fmt.Errorf("shape not found: %s", id)
	}

	// Advance the global tick.
	e.tick++

	s.Character.Content = newContent
	s.Tick = e.tick

	// Propagate through all dependents. The edit isn't complete
	// until every consequence has been processed.
	// The edited shape itself is pre-visited: it was the source of the wave.
	report := &PropagationReport{Tick: e.tick, Edited: id}
	e.propagateFrom(id, report, map[shape.ID]bool{id: true})

	e.recordMoment("edit", id, report)

	e.mu.Unlock()
	e.notifyMutate()

	return report, nil
}

// Propagate re-processes a shape's dependents. Use this after reviewing
// a flagged shape: you've resolved it, now propagate the resolution.
// Returns the same report structure as Edit.
func (e *Engine) Propagate(changedID shape.ID) (*PropagationReport, error) {
	e.mu.Lock()

	if _, ok := e.shapes[changedID]; !ok {
		e.mu.Unlock()
		return nil, fmt.Errorf("shape not found: %s", changedID)
	}

	report := &PropagationReport{Edited: changedID}
	e.propagateFrom(changedID, report, map[shape.ID]bool{changedID: true})

	e.mu.Unlock()
	e.notifyMutate()

	return report, nil
}

// propagateFrom recursively propagates the wave from a shape through
// its dependents. The wave never deadlocks because it never waits:
//   - AutoUpdate: transform handled it, cascade continues
//   - NewerAvailable: green flag, cascade continues (dependents learn too)
//   - NoChange: wave absorbed here, no cascade needed
//   - Locked: skipped (trace lock), no cascade
//
// The visited set prevents cycles. This is the engine.
func (e *Engine) propagateFrom(changedID shape.ID, report *PropagationReport, visited map[shape.ID]bool) {
	changed := e.shapes[changedID]

	for _, depID := range e.dependents[changedID] {
		if visited[depID] {
			continue
		}
		visited[depID] = true

		dep, ok := e.shapes[depID]
		if !ok {
			continue
		}

		// No transform fn or missing transform: newer version available.
		// The wave continues: dependents of this shape learn too.
		fnName := dep.Structure.Transformation.Fn
		if fnName == "" {
			dep.Tick = report.Tick
			report.NewerAvailable = append(report.NewerAvailable, depID)
			e.propagateFrom(depID, report, visited)
			continue
		}

		fn, ok := e.transforms.Get(fnName)
		if !ok {
			dep.Tick = report.Tick
			report.NewerAvailable = append(report.NewerAvailable, depID)
			e.propagateFrom(depID, report, visited)
			continue
		}

		// Ask the transform what to do.
		change := transform.Change{
			Source:     changedID,
			NewContent: changed.Character.Content,
		}

		result, newContent, err := fn.Propagate(change, dep)
		if err != nil {
			dep.Tick = report.Tick
			report.NewerAvailable = append(report.NewerAvailable, depID)
			e.propagateFrom(depID, report, visited)
			continue
		}

		switch result {
		case transform.AutoUpdate:
			dep.Character.Content = newContent
			dep.Tick = report.Tick
			report.AutoUpdated = append(report.AutoUpdated, depID)
			e.propagateFrom(depID, report, visited)

		case transform.FlagForReview:
			dep.Tick = report.Tick
			report.NewerAvailable = append(report.NewerAvailable, depID)
			e.propagateFrom(depID, report, visited)

		case transform.NoChange:
			// Wave absorbed. This shape and its dependents are unaffected.
		}
	}
}

// Tick returns the current global tick count.
func (e *Engine) Tick() uint64 {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.tick
}

// SetTick sets the global tick (used when loading from a shape file).
func (e *Engine) SetTick(t uint64) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.tick = t
}

// Block withdraws permission for an author to derive from a shape.
// Existing derivations persist (Law 2) but are flagged with a content warning.
// The wave propagates immediately: every downstream shape by the blocked author
// gets flagged. Returns the propagation report.
func (e *Engine) Block(shapeID shape.ID, blockedAuthor shape.ID, warning string) (*PropagationReport, error) {
	e.mu.Lock()

	s, ok := e.shapes[shapeID]
	if !ok {
		e.mu.Unlock()
		return nil, fmt.Errorf("shape not found: %s", shapeID)
	}

	// Add to blocked list.
	s.Structure.Permissions.Blocked = append(s.Structure.Permissions.Blocked, blockedAuthor)
	if warning != "" {
		s.Structure.Permissions.Warning = warning
	}

	// Advance tick.
	e.tick++
	s.Tick = e.tick

	// Propagate the block wave. Walk all dependents; any shape authored
	// by the blocked user gets withdrawn.
	report := &PropagationReport{Tick: e.tick, Edited: shapeID}
	e.propagateBlock(shapeID, blockedAuthor, report, map[shape.ID]bool{shapeID: true})

	e.recordMoment("block", shapeID, report)

	e.mu.Unlock()
	e.notifyMutate()

	return report, nil
}

// propagateBlock walks dependents and flags shapes authored by the blocked user.
func (e *Engine) propagateBlock(fromID, blockedAuthor shape.ID, report *PropagationReport, visited map[shape.ID]bool) {
	for _, depID := range e.dependents[fromID] {
		if visited[depID] {
			continue
		}
		visited[depID] = true

		dep, ok := e.shapes[depID]
		if !ok {
			continue
		}

		// Check if this shape is authored by the blocked user.
		// Author is in dimensions (identity shapes use deps, but
		// the author dimension is the structural authorship marker).
		author := shape.ID(dep.Character.Dimensions["author"])
		if author == blockedAuthor {
			dep.Tick = report.Tick
			report.Withdrawn = append(report.Withdrawn, depID)
		}

		// Wave continues through ALL dependents, not just blocked ones.
		// Downstream shapes need to learn that something upstream was withdrawn.
		e.propagateBlock(depID, blockedAuthor, report, visited)
	}
}

// Status returns the current state of the engine.
func (e *Engine) Status() *EngineStatus {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return &EngineStatus{
		TotalShapes: len(e.shapes),
		Tick:        e.tick,
	}
}

// Validate checks the coherence of all shapes in the engine.
// Returns violations: dangling deps (Law 1), missing transforms, etc.
func (e *Engine) Validate() *ValidationResult {
	e.mu.RLock()
	defer e.mu.RUnlock()

	result := &ValidationResult{}

	for id, s := range e.shapes {
		// Law 1: all deps must resolve.
		for _, dep := range s.Structure.Transformation.Deps {
			if _, ok := e.shapes[dep]; !ok {
				result.DanglingDeps = append(result.DanglingDeps, DanglingDep{
					Shape: id,
					Dep:   dep,
				})
			}
		}

		// Check transform function exists.
		fn := s.Structure.Transformation.Fn
		if fn != "" {
			if _, ok := e.transforms.Get(fn); !ok {
				result.MissingTransforms = append(result.MissingTransforms, MissingTransform{
					Shape:     id,
					Transform: fn,
				})
			}
		}

		// Law 1: emergence.From refs must resolve.
		for _, from := range s.Structure.Emergence.From {
			if _, ok := e.shapes[from]; !ok {
				result.DanglingDeps = append(result.DanglingDeps, DanglingDep{
					Shape: id,
					Dep:   from,
				})
			}
		}
	}

	return result
}

// Shapes returns all shapes in the engine as a slice.
func (e *Engine) Shapes() []*shape.Shape {
	e.mu.RLock()
	defer e.mu.RUnlock()
	result := make([]*shape.Shape, 0, len(e.shapes))
	for _, s := range e.shapes {
		result = append(result, s)
	}
	return result
}

// Dependents returns the IDs of shapes that directly depend on the given shape.
func (e *Engine) Dependents(id shape.ID) []shape.ID {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.dependents[id]
}

// ShapeCount returns the number of shapes in the engine.
func (e *Engine) ShapeCount() int {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return len(e.shapes)
}

// ValidationResult holds the results of a coherence check.
type ValidationResult struct {
	DanglingDeps      []DanglingDep      `json:"dangling_deps,omitempty"`
	MissingTransforms []MissingTransform `json:"missing_transforms,omitempty"`
}

// IsCoherent returns true if no violations were found.
func (v *ValidationResult) IsCoherent() bool {
	return len(v.DanglingDeps) == 0 && len(v.MissingTransforms) == 0
}

// DanglingDep is a Law 1 violation: a dep that doesn't resolve.
type DanglingDep struct {
	Shape shape.ID `json:"shape"`
	Dep   shape.ID `json:"dep"`
}

// MissingTransform is a shape referencing a transform not in the registry.
type MissingTransform struct {
	Shape     shape.ID `json:"shape"`
	Transform string   `json:"transform"`
}

// EngineStatus is the current state of the engine.
type EngineStatus struct {
	TotalShapes int    `json:"total_shapes"`
	Tick        uint64 `json:"tick"`
}
