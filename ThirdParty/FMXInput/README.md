# FMXInput (Windows subset)

Vendored source: https://github.com/HemulGM/FMXInput

Upstream revision: `bcb3d5bf3617edc59410904b8780e0e58c9bd093`
Imported on: 2026-11-01

## Included files

- `FMXInput.pas` — common input model, manager, action bindings and JSON profiles.
- `FMXInput.Windows.pas` — Windows Raw Input, XInput and DirectInput backend.
- `LICENSE` — original upstream MIT license.

The two Pascal units are included without local source modifications. This is
the Windows-only subset required by FMXPixie for Inno Setup (Win32/Win64).
Linux and macOS backend units are intentionally not included.

## FMXPixie wrapper

FMXPixie exposes the library through `Custom/FMXPixie.Input.pas`.
Pascal Script uses the exported `InitInput` factory and the
`FInput` interface declared in `Examples/Modules/FMXPixieHandle.iss`.

The wrapper owns one `TInputManager` and optionally polls it with an FMX
timer. Call `StartPolling(8, Event)` on the UI thread; the callback runs
after each poll. `IsPressed(Action)` reports the held state, while
`WasPressed(Action)` consumes a single rising-edge notification so a
held controller button does not repeatedly click an Inno Setup button.

Use `Bind(Action, DeviceID, Kind, Code, Direction)` for explicit
bindings. An empty device ID selects the aggregate keyboard for `Kind=0`,
or the aggregate mouse for `Kind=1` / `Kind=4`. Use a gamepad's
actual `DeviceID` for its buttons, axes and hat. `BeginCapture` and
`AcceptCaptured` provide interactive rebinding. `BindAxis` exposes
axis origin and press/release thresholds for manual calibration.

Device kinds: keyboard=0, controller=1, mouse=2. Element kinds: key=0,
button=1, axis=2, hat=3, relative axis=4. See the constants in the Inno Setup
handle include.

Create, poll, refresh and destroy the manager on the main/UI thread. Only one
Windows Raw Input backend may be active per process. Stop polling and call
`FInput.Shutdown` before unloading FMXPixie.dll.
