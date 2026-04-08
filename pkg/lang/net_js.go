//go:build js && wasm

// Browser stub for environment access.
package lang

func envGet(name string) string {
	return ""
}
