shape os.test.lang.time_url : os.test {
  type: test
  layer: 3
  desc: "Time and URL functions"
  """
// --- time_now ---
let t1 = time_now()
assert_true(t1 > 1700000000, "time_now: reasonable unix timestamp")
let t2 = time_now()
assert_true(t2 >= t1, "time_now: monotonic")

// --- time_ms ---
let ms = time_ms()
assert_true(ms > 1700000000000, "time_ms: reasonable ms timestamp")
assert_true(ms >= t1 * 1000, "time_ms: >= seconds * 1000")

// --- url_encode ---
assert_eq(url_encode("hello world"), "hello+world", "url_encode: space")
assert_eq(url_encode("a=b&c=d"), "a%3Db%26c%3Dd", "url_encode: special chars")
assert_eq(url_encode(""), "", "url_encode: empty")
assert_eq(url_encode("nospace"), "nospace", "url_encode: no encoding needed")

// --- url_decode ---
assert_eq(url_decode("hello+world"), "hello world", "url_decode: plus to space")
assert_eq(url_decode("a%3Db%26c%3Dd"), "a=b&c=d", "url_decode: percent decode")
assert_eq(url_decode(""), "", "url_decode: empty")
assert_eq(url_decode("nospace"), "nospace", "url_decode: no decoding needed")

// --- roundtrip ---
let original = "hello world & friends = awesome!"
assert_eq(url_decode(url_encode(original)), original, "url: roundtrip")
"""
}
