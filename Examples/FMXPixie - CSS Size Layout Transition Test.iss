
#define DemoAppName "PIXIE Setup - Additional Packages"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=PIXIE Setup - Additional Packages
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
    '<span class="brand">PIXIE SETUP / ДОПОЛНИТЕЛЬНЫЕ ПАКЕТЫ</span>' +
    '<span class="subtitle">Раскройте карточки, наведя на них курсор</span>' +
    '<div class="window-controls">' +
    '<div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Закрыть">×</div>' +
    '</div></div>' +
    '<div class="page">' +
    '<div class="eyebrow">ДОПОЛНИТЕЛЬНЫЕ ВОЗМОЖНОСТИ</div>' +
    '<div class="headline">Выберите дополнительные пакеты</div>' +
    '<div class="intro">Наведите курсор на карточки, чтобы прочитать подробности. При раскрытии карточки соседние блоки плавно перемещаются и занимают новое место, а не накладываются друг на друга.</div>' +
    '<div class="section-title">01 / ПАКЕТЫ И ШАБЛОНЫ</div>' +
    '<div class="inline-row">' +
    '<div id="size-inline" class="grow-inline"><strong>Готовые шаблоны</strong><br>Наведите курсор, чтобы открыть описание и список примеров.</div>' +
    '<div class="inline-neighbor">Документация и руководства<br>Откройте описание, не закрывая список пакетов.</div>' +
    '</div>' +
    '<div class="section-title">02 / ДОПОЛНИТЕЛЬНЫЕ ТЕМЫ</div>' +
    '<div class="stack">' +
    '<div id="size-height" class="grow-height"><strong>Темы оформления</strong><br>Наведите курсор, чтобы посмотреть варианты внешнего вида.</div>' +
    '<div class="after-height">Описание темы раскрывается, а следующие пакеты плавно перемещаются вниз.</div>' +
    '</div>' +
    '<div class="section-title">03 / ПРИМЕРЫ И ИЛЛЮСТРАЦИИ</div>' +
    '<div id="size-width" class="width-only">Дополнительные примеры раскрываются по наведению, сохраняя аккуратное расположение остальных элементов.</div>' +
    '<div class="note"><strong>Наведите курсор на каждый пакет и уберите его. Карточка плавно раскрывается, соседний элемент смещается, а после ухода курсора всё возвращается на место. Так можно просмотреть дополнительные сведения, не открывая отдельное окно.</div>' +
    '<div class="footer">PIXIE SETUP · ДОПОЛНИТЕЛЬНЫЕ ПАКЕТЫ · ПРЕДВАРИТЕЛЬНЫЙ ПРОСМОТР</div>' +
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
