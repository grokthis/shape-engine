shape os.container.ps : os.container {
  type: exec
  layer: 4
  """
// container ps [flags]
//
// List containers.
//   --all / -a    Show all containers (including stopped)
//
// Output:
//   ID      STACK                    STATUS    CYCLES     MEMORY
//   c01     mos6502                  running   1.2M       64KB
//   c02     riscv64/shape-engine     running   450K       16MB
//   c03     arm64/go/shape-engine    stopped   89K        256MB

let show_all = has_flag("all") || has_flag("a")
let prefix = "os.container.instances"
let kids = children(prefix)

print("ID        STACK                        STATUS    CYCLES      MEMORY")
print("----------------------------------------------------------------------")

for kid in kids {
  let cid = prefix + "." + kid
  let status = dim(cid, "status")
  if status == "running" || show_all {
    let stack = dim(cid, "stack")
    let cycles = dim(cid, "cycles")
    let mem = dim(cid, "memory")
    print(kid + "    " + stack + "    " + status + "    " + cycles + "    " + mem)
  }
}
  """
}
