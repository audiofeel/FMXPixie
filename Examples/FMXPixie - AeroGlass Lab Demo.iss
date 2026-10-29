; ============================================================================
; FMXPixie — AERO GLASS LAB
;
; A visual showcase of transparent, tinted-glass and gradient HTML/CSS surfaces
; rendered by Pixie inside a Windows Acrylic-backed FMX host form.
;
; The native window material is configured separately from the HTML surfaces.
; This build uses btAcrylic for the window. The three sample modes below change
; only CSS classes in the content document; they do not fake a system backdrop.
;
; The inspector is a separate HTML view/document. Hover callbacks update only
; the inspector, leaving CSS :hover in the sample document untouched.
;
; Requires the current working FMXPixie wrapper and hover callback bridge:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;
; This is a UI/API demo only. It does not install files.
; ============================================================================

#define DemoAppName "FMXPixie - AeroGlass Lab Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - AeroGlass Lab Demo
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
  DEMO_FORM_WIDTH = 1120;
  DEMO_FORM_HEIGHT = 760;
  TITLEBAR_HEIGHT = 42;
  TITLEBAR_BUTTONS_WIDTH = 92;
  MAIN_VIEW_WIDTH = 770;

var
  FMXForm: FForm;
  HeaderView: FPixieHtmlView;
  MainView: FPixieHtmlView;
  InspectorView: FPixieHtmlView;
  MainDoc: FPixieDocument;
  InspectorDoc: FPixieDocument;
  Elem: FPixieElement;
  TempDir: String;

  CurrentMaterial: String;
  CurrentMaterialLabel: String;
  HoverEnterCount: Integer;
  HoverLeaveCount: Integer;
  ClickCount: Integer;
  LastHoverEvent: String;
  LastHoverId: String;
  LastClickId: String;
  Recent1: String;
  Recent2: String;
  Recent3: String;
  DocumentsReady: Boolean;

function BuildHeaderHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:transparent;color:#eef6ff;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;}' +
    '.bar{position:relative;width:100%;height:42px;line-height:41px;overflow:hidden;' +
    'background:linear-gradient(100deg,rgba(8,16,31,.40),rgba(13,28,49,.18),rgba(23,39,66,.30));' +
    'border-bottom:1px solid rgba(204,229,255,.22);}' +
    '.logo{display:inline-block;vertical-align:middle;width:24px;height:24px;line-height:23px;' +
    'margin:0 10px 0 16px;text-align:center;border:1px solid rgba(143,220,255,.78);' +
    'border-radius:7px;background:linear-gradient(145deg,rgba(63,176,255,.65),rgba(92,91,226,.45));' +
    'color:#fff;font-size:13px;font-weight:bold;}' +
    '.brand{vertical-align:middle;color:#f2f7ff;font-size:12px;font-weight:700;letter-spacing:2.1px;}' +
    '.subbrand{vertical-align:middle;margin-left:11px;color:rgba(214,231,255,.62);font-size:9px;letter-spacing:1.25px;}' +
    '.window-controls{position:absolute;right:0;top:0;width:92px;height:41px;font-size:0;}' +
    '.window-button{display:inline-block;vertical-align:top;width:46px;height:41px;line-height:40px;' +
    'text-align:center;color:#e5efff;font-size:20px;cursor:pointer;}' +
    '.window-button:hover{background:rgba(160,204,255,.23);color:#fff;}' +
    '.window-close:hover{background:#c84155;color:#fff;}' +
    '</style></head><body><div class="bar">' +
    '<span class="logo">A</span><span class="brand">AERO / GLASS LAB</span>' +
    '<span class="subbrand">WINDOW MATERIALS · HTML/CSS · PIXIE EVENTS</span>' +
    '<div class="window-controls"><div id="title-minimize" class="window-button" title="Minimize">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Close">×</div></div>' +
    '</div></body></html>';
end;

function BuildMainHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:transparent;color:#edf5ff;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;}' +
    '.page{padding:21px 20px 16px 22px;}' +
    '.eyebrow{font-size:9px;font-weight:700;letter-spacing:2px;color:#8eddf2;text-transform:uppercase;}' +
    '.headline{margin:6px 0 6px 0;font-size:26px;line-height:1.08;font-weight:600;letter-spacing:-.7px;color:#f5f8ff;}' +
    '.intro{margin:0;color:rgba(219,233,255,.66);font-size:11px;line-height:1.48;max-width:600px;}' +
    '.top-tags{margin-top:11px;}' +
    '.tag{display:inline-block;margin-right:6px;padding:5px 8px;border:1px solid rgba(185,218,255,.22);' +
    'background:rgba(15,29,50,.18);color:rgba(224,239,255,.80);font-size:8px;font-weight:700;letter-spacing:.7px;}' +
    '.tag-accent{border-color:rgba(103,226,218,.45);background:rgba(43,179,185,.13);color:#aaf7ed;}' +
    '.work-grid{display:grid;grid-template-columns:1fr 205px;gap:13px;margin-top:18px;}' +
    '.stage-wrap{min-width:0;}' +
    '.section-line{display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;}' +
    '.section-name{color:rgba(226,240,255,.86);font-size:9px;font-weight:700;letter-spacing:1.4px;}' +
    '.section-hint{color:rgba(204,224,248,.45);font-size:9px;}' +
    '.stage{position:relative;height:330px;overflow:hidden;border:1px solid rgba(200,226,255,.25);' +
    'background:rgba(12,24,42,.10);}' +
    '.sample{position:relative;width:100%;height:100%;overflow:hidden;transition:background .15s ease;}' +
    '.sample.material-transparent{background:transparent;}' +
    '.sample.material-glass{background:linear-gradient(135deg,rgba(109,191,255,.24) 0%,rgba(70,88,170,.13) 53%,rgba(63,218,211,.15) 100%);}' +
    '.sample.material-gradient{background:linear-gradient(128deg,#176eb8 0%,#485ecb 47%,#148c9f 100%);}' +
    '.orb{position:absolute;border:1px solid rgba(224,244,255,.34);border-radius:50%;}' +
    '.orb-one{width:210px;height:210px;right:30px;top:34px;background:radial-gradient(circle at 34% 28%,rgba(165,234,255,.34),rgba(87,135,226,.08) 56%,rgba(30,57,100,.02) 75%);}' +
    '.orb-two{width:145px;height:145px;right:64px;top:65px;border-color:rgba(224,244,255,.28);background:linear-gradient(145deg,rgba(105,205,255,.20),rgba(138,112,255,.08));}' +
    '.orb-three{width:82px;height:82px;right:96px;top:96px;border-color:rgba(255,255,255,.36);background:linear-gradient(135deg,rgba(173,247,245,.52),rgba(65,138,246,.16));}' +
    '.orbit-line{position:absolute;width:270px;height:104px;right:1px;top:86px;border:1px solid rgba(177,232,255,.34);border-radius:50%;transform:rotate(-29deg);}' +
    '.preview-copy{position:absolute;left:22px;top:23px;width:54%;}' +
    '.preview-kicker{font-size:8px;font-weight:700;letter-spacing:1.8px;color:#a8e9f3;}' +
    '.preview-title{margin-top:8px;font-size:26px;line-height:1.08;font-weight:600;letter-spacing:-.6px;color:#f4f9ff;}' +
    '.preview-desc{margin-top:9px;max-width:280px;font-size:10px;line-height:1.5;color:rgba(226,240,255,.72);}' +
    '.preview-metrics{display:flex;gap:7px;margin-top:18px;}' +
    '.preview-metric{min-width:76px;padding:8px 9px;border:1px solid rgba(205,229,255,.26);background:rgba(8,21,39,.17);}' +
    '.preview-metric strong{display:block;font-size:14px;color:#fff;font-weight:600;}' +
    '.preview-metric span{display:block;margin-top:3px;color:rgba(213,231,255,.58);font-size:7px;letter-spacing:.8px;}' +
    '.preview-foot{position:absolute;left:22px;right:20px;bottom:17px;padding-top:9px;border-top:1px solid rgba(218,237,255,.20);' +
    'display:flex;justify-content:space-between;color:rgba(224,238,255,.55);font-size:8px;letter-spacing:.5px;}' +
    '.material-gradient .preview-kicker{color:#c5fff9;}.material-gradient .preview-desc{color:rgba(255,255,255,.82);}' +
    '.material-gradient .preview-metric{background:rgba(5,18,51,.18);border-color:rgba(255,255,255,.29);}' +
    '.material-gradient .orb-one{background:radial-gradient(circle at 34% 28%,rgba(255,255,255,.42),rgba(95,226,238,.12) 58%,rgba(30,57,100,.02) 75%);}' +
    '.material-gradient .orb-two{background:linear-gradient(145deg,rgba(255,255,255,.21),rgba(42,236,212,.10));}' +
    '.sample-note{margin-top:8px;color:rgba(204,225,250,.52);font-size:9px;line-height:1.4;}' +
    '.material-list{display:flex;flex-direction:column;gap:8px;}' +
    '.material-option{position:relative;display:block;width:100%;min-height:94px;padding:12px 12px 10px 12px;' +
    'border:1px solid rgba(203,226,255,.22);background:rgba(12,27,48,.18);color:#edf5ff;text-align:left;cursor:pointer;overflow:hidden;}' +
    '.material-option:hover{border-color:rgba(119,227,245,.72);background:rgba(41,106,142,.22);}' +
    '.material-option.active{border-color:rgba(113,226,247,.9);background:linear-gradient(135deg,rgba(53,158,208,.24),rgba(81,85,180,.13));}' +
    '.material-option.active:hover{border-color:#b5f6ff;background:linear-gradient(135deg,rgba(70,186,228,.38),rgba(94,115,216,.22));}' +
    '.material-option:hover .option-desc{color:#e4f7ff;}' +
    '.option-top{display:flex;align-items:center;justify-content:space-between;}' +
    '.option-name{font-size:10px;font-weight:700;letter-spacing:.45px;}' +
    '.option-number{color:rgba(201,224,255,.44);font-size:8px;letter-spacing:1px;}' +
    '.option-chip{display:block;width:100%;height:22px;margin-top:9px;border:1px solid rgba(219,239,255,.32);}' +
    '.chip-transparent{background:transparent;}' +
    '.chip-glass{background:linear-gradient(110deg,rgba(123,213,255,.40),rgba(101,105,218,.19),rgba(56,213,199,.24));}' +
    '.chip-gradient{background:linear-gradient(100deg,#1e87cb,#585bd6 55%,#27b4ad);}' +
    '.option-desc{display:block;margin-top:7px;color:rgba(213,231,255,.57);font-size:8px;line-height:1.4;}' +
    '.mini-panel{margin-top:14px;padding:12px;border:1px solid rgba(206,228,255,.18);background:linear-gradient(145deg,rgba(22,41,67,.26),rgba(29,58,76,.12));}' +
    '.mini-head{font-size:8px;font-weight:700;letter-spacing:1.2px;color:#aee8f1;}' +
    '.mini-copy{margin-top:6px;color:rgba(211,229,251,.60);font-size:9px;line-height:1.45;}' +
    '.bottom-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:9px;margin-top:15px;}' +
    '.info-card{min-height:88px;padding:12px;border:1px solid rgba(204,226,255,.20);background:rgba(9,24,42,.16);}' +
    '.info-label{color:rgba(200,225,255,.52);font-size:8px;font-weight:700;letter-spacing:1.2px;}' +
    '.info-value{margin-top:7px;color:#f0f7ff;font-size:12px;font-weight:600;}' +
    '.info-copy{margin-top:4px;color:rgba(206,224,247,.55);font-size:8px;line-height:1.4;}' +
    '.bottomline{display:flex;justify-content:space-between;margin-top:14px;padding-top:9px;border-top:1px solid rgba(204,228,255,.15);' +
    'color:rgba(192,218,248,.38);font-size:8px;letter-spacing:.7px;}' +
    '</style></head><body><div class="page">' +
    '<div class="eyebrow">NATIVE WINDOW MATERIAL / CSS COMPOSITION</div>' +
    '<div class="headline">The surface is the interface.</div>' +
    '<p class="intro">A live playground for transparent canvas, tinted glass and rich gradients. The Acrylic material belongs to the Windows host; Pixie draws the interface above it.</p>' +
    '<div class="top-tags"><span class="tag tag-accent">WINDOW BACKDROP · ACRYLIC</span><span class="tag">HTML/CSS · NO FMX CONTROLS INSIDE</span><span class="tag">INTERACTIVE DOM</span></div>' +
    '<div class="work-grid"><div class="stage-wrap">' +
    '<div class="section-line"><span class="section-name">01 / LIVE SURFACE PREVIEW</span><span class="section-hint">Choose a material below →</span></div>' +
    '<div class="stage"><div id="preview-surface" class="sample material-transparent">' +
    '<div class="orb orb-one"></div><div class="orb orb-two"></div><div class="orb orb-three"></div><div class="orbit-line"></div>' +
    '<div class="preview-copy"><div class="preview-kicker">AERO COMPOSITOR / 01</div>' +
    '<div class="preview-title">Light, layered.<br>Not boxed in.</div>' +
    '<div class="preview-desc">The panel underneath stays transparent. The visible color comes from the chosen CSS layer and the system material behind the window.</div>' +
    '<div class="preview-metrics"><div class="preview-metric"><strong>3</strong><span>SURFACES</span></div>' +
    '<div class="preview-metric"><strong>CSS</strong><span>HOVER STYLE</span></div><div class="preview-metric"><strong>LIVE</strong><span>PAS SCRIPT</span></div></div></div>' +
    '<div class="preview-foot"><span>PIXIE RENDER / SURFACE 001</span><span>WINDOW MATERIAL: ACRYLIC</span></div>' +
    '</div></div>' +
    '<div class="sample-note">Hover the preview choices. Their CSS highlight and the event monitor are independent: callbacks update the inspector document, not this surface document.</div>' +
    '</div><div><div class="section-line"><span class="section-name">02 / SURFACE MODES</span><span class="section-hint">Click to switch</span></div>' +
    '<div class="material-list">' +
    '<div id="material-transparent" class="material-option active"><span class="option-top"><span class="option-name">Transparent</span><span class="option-number">01</span></span>' +
    '<span class="option-chip chip-transparent"></span><span class="option-desc">Let the native window material show through.</span></div>' +
    '<div id="material-glass" class="material-option"><span class="option-top"><span class="option-name">Tinted glass</span><span class="option-number">02</span></span>' +
    '<span class="option-chip chip-glass"></span><span class="option-desc">A light blue-green tint with translucent layers.</span></div>' +
    '<div id="material-gradient" class="material-option"><span class="option-top"><span class="option-name">Gradient</span><span class="option-number">03</span></span>' +
    '<span class="option-chip chip-gradient"></span><span class="option-desc">A richer color surface when transparency is not enough.</span></div>' +
    '</div><div class="mini-panel"><div class="mini-head">ONE WINDOW · DIFFERENT SURFACES</div>' +
    '<div class="mini-copy">The native backdrop and the HTML surface are separate layers. Choose a mode to see the CSS background change without recreating the host form.</div></div>' +
    '</div></div>' +
    '<div class="bottom-grid"><div class="info-card"><div class="info-label">NATIVE LAYER</div><div class="info-value">Windows Acrylic</div><div class="info-copy">Created by the FMX host API, not by CSS blur.</div></div>' +
    '<div class="info-card"><div class="info-label">HTML LAYER</div><div class="info-value">Transparent by default</div><div class="info-copy">Selected panels add tint or gradient only where needed.</div></div>' +
    '<div class="info-card"><div class="info-label">EVENT BRIDGE</div><div class="info-value">ENTER / LEAVE / CLICK</div><div class="info-copy">Pixie element events are handled in Pascal Script.</div></div></div>' +
    '<div class="bottomline"><span>FMXPIXIE / AERO GLASS LAB</span><span>WINDOW: FMX · CONTENT: PIXIE HTML/CSS · LOGIC: INNO SETUP</span></div>' +
    '</div></body></html>';
end;

function BuildInspectorHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:transparent;color:#edf5ff;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;}' +
    '.inspector{height:100%;padding:19px 16px 15px 3px;}' +
    '.glass-panel{height:100%;padding:16px 14px;border:1px solid rgba(200,228,255,.24);' +
    'background:linear-gradient(155deg,rgba(12,28,48,.46),rgba(19,47,68,.25),rgba(29,31,67,.30));}' +
    '.eyebrow{font-size:8px;font-weight:700;letter-spacing:1.6px;color:#9fe6f0;}' +
    '.title{margin-top:6px;font-size:20px;line-height:1.1;font-weight:600;color:#f2f7ff;}' +
    '.copy{margin-top:7px;font-size:9px;line-height:1.45;color:rgba(211,231,252,.59);}' +
    '.live{display:flex;align-items:center;margin-top:12px;padding:7px 8px;border:1px solid rgba(96,223,193,.30);background:rgba(37,172,147,.10);}' +
    '.live-dot{width:6px;height:6px;border-radius:50%;background:#70ead4;margin-right:7px;}' +
    '.live-text{color:#b7f7e8;font-size:8px;font-weight:700;letter-spacing:.8px;}' +
    '.section{margin-top:17px;padding-top:12px;border-top:1px solid rgba(204,226,255,.17);}' +
    '.section-title{margin-bottom:9px;color:rgba(209,229,251,.53);font-size:8px;font-weight:700;letter-spacing:1.4px;}' +
    '.metric-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;}' +
    '.metric{padding:10px;border:1px solid rgba(204,229,255,.17);background:rgba(10,24,42,.23);}' +
    '.metric-number{font-size:24px;font-weight:600;line-height:1;color:#f5faff;}' +
    '.metric-name{margin-top:6px;font-size:8px;color:rgba(207,228,252,.56);letter-spacing:.6px;}' +
    '.wide-metric{margin-top:8px;padding:10px;border:1px solid rgba(204,229,255,.17);background:rgba(10,24,42,.18);}' +
    '.wide-label{color:rgba(207,228,252,.48);font-size:8px;font-weight:700;letter-spacing:1px;}' +
    '.wide-value{margin-top:6px;color:#dff6ff;font-size:11px;font-weight:600;overflow:hidden;}' +
    '.state-row{display:flex;align-items:center;justify-content:space-between;margin-top:8px;padding:8px 0;border-bottom:1px solid rgba(204,226,255,.10);}' +
    '.state-row:last-child{border-bottom:0;}' +
    '.state-key{font-size:9px;color:rgba(202,224,249,.53);}' +
    '.state-value{font-size:9px;color:#eff8ff;font-weight:600;text-align:right;}' +
    '.history{margin:0;padding:0;list-style:none;}' +
    '.history li{padding:8px 0;border-bottom:1px solid rgba(204,226,255,.09);font-size:9px;color:rgba(224,239,255,.76);}' +
    '.history li:last-child{border-bottom:0;}' +
    '.footer-note{margin-top:15px;padding:10px;border:1px solid rgba(200,226,255,.14);background:rgba(6,20,37,.16);' +
    'color:rgba(206,228,250,.49);font-size:8px;line-height:1.5;}' +
    '</style></head><body><div class="inspector"><div class="glass-panel">' +
    '<div class="eyebrow">03 / EVENT INSPECTOR</div><div class="title">Live telemetry</div>' +
    '<div class="copy">The monitor is another HTML document. It receives the callback results without rewriting the document currently under the cursor.</div>' +
    '<div class="live"><span class="live-dot"></span><span class="live-text" id="callback-status">LISTENING FOR PIXIE EVENTS</span></div>' +
    '<div class="section"><div class="section-title">ELEMENT CALLBACKS</div><div class="metric-grid">' +
    '<div class="metric"><div class="metric-number" id="enter-count">0</div><div class="metric-name">MEENTER</div></div>' +
    '<div class="metric"><div class="metric-number" id="leave-count">0</div><div class="metric-name">MELEAVE</div></div></div>' +
    '<div class="wide-metric"><div class="wide-label">LAST HOVER EVENT</div><div class="wide-value" id="last-event">Waiting for hover…</div></div>' +
    '<div class="state-row"><span class="state-key">Element ID</span><span class="state-value" id="last-hover-id">—</span></div>' +
    '<div class="state-row"><span class="state-key">Current surface</span><span class="state-value" id="current-material">Transparent</span></div>' +
    '<div class="state-row"><span class="state-key">Clicks</span><span class="state-value" id="click-count">0</span></div>' +
    '<div class="state-row"><span class="state-key">Last clicked</span><span class="state-value" id="last-click-id">—</span></div></div>' +
    '<div class="section"><div class="section-title">RECENT EVENTS</div><ul class="history">' +
    '<li id="history-1">Ready / waiting for first event</li><li id="history-2">—</li><li id="history-3">—</li></ul></div>' +
    '<div class="footer-note">CSS :hover is still handled by Pixie. The counters here are updated by Inno Setup through OnElementMouseEvent. No JavaScript is used.</div>' +
    '</div></div></body></html>';
end;

function IsTrackedId(const Id: String): Boolean;
begin
  Result := (Id = 'material-transparent') or (Id = 'material-glass') or
    (Id = 'material-gradient') or (Id = 'title-minimize') or
    (Id = 'title-close');
end;

function MaterialLabel(const Material: String): String;
begin
  if Material = 'glass' then
    Result := 'Tinted glass'
  else if Material = 'gradient' then
    Result := 'Gradient'
  else
    Result := 'Transparent';
end;

procedure SetInspectorText(const Id, Value: String);
var
  H: NativeInt;
begin
  H := InspectorDoc.GetElementById(Id);
  if H <> 0 then
    InspectorDoc.SetElementText(H, Value);
end;

procedure SetMainClass(const Id, Value: String);
var
  H: NativeInt;
begin
  H := MainDoc.GetElementById(Id);
  if H = 0 then
    Exit;
  Elem.FCreate(H);
  Elem.SetAttr('class', Value);
end;

procedure UpdateInspector;
begin
  if not DocumentsReady then
    Exit;
  InspectorDoc.BeginUpdate;
  try
    SetInspectorText('enter-count', IntToStr(HoverEnterCount));
    SetInspectorText('leave-count', IntToStr(HoverLeaveCount));
    SetInspectorText('click-count', IntToStr(ClickCount));
    SetInspectorText('callback-status', 'CALLBACK CONNECTED / LIVE');
    SetInspectorText('last-event', LastHoverEvent);
    SetInspectorText('last-hover-id', LastHoverId);
    SetInspectorText('current-material', CurrentMaterialLabel);
    SetInspectorText('last-click-id', LastClickId);
    SetInspectorText('history-1', Recent1);
    SetInspectorText('history-2', Recent2);
    SetInspectorText('history-3', Recent3);
  finally
    InspectorDoc.EndUpdate;
  end;
  InspectorDoc.Changed;
end;

procedure SelectMaterial(const Material: String);
begin
  CurrentMaterial := Material;
  CurrentMaterialLabel := MaterialLabel(Material);

  MainDoc.BeginUpdate;
  try
    SetMainClass('preview-surface', 'sample material-' + Material);
    if Material = 'transparent' then
      SetMainClass('material-transparent', 'material-option active')
    else
      SetMainClass('material-transparent', 'material-option');
    if Material = 'glass' then
      SetMainClass('material-glass', 'material-option active')
    else
      SetMainClass('material-glass', 'material-option');
    if Material = 'gradient' then
      SetMainClass('material-gradient', 'material-option active')
    else
      SetMainClass('material-gradient', 'material-option');
  finally
    MainDoc.EndUpdate;
  end;
  MainDoc.Changed;
  UpdateInspector;
end;

procedure ViewElementMouseEvent(Sender, El: TObject; Event: TPixieMouseEvent);
var
  Id, EventName: String;
begin
  if El = nil then
    Exit;
  Elem.FCreate(NativeInt(El));
  Id := Elem.GetAttr('id', '');
  if not IsTrackedId(Id) then
    Exit;

  if Event = meEnter then
  begin
    HoverEnterCount := HoverEnterCount + 1;
    EventName := 'meEnter';
  end
  else if Event = meLeave then
  begin
    HoverLeaveCount := HoverLeaveCount + 1;
    EventName := 'meLeave';
  end
  else
    Exit;

  LastHoverEvent := EventName + ' / ' + Id;
  LastHoverId := Id;
  Recent3 := Recent2;
  Recent2 := Recent1;
  Recent1 := EventName + '  |  ' + Id;
  UpdateInspector;
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
    WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
    Result := True;
    Exit;
  end;

  if (Id = 'material-transparent') or (Id = 'material-glass') or
     (Id = 'material-gradient') then
  begin
    Inc(ClickCount);
    LastClickId := Id;
    if Id = 'material-transparent' then
      SelectMaterial('transparent')
    else if Id = 'material-glass' then
      SelectMaterial('glass')
    else
      SelectMaterial('gradient');
    UpdateInspector;
    Result := True;
    Exit;
  end;
end;

procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;
  if (X < HeaderView.GetWidth - TITLEBAR_BUTTONS_WIDTH) and
     (Y >= 0) and (Y < TITLEBAR_HEIGHT) then
    FMXForm.StartWindowDrag;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  HeaderView := InitPixieHtmlView;
  MainView := InitPixieHtmlView;
  InspectorView := InitPixieHtmlView;
  MainDoc := InitPixieDocument;
  InspectorDoc := InitPixieDocument;
  Elem := InitPixieElement;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  TempDir := ExpandConstant('{tmp}');
  CurrentMaterial := 'transparent';
  CurrentMaterialLabel := 'Transparent';
  HoverEnterCount := 0;
  HoverLeaveCount := 0;
  ClickCount := 0;
  LastHoverEvent := 'Waiting for hover…';
  LastHoverId := '—';
  LastClickId := '—';
  Recent1 := 'Ready / waiting for first event';
  Recent2 := '—';
  Recent3 := '—';
  DocumentsReady := False;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);

  { This is the actual native window material. Change btAcrylic only to a
    backdrop value that exists in your current FMXPixieHandle.iss if you want
    to compare another Windows material. }
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btAcrylic, True, True);

  HeaderView.FCreate(FMXForm.Handle);
  HeaderView.Left(0);
  HeaderView.Top(0);
  HeaderView.Width(DEMO_FORM_WIDTH);
  HeaderView.Height(TITLEBAR_HEIGHT);
  HeaderView.ColorScheme(pcsDark);
  HeaderView.BaseUrl(TempDir + '\');
  HeaderView.OnElementClick(@ElementClick);
  HeaderView.OnElementMouseEvent(@ViewElementMouseEvent);
  HeaderView.OnMouseDown(@HeaderMouseDown);
  HeaderView.LoadFromStringUrl(BuildHeaderHtml, TempDir + '\');

  MainView.FCreate(FMXForm.Handle);
  MainView.Left(0);
  MainView.Top(TITLEBAR_HEIGHT);
  MainView.Width(MAIN_VIEW_WIDTH);
  MainView.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  MainView.ColorScheme(pcsDark);
  MainView.BaseUrl(TempDir + '\');
  MainView.OnElementClick(@ElementClick);
  MainView.OnElementMouseEvent(@ViewElementMouseEvent);
  MainView.LoadFromStringUrl(BuildMainHtml, TempDir + '\');

  InspectorView.FCreate(FMXForm.Handle);
  InspectorView.Left(MAIN_VIEW_WIDTH);
  InspectorView.Top(TITLEBAR_HEIGHT);
  InspectorView.Width(DEMO_FORM_WIDTH - MAIN_VIEW_WIDTH);
  InspectorView.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  InspectorView.ColorScheme(pcsDark);
  InspectorView.BaseUrl(TempDir + '\');
  InspectorView.LoadFromStringUrl(BuildInspectorHtml, TempDir + '\');

  MainDoc.FCreate(MainView.GetDocument);
  InspectorDoc.FCreate(InspectorView.GetDocument);
  DocumentsReady := True;
  SelectMaterial('transparent');
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
