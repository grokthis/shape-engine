// Input: user interaction as shapes.
//
// A keypress IS a shape with a key dimension and a state (pressed/released).
// Mouse position IS a shape with x,y dimensions.
// Every input event IS a shape that propagates through the event system.
// Input IS wave propagation from the human to the machine.

shape hardware.input : hardware {
  type: system
  layer: 2
  "Input devices. Keyboard, mouse, touch, gamepad. Events are shapes."
}

shape hardware.input.keyboard : hardware.input {
  type: unit
  layer: 2
  """
// Keyboard state: each key IS a shape.
// hardware.input.key.A = "pressed" or "released"
// Key events create/edit these shapes.
// Anything that depends on a key shape gets a wave on keypress.
"""
}

shape hardware.input.mouse : hardware.input {
  type: unit
  layer: 2
  """
// Mouse state as shapes.
// hardware.input.mouse.x = current x position
// hardware.input.mouse.y = current y position
// hardware.input.mouse.button.left = "pressed" or "released"
// hardware.input.mouse.button.right = "pressed" or "released"
// hardware.input.mouse.scroll = delta
//
// Mouse movement IS wave propagation: the position shape changes,
// everything that depends on it (cursor, selection, camera) updates.
"""
}

shape hardware.input.touch : hardware.input {
  type: unit
  layer: 2
  """
// Touch state: each touch point IS a shape.
// hardware.input.touch.0 = "x,y" (first finger)
// hardware.input.touch.1 = "x,y" (second finger)
// Pinch, rotate, pan are structural relationships between touch points.
"""
}

shape hardware.input.gamepad : hardware.input {
  type: unit
  layer: 2
  """
// Gamepad: axes and buttons as shapes.
// hardware.input.pad.axis.lx = left stick X (-1 to 1)
// hardware.input.pad.axis.ly = left stick Y
// hardware.input.pad.button.a = "pressed" or "released"
//
// The gamepad IS a shape graph. Each input IS a shape.
// Game logic depends on input shapes. Change propagates as waves.
"""
}
