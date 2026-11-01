; ============================================================================
; FMXPixie TagBar Demo for Inno Setup
;
; Demonstrates a native TPixieTagBar hosted on the independent FMX form:
;   - add tags in-place via the + pill
;   - select / unselect tags
;   - rename with F2 or double-click (when edit mode is enabled)
;   - dismiss individual tags
;   - show only selected tags in a filter row
;   - change tag shape, inspect colors and swatches
;   - query tag IDs/text/colors and selection from Inno Pascal Script
;   - test OnTagAdding / OnTagDeleting / OnTagChanging veto callbacks
;   - test GetCheckedCount / GetCheckedID through the selection summary
;   - configure options using TPixieTagBarOptions set values (not a bit mask)
;
; Required:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll / Modules\FMXPixie_x64.dll (rebuilt with wrapper)
;   FMXPixie_TagBar_Interface.iss
; ============================================================================

#define DemoAppName "FMXPixie - TagBar Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - TagBar Demo
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
  DEMO_FORM_WIDTH = 980;
  DEMO_FORM_HEIGHT = 760;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;

  MainTags: FPixieTagBar;
  FilterTags: FPixieTagBar;
  DisplayTags: FPixieTagBar;

  AddedCount: Integer;
  ProtectedTagID: Integer;
  TempDir: String;
  CurrentShape: TPixieTagShape;

function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:32px;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#111827;color:#e5e7eb;font-family:Segoe UI,Arial,sans-serif;font-size:14px;}' +
    '.titlebar{position:relative;width:100%;height:31px;overflow:hidden;' +
    'background:#111827;border-bottom:1px solid #263247;line-height:31px;}' +
    '.caption{margin-left:12px;color:#93c5fd;font-weight:bold;}' +
    '.subtitle{margin-left:10px;color:#64748b;font-size:12px;}' +
    '.controls{position:absolute;top:0;right:0;width:92px;height:31px;font-size:0;}' +
    '.tb{display:inline-block;vertical-align:top;width:46px;height:31px;line-height:30px;' +
    'text-align:center;color:#cbd5e1;font-size:22px;cursor:pointer;}' +
    '.tb:hover{background:#25344b;color:#fff;}.close:hover{background:#dc2626;}' +
    '</style></head><body><div class="titlebar">' +
    '<span class="caption">FMXPixie</span><span class="subtitle">/ TagBar component lab</span>' +
    '<div class="controls"><div id="title-minimize" class="tb" title="Свернуть">−</div>' +
    '<div id="title-close" class="tb close" title="Закрыть">×</div></div></div></body></html>';
end;

function BuildDemoHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;padding:0;width:100%;height:728px;overflow:hidden;}' +
    'body{position:relative;background:#0b1020;color:#e5e7eb;font-family:Segoe UI,Arial,sans-serif;font-size:13px;}' +
    '.hero{position:absolute;left:20px;top:16px;width:940px;height:76px;padding:14px 18px;' +
    'background:#111827;border:1px solid #26364c;}' +
    '.eyebrow{font-size:10px;letter-spacing:2px;color:#67e8f9;font-weight:bold;}' +
    'h1{font-size:24px;line-height:28px;margin:2px 0 1px;color:#f8fafc;}' +
    '.hero-sub{color:#94a3b8;font-size:12px;}' +
    '.label{position:absolute;left:24px;color:#93c5fd;font-size:11px;font-weight:bold;letter-spacing:1.5px;}' +
    '.surface{position:absolute;left:20px;width:940px;background:#111827;border:1px solid #26364c;}' +
    '.hint{position:absolute;left:18px;top:4px;color:#94a3b8;font-size:11px;}' +
    '.tiny{font-size:11px;color:#94a3b8;}' +
    '#main-label{top:105px;}#main-surface{top:128px;height:110px;}' +
    '#filter-label{top:248px;}#filter-surface{top:270px;height:68px;}' +
    '#tools-label{top:352px;}#tools-surface{top:376px;height:109px;}' +
    '#display-label{top:500px;}#display-surface{top:523px;height:70px;}' +
    '.tag-metric{position:absolute;right:18px;top:10px;color:#64748b;font-size:10px;}' +
    '.tools{position:absolute;left:14px;top:13px;right:14px;}' +
    '.row{height:34px;white-space:nowrap;}' +
    'button{font-family:Segoe UI,Arial,sans-serif;font-size:12px;background:#1e293b;color:#e2e8f0;' +
    'border:1px solid #3b4d66;border-radius:4px;padding:7px 11px;margin:0 5px 4px 0;cursor:pointer;}' +
    'button:hover{background:#1d4ed8;border-color:#60a5fa;color:#fff;}' +
    'button.primary{background:#164e63;border-color:#0e7490;color:#cffafe;}' +
    'button.danger:hover{background:#991b1b;border-color:#ef4444;}' +
    '.summary{position:absolute;left:18px;right:18px;top:82px;color:#a7f3d0;font-size:11px;}' +
    '#footer{position:absolute;left:24px;right:24px;top:608px;color:#64748b;font-size:11px;line-height:17px;}' +
    '#status{color:#bfdbfe;font-size:12px;margin-top:6px;}' +
    'a{color:#67e8f9;text-decoration:none;}' +
    '</style></head><body>' +
    '<div class="hero"><div class="eyebrow">NATIVE FMX CONTROL / INTERACTIVE TAGS</div>' +
    '<h1>TagBar <span style="color:#67e8f9">/</span> component lab</h1>' +
    '<div class="hero-sub">Color-coded labels, keyboard editing, selection state and filter views — hosted by FMXPixie.</div></div>' +
    '<div id="main-label" class="label">01 / EDITABLE COLLECTION</div>' +
    '<div id="main-surface" class="surface"><div class="hint">Click to select · “+” creates (type blocked to test veto) · × removes (Delphi is protected) · F2/double-click renames (try reserved).</div>' +
    '<div class="tag-metric"><span id="main-count">0</span> TAGS</div>' +
    '</div>' +
    '<div id="filter-label" class="label">02 / HORIZONTAL FILTER BAR</div>' +
    '<div id="filter-surface" class="surface"><div class="hint">Select categories, then use “Selected only” to hide unchecked categories. Scroll horizontally if needed.</div>' +
    '<div class="tag-metric"><span id="filter-count">0</span> TAGS</div></div>' +
    '<div id="tools-label" class="label">03 / CONTROL PANEL</div>' +
    '<div id="tools-surface" class="surface"><div class="tools">' +
    '<div class="row"><button id="btn-add-sample" class="primary">+ Add sample</button>' +
    '<button id="btn-select-all">Select all</button><button id="btn-uncheck-all">Clear selection</button>' +
    '<button id="btn-clear-main" class="danger">Clear collection</button><button id="btn-reset">Reset demo</button></div>' +
    '<div class="row"><button id="btn-filter-only">Selected only</button><button id="btn-filter-all">Show all categories</button>' +
    '<button id="btn-shape-pill">Pill</button><button id="btn-shape-round">Rounded</button><button id="btn-shape-rect">Rectangle</button></div>' +
    '</div><div class="summary">Main selected: <span id="main-selected">(none)</span><br>' +
    'Filter selected: <span id="filter-selected">(none)</span><br><span id="status">Ready — select a tag or try one of the controls.</span></div></div>' +
    '<div id="display-label" class="label">04 / READ-ONLY PRESENTATION</div>' +
    '<div id="display-surface" class="surface"><div class="hint">A display-only strip with color swatches. Selection and editing are disabled.</div>' +
    '<div class="tag-metric">READ ONLY</div></div>' +
    '<div id="footer">FMXPixie · TagBar demonstration · no application is installed. ' +
    'See <a href="https://gitlab.com/retrofoxed/pixie">Pixie source</a> for the component implementation.</div>' +
    '</body></html>';
end;

procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H <> 0 then Doc.SetElementText(H, S);
end;

procedure SetStatus(const S: String);
begin
  SetTextById('status', S);
  Log('FMXPixie TagBar: ' + S);
  Doc.Changed;
end;

function TagNameByID(Bar: FPixieTagBar; ID: Integer): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Bar.TagCount - 1 do
    if Bar.GetTagID(I) = ID then
    begin
      Result := Bar.GetTagText(I);
      Exit;
    end;
end;

function CheckedSummary(Bar: FPixieTagBar): String;
var
  I, ID: Integer;
  S, IDs: String;
begin
  Result := '';
  IDs := '';

  // Exercise the DLL wrappers for GetCheckedCount and GetCheckedID.
  for I := 0 to Bar.GetCheckedCount - 1 do
  begin
    ID := Bar.GetCheckedID(I);
    S := TagNameByID(Bar, ID);

    if Result <> '' then Result := Result + ' · ';
    if S <> '' then
      Result := Result + S
    else
      Result := Result + '#' + IntToStr(ID);

    if IDs <> '' then IDs := IDs + ', ';
    IDs := IDs + IntToStr(ID);
  end;

  if Result = '' then
    Result := '(none) [IDs: none]'
  else
    Result := Result + ' [IDs: ' + IDs + ']';
end;

procedure RefreshStats;
begin
  if Doc = nil then Exit;
  Doc.BeginUpdate;
  try
    SetTextById('main-count', IntToStr(MainTags.TagCount));
    SetTextById('filter-count', IntToStr(FilterTags.TagCount));
    SetTextById('main-selected', CheckedSummary(MainTags));
    SetTextById('filter-selected', CheckedSummary(FilterTags));
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure MainTagBarChanged(Sender: TObject);
begin
  RefreshStats;
end;

procedure FilterTagBarChanged(Sender: TObject);
begin
  RefreshStats;
end;

// OnTagAdding is called for tags created through the TagBar's inline '+'.
// Enter 'blocked' to verify that Allow=False cancels the operation.
procedure MainTagAdding(Sender: TObject; const Text: WideString;
  Color: TAlphaColor; var Allow: Boolean);
begin
  Allow := Lowercase(Text) <> 'blocked';

  if Allow then
    SetStatus('OnTagAdding: allowed tag "' + Text + '".')
  else
    SetStatus('OnTagAdding: vetoed tag "' + Text + '" (Allow=False).');
end;

// The first demo tag is deliberately protected from deletion by its ID.
procedure MainTagDeleting(Sender: TObject; ID: Integer;
  var Allow: Boolean);
var
  TagName: String;
begin
  TagName := TagNameByID(MainTags, ID);
  Allow := ID <> ProtectedTagID;

  if Allow then
    SetStatus('OnTagDeleting: allowed removal of "' + TagName +
      '" (ID ' + IntToStr(ID) + ').')
  else
    SetStatus('OnTagDeleting: vetoed removal of "' + TagName +
      '" (ID ' + IntToStr(ID) + ').');
end;

// Enter 'reserved' while renaming a tag to verify the change veto.
// Color changes also pass through this event and are allowed.
procedure MainTagChanging(Sender: TObject; ID: Integer;
  const NewText: WideString; NewColor: TAlphaColor;
  var Allow: Boolean);
begin
  Allow := Lowercase(NewText) <> 'reserved';

  if Allow then
    SetStatus('OnTagChanging: allowed change for ID ' +
      IntToStr(ID) + ' ("' + NewText + '").')
  else
    SetStatus('OnTagChanging: vetoed change to "' + NewText +
      '" (Allow=False).');
end;

procedure MainTagChecked(Sender: TObject; ID: Integer; Checked: Boolean);
var
  S: String;
begin
  S := TagNameByID(MainTags, ID);
  if Checked then
    SetStatus('Selected in editable collection: ' + S)
  else
    SetStatus('Unselected in editable collection: ' + S);
  RefreshStats;
end;

procedure FilterTagChecked(Sender: TObject; ID: Integer; Checked: Boolean);
var
  S: String;
begin
  S := TagNameByID(FilterTags, ID);
  if Checked then
    SetStatus('Filter category selected: ' + S)
  else
    SetStatus('Filter category cleared: ' + S);
  RefreshStats;
end;

procedure AddInitialTags;
begin
  MainTags.ClearTags;
  ProtectedTagID := MainTags.AddTagWithColor('Delphi', $FF60A5FA);
  MainTags.AddTagWithColor('FireMonkey', $FFA78BFA);
  MainTags.AddTagWithColor('Inno Setup', $FF34D399);
  MainTags.AddTagWithColor('Pixie', $FF22D3EE);
  MainTags.AddTagWithColor('HTML / CSS', $FF2DD4BF);
  MainTags.AddTagWithColor('SVG', $FFFB923C);
  MainTags.AddTagWithColor('Markdown', $FFF472B6);
  MainTags.AddTagWithColor('Windows', $FF818CF8);
  MainTags.AddTagWithColor('UI design', $FF38BDF8);
  MainTags.AddTagWithColor('Installer', $FFA3E635);
  MainTags.AddTagWithColor('Launcher', $FFFBBF24);
  MainTags.AddTagWithColor('Events', $FFFB7185);
  MainTags.AddTagWithColor('Experimental', $FF94A3B8);
  MainTags.AddTagWithColor('Native control', $FF5EEAD4);

  FilterTags.ClearTags;
  FilterTags.AddTagWithColor('Core', $FF60A5FA);
  FilterTags.AddTagWithColor('Graphics', $FFA78BFA);
  FilterTags.AddTagWithColor('Layout', $FF34D399);
  FilterTags.AddTagWithColor('Markdown', $FFF472B6);
  FilterTags.AddTagWithColor('SVG', $FFFB923C);
  FilterTags.AddTagWithColor('HTML', $FF22D3EE);
  FilterTags.AddTagWithColor('CSS', $FF2DD4BF);
  FilterTags.AddTagWithColor('Installer', $FFA3E635);
  FilterTags.AddTagWithColor('Launcher', $FFFBBF24);
  FilterTags.AddTagWithColor('Events', $FFFB7185);
  FilterTags.AddTagWithColor('Native', $FF818CF8);
  FilterTags.AddTagWithColor('Experimental', $FF94A3B8);
  FilterTags.CheckTag(FilterTags.GetTagID(0), True);
  FilterTags.CheckTag(FilterTags.GetTagID(1), True);
  FilterTags.CheckTag(FilterTags.GetTagID(3), True);

  DisplayTags.ClearTags;
  DisplayTags.AddTagWithColor('Stable', $FF34D399);
  DisplayTags.AddTagWithColor('New', $FF60A5FA);
  DisplayTags.AddTagWithColor('Recommended', $FF22D3EE);
  DisplayTags.AddTagWithColor('Experimental', $FFFBBF24);
  DisplayTags.AddTagWithColor('Deprecated', $FFFB7185);
  DisplayTags.AddTagWithColor('Built-in', $FFA78BFA);
end;

procedure ApplyTagShape(Value: TPixieTagShape);
begin
  CurrentShape := Value;
  MainTags.TagShape(Value);
  FilterTags.TagShape(Value);
  DisplayTags.TagShape(Value);
  case Value of
    tsRect: SetStatus('Tag shape changed to Rectangle.');
    tsRoundedRect: SetStatus('Tag shape changed to Rounded rectangle.');
  else
    SetStatus('Tag shape changed to Pill.');
  end;
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
  IgnoredID: Integer;
begin
  Result := False;
  if El = nil then Exit;
  H := NativeInt(El);
  Id := '';
  while H <> 0 do
  begin
    Elem.FCreate(H);
    Id := Elem.GetAttr('id', '');
    if Id <> '' then Break;
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

  if Id = 'btn-add-sample' then
  begin
    Inc(AddedCount);
    case AddedCount mod 6 of
      0: IgnoredID := MainTags.AddTagWithColor('Custom ' + IntToStr(AddedCount), $FF60A5FA);
      1: IgnoredID := MainTags.AddTagWithColor('Custom ' + IntToStr(AddedCount), $FF34D399);
      2: IgnoredID := MainTags.AddTagWithColor('Custom ' + IntToStr(AddedCount), $FFA78BFA);
      3: IgnoredID := MainTags.AddTagWithColor('Custom ' + IntToStr(AddedCount), $FFFB923C);
      4: IgnoredID := MainTags.AddTagWithColor('Custom ' + IntToStr(AddedCount), $FFF472B6);
    else
      IgnoredID := MainTags.AddTagWithColor('Custom ' + IntToStr(AddedCount), $FF22D3EE);
    end;
    RefreshStats;
    SetStatus('A sample tag was added. You can also use the + pill inside the TagBar.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-select-all' then
  begin
    MainTags.CheckAll;
    RefreshStats;
    SetStatus('All tags in the editable collection are selected.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-uncheck-all' then
  begin
    MainTags.UncheckAll;
    RefreshStats;
    SetStatus('Selection cleared in the editable collection.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-clear-main' then
  begin
    MainTags.ClearTags;
    RefreshStats;
    SetStatus('Editable collection cleared. Use + or Add sample to repopulate it.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-filter-only' then
  begin
    FilterTags.Options([tboAllowCheck]);
    RefreshStats;
    SetStatus('Filter bar now shows checked categories only.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-filter-all' then
  begin
    FilterTags.Options([tboShowAll, tboAllowCheck]);
    RefreshStats;
    SetStatus('All filter categories are visible.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-shape-pill' then
  begin
    ApplyTagShape(tsPill);
    Result := True;
    Exit;
  end;
  if Id = 'btn-shape-round' then
  begin
    ApplyTagShape(tsRoundedRect);
    Result := True;
    Exit;
  end;
  if Id = 'btn-shape-rect' then
  begin
    ApplyTagShape(tsRect);
    Result := True;
    Exit;
  end;

  if Id = 'btn-reset' then
  begin
    AddedCount := 0;
    MainTags.Options([tboShowAll, tboShowDismiss, tboAllowCheck,
      tboAllowCreate, tboAllowEdit, tboShowColorSwatch]);
    FilterTags.Options([tboShowAll, tboAllowCheck]);
    DisplayTags.Options([tboShowAll, tboReadOnly, tboShowColorSwatch]);
    MainTags.AutoHeight(True);
    MainTags.ScrollMode(smAuto);
    FilterTags.AutoHeight(False);
    FilterTags.ScrollMode(smHorizontal);
    DisplayTags.AutoHeight(False);
    DisplayTags.ScrollMode(smNone);
    ApplyTagShape(tsPill);
    AddInitialTags;
    RefreshStats;
    SetStatus('Demo reset. Try checking pills, adding a tag, changing its shape or filtering categories.');
    Result := True;
    Exit;
  end;
end;

procedure TitleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TitleView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  TitleView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  Doc := InitPixieDocument;
  Elem := InitPixieElement;
  MainTags := InitPixieTagBar;
  FilterTags := InitPixieTagBar;
  DisplayTags := InitPixieTagBar;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  TempDir := ExpandConstant('{tmp}');
  AddedCount := 0;
  CurrentShape := tsPill;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FFF3F5F8, '', True);

  TitleView.FCreate(FMXForm.Handle);
  TitleView.Left(0);
  TitleView.Top(0);
  TitleView.Width(DEMO_FORM_WIDTH);
  TitleView.Height(TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@TitleMouseDown);
  TitleView.LoadFromString(BuildTitleBarHtml);

  View.FCreate(FMXForm.Handle);
  View.Left(0);
  View.Top(TITLEBAR_HEIGHT);
  View.Width(DEMO_FORM_WIDTH);
  View.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.BaseUrl(TempDir + '\');
  View.OnElementClick(@ElementClick);
  View.LoadFromStringUrl(BuildDemoHtml, TempDir + '\');
  Doc.FCreate(View.GetDocument);

  MainTags.FCreate(FMXForm.Handle);
  MainTags.SetBounds(30, 185, 920, 82);
  MainTags.BackgroundColor($FF111827);
  MainTags.BorderColor($FF26364C);
  MainTags.ShowBorder(False);
  MainTags.FontFamily('Segoe UI');
  MainTags.FontSize(13);
  MainTags.Options([tboShowAll, tboShowDismiss, tboAllowCheck,
    tboAllowCreate, tboAllowEdit, tboShowColorSwatch]);
  MainTags.TagShape(tsPill);
  MainTags.AutoHeight(True);
  MainTags.ScrollMode(smAuto);

  FilterTags.FCreate(FMXForm.Handle);
  FilterTags.SetBounds(30, 326, 920, 44);
  FilterTags.BackgroundColor($FF111827);
  FilterTags.ShowBorder(False);
  FilterTags.FontFamily('Segoe UI');
  FilterTags.FontSize(12);
  FilterTags.Options([tboShowAll, tboAllowCheck]);
  FilterTags.TagShape(tsPill);
  FilterTags.AutoHeight(False);
  FilterTags.ScrollMode(smHorizontal);

  DisplayTags.FCreate(FMXForm.Handle);
  DisplayTags.SetBounds(30, 575, 920, 43);
  DisplayTags.BackgroundColor($FF111827);
  DisplayTags.ShowBorder(False);
  DisplayTags.FontFamily('Segoe UI');
  DisplayTags.FontSize(12);
  DisplayTags.Options([tboShowAll, tboReadOnly, tboShowColorSwatch]);
  DisplayTags.TagShape(tsPill);
  DisplayTags.AutoHeight(False);
  DisplayTags.ScrollMode(smNone);

  AddInitialTags;
  MainTags.OnTagChecked(@MainTagChecked);
  MainTags.OnChanged(@MainTagBarChanged);
  MainTags.OnTagAdding(@MainTagAdding);
  MainTags.OnTagDeleting(@MainTagDeleting);
  MainTags.OnTagChanging(@MainTagChanging);
  FilterTags.OnTagChecked(@FilterTagChecked);
  FilterTags.OnChanged(@FilterTagBarChanged);
  RefreshStats;
  SetStatus('Ready — try blocked (add veto), reserved (rename veto), or deleting Delphi (delete veto). Checked summaries show IDs.');
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
