# FMXPixie Modules

This directory contains the Inno Setup handle include and the architecture-specific DLL files required by the example scripts.

## Required files

- FMXPixieHandle.iss — Pascal Script interfaces, types, callbacks, and external imports.
- FMXPixie_x86.dll — 32-bit FMXPixie library.
- FMXPixie_x64.dll — 64-bit FMXPixie library.

The handle include is tracked in Git. The DLL binaries are not committed to the repository.

## Prepare the directory

1. Build FMXPixie for Win32 and Win64 in RAD Studio.
2. Copy the Win32 DLL output to this directory as FMXPixie_x86.dll.
3. Copy the Win64 DLL output to this directory as FMXPixie_x64.dll.
4. Compile one of the .iss files in the parent Examples\ directory.

See [BUILDING.md](../../BUILDING.md) for the full procedure.

## DLL filename expected by the script

The examples choose a DLL according to the Setup process architecture and assign the internal filename FMXPixie.dll:

~~~~iss
[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
~~~~

The external declarations in FMXPixieHandle.iss refer to @files:FMXPixie.dll. Do not change the internal filename unless you also update every matching import declaration.

The DLL bitness must match the Inno Setup process that loads it.
