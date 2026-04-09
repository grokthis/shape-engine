shape os.error : os {
  type: system
  layer: 4
  """
// Error System.
//
// Every error in Shape OS is a shape. Errors are not exceptions.
// They are not panics. They are not error codes. They are shapes
// with structure (what went wrong) and character (the details).
//
// Error shapes live under the failing shape's namespace:
//   theory.prior-reference.error.parse.1234
//   os.container.run.error.eval.5678
//
// The error shape's deps point to the shape that errored,
// giving the derivation trace for free.
//
// Commands:
//   errors              List all error shapes in the system
//   errors clear         Remove all error shapes
//   errors <id>          Show error details for a shape
//   errors --phase parse Show only parse errors
//   errors --recent 10   Show 10 most recent errors
  """
}
