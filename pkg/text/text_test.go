package text

import "testing"

func TestContains(t *testing.T) {
	if !Contains("hello world", "world") { t.Error("contains: found") }
	if Contains("hello", "xyz") { t.Error("contains: not found") }
	if !Contains("abc", "") { t.Error("contains: empty sub") }
	if !Contains("", "") { t.Error("contains: both empty") }
}

func TestHasPrefixSuffix(t *testing.T) {
	if !HasPrefix("hello", "hel") { t.Error("prefix: match") }
	if HasPrefix("hello", "xyz") { t.Error("prefix: no match") }
	if !HasSuffix("hello", "llo") { t.Error("suffix: match") }
	if HasSuffix("hello", "xyz") { t.Error("suffix: no match") }
}

func TestIndex(t *testing.T) {
	if Index("hello", "ll") != 2 { t.Error("index: found") }
	if Index("hello", "xyz") != -1 { t.Error("index: not found") }
	if Index("hello", "") != 0 { t.Error("index: empty") }
}

func TestSplit(t *testing.T) {
	parts := Split("a,b,c", ",")
	if len(parts) != 3 { t.Errorf("split: %d parts", len(parts)) }
	if parts[0] != "a" || parts[2] != "c" { t.Error("split: values") }

	single := Split("nosep", ",")
	if len(single) != 1 || single[0] != "nosep" { t.Error("split: no sep") }
}

func TestJoin(t *testing.T) {
	if Join([]string{"a", "b", "c"}, "-") != "a-b-c" { t.Error("join") }
	if Join(nil, ",") != "" { t.Error("join: nil") }
	if Join([]string{"x"}, ",") != "x" { t.Error("join: single") }
}

func TestTrimSpace(t *testing.T) {
	if TrimSpace("  hi  ") != "hi" { t.Error("trim") }
	if TrimSpace("hi") != "hi" { t.Error("trim: no space") }
	if TrimSpace("") != "" { t.Error("trim: empty") }
}

func TestReplaceAll(t *testing.T) {
	if ReplaceAll("aabbcc", "bb", "XX") != "aaXXcc" { t.Error("replace") }
	if ReplaceAll("aaa", "a", "b") != "bbb" { t.Error("replace: all") }
	if ReplaceAll("hello", "xyz", "!") != "hello" { t.Error("replace: no match") }
}

func TestToUpperLower(t *testing.T) {
	if ToUpper("hello") != "HELLO" { t.Error("upper") }
	if ToLower("HELLO") != "hello" { t.Error("lower") }
	if ToUpper("") != "" { t.Error("upper: empty") }
}

func TestRepeat(t *testing.T) {
	if Repeat("ab", 3) != "ababab" { t.Error("repeat") }
	if Repeat("x", 0) != "" { t.Error("repeat: 0") }
}

func TestEqualFold(t *testing.T) {
	if !EqualFold("Hello", "hello") { t.Error("fold: match") }
	if EqualFold("abc", "xyz") { t.Error("fold: no match") }
}

func TestSort(t *testing.T) {
	s := []string{"c", "a", "b"}
	Sort(s)
	if s[0] != "a" || s[1] != "b" || s[2] != "c" { t.Error("sort") }
}

func TestItoa(t *testing.T) {
	if Itoa(42) != "42" { t.Error("itoa: 42") }
	if Itoa(0) != "0" { t.Error("itoa: 0") }
	if Itoa(-5) != "-5" { t.Error("itoa: -5") }
}

func TestParseInt(t *testing.T) {
	n, ok := ParseInt("42")
	if !ok || n != 42 { t.Error("parseInt: 42") }

	n, ok = ParseInt("0xFF")
	if !ok || n != 255 { t.Error("parseInt: hex") }

	n, ok = ParseInt("-10")
	if !ok || n != -10 { t.Error("parseInt: neg") }

	_, ok = ParseInt("abc")
	if ok { t.Error("parseInt: should fail") }
}

func TestBuilder(t *testing.T) {
	var b Builder
	b.WriteString("hello")
	b.WriteByte(' ')
	b.WriteString("world")
	if b.String() != "hello world" { t.Error("builder") }
	if b.Len() != 11 { t.Error("builder: len") }
}
