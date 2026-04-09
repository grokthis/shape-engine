shape os.shell.cmd.pkg-upgrade : os.pkg {
  type: exec
  layer: 4
  """
// pkg-upgrade
//
// Check all installed packages against registry and upgrade if newer.

let all_installed = shapes_under("os.pkg.installed.")
let upgraded = []
let checked = 0

print("Reading package lists... Done")
print("Building dependency tree... Done")
print("Calculating upgrade... Done")
print("")

for pkg in all_installed {
  let name = dim(pkg, "name")
  let inst_ver = dim(pkg, "version")
  let mgr = dim(pkg, "manager")

  if name == "" {
    let parts = split(pkg, ".")
    set name = parts[len(parts) - 1]
  }
  if mgr == "" {
    set mgr = "apt"
  }

  let reg_id = "os.pkg.registry." + mgr + "." + name
  if exists(reg_id) {
    let reg_ver = dim(reg_id, "version")
    if reg_ver != inst_ver {
      if reg_ver != "" {
        set upgraded = append(upgraded, name)

        print("Unpacking " + name + " (" + reg_ver + ") over (" + inst_ver + ") ...")

        dilate 1000 {
          render(reg_id)
          set_dim(pkg, "version", reg_ver)
          set_dim(pkg, "install_tick", to_string(global_tick()))
        }

        print("Setting up " + name + " (" + reg_ver + ") ... done")
      }
    }
  }

  set checked = checked + 1
}

print("")
if len(upgraded) == 0 {
  print("All " + to_string(checked) + " packages are up to date.")
} else {
  print(to_string(len(upgraded)) + " upgraded, 0 newly installed, 0 to remove.")
}
  """
}

shape os.pkg.upgrade : os.pkg {
  type: exec
  layer: 4
  """
render("os.shell.cmd.pkg-upgrade")
  """
}
