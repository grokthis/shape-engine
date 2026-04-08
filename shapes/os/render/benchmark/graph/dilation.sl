shape os.render.benchmark.graph.dilation : os.render.benchmark.section.dilation {
  type: graph
  layer: 4
  graph_type: log-linear
  x_axis: "Stack Depth"
  y_axis: "Wall Time (log scale)"
  x_range: "0,10"
  y_range: "1ns,1e30ns"
  """
series "Gauss sum (constant)" {
  color: green
  style: solid
  data: 0:10.7, 1:10.7, 2:10.7, 3:10.7, 4:10.7, 5:10.7, 6:10.7, 7:10.7, 8:10.7, 9:10.7, 10:10.7
}

series "shape edit (265^n)" {
  color: orange
  style: solid
  data: 0:191, 1:191, 2:50615, 3:13413000, 4:3554000000, 5:941800000000, 6:249600000000000, 7:66140000000000000, 8:17530000000000000000, 9:4645000000000000000000, 10:1.23e24
}

annotation "heat death" {
  y: 4.3e26
  style: dashed
  color: red
}

fill_between: "Gauss sum (constant)", "shape edit (265^n)"
fill_color: orange
fill_opacity: 0.05
  """
}
