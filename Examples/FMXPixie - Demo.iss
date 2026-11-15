#define DemoAppName "FMXPixie - Demo"
#define DemoAppVersion "2.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Demo
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
  DEMO_FORM_WIDTH = 900;
  DEMO_FORM_HEIGHT = 690;
  TITLEBAR_HEIGHT = 34;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;

  InstallPath: String;
  InstallNotes: String;
  InstallMode: String;
  InstallModeValue: String;
  LanguageName: String;
  LanguageValue: String;
  Compression: String;
  SelectedComponents: String;
  CreateShortcut: Boolean;
  IncludeExamples: Boolean;
  IncludeThemes: Boolean;
  IsInstalled: Boolean;

function BuildTitleHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:34px;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#111c2b;color:#e8eef7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.bar{position:relative;height:33px;line-height:33px;background:#111c2b;border-bottom:1px solid #2b3b50;}' +
    '.brand{padding-left:15px;color:#91ddd1;font-weight:700;letter-spacing:.4px;}' +
    '.caption{margin-left:9px;color:#91a2b7;font-size:11px;}' +
    '.controls{position:absolute;top:0;right:0;width:92px;height:33px;font-size:0;}' +
    '.control{display:inline-block;width:46px;height:33px;text-align:center;line-height:31px;color:#cbd5e1;font-size:21px;cursor:pointer;}' +
    '.control:hover{background:#2d4059;color:#fff;}' +
    '.close:hover{background:#c43d4b;}' +
    '</style></head><body><div class="bar">' +
    '<span class="brand">PIXIE</span><span class="caption">Мастер установки</span>' +
    '<div class="controls"><div id="title-minimize" class="control">−</div>' +
    '<div id="title-close" class="control close">×</div></div></div></body></html>';
end;

function BuildOptionsHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:656px;margin:0;padding:0;overflow:hidden;}' +
    'body{padding:20px 23px;background:#0b1422;color:#e7eef7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.intro{height:86px;}' +
    '.eyebrow{color:#78bdb4;font-size:10px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;}' +
    '.title{margin-top:5px;color:#f3f7fb;font-size:23px;font-weight:650;}' +
    '.subtitle{margin-top:5px;color:#9bacbf;font-size:11px;}' +
    '.layout{height:435px;white-space:nowrap;}' +
    '.panel{display:inline-block;vertical-align:top;height:425px;padding:17px;background:#132136;border:1px solid #2b405b;border-radius:8px;white-space:normal;}' +
    '.left{width:55%;}' +
    '.right{width:43%;margin-left:1.2%;}' +
    '.heading{margin-bottom:7px;color:#93d9ce;font-size:14px;font-weight:650;}' +
    '.hint{margin:0 0 14px;color:#91a3b8;font-size:10px;line-height:1.45;}' +
    '.field{margin-bottom:15px;}' +
    '.field-title{display:block;margin-bottom:6px;color:#d8e2ee;font-size:11px;font-weight:600;}' +
    'input[type=text],select,textarea{display:block;width:100%;padding:9px 10px;background:#0b1728;color:#edf4fb;border:1px solid #3d536f;border-radius:5px;font:12px "Segoe UI",Arial,sans-serif;}' +
    'input[type=text]:focus,select:focus,textarea:focus{border-color:#71c9bc;}' +
    'textarea{height:91px;resize:none;line-height:1.4;}' +
    'input[type=range]{display:block;width:100%;margin:13px 0 6px;}' +
    '.range-labels{color:#8ea1b7;font-size:10px;}' +
    '.choice{display:block;margin:8px 0;padding:8px 9px;border:1px solid #2b405b;border-radius:5px;color:#dce6f1;font-size:11px;cursor:pointer;}' +
    '.choice:hover{background:#1c3049;border-color:#68bdb2;color:#fff;}' +
    '.choice input{margin:0 8px 0 0;vertical-align:middle;}' +
    '.choice small{display:block;margin:4px 0 0 23px;color:#91a3b8;font-size:10px;}' +
    '.group-label{margin:16px 0 6px;color:#91a3b8;font-size:10px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;}' +
    '.actions{height:63px;padding-top:12px;border-top:1px solid #24374f;}' +
    '.action-note{display:inline-block;vertical-align:middle;width:62%;color:#8396ad;font-size:10px;line-height:1.4;}' +
    'button{padding:10px 17px;background:#253b57;color:#edf4fb;border:1px solid #496482;border-radius:5px;cursor:pointer;font:12px "Segoe UI",Arial,sans-serif;}' +
    'button:hover{background:#315477;border-color:#82d3c7;color:#fff;}' +
    'button:active{background:#1a2e47;}' +
    'button.primary{float:right;background:#16766e;border-color:#2b9c90;color:#fff;font-weight:700;}' +
    'button.primary:hover{background:#209287;}' +
    '</style></head><body>' +
    '<div class="intro"><div class="eyebrow">PIXIE Setup · Шаг 1 из 2</div>' +
    '<div class="title">Выберите параметры установки</div>' +
    '<div class="subtitle">Настройте папку, состав и внешний вид приложения. Изменения можно будет проверить перед продолжением.</div></div>' +
    '<div class="layout">' +
    '<div class="panel left">' +
    '<div class="heading">Расположение и состав</div>' +
    '<p class="hint">Укажите, куда установить PIXIE, и выберите нужные компоненты.</p>' +
    '<div class="field"><label class="field-title" for="install-path">Папка установки</label>' +
    '<input id="install-path" type="text" value="C:\Program Files\PIXIE"></div>' +
    '<div class="group-label">Тип установки</div>' +
    '<label class="choice"><input id="mode-standard" type="radio" name="install-mode" value="standard" checked>Обычная установка<small>Основные файлы и необходимые компоненты</small></label>' +
    '<label class="choice"><input id="mode-full" type="radio" name="install-mode" value="full">Полная установка<small>Все компоненты, темы и примеры</small></label>' +
    '<div class="group-label">Дополнительные компоненты</div>' +
    '<label class="choice"><input id="component-examples" type="checkbox" value="examples" checked>Примеры и шаблоны</label>' +
    '<label class="choice"><input id="component-themes" type="checkbox" value="themes">Дополнительные темы оформления</label>' +
    '<label class="choice"><input id="component-shortcut" type="checkbox" value="desktop-shortcut" checked>Создать ярлык на рабочем столе</label>' +
    '</div>' +
    '<div class="panel right">' +
    '<div class="heading">Предпочтения</div>' +
    '<p class="hint">Выберите язык и настройте параметры установки.</p>' +
    '<div class="field"><label class="field-title" for="install-language">Язык интерфейса</label>' +
    '<select id="install-language"><option value="ru">Русский</option><option value="en">English</option><option value="de">Deutsch</option></select></div>' +
    '<div class="field"><label class="field-title" for="install-compression">Уровень сжатия</label>' +
    '<input id="install-compression" type="range" min="0" max="10" step="1" value="6">' +
    '<div class="range-labels">Быстрее <span style="float:right">Меньше места</span></div></div>' +
    '<div class="field"><label class="field-title" for="install-notes">Дополнительные пожелания</label>' +
    '<textarea id="install-notes">Создать резервную копию настроек' + #13#10 + 'Проверить наличие обновлений</textarea></div>' +
    '</div></div>' +
    '<div class="actions"><span class="action-note">Наведите курсор на карточки и кнопки — они подсветятся. Все выбранные параметры сохраняются при возврате назад.</span>' +
    '<button id="btn-next" class="primary">Далее</button></div>' +
    '</body></html>';
end;

function BuildSummaryHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:656px;margin:0;padding:0;overflow:hidden;}' +
    'body{padding:23px 28px;background:#0b1422;color:#e7eef7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.eyebrow{color:#78bdb4;font-size:10px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;}' +
    '.title{margin-top:6px;color:#f3f7fb;font-size:23px;font-weight:650;}' +
    '.subtitle{margin-top:6px;color:#9bacbf;font-size:11px;}' +
    '.summary{margin-top:22px;padding:18px 20px;background:#132136;border:1px solid #2b405b;border-radius:8px;}' +
    '.row{padding:10px 0;border-bottom:1px solid #263951;}' +
    '.row:last-child{border-bottom:0;}' +
    '.label{display:inline-block;vertical-align:top;width:185px;color:#91a5bb;font-size:11px;}' +
    '.value{display:inline-block;vertical-align:top;width:calc(100% - 195px);color:#edf4fb;font-size:12px;line-height:1.5;white-space:pre-wrap;}' +
    '.progress{height:8px;margin-top:22px;background:#22344a;border-radius:5px;overflow:hidden;}' +
    '.fill{width:0;height:8px;background:#42b8a8;}' +
    '.state{margin-top:9px;color:#9bacbf;font-size:11px;}' +
    '.actions{margin-top:22px;padding-top:14px;border-top:1px solid #24374f;}' +
    'button{margin-right:9px;padding:10px 17px;background:#253b57;color:#edf4fb;border:1px solid #496482;border-radius:5px;cursor:pointer;font:12px "Segoe UI",Arial,sans-serif;}' +
    'button:hover{background:#315477;border-color:#82d3c7;color:#fff;}' +
    'button.primary{float:right;background:#16766e;border-color:#2b9c90;color:#fff;font-weight:700;}' +
    'button.primary:hover{background:#209287;}' +
    '</style></head><body>' +
    '<div class="eyebrow">PIXIE Setup · Шаг 2 из 2</div>' +
    '<div id="summary-title" class="title">Всё готово к установке</div>' +
    '<div id="summary-subtitle" class="subtitle">Проверьте выбранные параметры. Чтобы что-то изменить, вернитесь на предыдущий шаг.</div>' +
    '<div class="summary">' +
    '<div class="row"><span class="label">Папка установки</span><span id="summary-path" class="value"></span></div>' +
    '<div class="row"><span class="label">Тип установки</span><span id="summary-mode" class="value"></span></div>' +
    '<div class="row"><span class="label">Компоненты</span><span id="summary-components" class="value"></span></div>' +
    '<div class="row"><span class="label">Язык интерфейса</span><span id="summary-language" class="value"></span></div>' +
    '<div class="row"><span class="label">Уровень сжатия</span><span id="summary-compression" class="value"></span></div>' +
    '<div class="row"><span class="label">Дополнительные пожелания</span><span id="summary-notes" class="value"></span></div>' +
    '</div>' +
    '<div class="progress"><div id="install-progress" class="fill"></div></div>' +
    '<div id="summary-state" class="state">Настройки проверены. Можно начинать установку.</div>' +
    '<div class="actions"><button id="btn-back">Назад</button>' +
    '<button id="btn-install" class="primary">Установить</button></div>' +
    '</body></html>';
end;

procedure SetOutput(const Id, Value: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, Value);
end;

function ElementHandle(const Id: String): NativeInt;
begin
  Result := Doc.GetElementById(Id);
end;

procedure WriteControlValue(const Id, Value: String);
var
  H: NativeInt;
begin
  H := ElementHandle(Id);
  if H = 0 then
    Exit;
  Elem.FCreate(H);
  Elem.SetValue(Value);
end;

function ReadControlValue(const Id: String): String;
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

procedure SetElementStyle(const Id, StyleText: String);
var
  H: NativeInt;
begin
  H := ElementHandle(Id);
  if H = 0 then
    Exit;
  Elem.FCreate(H);
  Elem.SetAttr('style', StyleText);
end;

procedure ApplySavedSettings;
begin
  WriteControlValue('install-path', InstallPath);
  WriteControlValue('install-notes', InstallNotes);
  WriteControlValue('install-language', LanguageValue);
  WriteControlValue('install-compression', Compression);

  WriteControlValue('mode-standard', 'standard');
  WriteControlValue('mode-full', 'full');
  WriteControlValue('component-examples', 'examples');
  WriteControlValue('component-themes', 'themes');
  WriteControlValue('component-shortcut', 'desktop-shortcut');

  WriteChecked('mode-standard', InstallModeValue = 'standard');
  WriteChecked('mode-full', InstallModeValue = 'full');
  WriteChecked('component-examples', IncludeExamples);
  WriteChecked('component-themes', IncludeThemes);
  WriteChecked('component-shortcut', CreateShortcut);
  Doc.Changed;
end;

procedure LoadDefaultSettings;
begin
  InstallPath := 'C:\Program Files\PIXIE';
  InstallNotes := 'Создать резервную копию настроек' + #13#10 +
    'Проверить наличие обновлений';
  InstallModeValue := 'standard';
  InstallMode := 'Обычная установка';
  LanguageValue := 'ru';
  LanguageName := 'Русский';
  Compression := '6';
  IncludeExamples := True;
  IncludeThemes := False;
  CreateShortcut := True;
end;

procedure ShowOptionsPage;
begin
  View.LoadFromString(BuildOptionsHtml);
  Doc.FCreate(View.GetDocument);
  ApplySavedSettings;
end;

procedure ReadSettingsFromForm;
var
  Parts: String;
begin
  InstallPath := ReadControlValue('install-path');
  InstallNotes := ReadControlValue('install-notes');
  Compression := ReadControlValue('install-compression');
  LanguageValue := ReadControlValue('install-language');

  if LanguageValue = 'en' then
    LanguageName := 'English'
  else if LanguageValue = 'de' then
    LanguageName := 'Deutsch'
  else
    LanguageName := 'Русский';

  if ReadChecked('mode-full') then
  begin
    InstallModeValue := ReadControlValue('mode-full');
    InstallMode := 'Полная установка';
  end
  else
  begin
    InstallModeValue := ReadControlValue('mode-standard');
    InstallMode := 'Обычная установка';
  end;

  IncludeExamples := ReadChecked('component-examples');
  IncludeThemes := ReadChecked('component-themes');
  CreateShortcut := ReadChecked('component-shortcut');

  Parts := '';
  if IncludeExamples then
    Parts := Parts + 'Примеры и шаблоны' + #13#10;
  if IncludeThemes then
    Parts := Parts + 'Дополнительные темы оформления' + #13#10;
  if CreateShortcut then
    Parts := Parts + 'Ярлык на рабочем столе' + #13#10;
  if Parts = '' then
    Parts := 'Дополнительные компоненты не выбраны';
  SelectedComponents := Parts;
end;

procedure ShowSummaryPage;
begin
  ReadSettingsFromForm;
  IsInstalled := False;

  View.LoadFromString(BuildSummaryHtml);
  Doc.FCreate(View.GetDocument);
  Doc.BeginUpdate;
  try
    SetOutput('summary-path', InstallPath);
    SetOutput('summary-mode', InstallMode);
    SetOutput('summary-components', SelectedComponents);
    SetOutput('summary-language', LanguageName);
    SetOutput('summary-compression', Compression + ' из 10');
    SetOutput('summary-notes', InstallNotes);
    SetOutput('summary-state', 'Настройки проверены. Можно начинать установку.');
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure FinishDemoInstall;
begin
  IsInstalled := True;
  SetElementStyle('install-progress', 'width:100%;');
  SetOutput('summary-title', 'Демонстрация завершена');
  SetOutput('summary-subtitle', 'PIXIE Setup получил выбранные параметры. Файлы на компьютер не копировались.');
  SetOutput('summary-state', 'Готово. В реальном установщике здесь начинается копирование выбранных компонентов.');
  SetOutput('btn-install', 'Завершить');
  Doc.Changed;
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

  if Id = 'btn-next' then
  begin
    if Trim(ReadControlValue('install-path')) = '' then
    begin
      SetOutput('summary-state', ''); // The options page remains open for correction.
      Result := True;
      Exit;
    end;
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

  if Id = 'btn-install' then
  begin
    if IsInstalled then
      CloseSetup
    else
      FinishDemoInstall;
    Result := True;
    Exit;
  end;
end;

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
  LoadDefaultSettings;
  IsInstalled := False;

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
  View.SetScrollbarVisibility(svHide);
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
