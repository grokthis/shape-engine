shape os.doc.cmd.container : os.doc {
  type: doc
  layer: 4
  """
container - manage computation stacks as isolated containers

USAGE
  container run <stack> <program> [flags]    Create and run a container
  container build <containerfile>            Build image from Containerfile
  container ps [-a]                          List containers
  container stop <id>                        Stop a container
  container rm <id> [-f]                     Remove a container
  container logs <id> [-f] [--tail n]        Show output
  container exec <id> <command>              Run command in container
  container inspect <id>                     Show container details
  container cp <src> <dst>                   Copy shapes in/out
  container attach <id>                      Attach to running container
  container commit <id> <name>               Save state as image

  container compose up [-d]                  Start services from compose file
  container compose down [--volumes]         Stop all services
  container compose ps                       List services
  container compose logs [service]           Show service output
  container compose scale <svc>=<n>          Scale a service
  container compose exec <svc> <cmd>         Run in service

  container network create <name>            Create network
  container network ls                       List networks
  container network connect <net> <ctr>      Connect container
  container network disconnect <net> <ctr>   Disconnect container

  container volume create <name>             Create volume
  container volume ls                        List volumes
  container volume rm <name>                 Remove volume

EXAMPLES
  container run mos6502 game.prg -it
  container run riscv64,shape-engine app.sl -d --name myapp
  container run shape-engine hello.sl --rm
  container compose up -d
  container exec myapp ls
  container logs myapp --tail 20

STACKS
  Computation stacks are comma-separated substrate layers.
  Available: mos6502, arm64, riscv32i, riscv64, x86-64,
             shape-engine, fpga

  Examples:
    mos6502                     Bare 6502
    riscv64,shape-engine        Shape engine on RISC-V
    arm64,go,shape-engine       Shape engine on ARM64 (current)
    shape-engine,shape-engine   Nested shape engines

  Each layer runs on the one below. I/O punches to the base.
  """
}
