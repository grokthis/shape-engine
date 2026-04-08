//go:build !js

// Host OS file I/O. Native only.
package lang

import "os"

func fileRead(path string) (string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

func fileReadBytes(path string) ([]byte, error) {
	return os.ReadFile(path)
}

func fileWrite(path, content string) error {
	return os.WriteFile(path, []byte(content), 0644)
}

func fileWriteBytes(path string, data []byte) error {
	return os.WriteFile(path, data, 0644)
}
