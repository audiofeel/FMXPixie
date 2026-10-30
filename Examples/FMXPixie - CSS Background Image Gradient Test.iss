; ============================================================================
; FMXPixie - CSS Background Image + Gradient Overlay Test
;
; Verifies a full-form background made from two CSS image layers:
;   1) semi-transparent linear-gradient() on top;
;   2) a local image underneath, scaled with background-size: cover.
;
; The SVG is a bundled test asset. Replace it with a game screenshot
; (PNG/JPG/WebP) in [Files] and in the url(...) below.
;
; Build from the Examples directory beside Modules\\ and Files\\.
; ============================================================================

#define DemoAppName "FMXPixie - CSS Background Image Gradient Test"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - CSS Background Image Gradient Test
//SetupArchitecture=x64
SetupIconFile=Files\\setup.ico

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
Source: "Files\\FMXPixie_SvgView_Demo.svg"; Flags: dontcopy

[Code]
#include "Modules\\FMXPixieHandle.iss"

const
  TEST_FORM_WIDTH = 1100;
  TEST_FORM_HEIGHT = 760;
  TITLEBAR_HEIGHT = 42;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  View: FPixieHtmlView;
  Elem: FPixieElement;

function BuildTestHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'html{background-color:#07101d;}' +
    'body{background-color:#07101d;color:#f0f5fa;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;' +
      'background-image:linear-gradient(180deg,rgba(4,10,22,.18) 0%,rgba(4,10,22,.42) 48%,rgba(4,10,22,.90) 100%),url("FMXPixie_SvgView_Demo.svg");' +
      'background-position:center center;background-size:cover;background-repeat:no-repeat;}' +
    '.titlebar{position:absolute;left:0;top:0;width:100%;height:42px;line-height:41px;' +
      'background:rgba(5,11,22,.58);border-bottom:1px solid rgba(190,220,255,.18);}' +
    '.brand{margin-left:17px;color:#a5e8ff;font-size:10px;font-weight:bold;letter-spacing:1.5px;}' +
    '.subtitle{margin-left:13px;color:#a4b6ca;font-size:10px;}' +
    '.window-controls{position:absolute;right:0;top:0;width:92px;height:41px;font-size:0;}' +
    '.window-button{display:inline-block;vertical-align:top;width:46px;height:41px;line-height:40px;text-align:center;' +
      'font-size:19px;color:#e4edf7;cursor:pointer;}' +
    '.window-button:hover{background:rgba(130,170,210,.22);}' +
    '.window-close:hover{background:#b83e4b;}' +
    '.hero{position:absolute;left:48px;bottom:45px;width:690px;padding:25px 28px 23px;' +
      'border:1px solid rgba(185,220,255,.25);border-radius:12px;background:rgba(5,12,25,.62);}' +
    '.eyebrow{color:#72d9ed;font-size:9px;font-weight:bold;letter-spacing:2px;}' +
    '.headline{margin-top:9px;color:#f7fbff;font-size:27px;font-weight:600;letter-spacing:-.4px;}' +
    '.copy{margin-top:10px;color:#c4d1df;font-size:12px;line-height:1.55;}' +
    '.chips{margin-top:17px;font-size:0;}' +
    '.chip{display:inline-block;margin-right:7px;padding:6px 9px;border:1px solid rgba(135,195,230,.32);' +
      'border-radius:5px;background:rgba(15,38,58,.72);color:#b9e8f7;font-size:9px;letter-spacing:.6px;}' +
    '.footnote{position:absolute;right:24px;bottom:20px;color:rgba(225,237,248,.72);font-size:9px;letter-spacing:.7px;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
      '<span class="brand">FMXPIXIE / CSS BACKGROUND LAB</span>' +
      '<span class="subtitle">IMAGE + TRANSPARENT GRADIENT OVERLAY</span>' +
      '<div class="window-controls">' +
        '<div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
        '<div id="title-close" class="window-button window-close" title="Закрыть">×</div>' +
      '</div>' +
    '</div>' +
    '<div class="hero">' +
      '<div class="eyebrow">FULL-FORM BACKGROUND / TWO CSS IMAGE LAYERS</div>' +
      '<div class="headline">Изображение на всю форму</div>' +
      '<div class="copy">На фоне находится локальное SVG-изображение. Поверх него отдельным верхним слоем нарисован полупрозрачный градиент: сверху он почти прозрачен, снизу затемняет картинку под текстом. Изображение масштабируется по принципу cover и центрируется.</div>' +
      '<div class="chips">' +
        '<span class="chip">LINEAR-GRADIENT()</span>' +
        '<span class="chip">URL IMAGE</span>' +
        '<span class="chip">BACKGROUND-SIZE: COVER</span>' +
        '<span class="chip">BACKGROUND-POSITION: CENTER</span>' +
      '</div>' +
    '</div>' +
    '<div class="footnote">TEST ASSET: FMXPIXIE_SVGVIEW_DEMO.SVG</div>' +
    '</body></html>';
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
  end
  else if Id = 'title-close' then
  begin
    CloseSetup;
    Result := True;
  end;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < View.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

procedure InitializeWizard;
var
  TempDir: String;
begin
  ExtractTemporaryFile('FMXPixie_SvgView_Demo.svg');
  TempDir := ExpandConstant('{tmp}\\');

  EmptyWizardForm(TEST_FORM_WIDTH, TEST_FORM_HEIGHT);

  FMXForm := InitFormHandle;
  View := InitPixieHtmlView;
  Elem := InitPixieElement;

  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);

  View.FCreate(FMXForm.Handle);
  View.Left(0);
  View.Top(0);
  View.Width(TEST_FORM_WIDTH);
  View.Height(TEST_FORM_HEIGHT);
  View.ColorScheme(pcsDark);
  View.BaseUrl(TempDir);
  View.OnElementClick(@ElementClick);
  View.OnMouseDown(@ViewMouseDown);
  View.LoadFromStringUrl(BuildTestHtml, TempDir);

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
