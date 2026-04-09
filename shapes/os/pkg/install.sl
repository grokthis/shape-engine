shape os.shell.cmd.pkg-install : os.pkg {
  type: exec
  layer: 4
  """
// pkg-install <name> [manager]
//
// Install a package and its dependencies.

let name = arg0
let mgr = "apt"
if exists("arg1") {
  if arg1 != "" {
    set mgr = arg1
  }
}

let reg_id = "os.pkg.registry." + mgr + "." + name
if !exists(reg_id) {
  print("E: Unable to locate package " + name)
  auto ""
}

// Check if already installed
let inst_id = "os.pkg.installed." + name
if exists(inst_id) {
  print(name + " is already the newest version (" + dim(inst_id, "version") + ").")
  print("0 upgraded, 0 newly installed, 0 to remove.")
  auto ""
}

// Resolve dependencies
let resolved = []
let seen = []

fn resolve(pkg_name) {
  if contains(seen, pkg_name) {
    auto ""
  }
  set seen = append(seen, pkg_name)

  let rid = "os.pkg.registry." + mgr + "." + pkg_name
  if exists(rid) {
    let dep_str = dim(rid, "depends")
    if dep_str != "" {
      let deps = split(dep_str, ",")
      for dep in deps {
        let d = trim(dep)
        if d != "" {
          resolve(d)
        }
      }
    }
  }

  set resolved = append(resolved, pkg_name)
  auto ""
}

resolve(name)

// Filter to uninstalled only
let to_install = []
for r in resolved {
  let check_id = "os.pkg.installed." + r
  if !exists(check_id) {
    set to_install = append(to_install, r)
  }
}

if len(to_install) == 0 {
  print(name + " is already the newest version.")
  auto ""
}

// Print apt-style output
print("Reading package lists... Done")
print("Building dependency tree... Done")
print("Reading state information... Done")

print("The following NEW packages will be installed:")
let names_str = "  "
for pkg in to_install {
  set names_str = names_str + pkg + " "
}
print(names_str)

print("Need to get " + to_string(len(to_install)) + " shapes.")
print("")

// Install each package
for pkg in to_install {
  let pkg_reg = "os.pkg.registry." + mgr + "." + pkg
  let pkg_ver = dim(pkg_reg, "version")
  let pkg_deps = dim(pkg_reg, "depends")

  print("Unpacking " + pkg + " (" + pkg_ver + ") ...")

  // Execute install script if the registry shape has content
  dilate 1000 {
    render(pkg_reg)

    // Create installed record
    let pkg_inst = "os.pkg.installed." + pkg
    add_shape(pkg_inst, "installed", "", 3)
    set_dim(pkg_inst, "name", pkg)
    set_dim(pkg_inst, "version", pkg_ver)
    set_dim(pkg_inst, "manager", mgr)
    set_dim(pkg_inst, "install_tick", to_string(global_tick()))
    set_dim(pkg_inst, "depends", pkg_deps)
  }

  print("Setting up " + pkg + " (" + pkg_ver + ") ... done")
}

print("")
print(to_string(len(to_install)) + " newly installed.")
  """
}

shape os.pkg.install : os.pkg {
  type: exec
  layer: 4
  """
// Alias: delegates to os.shell.cmd.pkg-install
render("os.shell.cmd.pkg-install")
  """
}
