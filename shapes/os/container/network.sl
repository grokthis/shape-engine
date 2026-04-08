shape os.container.network : os.container {
  type: exec
  layer: 4
  """
// container network <command> [args]
//
// Manage container networks.
//
// Networks are shapes that connect containers. A container
// connected to a network can communicate with other containers
// on the same network through shape references.
//
// Commands:
//   container network create <name>
//   container network ls
//   container network rm <name>
//   container network connect <network> <container>
//   container network disconnect <network> <container>
//   container network inspect <name>
//
// Unlike Docker networks: no bridges, no iptables, no DNS.
// A network IS a shape. Containers connected to it are deps.
// Communication is wave propagation through the network shape.
// "Sending a message" = editing a shape on the network.
// "Receiving a message" = being a dependent of that shape.
//
// Network types:
//   bridge (default): containers can reach each other and host.
//   isolated: containers can reach each other only.
//   host: container shares host shape namespace (no isolation).

let cmd = arg0

if cmd == "create" {
  let name = arg1
  let nid = "os.container.networks." + name
  add_shape(nid, "container-network", "", 4)
  set_dim(nid, "type", default(flag("driver"), "bridge"))
  print("Network " + name + " created")
}
else if cmd == "ls" {
  let nets = children("os.container.networks")
  print("NAME          TYPE        CONTAINERS")
  print("-------------------------------------")
  for n in nets {
    let nid = "os.container.networks." + n
    let typ = dim(nid, "type")
    let conns = children(nid + ".members")
    print(n + "    " + typ + "    " + len(conns))
  }
}
else if cmd == "connect" {
  let net = arg1
  let ctr = arg2
  let mid = "os.container.networks." + net + ".members." + ctr
  add_shape(mid, "network-member", "", 4)
  print("Connected " + ctr + " to " + net)
}
else if cmd == "disconnect" {
  let net = arg1
  let ctr = arg2
  rm("os.container.networks." + net + ".members." + ctr)
  print("Disconnected " + ctr + " from " + net)
}
  """
}
