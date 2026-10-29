; ============================================================================
; FMXPixie - CSS Transform / Display Link Test
;
; Purpose:
;   Isolate CSS translate/scale transitions from GIF/WebP animation.
;   FAnimTimer stays dedicated to animated images; CSS transform transitions are
;   interpolated from elapsed time on the FMX Display Link.
;
; Test:
;   1. Move the mouse over each card, then move it away.
;   2. Repeat quickly on the same card and between cards.
;   3. Compare linear, ease-in-out, and delayed longhand transitions.
;   4. Check smooth translation/scaling in both directions and quick retargeting.
;
; Build this file from the Examples directory beside Modules\ and Files\.
; ============================================================================

#define DemoAppName "FMXPixie - CSS Transform DisplayLink Test"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - CSS Transform DisplayLink Test
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
  TEST_FORM_WIDTH = 860;
  TEST_FORM_HEIGHT = 610;
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
    'body{background:#0b1220;color:#e5edf7;font-family:"Segoe UI",Arial,sans-serif;font-size:14px;}' +
    '.titlebar{position:relative;height:42px;line-height:41px;background:#111b2e;border-bottom:1px solid #263750;overflow:hidden;}' +
    '.brand{margin-left:16px;color:#8fc8ff;font-size:12px;font-weight:bold;letter-spacing:1.1px;}' +
    '.subtitle{margin-left:12px;color:#91a0b5;font-size:11px;}' +
    '.window-controls{position:absolute;right:0;top:0;width:92px;height:41px;font-size:0;}' +
    '.window-button{display:inline-block;vertical-align:top;width:46px;height:41px;line-height:40px;text-align:center;font-size:20px;color:#d8e2f0;cursor:pointer;}' +
    '.window-button:hover{background:#263750;color:#fff;}' +
    '.window-close:hover{background:#c43c4a;color:#fff;}' +
    '.page{padding:22px 24px;}' +
    '.eyebrow{color:#67d5c3;font-size:10px;font-weight:bold;letter-spacing:1.8px;}' +
    '.headline{margin-top:7px;font-size:26px;font-weight:600;letter-spacing:-.5px;color:#f5f8fc;}' +
    '.intro{margin-top:7px;max-width:760px;color:#a9b8cb;font-size:12px;line-height:1.5;}' +
    '.grid{display:flex;margin-top:23px;}' +
    '.card{position:relative;width:32%;height:206px;margin-right:2%;padding:17px;border:1px solid #3b4b65;background:#17243a;overflow:hidden;}' +
    '.card:last-child{margin-right:0;}' +
    '.card-index{font-size:10px;font-weight:bold;letter-spacing:1.3px;color:#8ba0bc;}' +
    '.card-title{margin-top:23px;font-size:19px;font-weight:600;color:#f1f6fc;}' +
    '.card-copy{margin-top:8px;color:#acbbcf;font-size:12px;line-height:1.5;}' +
    '.card-hint{position:absolute;left:17px;right:17px;bottom:16px;padding-top:10px;border-top:1px solid #3b4b65;color:#8fc8ff;font-size:10px;letter-spacing:.8px;}' +
    '#linear{transform:translate(0px,0px) scale(1);transition:transform 320ms linear;}' +
    '#linear:hover{transform:translate(26px,8px) scale(1.02);}' +
    '#eased{transform:translate(0px,0px) scale(1);transition:transform 280ms ease-out;}' +
    '#eased:hover{transform:translate(0px,-7px) scale(1.07);}' +
    '#delayed{transform:translate(0px,0px) scale(1);transition-property:transform;transition-duration:320ms;transition-timing-function:ease-out;transition-delay:80ms;}' +
    '#delayed:hover{transform:translate(-18px,8px) scale(0.94);}' +
    '.note{margin-top:22px;padding:13px 15px;border:1px solid #293d58;background:#101b2e;color:#a9b8cb;font-size:11px;line-height:1.55;}' +
    '.note strong{color:#d7eaff;}' +
    '.footer{margin-top:18px;padding-top:10px;border-top:1px solid #263750;color:#72859f;font-size:9px;letter-spacing:.7px;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="brand">FMXPIXIE / TRANSITION LAB</span>' +
    '<span class="subtitle">CSS translate + scale + FMX Display Link</span>' +
    '<div class="window-controls">' +
    '<div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Закрыть">×</div>' +
    '</div></div>' +
    '<div class="page">' +
    '<div class="eyebrow">ISOLATED REGRESSION TEST</div>' +
    '<div class="headline">CSS transform transition</div>' +
    '<div class="intro">Наведите курсор на карточку и уберите его. Здесь анимируется геометрия: одна карточка смещается, вторая увеличивается, третья перемещается и уменьшается. Края карточек помогают увидеть пропущенные кадры.</div>' +
    '<div class="grid">' +
    '<div id="linear" class="card"><div class="card-index">TEST 01 / TRANSLATE</div><div class="card-title">Linear move</div><div class="card-copy">Смещение на 26 × 8 px за 320 мс с постоянной скоростью.</div><div class="card-hint">HOVER → MOVE → RETURN</div></div>' +
    '<div id="eased" class="card"><div class="card-index">TEST 02 / SCALE</div><div class="card-title">Ease scale</div><div class="card-copy">Увеличение до 107% за 280 мс с замедлением к концу.</div><div class="card-hint">HOVER → GROW → RETURN</div></div>' +
    '<div id="delayed" class="card"><div class="card-index">TEST 03 / COMBINED</div><div class="card-title">Move + shrink</div><div class="card-copy">Задержка 80 мс, смещение и уменьшение до 94%.</div><div class="card-hint">HOVER → WAIT → MOVE</div></div>' +
    '</div>' +
    '<div class="note"><strong>Проверяйте именно плавность:</strong> повторно наведите курсор до завершения движения; быстро переводите его между карточками; отследите равномерность перемещения и изменение размера. Таймер GIF/WebP остаётся отдельным от CSS Display Link.</div>' +
    '<div class="footer">FMXPIXIE · CSS TRANSFORM · TRANSLATE + SCALE · NO JAVASCRIPT</div>' +
    '</div></body></html>';
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
begin
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
  View.OnElementClick(@ElementClick);
  View.OnMouseDown(@ViewMouseDown);
  View.LoadFromString(BuildTestHtml);

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
