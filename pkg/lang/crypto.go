package lang

import (
	"crypto/ed25519"
	"crypto/sha256"
	"encoding/hex"
)

func cryptoHash(data string) string {
	h := sha256.Sum256([]byte(data))
	return hex.EncodeToString(h[:])
}

func cryptoKeygen() (string, string) {
	pub, priv, _ := ed25519.GenerateKey(nil)
	return hex.EncodeToString(pub), hex.EncodeToString(priv)
}

func cryptoSign(data string, privHex string) (string, error) {
	priv, err := hex.DecodeString(privHex)
	if err != nil {
		return "", err
	}
	sig := ed25519.Sign(ed25519.PrivateKey(priv), []byte(data))
	return hex.EncodeToString(sig), nil
}

func cryptoVerify(data string, sigHex string, pubHex string) bool {
	pub, err := hex.DecodeString(pubHex)
	if err != nil {
		return false
	}
	sig, err := hex.DecodeString(sigHex)
	if err != nil {
		return false
	}
	return ed25519.Verify(ed25519.PublicKey(pub), []byte(data), sig)
}
