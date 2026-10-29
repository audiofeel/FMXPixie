; ============================================================================
; FMXPixie - Animated Installer Demo
;
; Visual showcase for the CSS transition features implemented on the
; FMX Display Link: opacity, background-color and transform translate/scale.
; This is a visual demo only; it does not install files.
;
; Build from the Examples directory beside Modules\ and Files\.
; ============================================================================

#define DemoAppName "FMXPixie - Animated Installer Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Animated Installer Demo
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
  DEMO_FORM_WIDTH = 1120;
  DEMO_FORM_HEIGHT = 790;
  TITLEBAR_HEIGHT = 44;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  View: FPixieHtmlView;
  Elem: FPixieElement;

function BuildDemoHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#0a101b;color:#e8eef7;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.titlebar{position:relative;height:44px;line-height:43px;background:#0e1726;border-bottom:1px solid #263a54;overflow:hidden;}' +
    '.brand{margin-left:17px;color:#91caff;font-size:11px;font-weight:bold;letter-spacing:1.6px;}' +
    '.title-sub{margin-left:14px;color:#7f91a9;font-size:10px;}' +
    '.window-controls{position:absolute;right:0;top:0;width:92px;height:43px;font-size:0;}' +
    '.window-button{display:inline-block;vertical-align:top;width:46px;height:43px;line-height:42px;text-align:center;font-size:19px;color:#d7e2f1;cursor:pointer;transition:background-color 140ms ease-out;}' +
    '.window-button:hover{background-color:#263a54;}' +
    '.window-close:hover{background-color:#bd3548;}' +
    '.workspace{display:flex;height:746px;}' +
    '.sidebar{width:210px;flex-shrink:0;padding:20px 14px;background:#0e1726;border-right:1px solid #263a54;}' +
    '.logo-mark{width:42px;height:42px;line-height:42px;text-align:center;background:#173b60;border:1px solid #3974a9;border-radius:10px;color:#bfe2ff;font-size:17px;font-weight:bold;}' +
    '.logo-name{margin-top:11px;color:#f1f6fc;font-size:16px;font-weight:bold;letter-spacing:1px;}' +
    '.logo-tag{margin-top:4px;color:#7e91ac;font-size:9px;letter-spacing:1.3px;}' +
    '.nav-label{margin-top:27px;margin-bottom:8px;color:#6f829d;font-size:9px;font-weight:bold;letter-spacing:1.7px;}' +
    '.nav-item{padding:10px 11px;margin-bottom:4px;border:1px solid transparent;border-radius:7px;color:#a7b6ca;font-size:11px;transition:background-color 150ms ease-out, opacity 150ms ease-out;}' +
    '.nav-item:hover{background-color:#1a2a40;opacity:1;}' +
    '.nav-active{background-color:#162a42;border-color:#2b4a6b;color:#dceeff;}' +
    '.side-info{margin-top:29px;padding:12px;border:1px solid #263a54;border-radius:8px;background:#111d2e;}' +
    '.side-info-title{color:#8298b6;font-size:9px;letter-spacing:1px;}' +
    '.side-info-value{margin-top:7px;color:#dbe9f8;font-size:11px;font-weight:bold;}' +
    '.side-info-copy{margin-top:6px;color:#7f92ab;font-size:9px;line-height:1.4;}' +
    '.main{flex:1;padding:20px 24px;min-width:0;}' +
    '.page-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:15px;}' +
    '.eyebrow{color:#5bd5bf;font-size:9px;font-weight:bold;letter-spacing:2px;}' +
    '.page-title{margin-top:5px;color:#f2f6fc;font-size:25px;font-weight:600;letter-spacing:-.4px;}' +
    '.build-pill{padding:7px 10px;border:1px solid #2d4e6c;border-radius:20px;background:#102338;color:#9bd5ff;font-size:9px;letter-spacing:1px;}' +
    '.hero{position:relative;display:flex;align-items:center;height:160px;padding:21px 23px;border:1px solid #2d4968;border-radius:12px;background:#12233a;overflow:hidden;}' +
    '.hero-copy{flex:1;min-width:0;}' +
    '.hero-kicker{color:#73bfff;font-size:9px;font-weight:bold;letter-spacing:1.7px;}' +
    '.hero-title{margin-top:8px;color:#f3f7fd;font-size:27px;font-weight:600;letter-spacing:-.5px;}' +
    '.hero-desc{margin-top:7px;max-width:470px;color:#a3b6ce;font-size:11px;line-height:1.5;}' +
    '.hero-side{width:245px;flex-shrink:0;padding-left:18px;border-left:1px solid #304b68;}' +
    '.hero-stat-label{color:#8198b3;font-size:9px;letter-spacing:1.3px;}' +
    '.hero-stat-value{margin-top:7px;color:#d8f5eb;font-size:19px;font-weight:bold;}' +
    '.hero-stat-copy{margin-top:5px;color:#8ca1ba;font-size:10px;}' +
    '.action-row{display:flex;margin-top:13px;}' +
    '.action{display:inline-block;min-width:150px;padding:12px 16px;margin-right:10px;border:1px solid #365778;border-radius:7px;text-align:center;font-size:10px;font-weight:bold;letter-spacing:1px;cursor:pointer;}' +
    '#install-now{background-color:#1e6f59;border-color:#3bba92;color:#eafff6;transform:scale(1);transition:background-color 160ms ease-out, transform 160ms ease-out;}' +
    '#install-now:hover{background-color:#299c78;transform:scale(1.035);}' +
    '#play-now{background-color:#17314d;color:#c7e7ff;opacity:0.64;transition:opacity 150ms ease-out;}' +
    '#play-now:hover{opacity:1;}' +
    '.section-head{display:flex;align-items:center;justify-content:space-between;margin-top:21px;margin-bottom:10px;}' +
    '.section-title{color:#dfe9f6;font-size:12px;font-weight:bold;letter-spacing:.8px;}' +
    '.section-note{color:#7589a4;font-size:9px;}' +
    '.showcase{display:flex;}' +
    '.showcase-card{width:18.8%;height:117px;margin-right:1.5%;padding:11px;border:1px solid #2a405c;border-radius:9px;background:#142137;overflow:hidden;}' +
    '.showcase-card:last-child{margin-right:0;}' +
    '.showcase-label{color:#829ab7;font-size:8px;font-weight:bold;letter-spacing:1px;}' +
    '.showcase-title{margin-top:13px;color:#f1f6fc;font-size:13px;font-weight:600;}' +
    '.showcase-copy{margin-top:5px;color:#99acc3;font-size:9px;line-height:1.4;}' +
    '#sample-color{background-color:#18314c;transition:background-color 170ms ease-out;}' +
    '#sample-color:hover{background-color:#2876b9;}' +
    '#sample-opacity{opacity:0.43;transition:opacity 150ms ease-out;}' +
    '#sample-opacity:hover{opacity:1;}' +
    '#sample-scale{transform:scale(0.94);transition:transform 170ms ease-out;}' +
    '#sample-scale:hover{transform:scale(1.08);}' +
    '#sample-move{transform:translate(0px,0px);transition:transform 170ms ease-out;}' +
    '#sample-move:hover{transform:translate(7px,-4px);}' +
    '#sample-combo{background-color:#164e63;opacity:0.72;transform:translate(0px,0px) scale(1);transition:background-color 180ms ease-out, opacity 170ms ease-out, transform 180ms ease-out;}' +
    '#sample-combo:hover{background-color:#0f766e;opacity:1;transform:translate(0px,-3px) scale(1.04);}' +
    '.layout-proof{display:flex;margin-top:14px;padding:10px 12px;border:1px solid #263a54;border-radius:8px;background:#101b2b;align-items:center;}' +
    '.layout-proof-title{width:165px;flex-shrink:0;color:#8ea2bd;font-size:9px;line-height:1.4;}' +
    '.layout-proof-track{display:flex;align-items:center;flex:1;}' +
    '#scale-slot{width:160px;padding:8px 10px;border:1px solid #3c7ba8;border-radius:5px;background:#173956;color:#c5e7ff;font-size:9px;text-align:center;transform:scale(1);transition:transform 170ms ease-out;}' +
    '#scale-slot:hover{transform:scale(1.13);}' +
    '.neighbor-slot{margin-left:12px;padding:8px 10px;border:1px solid #40516a;border-radius:5px;background:#1d293a;color:#b1c0d2;font-size:9px;}' +
    '.bottom-row{display:flex;align-items:center;justify-content:space-between;margin-top:14px;padding-top:11px;border-top:1px solid #263a54;}' +
    '.bottom-note{color:#8093ad;font-size:9px;}' +
    '.bottom-status{color:#62d8b4;font-size:9px;font-weight:bold;letter-spacing:1px;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="brand">FMXPIXIE / NOVA INSTALLER</span>' +
    '<span class="title-sub">CSS transition showcase · FMX Display Link</span>' +
    '<div class="window-controls">' +
    '<div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Закрыть">×</div>' +
    '</div></div>' +
    '<div class="workspace">' +
    '<aside class="sidebar">' +
    '<div class="logo-mark">N</div>' +
    '<div class="logo-name">NOVA</div>' +
    '<div class="logo-tag">GAME PLATFORM</div>' +
    '<div class="nav-label">УСТАНОВЩИК</div>' +
    '<div class="nav-item nav-active">Обзор</div>' +
    '<div class="nav-item">Компоненты</div>' +
    '<div class="nav-item">Папка установки</div>' +
    '<div class="nav-item">Настройки</div>' +
    '<div class="side-info"><div class="side-info-title">ПАКЕТ</div><div class="side-info-value">NOVA Protocol</div><div class="side-info-copy">Сборка 2.8.14<br>Проверка файлов готова</div></div>' +
    '</aside>' +
    '<main class="main">' +
    '<div class="page-head"><div><div class="eyebrow">INSTALLATION CENTER</div><div class="page-title">Подготовка установки</div></div><div class="build-pill">STABLE BUILD · 2.8.14</div></div>' +
    '<div class="hero"><div class="hero-copy"><div class="hero-kicker">НОВОЕ ОБНОВЛЕНИЕ ДОСТУПНО</div><div class="hero-title">NOVA Protocol</div><div class="hero-desc">Подготовьте игровой клиент к запуску. Этот экран демонстрирует CSS-переходы FMXPixie: плавный цвет, прозрачность, масштаб и перемещение без JavaScript.</div></div><div class="hero-side"><div class="hero-stat-label">РАЗМЕР ПАКЕТА</div><div class="hero-stat-value">24.8 GB</div><div class="hero-stat-copy">Свободное место: 128.4 GB</div></div></div>' +
    '<div class="action-row"><div id="install-now" class="action">УСТАНОВИТЬ</div><div id="play-now" class="action">ПРОВЕРИТЬ ФАЙЛЫ</div></div>' +
    '<div class="section-head"><div class="section-title">АНИМАЦИОННАЯ ВИТРИНА</div><div class="section-note">Наведите курсор на каждую карточку</div></div>' +
    '<div class="showcase">' +
    '<div id="sample-color" class="showcase-card"><div class="showcase-label">01 / COLOR</div><div class="showcase-title">Цвет фона</div><div class="showcase-copy">background-color</div></div>' +
    '<div id="sample-opacity" class="showcase-card"><div class="showcase-label">02 / OPACITY</div><div class="showcase-title">Прозрачность</div><div class="showcase-copy">opacity: 0.43 → 1</div></div>' +
    '<div id="sample-scale" class="showcase-card"><div class="showcase-label">03 / SCALE</div><div class="showcase-title">Масштаб</div><div class="showcase-copy">scale(0.94) → 1.08</div></div>' +
    '<div id="sample-move" class="showcase-card"><div class="showcase-label">04 / TRANSLATE</div><div class="showcase-title">Смещение</div><div class="showcase-copy">translate X / Y</div></div>' +
    '<div id="sample-combo" class="showcase-card"><div class="showcase-label">05 / COMBO</div><div class="showcase-title">Комбинация</div><div class="showcase-copy">Цвет + opacity + transform</div></div>' +
    '</div>' +
    '<div class="layout-proof"><div class="layout-proof-title">SCALE НЕ МЕНЯЕТ LAYOUT<br>Соседний блок остаётся на месте</div><div class="layout-proof-track"><div id="scale-slot">МАСШТАБИРУЕМЫЙ ЭЛЕМЕНТ</div><div class="neighbor-slot">СОСЕДНИЙ БЛОК</div></div></div>' +
    '<div class="bottom-row"><div class="bottom-note">Демо-витрина: реальная установка не выполняется. Скорости переходов — 150–180 мс.</div><div class="bottom-status">● READY</div></div>' +
    '</main></div></body></html>';
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
  end
  else if Id = 'install-now' then
  begin
    MsgBox('Это визуальная демонстрация. Установка файлов не выполняется.', mbInformation, MB_OK);
    Result := True;
  end
  else if Id = 'play-now' then
  begin
    MsgBox('Проверка файлов здесь не запускается: это демонстрация анимаций.', mbInformation, MB_OK);
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
  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);

  FMXForm := InitFormHandle;
  View := InitPixieHtmlView;
  Elem := InitPixieElement;

  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);

  View.FCreate(FMXForm.Handle);
  View.Left(0);
  View.Top(0);
  View.Width(DEMO_FORM_WIDTH);
  View.Height(DEMO_FORM_HEIGHT);
  View.ColorScheme(pcsDark);
  View.OnElementClick(@ElementClick);
  View.OnMouseDown(@ViewMouseDown);
  View.LoadFromString(BuildDemoHtml);

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
