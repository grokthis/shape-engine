shape theory.computing.network.security : theory.computing.network {
  type: structure
  layer: 0
  """
// Network Security as Reference Integrity.
//
// Security is Law 1 applied to network contact: ensuring that
// references are to who they claim to be, that character is not
// tampered with, and that contact is authorized.
//
// TLS (Transport Layer Security):
//   Wraps any TCP connection in encryption.
//   Handshake:
//     1. Client sends supported cipher suites.
//     2. Server sends certificate (public key + identity + CA sig).
//     3. Client verifies certificate chain back to trusted CA.
//     4. Key exchange (Diffie-Hellman): both derive shared secret.
//     5. All subsequent data encrypted with shared secret (AES-256).
//   The certificate chain is Law 1: references must close or
//   point to invariants. The trusted CA is the invariant anchor.
//   Without it, the reference is dangling (who is this server?).
//
// Cryptographic primitives:
//   Symmetric encryption (AES): same key encrypts and decrypts.
//     Fast. Used for bulk data.
//   Asymmetric encryption (RSA, ECDSA): public key encrypts,
//     private key decrypts (or vice versa for signing).
//     Slow. Used for key exchange and authentication.
//   Hash (SHA-256): input -> fixed-size digest.
//     One-way: cannot recover input from digest.
//     Collision-resistant: hard to find two inputs with same digest.
//     Used for integrity checking.
//   HMAC: keyed hash. Proves both integrity and authenticity.
//
// Authentication:
//   Proving identity. "I am who I claim to be."
//   Something you know (password, key).
//   Something you have (certificate, token).
//   Something you are (biometric).
//   Multi-factor: combine two or more.
//   Authentication is structural identity verification:
//   the claimed shape matches the actual shape.
//
// Authorization:
//   What the authenticated entity is allowed to do.
//   Access control lists, capabilities, role-based access.
//   Authorization is context restriction: limiting which
//   shapes enter the entity's transformation.
//
// Derives from: theory.computing.network
  """
}
