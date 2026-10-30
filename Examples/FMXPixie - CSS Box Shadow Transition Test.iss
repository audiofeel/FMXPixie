; ============================================================================
; FMXPixie - CSS Box Shadow Transition Test
;
; Static and animated CSS box-shadow regression coverage:
;   static shadow, none-to-shadow, geometry/color interpolation, delay,
;   combined background-color transition, and rapid retargeting.
;
; Build from the Examples directory beside Modules\ and Files\.
; Use a DLL built from feature/css-layout-transition-displaylink.
; ============================================================================

#define DemoAppName "FMXPixie - CSS Box Shadow Transition Test"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - CSS Box Shadow Transition Test
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
  TEST_FORM_HEIGHT = 820;
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
    'body{background:#e6edf5;color:#1e293b;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.titlebar{position:relative;height:42px;line-height:41px;background:#101a2b;border-bottom:1px solid #263852;overflow:hidden;}' +
    '.brand{margin-left:16px;color:#88c9ff;font-size:11px;font-weight:bold;letter-spacing:1.5px;}' +
    '.subtitle{margin-left:13px;color:#8498b4;font-size:10px;}' +
    '.window-controls{position:absolute;right:0;top:0;width:92px;height:41px;font-size:0;}' +
    '.window-button{display:inline-block;vertical-align:top;width:46px;height:41px;line-height:40px;text-align:center;font-size:19px;color:#d8e2f0;cursor:pointer;transition:background-color 150ms ease-out;}' +
    '.window-button:hover{background-color:#263750;}' +
    '.window-close:hover{background-color:#c43c4a;}' +
    '.page{padding:20px 24px;}' +
    '.eyebrow{color:#62d8c3;font-size:9px;font-weight:bold;letter-spacing:2px;}' +
    '.headline{margin-top:5px;font-size:25px;font-weight:600;letter-spacing:-.4px;color:#f4f7fc;}' +
    '.intro{margin-top:7px;max-width:980px;color:#526277;font-size:11px;line-height:1.5;}' +
    '.section-title{margin-top:17px;margin-bottom:10px;color:#17649b;font-size:9px;font-weight:bold;letter-spacing:1.3px;}' +
    '.row{display:flex;margin-top:8px;padding:30px 5px 36px;}' +
    '.card{position:relative;width:20%;height:142px;margin-right:6.66%;padding:13px;border:1px solid #b8c7d8;border-radius:12px;background:#ffffff;}' +
    '.card:last-child{margin-right:0;}' +
    '.card-index{font-size:9px;font-weight:bold;letter-spacing:1.1px;color:#64748b;}' +
    '.card-title{margin-top:15px;font-size:16px;font-weight:600;color:#172033;}' +
    '.card-copy{margin-top:7px;color:#526277;font-size:10px;line-height:1.45;}' +
    '.card-hint{position:absolute;left:13px;right:13px;bottom:11px;padding-top:7px;border-top:1px solid #d8e1eb;color:#17649b;font-size:8px;letter-spacing:.6px;}' +
    '#shadow-static{box-shadow:0 0 0 14px #ff006e;}' +
    '#shadow-hover{box-shadow:0 2px 5px 0 rgba(0,0,0,.16);transition:box-shadow 340ms cubic-bezier(.2,.75,.25,1);}' +
    '#shadow-hover:hover{box-shadow:0 12px 30px 4px rgba(0,150,255,.92);}' +
    '#shadow-none{box-shadow:none;transition:box-shadow 380ms ease-out;}' +
    '#shadow-none:hover{box-shadow:0 10px 28px 2px rgba(124,58,237,.94);}' +
    '#shadow-delay{box-shadow:0 2px 5px 0 rgba(0,0,0,.16);transition-property:box-shadow;transition-duration:260ms;transition-timing-function:ease-out;transition-delay:320ms;}' +
    '#shadow-delay:hover{box-shadow:0 9px 24px 3px rgba(249,115,22,.95);}' +
    '#shadow-combo{background-color:#152238;box-shadow:0 2px 5px 0 rgba(0,0,0,.16);transition:background-color 220ms linear,box-shadow 360ms ease-out;}' +
    '#shadow-combo:hover{background-color:#164e63;box-shadow:0 9px 26px 3px rgba(20,184,166,.95);}' +
    '#shadow-retarget{box-shadow:0 0 0 0 rgba(56,189,248,0);transition:box-shadow 560ms ease-in-out;}' +
    '#shadow-retarget:hover{box-shadow:0 12px 32px 5px rgba(56,189,248,.96);}' +
    '#shadow-spread{box-shadow:0 3px 8px -3px rgba(0,0,0,.3);transition:box-shadow 360ms ease-out;}' +
    '#shadow-spread:hover{box-shadow:0 7px 20px 7px rgba(244,63,94,.94);}' +
    '.note{margin-top:14px;padding:11px 13px;border:1px solid #b8c7d8;background:#f8fafc;color:#526277;font-size:10px;line-height:1.55;}' +
    '.note strong{color:#172033;}' +
    '.footer{margin-top:12px;padding-top:8px;border-top:1px solid #c5d1df;color:#64748b;font-size:8px;letter-spacing:.8px;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="brand">FMXPIXIE / BOX-SHADOW LAB</span>' +
    '<span class="subtitle">DisplayLink shadow test · hover each card</span>' +
    '<div class="window-controls">' +
    '<div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Закрыть">×</div>' +
    '</div></div>' +
    '<div class="page">' +
    '<div class="eyebrow">CSS BOX-SHADOW / STATIC + TRANSITION</div>' +
    '<div class="headline">Тень: отрисовка и плавное изменение</div>' +
    '<div class="intro">Сначала проверьте яркую розовую статическую тень слева. Она должна быть видна постоянно. На остальных карточках наведите курсор и уберите его: меняются смещение, размытие, spread и цвет. Тень должна появляться и исчезать без скачка; у карточки 04 начало специально задержано.</div>' +
    '<div class="section-title">01 / STATIC SHADOW — БЕЗ АНИМАЦИИ</div>' +
    '<div class="row">' +
    '<div id="shadow-static" class="card"><div class="card-index">TEST 01 / STATIC</div><div class="card-title">Обычная тень</div><div class="card-copy">Постоянная контрастная тень без blur. Это контроль самого парсинга и вызова отрисовки.</div><div class="card-hint">0 0 0 14px · HEX / NO BLUR</div></div>' +
    '<div id="shadow-hover" class="card"><div class="card-index">TEST 02 / HOVER</div><div class="card-title">Изменение параметров</div><div class="card-copy">Смещение, blur, spread и цвет меняются вместе.</div><div class="card-hint">340 ms · CUBIC-BEZIER</div></div>' +
    '<div id="shadow-none" class="card"><div class="card-index">TEST 03 / NONE → SHADOW</div><div class="card-title">Появление тени</div><div class="card-copy">Переход из box-shadow:none и обратно.</div><div class="card-hint">380 ms · EASE-OUT</div></div>' +
    '<div id="shadow-delay" class="card"><div class="card-index">TEST 04 / DELAY</div><div class="card-title">Задержка старта</div><div class="card-copy">После наведения тень начинает меняться через 320 ms.</div><div class="card-hint">320 ms DELAY · 260 ms DURATION</div></div>' +
    '</div>' +
    '<div class="section-title">02 / COMBINED + RETARGET + SPREAD</div>' +
    '<div class="row">' +
    '<div id="shadow-combo" class="card"><div class="card-index">TEST 05 / COMBINED</div><div class="card-title">Два свойства</div><div class="card-copy">Цвет фона и тень анимируются одновременно.</div><div class="card-hint">BACKGROUND + BOX-SHADOW</div></div>' +
    '<div id="shadow-retarget" class="card"><div class="card-index">TEST 06 / RETARGET</div><div class="card-title">Быстрый реверс</div><div class="card-copy">Быстро входите и выходите до окончания анимации.</div><div class="card-hint">560 ms · EASE-IN-OUT</div></div>' +
    '<div id="shadow-spread" class="card"><div class="card-index">TEST 07 / SPREAD</div><div class="card-title">Распространение</div><div class="card-copy">Отрицательный spread переходит в положительный.</div><div class="card-hint">360 ms · EASE-OUT</div></div>' +
    '<div class="card" style="background:#f1f5f9;border-style:dashed;"><div class="card-index">TEST NOTES</div><div class="card-title">Что смотреть</div><div class="card-copy">Край тени должен быть мягким, скругления совпадать с карточкой, а быстрый реверс — идти от текущего состояния.</div><div class="card-hint">NO EXTRA TIMER</div></div>' +
    '</div>' +
    '<div class="note"><strong>Ограничения экспериментальной реализации:</strong> одна внешняя тень; поддерживаются 2–4 длины (offset-x, offset-y, blur, spread) и один цвет, включая rgba() и currentColor. Несколько теней через запятую и inset пока не поддерживаются. Размытие сейчас аппроксимируется несколькими полупрозрачными скруглёнными слоями, а не точным Gaussian blur. Поэтому особенно важны проверка качества края и производительности на нескольких одновременно анимируемых элементах.</div>' +
    '<div class="footer">FMXPIXIE · BOX-SHADOW TRANSITIONS ON FMX DISPLAY LINK · NO NEW TIMER · EXPERIMENTAL BRANCH</div>' +
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
