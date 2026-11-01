# FMXInput (Windows subset)

Vendored source: https://github.com/HemulGM/FMXInput

Upstream revision: \`bcb3d5bf3617edc59410904b8780e0e58c9bd093\`
Imported on: 2026-11-01

## Included files

- \`FMXInput.pas\` — common input model, manager, action bindings and JSON profiles.
- \`FMXInput.Windows.pas\` — Windows Raw Input, XInput and DirectInput backend.
- \`LICENSE\` — original upstream MIT license.

The two Pascal units are included without local source modifications. This is
the Windows-only subset required by FMXPixie for Inno Setup (Win32/Win64).
Linux and macOS backend units are intentionally not included.

## Integration notes

FMXPixie exposes the library through \`Custom/FMXPixie.Input.pas\`. Pascal
Script code should use the exported \`InitInput\` factory and the \`FInput\`
interface declared in \`Examples/Modules/FMXPixieHandle.iss\`.

Create and use the manager on the main/UI thread. Only one Windows Raw Input
backend may be active per process. Stop polling and call \`FInput.Shutdown\`
before unloading FMXPixie.dll.
