; ============================================================================
; FMXPixie - CSS Size Layout Transition Test
;
; Regression coverage for layout-aware CSS width/height transitions.
; Hover the boxes to check changing dimensions and sibling reflow.
;
; This branch also retains the opacity, background-color and transform
; DisplayLink transitions covered by the separate general transition test.
;
; Build from the Examples directory beside Modules\ and Files\.
; ============================================================================

#define DemoAppName "FMXPixie - CSS Size Layout Transition Test"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - CSS Size Layout Transition Test
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
  TEST_FORM_WIDTH = 1080;
  TEST_FORM_HEIGHT = 740;
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
    'body{background:#0b1120;color:#e5edf7;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.titlebar{position:relative;height:42px;line-height:41px;background:#101a2b;border-bottom:1px solid #263852;overflow:hidden;}' +
    '.brand{margin-left:16px;color:#88c9ff;font-size:11px;font-weight:bold;letter-spacing:1.5px;}' +
    '.subtitle{margin-left:13px;color:#8498b4;font-size:10px;}' +
    '.window-controls{position:absolute;right:0;top:0;width:92px;height:41px;font-size:0;}' +
    '.window-button{display:inline-block;vertical-align:top;width:46px;height:41px;line-height:40px;text-align:center;font-size:19px;color:#d8e2f0;cursor:pointer;transition:background-color 150ms ease-out;}' +
    '.window-button:hover{background-color:#263750;}' +
    '.window-close:hover{background-color:#c43c4a;}' +
    '.page{padding:21px 26px;}' +
    '.eyebrow{color:#62d8c3;font-size:9px;font-weight:bold;letter-spacing:2px;}' +
    '.headline{margin-top:5px;font-size:25px;font-weight:600;letter-spacing:-.4px;color:#f4f7fc;}' +
    '.intro{margin-top:7px;max-width:970px;color:#a4b4ca;font-size:11px;line-height:1.5;}' +
    '.section-title{margin-top:16px;margin-bottom:8px;color:#80c5ff;font-size:9px;font-weight:bold;letter-spacing:1.3px;}' +
    '.inline-row{font-size:0;line-height:0;white-space:normal;}' +
    '.grow-inline{display:inline-block;vertical-align:top;width:220px;height:78px;margin-right:10px;padding:12px;border:1px solid #3c5876;background:#152238;color:#e5edf7;font-size:11px;line-height:1.4;transition:width 240ms ease-out,height 240ms ease-out,background-color 180ms ease-out;}' +
    '.grow-inline:hover{width:330px;height:112px;background-color:#1e3a5f;}' +
    '.inline-neighbor{display:inline-block;vertical-align:top;width:200px;height:78px;padding:12px;border:1px solid #344661;background:#101a2b;color:#a9b9ce;font-size:11px;line-height:1.4;}' +
    '.stack{margin-top:2px;}' +
    '.grow-height{display:block;width:280px;height:48px;padding:11px;border:1px solid #3c5876;background:#152238;color:#e5edf7;overflow:hidden;transition:height 260ms ease-out,background-color 180ms ease-out;}' +
    '.grow-height:hover{height:108px;background-color:#164e63;}' +
    '.after-height{display:block;width:470px;height:38px;margin-top:10px;padding:10px;border:1px solid #344661;background:#101a2b;color:#a9b9ce;font-size:10px;line-height:1.4;}' +
    '.width-only{display:block;width:280px;height:42px;margin-top:13px;padding:10px;border:1px solid #3c5876;background:#152238;color:#e5edf7;transition:width 240ms ease-out,background-color 180ms ease-out;}' +
    '.width-only:hover{width:430px;background-color:#3b2b59;}' +
    '.note{margin-top:15px;padding:10px 13px;border:1px solid #2a3b55;background:#101a2b;color:#a7b8ce;font-size:10px;line-height:1.5;}' +
    '.note strong{color:#d8eaff;}' +
    '.footer{margin-top:10px;padding-top:8px;border-top:1px solid #263852;color:#7185a0;font-size:8px;letter-spacing:.8px;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="brand">FMXPIXIE / CSS SIZE TRANSITIONS</span>' +
    '<span class="subtitle">DisplayLink layout test · hover the boxes</span>' +
    '<div class="window-controls">' +
    '<div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Закрыть">×</div>' +
    '</div></div>' +
    '<div class="page">' +
    '<div class="eyebrow">CSS TRANSITIONS / LAYOUT-AWARE SIZE</div>' +
    '<div class="headline">Анимация размеров с перерасчётом layout</div>' +
    '<div class="intro">Здесь меняется не визуальный масштаб: движок каждый кадр получает промежуточные width/height и заново раскладывает элементы. Проверьте горизонтальный сдвиг соседа, вертикальное смещение следующего блока и независимую анимацию ширины.</div>' +
    '<div class="section-title">01 / WIDTH + HEIGHT — INLINE SIBLING</div>' +
    '<div class="inline-row">' +
    '<div id="size-inline" class="grow-inline"><strong>Наведи курсор</strong><br>Ширина: 220 → 330 px<br>Высота: 78 → 112 px<br>Сосед справа должен плавно сместиться.</div>' +
    '<div class="inline-neighbor">Соседний inline-block<br>Его позиция зависит от текущей ширины первого блока.</div>' +
    '</div>' +
    '<div class="section-title">02 / HEIGHT — FOLLOWING BLOCK</div>' +
    '<div class="stack">' +
    '<div id="size-height" class="grow-height"><strong>Наведи курсор</strong><br>Высота: 48 → 108 px</div>' +
    '<div class="after-height">Следующий блок должен плавно опускаться и возвращаться вместе с высотой верхнего элемента.</div>' +
    '</div>' +
    '<div class="section-title">03 / WIDTH ONLY</div>' +
    '<div id="size-width" class="width-only">Ширина: 280 → 430 px. Текст и рамка должны перестраиваться в реальном layout.</div>' +
    '<div class="note"><strong>Границы первой реализации:</strong> transition поддерживает явные вычисленные абсолютные размеры в px (включая абсолютные единицы, преобразованные в px). Значения auto, проценты и calc()/min()/max()/clamp() пока меняются дискретно. Opacity, background-color и transform остаются на существующем DisplayLink-механизме.</div>' +
    '<div class="footer">FMXPIXIE · CSS WIDTH/HEIGHT TRANSITIONS · LAYOUT RECALCULATED PER DISPLAY LINK FRAME · GIF/WEBP AND SCROLLBAR TIMERS UNCHANGED</div>' +
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
