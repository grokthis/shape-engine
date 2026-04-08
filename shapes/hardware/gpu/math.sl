// GPU math: vectors, matrices, transforms.
//
// A vec3 IS three numbers connected. A mat4 IS sixteen numbers in a grid.
// Transform IS matrix multiply. Projection IS perspective divide.
// All of these are structural: the shape of the data IS the operation.

shape hardware.gpu.math : hardware.gpu {
  type: lib
  layer: 2
  """
// Vector operations.
// Vectors are stored as comma-separated strings in shape content.
// vec3: "x,y,z"  vec4: "x,y,z,w"
//
// This is the structural representation: the vector IS its components.
// On hardware, each component is a shape-gate. The vector is 3 gates connected.

// vec3_new(x, y, z) -> "x,y,z"
// vec3_x/y/z(v) -> component
// vec3_add(a, b) -> component-wise add
// vec3_sub(a, b) -> component-wise subtract
// vec3_mul(a, s) -> scalar multiply
// vec3_dot(a, b) -> dot product
// vec3_cross(a, b) -> cross product
// vec3_normalize(v) -> unit vector
// vec3_length(v) -> magnitude
"""
}

shape hardware.gpu.math.vec3 : hardware.gpu.math {
  type: exec
  layer: 2
  """
// Create vec3 from components.
fn vec3_new(x, y, z) {
  to_string(x) + "," + to_string(y) + "," + to_string(z)
}

fn vec3_x(v) {
  let parts = split(v, ",")
  to_int(index(parts, 0))
}

fn vec3_y(v) {
  let parts = split(v, ",")
  to_int(index(parts, 1))
}

fn vec3_z(v) {
  let parts = split(v, ",")
  to_int(index(parts, 2))
}

fn vec3_add(a, b) {
  let ap = split(a, ",")
  let bp = split(b, ",")
  let x = to_int(index(ap, 0)) + to_int(index(bp, 0))
  let y = to_int(index(ap, 1)) + to_int(index(bp, 1))
  let z = to_int(index(ap, 2)) + to_int(index(bp, 2))
  to_string(x) + "," + to_string(y) + "," + to_string(z)
}

fn vec3_sub(a, b) {
  let ap = split(a, ",")
  let bp = split(b, ",")
  let x = to_int(index(ap, 0)) - to_int(index(bp, 0))
  let y = to_int(index(ap, 1)) - to_int(index(bp, 1))
  let z = to_int(index(ap, 2)) - to_int(index(bp, 2))
  to_string(x) + "," + to_string(y) + "," + to_string(z)
}

fn vec3_scale(v, s) {
  let p = split(v, ",")
  let x = to_int(index(p, 0)) * s
  let y = to_int(index(p, 1)) * s
  let z = to_int(index(p, 2)) * s
  to_string(x) + "," + to_string(y) + "," + to_string(z)
}

fn vec3_dot(a, b) {
  let ap = split(a, ",")
  let bp = split(b, ",")
  to_int(index(ap, 0)) * to_int(index(bp, 0)) + to_int(index(ap, 1)) * to_int(index(bp, 1)) + to_int(index(ap, 2)) * to_int(index(bp, 2))
}

fn vec3_cross(a, b) {
  let ap = split(a, ",")
  let bp = split(b, ",")
  let ax = to_int(index(ap, 0))
  let ay = to_int(index(ap, 1))
  let az = to_int(index(ap, 2))
  let bx = to_int(index(bp, 0))
  let by = to_int(index(bp, 1))
  let bz = to_int(index(bp, 2))
  to_string(ay * bz - az * by) + "," + to_string(az * bx - ax * bz) + "," + to_string(ax * by - ay * bx)
}
"""
}

shape hardware.gpu.math.mat4 : hardware.gpu.math {
  type: exec
  layer: 2
  """
// 4x4 matrix as 16 comma-separated values (row-major).
// mat4: "m00,m01,m02,m03,m10,m11,m12,m13,m20,m21,m22,m23,m30,m31,m32,m33"
//
// Identity: "1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1"
//
// Matrix multiply IS the structural composition of two transforms.
// On hardware: 64 multiply-accumulate gates in a grid.

fn mat4_identity() {
  "1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1"
}

fn mat4_get(m, row, col) {
  let parts = split(m, ",")
  to_int(index(parts, row * 4 + col))
}

fn mat4_translate(tx, ty, tz) {
  "1,0,0," + to_string(tx) + ",0,1,0," + to_string(ty) + ",0,0,1," + to_string(tz) + ",0,0,0,1"
}

fn mat4_scale(sx, sy, sz) {
  to_string(sx) + ",0,0,0,0," + to_string(sy) + ",0,0,0,0," + to_string(sz) + ",0,0,0,0,1"
}

// mat4_mul: multiply two 4x4 matrices.
// This IS the structural composition. Two transforms become one.
fn mat4_mul(a, b) {
  let ap = split(a, ",")
  let bp = split(b, ",")
  let r = ""
  for row in range(4) {
    for col in range(4) {
      let sum = 0
      for k in range(4) {
        set sum = sum + to_int(index(ap, row * 4 + k)) * to_int(index(bp, k * 4 + col))
      }
      if r != "" { set r = r + "," }
      set r = r + to_string(sum)
    }
  }
  r
}

// Transform a vec3 by mat4 (assumes w=1, returns vec3).
fn mat4_transform(m, v) {
  let mp = split(m, ",")
  let vp = split(v, ",")
  let vx = to_int(index(vp, 0))
  let vy = to_int(index(vp, 1))
  let vz = to_int(index(vp, 2))
  let rx = to_int(index(mp, 0)) * vx + to_int(index(mp, 1)) * vy + to_int(index(mp, 2)) * vz + to_int(index(mp, 3))
  let ry = to_int(index(mp, 4)) * vx + to_int(index(mp, 5)) * vy + to_int(index(mp, 6)) * vz + to_int(index(mp, 7))
  let rz = to_int(index(mp, 8)) * vx + to_int(index(mp, 9)) * vy + to_int(index(mp, 10)) * vz + to_int(index(mp, 11))
  to_string(rx) + "," + to_string(ry) + "," + to_string(rz)
}
"""
}
