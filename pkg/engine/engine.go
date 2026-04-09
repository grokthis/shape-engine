// Package engine is the composition layer. The engine runtime emerges
// from shapes, traces, transforms, and dimensions: it composes them
// into a functioning system.
package engine

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"sort"
	"strings"
	"sync"

	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/transform"
)

// sortedEntry is one slot in the time-dilated index.
// Pre-sorted by ID so Signature() is a pure linear fold.
type sortedEntry struct {
	id string
	s  *shape.Shape
}

// Namespace tiers: owner (user/agent), local (os), global (world).
// Write isolation: actors can only write to their own namespace prefix.

// Old comment line removed by rename.
//   - "ash"            → "user.ash."
//   - "agent:copilot"  → "agent.copilot."
//   - "" or "system"   → "" (unchecked bootstrap mode)
// NamespaceForActor returns the writable namespace prefix for an actor.
func NamespaceForActor(actor string) string {
	if actor == "system" {
		return "" // unrestricted
	}
	if actor == "" {
		return "\x00" // locked: matches nothing, all writes rejected
	}
	if strings.HasPrefix(actor, "agent:") {
		return "agent." + actor[6:] + "."
	}
	// If actor already looks like a namespace (user.X or agent.X), use it directly.
	if strings.HasPrefix(actor, "user.") || strings.HasPrefix(actor, "agent.") {
		return actor + "."
	}
	return "user." + actor + "."
}

// ParseNamespace splits a shape ID into (namespace, suffix).
//   - "os.render.foo"        → ("os", "render.foo")
//   - "user.ash.render.foo"  → ("user.ash", "render.foo")
//   - "agent.copilot.draft"  → ("agent.copilot", "draft")
//   - "world.theme.dark"     → ("world", "theme.dark")
func ParseNamespace(id shape.ID) (ns, suffix string) {
	s := string(id)
	dot := strings.IndexByte(s, '.')
	if dot < 0 {
		return s, ""
	}
	kind := s[:dot]
	rest := s[dot+1:]
	switch kind {
	case "user", "agent":
		// Second segment is the name.
		dot2 := strings.IndexByte(rest, '.')
		if dot2 < 0 {
			return s, ""
		}
		return kind + "." + rest[:dot2], rest[dot2+1:]
	default:
		return kind, rest
	}
}

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

	// Children index: for each prefix, the direct child segment names.
	// "os.shell" -> ["cmd", "..."] (the unique next-level segments).
	children map[string]map[string]bool

	// tick is the global tick counter. Every Edit increments this.
	// Every shape touched by the wave gets stamped with the current tick.
	// This is a structural position, not a timestamp.
	tick uint64

	// dilation is the time dilation factor. When > 1, N inner mutations
	// share a single outer tick. Set via the dilate builtin. 0 or 1 = normal.
	dilation uint64

	// dilationCount tracks mutations within the current dilation window.
	// When it reaches dilation, the outer tick advances and the counter resets.
	dilationCount uint64

	// actor is the user shape ID of the current session.
	// Every trace moment is structurally connected to the actor.
	// This is the audit trail: attention costs ticks.
	actor string

	// trace is the append-only log of all mutations. Every AddShape, Edit,
	// Remove, and Block produces a Moment. The trace is the complete history:
	// any prior state can be reconstructed from it.
	trace []Moment

	// overlayCache maps "actor:requestedID" → resolved ID for overlay lookups.
	// Invalidated on any mutation to user/agent namespace shapes.
	overlayCache map[string]shape.ID

	// sorted is the time-dilated index: shapes pre-ordered by ID so that
	// Signature() never allocates or sorts. Binary search finds the prefix
	// boundary, then the fold is a linear scan over contiguous hashes.
	// Maintained on every add/remove. The dilation: O(log n) insert pays
	// once so the fold runs in O(k) where k = matching shapes.
	sorted []sortedEntry


	// onMutate is called after every mutation (AddShape, Edit, Block).
	// The engine is unlocked when this fires. Used for auto-persistence.
	onMutate func()

	// ext holds extension objects (LLM client, etc.) without import coupling.
	// Keys are package paths, values are typed by the caller.
	ext map[string]interface{}

	// Debug is a process-level flag. When set, every builtin operation
	// prints its inputs and outputs to stderr. Accessible from shape-lang
	// via the debug() builtin.
	Debug bool
}

// ErrNamespace is returned when a write violates namespace isolation.
type ErrNamespace struct {
	Actor  string
	Target shape.ID
}

func (e *ErrNamespace) Error() string {
	return fmt.Sprintf("namespace violation: actor %q cannot write to %s", e.Actor, e.Target)
}

// checkWrite verifies the current actor can write to the target shape ID.
// Returns nil if allowed, ErrNamespace if not.
func (e *Engine) checkWrite(target shape.ID) error {
	prefix := NamespaceForActor(e.actor)
	if prefix == "" {
		return nil // bootstrap/system mode
	}
	if strings.HasPrefix(string(target), prefix) {
		return nil
	}
	return &ErrNamespace{Actor: e.actor, Target: target}
}

// New creates a new engine with an empty structure.
func New() *Engine {
	return &Engine{
		shapes:       make(map[shape.ID]*shape.Shape),
		transforms:   transform.NewRegistry(),
		dependents:   make(map[shape.ID][]shape.ID),
		children:     make(map[string]map[string]bool),
		overlayCache: make(map[string]shape.ID),
		ext:          make(map[string]interface{}),
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

// advanceTick increments the global tick, respecting time dilation.
// Under dilation N, the outer tick advances once per N mutations.
// Must be called with lock held.
func (e *Engine) advanceTick() {
	if e.dilation <= 1 {
		e.tick++
		return
	}
	e.dilationCount++
	if e.dilationCount >= e.dilation {
		e.tick++
		e.dilationCount = 0
	}
}

// SetDilation sets the time dilation factor. N inner mutations share one
// outer tick. Set to 0 or 1 to disable. Returns the previous factor.
func (e *Engine) SetDilation(factor uint64) uint64 {
	e.mu.Lock()
	defer e.mu.Unlock()
	prev := e.dilation
	e.dilation = factor
	e.dilationCount = 0
	return prev
}

// Dilation returns the current time dilation factor.
func (e *Engine) Dilation() uint64 {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.dilation
}

// AddShape adds a shape to the engine with namespace enforcement.
// Returns ErrNamespace if the current actor cannot write to this shape's namespace.
func (e *Engine) AddShape(s *shape.Shape) error {
	if err := e.checkWrite(s.ID); err != nil {
		return err
	}
	e.addShapeInternal(s)
	return nil
}

// AddShapeUnchecked adds a shape without namespace enforcement.
// Use only for bootstrap loading (before any actor is set).
func (e *Engine) AddShapeUnchecked(s *shape.Shape) {
	e.addShapeInternal(s)
}

// addShapeInternal is the shared implementation for AddShape/AddShapeUnchecked.
func (e *Engine) addShapeInternal(s *shape.Shape) {
	e.mu.Lock()
	e.shapes[s.ID] = s

	// Index reverse dependencies
	for _, dep := range s.Structure.Transformation.Deps {
		e.dependents[dep] = append(e.dependents[dep], s.ID)
	}

	// Index children: each dot-separated segment registers with its parent prefix.
	id := string(s.ID)
	for i := len(id) - 1; i >= 0; i-- {
		if id[i] == '.' {
			parent := id[:i]
			child := id[i+1:]
			// Only the immediate next segment, not the full rest.
			if dot := indexByte(child, '.'); dot >= 0 {
				child = child[:dot]
			}
			if e.children[parent] == nil {
				e.children[parent] = make(map[string]bool)
			}
			e.children[parent][child] = true
			break
		}
	}
	// Top-level: shapes without dots are children of ""
	if indexByte(id, '.') < 0 {
		if e.children[""] == nil {
			e.children[""] = make(map[string]bool)
		}
		e.children[""][id] = true
	}

	e.invalidateOverlayCache(s.ID)
	e.stampHash(s)
	e.sortedInsert(s)
	e.recordMoment("add", s.ID, nil)
	e.mu.Unlock()

	e.notifyMutate()
}

// RemoveShape removes a shape from the engine with namespace enforcement.
func (e *Engine) RemoveShape(id shape.ID) error {
	if err := e.checkWrite(id); err != nil {
		return err
	}
	e.mu.Lock()
	delete(e.shapes, id)
	delete(e.dependents, id)
	e.sortedRemove(id)
	e.invalidateOverlayCache(id)
	e.recordMoment("remove", id, nil)
	e.mu.Unlock()
	e.notifyMutate()
	return nil
}

// GetShape retrieves a shape by ID (direct lookup, no overlay).
func (e *Engine) GetShape(id shape.ID) (*shape.Shape, bool) {
	e.mu.RLock()
	defer e.mu.RUnlock()
	s, ok := e.shapes[id]
	return s, ok
}

// ResolveShape looks up a shape with namespace overlay.
// For os.* or world.* shapes, checks user override first.
// Resolution chain: user.<actor>.<suffix> → os.<suffix> → world.<suffix>
// Returns the shape, the actual resolved ID, and whether it was found.
func (e *Engine) ResolveShape(id shape.ID) (*shape.Shape, shape.ID, bool) {
	e.mu.RLock()
	defer e.mu.RUnlock()

	actor := e.actor
	if actor == "" {
		// No actor: direct lookup only.
		s, ok := e.shapes[id]
		return s, id, ok
	}

	// Check cache.
	cacheKey := actor + ":" + string(id)
	if resolved, ok := e.overlayCache[cacheKey]; ok {
		s, ok := e.shapes[resolved]
		if ok {
			return s, resolved, true
		}
		// Cache stale, fall through.
	}

	ns, suffix := ParseNamespace(id)
	if suffix == "" || (ns != "os" && ns != "world") {
		// Not an overlayable namespace (already user/agent, or no suffix).
		s, ok := e.shapes[id]
		if ok {
			e.overlayCache[cacheKey] = id
		}
		return s, id, ok
	}

	// Build resolution chain: user override → original.
	prefix := NamespaceForActor(actor)
	userID := shape.ID(prefix + suffix)

	if s, ok := e.shapes[userID]; ok {
		e.overlayCache[cacheKey] = userID
		return s, userID, true
	}

	// For world.* shapes, also check os.* override.
	if ns == "world" {
		osID := shape.ID("os." + suffix)
		if s, ok := e.shapes[osID]; ok {
			e.overlayCache[cacheKey] = osID
			return s, osID, true
		}
	}

	// Fall back to original.
	s, ok := e.shapes[id]
	if ok {
		e.overlayCache[cacheKey] = id
	}
	return s, id, ok
}

// invalidateOverlayCache clears overlay cache entries affected by a shape mutation.
// Called with lock held.
func (e *Engine) invalidateOverlayCache(id shape.ID) {
	ns, _ := ParseNamespace(id)
	if strings.HasPrefix(ns, "user.") || strings.HasPrefix(ns, "agent.") {
		// User/agent shape changed: clear all cache (could be smarter but safe).
		clear(e.overlayCache)
	}
}

// Promote copies a shape and its dependency tree from one namespace to another.
// This is the only cross-namespace write operation.
// targetTier is "local" (os.*) or "global" (world.*).
func (e *Engine) Promote(sourceID shape.ID, targetTier string) ([]shape.ID, error) {
	// Determine target prefix.
	var targetPrefix string
	switch targetTier {
	case "local":
		targetPrefix = "os."
	case "global":
		targetPrefix = "world."
	default:
		return nil, fmt.Errorf("promote: invalid tier %q (must be local or global)", targetTier)
	}

	// Check promotion permission.
	actor := e.Actor()
	if actor == "" {
		return nil, fmt.Errorf("promote: no actor set")
	}
	permID := shape.ID("os.permissions.promote." + actor)
	if _, ok := e.GetShape(permID); !ok {
		return nil, fmt.Errorf("promote: actor %q lacks promotion permission (need %s)", actor, permID)
	}

	// Collect source shape and its dep tree.
	sourceNS, sourceSuffix := ParseNamespace(sourceID)
	if sourceSuffix == "" {
		return nil, fmt.Errorf("promote: cannot promote root namespace shape %s", sourceID)
	}

	// DFS to collect all shapes in the dep tree.
	var toPromote []shape.ID
	visited := map[shape.ID]bool{}
	var walk func(id shape.ID)
	walk = func(id shape.ID) {
		if visited[id] {
			return
		}
		visited[id] = true
		s, ok := e.GetShape(id)
		if !ok {
			return
		}
		// Only promote shapes in the same source namespace.
		ns, _ := ParseNamespace(id)
		if ns == sourceNS {
			toPromote = append(toPromote, id)
		}
		for _, dep := range s.Structure.Transformation.Deps {
			walk(dep)
		}
	}
	walk(sourceID)

	if len(toPromote) == 0 {
		return nil, fmt.Errorf("promote: source shape %s not found", sourceID)
	}

	// Copy each shape with rewritten ID.
	promoted := make([]shape.ID, 0, len(toPromote))
	e.mu.Lock()
	e.advanceTick()
	for _, srcID := range toPromote {
		src, ok := e.shapes[srcID]
		if !ok {
			continue
		}
		_, suffix := ParseNamespace(srcID)
		newID := shape.ID(targetPrefix + suffix)

		// Deep copy.
		newShape := &shape.Shape{
			ID: newID,
			Character: shape.Character{
				Content:    src.Character.Content,
				Dimensions: make(map[string]string, len(src.Character.Dimensions)),
			},
			Structure: shape.Structure{
				Emergence:   src.Structure.Emergence,
				Permissions: src.Structure.Permissions,
			},
			Tick: e.tick,
		}
		for k, v := range src.Character.Dimensions {
			newShape.Character.Dimensions[k] = v
		}
		// Rewrite deps that are in the source namespace.
		for _, dep := range src.Structure.Transformation.Deps {
			depNS, depSuffix := ParseNamespace(dep)
			if depNS == sourceNS {
				newShape.Structure.Transformation.Deps = append(newShape.Structure.Transformation.Deps, shape.ID(targetPrefix+depSuffix))
			} else {
				newShape.Structure.Transformation.Deps = append(newShape.Structure.Transformation.Deps, dep)
			}
		}

		e.shapes[newID] = newShape
		promoted = append(promoted, newID)
	}
	e.recordMoment("promote", sourceID, nil)
	e.mu.Unlock()
	e.notifyMutate()

	return promoted, nil
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
	if err := e.checkWrite(id); err != nil {
		return nil, err
	}
	e.mu.Lock()

	s, ok := e.shapes[id]
	if !ok {
		e.mu.Unlock()
		return nil, fmt.Errorf("shape not found: %s", id)
	}

	// Advance the global tick.
	e.advanceTick()

	s.Character.Content = newContent
	s.Tick = e.tick
	e.stampHash(s)

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
	e.advanceTick()
	s.Tick = e.tick
	e.stampHash(s)

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

// EditDim atomically sets a single dimension on an existing shape.
// Safe for concurrent use: the entire read-modify-write happens under the lock.
func (e *Engine) EditDim(id shape.ID, key, value string) error {
	if err := e.checkWrite(id); err != nil {
		return err
	}
	e.mu.Lock()
	s, ok := e.shapes[id]
	if !ok {
		e.mu.Unlock()
		return fmt.Errorf("set_dim: shape not found: %s", id)
	}
	if s.Character.Dimensions == nil {
		s.Character.Dimensions = make(map[string]string)
	}
	s.Character.Dimensions[key] = value
	e.advanceTick()
	s.Tick = e.tick
	e.stampHash(s)
	e.recordMoment("edit", id, nil)
	e.mu.Unlock()
	e.notifyMutate()
	return nil
}

// SetContent atomically sets the content of an existing shape, or creates it.
// Returns ErrNamespace if the current actor cannot write to this shape's namespace.
func (e *Engine) SetContent(id shape.ID, content string) error {
	if err := e.checkWrite(id); err != nil {
		return err
	}
	e.mu.Lock()
	s, ok := e.shapes[id]
	if !ok {
		// Create a minimal shape.
		s = &shape.Shape{ID: id}
		e.shapes[id] = s
		// Index children.
		sid := string(id)
		for i := len(sid) - 1; i >= 0; i-- {
			if sid[i] == '.' {
				parent := sid[:i]
				child := sid[i+1:]
				if dot := indexByte(child, '.'); dot >= 0 {
					child = child[:dot]
				}
				if e.children[parent] == nil {
					e.children[parent] = make(map[string]bool)
				}
				e.children[parent][child] = true
				break
			}
		}
	}
	s.Character.Content = content
	e.advanceTick()
	s.Tick = e.tick
	e.stampHash(s)
	e.recordMoment("edit", id, nil)
	e.mu.Unlock()
	e.notifyMutate()
	return nil
}

// stampHash computes and stores the structural hash on a shape.
// Called at birth (AddShape) and at every mutation. The hash encodes
// everything that makes this moment this moment: ID, content, dimensions,
// layer, tick. No dep hashes — the shape's hash is its own identity.
// Tree signatures are computed by folding over these intrinsic hashes.
// Must be called with lock held.
func (e *Engine) stampHash(s *shape.Shape) {
	h := sha256.New()
	h.Write([]byte(s.ID))
	h.Write([]byte{0})
	h.Write([]byte(s.Character.Content))
	h.Write([]byte{0})

	// Dimensions: sorted keys for determinism.
	var dimKeys []string
	for k := range s.Character.Dimensions {
		dimKeys = append(dimKeys, k)
	}
	sort.Strings(dimKeys)
	for _, k := range dimKeys {
		h.Write([]byte(k))
		h.Write([]byte{0})
		h.Write([]byte(s.Character.Dimensions[k]))
		h.Write([]byte{0})
	}

	// Deps: the shape's own declared dependencies (IDs only, not their hashes).
	// This is the shape's structure, not a Merkle tree.
	for _, dep := range s.Structure.Transformation.Deps {
		h.Write([]byte(dep))
		h.Write([]byte{0})
	}

	// Layer and tick encode structural position and version.
	fmt.Fprintf(h, "%d:%d", s.Structure.Emergence.Layer, s.Tick)
	h.Write([]byte{0xFF})

	copy(s.Hash[:], h.Sum(nil))
}

// sortedInsert adds a shape to the time-dilated index in O(log n).
// Must be called with lock held.
func (e *Engine) sortedInsert(s *shape.Shape) {
	sid := string(s.ID)
	i := sort.Search(len(e.sorted), func(j int) bool { return e.sorted[j].id >= sid })
	// Update in place if already present (edit/re-add).
	if i < len(e.sorted) && e.sorted[i].id == sid {
		e.sorted[i].s = s
		return
	}
	e.sorted = append(e.sorted, sortedEntry{})
	copy(e.sorted[i+1:], e.sorted[i:])
	e.sorted[i] = sortedEntry{id: sid, s: s}
}

// sortedRemove removes a shape from the time-dilated index in O(log n + k).
// Must be called with lock held.
func (e *Engine) sortedRemove(id shape.ID) {
	sid := string(id)
	i := sort.Search(len(e.sorted), func(j int) bool { return e.sorted[j].id >= sid })
	if i < len(e.sorted) && e.sorted[i].id == sid {
		e.sorted = append(e.sorted[:i], e.sorted[i+1:]...)
	}
}

// Signature computes a structural hash over all shapes under a prefix.
// Time-dilated: the sorted index is pre-computed, so this is a binary search
// to find the prefix boundary + a linear fold over contiguous hashes.
// No allocation, no sort, no cache. Always correct.
func (e *Engine) Signature(prefix string) string {
	e.mu.RLock()
	defer e.mu.RUnlock()

	h := sha256.New()

	if prefix == "" {
		// Full engine: linear scan, no search needed.
		for i := range e.sorted {
			h.Write(e.sorted[i].s.Hash[:])
		}
	} else {
		// Binary search for first entry >= prefix.
		start := sort.Search(len(e.sorted), func(i int) bool { return e.sorted[i].id >= prefix })
		pfx := prefix + "."
		for i := start; i < len(e.sorted); i++ {
			sid := e.sorted[i].id
			if sid != prefix && !strings.HasPrefix(sid, pfx) {
				if sid > pfx {
					break // Past the prefix range, done.
				}
				continue
			}
			h.Write(e.sorted[i].s.Hash[:])
		}
	}

	return hex.EncodeToString(h.Sum(nil))
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

// Children returns the direct child segment names for a prefix.
// O(1) lookup from the children index.
func (e *Engine) Children(prefix string) []string {
	e.mu.RLock()
	defer e.mu.RUnlock()
	kids := e.children[prefix]
	if kids == nil {
		return nil
	}
	result := make([]string, 0, len(kids))
	for k := range kids {
		result = append(result, k)
	}
	return result
}

func indexByte(s string, c byte) int {
	for i := 0; i < len(s); i++ {
		if s[i] == c {
			return i
		}
	}
	return -1
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
