//go:build js && wasm

// Browser stubs for file I/O. Returns clear errors.
package lang

import "fmt"

func fileRead(path string) (string, error) {
	return "", fmt.Errorf("file.read: not available in browser")
}

func fileReadBytes(path string) ([]byte, error) {
	return nil, fmt.Errorf("file.read_bytes: not available in browser")
}

func fileWrite(path, content string) error {
	return fmt.Errorf("file.write: not available in browser")
}

func fileWriteBytes(path string, data []byte) error {
	return fmt.Errorf("file.write_bytes: not available in browser")
}
