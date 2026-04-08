// Package text provides string primitives without importing strings/fmt/strconv.
//
// These are byte-level operations on UTF-8 strings. They mirror the
// shape-lang string builtins and the hardware byte operations.
// The Go shim uses these instead of stdlib string packages.
//
// Zero external imports. This is the text layer of the shape machine.
package text

import "errors"

// Contains reports whether sub is within s.
func Contains(s, sub string) bool {
	if len(sub) == 0 {
		return true
	}
	if len(sub) > len(s) {
		return false
	}
	for i := 0; i <= len(s)-len(sub); i++ {
		if s[i:i+len(sub)] == sub {
			return true
		}
	}
	return false
}

// HasPrefix reports whether s starts with prefix.
func HasPrefix(s, prefix string) bool {
	return len(s) >= len(prefix) && s[:len(prefix)] == prefix
}

// HasSuffix reports whether s ends with suffix.
func HasSuffix(s, suffix string) bool {
	return len(s) >= len(suffix) && s[len(s)-len(suffix):] == suffix
}

// Index returns the index of the first occurrence of sub in s, or -1.
func Index(s, sub string) int {
	if len(sub) == 0 {
		return 0
	}
	if len(sub) > len(s) {
		return -1
	}
	for i := 0; i <= len(s)-len(sub); i++ {
		if s[i:i+len(sub)] == sub {
			return i
		}
	}
	return -1
}

// Split splits s by sep. Returns all substrings between separators.
func Split(s, sep string) []string {
	if sep == "" {
		// Split into characters.
		result := make([]string, len(s))
		for i := range s {
			result[i] = string(s[i])
		}
		return result
	}
	var result []string
	for {
		i := Index(s, sep)
		if i < 0 {
			result = append(result, s)
			break
		}
		result = append(result, s[:i])
		s = s[i+len(sep):]
	}
	return result
}

// Join concatenates elements with sep between each.
func Join(elems []string, sep string) string {
	if len(elems) == 0 {
		return ""
	}
	n := len(sep) * (len(elems) - 1)
	for _, e := range elems {
		n += len(e)
	}
	buf := make([]byte, 0, n)
	for i, e := range elems {
		if i > 0 {
			buf = append(buf, sep...)
		}
		buf = append(buf, e...)
	}
	return string(buf)
}

// TrimSpace removes leading and trailing whitespace.
func TrimSpace(s string) string {
	start := 0
	for start < len(s) && isSpace(s[start]) {
		start++
	}
	end := len(s)
	for end > start && isSpace(s[end-1]) {
		end--
	}
	return s[start:end]
}

// ReplaceAll replaces all non-overlapping occurrences of old with new.
func ReplaceAll(s, old, new string) string {
	if old == "" {
		return s
	}
	var buf []byte
	for {
		i := Index(s, old)
		if i < 0 {
			buf = append(buf, s...)
			break
		}
		buf = append(buf, s[:i]...)
		buf = append(buf, new...)
		s = s[i+len(old):]
	}
	return string(buf)
}

// ToUpper converts ASCII lowercase to uppercase.
func ToUpper(s string) string {
	buf := make([]byte, len(s))
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c >= 'a' && c <= 'z' {
			buf[i] = c - 32
		} else {
			buf[i] = c
		}
	}
	return string(buf)
}

// ToLower converts ASCII uppercase to lowercase.
func ToLower(s string) string {
	buf := make([]byte, len(s))
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c >= 'A' && c <= 'Z' {
			buf[i] = c + 32
		} else {
			buf[i] = c
		}
	}
	return string(buf)
}

// Repeat returns s repeated n times.
func Repeat(s string, n int) string {
	if n <= 0 {
		return ""
	}
	buf := make([]byte, len(s)*n)
	for i := 0; i < n; i++ {
		copy(buf[i*len(s):], s)
	}
	return string(buf)
}

// EqualFold reports whether s and t are equal under ASCII case folding.
func EqualFold(s, t string) bool {
	if len(s) != len(t) {
		return false
	}
	for i := 0; i < len(s); i++ {
		a, b := s[i], t[i]
		if a >= 'A' && a <= 'Z' {
			a += 32
		}
		if b >= 'A' && b <= 'Z' {
			b += 32
		}
		if a != b {
			return false
		}
	}
	return true
}

// --- Sorting ---

// Sort sorts a string slice in place using insertion sort.
// Insertion sort is structural: each element finds its position
// by comparing with its predecessors. O(n^2) but no external deps.
func Sort(s []string) {
	for i := 1; i < len(s); i++ {
		key := s[i]
		j := i - 1
		for j >= 0 && s[j] > key {
			s[j+1] = s[j]
			j--
		}
		s[j+1] = key
	}
}

// --- Number formatting ---

// Itoa converts an integer to its decimal string representation.
func Itoa(n int) string {
	if n == 0 {
		return "0"
	}
	neg := false
	if n < 0 {
		neg = true
		n = -n
	}
	// Max int64 is 19 digits.
	var buf [20]byte
	pos := len(buf)
	for n > 0 {
		pos--
		buf[pos] = byte('0' + n%10)
		n /= 10
	}
	if neg {
		pos--
		buf[pos] = '-'
	}
	return string(buf[pos:])
}

// ParseInt parses a decimal or hex integer string.
func ParseInt(s string) (int, bool) {
	s = TrimSpace(s)
	if len(s) == 0 {
		return 0, false
	}

	// Hex: 0x...
	if len(s) > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X') {
		n := 0
		for i := 2; i < len(s); i++ {
			c := s[i]
			var digit int
			if c >= '0' && c <= '9' {
				digit = int(c - '0')
			} else if c >= 'a' && c <= 'f' {
				digit = int(c-'a') + 10
			} else if c >= 'A' && c <= 'F' {
				digit = int(c-'A') + 10
			} else {
				return 0, false
			}
			n = n*16 + digit
		}
		return n, true
	}

	neg := false
	start := 0
	if s[0] == '-' {
		neg = true
		start = 1
	} else if s[0] == '+' {
		start = 1
	}

	n := 0
	for i := start; i < len(s); i++ {
		c := s[i]
		if c < '0' || c > '9' {
			return 0, false
		}
		n = n*10 + int(c-'0')
	}
	if neg {
		n = -n
	}
	return n, true
}

// LastIndex returns the index of the last occurrence of sub in s, or -1.
func LastIndex(s, sub string) int {
	if len(sub) == 0 {
		return len(s)
	}
	last := -1
	for i := 0; i <= len(s)-len(sub); i++ {
		if s[i:i+len(sub)] == sub {
			last = i
		}
	}
	return last
}

// Count returns the number of non-overlapping occurrences of sub in s.
func Count(s, sub string) int {
	if len(sub) == 0 {
		return len(s) + 1
	}
	n := 0
	for {
		i := Index(s, sub)
		if i < 0 {
			break
		}
		n++
		s = s[i+len(sub):]
	}
	return n
}

// Replace applies a list of old->new replacements to s.
func Replace(s string, pairs ...string) string {
	for i := 0; i+1 < len(pairs); i += 2 {
		s = ReplaceAll(s, pairs[i], pairs[i+1])
	}
	return s
}

// --- Error construction ---

// Err creates an error from string parts concatenated together.
func Err(parts ...string) error {
	n := 0
	for _, p := range parts {
		n += len(p)
	}
	buf := make([]byte, 0, n)
	for _, p := range parts {
		buf = append(buf, p...)
	}
	return errors.New(string(buf))
}

// --- Helpers ---

func isSpace(c byte) bool {
	return c == ' ' || c == '\t' || c == '\n' || c == '\r'
}

// Builder is a minimal string builder (avoids importing strings.Builder).
type Builder struct {
	buf []byte
}

func (b *Builder) WriteString(s string) {
	b.buf = append(b.buf, s...)
}

func (b *Builder) WriteByte(c byte) {
	b.buf = append(b.buf, c)
}

func (b *Builder) String() string {
	return string(b.buf)
}

func (b *Builder) Len() int {
	return len(b.buf)
}

func (b *Builder) Reset() {
	b.buf = b.buf[:0]
}
