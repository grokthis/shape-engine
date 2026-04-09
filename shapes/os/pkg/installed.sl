shape os.pkg.installed : os.pkg {
  type: system
  layer: 3
  """
// List all installed packages.

let pkgs = shapes_under("os.pkg.installed.")
let count = 0

print("Installed packages:")
print("")

for pkg in pkgs {
  let name = dim(pkg, "name")
  let ver = dim(pkg, "version")
  let mgr = dim(pkg, "manager")
  let tick = dim(pkg, "install_tick")
  if name == "" {
    let parts = split(pkg, ".")
    set name = parts[len(parts) - 1]
  }
  print("  " + name + " " + ver + " [" + mgr + "] (tick " + tick + ")")
  set count = count + 1
}

if count == 0 {
  print("  (none)")
}

print("")
print(to_string(count) + " packages installed.")
  """
}
