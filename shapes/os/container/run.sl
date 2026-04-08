shape os.container.run : os.container {
  type: exec
  layer: 4
  """
// container run <stack> <program> [flags]
//
// Create and start a container.
//
// Arguments:
//   stack:    comma-separated substrate layers.
//             "mos6502", "riscv64,shape-engine", "arm64,go,shape-engine"
//   program:  path to program or shape ID to execute.
//   flags:
//     --name <name>       Container name (auto-generated if omitted)
//     --rm                Remove container after exit
//     --detach / -d       Run in background
//     --interactive / -i  Keep stdin open
//     --tty / -t          Allocate pseudo-TTY
//     --env KEY=VAL       Set environment variable
//     --mount <src>:<dst> Mount host shape path into container
//     --memory <limit>    Memory limit (e.g. "64KB", "16MB")
//     --cycles <limit>    Cycle budget per tick
//     --caps <list>       Allowed syscalls (e.g. "0,1,2,3,4,5,9")
//     --network <name>    Connect to container network
//     --port <host>:<guest> Forward port
//     --volume <name>:<path> Attach volume
//     --restart <policy>  "no", "always", "on-failure"
//
// Examples:
//   container run mos6502 game.prg -it
//   container run riscv64,shape-engine app.sl -d --name my-app
//   container run arm64,go,shape-engine,shape-os os.img --memory 256MB
//   container run shape-engine hello.sl --rm
//
// What happens:
//   1. Parse stack string into substrate layers.
//   2. Create container shape: os.container.instances.<id>
//   3. Initialize each substrate layer (allocate memory, reset).
//   4. Load program into top layer.
//   5. Configure passthrough (stdio, mounts, caps).
//   6. If --detach: return container ID immediately.
//      Else: attach stdio and run until exit.

let id = default(flag("name"), "c" + global_tick())
let stack = arg0
let program = arg1
let detach = has_flag("detach") || has_flag("d")
let interactive = has_flag("interactive") || has_flag("i")
let rm_after = has_flag("rm")

// Create container shape
let cid = "os.container.instances." + id
add_shape(cid, "container", "", 4)
set_dim(cid, "stack", stack)
set_dim(cid, "program", program)
set_dim(cid, "status", "created")
set_dim(cid, "cycles", "0")
set_dim(cid, "memory", default(flag("memory"), "64MB"))
set_dim(cid, "restart", default(flag("restart"), "no"))

if detach {
  set_dim(cid, "status", "running")
  print("Container " + id + " started (detached)")
} else {
  set_dim(cid, "status", "running")
  print("Container " + id + " started")
}
  """
}
