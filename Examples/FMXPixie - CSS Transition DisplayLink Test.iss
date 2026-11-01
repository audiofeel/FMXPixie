; ============================================================================
; FMXPixie - CSS Transition DisplayLink Test
;
; Regression coverage for opacity, background-color and transform
; transitions, including transition:all, longhand timing/delay and retargeting.
;
; Layout-aware width/height transitions are covered by the separate
; "FMXPixie - CSS Size Layout Transition Test.iss" example.
;
; Build from the Examples directory beside Modules\ and Files\.
; ============================================================================

#define DemoAppName "FMXPixie - CSS Transition DisplayLink Test"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - CSS Transition DisplayLink Test
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
    '.page{padding:19px 22px;}' +
    '.eyebrow{color:#62d8c3;font-size:9px;font-weight:bold;letter-spacing:2px;}' +
    '.headline{margin-top:5px;font-size:25px;font-weight:600;letter-spacing:-.4px;color:#f4f7fc;}' +
    '.intro{margin-top:6px;max-width:970px;color:#a4b4ca;font-size:11px;line-height:1.45;}' +
    '.row{display:flex;margin-top:13px;}' +
    '.card{position:relative;width:23.5%;height:137px;margin-right:1.5%;padding:12px;border:1px solid #344661;background:#152238;overflow:hidden;}' +
    '.card:last-child{margin-right:0;}' +
    '.card-index{font-size:9px;font-weight:bold;letter-spacing:1.1px;color:#8aa0bd;}' +
    '.card-title{margin-top:15px;font-size:16px;font-weight:600;color:#f1f6fc;}' +
    '.card-copy{margin-top:6px;color:#a9b9ce;font-size:10px;line-height:1.4;}' +
    '.card-hint{position:absolute;left:12px;right:12px;bottom:10px;padding-top:7px;border-top:1px solid #344661;color:#80c5ff;font-size:8px;letter-spacing:.6px;}' +
    '#t-color{background-color:#8b0000;transition:background-color 180ms linear;}' +
    '#t-color:hover{background-color:#ff2400;}' +
    '#t-opacity{opacity:0.36;transition:opacity 160ms ease-out;}' +
    '#t-opacity:hover{opacity:1;}' +
    '#t-scale{transform:scale(0.92);transition:transform 180ms ease-out;}' +
    '#t-scale:hover{transform:scale(1.07);}' +
    '#t-translate{transform:translate(0px,0px);transition:transform 180ms ease-out;}' +
    '#t-translate:hover{transform:translate(9px,-5px);}' +
    '#t-combo{background-color:#164e63;opacity:0.70;transform:translate(0px,0px) scale(1);transition:background-color 180ms ease-out, opacity 160ms ease-out, transform 180ms ease-out;}' +
    '#t-combo:hover{background-color:#0f766e;opacity:1;transform:translate(-2px,-2px) scale(1.04);}' +
    '#t-longhand{background-color:#3b2b59;transform:translate(0px,0px);transition-property:background-color, transform;transition-duration:150ms,180ms;transition-timing-function:linear,ease-out;transition-delay:0ms,300ms;}' +
    '#t-longhand:hover{background-color:#7c3aed;transform:translate(6px,-3px);}' +
    '#t-all{background-color:#1e293b;opacity:0.62;transform:translate(0px,0px) scale(1);transition:all 170ms ease-out;}' +
    '#t-all:hover{background-color:#2563eb;opacity:1;transform:translate(4px,-2px) scale(1.04);}' +
    '#t-retarget{background-color:#44403c;transform:scale(1);transition:background-color 210ms ease-in-out, transform 210ms ease-out;}' +
    '#t-retarget:hover{background-color:#ea580c;transform:scale(1.05);}' +
    '.note{margin-top:12px;padding:10px 13px;border:1px solid #2a3b55;background:#101a2b;color:#a7b8ce;font-size:10px;line-height:1.5;}' +
    '.note strong{color:#d8eaff;}' +
    '.footer{margin-top:11px;padding-top:8px;border-top:1px solid #263852;color:#7185a0;font-size:8px;letter-spacing:.8px;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="brand">FMXPIXIE / TRANSITION LAB</span>' +
    '<span class="subtitle">DisplayLink regression suite · hover each card</span>' +
    '<div class="window-controls">' +
    '<div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Закрыть">×</div>' +
    '</div></div>' +
    '<div class="page">' +
    '<div class="eyebrow">CSS TRANSITIONS / IMPLEMENTED PROPERTIES</div>' +
    '<div class="headline">Проверка анимации без сторонних таймеров</div>' +
    '<div class="intro">Наводите курсор на карточки, убирайте его и быстро переключайтесь между ними. Проверяются opacity, background-color, transform translate/scale, несколько свойств одновременно, transition:all, longhand delay и обратный переход при повторном наведении.</div>' +
    '<div class="row">' +
    '<div id="t-color" class="card"><div class="card-index">TEST 01 / COLOR</div><div class="card-title">Цвет фона</div><div class="card-copy">Тёмно-красный → алый. Только background-color.</div><div class="card-hint">180 ms · LINEAR</div></div>' +
    '<div id="t-opacity" class="card"><div class="card-index">TEST 02 / OPACITY</div><div class="card-title">Прозрачность</div><div class="card-copy">Карточка становится ярче и снова тускнеет.</div><div class="card-hint">160 ms · EASE-OUT</div></div>' +
    '<div id="t-scale" class="card"><div class="card-index">TEST 03 / SCALE</div><div class="card-title">Увеличение</div><div class="card-copy">Масштаб 92% → 107%. Слот карточки не меняется.</div><div class="card-hint">180 ms · EASE-OUT</div></div>' +
    '<div id="t-translate" class="card"><div class="card-index">TEST 04 / TRANSLATE</div><div class="card-title">Смещение</div><div class="card-copy">Сдвиг по X/Y с плавным возвратом.</div><div class="card-hint">180 ms · EASE-OUT</div></div>' +
    '</div>' +
    '<div class="row">' +
    '<div id="t-combo" class="card"><div class="card-index">TEST 05 / COMBINED</div><div class="card-title">Три свойства</div><div class="card-copy">Цвет, opacity и transform идут одновременно.</div><div class="card-hint">160–180 ms</div></div>' +
    '<div id="t-longhand" class="card"><div class="card-index">TEST 06 / LONGHAND</div><div class="card-title">Задержка</div><div class="card-copy">Цвет меняется сразу, движение начинается позже.</div><div class="card-hint">60 ms DELAY ON TRANSFORM</div></div>' +
    '<div id="t-all" class="card"><div class="card-index">TEST 07 / ALL</div><div class="card-title">transition: all</div><div class="card-copy">Проверка всех трёх поддерживаемых свойств вместе.</div><div class="card-hint">170 ms · EASE-OUT</div></div>' +
    '<div id="t-retarget" class="card"><div class="card-index">TEST 08 / RETARGET</div><div class="card-title">Быстрый реверс</div><div class="card-copy">Входите и выходите до окончания анимации.</div><div class="card-hint">210 ms · EASE-IN-OUT</div></div>' +
    '</div>' +
    '<div class="note"><strong>Проверка соседних элементов:</strong> transform:scale() только визуально меняет размер и не двигает соседей — это ожидаемое поведение CSS. Для анимации width/height с перерасчётом layout используйте отдельный CSS Size Layout Transition Test. Этот набор проверяет opacity, background-color и совместимые transform translate/scale.</div>' +
    '<div class="footer">FMXPIXIE · CSS TRANSITIONS ON FMX DISPLAY LINK · GIF/WEBP AND SCROLLBAR TIMERS ARE UNCHANGED</div>' +
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
