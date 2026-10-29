; ============================================================================
; FMXPixie PaintBox Demo / API Test
;
; One interactive demo and test for the native FMX TPixiePaintBox wrapper:
;   - HTML pseudo-titlebar with minimize / close
;   - draw primitives, text, text measurement, pen / brush / font state
;   - FillBackground / BackgroundColor
;   - Repaint, Visible, Opacity, Enabled, HitTest, z-order
;   - geometry and object handle queries
;
; Required:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll / Modules\FMXPixie_x64.dll (rebuilt with wrapper)
;   Examples\PaintBox\FPixiePaintBox_Interface.iss
; ============================================================================

#define DemoAppName "FMXPixie - PaintBox Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - PaintBox Demo
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
  PaintBox: FPixiePaintBox;

  TempDir: String;
  DrawGrid: Boolean;
  PaintVisible: Boolean;
  PaintFront: Boolean;
  PaintControlEnabled: Boolean;
  PaintHitTestEnabled: Boolean;
  FillCanvasBackground: Boolean;
  ReducedOpacity: Boolean;
  PaletteIndex: Integer;
  PaintCount: Integer;

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
    '<span class="caption">FMXPixie</span><span class="subtitle">/ PaintBox component lab</span>' +
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
    '.hero{position:absolute;left:20px;top:13px;width:940px;height:68px;padding:11px 18px;' +
    'background:#111827;border:1px solid #26364c;}' +
    '.eyebrow{font-size:10px;letter-spacing:2px;color:#67e8f9;font-weight:bold;}' +
    'h1{font-size:23px;line-height:27px;margin:1px 0;color:#f8fafc;}' +
    '.hero-sub{color:#94a3b8;font-size:12px;}' +
    '.label{position:absolute;left:24px;color:#93c5fd;font-size:11px;font-weight:bold;letter-spacing:1.5px;}' +
    '.surface{position:absolute;left:20px;width:940px;background:#172033;border:1px solid #26364c;}' +
    '#canvas-label{top:94px;}#canvas-surface{top:118px;height:334px;}' +
    '#tools-label{top:464px;}#tools-surface{top:486px;height:142px;}' +
    '.tools{position:absolute;left:14px;top:10px;right:14px;}' +
    '.row{height:32px;white-space:nowrap;}' +
    'button{font-family:Segoe UI,Arial,sans-serif;font-size:12px;background:#1e293b;color:#e2e8f0;' +
    'border:1px solid #3b4d66;border-radius:4px;padding:6px 10px;margin:0 5px 4px 0;cursor:pointer;}' +
    'button:hover{background:#1d4ed8;border-color:#60a5fa;color:#fff;}' +
    'button.primary{background:#164e63;border-color:#0e7490;color:#cffafe;}' +
    'button.danger:hover{background:#991b1b;border-color:#ef4444;}' +
    '.hint{position:absolute;left:16px;top:6px;color:#94a3b8;font-size:10px;}' +
    '#status{position:absolute;left:16px;right:16px;top:79px;color:#bfdbfe;font-size:11px;line-height:16px;}' +
    '#metrics{position:absolute;right:18px;top:7px;color:#64748b;font-size:10px;}' +
    '#footer{position:absolute;left:24px;right:24px;top:646px;color:#64748b;font-size:11px;line-height:17px;}' +
    'a{color:#67e8f9;text-decoration:none;}' +
    '</style></head><body>' +
    '<div class="hero"><div class="eyebrow">NATIVE FMX GRAPHICS / DRAWING API</div>' +
    '<h1>PaintBox <span style="color:#67e8f9">/</span> component lab</h1>' +
    '<div class="hero-sub">Drawing primitives and text are rendered by Pixie; the callback is implemented in Inno Setup Pascal Script.</div></div>' +
    '<div id="canvas-label" class="label">01 / LIVE DRAWING SURFACE</div>' +
    '<div id="canvas-surface" class="surface">' +
    '<div class="hint">Shapes, state changes, text metrics, repaint and canvas background</div>' +
    '<div id="metrics">SIZE / REPAINT COUNTER SHOWN ON CANVAS</div></div>' +
    '<div id="tools-label" class="label">02 / INTERACTIVE API TESTS</div>' +
    '<div id="tools-surface" class="surface"><div class="tools">' +
    '<div class="row"><button id="btn-redraw" class="primary">Repaint</button>' +
    '<button id="btn-grid">Toggle grid</button><button id="btn-palette">Cycle palette</button>' +
    '<button id="btn-background">Disable background fill</button></div>' +
    '<div class="row"><button id="btn-visible">Hide PaintBox</button>' +
    '<button id="btn-opacity">Opacity: 100%</button><button id="btn-enabled">Enabled: true</button>' +
    '<button id="btn-hittest">HitTest: off</button><button id="btn-layer">Send to back</button>' +
    '<button id="btn-reset" class="danger">Reset</button></div>' +
    '</div><div id="status">Starting PaintBox test…</div></div>' +
    '<div id="footer">FMXPixie · PaintBox Demo / Test · no installation is performed. ' +
    'The source and drawing API are based on the <a href="https://gitlab.com/retrofoxed/pixie">Pixie project</a>.</div>' +
    '</body></html>';
end;

// -----------------------------------------------------------------------------
// HTML document helpers
// -----------------------------------------------------------------------------
procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  if Doc = nil then Exit;
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, S);
end;

procedure SetStatus(const S: String);
begin
  SetTextById('status', S);
  Log('FMXPixie PaintBox: ' + S);
  if Doc <> nil then
    Doc.Changed;
end;

procedure UpdateButtonLabels;
begin
  if PaintVisible then
    SetTextById('btn-visible', 'Hide PaintBox')
  else
    SetTextById('btn-visible', 'Show PaintBox');

  if PaintControlEnabled then
    SetTextById('btn-enabled', 'Enabled: true')
  else
    SetTextById('btn-enabled', 'Enabled: false');

  if PaintHitTestEnabled then
    SetTextById('btn-hittest', 'HitTest: on')
  else
    SetTextById('btn-hittest', 'HitTest: off');

  if FillCanvasBackground then
    SetTextById('btn-background', 'Disable background fill')
  else
    SetTextById('btn-background', 'Enable background fill');

  if ReducedOpacity then
    SetTextById('btn-opacity', 'Opacity: 62%')
  else
    SetTextById('btn-opacity', 'Opacity: 100%');

  if PaintFront then
    SetTextById('btn-layer', 'Send to back')
  else
    SetTextById('btn-layer', 'Bring to front');
end;

function PrimaryColor: TAlphaColor;
begin
  case PaletteIndex mod 3 of
    0: Result := $FF67C8FF;
    1: Result := $FFA78BFA;
  else
    Result := $FF34D399;
  end;
end;

function SecondaryColor: TAlphaColor;
begin
  case PaletteIndex mod 3 of
    0: Result := $FFFFD479;
    1: Result := $FFFB923C;
  else
    Result := $FFF472B6;
  end;
end;

function DeepColor: TAlphaColor;
begin
  case PaletteIndex mod 3 of
    0: Result := $FF163854;
    1: Result := $FF35265E;
  else
    Result := $FF164A3D;
  end;
end;

// -----------------------------------------------------------------------------
// PaintBox OnPaint callback
// -----------------------------------------------------------------------------
procedure PaintBoxDraw(Sender: TObject);
var
  W, H: Single;
  I: Integer;
  TextW, TextH: Single;
  ProgressW: Single;
  GridColor: TAlphaColor;
begin
  Inc(PaintCount);

  W := PaintBox.GetWidth;
  H := PaintBox.GetHeight;
  if (W <= 0) or (H <= 0) then Exit;

  GridColor := $FF203047;

  if DrawGrid then
  begin
    PaintBox.PenStyle(ppsSolid);
    PaintBox.PenWidth(1);
    PaintBox.PenColor(GridColor);
    PaintBox.BrushStyle(pbsClear);

    for I := 1 to 8 do
      PaintBox.Line(0, H * I / 9, W, H * I / 9);

    for I := 1 to 18 do
      PaintBox.Line(W * I / 19, 0, W * I / 19, H);
  end;

  { Header }
  PaintBox.PenStyle(ppsSolid);
  PaintBox.BrushStyle(pbsClear);
  PaintBox.FontFamily('Segoe UI');
  PaintBox.FontSize(20);
  PaintBox.FontColor($FFE6F2FF);
  PaintBox.FontStyle([pfsBold]);
  PaintBox.TextOut(18, 27, 'Drawing API');

  PaintBox.FontSize(11);
  PaintBox.FontColor($FF9AB3CE);
  PaintBox.FontStyle([]);
  PaintBox.TextOut(19, 47, 'Line / Rectangle / FillRect / RoundRect / Ellipse / Circle / Arc');

  PaintBox.PenColor($FF30445E);
  PaintBox.PenWidth(1);
  PaintBox.Line(18, 61, W - 18, 61);

  { 1. Rectangle outline }
  PaintBox.PenColor(PrimaryColor);
  PaintBox.PenWidth(2);
  PaintBox.BrushStyle(pbsClear);
  PaintBox.Rectangle(20, 77, 124, 54);
  PaintBox.FontSize(10);
  PaintBox.FontColor($FFB7C8DD);
  PaintBox.TextOut(20, 151, 'Rectangle');

  { 2. FillRect }
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor(DeepColor);
  PaintBox.FillRect(166, 77, 124, 54);
  PaintBox.FontColor($FFB7C8DD);
  PaintBox.TextOut(166, 151, 'FillRect');

  { 3. RoundRect }
  PaintBox.PenColor(SecondaryColor);
  PaintBox.PenWidth(2);
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor(DeepColor);
  PaintBox.RoundRect(312, 77, 124, 54, 10);
  PaintBox.FontColor($FFB7C8DD);
  PaintBox.TextOut(312, 151, 'RoundRect');

  { 4. Ellipse }
  PaintBox.PenColor($FF7DE0B1);
  PaintBox.BrushColor($FF174A3D);
  PaintBox.Ellipse(458, 80, 116, 48);
  PaintBox.FontColor($FFB7C8DD);
  PaintBox.TextOut(458, 151, 'Ellipse');

  { 5. Circle }
  PaintBox.PenColor($FFFFD479);
  PaintBox.BrushColor($FF604820);
  PaintBox.Circle(650, 104, 28);
  PaintBox.FontColor($FFB7C8DD);
  PaintBox.TextOut(625, 151, 'Circle');

  { 6. Arc and Line }
  PaintBox.SaveState;
  PaintBox.PenColor(PrimaryColor);
  PaintBox.PenWidth(4);
  PaintBox.BrushStyle(pbsClear);
  PaintBox.Arc(722, 74, 66, 62, -35, 285);
  PaintBox.RestoreState;
  PaintBox.PenWidth(1);
  PaintBox.PenColor(SecondaryColor);
  PaintBox.Line(820, 104, 904, 104);
  PaintBox.FontSize(10);
  PaintBox.FontColor($FFB7C8DD);
  PaintBox.TextOut(729, 151, 'Arc');
  PaintBox.TextOut(839, 151, 'Line');

  { TextOut, TextWidth, TextHeight }
  PaintBox.PenStyle(ppsSolid);
  PaintBox.PenColor($FF30445E);
  PaintBox.PenWidth(1);
  PaintBox.Line(18, 169, W - 18, 169);

  PaintBox.FontSize(12);
  PaintBox.FontColor($FFE6F2FF);
  PaintBox.FontStyle([pfsBold]);
  PaintBox.TextOut(20, 191, 'TextOut: measured sample');
  PaintBox.FontStyle([]);

  PaintBox.FontColor($FF9AB3CE);
  PaintBox.TextOut(20, 217, 'TextWidth: underline = measured width');
  TextW := PaintBox.TextWidth('TextWidth: underline = measured width');
  PaintBox.Line(20, 226, 20 + TextW, 226);

  TextH := PaintBox.TextHeight;
  PaintBox.Line(390, 198, 390, 198 + TextH);
  PaintBox.Line(384, 198, 396, 198);
  PaintBox.Line(384, 198 + TextH, 396, 198 + TextH);
  PaintBox.TextOut(405, 217, 'TextHeight = ' + IntToStr(Round(TextH)) + ' px');

  PaintBox.TextRect(565, 181, 332, 48,
    'TextRect: centered text', ptaCenter, pvaMiddle);
  PaintBox.PenColor(PrimaryColor);
  PaintBox.PenWidth(1);
  PaintBox.BrushStyle(pbsClear);
  PaintBox.Rectangle(565, 181, 332, 48);

  { Dynamic meter and callback count }
  PaintBox.PenColor($FF30445E);
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor($FF1E293B);
  PaintBox.FillRect(20, 265, 260, 8);

  ProgressW := 12 + (PaintCount mod 100) * 2.4;
  if ProgressW > 258 then ProgressW := 258;
  PaintBox.BrushColor(PrimaryColor);
  PaintBox.FillRect(21, 266, ProgressW, 6);

  PaintBox.FontSize(10);
  PaintBox.FontColor($FF9AB3CE);
  PaintBox.TextOut(20, 293,
    'Paint callback count: ' + IntToStr(PaintCount));

  PaintBox.FontColor($FFB7C8DD);
  PaintBox.TextOut(360, 293,
    'Control size: ' + IntToStr(Round(W)) + ' x ' + IntToStr(Round(H)));

  PaintBox.FontColor($FF64748B);
  PaintBox.TextOut(20, 316,
    'Change palette, toggle the grid/background, hide the control or request a new paint from the buttons below.');
end;

// -----------------------------------------------------------------------------
// Element clicks and window controls
// -----------------------------------------------------------------------------
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

  if Id = 'btn-redraw' then
  begin
    PaintBox.Repaint;
    SetStatus('Repaint requested. Paint callback count: ' + IntToStr(PaintCount));
    Result := True;
    Exit;
  end;

  if Id = 'btn-grid' then
  begin
    DrawGrid := not DrawGrid;
    PaintBox.Repaint;
    if DrawGrid then
      SetStatus('Grid enabled.')
    else
      SetStatus('Grid disabled.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-palette' then
  begin
    PaletteIndex := (PaletteIndex + 1) mod 3;
    PaintBox.BackgroundColor(DeepColor);
    PaintBox.Repaint;
    SetStatus('Palette changed. Accent colors and PaintBox background updated.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-background' then
  begin
    FillCanvasBackground := not FillCanvasBackground;
    PaintBox.FillBackground(FillCanvasBackground);
    UpdateButtonLabels;
    PaintBox.Repaint;
    if FillCanvasBackground then
      SetStatus('FillBackground enabled. PaintBox paints its own background.')
    else
      SetStatus('FillBackground disabled. The parent surface should show through.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-visible' then
  begin
    PaintVisible := not PaintVisible;
    PaintBox.Visible(PaintVisible);
    UpdateButtonLabels;
    if PaintVisible then
      SetStatus('PaintBox is visible.')
    else
      SetStatus('PaintBox hidden. Use Show PaintBox to restore it.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-opacity' then
  begin
    ReducedOpacity := not ReducedOpacity;
    if ReducedOpacity then
      PaintBox.Opacity(0.62)
    else
      PaintBox.Opacity(1.0);
    UpdateButtonLabels;
    if ReducedOpacity then
      SetStatus('PaintBox opacity set to 62%.')
    else
      SetStatus('PaintBox opacity restored to 100%.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-enabled' then
  begin
    PaintControlEnabled := not PaintControlEnabled;
    PaintBox.Enabled(PaintControlEnabled);
    UpdateButtonLabels;
    if PaintControlEnabled then
      SetStatus('Enabled=True. PaintBox is enabled.')
    else
      SetStatus('Enabled=False. PaintBox is disabled; hit testing is controlled separately.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-hittest' then
  begin
    PaintHitTestEnabled := not PaintHitTestEnabled;
    PaintBox.HitTest(PaintHitTestEnabled);
    UpdateButtonLabels;
    if PaintHitTestEnabled then
      SetStatus('HitTest=True. PaintBox can receive mouse input over its area.')
    else
      SetStatus('HitTest=False. Mouse input can pass through to controls underneath.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-layer' then
  begin
    PaintFront := not PaintFront;
    if PaintFront then
      PaintBox.BringToFront
    else
      PaintBox.SendToBack;
    UpdateButtonLabels;
    if PaintFront then
      SetStatus('PaintBox brought to front.')
    else
      SetStatus('PaintBox sent behind the HTML view. Use Bring to front to restore it.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-reset' then
  begin
    DrawGrid := True;
    PaintVisible := True;
    PaintFront := True;
    PaintControlEnabled := True;
    PaintHitTestEnabled := False;
    FillCanvasBackground := True;
    ReducedOpacity := False;
    PaletteIndex := 0;

    PaintBox.FillBackground(True);
    PaintBox.BackgroundColor($FF0B1220);
    PaintBox.Opacity(1.0);
    PaintBox.Enabled(True);
    PaintBox.HitTest(False);
    PaintBox.Visible(True);
    PaintBox.BringToFront;

    UpdateButtonLabels;
    PaintBox.Repaint;
    SetStatus('Reset complete. All drawing primitives and common PaintBox options are active.');
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

// -----------------------------------------------------------------------------
// Initialization
// -----------------------------------------------------------------------------
procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  TitleView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  Doc := InitPixieDocument;
  Elem := InitPixieElement;
  PaintBox := InitPixiePaintBox;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  TempDir := ExpandConstant('{tmp}');
  DrawGrid := True;
  PaintVisible := True;
  PaintFront := True;
  PaintControlEnabled := True;
  PaintHitTestEnabled := False;
  FillCanvasBackground := True;
  ReducedOpacity := False;
  PaletteIndex := 0;
  PaintCount := 0;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF101827, '', True);

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

  PaintBox.FCreate(FMXForm.Handle);
  PaintBox.SetBounds(22, TITLEBAR_HEIGHT + 120,
    DEMO_FORM_WIDTH - 44, 330);
  PaintBox.Margins(0, 0, 0, 0);
  PaintBox.Padding(0, 0, 0, 0);
  PaintBox.SetHint('Pixie PaintBox: drawing commands are available only during OnPaint.');
  PaintBox.SetClipParent(True);
  PaintBox.SetClipChildren(False);
  PaintBox.FillBackground(True);
  PaintBox.BackgroundColor($FF0B1220);
  PaintBox.PenColor($FF000000);
  PaintBox.PenWidth(1);
  PaintBox.PenStyle(ppsSolid);
  PaintBox.BrushColor($FFFFFFFF);
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.FontFamily('Segoe UI');
  PaintBox.FontSize(13);
  PaintBox.FontColor($FF000000);
  PaintBox.FontStyle([]);
  PaintBox.Opacity(1.0);
  PaintBox.Enabled(True);
  PaintBox.Visible(True);
  PaintBox.HitTest(False);
  PaintBox.OnPaint(@PaintBoxDraw);
  PaintBox.BringToFront;

  UpdateButtonLabels;
  PaintBox.Repaint;
  SetStatus('Ready. PaintBox handle=' + IntToStr(PaintBox.Handle) +
    '; size=' + IntToStr(Round(PaintBox.GetWidth)) + ' x ' +
    IntToStr(Round(PaintBox.GetHeight)) + '.');
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
