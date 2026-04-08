#!/usr/bin/env ruby
# frozen_string_literal: true
#
# bench.rb — Shape engine in Ruby, built from the fastest structure.
#
# Ruby's structural primitives:
#   - Fixnum: immediate integer, no allocation (stored in pointer tag)
#   - Frozen method: JIT-friendly, no deopt
#   - Hash with symbol keys: faster than string keys
#
# The shape engine IS integer arithmetic. No objects created in the hot path.
#
# Run: ruby bench.rb

# ============================================================
# Shape evaluation: pattern -> formula. No iteration.
# Each method IS the closed-form solution.
# ============================================================

def gauss(n); n * (n - 1) / 2; end
def gauss_range(s, e); (e - s) * (s + e - 1) / 2; end
def accum_const(n, c); n * c; end
def nested(n, m); n * m; end

# Power by squaring. O(log n).
def fast_pow(base, exp)
  r = 1
  while exp > 0
    r *= base if exp.odd?
    base *= base
    exp >>= 1
  end
  r
end

# ============================================================
# Full eval: parse AST tag, dispatch to formula.
# AST nodes are arrays (fastest Ruby structure for small tuples).
#
# Tags (integers, not symbols, not strings):
#   1=let, 2=set, 3=for, 20=int, 24=ident, 25=binop, 27=call
#
# Node layout: [tag, ...fields]
#   let:   [1, name, expr_node]
#   for:   [3, var_name, iter_node, body_nodes]
#   set:   [2, name, expr_node]
#   int:   [20, value]
#   ident: [24, name]
#   binop: [25, op, left, right]
#   call:  [27, fn_name, args]
# ============================================================

T_LET = 1; T_SET = 2; T_FOR = 3; T_INT = 20; T_IDENT = 24; T_BINOP = 25; T_CALL = 27

def eval_fast(stmts)
  return nil unless stmts.length == 2
  s0, s1 = stmts[0], stmts[1]
  return nil unless s0[0] == T_LET && s1[0] == T_FOR
  return nil unless s0[2][0] == T_INT  # let expr is int

  init = s0[2][1]                       # init value
  iter = s1[2]                          # iter node (call to range)
  body = s1[3]                          # body nodes
  return nil unless iter[0] == T_CALL   # must be range()
  return nil unless body.length == 1
  set_node = body[0]
  return nil unless set_node[0] == T_SET && set_node[1] == s0[1] # set ACC = ...

  expr = set_node[2]
  return nil unless expr[0] == T_BINOP && expr[2][0] == T_IDENT && expr[2][1] == s0[1] # ACC op ...

  op = expr[1]
  args = iter[2]

  # Range bounds.
  if args.length == 1 && args[0][0] == T_INT
    start_v, end_v = 0, args[0][1]
  elsif args.length >= 2 && args[0][0] == T_INT && args[1][0] == T_INT
    start_v, end_v = args[0][1], args[1][1]
  else
    return nil
  end
  count = end_v - start_v

  rhs = expr[3]
  # Counter accumulator: Gauss sum.
  if rhs[0] == T_IDENT && rhs[1] == s1[1] # rhs is loop variable
    sum = count * (start_v + end_v - 1) / 2
    return init + sum if op == :+
    return init - sum if op == :-
  end
  # Constant accumulator: multiply.
  if rhs[0] == T_INT
    c = rhs[1]
    return init + count * c if op == :+
    return init - count * c if op == :-
  end
  nil
end

# Build the AST for: let s = 0; for i in range(1000) { set s = s + i }
PROG_SUM = [
  [T_LET, :s, [T_INT, 0]],
  [T_FOR, :i, [T_CALL, :range, [[T_INT, 1000]]],
    [[T_SET, :s, [T_BINOP, :+, [T_IDENT, :s], [T_IDENT, :i]]]]]
]

PROG_CONST = [
  [T_LET, :s, [T_INT, 0]],
  [T_FOR, :i, [T_CALL, :range, [[T_INT, 1000]]],
    [[T_SET, :s, [T_BINOP, :+, [T_IDENT, :s], [T_INT, 1]]]]]
]

# ============================================================
# Benchmark
# ============================================================

def bench(name, iters)
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
  iters.times { yield }
  t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
  ns = (t1 - t0).to_f / iters
  printf "  %-45s %8.1f ns/op\n", name, ns
  ns
end

puts "Shape Engine Ruby Benchmark"
puts "==========================="
puts

# Verify.
puts "Correctness:"
puts "  eval_fast(PROG_SUM)   = #{eval_fast(PROG_SUM)} (expect 499500)"
puts "  eval_fast(PROG_CONST) = #{eval_fast(PROG_CONST)} (expect 1000)"
puts "  gauss(1000)           = #{gauss(1000)} (expect 499500)"
puts "  nested(10,10)         = #{nested(10,10)} (expect 100)"
puts "  fast_pow(2,20)        = #{fast_pow(2,20)} (expect 1048576)"
puts

puts "--- Ruby Native ---"
nat_loop = bench("loop 1000 (each)", 100_000) { s=0; (0...1000).each{|i| s+=i}; s }
nat_nested = bench("nested 10x10 (times)", 500_000) { s=0; 10.times{10.times{s+=1}}; s }
nat_pow = bench("pow 2^20 (loop)", 500_000) { r=1; 20.times{r*=2}; r }

puts
puts "--- Ruby Shape Engine (direct formula) ---"
shp_gauss = bench("gauss(1000)", 10_000_000) { gauss(1000) }
shp_nested = bench("nested(10,10)", 10_000_000) { nested(10,10) }
shp_pow = bench("fast_pow(2,20)", 2_000_000) { fast_pow(2,20) }

puts
puts "--- Ruby Shape Engine (full eval with AST) ---"
shp_eval_sum = bench("eval_fast(PROG_SUM)", 5_000_000) { eval_fast(PROG_SUM) }
shp_eval_const = bench("eval_fast(PROG_CONST)", 5_000_000) { eval_fast(PROG_CONST) }

puts
puts "--- Speedup ---"
printf "  loop 1000 (formula):    %6.1fx faster than Ruby native\n", nat_loop / shp_gauss
printf "  loop 1000 (full eval):  %6.1fx faster than Ruby native\n", nat_loop / shp_eval_sum
printf "  nested 10x10:           %6.1fx faster than Ruby native\n", nat_nested / shp_nested
