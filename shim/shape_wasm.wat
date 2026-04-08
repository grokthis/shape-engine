;; shape_wasm.wat — Shape engine in WebAssembly (text format).
;;
;; WASM: stack machine, 32/64-bit, structured control flow.
;; Runs in every browser and WASI runtime. The universal substrate.
;;
;; Same operations as ARM64/RISC-V/x86 shims:
;;   loop_accum_add, loop_accum_const, nested_accum, pow, add, mul, div
;;   vec_accum (SIMD 128-bit, 2x i64 per operation)
;;   vec_propagate (SIMD tick stamping)

(module
  ;; ============================================================
  ;; asm_loop_accum_add(start, end, init) -> sum
  ;; for i in [start, end) { acc += i }
  ;; ============================================================
  (func (export "asm_loop_accum_add")
    (param $start i64) (param $end i64) (param $init i64) (result i64)
    (local $i i64) (local $acc i64)
    (local.set $i (local.get $start))
    (local.set $acc (local.get $init))
    (block $done
      (loop $loop
        (br_if $done (i64.ge_s (local.get $i) (local.get $end)))
        (local.set $acc (i64.add (local.get $acc) (local.get $i)))
        (local.set $i (i64.add (local.get $i) (i64.const 1)))
        (br $loop)
      )
    )
    (local.get $acc)
  )

  ;; ============================================================
  ;; asm_loop_accum_const(start, end, init, c) -> sum
  ;; Structural shortcut: init + c * (end - start)
  ;; ============================================================
  (func (export "asm_loop_accum_const")
    (param $start i64) (param $end i64) (param $init i64) (param $c i64) (result i64)
    (i64.add
      (local.get $init)
      (i64.mul
        (local.get $c)
        (i64.sub (local.get $end) (local.get $start))
      )
    )
  )

  ;; ============================================================
  ;; asm_nested_accum(n, m, init) -> init + n * m
  ;; ============================================================
  (func (export "asm_nested_accum")
    (param $n i64) (param $m i64) (param $init i64) (result i64)
    (i64.add
      (local.get $init)
      (i64.mul (local.get $n) (local.get $m))
    )
  )

  ;; ============================================================
  ;; asm_pow(base, exp) -> result
  ;; Repeated squaring.
  ;; ============================================================
  (func (export "asm_pow")
    (param $base i64) (param $exp i64) (result i64)
    (local $result i64)
    (local.set $result (i64.const 1))
    (block $done
      (loop $loop
        (br_if $done (i64.eqz (local.get $exp)))
        (if (i64.and (local.get $exp) (i64.const 1))
          (then
            (local.set $result (i64.mul (local.get $result) (local.get $base)))
          )
        )
        (local.set $base (i64.mul (local.get $base) (local.get $base)))
        (local.set $exp (i64.shr_u (local.get $exp) (i64.const 1)))
        (br $loop)
      )
    )
    (local.get $result)
  )

  ;; ============================================================
  ;; Primitives
  ;; ============================================================
  (func (export "asm_add") (param i64) (param i64) (result i64)
    (i64.add (local.get 0) (local.get 1))
  )

  (func (export "asm_mul") (param i64) (param i64) (result i64)
    (i64.mul (local.get 0) (local.get 1))
  )

  (func (export "asm_div") (param i64) (param i64) (result i64)
    (i64.div_s (local.get 0) (local.get 1))
  )

  ;; ============================================================
  ;; Memory for vec operations
  ;; ============================================================
  (memory (export "memory") 1)

  ;; ============================================================
  ;; asm_vec_accum(offset, len) -> sum
  ;; Sum i64 array in linear memory using SIMD (v128).
  ;; 2x i64 per SIMD operation (128-bit lanes).
  ;; offset = byte offset in memory, len = element count.
  ;; ============================================================
  (func (export "asm_vec_accum")
    (param $offset i32) (param $len i32) (result i64)
    (local $acc_lo i64) (local $acc_hi i64)
    (local $pairs i32) (local $i i32) (local $v v128)
    (local.set $acc_lo (i64.const 0))
    (local.set $acc_hi (i64.const 0))
    (local.set $pairs (i32.shr_u (local.get $len) (i32.const 1)))
    (local.set $i (i32.const 0))
    ;; Process pairs
    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $pairs)))
        (local.set $v (v128.load
          (i32.add (local.get $offset) (i32.mul (local.get $i) (i32.const 16)))
        ))
        (local.set $acc_lo (i64.add (local.get $acc_lo)
          (i64x2.extract_lane 0 (local.get $v))))
        (local.set $acc_hi (i64.add (local.get $acc_hi)
          (i64x2.extract_lane 1 (local.get $v))))
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $loop)
      )
    )
    ;; Reduce
    (local.set $acc_lo (i64.add (local.get $acc_lo) (local.get $acc_hi)))
    ;; Handle odd element
    (if (i32.and (local.get $len) (i32.const 1))
      (then
        (local.set $acc_lo (i64.add (local.get $acc_lo)
          (i64.load (i32.add (local.get $offset)
            (i32.mul (i32.sub (local.get $len) (i32.const 1)) (i32.const 8))
          ))
        ))
      )
    )
    (local.get $acc_lo)
  )

  ;; ============================================================
  ;; asm_vec_propagate(offset, new_tick, count) -> updated
  ;; Stamp dependents: if tick < new_tick, set to new_tick.
  ;; 2 deps per SIMD cycle.
  ;; ============================================================
  (func (export "asm_vec_propagate")
    (param $offset i32) (param $new_tick i64) (param $count i32) (result i32)
    (local $updated i32) (local $i i32) (local $addr i32) (local $old i64)
    (local.set $updated (i32.const 0))
    (local.set $i (i32.const 0))
    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $count)))
        (local.set $addr (i32.add (local.get $offset)
          (i32.mul (local.get $i) (i32.const 8))))
        (local.set $old (i64.load (local.get $addr)))
        (if (i64.lt_s (local.get $old) (local.get $new_tick))
          (then
            (i64.store (local.get $addr) (local.get $new_tick))
            (local.set $updated (i32.add (local.get $updated) (i32.const 1)))
          )
        )
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $loop)
      )
    )
    (local.get $updated)
  )

  ;; ============================================================
  ;; asm_vec_validate(offset, count) -> violations
  ;; Count zero entries (dangling references).
  ;; ============================================================
  (func (export "asm_vec_validate")
    (param $offset i32) (param $count i32) (result i32)
    (local $violations i32) (local $i i32) (local $addr i32)
    (local.set $violations (i32.const 0))
    (local.set $i (i32.const 0))
    (block $done
      (loop $loop
        (br_if $done (i32.ge_u (local.get $i) (local.get $count)))
        (local.set $addr (i32.add (local.get $offset)
          (i32.mul (local.get $i) (i32.const 8))))
        (if (i64.eqz (i64.load (local.get $addr)))
          (then
            (local.set $violations (i32.add (local.get $violations) (i32.const 1)))
          )
        )
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $loop)
      )
    )
    (local.get $violations)
  )
)
