shape os.container : os {
  type: system
  layer: 4
  """
// Shape Container Runtime.
//
// Everything is a shape. A container is a shape whose character
// is an isolated computation stack with passthrough I/O.
//
// Unlike Docker: no images, no layers, no registries, no daemon.
// A container IS a shape with deps. The shape graph IS the
// registry. Wave propagation IS the orchestration. The laws
// of coherence ARE the security model.
//
// Commands:
//   container run <stack> <program> [flags]
//   container build <containerfile>
//   container ps
//   container stop <id>
//   container rm <id>
//   container logs <id>
//   container exec <id> <command>
//   container inspect <id>
//   container cp <src> <id>:<dst>
//   container attach <id>
//   container commit <id> <name>
//   container export <id> <path>
//   container import <path> <name>
//   container compose up [file]
//   container compose down
//   container compose ps
//   container compose logs
//   container network create <name>
//   container network ls
//   container volume create <name>
//   container volume ls
  """
}
