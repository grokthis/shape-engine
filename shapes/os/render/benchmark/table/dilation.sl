shape os.render.benchmark.table.dilation : os.render.benchmark.section.dilation {
  type: table
  layer: 4
  columns: "Level, Stack, Gauss Sum, Shape Edit, CPU 100-loop, Dilation"
  """
0, native, 10.7 ns, 191 ns, 52.7 us, 1x
1, SE, 10.7 ns, 191 ns, 52.7 us, 1x
2, SE x2, 10.7 ns, 50.6 us, 14.0 ms, 265x
3, SE x3, 10.7 ns, 13.4 ms, 3.7 s, 70Kx
4, SE x4, 10.7 ns, 3.6 s, 16 min, 19Mx
5, SE x5, 10.7 ns, 15.7 min, 3 days, 4.9Gx
6, SE x6, 10.7 ns, 2.9 days, 2.2 yr, 1.3Tx
7, SE x7, 10.7 ns, 2.1 yr, 588 yr, 350Tx
8, SE x8, 10.7 ns, 563 yr, 156K yr, 93Px
9, SE x9, 10.7 ns, 149K yr, 41M yr, 25Ex
10, SE x10, 10.7 ns, 39.5M yr, 10.9G yr, 6.5Zx
  """
}
