shape theory.computing.peripheral.input : theory.computing.peripheral {
  type: unit
  layer: 0
  """
// Input Protocol.
//
// Input devices are how external character enters the computer's
// transformation. Each converts physical action to digital event.
//
// Keyboard:
//   Key matrix: N rows x M columns.
//   Controller scans matrix every ~1ms.
//   Key press: row-column intersection detected.
//   Generates scan code (which key) + make/break (press/release).
//   Delivered as interrupt. Driver maps scan code to character
//   (keymap, modified by shift/ctrl/alt state).
//   Event: {key, action, modifiers, timestamp}.
//
// Mouse / Trackpad:
//   Reports: delta_x, delta_y, button_state.
//   Polling rate: 125-1000 Hz.
//   Trackpad: capacitive touch sensor grid.
//   Reports touch position(s), pressure, gesture recognition.
//   Event: {x, y, buttons, scroll, timestamp}.
//
// Touch screen:
//   Capacitive grid overlaid on display.
//   Reports: array of touch points, each with (x, y, pressure).
//   Multi-touch: up to 10 simultaneous contacts.
//   Gesture recognition: tap, swipe, pinch, rotate.
//   Event: {touches[], gesture, timestamp}.
//
// Event model:
//   All input devices produce events.
//   Events are timestamped, typed, and queued.
//   The event queue is a FIFO: first-in first-out.
//   The OS delivers events to the focused application.
//   The application's event loop: dequeue -> handle -> render.
//   This is the application-level transformation law:
//     M' = f(event, app_state).
//   The event is character. The application is structure.
//   The rendered output is the emergent moment.
//
// Derives from: theory.computing.peripheral
  """
}
