; ============================================================================
; FMXPixie Wrapper Integration Lab
; One integrated FMX surface using every public interface in the supplied
; FMXPixieHandle.iss: FForm, FMsgForm, FPixieHtmlView, FPixieDocument,
; FPixieElement, FPixieElementList, FPixieSvgView, FPixieMarkdownView,
; FPixieTagBar and FPixiePaintBox.
;
; Requirements:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;
; No JavaScript, external assets, or application installation is required.
; ============================================================================

#define DemoAppName "FMXPixie - Wrapper Integration Lab"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Wrapper Integration Lab
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
  DEMO_FORM_WIDTH = 1020;
  DEMO_FORM_HEIGHT = 790;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  MsgForm: FMsgForm;

  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  MsgView: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;
  FoundList: FPixieElementList;
  SvgView: FPixieSvgView;
  MarkdownView: FPixieMarkdownView;
  TagBar: FPixieTagBar;
  PaintBox: FPixiePaintBox;

  TempDir: String;
  UiReady: Boolean;
  MsgFormCreated: Boolean;
  TagBatching: Boolean;

  ClickCount: Integer;
  SystemEnabled: Boolean;
  HtmlZoomFactor: Double;
  SvgZoomFactor: Double;
  MarkdownZoomFactor: Double;
  SvgDarkBackground: Boolean;
  MarkdownDefaults: Boolean;
  MarkdownVisible: Boolean;
  DrawGrid: Boolean;
  PaintFront: Boolean;
  PaletteIndex: Integer;
  PaintPhase: Integer;
  PaintCount: Integer;
  TagIndex: Integer;

// ---------------------------------------------------------------------------
// HTML: custom title bar
// ---------------------------------------------------------------------------
function BuildTitleHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;padding:0;width:100%;height:32px;overflow:hidden;}' +
    'body{background:#111a28;color:#e5edf7;font-family:Segoe UI,Arial,sans-serif;font-size:12px;}' +
    '.bar{position:relative;width:100%;height:32px;line-height:31px;background:#111a28;border-bottom:1px solid #2a3b50;}' +
    '.brand{margin-left:14px;color:#91dce0;font-weight:bold;letter-spacing:1.5px;}' +
    '.caption{margin-left:12px;color:#8294aa;}' +
    '.controls{position:absolute;right:0;top:0;width:92px;height:31px;font-size:0;}' +
    '.tb{display:inline-block;vertical-align:top;width:46px;height:31px;line-height:30px;text-align:center;color:#d6e0ec;font-size:19px;cursor:pointer;}' +
    '.tb:hover{background:#2a3c52;color:#fff;}.close:hover{background:#c73c4a;color:#fff;}' +
    '</style></head><body><div class="bar">' +
    '<span class="brand">FMXPIXIE</span><span class="caption">/ WRAPPER INTEGRATION LAB</span>' +
    '<div class="controls"><div id="title-minimize" class="tb" title="Minimize">−</div>' +
    '<div id="title-close" class="tb close" title="Close">×</div></div></div>' +
    '</body></html>';
end;

// ---------------------------------------------------------------------------
// HTML: common workspace. FMX controls are placed over their matching panels.
// ---------------------------------------------------------------------------
function BuildMainHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;padding:0;width:1020px;height:758px;overflow:hidden;}' +
    'body{position:relative;background:#0b1220;color:#e7edf6;font-family:Segoe UI,Arial,sans-serif;font-size:12px;}' +
    '.hero{position:absolute;left:18px;top:12px;width:984px;height:66px;padding:10px 15px;background:#111b2a;border:1px solid #2a3b50;}' +
    '.eyebrow{color:#67d6d3;font-size:9px;font-weight:bold;letter-spacing:2px;}' +
    'h1{margin:1px 0 0;font-size:22px;line-height:26px;color:#f4f7fb;font-weight:600;}' +
    '.hero-note{position:absolute;right:15px;top:21px;color:#91a2b8;font-size:11px;}' +
    '.card{position:absolute;background:#111b2a;border:1px solid #2a3b50;overflow:hidden;}' +
    '.card-title{position:absolute;left:13px;top:10px;color:#9edee1;font-size:10px;font-weight:bold;letter-spacing:1.1px;}' +
    '.card-sub{position:absolute;left:13px;top:27px;color:#74869d;font-size:10px;}' +
    '#svg-panel{left:18px;top:92px;width:220px;height:192px;}' +
    '#markdown-panel{left:252px;top:92px;width:390px;height:192px;}' +
    '#tag-panel{left:654px;top:92px;width:346px;height:192px;}' +
    '#paint-panel{left:18px;top:300px;width:610px;height:265px;}' +
    '#api-panel{left:642px;top:300px;width:358px;height:265px;}' +
    '#footer-panel{left:18px;top:578px;width:984px;height:162px;}' +
    '.btn{display:inline-block;vertical-align:top;background:#1b2a3d;color:#dce8f5;border:1px solid #3a5069;border-radius:3px;padding:5px 8px;margin:0 4px 0 0;height:26px;line-height:14px;font-size:10px;cursor:pointer;white-space:nowrap;}' +
    '.btn:hover{background:#1c5870;border-color:#58c4cf;color:#fff;}.btn.primary{background:#164e63;border-color:#0e7490;color:#cffafe;}' +
    '.btn.danger:hover{background:#8d2838;border-color:#e35b6a;}' +
    '.actions{position:absolute;left:12px;top:150px;white-space:nowrap;}' +
    '.paint-actions{top:234px;}' +
    '#tag-actions{left:12px;}' +
    '.metric-row{position:absolute;left:14px;top:48px;right:14px;height:25px;color:#9aabc0;}' +
    '.metric{display:inline-block;margin-right:14px;}' +
    '.metric b{color:#f1f5f9;font-size:14px;}' +
    '.state-card{position:absolute;left:14px;right:14px;top:77px;height:37px;padding:8px 9px;background:#122c32;border:1px solid #1c696c;color:#c9fbf0;}' +
    '.state-card.is-off{background:#311c28;border-color:#854154;color:#ffd6df;}' +
    '.state-value{float:right;font-weight:bold;letter-spacing:1px;}' +
    '#api-actions1{position:absolute;left:14px;top:124px;white-space:nowrap;}' +
    '#api-actions2{position:absolute;left:14px;top:156px;white-space:nowrap;}' +
    '#query-result{position:absolute;left:15px;right:15px;top:194px;color:#9bb0c8;font-size:10px;line-height:14px;}' +
    '#footer-info{position:absolute;left:14px;top:11px;color:#7f93ac;font-size:10px;}' +
    '#status{position:absolute;left:14px;right:14px;top:34px;height:30px;padding:8px 10px;background:#0b1422;border:1px solid #26394f;color:#c5d8eb;white-space:nowrap;overflow:hidden;}' +
    '#footer-actions{position:absolute;left:14px;top:78px;white-space:nowrap;}' +
    '#footer-note{position:absolute;left:14px;right:14px;top:119px;color:#5f748e;font-size:10px;}' +
    'a{color:#79d7df;text-decoration:none;}a:hover{color:#fff;text-decoration:underline;}' +
    '</style></head><body>' +
    '<div class="hero"><div class="eyebrow">FMX CONTROLS / HTML RENDERING / VECTOR DRAWING</div>' +
    '<h1>One surface. All wrappers.</h1>' +
    '<div class="hero-note">Interactive integration demo · no install payload</div></div>' +

    '<div id="svg-panel" class="card query-target"><div class="card-title">01 / SVG VIEW</div>' +
    '<div class="card-sub">Inline vector / zoom / background</div>' +
    '<div class="actions mini-actions"><button id="btn-svg-zoom" class="btn">SVG zoom 100%</button>' +
    '<button id="btn-svg-bg" class="btn">Toggle background</button></div></div>' +

    '<div id="markdown-panel" class="card query-target"><div class="card-title">02 / MARKDOWN VIEW</div>' +
    '<div class="card-sub">Rendered from a string / style and zoom controls</div>' +
    '<div class="actions mini-actions"><button id="btn-md-zoom" class="btn">MD zoom 100%</button>' +
    '<button id="btn-md-styles" class="btn">Default CSS: ON</button>' +
    '<button id="btn-md-visible" class="btn">Hide Markdown</button></div></div>' +

    '<div id="tag-panel" class="card query-target"><div class="card-title">03 / TAG BAR</div>' +
    '<div class="card-sub">Check tags to send events back to Pascal Script</div>' +
    '<div class="actions mini-actions" id="tag-actions"><button id="btn-tags-all" class="btn">Check all</button>' +
    '<button id="btn-tags-none" class="btn">Uncheck all</button></div></div>' +

    '<div id="paint-panel" class="card query-target"><div class="card-title">04 / PAINT BOX</div>' +
    '<div class="actions paint-actions"><button id="btn-paint-grid" class="btn">Grid: ON</button>' +
    '<button id="btn-paint-color" class="btn">Change palette</button>' +
    '<button id="btn-paint-repaint" class="btn">Repaint</button>' +
    '<button id="btn-paint-layer" class="btn">Send to back</button></div></div>' +

    '<div id="api-panel" class="card query-target"><div class="card-title">05 / HTML + DOM API</div>' +
    '<div class="metric-row"><span class="metric">HTML clicks <b id="click-count">0</b></span>' +
    '<span class="metric">DOM targets <b id="query-count">?</b></span></div>' +
    '<div id="state-card" class="state-card is-on">Runtime setting <span id="state-value" class="state-value">ENABLED</span></div>' +
    '<div id="api-actions1"><button id="btn-count" class="btn primary">Increment</button>' +
    '<button id="btn-state" class="btn">Toggle setting</button></div>' +
    '<div id="api-actions2"><button id="btn-query" class="btn">QuerySelectorAll</button>' +
    '<button id="btn-message" class="btn">Open FMsgForm</button></div>' +
    '<div id="query-result">Ready. Use the controls to exercise the wrappers.</div></div>' +

    '<div id="footer-panel" class="card query-target"><div class="card-title">06 / SHARED STATUS AND HTML VIEW CONTROLS</div>' +
    '<div id="footer-info">Document updates are batched through FPixieDocument; element attributes are changed through FPixieElement.</div>' +
    '<div id="status">Initialising FMXPixie components…</div>' +
    '<div id="footer-actions"><button id="btn-select" class="btn">Select HTML text</button>' +
    '<button id="btn-clear-select" class="btn">Clear selection</button>' +
    '<button id="btn-reset" class="btn danger">Reset demo state</button>' +
    '<a id="demo-anchor" href="https://example.com/fmxpixie">Test OnAnchorClick</a></div>' +
    '<div id="footer-note">The five visual areas above are controls hosted by the same FMX form; only the optional message test opens a second form.</div></div>' +
    '</body></html>';
end;

// ---------------------------------------------------------------------------
// Small message form content (uses FMsgForm + another HtmlView instance).
// ---------------------------------------------------------------------------
function BuildMessageHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;}' +
    'body{background:#101827;color:#dce7f3;font-family:Segoe UI,Arial,sans-serif;font-size:13px;}' +
    '.bar{height:32px;background:#172235;border-bottom:1px solid #2c405a;line-height:31px;position:relative;}' +
    '.title{margin-left:12px;color:#91dce0;font-weight:bold;}' +
    '.close{position:absolute;right:0;top:0;width:44px;height:31px;text-align:center;font-size:19px;cursor:pointer;}' +
    '.close:hover{background:#bd3445;color:white;}' +
    '.content{padding:17px 18px;line-height:1.5;color:#aebed1;}' +
    'h2{margin:0 0 9px;color:#f1f5f9;font-size:19px;}' +
    '.accent{color:#8fe0dc;font-weight:bold;}' +
    '.btn{display:inline-block;margin-top:15px;padding:7px 12px;background:#164e63;border:1px solid #0e7490;color:#d7fbfc;cursor:pointer;}' +
    '.btn:hover{background:#1c7084;}' +
    '</style></head><body><div class="bar"><span class="title">FMXPixie / FMsgForm</span>' +
    '<div id="msg-close" class="close" title="Close">×</div></div>' +
    '<div class="content"><h2>Every wrapper is alive.</h2>' +
    'This small owned form is created through <span class="accent">FMsgForm</span>.' +
    '<br>The content itself is another <span class="accent">FPixieHtmlView</span>.' +
    '<br><br>Close this window to return to the integrated workspace.' +
    '<div id="msg-close-button" class="btn">Close message</div></div></body></html>';
end;

function BuildSvgMarkup: String;
begin
  Result :=
    '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="108" viewBox="0 0 200 108">' +
    '<rect x="1" y="1" width="198" height="106" rx="12" fill="#101827" stroke="#30465f" stroke-width="1.5"/>' +
    '<circle cx="51" cy="53" r="29" fill="#173c4c" stroke="#5bd0d2" stroke-width="2"/>' +
    '<path d="M36 53 L47 64 L68 40" fill="none" stroke="#c7fff4" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>' +
    '<rect x="94" y="30" width="80" height="10" rx="5" fill="#79d6db"/>' +
    '<rect x="94" y="48" width="62" height="7" rx="3.5" fill="#667e9a"/>' +
    '<rect x="94" y="62" width="72" height="7" rx="3.5" fill="#405973"/>' +
    '<text x="94" y="85" fill="#d9e7f5" font-family="Segoe UI,Arial" font-size="10">SVG VIEW</text>' +
    '</svg>';
end;

function BuildMarkdown: String;
begin
  Result :=
    '# MarkdownView' + #13#10 + #13#10 +
    'This content is rendered by **FPixieMarkdownView** on the same FMX form.' + #13#10 + #13#10 +
    '- Markdown source is a string.' + #13#10 +
    '- Zoom and default styles are interactive.' + #13#10 +
    '- [Anchor callback test](https://example.com/markdown-view)' + #13#10;
end;

// ---------------------------------------------------------------------------
// Main HTML Document / DOM helpers
// ---------------------------------------------------------------------------
procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  if not UiReady then Exit;
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, S);
end;

procedure SetClassById(const Id, ClassName: String);
var
  H: NativeInt;
begin
  if not UiReady then Exit;
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  Elem.SetAttr('class', ClassName);
end;

procedure SetStatus(const S: String);
begin
  if UiReady then
  begin
    SetTextById('status', S);
    Doc.Changed;
  end;
  Log('FMXPixie Wrapper Lab: ' + S);
end;

procedure SetTextAndStatus(const Id, Value, StatusText: String);
begin
  if UiReady then
  begin
    Doc.BeginUpdate;
    try
      SetTextById(Id, Value);
      SetTextById('query-result', StatusText);
      SetTextById('status', StatusText);
      Doc.Changed;
    finally
      Doc.EndUpdate;
    end;
  end;
  Log('FMXPixie Wrapper Lab: ' + StatusText);
end;

// ---------------------------------------------------------------------------
// PaintBox drawing. Coordinates are relative to the PaintBox client area.
// ---------------------------------------------------------------------------
function PrimaryColor: TAlphaColor;
begin
  case PaletteIndex mod 3 of
    0: Result := $FF63D7D2;
    1: Result := $FFB8A0FF;
  else
    Result := $FF8BDD9E;
  end;
end;

function SecondaryColor: TAlphaColor;
begin
  case PaletteIndex mod 3 of
    0: Result := $FFFFCD7C;
    1: Result := $FFFFA36C;
  else
    Result := $FFEE8BB8;
  end;
end;

procedure PaintBoxDraw(Sender: TObject);
var
  W, H: Single;
  I: Integer;
  BarW: Single;
  Txt: String;
begin
  Inc(PaintCount);
  W := PaintBox.GetWidth;
  H := PaintBox.GetHeight;
  if (W <= 0) or (H <= 0) then Exit;

  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor($FF0B1422);
  PaintBox.FillRect(0, 0, W, H);

  if DrawGrid then
  begin
    PaintBox.PenStyle(ppsSolid);
    PaintBox.PenWidth(1);
    PaintBox.PenColor($FF1A2A3F);
    PaintBox.BrushStyle(pbsClear);
    for I := 1 to 7 do
      PaintBox.Line(0, H * I / 8, W, H * I / 8);
    for I := 1 to 15 do
      PaintBox.Line(W * I / 16, 0, W * I / 16, H);
  end;

  PaintBox.PenStyle(ppsSolid);
  PaintBox.BrushStyle(pbsClear);
  PaintBox.PenColor($FF30465F);
  PaintBox.PenWidth(1);
  PaintBox.Line(14, 28, W - 14, 28);

  PaintBox.FontFamily('Segoe UI');
  PaintBox.FontSize(13);
  PaintBox.FontColor($FFEAF4FC);
  PaintBox.FontStyle([pfsBold]);
  PaintBox.TextOut(15, 20, 'PaintBox / OnPaint');
  PaintBox.FontSize(9);
  PaintBox.FontColor($FF8CA4BE);
  PaintBox.FontStyle([]);
  PaintBox.TextOut(W - 147, 20, 'FRAME ' + IntToStr(PaintCount));

  PaintBox.PenColor(PrimaryColor);
  PaintBox.PenWidth(2);
  PaintBox.BrushStyle(pbsClear);
  PaintBox.Rectangle(16, 42, 87, 46);
  PaintBox.FontColor($FFB5C6D9);
  PaintBox.TextOut(18, 103, 'Rectangle');

  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor($FF20394D);
  PaintBox.PenColor(SecondaryColor);
  PaintBox.PenWidth(1.5);
  PaintBox.RoundRect(119, 42, 88, 46, 8);
  PaintBox.FontColor($FFB5C6D9);
  PaintBox.TextOut(121, 103, 'RoundRect');

  PaintBox.BrushColor($FF15443F);
  PaintBox.PenColor($FF7DE3B1);
  PaintBox.Ellipse(225, 47, 69, 36);
  PaintBox.FontColor($FFB5C6D9);
  PaintBox.TextOut(231, 103, 'Ellipse');

  PaintBox.BrushColor($FF554225);
  PaintBox.PenColor(SecondaryColor);
  PaintBox.Circle(336, 65, 23);
  PaintBox.FontColor($FFB5C6D9);
  PaintBox.TextOut(319, 103, 'Circle');

  PaintBox.BrushStyle(pbsClear);
  PaintBox.PenWidth(4);
  PaintBox.PenColor(PrimaryColor);
  PaintBox.Arc(375, 42, 58, 49, -35, 285);
  PaintBox.FontColor($FFB5C6D9);
  PaintBox.FontSize(9);
  PaintBox.TextOut(392, 103, 'Arc');

  PaintBox.PenWidth(1.5);
  PaintBox.PenColor(SecondaryColor);
  PaintBox.Line(451, 65, W - 16, 65);
  PaintBox.FontColor($FFB5C6D9);
  PaintBox.TextOut(455, 103, 'Line');

  PaintBox.PenColor($FF30465F);
  PaintBox.PenWidth(1);
  PaintBox.Line(15, 122, W - 15, 122);
  PaintBox.FontSize(10);
  PaintBox.FontColor($FFBDD0E4);
  PaintBox.TextOut(16, 142, 'TextWidth: ' + IntToStr(Round(PaintBox.TextWidth('FMXPixie'))));
  PaintBox.TextOut(180, 142, 'TextHeight: ' + IntToStr(Round(PaintBox.TextHeight)));
  PaintBox.TextRect(330, 128, W - 346, 23,
    'TextRect / centered', ptaCenter, pvaMiddle);

  PaintBox.PenColor($FF2A3F56);
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor($FF1A2B40);
  PaintBox.FillRect(16, H - 28, W - 32, 9);
  BarW := (W - 34) * (PaintPhase + 1) / 6;
  if BarW < 1 then BarW := 1;
  PaintBox.BrushColor(PrimaryColor);
  PaintBox.FillRect(17, H - 27, BarW, 7);
  PaintBox.FontSize(9);
  PaintBox.FontColor($FF8CA4BE);
  Txt := 'Phase ' + IntToStr(PaintPhase + 1) + '/6  ·  grid ';
  if DrawGrid then Txt := Txt + 'ON' else Txt := Txt + 'OFF';
  PaintBox.TextOut(16, H - 35, Txt);
end;

// ---------------------------------------------------------------------------
// Window callbacks
// ---------------------------------------------------------------------------
procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

procedure TitleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TitleView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

procedure MessageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and (X < 420 - 44) then
    MsgForm.StartWindowDrag;
end;

procedure MainFormShown(Sender: TObject);
begin
  Log('FMXPixie Wrapper Lab: FMX form shown.');
end;

procedure MainFormActivated(Sender: TObject);
begin
  Log('FMXPixie Wrapper Lab: FMX form activated.');
end;

procedure MainFormDeactivated(Sender: TObject);
begin
  Log('FMXPixie Wrapper Lab: FMX form deactivated.');
end;

procedure SvgViewClicked(Sender: TObject);
begin
  SetStatus('FPixieSvgView.OnClick fired. SVG is a separate FMX wrapper on this surface.');
end;

procedure MarkdownViewClicked(Sender: TObject);
begin
  SetStatus('FPixieMarkdownView.OnClick fired.');
end;

procedure MarkdownAnchorClick(Sender, El: TObject; const Url: String);
begin
  SetStatus('Markdown anchor callback: ' + Url);
end;

procedure MainAnchorClick(Sender, El: TObject; const Url: String);
begin
  SetStatus('HTML OnAnchorClick callback: ' + Url + ' (not opened automatically).');
end;

procedure AfterParse(Sender: TObject);
begin
  Log('FMXPixie Wrapper Lab: main HTML parsed.');
end;

procedure TagChecked(Sender: TObject; ID: Integer; Checked: Boolean);
begin
  if TagBatching then Exit;
  if Checked then
    SetStatus('FPixieTagBar.OnTagChecked: ID ' + IntToStr(ID) + ' checked.')
  else
    SetStatus('FPixieTagBar.OnTagChecked: ID ' + IntToStr(ID) + ' unchecked.');
end;

function ElementClick(Sender, El: TObject): Boolean; forward;

procedure ShowMessageForm;
begin
  if not MsgFormCreated then
  begin
    MsgForm.FCreateBlankForm(FMXForm.HandleHWND, $FF101827, '', True);
    MsgForm.Caption('FMXPixie - FMsgForm test');
    MsgForm.Width(420);
    MsgForm.Height(250);

    MsgView.FCreate(MsgForm.Handle);
    MsgView.SetBounds(0, 0, 420, 250);
    MsgView.ColorScheme(pcsDark);
    MsgView.HitTest(True);
    MsgView.OnElementClick(@ElementClick);
    MsgView.OnMouseDown(@MessageMouseDown);
    MsgView.LoadFromString(BuildMessageHtml);
    MsgFormCreated := True;
  end;
  MsgForm.Show;
end;

// ---------------------------------------------------------------------------
// Click dispatcher. It is shared by both HTML views.
// ---------------------------------------------------------------------------
function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
  TargetCount: Integer;
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

  if (Id = 'msg-close') or (Id = 'msg-close-button') then
  begin
    MsgForm.Close;
    Result := True;
    Exit;
  end;

  if Id = 'btn-count' then
  begin
    Inc(ClickCount);
    Doc.BeginUpdate;
    try
      SetTextById('click-count', IntToStr(ClickCount));
      SetTextById('query-result', 'The HTML click was dispatched to Inno Pascal Script.');
      SetStatus('FPixieHtmlView.OnElementClick + FPixieDocument.SetElementText executed.');
    finally
      Doc.EndUpdate;
    end;
    Result := True;
    Exit;
  end;

  if Id = 'btn-state' then
  begin
    SystemEnabled := not SystemEnabled;
    Doc.BeginUpdate;
    try
      if SystemEnabled then
      begin
        SetClassById('state-card', 'state-card is-on');
        SetTextById('state-value', 'ENABLED');
        SetStatus('Runtime state set to ENABLED; FPixieElement changed the CSS class.');
      end
      else
      begin
        SetClassById('state-card', 'state-card is-off');
        SetTextById('state-value', 'DISABLED');
        SetStatus('Runtime state set to DISABLED; FPixieElement changed the CSS class.');
      end;
    finally
      Doc.EndUpdate;
    end;
    Result := True;
    Exit;
  end;

  if Id = 'btn-query' then
  begin
    FoundList.FCreate(Doc.QuerySelectorAll('.query-target'));
    TargetCount := FoundList.Count;
    SetTextById('query-count', IntToStr(TargetCount));
    if TargetCount > 0 then
    begin
      Elem.FCreate(FoundList.Item(0));
      SetTextById('query-result', 'QuerySelectorAll found ' + IntToStr(TargetCount) +
        ' panels. First target: ' + Elem.GetAttr('id', '(no id)') + '.');
    end
    else
      SetTextById('query-result', 'QuerySelectorAll found no targets.');
    SetStatus('FPixieDocument.QuerySelectorAll + FPixieElementList.Count/Item executed.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-message' then
  begin
    ShowMessageForm;
    SetStatus('FMsgForm opened. Its client area is another FPixieHtmlView.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-svg-zoom' then
  begin
    if SvgZoomFactor < 1.25 then SvgZoomFactor := 1.25
    else if SvgZoomFactor < 1.5 then SvgZoomFactor := 1.5
    else SvgZoomFactor := 1.0;
    SvgView.Zoom(SvgZoomFactor);
    SetTextById('btn-svg-zoom', 'SVG zoom ' + IntToStr(Round(SvgZoomFactor * 100)) + '%');
    SetStatus('FPixieSvgView.Zoom set to ' + IntToStr(Round(SvgZoomFactor * 100)) + '%.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-svg-bg' then
  begin
    SvgDarkBackground := not SvgDarkBackground;
    if SvgDarkBackground then
    begin
      SvgView.ColorInner($FF101827);
      SvgView.ColorInnerBorder($FF30465F);
      SvgView.ColorCheckers($FF18263A);
    end
    else
    begin
      SvgView.ColorInner($FF192B3D);
      SvgView.ColorInnerBorder($FF62C8CC);
      SvgView.ColorCheckers($FF243B4D);
    end;
    SetStatus('FPixieSvgView background, border and checker colors changed.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-md-zoom' then
  begin
    if MarkdownZoomFactor < 1.1 then MarkdownZoomFactor := 1.1
    else if MarkdownZoomFactor < 1.2 then MarkdownZoomFactor := 1.2
    else MarkdownZoomFactor := 1.0;
    MarkdownView.Zoom(MarkdownZoomFactor);
    SetTextById('btn-md-zoom', 'MD zoom ' + IntToStr(Round(MarkdownZoomFactor * 100)) + '%');
    SetStatus('FPixieMarkdownView.Zoom set to ' + IntToStr(Round(MarkdownZoomFactor * 100)) + '%.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-md-styles' then
  begin
    MarkdownDefaults := not MarkdownDefaults;
    MarkdownView.SetUseDefaultStyles(MarkdownDefaults);
    if MarkdownDefaults then
      SetTextById('btn-md-styles', 'Default CSS: ON')
    else
      SetTextById('btn-md-styles', 'Default CSS: OFF');
    if MarkdownDefaults then
      SetStatus('FPixieMarkdownView.SetUseDefaultStyles changed to ON.')
    else
      SetStatus('FPixieMarkdownView.SetUseDefaultStyles changed to OFF.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-md-visible' then
  begin
    MarkdownVisible := not MarkdownVisible;
    MarkdownView.Visible(MarkdownVisible);
    if MarkdownVisible then
      SetTextById('btn-md-visible', 'Hide Markdown')
    else
      SetTextById('btn-md-visible', 'Show Markdown');
    SetStatus('FPixieMarkdownView.Visible changed.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-tags-all' then
  begin
    TagBatching := True;
    try
      TagBar.CheckAll;
    finally
      TagBatching := False;
    end;
    SetStatus('FPixieTagBar.CheckAll called; individual callbacks were batched by the demo.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-tags-none' then
  begin
    TagBatching := True;
    try
      TagBar.UncheckAll;
    finally
      TagBatching := False;
    end;
    SetStatus('FPixieTagBar.UncheckAll called; individual callbacks were batched by the demo.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-paint-grid' then
  begin
    DrawGrid := not DrawGrid;
    PaintBox.Repaint;
    if DrawGrid then SetTextById('btn-paint-grid', 'Grid: ON')
    else SetTextById('btn-paint-grid', 'Grid: OFF');
    SetStatus('FPixiePaintBox.Repaint requested after grid option changed.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-paint-color' then
  begin
    PaletteIndex := (PaletteIndex + 1) mod 3;
    PaintBox.BackgroundColor($FF0B1422);
    PaintBox.Repaint;
    SetStatus('PaintBox palette changed. Drawing primitives use a new accent palette.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-paint-repaint' then
  begin
    PaintPhase := (PaintPhase + 1) mod 6;
    PaintBox.Repaint;
    SetStatus('FPixiePaintBox.Repaint called. Paint callback count: ' + IntToStr(PaintCount) + '.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-paint-layer' then
  begin
    PaintFront := not PaintFront;
    if PaintFront then
    begin
      PaintBox.BringToFront;
      SetTextById('btn-paint-layer', 'Send to back');
    end
    else
    begin
      PaintBox.SendToBack;
      SetTextById('btn-paint-layer', 'Bring to front');
    end;
    SetStatus('FPixiePaintBox.BringToFront / SendToBack toggled.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-select' then
  begin
    View.SelectAll;
    SetStatus('FPixieHtmlView.SelectAll called. Click Clear selection to remove the selection.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-clear-select' then
  begin
    View.ClearSelection;
    SetStatus('FPixieHtmlView.ClearSelection called.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-reset' then
  begin
    ClickCount := 0;
    SystemEnabled := True;
    HtmlZoomFactor := 1.0;
    SvgZoomFactor := 1.0;
    MarkdownZoomFactor := 1.0;
    SvgDarkBackground := True;
    MarkdownDefaults := True;
    MarkdownVisible := True;
    DrawGrid := True;
    PaintFront := True;
    PaletteIndex := 0;
    PaintPhase := 0;
    PaintBox.FillBackground(True);
    PaintBox.BackgroundColor($FF0B1422);
    PaintBox.Opacity(1.0);
    PaintBox.Enabled(True);
    PaintBox.Visible(True);
    PaintBox.HitTest(False);
    PaintBox.BringToFront;
    SvgView.Zoom(SvgZoomFactor);
    SvgView.ColorInner($FF101827);
    SvgView.ColorInnerBorder($FF30465F);
    SvgView.ColorCheckers($FF18263A);
    MarkdownView.Zoom(MarkdownZoomFactor);
    MarkdownView.SetUseDefaultStyles(MarkdownDefaults);
    MarkdownView.Visible(True);
    View.Zoom(HtmlZoomFactor);
    Doc.BeginUpdate;
    try
      SetTextById('click-count', '0');
      SetTextById('query-count', '?');
      SetTextById('query-result', 'Ready. Use the controls to exercise the wrappers.');
      SetTextById('state-value', 'ENABLED');
      SetClassById('state-card', 'state-card is-on');
      SetTextById('btn-svg-zoom', 'SVG zoom 100%');
      SetTextById('btn-md-zoom', 'MD zoom 100%');
      SetTextById('btn-md-styles', 'Default CSS: ON');
      SetTextById('btn-md-visible', 'Hide Markdown');
      SetTextById('btn-paint-grid', 'Grid: ON');
      SetTextById('btn-paint-layer', 'Send to back');
      SetStatus('Demo reset. All wrappers remain attached to the shared FMX workspace.');
    finally
      Doc.EndUpdate;
    end;
    TagBatching := True;
    try
      TagBar.CheckAll;
    finally
      TagBatching := False;
    end;
    PaintBox.Repaint;
    Result := True;
    Exit;
  end;
end;

// ---------------------------------------------------------------------------
// Setup initialisation
// ---------------------------------------------------------------------------
procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  MsgForm := InitMsgFormHandle;
  TitleView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  MsgView := InitPixieHtmlView;
  Doc := InitPixieDocument;
  Elem := InitPixieElement;
  FoundList := InitPixieElementList;
  SvgView := InitPixieSvgView;
  MarkdownView := InitPixieMarkdownView;
  TagBar := InitPixieTagBar;
  PaintBox := InitPixiePaintBox;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure ConfigureSetupHost;
begin
  WizardForm.BorderStyle := bsNone;
  WizardForm.ClientWidth := DEMO_FORM_WIDTH;
  WizardForm.ClientHeight := DEMO_FORM_HEIGHT;
  WizardForm.Position := poScreenCenter;
end;

procedure InitializeWizard;
begin
  TempDir := ExpandConstant('{tmp}');
  UiReady := False;
  MsgFormCreated := False;
  TagBatching := False;
  ClickCount := 0;
  SystemEnabled := True;
  HtmlZoomFactor := 1.0;
  SvgZoomFactor := 1.0;
  MarkdownZoomFactor := 1.0;
  SvgDarkBackground := True;
  MarkdownDefaults := True;
  MarkdownVisible := True;
  DrawGrid := True;
  PaintFront := True;
  PaletteIndex := 0;
  PaintPhase := 0;
  PaintCount := 0;

  ConfigureSetupHost;
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('FMXPixie Wrapper Integration Lab');
  FMXForm.ChangeBorderColor($FF2A8092);
  FMXForm.StayOnTop(False);
  FMXForm.OnShow(@MainFormShown);
  FMXForm.OnActivate(@MainFormActivated);
  FMXForm.OnDeactivate(@MainFormDeactivated);

  // First create the base HTML surfaces so the native FMX wrappers can sit
  // above their reserved areas on the exact same form.
  TitleView.FCreate(FMXForm.Handle);
  TitleView.SetBounds(0, 0, DEMO_FORM_WIDTH, TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.HitTest(True);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@TitleMouseDown);
  TitleView.LoadFromString(BuildTitleHtml);

  View.FCreate(FMXForm.Handle);
  View.SetBounds(0, TITLEBAR_HEIGHT, DEMO_FORM_WIDTH,
    DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.BaseUrl(TempDir + '\');
  View.SetScrollbarWidth(6);
  View.SetScrollbarMargin(2);
  View.SetScrollbarVisibility(svAuto);
  View.SetAutoScrollSpeed(350);
  View.SetAutoScrollEdge(22);
  View.HitTest(True);
  View.Enabled(True);
  View.Visible(True);
  View.Opacity(1.0);
  View.OnElementClick(@ElementClick);
  View.OnAnchorClick(@MainAnchorClick);
  View.OnAfterParse(@AfterParse);
  View.LoadFromStringUrl(BuildMainHtml, TempDir + '\');

  Doc.FCreate(View.GetDocument);
  UiReady := True;

  // SVGView occupies the first reserved panel.
  SvgView.FCreate(FMXForm.Handle);
  SvgView.SetBounds(28, TITLEBAR_HEIGHT + 132, 200, 108);
  SvgView.SetClipParent(True);
  SvgView.SetClipChildren(True);
  SvgView.SvgAlign(saCenterBoth);
  SvgView.Zoom(SvgZoomFactor);
  SvgView.ColorInner($FF101827);
  SvgView.ColorInnerBorder($FF30465F);
  SvgView.ColorCheckers($FF18263A);
  SvgView.CheckersSize(10);
  SvgView.Opacity(1.0);
  SvgView.Enabled(True);
  SvgView.Visible(True);
  SvgView.HitTest(True);
  SvgView.OnClick(@SvgViewClicked);
  SvgView.LoadFromString(BuildSvgMarkup);

  // MarkdownView occupies the second reserved panel.
  MarkdownView.FCreate(FMXForm.Handle);
  MarkdownView.SetBounds(263, TITLEBAR_HEIGHT + 132, 367, 104);
  MarkdownView.SetClipParent(True);
  MarkdownView.SetClipChildren(True);
  MarkdownView.BaseUrl(TempDir + '\');
  MarkdownView.SetUseDefaultStyles(MarkdownDefaults);
  MarkdownView.UserCss('body{background:#111b2a;color:#dce8f5;font-family:Segoe UI,Arial,sans-serif;font-size:11px;}' +
    'h1,h2,h3{color:#9edee1;}a{color:#79d7df;}p,li{line-height:1.35;}');
  MarkdownView.Zoom(MarkdownZoomFactor);
  MarkdownView.Opacity(1.0);
  MarkdownView.Enabled(True);
  MarkdownView.Visible(True);
  MarkdownView.HitTest(True);
  MarkdownView.OnAnchorClick(@MarkdownAnchorClick);
  MarkdownView.OnClick(@MarkdownViewClicked);
  MarkdownView.LoadMarkdownFromString(BuildMarkdown, TempDir + '\');

  // TagBar is a real FMX control on the third panel; events update the shared
  // HTML status strip and never require rebuilding the surrounding layout.
  TagBar.FCreate(FMXForm.Handle);
  TagBar.SetBounds(663, TITLEBAR_HEIGHT + 132, 323, 89);
  TagBar.Options([tboShowAll, tboAllowCheck, tboShowColorSwatch]);
  TagBar.TagShape(tsPill);
  TagBar.AutoHeight(False);
  TagBar.ScrollMode(smAuto);
  TagBar.ShowBorder(True);
  TagBar.BackgroundColor($FF111B2A);
  TagBar.BorderColor($FF30445E);
  TagBar.FontFamily('Segoe UI');
  TagBar.FontSize(11);
  TagBar.EmptyMessage('Add or check a tag');
  TagIndex := TagBar.AddTagWithColor('HTML / CSS', $FF56C9D0);
  TagIndex := TagBar.AddTagWithColor('SVG', $FF9B8AFB);
  TagIndex := TagBar.AddTagWithColor('Markdown', $FF70D6A5);
  TagIndex := TagBar.AddTagWithColor('PaintBox', $FFFFC66D);
  TagIndex := TagBar.AddTagWithColor('DOM API', $FFF08CAF);
  TagBar.CheckAll;
  TagBar.OnTagChecked(@TagChecked);

  // PaintBox renders its demonstration primitives in its OnPaint callback.
  PaintBox.FCreate(FMXForm.Handle);
  PaintBox.SetBounds(28, TITLEBAR_HEIGHT + 328, 590, 205);
  PaintBox.Margins(0, 0, 0, 0);
  PaintBox.Padding(0, 0, 0, 0);
  PaintBox.SetHint('Pixie PaintBox: all drawing commands run from OnPaint.');
  PaintBox.SetClipParent(True);
  PaintBox.SetClipChildren(False);
  PaintBox.FillBackground(True);
  PaintBox.BackgroundColor($FF0B1422);
  PaintBox.PenColor($FF63D7D2);
  PaintBox.PenWidth(1);
  PaintBox.PenStyle(ppsSolid);
  PaintBox.BrushColor($FFFFFFFF);
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.FontFamily('Segoe UI');
  PaintBox.FontSize(10);
  PaintBox.FontColor($FFFFFFFF);
  PaintBox.FontStyle([]);
  PaintBox.Opacity(1.0);
  PaintBox.Enabled(True);
  PaintBox.Visible(True);
  PaintBox.HitTest(False);
  PaintBox.OnPaint(@PaintBoxDraw);
  PaintBox.BringToFront;

  // QuerySelectorAll / ElementList / Element are exercised immediately so
  // the DOM panel starts with meaningful information.
  FoundList.FCreate(Doc.QuerySelectorAll('.query-target'));
  SetTextById('query-count', IntToStr(FoundList.Count));
  SetTextById('query-result', 'DOM is ready. Click QuerySelectorAll or change any wrapper setting.');
  SetStatus('Ready. HTML View, DOM, SVG View, Markdown View, TagBar and PaintBox share one FMX form.');
  PaintBox.Repaint;
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
