#define DemoAppName "FMXPixie - Component Size Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
//SetupArchitecture=x64
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

var
  FMXForm: FForm;
  PixieView: FPixieHtmlView;
  Elem: FPixieElement;

  CoreSelected: Boolean;
  TexturesSelected: Boolean;
  CinematicsSelected: Boolean;
  SoundtrackSelected: Boolean;
  ArtbookSelected: Boolean;
  ModToolsSelected: Boolean;
  VoiceChoice: Integer;
  SelectionConfirmed: Boolean;

// -----------------------------------------------------------------------------
// Formatting and selection helpers
// -----------------------------------------------------------------------------
function TwoDigits(Value: Integer): String;
begin
  Result := IntToStr(Value);
  if Length(Result) < 2 then Result := '0' + Result;
end;

function HtmlEscape(const S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    case S[I] of
      '&': Result := Result + '&amp;';
      '<': Result := Result + '&lt;';
      '>': Result := Result + '&gt;';
      '"': Result := Result + '&quot;';
      '''': Result := Result + '&#39;';
    else
      Result := Result + S[I];
    end;
end;

function SizeText(SizeMB: Integer): String;
var
  Hundredths, Whole, Fraction: Integer;
begin
  if SizeMB >= 1024 then
  begin
    Hundredths := (SizeMB * 100 + 512) div 1024;
    Whole := Hundredths div 100;
    Fraction := Hundredths mod 100;
    Result := IntToStr(SizeMB) + ' MB / ' + IntToStr(Whole) + '.' + TwoDigits(Fraction) + ' GB';
  end
  else
    Result := IntToStr(SizeMB) + ' MB';
end;

procedure AddSummaryItem(var Html: String; const ItemName: String;
  SizeMB: Integer; var TotalMB, ItemCount: Integer);
begin
  Html := Html +
    '<div class="sum-row"><span class="sum-name">' + HtmlEscape(ItemName) +
    '</span><span class="sum-size">' + IntToStr(SizeMB) + ' MB</span></div>';
  TotalMB := TotalMB + SizeMB;
  ItemCount := ItemCount + 1;
end;

function CheckboxOption(const Key, Caption, Description: String;
  SizeMB: Integer; IsChecked: Boolean): String;
var
  CheckedAttr, SelectedClass: String;
begin
  CheckedAttr := '';
  SelectedClass := '';
  if IsChecked then
  begin
    CheckedAttr := ' checked';
    SelectedClass := ' selected';
  end;
  Result :=
    '<label id="opt-' + Key + '" class="option' + SelectedClass + '">' +
      '<input type="checkbox" id="chk-' + Key + '" style="display:none;"' + CheckedAttr + ' />' +
      '<span class="glyph"><span class="tick">&#10003;</span></span>' +
      '<span class="option-copy"><span class="option-name">' + Caption + '</span>' +
      '<span class="option-desc">' + Description + '</span></span>' +
      '<span class="option-size">' + IntToStr(SizeMB) + ' MB</span>' +
    '</label>';
end;

function VoiceOption(const Key, Caption, Description: String;
  SizeMB, Choice: Integer): String;
var
  CheckedAttr, SelectedClass: String;
begin
  CheckedAttr := '';
  SelectedClass := '';
  if VoiceChoice = Choice then
  begin
    CheckedAttr := ' checked';
    SelectedClass := ' selected';
  end;
  Result :=
    '<label id="opt-voice-' + Key + '" class="option voice-option' + SelectedClass + '">' +
      '<input type="radio" id="rad-voice-' + Key + '" name="voice" style="display:none;"' + CheckedAttr + ' />' +
      '<span class="glyph radio-glyph"><span class="radio-dot"></span></span>' +
      '<span class="option-copy"><span class="option-name">' + Caption + '</span>' +
      '<span class="option-desc">' + Description + '</span></span>' +
      '<span class="option-size">' + IntToStr(SizeMB) + ' MB</span>' +
    '</label>';
end;

function BuildSelectedList: String;
var
  TotalMB, ItemCount: Integer;
begin
  Result := '';
  TotalMB := 0;
  ItemCount := 0;

  if CoreSelected then
    AddSummaryItem(Result, 'Core runtime', 84, TotalMB, ItemCount);
  if TexturesSelected then
    AddSummaryItem(Result, 'HD texture pack', 620, TotalMB, ItemCount);
  if CinematicsSelected then
    AddSummaryItem(Result, 'Cinematic videos', 780, TotalMB, ItemCount);

  case VoiceChoice of
    1: AddSummaryItem(Result, 'English voice pack', 145, TotalMB, ItemCount);
    2: AddSummaryItem(Result, 'Russian voice pack', 158, TotalMB, ItemCount);
    3: AddSummaryItem(Result, 'Japanese voice pack', 212, TotalMB, ItemCount);
  end;

  if SoundtrackSelected then
    AddSummaryItem(Result, 'Original soundtrack', 96, TotalMB, ItemCount);
  if ArtbookSelected then
    AddSummaryItem(Result, 'Artbook & wallpapers', 42, TotalMB, ItemCount);
  if ModToolsSelected then
    AddSummaryItem(Result, 'Modding tools', 118, TotalMB, ItemCount);

  if ItemCount = 0 then
    Result := '<div class="empty-list">No components selected.</div>';
end;

function CalculateTotalMB: Integer;
begin
  Result := 0;
  if CoreSelected then Result := Result + 84;
  if TexturesSelected then Result := Result + 620;
  if CinematicsSelected then Result := Result + 780;

  case VoiceChoice of
    1: Result := Result + 145;
    2: Result := Result + 158;
    3: Result := Result + 212;
  end;

  if SoundtrackSelected then Result := Result + 96;
  if ArtbookSelected then Result := Result + 42;
  if ModToolsSelected then Result := Result + 118;
end;

function CountSelectedItems: Integer;
begin
  Result := 0;
  if CoreSelected then Result := Result + 1;
  if TexturesSelected then Result := Result + 1;
  if CinematicsSelected then Result := Result + 1;
  if VoiceChoice > 0 then Result := Result + 1;
  if SoundtrackSelected then Result := Result + 1;
  if ArtbookSelected then Result := Result + 1;
  if ModToolsSelected then Result := Result + 1;
end;

function BuildSummaryPanel: String;
var
  TotalMB, ItemCount: Integer;
  StatusText, StatusClass: String;
begin
  TotalMB := CalculateTotalMB;
  ItemCount := CountSelectedItems;
  if SelectionConfirmed then
  begin
    StatusText := 'SELECTION CONFIRMED';
    StatusClass := 'summary-status confirmed';
  end
  else
  begin
    StatusText := 'LIVE SIZE ESTIMATE';
    StatusClass := 'summary-status';
  end;

  Result :=
    '<div class="summary-panel panel">' +
      '<div class="summary-head"><div class="panel-kicker">INSTALL SUMMARY</div>' +
      '<div class="summary-title">Your selection</div>' +
      '<div class="summary-status-wrap"><span class="' + StatusClass + '">' + StatusText + '</span></div></div>' +
      '<div class="summary-meta"><span>SELECTED ITEMS</span><strong>' + IntToStr(ItemCount) + '</strong></div>' +
      '<div class="sum-list">' + BuildSelectedList + '</div>' +
      '<div class="total-card"><div class="total-caption">ESTIMATED INSTALL SIZE</div>' +
        '<div class="total-value">' + SizeText(TotalMB) + '</div>' +
        '<div class="total-sub">Calculated from the current selection</div></div>' +
      '<div class="summary-foot">Sizes are illustrative. This demo does not copy or install files.</div>' +
    '</div>';
end;

function BuildHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"></head><body>' +
    '<div id="demo-titlebar" class="titlebar">' +
      '<span class="title-caption">FMXPIXIE</span><span class="title-note"> / COMPONENT SIZE DEMO</span>' +
      '<div class="title-controls"><div id="title-minimize" class="title-button title-minimize" title="Minimize">−</div>' +
      '<div id="title-close" class="title-button title-close" title="Close">×</div></div>' +
    '</div>' +
    '<div class="page">' +
      '<div class="masthead"><div class="eyebrow">INSTALLER UI / LIVE SIZE CALCULATION</div>' +
        '<div class="hero-title">Choose what to install.</div>' +
        '<div class="hero-copy">Toggle components, switch the voice pack, and watch the estimated size update immediately.</div>' +
        '<div class="count-pills"><span>HTML SPAN CONTROLS</span><span>PASCAL SCRIPT STATE</span><span>LIVE TOTAL</span></div>' +
      '</div>' +
      '<div class="columns">' +
        '<div class="left-column"><div class="panel selection-panel">' +
          '<div class="panel-kicker">OPTIONAL CONTENT</div><div class="panel-title">Components & extras</div>' +
          '<div class="section-title">CORE / CONTENT</div><div class="option-grid">' +
            CheckboxOption('core', 'Core runtime', 'Required base files', 84, CoreSelected) +
            CheckboxOption('textures', 'HD texture pack', 'Higher quality assets', 620, TexturesSelected) +
            CheckboxOption('cinematics', 'Cinematic videos', 'Full-motion sequences', 780, CinematicsSelected) +
          '</div>' +
          '<div class="section-title">VOICE / LANGUAGE</div><div class="option-grid">' +
            VoiceOption('en', 'English voice', 'Original dialogue', 145, 1) +
            VoiceOption('ru', 'Russian voice', 'Localized dialogue', 158, 2) +
            VoiceOption('jp', 'Japanese voice', 'Alternate voice-over', 212, 3) +
          '</div>' +
          '<div class="section-title">EXTRAS / TOOLS</div><div class="option-grid">' +
            CheckboxOption('soundtrack', 'Original soundtrack', 'Music files', 96, SoundtrackSelected) +
            CheckboxOption('artbook', 'Artbook & wallpapers', 'Digital bonus pack', 42, ArtbookSelected) +
            CheckboxOption('modtools', 'Modding tools', 'Tools for custom content', 118, ModToolsSelected) +
          '</div>' +
          '<div class="selection-note"><span class="note-dot"></span>Click any option to recalculate the total. Voice packs are mutually exclusive.</div>' +
        '</div></div>' +
        '<div class="right-column">' + BuildSummaryPanel +
          '<div class="tip-card"><div class="tip-mark">i</div><div class="tip-title">How it works</div>' +
            '<div class="tip-copy">OnElementClick updates the script-side state. The summary is rebuilt from the selected options, so checking twice cannot accidentally double-add a size.</div>' +
          '</div>' +
        '</div>' +
      '</div>' +
      '<div class="action-row"><div class="action-note">Changes are simulated; nothing is installed.</div>' +
        '<div id="btn-reset" class="button secondary">Reset</div>' +
        '<div id="btn-confirm" class="button primary">Confirm selection &#8594;</div></div>' +
      '<div class="footer-note">FMXPixie / Pixie HTML renderer / component selection and size calculation test</div>' +
    '</div></body></html>';
end;

function BuildCss: String;
begin
  Result :=
    '*{box-sizing:border-box;user-select:none;-webkit-user-select:none;}' + #13#10 +
    'html,body{margin:0;padding:0;width:100%;height:100%;background:#0a1019;color:#e7eef8;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;overflow:hidden;}' + #13#10 +
    '.titlebar{position:fixed;top:0;left:0;right:0;height:32px;line-height:31px;background:#111a27;border-bottom:1px solid #293b50;color:#e7eef8;z-index:999;}' + #13#10 +
    '.title-caption{margin-left:14px;color:#60dfce;font-size:11px;font-weight:bold;letter-spacing:1.2px;}' + #13#10 +
    '.title-note{margin-left:8px;color:#8498b0;font-size:9px;letter-spacing:.6px;}' + #13#10 +
    '.title-controls{position:absolute;top:0;right:0;width:88px;height:31px;font-size:0;}' + #13#10 +
    '.title-button{display:inline-block;vertical-align:top;width:44px;height:31px;line-height:31px;text-align:center;color:#d1dbe7;cursor:pointer;font-size:16px;}' + #13#10 +
    '.title-minimize:hover{background:#25344b;color:#fff;}.title-close:hover{background:#dc3545;color:#fff;}' + #13#10 +
    '.page{display:block;padding:45px 16px 12px;}' + #13#10 +
    '.masthead{padding:3px 3px 12px;border-bottom:1px solid #263548;margin-bottom:13px;}' + #13#10 +
    '.eyebrow{color:#60dfce;font-size:9px;font-weight:bold;letter-spacing:1.4px;margin-bottom:5px;}' + #13#10 +
    '.hero-title{color:#f5f8fc;font-size:24px;font-weight:bold;margin-bottom:4px;}' + #13#10 +
    '.hero-copy{color:#99abc1;font-size:11px;margin-bottom:9px;}' + #13#10 +
    '.count-pills span{display:inline-block;background:#152233;border:1px solid #2d4259;color:#a8bbd1;padding:4px 7px;margin:0 5px 0 0;font-size:8px;letter-spacing:.5px;}' + #13#10 +
    '.columns{display:block;white-space:nowrap;}' + #13#10 +
    '.left-column{display:inline-block;vertical-align:top;white-space:normal;width:65.2%;margin-right:1.2%;}' + #13#10 +
    '.right-column{display:inline-block;vertical-align:top;white-space:normal;width:32.4%;}' + #13#10 +
    '.panel{display:block;padding:13px;background:#111a27;border:1px solid #293b50;border-radius:10px;}' + #13#10 +
    '.panel-kicker{color:#60dfce;font-size:8px;font-weight:bold;letter-spacing:1.4px;margin-bottom:4px;}' + #13#10 +
    '.panel-title{color:#f1f5fb;font-size:14px;font-weight:bold;margin-bottom:4px;}' + #13#10 +
    '.section-title{display:block;color:#7ca7b8;font-size:8px;font-weight:bold;letter-spacing:1.3px;margin:13px 0 5px;padding-top:8px;border-top:1px solid #26384b;}' + #13#10 +
    '.option-grid{display:block;font-size:0;}' + #13#10 +
    '.option{position:relative;display:inline-block;vertical-align:top;width:49%;height:46px;line-height:normal;margin:0 1% 4px 0;padding:7px 8px 5px 32px;background:#131f2e;border:1px solid #1e3044;border-radius:6px;color:#bdcad9;cursor:pointer;overflow:hidden;}' + #13#10 +
    '.option:hover{background:#1a2a3d;border-color:#3f5872;color:#fff;}' + #13#10 +
    '.glyph{position:absolute;left:9px;top:14px;width:14px;height:14px;line-height:12px;text-align:center;border:1px solid #4b6078;border-radius:3px;background:#0d1723;}' + #13#10 +
    '.tick{color:transparent;font-size:10px;font-weight:bold;}' + #13#10 +
    '.option-copy{display:block;padding-right:46px;}' + #13#10 +
    '.option-name{display:block;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;color:#e1e9f3;font-size:10px;font-weight:bold;margin-bottom:4px;}' + #13#10 +
    '.option-desc{display:block;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;color:#7f93aa;font-size:8px;}' + #13#10 +
    '.option-size{position:absolute;right:7px;top:16px;color:#8ba1b9;font-size:9px;font-weight:bold;white-space:nowrap;}' + #13#10 +
    '.option.selected{background:#14302f;border-color:#317f78;}' + #13#10 +
    '.option.selected .glyph{background:#60dfce;border-color:#60dfce;}' + #13#10 +
    '.option.selected .tick{color:#091b1a;}' + #13#10 +
    '.option.selected .option-name{color:#f3fffd;}' + #13#10 +
    '.option.selected .option-size{color:#8ce9dc;}' + #13#10 +
    '.radio-glyph{border-radius:50%;background:#0d1723;}' + #13#10 +
    '.radio-dot{position:absolute;left:3px;top:3px;width:6px;height:6px;border-radius:50%;background:transparent;}' + #13#10 +
    '.voice-option.selected{background:#30271a;border-color:#a97938;}' + #13#10 +
    '.voice-option.selected .glyph{background:#30271a;border-color:#ffc36d;}' + #13#10 +
    '.voice-option.selected .radio-dot{background:#ffc36d;}' + #13#10 +
    '.voice-option.selected .option-name{color:#fff8eb;}' + #13#10 +
    '.voice-option.selected .option-size{color:#ffc36d;}' + #13#10 +
    '.selection-note{margin-top:8px;padding-top:10px;border-top:1px solid #26384b;color:#7f93aa;font-size:9px;line-height:14px;}' + #13#10 +
    '.note-dot{display:inline-block;width:6px;height:6px;border-radius:50%;background:#60dfce;margin:0 6px 1px 0;}' + #13#10 +
    '.summary-panel{padding:14px;}' + #13#10 +
    '.summary-head{position:relative;padding-bottom:12px;border-bottom:1px solid #26384b;}' + #13#10 +
    '.summary-title{color:#f4f7fb;font-size:19px;font-weight:bold;margin-top:2px;}' + #13#10 +
    '.summary-status-wrap{margin-top:8px;}' + #13#10 +
    '.summary-status{display:inline-block;padding:4px 7px;background:#15312f;border:1px solid #2b605b;border-radius:4px;color:#69dfcb;font-size:8px;font-weight:bold;letter-spacing:.7px;}' + #13#10 +
    '.summary-status.confirmed{background:#25351f;border-color:#607849;color:#c5ed8c;}' + #13#10 +
    '.summary-meta{padding:12px 0 7px;color:#71869d;font-size:8px;font-weight:bold;letter-spacing:1px;}' + #13#10 +
    '.summary-meta strong{float:right;color:#dce6f1;font-size:10px;letter-spacing:0;}' + #13#10 +
    '.sum-list{display:block;min-height:70px;}' + #13#10 +
    '.sum-row{display:block;height:25px;line-height:25px;border-bottom:1px solid #1e2d40;white-space:nowrap;}' + #13#10 +
    '.sum-name{display:inline-block;width:72%;overflow:hidden;text-overflow:ellipsis;vertical-align:middle;color:#b9c8d8;font-size:9px;}' + #13#10 +
    '.sum-size{display:inline-block;width:27%;text-align:right;vertical-align:middle;color:#87a4b8;font-size:9px;font-weight:bold;}' + #13#10 +
    '.empty-list{padding:17px 0;color:#7f93aa;font-size:10px;}' + #13#10 +
    '.total-card{margin-top:12px;padding:13px;background:#0d2026;border:1px solid #28514f;border-radius:8px;}' + #13#10 +
    '.total-caption{color:#70bdb3;font-size:8px;font-weight:bold;letter-spacing:1.2px;margin-bottom:7px;}' + #13#10 +
    '.total-value{color:#91f0de;font-size:23px;line-height:28px;font-weight:bold;white-space:nowrap;}' + #13#10 +
    '.total-sub{color:#648f91;font-size:8px;margin-top:5px;}' + #13#10 +
    '.summary-foot{color:#72869c;font-size:8px;line-height:13px;margin-top:12px;}' + #13#10 +
    '.tip-card{position:relative;margin-top:10px;padding:12px 12px 12px 37px;background:#111a27;border:1px solid #293b50;border-radius:8px;}' + #13#10 +
    '.tip-mark{position:absolute;left:12px;top:12px;width:16px;height:16px;border-radius:50%;background:#1c3c4b;color:#78d8ce;text-align:center;line-height:16px;font-size:10px;font-weight:bold;}' + #13#10 +
    '.tip-title{color:#dce6f1;font-size:10px;font-weight:bold;margin-bottom:5px;}' + #13#10 +
    '.tip-copy{color:#8296ad;font-size:9px;line-height:14px;}' + #13#10 +
    '.action-row{display:block;position:relative;height:42px;margin-top:10px;padding-top:10px;border-top:1px solid #263548;white-space:nowrap;}' + #13#10 +
    '.action-note{display:inline-block;vertical-align:middle;width:61%;color:#687f96;font-size:9px;line-height:30px;}' + #13#10 +
    '.button{display:inline-block;vertical-align:middle;height:30px;line-height:28px;padding:0 13px;margin-left:7px;border:1px solid #34475e;border-radius:5px;background:#172538;color:#cbd8e7;font-size:9px;font-weight:bold;text-align:center;cursor:pointer;}' + #13#10 +
    '.button:hover{background:#263b52;border-color:#55728e;color:#fff;}' + #13#10 +
    '.button.primary{background:#60dfce;border-color:#60dfce;color:#092321;}' + #13#10 +
    '.button.primary:hover{background:#8ce9dc;border-color:#8ce9dc;color:#092321;}' + #13#10 +
    '.footer-note{color:#5f738a;font-size:8px;margin:7px 3px 0;}' + #13#10;
end;

procedure RenderPage;
begin
  PixieView.LoadFromString(BuildHtml);
end;

procedure ResetSelection;
begin
  CoreSelected := True;
  TexturesSelected := False;
  CinematicsSelected := False;
  VoiceChoice := 1;
  SoundtrackSelected := False;
  ArtbookSelected := False;
  ModToolsSelected := False;
  SelectionConfirmed := False;
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
  if El = nil then Exit;

  H := NativeInt(El);
  Id := '';
  while H <> 0 do
  begin
    Elem.FCreate(H);
    Id := Elem.GetAttr('id', '');
    if (Id <> '') and (Copy(Id, 1, 4) <> 'chk-') and
       (Copy(Id, 1, 10) <> 'rad-voice-') then Break;
    H := Elem.Parent;
  end;
  if H = 0 then Exit;

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

  if Id = 'opt-core' then CoreSelected := not CoreSelected
  else if Id = 'opt-textures' then TexturesSelected := not TexturesSelected
  else if Id = 'opt-cinematics' then CinematicsSelected := not CinematicsSelected
  else if Id = 'opt-voice-en' then VoiceChoice := 1
  else if Id = 'opt-voice-ru' then VoiceChoice := 2
  else if Id = 'opt-voice-jp' then VoiceChoice := 3
  else if Id = 'opt-soundtrack' then SoundtrackSelected := not SoundtrackSelected
  else if Id = 'opt-artbook' then ArtbookSelected := not ArtbookSelected
  else if Id = 'opt-modtools' then ModToolsSelected := not ModToolsSelected
  else if Id = 'btn-reset' then
  begin
    ResetSelection;
    RenderPage;
    Result := True;
    Exit;
  end
  else if Id = 'btn-confirm' then
  begin
    SelectionConfirmed := True;
    Log('FMXPixie Component Size Demo: selection confirmed; total=' + IntToStr(CalculateTotalMB) + ' MB.');
    RenderPage;
    Result := True;
    Exit;
  end
  else
    Exit;

  SelectionConfirmed := False;
  Log('FMXPixie Component Size Demo: ' + IntToStr(CalculateTotalMB) + ' MB selected.');
  RenderPage;
  Result := True;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < PixieView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

function InitializeSetup(): Boolean;
begin
  FMXForm := InitFormHandle;
  PixieView := InitPixieHtmlView;
  Elem := InitPixieElement;
  Result := True;
end;

procedure InitializeWizard;
begin
  ResetSelection;
  EmptyWizardForm(DEMO_WIDTH, DEMO_HEIGHT);

  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF0A1019, '', True);
  FMXForm.Caption('FMXPixie / Component Size Demo');

  PixieView.FCreate(FMXForm.Handle);
  PixieView.Align(Client);
  PixieView.ColorScheme(pcsDark);
  PixieView.OnElementClick(@ElementClick);
  PixieView.OnMouseDown(@ViewMouseDown);
  PixieView.UserCss(BuildCss);
  RenderPage;

  FMXForm.Show;
end;

procedure DeinitializeSetup;
begin
  FMXPixieShutDown;
end;
