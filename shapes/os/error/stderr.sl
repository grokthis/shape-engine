shape os.error.stderr : os.error, theory.computing.stack.passthrough {
  type: exec
  layer: 4
  """
// stderr Passthrough.
//
// When an error shape is created, it is printed to stderr
// through the passthrough mechanism. This bypasses all
// emulation layers and goes directly to the host process's
// file descriptor 2.
//
// Format:
//   [phase] source: message
//
// With --verbose:
//   [phase] source: message
//   derivation: dep0 -> dep1 -> ... -> source
//   tick: N
//   content: first 200 chars of failing shape
//
// stderr is write-only, append-only. You cannot read from stderr.
// You cannot suppress stderr (errors must be visible, Law 0:
// incoherence must surface). You can redirect stderr to a shape
// for programmatic handling:
//   errors --capture os.my-error-log
//
// The stderr channel is the forcing shape (Definition 11.1) for
// error resolution. It forces the operator to see the error.
// Suppressing it would be suppressing incoherence, which violates
// Law 0.
  """
}
