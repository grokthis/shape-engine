// Package pool provides arena-style allocation for shape values.
//
// A Pool is a shape: a fixed-size container of slots. Allocation is
// returning the next free slot. Deallocation is resetting the pool.
// The same abstraction backs memory, files, cache, and replication.
//
// This eliminates GC pressure from the interpreter hot path.
// Instead of allocating value objects on the Go heap (which the GC
// must scan and collect), the evaluator allocates from a pool that
// resets in O(1) when the evaluation completes.
//
// The pool IS the hardware: a fixed grid of slots, each holds a value,
// addressing by index. Same as the FPGA gate lattice.
package pool

// Pool is a pre-allocated arena of slots.
// Allocation is O(1): return slot at next index.
// Reset is O(1): set index to 0.
type Pool[T any] struct {
	slots []T
	next  int
}

// New creates a pool with capacity slots.
func New[T any](capacity int) *Pool[T] {
	return &Pool[T]{
		slots: make([]T, capacity),
	}
}

// Alloc returns a pointer to the next free slot.
// If the pool is full, it grows (doubles capacity).
func (p *Pool[T]) Alloc() *T {
	if p.next >= len(p.slots) {
		// Grow: double the capacity.
		newSlots := make([]T, len(p.slots)*2)
		copy(newSlots, p.slots)
		p.slots = newSlots
	}
	slot := &p.slots[p.next]
	p.next++
	return slot
}

// AllocN returns a slice of n contiguous slots.
func (p *Pool[T]) AllocN(n int) []T {
	if p.next+n > len(p.slots) {
		needed := p.next + n
		newCap := len(p.slots) * 2
		if newCap < needed {
			newCap = needed
		}
		newSlots := make([]T, newCap)
		copy(newSlots, p.slots)
		p.slots = newSlots
	}
	start := p.next
	p.next += n
	return p.slots[start : start+n]
}

// Reset returns all slots to the pool. O(1).
// Does not zero the memory. The next Alloc will overwrite.
func (p *Pool[T]) Reset() {
	p.next = 0
}

// Used returns the number of allocated slots.
func (p *Pool[T]) Used() int {
	return p.next
}

// Cap returns the total capacity.
func (p *Pool[T]) Cap() int {
	return len(p.slots)
}

// Get returns the slot at index i.
func (p *Pool[T]) Get(i int) *T {
	if i < 0 || i >= p.next {
		return nil
	}
	return &p.slots[i]
}
