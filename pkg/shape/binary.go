package shape

import (
	"encoding/binary"
	"fmt"
	"io"
	"math"
	"sort"
)

// Binary shape file format.
//
// The entire graph lives in one file. The engine binary reads it,
// operates on it, writes changes back. Nothing else exists.
//
// Layout:
//   [Magic: "SHPE" 4 bytes]
//   [Version: 1 byte]
//   [Global Tick: 8 bytes big-endian]
//   [Shape Count: varint]
//   [Shape 0][Shape 1]...[Shape N]
//
// Each shape is length-prefixed fields, varints for counts and lengths,
// sorted keys for determinism. No tags, no padding. Just structure.

var magic = [4]byte{'S', 'H', 'P', 'E'}

const version = 1

// MarshalGraph serializes an entire shape graph into a single binary blob.
// This is the canonical on-disk format. Everything else is a projection.
func MarshalGraph(tick uint64, shapes []*Shape) ([]byte, error) {
	// Sort shapes by ID for deterministic output
	sorted := make([]*Shape, len(shapes))
	copy(sorted, shapes)
	sort.Slice(sorted, func(i, j int) bool {
		return sorted[i].ID < sorted[j].ID
	})

	var buf []byte

	// Header
	buf = append(buf, magic[:]...)
	buf = append(buf, version)
	buf = appendUint64(buf, tick)
	buf = appendVarint(buf, uint64(len(sorted)))

	// Shapes
	for _, s := range sorted {
		buf = marshalShape(buf, s)
	}

	return buf, nil
}

// UnmarshalGraph deserializes an entire shape graph from binary.
// Returns the global tick and all shapes.
func UnmarshalGraph(data []byte) (uint64, []*Shape, error) {
	r := &reader{data: data}

	// Magic
	m, err := r.readBytes(4)
	if err != nil {
		return 0, nil, fmt.Errorf("reading magic: %w", err)
	}
	if m[0] != magic[0] || m[1] != magic[1] || m[2] != magic[2] || m[3] != magic[3] {
		return 0, nil, fmt.Errorf("not a shape file: bad magic %q", m)
	}

	// Version
	v, err := r.readByte()
	if err != nil {
		return 0, nil, fmt.Errorf("reading version: %w", err)
	}
	if v != version {
		return 0, nil, fmt.Errorf("unsupported version: %d", v)
	}

	// Global tick
	tick, err := r.readUint64()
	if err != nil {
		return 0, nil, fmt.Errorf("reading tick: %w", err)
	}

	// Shape count
	count, err := r.readVarint()
	if err != nil {
		return 0, nil, fmt.Errorf("reading shape count: %w", err)
	}

	shapes := make([]*Shape, 0, count)
	for i := uint64(0); i < count; i++ {
		s, err := unmarshalShape(r)
		if err != nil {
			return 0, nil, fmt.Errorf("reading shape %d: %w", i, err)
		}
		shapes = append(shapes, s)
	}

	return tick, shapes, nil
}

func marshalShape(buf []byte, s *Shape) []byte {
	// ID
	buf = appendString(buf, string(s.ID))

	// Tick
	buf = appendUint64(buf, s.Tick)

	// Character: dimensions (sorted by key for determinism).
	// Insertion sort: no allocation, shapes typically have <10 dimensions.
	keys := make([]string, 0, len(s.Character.Dimensions))
	for k := range s.Character.Dimensions {
		keys = append(keys, k)
	}
	for i := 1; i < len(keys); i++ {
		for j := i; j > 0 && keys[j] < keys[j-1]; j-- {
			keys[j], keys[j-1] = keys[j-1], keys[j]
		}
	}
	buf = appendVarint(buf, uint64(len(keys)))
	for _, k := range keys {
		buf = appendString(buf, k)
		buf = appendString(buf, s.Character.Dimensions[k])
	}

	// Character: content
	buf = appendString(buf, s.Character.Content)

	// Structure.Transformation
	buf = appendString(buf, s.Structure.Transformation.Fn)
	buf = appendIDs(buf, s.Structure.Transformation.Deps)

	// Constraints
	buf = appendVarint(buf, uint64(len(s.Structure.Transformation.Constraints)))
	for _, c := range s.Structure.Transformation.Constraints {
		buf = append(buf, byte(c.Law))
		buf = append(buf, encodeStatus(c.Status))
		buf = appendString(buf, c.Note)
	}

	// Structure.Emergence
	buf = appendVarint(buf, uint64(s.Structure.Emergence.Layer))
	buf = appendIDs(buf, s.Structure.Emergence.From)
	buf = appendIDs(buf, s.Structure.Emergence.Produces)

	// Structure.Permissions
	buf = appendIDs(buf, s.Structure.Permissions.Blocked)
	buf = appendStrings(buf, s.Structure.Permissions.Visibility)
	buf = appendString(buf, s.Structure.Permissions.Warning)

	return buf
}

func unmarshalShape(r *reader) (*Shape, error) {
	s := &Shape{}

	// ID
	id, err := r.readString()
	if err != nil {
		return nil, fmt.Errorf("id: %w", err)
	}
	s.ID = ID(id)

	// Tick
	s.Tick, err = r.readUint64()
	if err != nil {
		return nil, fmt.Errorf("tick: %w", err)
	}

	// Dimensions
	dimCount, err := r.readVarint()
	if err != nil {
		return nil, fmt.Errorf("dimension count: %w", err)
	}
	if dimCount > 0 {
		s.Character.Dimensions = make(map[string]string, dimCount)
		for i := uint64(0); i < dimCount; i++ {
			k, err := r.readString()
			if err != nil {
				return nil, fmt.Errorf("dimension key %d: %w", i, err)
			}
			v, err := r.readString()
			if err != nil {
				return nil, fmt.Errorf("dimension value %d: %w", i, err)
			}
			s.Character.Dimensions[k] = v
		}
	}

	// Content
	content, err := r.readString()
	if err != nil {
		return nil, fmt.Errorf("content: %w", err)
	}
	s.Character.Content = content

	// Transformation.Fn
	fn, err := r.readString()
	if err != nil {
		return nil, fmt.Errorf("fn: %w", err)
	}
	s.Structure.Transformation.Fn = fn

	// Transformation.Deps
	s.Structure.Transformation.Deps, err = r.readIDs()
	if err != nil {
		return nil, fmt.Errorf("deps: %w", err)
	}

	// Constraints
	constraintCount, err := r.readVarint()
	if err != nil {
		return nil, fmt.Errorf("constraint count: %w", err)
	}
	if constraintCount > 0 {
		s.Structure.Transformation.Constraints = make([]Constraint, constraintCount)
		for i := uint64(0); i < constraintCount; i++ {
			law, err := r.readByte()
			if err != nil {
				return nil, fmt.Errorf("constraint %d law: %w", i, err)
			}
			statusByte, err := r.readByte()
			if err != nil {
				return nil, fmt.Errorf("constraint %d status: %w", i, err)
			}
			note, err := r.readString()
			if err != nil {
				return nil, fmt.Errorf("constraint %d note: %w", i, err)
			}
			s.Structure.Transformation.Constraints[i] = Constraint{
				Law:    int(law),
				Status: decodeStatus(statusByte),
				Note:   note,
			}
		}
	}

	// Emergence
	layer, err := r.readVarint()
	if err != nil {
		return nil, fmt.Errorf("layer: %w", err)
	}
	s.Structure.Emergence.Layer = int(layer)

	s.Structure.Emergence.From, err = r.readIDs()
	if err != nil {
		return nil, fmt.Errorf("emergence from: %w", err)
	}

	s.Structure.Emergence.Produces, err = r.readIDs()
	if err != nil {
		return nil, fmt.Errorf("emergence produces: %w", err)
	}

	// Permissions
	s.Structure.Permissions.Blocked, err = r.readIDs()
	if err != nil {
		return nil, fmt.Errorf("permissions blocked: %w", err)
	}

	vis, err := r.readStrings()
	if err != nil {
		return nil, fmt.Errorf("permissions visibility: %w", err)
	}
	s.Structure.Permissions.Visibility = vis

	warning, err := r.readString()
	if err != nil {
		return nil, fmt.Errorf("permissions warning: %w", err)
	}
	s.Structure.Permissions.Warning = warning

	return s, nil
}

// --- encoding helpers ---

func appendUint64(buf []byte, v uint64) []byte {
	return binary.BigEndian.AppendUint64(buf, v)
}

func appendVarint(buf []byte, v uint64) []byte {
	return binary.AppendUvarint(buf, v)
}

func appendString(buf []byte, s string) []byte {
	buf = appendVarint(buf, uint64(len(s)))
	return append(buf, s...)
}

func appendIDs(buf []byte, ids []ID) []byte {
	buf = appendVarint(buf, uint64(len(ids)))
	for _, id := range ids {
		buf = appendString(buf, string(id))
	}
	return buf
}

func appendStrings(buf []byte, ss []string) []byte {
	buf = appendVarint(buf, uint64(len(ss)))
	for _, s := range ss {
		buf = appendString(buf, s)
	}
	return buf
}

func encodeStatus(s ConstraintStatus) byte {
	switch s {
	case Satisfied:
		return 1
	case Violated:
		return 2
	case Unchecked:
		return 3
	default:
		return 0
	}
}

func decodeStatus(b byte) ConstraintStatus {
	switch b {
	case 1:
		return Satisfied
	case 2:
		return Violated
	case 3:
		return Unchecked
	default:
		return ""
	}
}

// --- reader ---

type reader struct {
	data []byte
	pos  int
}

func (r *reader) readByte() (byte, error) {
	if r.pos >= len(r.data) {
		return 0, io.ErrUnexpectedEOF
	}
	b := r.data[r.pos]
	r.pos++
	return b, nil
}

func (r *reader) readBytes(n int) ([]byte, error) {
	if r.pos+n > len(r.data) {
		return nil, io.ErrUnexpectedEOF
	}
	b := r.data[r.pos : r.pos+n]
	r.pos += n
	return b, nil
}

func (r *reader) readUint64() (uint64, error) {
	b, err := r.readBytes(8)
	if err != nil {
		return 0, err
	}
	return binary.BigEndian.Uint64(b), nil
}

func (r *reader) readVarint() (uint64, error) {
	if r.pos >= len(r.data) {
		return 0, io.ErrUnexpectedEOF
	}
	v, n := binary.Uvarint(r.data[r.pos:])
	if n <= 0 {
		return 0, fmt.Errorf("invalid varint")
	}
	r.pos += n
	return v, nil
}

func (r *reader) readString() (string, error) {
	length, err := r.readVarint()
	if err != nil {
		return "", err
	}
	if length > math.MaxInt32 {
		return "", fmt.Errorf("string too long: %d", length)
	}
	b, err := r.readBytes(int(length))
	if err != nil {
		return "", err
	}
	return string(b), nil
}

func (r *reader) readIDs() ([]ID, error) {
	count, err := r.readVarint()
	if err != nil {
		return nil, err
	}
	if count == 0 {
		return nil, nil
	}
	ids := make([]ID, count)
	for i := uint64(0); i < count; i++ {
		s, err := r.readString()
		if err != nil {
			return nil, err
		}
		ids[i] = ID(s)
	}
	return ids, nil
}

func (r *reader) readStrings() ([]string, error) {
	count, err := r.readVarint()
	if err != nil {
		return nil, err
	}
	if count == 0 {
		return nil, nil
	}
	ss := make([]string, count)
	for i := uint64(0); i < count; i++ {
		s, err := r.readString()
		if err != nil {
			return nil, err
		}
		ss[i] = s
	}
	return ss, nil
}
