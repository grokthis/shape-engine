# shape_riscv_a.s — Shape engine in RISC-V RV64IMA (A extension: atomics).
#
# The A extension adds atomic memory operations: LR/SC (load-reserved /
# store-conditional) and AMO (atomic memory operations).
#
# For the shape engine, atomics matter for one thing: concurrent shape
# edits. Multiple cores editing the shape graph need atomic updates to
# the tick counter and shape content. This is Law 3 in hardware:
# coupled incompatible writes must resolve.

.global asm_atomic_tick_inc
.global asm_atomic_cas
.global asm_atomic_add

.text
.align 2

# ============================================================
# asm_atomic_tick_inc(tick_addr) -> old_tick
# Atomically increment the global tick counter.
# a0 = pointer to tick (uint64)
# Returns: a0 = old value (before increment)
# ============================================================
asm_atomic_tick_inc:
    li      t0, 1
    amoadd.d.aqrl a0, t0, (a0)  # atomic: old = *a0; *a0 += 1
    ret

# ============================================================
# asm_atomic_cas(addr, expected, desired) -> success (0 or 1)
# Compare-and-swap. The foundation of lock-free shape updates.
# a0 = addr, a1 = expected, a2 = desired
# Returns: a0 = 1 if swapped, 0 if not
# ============================================================
asm_atomic_cas:
.Lcas_retry:
    lr.d.aq t0, (a0)            # load-reserved
    bne     t0, a1, .Lcas_fail  # if *addr != expected, fail
    sc.d.rl t1, a2, (a0)        # store-conditional
    bnez    t1, .Lcas_retry     # if SC failed (contention), retry
    li      a0, 1               # success
    ret
.Lcas_fail:
    li      a0, 0               # failure
    ret

# ============================================================
# asm_atomic_add(addr, val) -> old
# Atomic fetch-and-add. Used for reference counting shapes.
# a0 = addr, a1 = value to add
# Returns: a0 = old value
# ============================================================
asm_atomic_add:
    amoadd.d.aqrl a0, a1, (a0)
    ret
