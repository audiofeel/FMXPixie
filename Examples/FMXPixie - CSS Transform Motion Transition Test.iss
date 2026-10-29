; ============================================================================
; FMXPixie - CSS Transform Motion Transition Test
;
; Visual test for the first movement transition:
;   transition: transform 900ms linear;
;   transform: translate(x, y);   (one translate() op, explicit px values)
;
; Hover either rail to move the fixed-color block. Move outside the rail to
; reverse the transition. This is a visual behavior test, not a benchmark.
;
; Place in Examples beside Modules\FMXPixieHandle.iss and the architecture-
; matching FMXPixie DLL.
; ============================================================================

#define DemoAppName "FMXPixie - CSS Transform Motion Transition Test"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - CSS Transform Motion Transition Test
; Uncomment for an x64 build if required by your setup:
; SetupArchitecture=x64

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  TEST_FORM_WIDTH = 900;
  TEST_FORM_HEIGHT = 650;
  TITLEBAR_HEIGHT = 44;

var
  FMXForm: FForm;
  View: FPixieHtmlView;

function BuildMotionHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;width:100%;height:100%;overflow:hidden;}' +
    'body{background:#0b1220;color:#e5e7eb;font-family:"Segoe UI",Arial,sans-serif;font-size:14px;}' +
    '.titlebar{height:44px;padding:0 18px;display:flex;align-items:center;' +
    'background:#101827;border-bottom:1px solid #263248;color:#cbd5e1;' +
    'font-size:12px;letter-spacing:1.3px;text-transform:uppercase;}' +
    '.content{padding:20px 28px;}' +
    '.eyebrow{font-size:11px;letter-spacing:2px;color:#93c5fd;text-transform:uppercase;}' +
    'h1{font-size:25px;font-weight:600;margin:7px 0 6px;color:#f8fafc;}' +
    '.description{color:#9ca3af;line-height:1.5;margin:0 0 17px;}' +
    '.section-title{font-size:12px;letter-spacing:1px;text-transform:uppercase;' +
    'color:#cbd5e1;margin:0 0 8px;}' +
    '.rail{position:relative;width:100%;border:1px solid #334155;' +
    'border-radius:12px;background:#111c2f;overflow:hidden;}' +
    '#track-x{height:96px;}' +
    '#moving-x{position:absolute;left:8px;top:17px;width:132px;height:60px;' +
    'border:1px solid #93c5fd;border-radius:9px;background:#2563eb;' +
    'display:flex;align-items:center;justify-content:center;color:#fff;' +
    'font-weight:600;letter-spacing:.5px;transform:translate(0px,0px);' +
    'transition:transform 900ms linear;}' +
    '#track-x:hover #moving-x{transform:translate(560px,0px);}' +
    '#track-y{height:168px;}' +
    '#moving-y{position:absolute;left:22px;top:8px;width:132px;height:52px;' +
    'border:1px solid #86efac;border-radius:9px;background:#166534;' +
    'display:flex;align-items:center;justify-content:center;color:#fff;' +
    'font-weight:600;letter-spacing:.5px;transform:translate(0px,0px);' +
    'transition:transform 900ms linear;}' +
    '#track-y:hover #moving-y{transform:translate(0px,96px);}' +
    '.section{margin-top:16px;}' +
    '.note{margin-top:18px;padding-top:13px;border-top:1px solid #253248;' +
    'font-size:12px;color:#94a3b8;line-height:1.65;}' +
    '.code{font-family:Consolas,monospace;color:#bfdbfe;}' +
    '</style></head><body>' +
    '<div class="titlebar">FMXPixie / CSS Transform Motion Test</div>' +
    '<div class="content">' +
    '<div class="eyebrow">Visual transition test</div>' +
    '<h1>Movement, not color</h1>' +
    '<p class="description">Hover a rail to move its block. Move the pointer out of the rail to reverse the motion. The blocks keep the same colors and dimensions.</p>' +
    '<div class="section-title">Horizontal translate · 560 px</div>' +
    '<div id="track-x" class="rail"><div id="moving-x">MOVE X</div></div>' +
    '<div class="section">' +
    '<div class="section-title">Vertical translate · 96 px</div>' +
    '<div id="track-y" class="rail"><div id="moving-y">MOVE Y</div></div>' +
    '</div>' +
    '<div class="note">' +
    'Both examples use <span class="code">transition: transform 900ms linear</span> and an explicit ' +
    '<span class="code">translate(x, y)</span> in pixels. No JavaScript and no color transition are involved.<br>' +
    'If movement jumps instead of interpolating, stops partway, or leaves drawing artifacts, capture the window while testing and share the result.' +
    '</div></div></body></html>';
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if (Button = mbLeft) and (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TEST_FORM_WIDTH - 70) then
    FMXForm.StartWindowDrag;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  View := InitPixieHtmlView;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  EmptyWizardForm(TEST_FORM_WIDTH, TEST_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('FMXPixie - CSS Transform Motion Transition Test');

  View.FCreate(FMXForm.Handle);
  View.SetBounds(0, 0, TEST_FORM_WIDTH, TEST_FORM_HEIGHT);
  View.ColorScheme(pcsDark);
  View.OnMouseDown(@ViewMouseDown);
  View.LoadFromString(BuildMotionHtml);

  FMXForm.Show;
end;

procedure DeinitializeSetup;
begin
  FMXPixieShutDown;
end;
