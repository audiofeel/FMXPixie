#define DemoAppName "FMXPixie - Select Option Demo"
#define DemoAppVersion "2.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Select Option Demo
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
  DEMO_FORM_WIDTH = 860;
  DEMO_FORM_HEIGHT = 700;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;

  LanguageValue: String;
  ComponentValue: String;
  PackageValue: String;
  LanguageName: String;
  ComponentName: String;
  PackageName: String;
  IsConfirmed: Boolean;

function BuildTitleHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:32px;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#111c2b;color:#e8eef7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.bar{position:relative;height:31px;line-height:31px;background:#111c2b;border-bottom:1px solid #2b3b50;}' +
    '.brand{padding-left:14px;color:#91ddd1;font-weight:700;}' +
    '.caption{margin-left:9px;color:#91a2b7;font-size:11px;}' +
    '.controls{position:absolute;top:0;right:0;width:92px;height:31px;font-size:0;}' +
    '.control{display:inline-block;width:46px;height:31px;text-align:center;line-height:30px;color:#cbd5e1;font-size:21px;cursor:pointer;}' +
    '.control:hover{background:#2d4059;color:#fff;}.close:hover{background:#c43d4b;}' +
    '</style></head><body><div class="bar"><span class="brand">PIXIE</span>' +
    '<span class="caption">Выбор параметров</span><div class="controls">' +
    '<div id="title-minimize" class="control">−</div><div id="title-close" class="control close">×</div>' +
    '</div></div></body></html>';
end;

function BuildOptionsHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:668px;margin:0;padding:0;overflow:hidden;}' +
    'body{padding:20px 22px;background:#0b1422;color:#e7eef7;font:12px "Segoe UI",Arial,sans-serif;}' +
    '.intro{height:77px;}' +
    '.eyebrow{color:#78bdb4;font-size:10px;font-weight:700;letter-spacing:1.4px;text-transform:uppercase;}' +
    '.title{margin-top:5px;color:#f3f7fb;font-size:22px;font-weight:650;}' +
    '.subtitle{margin-top:5px;color:#9bacbf;font-size:11px;}' +
    '.grid{height:470px;white-space:normal;}' +
    '.card{display:inline-block;vertical-align:top;width:49%;height:214px;margin:0 .7% 12px 0;padding:14px;background:#132136;border:1px solid #2b405b;border-radius:7px;white-space:normal;}' +
    '.card:nth-child(even){margin-right:0;}' +
    '.heading{margin-bottom:5px;color:#93d9ce;font-size:13px;font-weight:650;}' +
    '.hint{margin:0 0 10px;color:#91a3b8;font-size:10px;line-height:1.4;}' +
    '.field-label{display:block;margin:5px 0;color:#d8e2ee;font-size:11px;font-weight:600;}' +
    'select{display:block;width:100%;height:37px;padding:0 8px;background:#172554;color:#dbeafe;border:1px solid #3b82f6;border-radius:8px;font:12px "Segoe UI",Arial,sans-serif;}' +
    'select:hover{background:#1e3a8a;color:#fff;border-color:#93c5fd;}' +
    '.select-green{background:#052e2b;color:#d1fae5;border:1px solid #10b981;border-radius:4px;}' +
    '.select-green:hover{background:#064e3b;color:#ecfdf5;border-color:#6ee7b7;}' +
    '.select-amber{background:#422006;color:#ffedd5;border:1px solid #d97706;border-radius:12px;}' +
    '.select-amber:hover{background:#78350f;color:#fff7ed;border-color:#fbbf24;}' +
    '.select-disabled{background:#202936;color:#94a3b8;border:1px solid #475569;border-radius:6px;}' +
    'option{background:#1f2937;color:#e5e7eb;border:1px solid #344256;border-radius:5px;}' +
    'option:hover{background:#334155;color:#fff;border-color:#60a5fa;}' +
    'option:checked{background:#2563eb;color:#fff;border-color:#60a5fa;}' +
    'option:disabled{color:#64748b;}' +
    '.green-option{background:#064e3b;color:#d1fae5;border:1px solid #047857;border-radius:3px;}' +
    '.green-option:hover{background:#047857;color:#fff;border-color:#6ee7b7;}' +
    '.green-option:checked{background:#059669;color:#fff;border-color:#a7f3d0;}' +
    '.green-option:disabled{background:#1f2937;color:#64748b;border-color:#374151;}' +
    '.green-group{background:#064e3b;color:#6ee7b7;border:1px solid #10b981;border-radius:4px;}' +
    '.green-group:hover{background:#065f46;color:#a7f3d0;}' +
    '.amber-option{background:#451a03;color:#ffedd5;border:1px solid #92400e;border-radius:8px;}' +
    '.amber-option:hover{background:#92400e;color:#fff7ed;border-color:#fbbf24;}' +
    '.amber-option:checked{background:#b45309;color:#fff;border-color:#fcd34d;}' +
    '.disabled-option{background:#202936;color:#64748b;border:1px solid #374151;border-radius:6px;}' +
    '.theme{display:inline-block;margin:0 0 7px;padding:3px 6px;border:1px solid;font-size:9px;font-weight:700;letter-spacing:.8px;}' +
    '.blue{color:#93c5fd;border-color:#3b82f6;background:#172554;}' +
    '.green{color:#6ee7b7;border-color:#10b981;background:#052e2b;}' +
    '.amber{color:#fcd34d;border-color:#d97706;background:#422006;}' +
    '.gray{color:#94a3b8;border-color:#475569;background:#202936;}' +
    '.note{margin-top:8px;color:#91a3b8;font-size:10px;line-height:1.4;}' +
    '.actions{height:62px;padding-top:12px;border-top:1px solid #24374f;}' +
    '.action-note{display:inline-block;vertical-align:middle;width:61%;color:#8396ad;font-size:10px;line-height:1.4;}' +
    'button{padding:10px 14px;margin-left:7px;background:#253b57;color:#edf4fb;border:1px solid #496482;border-radius:5px;cursor:pointer;font:11px "Segoe UI",Arial,sans-serif;}' +
    'button:hover{background:#315477;border-color:#82d3c7;color:#fff;}' +
    'button.primary{float:right;background:#16766e;border-color:#2b9c90;color:#fff;font-weight:700;}' +
    '</style></head><body>' +
    '<div class="intro"><div class="eyebrow">PIXIE Setup · Шаг 1 из 2</div>' +
    '<div class="title">Выберите язык и дополнительные модули</div>' +
    '<div class="subtitle">Списки можно раскрывать мышью и выбирать пункты клавиатурой.</div></div>' +
    '<div class="grid">' +
    '<div class="card"><div class="heading">Язык интерфейса</div>' +
    '<p class="hint">Выберите язык, который будет использоваться в приложении.</p>' +
    '<div class="theme blue">СИНИЙ СТИЛЬ</div>' +
    '<label class="field-label" for="select-language">Язык</label>' +
    '<select id="select-language">' +
    '<option value="de" class="blue-option">Deutsch</option>' +
    '<option value="ru" class="blue-option" selected>Русский</option>' +
    '<option value="en" class="blue-option">English</option>' +
    '<option value="fr" class="blue-option">Français</option>' +
    '<option value="es" class="blue-option">Español</option>' +
    '</select><div class="note">Наведение на закрытый список и пункты меню меняет цвет оформления.</div></div>' +
    '<div class="card"><div class="heading">Основной компонент</div>' +
    '<p class="hint">Выберите технологию, которая будет добавлена в состав установки.</p>' +
    '<div class="theme green">ЗЕЛЁНЫЙ СТИЛЬ</div>' +
    '<label class="field-label" for="select-component">Компонент</label>' +
    '<select id="select-component" class="select-green">' +
    '<optgroup label="Основные" class="green-group">' +
    '<option value="delphi" class="green-option" selected>Delphi</option>' +
    '<option value="fpc" class="green-option">Free Pascal</option></optgroup>' +
    '<optgroup label="Графика" class="green-group">' +
    '<option value="skia" class="green-option">Skia</option>' +
    '<option value="svg" class="green-option">SVG</option></optgroup>' +
    '<optgroup label="Недоступные" class="green-group" disabled>' +
    '<option value="legacy" class="green-option">Устаревший модуль</option></optgroup>' +
    '</select><div class="note">Некоторые пункты сгруппированы, недоступные варианты нельзя выбрать.</div></div>' +
    '<div class="card"><div class="heading">Дополнительный пакет</div>' +
    '<p class="hint">В списке много вариантов. Прокрутите его или используйте клавиши со стрелками.</p>' +
    '<div class="theme amber">ЯНТАРНЫЙ СТИЛЬ</div>' +
    '<label class="field-label" for="select-package">Пакет</label>' +
    '<select id="select-package" class="select-amber">' +
    '<option value="item-01" class="amber-option" selected>Пакет 01 — базовый</option>' +
    '<option value="item-02" class="amber-option">Пакет 02</option>' +
    '<option value="item-03" class="amber-option">Пакет 03</option>' +
    '<option value="item-04" class="amber-option">Пакет 04</option>' +
    '<option value="item-05" class="amber-option">Пакет 05</option>' +
    '<option value="item-06" class="amber-option">Пакет 06</option>' +
    '<option value="item-07" class="amber-option">Пакет 07</option>' +
    '<option value="item-08" class="amber-option">Пакет 08</option>' +
    '<option value="item-09" class="amber-option">Пакет 09</option>' +
    '<option value="item-10" class="amber-option">Пакет 10</option>' +
    '<option value="item-11" class="amber-option">Пакет 11</option>' +
    '<option value="item-12" class="amber-option">Пакет 12 — расширенный</option>' +
    '<option value="item-13" class="amber-option">Пакет 13</option>' +
    '<option value="item-14" class="amber-option">Пакет 14</option>' +
    '<option value="item-15" class="amber-option">Пакет 15</option>' +
    '<option value="item-16" class="amber-option">Пакет 16 — последний</option>' +
    '</select><div class="note">В длинном списке доступны прокрутка, Home, End, PgUp и PgDn.</div></div>' +
    '<div class="card"><div class="heading">Редакция приложения</div>' +
    '<p class="hint">Эта редакция задаётся поставщиком и недоступна для изменения.</p>' +
    '<div class="theme gray">ТОЛЬКО ЧТЕНИЕ</div>' +
    '<label class="field-label" for="select-edition">Редакция</label>' +
    '<select id="select-edition" class="select-disabled" disabled>' +
    '<option value="professional" selected>Professional</option>' +
    '<option value="enterprise">Enterprise</option></select>' +
    '<div class="note">Список отключён: его значение нельзя поменять.</div></div>' +
    '</div>' +
    '<div class="actions"><span class="action-note">«Рекомендуемые параметры» подставит подходящий набор. Перед продолжением его можно изменить вручную.</span>' +
    '<button id="btn-recommended">Рекомендуемые параметры</button>' +
    '<button id="btn-next" class="primary">Далее</button></div>' +
    '</body></html>';
end;

function BuildSummaryHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:668px;margin:0;padding:0;overflow:hidden;}' +
    'body{padding:24px 28px;background:#0b1422;color:#e7eef7;font:12px "Segoe UI",Arial,sans-serif;}' +
    '.eyebrow{color:#78bdb4;font-size:10px;font-weight:700;letter-spacing:1.4px;text-transform:uppercase;}' +
    '.title{margin-top:7px;color:#f3f7fb;font-size:22px;font-weight:650;}' +
    '.subtitle{margin-top:6px;color:#9bacbf;font-size:11px;}' +
    '.summary{margin-top:24px;padding:18px 20px;background:#132136;border:1px solid #2b405b;border-radius:7px;}' +
    '.row{padding:12px 0;border-bottom:1px solid #263951;}' +
    '.row:last-child{border:0;}' +
    '.label{display:inline-block;vertical-align:top;width:190px;color:#91a5bb;font-size:11px;}' +
    '.value{display:inline-block;vertical-align:top;width:calc(100% - 200px);color:#edf4fb;font-size:12px;}' +
    '.actions{margin-top:22px;padding-top:14px;border-top:1px solid #24374f;}' +
    'button{padding:10px 16px;margin-right:8px;background:#253b57;color:#edf4fb;border:1px solid #496482;border-radius:5px;cursor:pointer;font:11px "Segoe UI",Arial,sans-serif;}' +
    'button:hover{background:#315477;border-color:#82d3c7;color:#fff;}' +
    'button.primary{float:right;background:#16766e;border-color:#2b9c90;color:#fff;font-weight:700;}' +
    '.done{margin-top:22px;padding:14px;background:#103a37;border:1px solid #247d73;color:#c7f5ec;border-radius:6px;}' +
    '</style></head><body>' +
    '<div class="eyebrow">PIXIE Setup · Шаг 2 из 2</div>' +
    '<div id="summary-title" class="title">Выбранные параметры</div>' +
    '<div id="summary-subtitle" class="subtitle">Проверьте выбор перед продолжением.</div>' +
    '<div class="summary">' +
    '<div class="row"><span class="label">Язык интерфейса</span><span id="summary-language" class="value"></span></div>' +
    '<div class="row"><span class="label">Основной компонент</span><span id="summary-component" class="value"></span></div>' +
    '<div class="row"><span class="label">Дополнительный пакет</span><span id="summary-package" class="value"></span></div>' +
    '<div class="row"><span class="label">Редакция приложения</span><span id="summary-edition" class="value">Professional</span></div>' +
    '</div>' +
    '<div id="summary-done" class="done" style="display:none">Настройки сохранены. Можно переходить к следующему этапу установки.</div>' +
    '<div class="actions"><button id="btn-back">Назад</button>' +
    '<button id="btn-continue" class="primary">Продолжить</button></div>' +
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

procedure WriteSelectValue(const Id, Value: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  Elem.SetValue(Value);
end;

function ReadSelectValue(const Id: String): String;
var
  H: NativeInt;
begin
  Result := '';
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  Result := Elem.GetValue;
end;

function LanguageCaption(const Value: String): String;
begin
  if Value = 'en' then Result := 'English'
  else if Value = 'de' then Result := 'Deutsch'
  else if Value = 'fr' then Result := 'Français'
  else if Value = 'es' then Result := 'Español'
  else Result := 'Русский';
end;

function ComponentCaption(const Value: String): String;
begin
  if Value = 'fpc' then Result := 'Free Pascal'
  else if Value = 'skia' then Result := 'Skia'
  else if Value = 'svg' then Result := 'SVG'
  else Result := 'Delphi';
end;

function PackageCaption(const Value: String): String;
begin
  if Value = '' then
    Result := 'Не выбран'
  else if Value = 'item-12' then
    Result := 'Пакет 12 — расширенный'
  else
    Result := 'Пакет ' + Copy(Value, 6, 2);
end;

procedure LoadDefaultValues;
begin
  LanguageValue := 'ru';
  ComponentValue := 'delphi';
  PackageValue := 'item-01';
  LanguageName := LanguageCaption(LanguageValue);
  ComponentName := ComponentCaption(ComponentValue);
  PackageName := PackageCaption(PackageValue);
end;

procedure ShowOptionsPage;
begin
  View.LoadFromString(BuildOptionsHtml);
  Doc.FCreate(View.GetDocument);
  WriteSelectValue('select-language', LanguageValue);
  WriteSelectValue('select-component', ComponentValue);
  WriteSelectValue('select-package', PackageValue);
  WriteSelectValue('select-edition', 'professional');
  Doc.Changed;
end;

procedure ReadOptions;
begin
  LanguageValue := ReadSelectValue('select-language');
  ComponentValue := ReadSelectValue('select-component');
  PackageValue := ReadSelectValue('select-package');

  LanguageName := LanguageCaption(LanguageValue);
  ComponentName := ComponentCaption(ComponentValue);
  PackageName := PackageCaption(PackageValue);
end;

procedure ShowSummaryPage;
begin
  ReadOptions;
  IsConfirmed := False;
  View.LoadFromString(BuildSummaryHtml);
  Doc.FCreate(View.GetDocument);
  SetOutput('summary-language', LanguageName);
  SetOutput('summary-component', ComponentName);
  SetOutput('summary-package', PackageName);
  Doc.Changed;
end;

procedure ConfirmOptions;
begin
  IsConfirmed := True;
  SetOutput('summary-title', 'Настройки сохранены');
  SetOutput('summary-subtitle', 'Выбранные параметры переданы установщику.');
  SetOutput('summary-done', 'Готово. В реальном установщике теперь можно переходить к копированию выбранных компонентов.');
  SetOutput('btn-continue', 'Завершить');
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
  if El = nil then Exit;

  H := NativeInt(El);
  Id := '';
  while H <> 0 do
  begin
    Elem.FCreate(H);
    Id := Elem.GetAttr('id', '');
    if Id <> '' then Break;
    H := Elem.Parent;
  end;
  if H = 0 then Exit;

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
    WriteSelectValue('select-language', 'en');
    WriteSelectValue('select-component', 'skia');
    WriteSelectValue('select-package', 'item-12');
    LanguageValue := 'en';
    ComponentValue := 'skia';
    PackageValue := 'item-12';
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

  if Id = 'btn-continue' then
  begin
    if IsConfirmed then
      CloseSetup
    else
      ConfirmOptions;
    Result := True;
    Exit;
  end;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
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
  LoadDefaultValues;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('PIXIE Setup');

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
