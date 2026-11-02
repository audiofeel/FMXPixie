# FMXPixie

> **A Delphi / FireMonkey DLL for building rich installer interfaces with Inno Setup.**

FMXPixie exposes FireMonkey forms, controls, rendering components, and utility services to Windows host applications through a DLL and a matching Inno Setup Pascal Script interface.

Its main rendering component is a Pascal-based HTML/CSS engine. FMXPixie does not host Chromium, WebView2, or an external browser process. The project also exposes SVG, Markdown, custom drawing, tag controls, MP3 playback, input-device handling, and Windows integration.

FMXPixie is designed for Inno Setup. The installer process loads the DLL, while the FMX window is created as a separate top-level window. The host HWND is passed to the FMX form creation method; the FMX UI is not an Inno Setup child control.

The repository contains both sides of the integration:

- FMXPixie.dpr and the Delphi units that build the DLL.
- [FMXPixieHandle.iss](Examples/Modules/FMXPixieHandle.iss), which declares the interfaces, types, callbacks, and imported DLL functions for Inno Setup Pascal Script.

## Features

- **HTML and CSS rendering** — load HTML from a string or file, set a base URL and user CSS, work with document and DOM element wrappers, query elements with CSS selectors, update the DOM in batches, handle links and element events, control zoom and scrolling, and export rendered content to PDF or PNG.
- **CSS interaction and transitions** — hover states, visual effects, and transition/layout test cases included in the examples.
- **SVG rendering** — display SVG content through a dedicated FMX view with alignment and sizing controls.
- **Markdown rendering** — render Markdown through the Pixie Markdown parser and an FMX view.
- **PaintBox** — draw paths and shapes, fill and stroke them, and render images through a canvas-oriented API.
- **TagBar** — display interactive tags with configurable colors, icons, checking, editing callbacks, and scrolling.
- **MP3 audio** — an FMX audio-player wrapper with playback controls and volume support.
- **Input devices** — keyboard, mouse, and game-controller input through the vendored Windows-only FMXInput subset; includes action bindings, polling, capture/rebinding, profiles, and rumble where supported by the device/backend.
- **Windows integration** — FMX forms, DWM-related appearance helpers, window utilities, cursor support, and system/storage information.
- **Utility services** — timers, a stopwatch, text-file helpers, and size/frequency formatting functions.

The public Pascal Script declarations in [FMXPixieHandle.iss](Examples/Modules/FMXPixieHandle.iss) are the definitive reference for exported names, interface identifiers, method signatures, parameter types, and callbacks.

## Examples

The [Examples](Examples/) directory contains 20 Inno Setup scripts. They are source demos and test cases, not precompiled installers.

### Application-style demos

- [Main Demo](<Examples/FMXPixie - Demo.iss>) — FMX form, separate HTML title/content views, HTML/CSS interaction, DOM access, callbacks, zoom, and PDF/PNG export.
- [MORROW / Object Archive](<Examples/FMXPixie - Morrow Demo.iss>) — an application-style catalogue UI with cards, filtering, and DOM updates.
- [FluentInstaller](<Examples/FMXPixie - FluentInstaller Demo.iss>) — installer-style interface composition.
- [MELE Launcher](<Examples/FMXPixie - MELE Launcher Demo.iss>) — launcher-style interface.
- [AeroGlass Lab](<Examples/FMXPixie - AeroGlass Lab Demo.iss>) — window appearance and DWM experiments.
- [Wrapper Integration Lab](<Examples/FMXPixie - Wrapper Integration Lab.iss>) — a broader exercise of the Pascal Script wrapper API.

### Component demos

- [SVGView](<Examples/FMXPixie - SVGView Demo.iss>)
- [MarkdownView](<Examples/FMXPixie - MarkdownView Demo.iss>)
- [PaintBox](<Examples/FMXPixie - PaintBox Demo.iss>)
- [TagBar](<Examples/FMXPixie - TagBar Demo.iss>)
- [SpanControls](<Examples/FMXPixie - SpanControls Demo.iss>)
- [Component Size](<Examples/FMXPixie - Component Size Demo.iss>)
- [Hover Event Visual](<Examples/FMXPixie - Hover Event Visual Demo.iss>)

### Audio and input

- [AudioPlayer](<Examples/FMXPixie - AudioPlayer Demo.iss>)
- [Volume Slider](<Examples/FMXPixie - Volume Slider Demo.iss>)
- [Gamepad Input](<Examples/FMXPixie - Gamepad Input Demo.iss>)

### CSS and rendering tests

- [CSS Background Image Gradient](<Examples/FMXPixie - CSS Background Image Gradient Test.iss>)
- [CSS Box Shadow Transition](<Examples/FMXPixie - CSS Box Shadow Transition Test.iss>)
- [CSS Size/Layout Transition](<Examples/FMXPixie - CSS Size Layout Transition Test.iss>)
- [CSS Transition / DisplayLink](<Examples/FMXPixie - CSS Transition DisplayLink Test.iss>)

Supporting content is stored in [Examples/Files](Examples/Files/).

## Requirements

- **Embarcadero RAD Studio 13.2 / Delphi with FireMonkey.** The checked-in handle include identifies compiler build 37.0.60952.8797, RTM Update 2.
- **Windows, Win32 and Win64.** The project is configured to produce 32-bit and 64-bit DLLs.
- **Inno Setup** to compile and run the .iss examples. The selected DLL architecture must match the Setup process architecture.
- The project uses local source under ThirdParty/FMXInput, Custom/AudioPlayer/Source, and Custom/AudioPlayer/Dependencies/PCMAudio; those source folders are included in the project search path.

A separate installation of Pixie or FMXInput components into the RAD Studio component palette is not required.

Review [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) before redistributing source files or DLLs. The repository is mixed-source; the root MIT license does not cover every file.

## Project structure

| Path | Purpose |
| --- | --- |
| FMXPixie.dpr | DLL project source, unit list, and architecture-specific library suffix. |
| FMXPixie.dproj | RAD Studio project configuration. |
| [Examples/Modules/FMXPixieHandle.iss](Examples/Modules/FMXPixieHandle.iss) | Inno Setup interface declarations and external function imports. |
| Forms/ | FMX forms, DWM helpers, cursor support, and Windows utilities. |
| FMX/ | FMX system integration. |
| Pixie/Common/ | Shared rendering primitives, images, colors, fonts, SVG, and WebP support from the Pixie engine. |
| Pixie/HtmlView/ | HTML/CSS parsing, layout, DOM, rendering, and PDF export. |
| Pixie/Markdown/ | Markdown parser and FMX view integration. |
| Pixie/SvgView/, Pixie/PaintBox/, Pixie/TagBar/ | Additional FMX rendering and controls. |
| Custom/ | FMXPixie wrappers, audio player, input, system information, and helpers. |
| ThirdParty/FMXInput/ | Vendored Windows-only FMXInput source and its MIT license. |
| Fix/FMX.Platform.Win.pas | Modified Embarcadero FireMonkey Windows platform unit; separately licensed. |
| Examples/ | Inno Setup demos and their supporting files. |

## Build the DLL

See [BUILDING.md](BUILDING.md) for the build and Inno Setup integration procedure.

The project defines architecture-specific suffixes in FMXPixie.dpr:

- Win32: FMXPixie_x86.dll
- Win64: FMXPixie_x64.dll

The project output directories are Win32\Release\ and Win64\Release\. Copy the corresponding build outputs into Examples\Modules\ before compiling the demos.

## Use FMXPixie from Inno Setup

For a script stored directly inside Examples\, include the handle file:

~~~~iss
[Code]
#include "Modules\FMXPixieHandle.iss"
~~~~

Add the architecture-matching DLL to [Files], using the internal name FMXPixie.dll. This is the name imported by the handle include:

~~~~iss
[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
~~~~

A minimal form-creation example, using the interface declared in the handle include:

~~~~pascal
var
  FMXForm: FForm;

procedure InitializeWizard;
begin
  FMXForm := InitFormHandle;
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF202020, '', False);
  FMXForm.Caption('FMXPixie');
  FMXForm.Show;
end;
~~~~

The full API is declared in [FMXPixieHandle.iss](Examples/Modules/FMXPixieHandle.iss). Keep the Delphi interface definitions and the Pascal Script declarations synchronized whenever an exported interface or method changes.

### Shutdown note

The current handle include provides FMXPixieShutDown and FMXPixieShutDownUn. These call the DLL shutdown export and then call Windows EndTask for the Setup or Uninstall progress window. They are host-window termination helpers, not generic UnloadDLL wrappers or proof that arbitrary DLL unloading is safe.

For the input service, stop polling and call FInput.Shutdown before unloading FMXPixie, as documented in [the vendored FMXInput README](ThirdParty/FMXInput/README.md). Destroy FMX objects and stop timers/services before ending the host process.

## API model

The DLL exposes factory functions including:

- InitFormHandle and InitMsgFormHandle
- InitPixieHtmlView, InitPixieElementList, InitPixieElement, and InitPixieDocument
- InitPixieSvgView, InitPixieMarkdownView, InitPixieTagBar, and InitPixiePaintBox
- InitPixieAudioPlayer and InitInput
- InitTimer, InitStopwatch, InitStorageInfo, and InitSystemInfo

The interface layer uses GUID-based IUnknown interfaces and pointer-sized FMX object handles. The handle include declares the corresponding Pascal Script types and imports, including WideString parameters and callback signatures. Use those declarations as written; do not substitute a different string or pointer representation.

## Credits and licensing

FMXPixie builds on the Pixie rendering engine, originally published by SoftPerfect Pty Ltd and distributed under the MIT License. The project also includes the Windows-only FMXInput subset by HemulGM and selected audio source files from FMXAudioLib and PCMAudio.

See [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for source origins, exact license boundaries, and the components shared with FMXBridge.

The root [LICENSE](LICENSE) applies only to original code authored by audiofeel. It does not grant rights to third-party code or Embarcadero platform source.
