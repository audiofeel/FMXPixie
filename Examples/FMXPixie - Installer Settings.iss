
#define DemoAppName "FMXPixie - Installer Settings"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
OutputBaseFilename={#DemoAppName}
SetupArchitecture=x64
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
  DEMO_FORM_WIDTH = 820;
  DEMO_FORM_HEIGHT = 650;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;

  FInstallNote: String;
  FCompression: String;
  FShortcutValue: String;
  FCreateShortcut: Boolean;
  FStandardValue: String;
  FFullValue: String;
  FInstallFull: Boolean;
  FInstallModeName: String;
  FInstallModeValue: String;

function BuildTitleHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{margin:0;padding:0;width:100%;height:32px;overflow:hidden;}' +
    'body{background:#101827;color:#e5edf7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.bar{position:relative;width:100%;height:32px;line-height:32px;background:#101827;border-bottom:1px solid #29384c;}' +
    '.caption{padding-left:14px;color:#8dd8ce;font-weight:bold;}' +
    '.sub{padding-left:8px;color:#8192a8;font-size:11px;}' +
    '.buttons{position:absolute;right:0;top:0;width:92px;height:32px;font-size:0;}' +
    '.button{display:inline-block;width:46px;height:32px;line-height:30px;text-align:center;font-size:21px;color:#cbd5e1;cursor:pointer;}' +
    '.button:hover{background:#29384c;color:#fff;}' +
    '.close:hover{background:#c43d4b;}' +
    '</style></head><body><div class="bar">' +
    '<span class="caption">PIXIE Setup</span><span class="sub">/ мастер установки</span>' +
    '<div class="buttons"><div id="title-minimize" class="button">−</div>' +
    '<div id="title-close" class="button close">×</div></div></div></body></html>';
end;

function BuildOptionsHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;padding:0;width:100%;height:618px;overflow:hidden;}' +
    'body{padding:17px 19px;background:#0b1220;color:#e5edf7;font:12px "Segoe UI",Arial,sans-serif;}' +
    '.header{height:64px;margin-bottom:10px;}' +
    '.title{font-size:21px;font-weight:650;color:#8dd8ce;}' +
    '.subtitle{margin-top:5px;color:#9aabc0;font-size:11px;line-height:1.4;}' +
    '.row{height:180px;margin-bottom:10px;white-space:normal;}' +
    '.row.short{height:120px;}' +
    '.card{display:inline-block;vertical-align:top;width:49%;height:180px;margin-right:0.7%;padding:12px 13px;background:#121e30;border:1px solid #2a3a52;border-radius:5px;white-space:normal;}' +
    '.card.short{height:120px;}' +
    '.heading{margin-bottom:8px;color:#8dd8ce;font-weight:bold;font-size:13px;}' +
    '.description{margin-bottom:9px;color:#9aabc0;font-size:10px;line-height:1.4;}' +
    '.field-label{display:block;margin-bottom:5px;color:#c3cfdd;font-size:11px;}' +
    'textarea{display:block;width:100%;height:78px;padding:7px 8px;background:#0b1524;color:#edf4fb;border:1px solid #40536d;border-radius:4px;font:11px "Segoe UI",Arial,sans-serif;resize:none;}' +
    'input[type=range]{width:100%;margin:15px 0 5px;}' +
    'input[type=checkbox],input[type=radio]{vertical-align:middle;margin-right:6px;}' +
    'label.choice{display:inline-block;margin:7px 17px 5px 0;color:#d8e2ee;font-size:12px;}' +
    '.hint{margin-top:8px;color:#8498af;font-size:10px;line-height:1.4;}' +
    '.actions{height:47px;margin-top:4px;}' +
    'button{margin:0 8px 0 0;padding:9px 15px;background:#23364f;color:#eaf2fa;border:1px solid #48617f;border-radius:5px;cursor:pointer;font:12px "Segoe UI",Arial,sans-serif;}' +
    'button:hover{background:#315477;border-color:#80c9c2;color:#fff;}' +
    'button.primary{background:#176b67;border-color:#2b9a8c;color:#fff;font-weight:bold;}' +
    '.tip{margin-top:5px;color:#72869d;font-size:10px;}' +
    '</style></head><body>' +

    '<div class="header">' +
    '<div class="title">Параметры установки</div>' +
    '<div class="subtitle">Выберите нужные настройки и нажмите «Далее». ' +
    'На следующем шаге установщик покажет, какие значения он получил из формы.</div>' +
    '</div>' +

    '<div class="row">' +
    '<div class="card">' +
    '<div class="heading">Дополнительные параметры</div>' +
    '<div class="description">Здесь можно указать дополнительные действия для установки, по одному на строку.</div>' +
    '<label class="field-label" for="field-note">Параметры</label>' +
    '<textarea id="field-note" rows="3">Проверить наличие обновлений</textarea>' +
    '</div>' +

    '<div class="card">' +
    '<div class="heading">Сжатие резервных данных</div>' +
    '<div class="description">Установите уровень сжатия от 0 до 10. Значение можно задать кодом или передвинуть ползунок.</div>' +
    '<label class="field-label" for="field-compression">Уровень сжатия</label>' +
    '<input id="field-compression" type="range" min="0" max="10" step="0.5" value="4">' +
    '<div class="hint">Допустимый шаг — 0.5</div>' +
    '</div>' +
    '</div>' +

    '<div class="row short">' +
    '<div class="card short">' +
    '<div class="heading">Ярлык</div>' +
    '<label class="choice"><input id="field-shortcut" type="checkbox" value="shortcut" checked>Создать ярлык на рабочем столе</label>' +
    '</div>' +

    '<div class="card short">' +
    '<div class="heading">Тип установки</div>' +
    '<label class="choice"><input id="field-mode-standard" type="radio" name="install-mode" value="basic" checked>Обычная</label>' +
    '<label class="choice"><input id="field-mode-full" type="radio" name="install-mode" value="complete">Полная</label>' +
    '</div>' +
    '</div>' +

    '<div class="actions">' +
    '<button id="btn-recommended">Рекомендуемые настройки</button>' +
    '<button id="btn-next" class="primary">Далее</button>' +
    '</div>' +
    '<div class="tip">«Рекомендуемые настройки» заполняет поля программно. Можно изменить их вручную перед переходом дальше.</div>' +
    '</body></html>';
end;

function BuildSummaryHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;padding:0;width:100%;height:618px;overflow:hidden;}' +
    'body{padding:20px 22px;background:#0b1220;color:#e5edf7;font:12px "Segoe UI",Arial,sans-serif;}' +
    '.title{font-size:21px;font-weight:650;color:#8dd8ce;}' +
    '.subtitle{margin-top:6px;color:#9aabc0;font-size:11px;line-height:1.4;}' +
    '.summary{margin-top:18px;padding:15px 17px;background:#121e30;border:1px solid #2a3a52;border-radius:5px;}' +
    '.row{margin:0 0 14px;color:#9aabc0;font-size:11px;}' +
    '.label{display:block;margin-bottom:5px;color:#8dd8ce;font-weight:bold;font-size:12px;}' +
    '.value{color:#edf4fb;font-size:12px;line-height:1.45;white-space:pre-wrap;}' +
    '.actions{margin-top:18px;}' +
    'button{margin-right:8px;padding:9px 15px;background:#23364f;color:#eaf2fa;border:1px solid #48617f;border-radius:5px;cursor:pointer;font:12px "Segoe UI",Arial,sans-serif;}' +
    'button:hover{background:#315477;border-color:#80c9c2;color:#fff;}' +
    'button.primary{background:#176b67;border-color:#2b9a8c;color:#fff;font-weight:bold;}' +
    '.tip{margin-top:15px;color:#72869d;font-size:10px;}' +
    '</style></head><body>' +
    '<div class="title">Проверьте выбранные параметры</div>' +
    '<div class="subtitle">Эти данные Inno Setup прочитал из HTML-элементов через FPixieElement.GetValue и GetChecked.</div>' +
    '<div class="summary">' +
    '<div class="row"><span class="label">Дополнительные параметры</span><div id="summary-note" class="value"></div></div>' +
    '<div class="row"><span class="label">Создать ярлык</span><div id="summary-shortcut" class="value"></div></div>' +
    '<div class="row"><span class="label">Тип установки</span><div id="summary-mode" class="value"></div></div>' +
    '<div class="row"><span class="label">Сжатие резервных данных</span><div id="summary-compression" class="value"></div></div>' +
    '</div>' +
    '<div class="actions">' +
    '<button id="btn-back">Назад</button>' +
    '<button id="btn-confirm" class="primary">Подтвердить</button>' +
    '</div>' +
    '</body></html>';
end;

function BuildDoneHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{margin:0;padding:0;width:100%;height:618px;overflow:hidden;}' +
    'body{padding:38px;background:#0b1220;color:#e5edf7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.title{font-size:23px;font-weight:650;color:#8dd8ce;}' +
    '.text{margin-top:12px;color:#c2d0df;line-height:1.6;}' +
    'button{margin-top:25px;padding:9px 18px;background:#176b67;color:#fff;border:1px solid #2b9a8c;border-radius:5px;cursor:pointer;font:12px "Segoe UI",Arial,sans-serif;}' +
    '</style></head><body>' +
    '<div class="title">Параметры получены</div>' +
    '<div class="text">Inno Setup прочитал настройки из FMXPixie и передал их в код установщика.<br>' +
    'В этом демонстрационном примере копирование файлов не выполняется.</div>' +
    '<button id="btn-finish">Завершить</button>' +
    '</body></html>';
end;

// FPixieElement access
function ElementHandle(const Id: String): NativeInt;
begin
  Result := Doc.GetElementById(Id);
end;

function ReadValue(const Id: String): String;
var
  H: NativeInt;
begin
  Result := '';
  H := ElementHandle(Id);
  if H = 0 then
    Exit;

  Elem.FCreate(H);
  Result := Elem.GetValue;
end;

procedure WriteValue(const Id, Value: String);
var
  H: NativeInt;
begin
  H := ElementHandle(Id);
  if H = 0 then
    Exit;

  Elem.FCreate(H);
  Elem.SetValue(Value);
end;

function ReadChecked(const Id: String): Boolean;
var
  H: NativeInt;
begin
  Result := False;
  H := ElementHandle(Id);
  if H = 0 then
    Exit;

  Elem.FCreate(H);
  Result := Elem.GetChecked;
end;

procedure WriteChecked(const Id: String; Value: Boolean);
var
  H: NativeInt;
begin
  H := ElementHandle(Id);
  if H = 0 then
    Exit;

  Elem.FCreate(H);
  Elem.SetChecked(Value);
end;

procedure SetOutput(const Id, Value: String);
var
  H: NativeInt;
begin
  H := ElementHandle(Id);
  if H <> 0 then
    Doc.SetElementText(H, Value);
end;

// Installer flow
procedure ApplySavedOptions;
begin
  WriteValue('field-note', FInstallNote);
  WriteValue('field-compression', FCompression);
  WriteValue('field-shortcut', FShortcutValue);
  WriteChecked('field-shortcut', FCreateShortcut);
  WriteValue('field-mode-standard', FStandardValue);
  WriteValue('field-mode-full', FFullValue);
  WriteChecked('field-mode-standard', not FInstallFull);
  WriteChecked('field-mode-full', FInstallFull);
end;

procedure ShowOptionsPage;
begin
  View.LoadFromString(BuildOptionsHtml);
  Doc.FCreate(View.GetDocument);
  ApplySavedOptions;
end;

procedure LoadRecommendedOptions;
begin
  FInstallNote := 'Проверить наличие обновлений' + #13#10 +
    'Создать журнал установки';
  FCompression := '7.5';
  FShortcutValue := 'desktop-shortcut';
  FCreateShortcut := True;
  FStandardValue := 'standard-install';
  FFullValue := 'full-install';
  FInstallFull := False;

  ApplySavedOptions;
end;

procedure ReadOptionsFromForm;
begin
  FInstallNote := ReadValue('field-note');
  FCompression := ReadValue('field-compression');

  FShortcutValue := ReadValue('field-shortcut');
  FCreateShortcut := ReadChecked('field-shortcut');

  FStandardValue := ReadValue('field-mode-standard');
  FFullValue := ReadValue('field-mode-full');

  if ReadChecked('field-mode-full') then
  begin
    FInstallFull := True;
    FInstallModeName := 'Полная';
    FInstallModeValue := FFullValue;
  end
  else
  begin
    FInstallFull := False;
    FInstallModeName := 'Обычная';
    FInstallModeValue := FStandardValue;
  end;
end;

procedure ShowSummaryPage;
var
  ShortcutText: String;
begin
  ReadOptionsFromForm;

  View.LoadFromString(BuildSummaryHtml);
  Doc.FCreate(View.GetDocument);

  if FCreateShortcut then
    ShortcutText := 'Да'
  else
    ShortcutText := 'Нет';

  Doc.BeginUpdate;
  try
    SetOutput('summary-note', FInstallNote);
    SetOutput('summary-shortcut', ShortcutText +
      ' (value: ' + FShortcutValue + ')');
    SetOutput('summary-mode', FInstallModeName +
      ' (value: ' + FInstallModeValue + ')');
    SetOutput('summary-compression', FCompression);
  finally
    Doc.EndUpdate;
  end;
end;

procedure ConfirmOptions;
begin
  Log('Installer settings:');
  Log('Additional parameters: ' + FInstallNote);
  Log('Create shortcut: ' + IntToStr(Ord(FCreateShortcut)) +
    '; value=' + FShortcutValue);
  Log('Install mode: ' + FInstallModeName +
    '; value=' + FInstallModeValue);
  Log('Compression: ' + FCompression);

  View.LoadFromString(BuildDoneHtml);
  Doc.FCreate(View.GetDocument);
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

// Event handling
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
    CloseSetup;
    Result := True;
    Exit;
  end;

  if Id = 'btn-recommended' then
  begin
    LoadRecommendedOptions;
    Result := True;
    Exit;
  end;

  if Id = 'btn-next' then
  begin
    ShowSummaryPage;
    Result := True;
    Exit;
  end;

  if Id = 'btn-back' then
  begin
    ShowOptionsPage;
    Result := True;
    Exit;
  end;

  if Id = 'btn-confirm' then
  begin
    ConfirmOptions;
    Result := True;
    Exit;
  end;

  if Id = 'btn-finish' then
  begin
    CloseSetup;
    Result := True;
    Exit;
  end;
end;

// Window
procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TitleView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  TitleView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  Doc := InitPixieDocument;
  Elem := InitPixieElement;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  FInstallNote := 'Установка для текущего пользователя.';
  FCompression := '4';
  FShortcutValue := 'shortcut';
  FCreateShortcut := True;
  FStandardValue := 'basic';
  FFullValue := 'complete';
  FInstallFull := False;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('PIXIE Setup');
  FMXForm.StayOnTop(False);

  TitleView.FCreate(FMXForm.Handle);
  TitleView.SetBounds(0, 0, DEMO_FORM_WIDTH, TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.HitTest(True);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@ViewMouseDown);
  TitleView.LoadFromString(BuildTitleHtml);

  View.FCreate(FMXForm.Handle);
  View.SetBounds(0, TITLEBAR_HEIGHT, DEMO_FORM_WIDTH,
    DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.HitTest(True);
  View.OnElementClick(@ElementClick);

  ShowOptionsPage;
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
