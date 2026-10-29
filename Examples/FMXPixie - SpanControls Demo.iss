; ============================================================================
; FMXPixie Span Controls Demo
; 64 custom span-based checkboxes and 16 custom span-based radio options.
;
; All visible glyphs are ordinary HTML <span> elements styled by CSS.
; Hidden HTML inputs provide state. No native FMX check/radio controls and
; no JavaScript are used. Checkbox labels switch OFF/ON text and styling.
; Radio groups switch SELECT/ACTIVE text and update a configuration summary.
;
; Place this ISS file in the project root next to Modules\FMXPixieHandle.iss
; and Modules\FMXPixie_x64.dll / Modules\FMXPixie_x86.dll.
; ============================================================================

#define DemoAppName "FMXPixie - Span Controls Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie -SpanControls Demo
; SetupArchitecture=x64
SetupIconFile=Files\setup.ico

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
  Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
  Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  DEMO_WIDTH = 1120;
  DEMO_HEIGHT = 760;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 88;
  CHECK_COUNT = 64;
  RADIO_GROUP_COUNT = 4;
  RADIO_CHOICE_COUNT = 4;

var
  FMXForm: FForm;
  PixieView: FPixieHtmlView;
  Elem: FPixieElement;

function TwoDigits(Value: Integer): String;
begin
  Result := IntToStr(Value);
  if Length(Result) < 2 then Result := '0' + Result;
end;

function ComponentName(Index: Integer): String;
begin
  case Index of
    1: Result := 'Core runtime';
    2: Result := 'Command-line tools';
    3: Result := 'Runtime libraries';
    4: Result := 'Project templates';
    5: Result := 'SDK headers';
    6: Result := 'Language resources';
    7: Result := 'Compatibility layer';
    8: Result := 'Diagnostics tools';
    9: Result := 'Crash report support';
    10: Result := 'Offline documentation';
    11: Result := 'Sample projects';
    12: Result := 'Developer symbols';
    13: Result := 'Resource compiler';
    14: Result := 'Build utilities';
    15: Result := 'Package manager';
    16: Result := 'License files';
    17: Result := 'Dark interface';
    18: Result := 'Light interface';
    19: Result := 'High-contrast mode';
    20: Result := 'Compact spacing';
    21: Result := 'Large text';
    22: Result := 'Reduced motion';
    23: Result := 'Rounded panels';
    24: Result := 'Custom title bar';
    25: Result := 'Window animations';
    26: Result := 'Accent color pack';
    27: Result := 'Icon theme pack';
    28: Result := 'Syntax colors';
    29: Result := 'Status indicators';
    30: Result := 'Progress overlays';
    31: Result := 'Keyboard shortcuts';
    32: Result := 'Touch spacing';
    33: Result := 'SVG icon library';
    34: Result := 'PNG asset pack';
    35: Result := 'WebP image support';
    36: Result := 'GIF animation support';
    37: Result := 'HTML snippets';
    38: Result := 'CSS templates';
    39: Result := 'Markdown renderer';
    40: Result := 'PDF export support';
    41: Result := 'Image preview tools';
    42: Result := 'Media helpers';
    43: Result := 'Example layouts';
    44: Result := 'Form templates';
    45: Result := 'Notification sounds';
    46: Result := 'Localization pack';
    47: Result := 'Typography pack';
    48: Result := 'Background textures';
    49: Result := 'Unit test samples';
    50: Result := 'Performance logger';
    51: Result := 'Layout inspector';
    52: Result := 'DOM inspector';
    53: Result := 'CSS selector trace';
    54: Result := 'Resource validator';
    55: Result := 'Build report';
    56: Result := 'Debug console';
    57: Result := 'Export diagnostics';
    58: Result := 'Memory snapshot';
    59: Result := 'Benchmark tools';
    60: Result := 'Theme validator';
    61: Result := 'Accessibility checks';
    62: Result := 'Install log';
    63: Result := 'Update checker';
    64: Result := 'Recovery utilities';
  else Result := 'Component ' + IntToStr(Index);
  end;
end;

function RadioGroupKey(GroupIndex: Integer): String;
begin
  case GroupIndex of
    1: Result := 'profile';
    2: Result := 'theme';
    3: Result := 'channel';
    4: Result := 'scope';
  else Result := 'group';
  end;
end;

function RadioGroupTitle(GroupIndex: Integer): String;
begin
  case GroupIndex of
    1: Result := 'INSTALL PROFILE';
    2: Result := 'APPEARANCE';
    3: Result := 'UPDATE CHANNEL';
    4: Result := 'INSTALL SCOPE';
  else Result := 'OPTIONS';
  end;
end;

function RadioOptionName(GroupIndex, ChoiceIndex: Integer): String;
begin
  case GroupIndex of
    1: case ChoiceIndex of
      1: Result := 'Minimal';
      2: Result := 'Recommended';
      3: Result := 'Complete';
      4: Result := 'Portable';
    else Result := 'Option';
    end;
    2: case ChoiceIndex of
      1: Result := 'Midnight';
      2: Result := 'Graphite';
      3: Result := 'Light';
      4: Result := 'High contrast';
    else Result := 'Option';
    end;
    3: case ChoiceIndex of
      1: Result := 'Stable';
      2: Result := 'Preview';
      3: Result := 'Beta';
      4: Result := 'Nightly';
    else Result := 'Option';
    end;
    4: case ChoiceIndex of
      1: Result := 'Current user';
      2: Result := 'All users';
      3: Result := 'Portable folder';
      4: Result := 'Developer setup';
    else Result := 'Option';
    end;
  else Result := 'Option';
  end;
end;

function RadioOptionDescription(GroupIndex, ChoiceIndex: Integer): String;
begin
  case GroupIndex of
    1: case ChoiceIndex of
      1: Result := 'Core runtime and required files only.';
      2: Result := 'A balanced set for everyday use.';
      3: Result := 'All optional packages and developer tools.';
      4: Result := 'A self-contained portable-style layout.';
    else Result := 'Choose an option.';
    end;
    2: case ChoiceIndex of
      1: Result := 'Dark surfaces with a teal accent.';
      2: Result := 'Neutral dark surfaces and muted accents.';
      3: Result := 'Bright surfaces with darker text.';
      4: Result := 'Stronger contrast for interface elements.';
    else Result := 'Choose an option.';
    end;
    3: case ChoiceIndex of
      1: Result := 'Only releases marked stable.';
      2: Result := 'Early access to upcoming changes.';
      3: Result := 'Preview builds intended for wider testing.';
      4: Result := 'Frequent development snapshots.';
    else Result := 'Choose an option.';
    end;
    4: case ChoiceIndex of
      1: Result := 'Install preferences for this user.';
      2: Result := 'Use a shared machine-wide configuration.';
      3: Result := 'Keep settings beside the application.';
      4: Result := 'Include tools for a development workstation.';
    else Result := 'Choose an option.';
    end;
  else Result := 'Choose an option.';
  end;
end;

function BuildCheckboxes: String;
var
  I: Integer;
  Id: String;
  Heading: String;
begin
  Result := '';
  for I := 1 to CHECK_COUNT do
  begin
    Heading := '';
    if I = 1 then Heading := 'RUNTIME / CORE'
    else if I = 17 then Heading := 'INTERFACE / EXPERIENCE'
    else if I = 33 then Heading := 'CONTENT / MEDIA'
    else if I = 49 then Heading := 'DEVELOPER / DIAGNOSTICS';

    if Heading <> '' then
      Result := Result + '<div class="section-title">' + Heading + '</div>' + #13#10;

    Id := 'chk_' + TwoDigits(I);
    Result := Result + '<input type="checkbox" id="' + Id + '" style="display:none;" />' + #13#10;
    Result := Result + '<label class="check-option" for="' + Id + '">' +
      '<span class="check-glyph"><span class="check-tick">&#10003;</span></span>' +
      '<span class="option-name">' + ComponentName(I) + '</span>' +
      '<span class="option-state"><span class="state-off">OFF</span><span class="state-on">ON</span></span>' +
      '</label>' + #13#10;
  end;
end;

function BuildComponentPanel: String;
begin
  Result := '<div class="panel component-panel">' +
    '<div class="panel-title">COMPONENT SELECTION</div>' +
    '<div class="panel-subtitle">64 independent toggles / click any combination</div>' +
    BuildCheckboxes +
    '<div class="component-note">Each option changes its custom glyph, background, and OFF/ON text. The visible controls are made from HTML spans - not native FMX controls.</div>' +
    '</div>';
end;

function BuildRadioGroup(GroupIndex: Integer): String;
var
  I: Integer;
  Key: String;
  Id: String;
  DefaultChoice: Integer;
begin
  Key := RadioGroupKey(GroupIndex);
  if GroupIndex = 1 then DefaultChoice := 2 else DefaultChoice := 1;
  Result := '<div class="panel radio-panel">' +
    '<div class="panel-title">' + RadioGroupTitle(GroupIndex) + '</div>';

  for I := 1 to RADIO_CHOICE_COUNT do
  begin
    Id := 'rad_' + Key + '_' + TwoDigits(I);
    Result := Result + '<input type="radio" id="' + Id + '" name="' + Key + '" style="display:none;"';
    if I = DefaultChoice then Result := Result + ' checked';
    Result := Result + ' />' + #13#10;
    Result := Result + '<label class="radio-option" for="' + Id + '">' +
      '<span class="radio-glyph"><span class="radio-dot"></span></span>' +
      '<span class="radio-name">' + RadioOptionName(GroupIndex, I) + '</span>' +
      '<span class="option-state"><span class="state-off">SELECT</span><span class="state-on">ACTIVE</span></span>' +
      '</label>' + #13#10;
  end;

  Result := Result + '<div class="radio-result">';
  for I := 1 to RADIO_CHOICE_COUNT do
    Result := Result + '<div class="radio-result-choice result-' + Key + '-' + TwoDigits(I) + '">' +
      '<span class="result-kicker">CURRENT VALUE</span>' +
      '<span class="result-name">' + RadioOptionName(GroupIndex, I) + '</span>' +
      '<span class="result-description">' + RadioOptionDescription(GroupIndex, I) + '</span>' +
      '</div>';
  Result := Result + '</div></div>';
end;

function BuildHtml: String;
begin
  Result := '<html><head><meta charset="utf-8"></head><body>' +
    '<div id="demo-titlebar" class="titlebar">' +
    '<span class="title-caption">FMXPIXIE</span>' +
    '<span class="title-note"> / SPAN CONTROLS DEMO</span>' +
    '<div class="title-controls">' +
    '<div id="title-minimize" class="title-button title-minimize" title="Minimize">−</div>' +
    '<div id="title-close" class="title-button title-close" title="Close">×</div>' +
    '</div></div>' +
    '<div class="page">' +
    '<div class="masthead"><div class="eyebrow">FMXPIXIE / INTERACTION EXAMPLE</div>' +
    '<div class="hero-title">Span-based custom controls</div>' +
    '<div class="hero-copy">80 interactive options, built from HTML inputs and ordinary span elements. No JavaScript and no native FMX checkboxes or radio buttons.</div>' +
    '<div class="count-pills"><span>64 CHECKBOXES</span><span>16 RADIO OPTIONS</span><span>CSS-DRIVEN STATE</span></div></div>' +
    '<div class="columns"><div class="left-column">' + BuildComponentPanel + '</div>' +
    '<div class="right-column">' + BuildRadioGroup(1) + BuildRadioGroup(2) + BuildRadioGroup(3) + BuildRadioGroup(4) + '</div></div>' +
    '<div class="footer-note">FMXPixie / PIXIE HTML renderer / interactive custom-control demo</div>' +
    '</div></body></html>';
end;

function BuildCss: String;
var
  G, I: Integer;
  Key: String;
begin
  Result := 'html, body { margin:0; padding:0; background:#0a1019; color:#e7eef8; font-family:"Segoe UI"; font-size:12px; }' + #13#10 +
    'body { padding:0; }' + #13#10 +
    '.titlebar { position:fixed; top:0; left:0; right:0; height:32px; line-height:31px; background:#111a27; border-bottom:1px solid #293b50; color:#e7eef8; z-index:999; }' + #13#10 +
    '.title-caption { margin-left:14px; color:#60dfce; font-size:11px; font-weight:bold; letter-spacing:1.2px; }' + #13#10 +
    '.title-note { margin-left:8px; color:#8498b0; font-size:9px; letter-spacing:.6px; }' + #13#10 +
    '.title-controls { position:absolute; top:0; right:0; width:88px; height:31px; font-size:0; }' + #13#10 +
    '.title-button { display:inline-block; vertical-align:top; width:44px; height:31px; line-height:31px; text-align:center; color:#d1dbe7; cursor:pointer; font-size:16px; }' + #13#10 +
    '.title-minimize:hover { background:#25344b; color:#ffffff; }' + #13#10 +
    '.title-close:hover { background:#dc3545; color:#ffffff; }' + #13#10 +
    '.page { display:block; padding:46px 14px 14px; }' + #13#10 +
    '.masthead { padding:8px 4px 16px 4px; border-bottom:1px solid #263548; margin-bottom:14px; }' + #13#10 +
    '.eyebrow { color:#60dfce; font-size:10px; font-weight:bold; letter-spacing:1.4px; margin-bottom:7px; }' + #13#10 +
    '.hero-title { color:#f5f8fc; font-size:25px; font-weight:bold; margin-bottom:6px; }' + #13#10 +
    '.hero-copy { color:#99abc1; font-size:12px; margin-bottom:10px; }' + #13#10 +
    '.count-pills span { display:inline-block; background:#152233; border:1px solid #2d4259; color:#a8bbd1; padding:4px 7px; margin:0 5px 0 0; font-size:9px; }' + #13#10 +
    '.columns { display:block; }' + #13#10 +
    '.left-column { display:inline-block; vertical-align:top; width:59%; margin-right:1.3%; }' + #13#10 +
    '.right-column { display:inline-block; vertical-align:top; width:38%; }' + #13#10 +
    '.panel { display:block; padding:13px; margin-bottom:12px; background:#111a27; border:1px solid #293b50; border-radius:10px; }' + #13#10 +
    '.panel-title { color:#f1f5fb; font-size:13px; font-weight:bold; margin-bottom:4px; }' + #13#10 +
    '.panel-subtitle { color:#8498b0; font-size:10px; margin-bottom:12px; }' + #13#10 +
    '.section-title { display:block; color:#60dfce; font-size:9px; font-weight:bold; letter-spacing:1.2px; margin:14px 0 5px 0; padding-top:7px; border-top:1px solid #26384b; }' + #13#10 +
    '.section-title:first-of-type { margin-top:6px; border-top:0; padding-top:0; }' + #13#10 +
    '.check-option { display:inline-block; vertical-align:middle; width:48%; height:25px; line-height:25px; margin:1px 1% 1px 0; padding:0 4px; color:#b9c7d8; background:#131f2e; border:1px solid #1e3044; border-radius:4px; white-space:nowrap; cursor:pointer; }' + #13#10 +
    '.check-option:hover, .radio-option:hover { background:#1a2a3d; color:#ffffff; border-color:#3f5872; }' + #13#10 +
    '.check-glyph { display:inline-block; vertical-align:middle; width:14px; height:14px; line-height:13px; text-align:center; margin-right:7px; border:1px solid #4b6078; border-radius:3px; background:#0d1723; }' + #13#10 +
    '.check-tick { color:transparent; font-size:11px; font-weight:bold; }' + #13#10 +
    '.option-name { display:inline-block; vertical-align:middle; width:68%; overflow:hidden; }' + #13#10 +
    '.option-state { display:inline-block; vertical-align:middle; color:#637992; font-size:8px; font-weight:bold; text-align:right; }' + #13#10 +
    '.state-on { display:none; color:#60dfce; }' + #13#10 +
    'input:checked + label.check-option { color:#f3fffd; background:#14302f; border-color:#317f78; }' + #13#10 +
    'input:checked + label.check-option .check-glyph { background:#60dfce; border-color:#60dfce; }' + #13#10 +
    'input:checked + label.check-option .check-tick { color:#091b1a; }' + #13#10 +
    'input:checked + label.check-option .state-off { display:none; }' + #13#10 +
    'input:checked + label.check-option .state-on { display:inline-block; }' + #13#10 +
    '.component-note { color:#8296ad; font-size:10px; line-height:16px; border-top:1px solid #26384b; padding-top:10px; margin-top:12px; }' + #13#10 +
    '.radio-panel { padding:12px; }' + #13#10 +
    '.radio-panel .panel-title { margin-bottom:10px; }' + #13#10 +
    '.radio-option { display:inline-block; vertical-align:middle; width:47%; height:31px; line-height:31px; margin:1px 1% 2px 0; padding:0 4px; color:#b9c7d8; background:#131f2e; border:1px solid #1e3044; border-radius:4px; white-space:nowrap; cursor:pointer; }' + #13#10 +
    '.radio-glyph { display:inline-block; position:relative; vertical-align:middle; width:14px; height:14px; margin-right:6px; border:1px solid #4b6078; border-radius:50%; background:#0d1723; }' + #13#10 +
    '.radio-dot { display:block; position:absolute; left:4px; top:4px; width:6px; height:6px; margin:0; border-radius:50%; background:transparent; }' + #13#10 +
    '.radio-name { display:inline-block; vertical-align:middle; width:60%; overflow:hidden; }' + #13#10 +
    'input:checked + label.radio-option { color:#fff9ee; background:#30271a; border-color:#a97938; }' + #13#10 +
    'input:checked + label.radio-option .radio-glyph { border-color:#ffc36d; }' + #13#10 +
    'input:checked + label.radio-option .radio-dot { background:#ffc36d; }' + #13#10 +
    'input:checked + label.radio-option .state-off { display:none; }' + #13#10 +
    'input:checked + label.radio-option .state-on { display:inline-block; color:#ffc36d; }' + #13#10 +
    '.radio-result { margin-top:9px; padding:9px 10px; background:#0d1723; border:1px solid #2a3b50; border-radius:6px; min-height:51px; }' + #13#10 +
    '.radio-result-choice { display:none; }' + #13#10 +
    '.result-kicker { display:block; color:#72869e; font-size:8px; font-weight:bold; letter-spacing:1px; margin-bottom:3px; }' + #13#10 +
    '.result-name { display:block; color:#ffc36d; font-size:12px; font-weight:bold; margin-bottom:2px; }' + #13#10 +
    '.result-description { display:block; color:#9aacc0; font-size:10px; }' + #13#10 +
    '.footer-note { color:#5f738a; font-size:9px; margin:6px 3px 16px 3px; }' + #13#10;

  for G := 1 to RADIO_GROUP_COUNT do
  begin
    Key := RadioGroupKey(G);
    for I := 1 to RADIO_CHOICE_COUNT do
      Result := Result + '#rad_' + Key + '_' + TwoDigits(I) + ':checked ~ .radio-result .result-' + Key + '-' + TwoDigits(I) + ' { display:block; }' + #13#10;
  end;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  PixieView := InitPixieHtmlView;
  Elem := InitPixieElement;
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
begin
  Result := False;
  if El = nil then
    Exit;

  H := NativeInt(El);
  Id := '';
  while H <> 0 do
  begin
    Elem.FCreate(H);
    Id := Elem.GetAttr('id', '');
    if Id <> '' then
      Break;
    H := Elem.Parent;
  end;
  if H = 0 then
    Exit;

  if Id = 'title-minimize' then
  begin
    FMXForm.Minimize;
    Result := True;
    Exit;
  end;

  if Id = 'title-close' then
  begin
    CloseSetup;
    Result := True;
    Exit;
  end;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < PixieView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard();
begin
  EmptyWizardForm(DEMO_WIDTH, DEMO_HEIGHT);

  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF101827, '', True);

  PixieView.FCreate(FMXForm.Handle);
  PixieView.Align(Client);
  PixieView.ColorScheme(pcsDark);
  PixieView.OnElementClick(@ElementClick);
  PixieView.OnMouseDown(@ViewMouseDown);
  PixieView.UserCss(BuildCss);
  PixieView.LoadFromString(BuildHtml);

  FMXForm.Show;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := False;
end;

procedure DeinitializeSetup;
begin
  FMXPixieShutDown;
end;
