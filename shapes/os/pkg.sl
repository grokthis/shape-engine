// Package system for shape-engine.
//
// Architecture:
//   os.pkg.registry.<manager>.<name>  — package definitions (metadata + install script)
//   os.pkg.installed.<name>           — installed package records
//   os.pkg.resolve                    — dependency resolver
//   os.pkg.install                    — install lifecycle
//   os.pkg.remove                     — removal with reverse-dep check
//   os.pkg.search                     — search across registries
//   os.pkg.upgrade                    — upgrade installed packages
//
// Package shapes in the registry carry dimensions:
//   version, description, depends, manager
// and content that serves as the install script (rendered on install).
//
// Installed records carry:
//   version, manager, install_tick, depends

shape os.pkg : os {
  type: system
  layer: 3
  "Shape package system. Everything is a shape, packages included."
}
