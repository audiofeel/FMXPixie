# Third-party notices

FMXPixie is a mixed-source repository. The root [LICENSE](LICENSE) applies only to original code authored by audiofeel; it does not replace the licenses or distribution conditions of third-party code, platform source, or external packages.

This document records the source origins and licensing boundaries identified during the repository review. It is not a substitute for the original upstream license or vendor agreement. Preserve notices in individual source files and license files when copying or redistributing code.

## Pixie rendering engine — SoftPerfect Pty Ltd

- Upstream project: [laoqiuqiu/pixie](https://github.com/laoqiuqiu/pixie).
- Intermediate fork used for comparison: [HemulGM/Pixie](https://github.com/HemulGM/Pixie), which identifies itself as a fork of the laoqiuqiu repository.
- Original project origin: [gitlab.com/retrofoxed/pixie](https://gitlab.com/retrofoxed/pixie).
- Included source: adapted Pixie engine units under Pixie/Common/, Pixie/HtmlView/, Pixie/Markdown/, Pixie/SvgView/, Pixie/PaintBox/, and upstream-derived portions of Pixie/TagBar/.
- License: MIT, Copyright (c) 2026 SoftPerfect Pty Ltd. The upstream license is reproduced in [ThirdParty/Pixie/LICENSE](ThirdParty/Pixie/LICENSE).

The FMXPixie source tree contains adapted versions of upstream Pixie units; the engine is not a verbatim copy. Keep the SoftPerfect MIT notice with redistributed copies of those adapted portions.

The project-specific FMXPixie adapter units in the Pixie tree are separate integration code. Their original portions are covered by the root license only to the extent that they were authored by audiofeel and are not derived from third-party code.

## FMXInput — HemulGM

- Upstream: [HemulGM/FMXInput](https://github.com/HemulGM/FMXInput).
- Included source: ThirdParty/FMXInput/FMXInput.pas and ThirdParty/FMXInput/FMXInput.Windows.pas.
- Upstream revision recorded by the vendored README: bcb3d5bf3617edc59410904b8780e0e58c9bd093.
- License: MIT, Copyright (c) 2026 HemulGM. The original license is retained at [ThirdParty/FMXInput/LICENSE](ThirdParty/FMXInput/LICENSE).

The included units are identified by the vendored README as an unmodified Windows-only subset. The FMXPixie service wrapper is in Custom/FMXPixie.Input.pas.

## Audio components

### FMXAudioLib — HemulGM

- Upstream: [HemulGM/FMXAudioLib](https://github.com/HemulGM/FMXAudioLib).
- Selected source files: Custom/AudioPlayer/Source/.
- License status: the upstream repository currently has no LICENSE file and does not declare a repository license. The license for FMXAudioLib-authored portions is therefore not explicitly specified by that repository. Do not assume that the root FMXPixie MIT license grants rights to redistribute those portions. Obtain permission or licensing clarification from the upstream author before redistributing the affected source or binaries.

The following six MP3 decoder units explicitly identify their code as translated from [minimp3](https://github.com/lieff/minimp3) and state **CC0 1.0 Universal** in their own source headers:

- FMXAudio.MP3.BitStream.pas
- FMXAudio.MP3.Frame.pas
- FMXAudio.MP3.Huffman.pas
- FMXAudio.MP3.Layer3.pas
- FMXAudio.MP3.ScaleFactors.pas
- FMXAudio.MP3.Types.pas

Preserve those headers. The stated CC0 status applies to the identified minimp3-derived code; it must not be extended to other FMXAudioLib-authored files without a separate license basis.

Other selected units in the same folder, including FMXAudio.Audio.PCM.pas, FMXAudio.Sources.Convert.pas, FMXAudio.Sources.MP3.pas, FMXAudio.Sources.pas, and FMXAudio.Types.pas, do not carry the same CC0 source notice. They remain within the FMXAudioLib licensing question above.

### PCMAudio — HemulGM

- Upstream: [HemulGM/PCMAudio](https://github.com/HemulGM/PCMAudio).
- Included source: selected PCM backend units under Custom/AudioPlayer/Dependencies/PCMAudio/.
- License: MIT, Copyright (c) 2026 HemulGM.

The upstream license text is included at [Custom/AudioPlayer/Dependencies/PCMAudio/LICENSE](Custom/AudioPlayer/Dependencies/PCMAudio/LICENSE). Retain it with redistributed copies of PCMAudio source.

## Embarcadero FireMonkey platform source

- Related file: Fix/FMX.Platform.Win.pas.
- This is a modified Embarcadero FireMonkey Windows platform unit. It retains the Embarcadero copyright notice and the statement “All rights reserved”.
- It is **not** covered by the root FMXPixie MIT license. Use and redistribution must comply with the applicable RAD Studio license and Embarcadero distribution requirements. See [Embarcadero Software License Requirements](https://docwiki.embarcadero.com/RADStudio/Athens/en/Software_License_Requirements).

## Files shared with FMXBridge

The current main snapshots of FMXPixie and [FMXBridge](https://github.com/audiofeel/FMXBridge) were compared by Git blob SHA. The following 16 files are byte-for-byte identical in the two repositories:

- Fix/FMX.Platform.Win.pas.
- Four files under Custom/AudioPlayer/Dependencies/PCMAudio/:
  - PCM.Audio.Backend.pas
  - PCM.Audio.Factory.pas
  - PCM.Audio.Windows.MMSystem.pas
  - PCM.Audio.pas
- Eleven files under Custom/AudioPlayer/Source/:
  - FMXAudio.Audio.PCM.pas
  - FMXAudio.MP3.BitStream.pas
  - FMXAudio.MP3.Frame.pas
  - FMXAudio.MP3.Huffman.pas
  - FMXAudio.MP3.Layer3.pas
  - FMXAudio.MP3.ScaleFactors.pas
  - FMXAudio.MP3.Types.pas
  - FMXAudio.Sources.Convert.pas
  - FMXAudio.Sources.MP3.pas
  - FMXAudio.Sources.pas
  - FMXAudio.Types.pas

The same licensing conclusions therefore apply to those shared copies in both projects:

- The six minimp3-derived MP3 decoder files carry their own CC0 1.0 notice.
- The other selected FMXAudioLib source files have no explicit upstream repository license identified.
- The PCMAudio subset is MIT-licensed by HemulGM.
- The modified FMX.Platform.Win.pas remains subject to Embarcadero terms.

This comparison is limited to the checked repository snapshots; it does not assert that every similarly named component in the two projects has the same source or license.

## Components from FMXBridge that are not vendored here

The FMXPixie source tree does not contain the FMXBridge source integrations for GIFImage, DzHTMLText, FMXSVG, Skia4Delphi, or RadiantShapes. FMXPixie's HTML, SVG, Markdown, PaintBox, and TagBar functionality is provided by the Pixie engine and FMXPixie-specific wrappers described above. The absence of those FMXBridge source trees is why their notices are not copied into this file as FMXPixie dependencies.

## License for original FMXPixie code

See the root [LICENSE](LICENSE). It applies only to original code authored by audiofeel, subject to the exclusions described above. No project-level license is granted for third-party code whose license is controlled by its upstream author, or for Embarcadero platform source.
