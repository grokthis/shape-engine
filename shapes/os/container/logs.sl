shape os.container.logs : os.container {
  type: exec
  layer: 4
  """
// container logs <id> [flags]
//
// Show stdout/stderr output from a container.
//   --follow / -f   Stream output continuously
//   --tail <n>      Show last n lines
//   --timestamps    Show timestamps

let id = arg0
let cid = "os.container.instances." + id

if !exists(cid) {
  print("Error: container " + id + " not found")
  flag
}

let log_id = cid + ".log"
if exists(log_id) {
  let log = content(log_id)
  let lines = split(log, "\n")
  let tail = to_int(default(flag("tail"), "0"))
  if tail > 0 {
    let start = len(lines) - tail
    if start < 0 { set start = 0 }
    for i in range(start, len(lines)) {
      print(lines[i])
    }
  } else {
    print(log)
  }
} else {
  print("(no output)")
}
  """
}
