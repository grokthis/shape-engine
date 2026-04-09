shape os.pkg.resolve : os.pkg {
  type: exec
  layer: 4
  """
// Dependency resolver.
// arg0: package name
// arg1: manager (default "apt")
//
// Looks up os.pkg.registry.<manager>.<name>, reads depends dimension,
// recursively resolves, returns topologically sorted install order.

let name = arg0
let mgr = "apt"
if exists("arg1") {
  if arg1 != "" {
    set mgr = arg1
  }
}

// Resolve dependencies depth-first, collect in order.
let resolved = []
let seen = []

fn resolve(pkg_name) {
  // Check if already resolved
  if contains(seen, pkg_name) {
    auto ""
  }
  set seen = append(seen, pkg_name)

  let reg_id = "os.pkg.registry." + mgr + "." + pkg_name
  if !exists(reg_id) {
    print("E: Package " + pkg_name + " not found in " + mgr + " registry")
    auto ""
  }

  let dep_str = dim(reg_id, "depends")
  if dep_str != "" {
    let deps = split(dep_str, ",")
    for dep in deps {
      let d = trim(dep)
      if d != "" {
        resolve(d)
      }
    }
  }

  set resolved = append(resolved, pkg_name)
  auto ""
}

resolve(name)

print("Resolution order for " + name + " (" + mgr + "):")
for r in resolved {
  print("  " + r)
}
print(to_string(len(resolved)) + " packages in resolution.")
  """
}
