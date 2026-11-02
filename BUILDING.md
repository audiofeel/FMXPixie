# Building and integrating FMXPixie

This guide describes the current project layout and the Inno Setup interface shipped in this repository.

## 1. Build the DLL in RAD Studio

1. Open FMXPixie.dproj in RAD Studio 13.2.
2. Select the Release configuration.
3. Select Win32 and build the project.
4. Select Win64 and build the project again.

FMXPixie.dpr defines the architecture-specific library suffix:

| Target | Expected DLL |
| --- | --- |
| Win32 | FMXPixie_x86.dll |
| Win64 | FMXPixie_x64.dll |

The project output directories are:

- Win32\Release\
- Win64\Release\

The project search path includes the local Pixie source, the vendored Windows FMXInput units, the selected FMXAudioLib source, the PCMAudio subset, and Fix\FMX.Platform.Win.pas. A separate component-palette installation is not required.

The project file also contains IDE package configuration entries. If a build on another RAD Studio installation reports a missing package, inspect the actual compiler diagnostic and the active package/linker settings rather than assuming that every package name stored in the project is a source dependency.

## 2. Prepare the Inno Setup module directory

The demo scripts expect the following files in Examples\Modules\:

- FMXPixieHandle.iss — already included in the repository.
- FMXPixie_x86.dll — copy from the Win32 Release output.
- FMXPixie_x64.dll — copy from the Win64 Release output.

The DLL binaries are not checked into this Git repository. Keep the architecture suffixes on the files in the module directory.

## 3. Add the DLL to an Inno Setup script

The handle include imports the library as FMXPixie.dll using @files:FMXPixie.dll. Therefore, use DestName: "FMXPixie.dll" for the internal extracted filename.

The following selection is used by the repository demos:

~~~~iss
[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
~~~~

The installer process and DLL must have matching bitness. With no x64 Setup architecture selected, the script uses the x86 DLL.

## 4. Include the Pascal Script declarations

For a script stored directly inside Examples\, use:

~~~~iss
[Code]
#include "Modules\FMXPixieHandle.iss"
~~~~

The include declares the FMXPixie interfaces, GUIDs, enumerations, callback types, external imports, and helper routines. It is the Pascal Script side of the API and must remain synchronized with the Delphi interface declarations and exports.

For scripts stored in a different directory, adjust the relative include and DLL source paths.

## 5. Create an FMX window

A minimal example using declarations from FMXPixieHandle.iss:

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

The host window handle is passed to the FMX form creation method. The FMX window is created by the DLL as a separate FMX window; it is not a child control inserted into the Inno Setup form.

Use the FPixieHtmlView, FPixieDocument, FPixieElement, and component interfaces declared in the same include for the rest of the UI.

## 6. Input service lifecycle

The input wrapper uses the Windows FMXInput backend and can poll with an FMX timer. Follow the vendored [FMXInput README](ThirdParty/FMXInput/README.md):

- Create and use the input manager on the main/UI thread.
- Stop polling before shutdown.
- Call FInput.Shutdown before unloading FMXPixie.dll.
- Only one Windows Raw Input backend may be active per process.

The wrapper's polling callback is invoked after the poll operation. Do not leave a polling timer active while destroying the FMXPixie host objects.

## 7. Shutdown behavior in the current handle include

The current include defines FMXPixieShutDown and FMXPixieShutDownUn. Each calls the DLL shutdown export and then calls Windows EndTask for the corresponding Setup or Uninstall progress window.

These procedures are not generic UnloadDLL wrappers. They request termination of the host window after the exported shutdown call. Do not interpret them as proof that manually unloading the DLL while Pascal Script interface references, callbacks, timers, or FMX objects remain alive is safe.

## 8. Examples

Compile the scripts in Examples\ with the prepared module directory. The examples include application-style layouts, component demos, audio/input examples, and CSS rendering tests.
