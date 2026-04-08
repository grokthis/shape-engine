// shape.h — C shape engine. The thinnest possible shim.
//
// No malloc in the hot path. Arena allocation only.
// No string comparison for scope. Register file indexed by number.
// No GC. No runtime. Just structure.
#ifndef SHAPE_H
#define SHAPE_H

#include <stdint.h>
#include <stddef.h>
#include <string.h>

// ============================================================
// Arena allocator. All runtime values live here.
// Reset is O(1). Zero GC.
// ============================================================

typedef struct {
    char *buf;
    size_t cap;
    size_t used;
} Arena;

static inline void arena_init(Arena *a, char *buf, size_t cap) {
    a->buf = buf;
    a->cap = cap;
    a->used = 0;
}

static inline void *arena_alloc(Arena *a, size_t size) {
    // Align to 8 bytes.
    size = (size + 7) & ~7;
    if (a->used + size > a->cap) return NULL;
    void *ptr = a->buf + a->used;
    a->used += size;
    return ptr;
}

static inline void arena_reset(Arena *a) {
    a->used = 0;
}

// ============================================================
// String interning. Pointer comparison instead of strcmp.
// ============================================================

#define INTERN_CAP 4096

typedef struct {
    const char *strings[INTERN_CAP];
    int count;
} InternTable;

static inline const char *intern(InternTable *t, const char *s) {
    // Check existing.
    for (int i = 0; i < t->count; i++) {
        if (strcmp(t->strings[i], s) == 0) return t->strings[i];
    }
    // Add new (in a real impl, would copy to arena).
    if (t->count < INTERN_CAP) {
        t->strings[t->count] = s;
        return t->strings[t->count++];
    }
    return s;
}

// ============================================================
// Value. Tagged union. 16 bytes total.
// ============================================================

enum ValueKind {
    VAL_NIL = 0,
    VAL_INT,
    VAL_FLOAT,
    VAL_BOOL,
    VAL_STR,
    VAL_LIST,
};

typedef struct Value {
    uint8_t kind;
    union {
        int64_t i;
        double f;
        int b;
        const char *s;
        struct { struct Value *items; int len; } list;
    };
} Value;

static inline Value val_int(int64_t n) { Value v; v.kind = VAL_INT; v.i = n; return v; }
static inline Value val_nil(void)      { Value v; v.kind = VAL_NIL; v.i = 0; return v; }
static inline Value val_bool(int b)    { Value v; v.kind = VAL_BOOL; v.b = b; return v; }
static inline Value val_str(const char *s) { Value v; v.kind = VAL_STR; v.s = s; return v; }

// ============================================================
// Shape. The primitive.
// ============================================================

#define MAX_DEPS 8
#define MAX_DIMS 16

typedef struct {
    const char *key;
    const char *val;
} Dim;

typedef struct {
    const char *id;
    const char *content;
    Dim dims[MAX_DIMS];
    int ndims;
    const char *deps[MAX_DEPS];
    int ndeps;
    int layer;
    uint64_t tick;
} Shape;

// ============================================================
// Engine. Shape graph + tick.
// ============================================================

#define ENGINE_CAP 4096

typedef struct {
    Shape shapes[ENGINE_CAP];
    int count;
    uint64_t tick;

    // Children index: for each prefix, child segments.
    // Simple hash map: hash(prefix) -> list of children.
    // For benchmarking, we use linear scan (same as shapes).
} Engine;

static inline void engine_init(Engine *e) {
    e->count = 0;
    e->tick = 0;
}

static inline Shape *engine_add(Engine *e, const char *id) {
    if (e->count >= ENGINE_CAP) return NULL;
    Shape *s = &e->shapes[e->count++];
    memset(s, 0, sizeof(Shape));
    s->id = id;
    return s;
}

static inline Shape *engine_get(Engine *e, const char *id) {
    for (int i = 0; i < e->count; i++) {
        if (e->shapes[i].id == id) return &e->shapes[i]; // Interned: pointer compare.
    }
    // Fallback: string compare.
    for (int i = 0; i < e->count; i++) {
        if (strcmp(e->shapes[i].id, id) == 0) return &e->shapes[i];
    }
    return NULL;
}

static inline void engine_edit(Engine *e, const char *id, const char *content) {
    Shape *s = engine_get(e, id);
    if (!s) return;
    e->tick++;
    s->content = content;
    s->tick = e->tick;
    // Propagation would go here. For benchmarks, edit alone.
}

// ============================================================
// Register file. Scope as flat array. O(1) access.
// ============================================================

#define REG_CAP 64

typedef struct {
    const char *names[REG_CAP]; // Interned name for each register.
    Value regs[REG_CAP];        // Value in each register.
    int count;
} Registers;

static inline void regs_init(Registers *r) {
    r->count = 0;
}

static inline int regs_bind(Registers *r, const char *name) {
    // Check if already bound.
    for (int i = 0; i < r->count; i++) {
        if (r->names[i] == name) return i;
    }
    if (r->count >= REG_CAP) return -1;
    int idx = r->count++;
    r->names[idx] = name;
    r->regs[idx] = val_nil();
    return idx;
}

static inline Value regs_get(Registers *r, int idx) {
    if (idx < 0 || idx >= r->count) return val_nil();
    return r->regs[idx];
}

static inline void regs_set(Registers *r, int idx, Value v) {
    if (idx >= 0 && idx < r->count) r->regs[idx] = v;
}

static inline int regs_find(Registers *r, const char *name) {
    for (int i = 0; i < r->count; i++) {
        if (r->names[i] == name) return i;
    }
    return -1;
}

// ============================================================
// Evaluator. Runs shape-lang on the engine.
// For benchmarks: hardcoded patterns, not a full parser.
// ============================================================

// eval_loop_accum: the tight accumulator pattern.
// for i in range(n) { set acc = acc + i }
// Returns the final accumulator value.
static inline int64_t eval_loop_accum_add(int64_t start, int64_t end, int64_t init) {
    int64_t acc = init;
    for (int64_t i = start; i < end; i++) {
        acc += i;
    }
    return acc;
}

// eval_loop_accum_const: for i in range(n) { set acc = acc + c }
static inline int64_t eval_loop_accum_const(int64_t start, int64_t end, int64_t init, int64_t c) {
    int64_t acc = init;
    for (int64_t i = start; i < end; i++) {
        acc += c;
    }
    return acc;
}

// eval_nested_accum: for i in range(n) { for j in range(m) { set acc = acc + 1 } }
static inline int64_t eval_nested_accum(int64_t n, int64_t m, int64_t init) {
    int64_t acc = init;
    for (int64_t i = 0; i < n; i++) {
        for (int64_t j = 0; j < m; j++) {
            acc++;
        }
    }
    return acc;
}

#endif // SHAPE_H
