shape os.container.volume : os.container {
  type: exec
  layer: 4
  """
// container volume <command> [args]
//
// Manage persistent volumes.
//
// A volume is a shape subtree that persists independently of
// any container. Containers mount volumes to share or persist
// data across restarts.
//
// Commands:
//   container volume create <name>
//   container volume ls
//   container volume rm <name>
//   container volume inspect <name>
//
// Unlike Docker volumes: no drivers, no mount points, no tmpfs.
// A volume IS a shape subtree. Mounting = adding a dep.
// The shape graph handles persistence automatically.
// Volumes persist because shapes persist (Law 0).

let cmd = arg0

if cmd == "create" {
  let name = arg1
  let vid = "os.container.volumes." + name
  add_shape(vid, "container-volume", "", 4)
  print("Volume " + name + " created")
}
else if cmd == "ls" {
  let vols = children("os.container.volumes")
  print("NAME          SIZE")
  print("-------------------")
  for v in vols {
    let vid = "os.container.volumes." + v
    let kids = children(vid)
    print(v + "    " + len(kids) + " shapes")
  }
}
else if cmd == "rm" {
  let name = arg1
  let vid = "os.container.volumes." + name
  rm(vid)
  print("Volume " + name + " removed")
}
  """
}
