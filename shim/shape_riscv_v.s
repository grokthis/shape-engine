# shape_riscv_v.s — Shape engine in RISC-V RV64GV (V extension: vector).
#
# The V extension adds scalable vector operations. Vector length is
# hardware-defined (VLEN), not fixed. The same code runs on any
# vector width. This is structural: the operation IS the structure,
# the width IS the character.
#
# For the shape engine, vectors matter for wave propagation:
# when a shape changes and has N dependents, all N can be checked
# in parallel using vector operations.

.global asm_vec_accum_add
.global asm_vec_propagate
.global asm_vec_validate

.text
.align 2

# ============================================================
# asm_vec_accum_add(array, len) -> sum
# Vector reduction: sum all elements.
# a0 = pointer to int64 array, a1 = length
# Returns: a0 = sum
#
# The loop processes VLEN elements per iteration.
# On a 256-bit VLEN: 4 int64s per cycle.
# On a 1024-bit VLEN: 16 int64s per cycle.
# Same code, different hardware, different throughput.
# ============================================================
asm_vec_accum_add:
    li      t0, 0               # accumulator
    mv      t1, a1              # remaining count
.Lvec_sum:
    vsetvli t2, t1, e64, m1     # set vector length (64-bit elements)
    vle64.v v1, (a0)            # load vector
    vredsum.vs v2, v1, v0       # reduce: sum elements into v2[0]
    vmv.x.s t3, v2              # extract scalar
    add     t0, t0, t3          # accumulate
    slli    t4, t2, 3           # bytes processed = vl * 8
    add     a0, a0, t4          # advance pointer
    sub     t1, t1, t2          # remaining -= vl
    bnez    t1, .Lvec_sum
    mv      a0, t0
    ret

# ============================================================
# asm_vec_propagate(dep_ticks, new_tick, count) -> updated_count
# Vector wave propagation: stamp all dependents whose tick < new_tick.
# a0 = pointer to dependent tick array (uint64)
# a1 = new tick value
# a2 = count of dependents
# Returns: a0 = number of dependents updated
#
# This is the inner loop of the shape engine's Edit operation.
# For each dependent: if dep.tick < new_tick, set dep.tick = new_tick.
# Vector: process VLEN dependents per cycle.
# ============================================================
asm_vec_propagate:
    li      t0, 0               # updated count
    mv      t1, a2              # remaining
.Lvec_prop:
    vsetvli t2, t1, e64, m1
    vle64.v v1, (a0)            # load tick values
    vmv.v.x v2, a1              # broadcast new_tick
    vmslt.vv v0, v1, v2         # mask: which deps have tick < new_tick
    vse64.v v2, (a0), v0.t      # store new_tick where mask is set
    vcpop.m t3, v0              # count set bits in mask
    add     t0, t0, t3          # accumulate updated count
    slli    t4, t2, 3
    add     a0, a0, t4
    sub     t1, t1, t2
    bnez    t1, .Lvec_prop
    mv      a0, t0
    ret

# ============================================================
# asm_vec_validate(dep_ids, shape_exists_bitmap, count) -> violations
# Vector coherence check: verify all deps exist.
# a0 = pointer to dep ID array (uint64 indices)
# a1 = pointer to existence bitmap
# a2 = count
# Returns: a0 = number of dangling references (Law 1 violations)
#
# For each dep ID: check if the bit is set in the existence bitmap.
# If not set: dangling reference. Count violations.
# ============================================================
asm_vec_validate:
    li      t0, 0               # violation count
    mv      t1, a2
.Lvec_val:
    vsetvli t2, t1, e64, m1
    vle64.v v1, (a0)            # load dep IDs
    # For each ID, compute byte index and bit position
    vsrl.vi v2, v1, 3           # byte index = id >> 3
    vand.vi v3, v1, 7           # bit position = id & 7
    # Gather bytes from bitmap
    vluxei64.v v4, (a1), v2     # gather: v4[i] = bitmap[v2[i]]
    # Create bit masks
    li      t3, 1
    vmv.v.x v5, t3
    vsll.vv v5, v5, v3          # v5[i] = 1 << bit_position
    # Test: v4 & v5 == 0 means dep doesn't exist
    vand.vv v6, v4, v5
    vmseq.vi v0, v6, 0          # mask: which deps don't exist
    vcpop.m t3, v0
    add     t0, t0, t3
    slli    t4, t2, 3
    add     a0, a0, t4
    sub     t1, t1, t2
    bnez    t1, .Lvec_val
    mv      a0, t0
    ret
