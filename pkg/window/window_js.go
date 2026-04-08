//go:build js && wasm

// In the browser, the browser IS the window.
package window

func Open(url, title string, width, height int, fullscreen bool) {}
