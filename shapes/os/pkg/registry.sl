shape os.pkg.registry : os.pkg {
  type: system
  layer: 3
  """
// List all registered packages across all managers.

let pkgs = shapes_under("os.pkg.registry.")
let count = 0

for pkg in pkgs {
  let t = dim(pkg, "type")
  if t == "package" {
    let name = dim(pkg, "name")
    let ver = dim(pkg, "version")
    let desc = dim(pkg, "description")
    let mgr = dim(pkg, "manager")
    if name == "" {
      // derive name from shape id
      let parts = split(pkg, ".")
      set name = parts[len(parts) - 1]
    }
    print(name + "/" + mgr + " " + ver + " - " + desc)
    set count = count + 1
  }
}

if count == 0 {
  print("No packages registered.")
} else {
  print("")
  print(to_string(count) + " packages in registry.")
}
  """
}
