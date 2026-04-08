shape os.test.lang.crypto : os.test {
  type: test
  layer: 3
  desc: "Cryptography functions"
  """
// --- sha256 ---
let hash1 = sha256("hello")
assert_true(len(hash1) == 64, "sha256: 64 hex chars")
let hash2 = sha256("hello")
assert_eq(hash1, hash2, "sha256: deterministic")
let hash3 = sha256("world")
assert_true(hash1 != hash3, "sha256: different inputs differ")
assert_eq(sha256(""), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "sha256: empty string known")

// --- ed25519 keygen/sign/verify ---
let kp = ed25519_keygen()
assert_true(type(kp) == "map" || type(kp) == "list", "ed25519_keygen: returns keys")

let msg = "test message"
let privkey = map_get(kp, "private")
let pubkey = map_get(kp, "public")
assert_true(len(privkey) > 0, "ed25519: private key exists")
assert_true(len(pubkey) > 0, "ed25519: public key exists")

let sig = ed25519_sign(msg, privkey)
assert_true(len(sig) > 0, "ed25519_sign: produces signature")

let valid = ed25519_verify(msg, sig, pubkey)
assert_true(valid, "ed25519_verify: valid signature")

let invalid = ed25519_verify("wrong message", sig, pubkey)
assert_true(!invalid, "ed25519_verify: invalid for wrong message")
"""
}
