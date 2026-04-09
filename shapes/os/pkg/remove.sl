shape os.shell.cmd.pkg-remove : os.pkg {
  type: exec
  layer: 4
  """
// pkg-remove <name>
//
// Remove an installed package. Checks for reverse dependencies first.

let name = arg0
let inst_id = "os.pkg.installed." + name

if !exists(inst_id) {
  print("E: Package " + name + " is not installed.")
  auto ""
}

// Check reverse dependencies: find installed packages that depend on this one
let all_installed = shapes_under("os.pkg.installed.")
let rdeps = []

for pkg in all_installed {
  let dep_str = dim(pkg, "depends")
  if dep_str != "" {
    let deps = split(dep_str, ",")
    for dep in deps {
      let d = trim(dep)
      if d == name {
        let pkg_name = dim(pkg, "name")
        if pkg_name == "" {
          let parts = split(pkg, ".")
          set pkg_name = parts[len(parts) - 1]
        }
        set rdeps = append(rdeps, pkg_name)
      }
    }
  }
}

if len(rdeps) > 0 {
  print("E: Cannot remove " + name + ". The following packages depend on it:")
  for rd in rdeps {
    print("  " + rd)
  }
  print("")
  print("Remove those packages first, or use --force (not recommended).")
  auto ""
}

// Safe to remove
print("Reading package lists... Done")
print("Building dependency tree... Done")
print("")
print("The following packages will be REMOVED:")
print("  " + name)
print("")

remove(inst_id)

print("Removing " + name + " ... done")
print("0 upgraded, 0 newly installed, 1 to remove.")
  """
}

shape os.pkg.remove : os.pkg {
  type: exec
  layer: 4
  """
render("os.shell.cmd.pkg-remove")
  """
}
