//go:build !js

// Host OS environment access. Native only.
package lang

import "os"

func envGet(name string) string {
	return os.Getenv(name)
}
