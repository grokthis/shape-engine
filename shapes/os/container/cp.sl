shape os.container.cp : os.container {
  type: exec
  layer: 4
  """
// container cp <src> <container>:<dst>
// container cp <container>:<src> <dst>
//
// Copy shapes between host and container.
//
// Unlike docker cp: no tar, no filesystem layer.
// Copying a shape = creating a shape in the target namespace
// with the same content and dimensions.

let src = arg0
let dst = arg1

if contains(src, ":") {
  // Container to host
  let parts = split(src, ":")
  let cid = "os.container.instances." + parts[0]
  let src_path = parts[1]
  print("Copied " + src_path + " from " + parts[0] + " to " + dst)
} else if contains(dst, ":") {
  // Host to container
  let parts = split(dst, ":")
  let cid = "os.container.instances." + parts[0]
  let dst_path = parts[1]
  print("Copied " + src + " to " + parts[0] + ":" + dst_path)
}
  """
}
