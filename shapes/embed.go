// Package shapes embeds all shape files for the system.
// Directory structure mirrors the shape namespace:
//
//	law/persistence.sl            → shape law.persistence
//	os/office/handler/sheet/data.sl → shape os.office.handler.sheet.data
//
// Any runtime (Go, C, or native shape machine) imports this
// package to bootstrap the system.
package shapes

import "embed"

//go:embed all:_preamble.sl app.sl app engine.sl engine hardware.sl hardware law.sl law lib.sl lib os.sl os shape.sl shape user.sl
var FS embed.FS
