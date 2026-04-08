// Pure net helpers: time, URL encoding.
// No OS dependencies. Compiles on all targets.
package lang

import (
	"net/url"
	"time"
)

func timeNow() int64 {
	return time.Now().Unix()
}

func timeMs() int64 {
	return time.Now().UnixMilli()
}

func urlEncode(s string) string {
	return url.QueryEscape(s)
}

func urlDecode(s string) string {
	decoded, err := url.QueryUnescape(s)
	if err != nil {
		return s
	}
	return decoded
}
