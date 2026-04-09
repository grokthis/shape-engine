shape os.shell.cmd.pkg-search : os.pkg {
  type: exec
  layer: 4
  """
// pkg-search <term> [manager]
//
// Search registered packages by name and description.

let term = arg0
let mgr_filter = ""
if exists("arg1") {
  if arg1 != "" {
    set mgr_filter = arg1
  }
}

let all_pkgs = shapes_under("os.pkg.registry.")
let results = []
let count = 0

for pkg in all_pkgs {
  let t = dim(pkg, "type")
  if t != "package" {
    // skip non-package shapes (manager groupings etc)
  } else {
    let pkg_name = dim(pkg, "name")
    let pkg_desc = dim(pkg, "description")
    let pkg_mgr = dim(pkg, "manager")
    let pkg_ver = dim(pkg, "version")

    if pkg_name == "" {
      let parts = split(pkg, ".")
      set pkg_name = parts[len(parts) - 1]
    }

    // Apply manager filter if given
    let mgr_ok = 1
    if mgr_filter != "" {
      if pkg_mgr != mgr_filter {
        set mgr_ok = 0
      }
    }

    if mgr_ok == 1 {
      // Match against name and description
      let match = 0
      if contains(pkg_name, term) {
        set match = 1
      }
      if contains(pkg_desc, term) {
        set match = 1
      }

      if match == 1 {
        print(pkg_name + "/" + pkg_mgr + " " + pkg_ver)
        if pkg_desc != "" {
          print("  " + pkg_desc)
        }
        print("")
        set count = count + 1
      }
    }
  }
}

if count == 0 {
  print("No packages found matching '" + term + "'.")
} else {
  print(to_string(count) + " packages found.")
}
  """
}

shape os.pkg.search : os.pkg {
  type: exec
  layer: 4
  """
render("os.shell.cmd.pkg-search")
  """
}
