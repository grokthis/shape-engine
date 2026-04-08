package pool

import "testing"

func TestAllocAndGet(t *testing.T) {
	p := New[int](8)
	slot := p.Alloc()
	*slot = 42
	if *p.Get(0) != 42 {
		t.Error("expected 42")
	}
	if p.Used() != 1 {
		t.Errorf("used: %d", p.Used())
	}
}

func TestReset(t *testing.T) {
	p := New[int](8)
	for i := 0; i < 5; i++ {
		*p.Alloc() = i
	}
	if p.Used() != 5 {
		t.Error("used should be 5")
	}
	p.Reset()
	if p.Used() != 0 {
		t.Error("used should be 0 after reset")
	}
	// Reuse slots
	*p.Alloc() = 99
	if *p.Get(0) != 99 {
		t.Error("slot should be reused")
	}
}

func TestGrow(t *testing.T) {
	p := New[int](2)
	for i := 0; i < 10; i++ {
		*p.Alloc() = i
	}
	if p.Used() != 10 {
		t.Errorf("used: %d", p.Used())
	}
	for i := 0; i < 10; i++ {
		if *p.Get(i) != i {
			t.Errorf("slot %d: %d", i, *p.Get(i))
		}
	}
}

func TestAllocN(t *testing.T) {
	p := New[int](16)
	slice := p.AllocN(5)
	if len(slice) != 5 {
		t.Errorf("len: %d", len(slice))
	}
	for i := range slice {
		slice[i] = i * 10
	}
	if *p.Get(2) != 20 {
		t.Error("slot 2 should be 20")
	}
}

func BenchmarkPoolAlloc(b *testing.B) {
	p := New[int](1024)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		p.Reset()
		for j := 0; j < 1000; j++ {
			*p.Alloc() = j
		}
	}
}

func BenchmarkHeapAlloc(b *testing.B) {
	for i := 0; i < b.N; i++ {
		for j := 0; j < 1000; j++ {
			x := new(int)
			*x = j
			_ = x
		}
	}
}

func BenchmarkPoolAllocReset(b *testing.B) {
	p := New[int](1024)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		for j := 0; j < 100; j++ {
			*p.Alloc() = j
		}
		p.Reset()
	}
}
