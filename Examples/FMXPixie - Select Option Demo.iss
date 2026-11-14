; ============================================================================
; FMXPixie - Select / Option Demo
; Тестирование HTML <select>, <option> и <optgroup> в FMXPixie DLL.
;
; Необходимые файлы:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;
; Проверяется:
;   - одиночный select и начальный selected option
;   - option value / label
;   - группировка optgroup
;   - disabled option и disabled optgroup
;   - длинный список и прокрутка popup колесом мыши
;   - клавиатурная навигация: Up / Down / Home / End / PgUp / PgDn
;   - Enter / Space и отмена через Escape
;   - FPixieElement.GetValue / SetValue
;
; multiple намеренно не тестируется: он не входит в первую реализацию.
; ============================================================================

#define DemoAppName "FMXPixie - Select Option Demo"
#define DemoAppVersion "1.0"

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

  TempDir: String;

function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html>' +
    '<html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:32px;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#111827;color:#e5e7eb;font-family:"Segoe UI",Arial,sans-serif;font-size:14px;}' +
    '.titlebar{position:relative;width:100%;height:31px;overflow:hidden;background:#111827;border-bottom:1px solid #263247;line-height:31px;}' +
    '.title-caption{margin-left:12px;color:#93c5fd;font-weight:bold;}' +
    '.title-controls{position:absolute;top:0;right:0;width:92px;height:31px;font-size:0;}' +
    '.title-button{display:inline-block;vertical-align:top;overflow:hidden;width:46px;height:31px;line-height:31px;text-align:center;color:#d1d5db;cursor:pointer;font-size:23px;}' +
    '.title-close{font-size:25px;line-height:28px;}' +
    '.title-minimize:hover{background:#25344b;color:#fff;}' +
    '.title-close:hover{background:#dc2626;color:#fff;}' +
    '.title-button:active{background:#1d4ed8;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="title-caption">FMXPixie / HTML SELECT TEST</span>' +
    '<div class="title-controls">' +
    '<div id="title-minimize" class="title-button title-minimize" title="Свернуть">−</div>' +
    '<div id="title-close" class="title-button title-close" title="Закрыть">×</div>' +
    '</div></div></body></html>';
end;

function BuildDemoHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'body{margin:0;padding:20px;background:transparent;color:#e5e7eb;font-family:"Segoe UI",Arial,sans-serif;font-size:14px;}' +
    '.topline{background:#111827;border:1px solid #263247;padding:16px;margin-bottom:14px;}' +
    '.brand{color:#93c5fd;font-size:24px;font-weight:bold;}' +
    '.sub{color:#9ca3af;margin-top:4px;}' +
    '.tag{display:inline-block;color:#a7f3d0;border:1px solid #276749;padding:4px 8px;margin-top:10px;}' +
    '.panel{background:#111827;border:1px solid #263247;padding:16px;margin-bottom:14px;}' +
    '.section-title{color:#93c5fd;font-weight:bold;margin-bottom:10px;}' +
    '.muted{color:#9ca3af;}' +
    '.field-label{display:block;color:#cbd5e1;margin-top:9px;margin-bottom:5px;}' +
    'select{width:290px;height:34px;margin:2px 0 8px;background:#1f2937;color:#e5e7eb;border:1px solid #475569;border-radius:8px;}' +
    'option{background:#1f2937;color:#e5e7eb;}' +
    'option:hover{background:#334155;color:#fff;border-radius:5px;}' +
    'option:checked{background:#2563eb;color:#fff;border-radius:5px;}' +
    'option:disabled{color:#64748b;}' +
    'optgroup{background:#263449;color:#93c5fd;border-radius:5px;}' +
    'optgroup:hover{background:#334155;}' +
    'optgroup:disabled{color:#64748b;}' +
    'button{background:#25344b;color:#f9fafb;border:1px solid #40516b;padding:8px 12px;margin:4px 5px 4px 0;cursor:pointer;}' +
    'button:hover{background:#2563a6;border-color:#60a5fa;}' +
    'button:active{background:#174477;}' +
    '.primary{background:#1d4ed8;border-color:#3b82f6;}' +
    '.row{margin-top:8px;}' +
    '.value{display:inline-block;min-width:180px;color:#a7f3d0;background:#07101f;border:1px solid #263247;padding:5px 8px;margin:3px 0;}' +
    '.status{background:#07101f;border:1px solid #263247;padding:10px;color:#bfdbfe;margin-top:12px;}' +
    '.hint{font-size:12px;color:#9ca3af;margin-top:5px;}' +
    '.disabled-note{color:#fca5a5;}' +
    '</style></head><body>' +

    '<div class="topline">' +
    '<div class="brand">HTML Select / Option</div>' +
    '<div class="sub">Проверка выпадающих списков внутри FMX-формы Inno Setup</div>' +
    '<div class="tag">TEST BUILD · SINGLE SELECT</div>' +
    '</div>' +

    '<div class="panel">' +
    '<div class="section-title">01 / Обычный select и атрибуты option</div>' +
    '<div class="muted">Проверь открытие списка, выбор мышью, начальное состояние selected и чтение value.</div>' +
    '<label class="field-label" for="select-basic">Язык интерфейса</label>' +
    '<select id="select-basic">' +
    '<option value="de">Deutsch</option>' +
    '<option value="ru" selected>Русский</option>' +
    '<option value="en" label="English">English language</option>' +
    '<option value="fr">Français</option>' +
    '<option value="es">Español</option>' +
    '</select>' +
    '<div class="row"><button id="btn-set-basic" class="primary">SetValue: English</button>' +
    '<span class="hint">Кнопка программно выбирает option с value="en".</span></div>' +
    '</div>' +

    '<div class="panel">' +
    '<div class="section-title">02 / optgroup и disabled</div>' +
    '<div class="muted">Группы должны отображаться отдельными строками. Недоступные пункты должны быть серыми и не выбираться.</div>' +
    '<label class="field-label" for="select-groups">Компонент</label>' +
    '<select id="select-groups">' +
    '<optgroup label="Основные">' +
    '<option value="delphi" selected>Delphi</option>' +
    '<option value="fpc">Free Pascal</option>' +
    '</optgroup>' +
    '<optgroup label="Графика">' +
    '<option value="skia">Skia</option>' +
    '<option value="svg">SVG</option>' +
    '</optgroup>' +
    '<optgroup label="Недоступная группа" disabled>' +
    '<option value="disabled-group">Этот пункт отключён группой</option>' +
    '</optgroup>' +
    '<option value="disabled-option" disabled>Отдельный disabled option</option>' +
    '</select>' +
    '<div class="row"><button id="btn-set-group">SetValue: Skia</button>' +
    '<span class="hint">Отдельно проверь disabled-группу и disabled option.</span></div>' +
    '</div>' +

    '<div class="panel">' +
    '<div class="section-title">03 / Длинный список и клавиатура</div>' +
    '<div class="muted">Список содержит больше строк, чем помещается в popup. Проверь прокрутку колесом и переходы по клавишам.</div>' +
    '<label class="field-label" for="select-long">Тестовый список</label>' +
    '<select id="select-long">' +
    '<option value="item-01" selected>Пункт 01 — первый</option>' +
    '<option value="item-02">Пункт 02</option>' +
    '<option value="item-03">Пункт 03</option>' +
    '<option value="item-04">Пункт 04</option>' +
    '<option value="item-05">Пункт 05</option>' +
    '<option value="item-06">Пункт 06</option>' +
    '<option value="item-07">Пункт 07</option>' +
    '<option value="item-08">Пункт 08</option>' +
    '<option value="item-09">Пункт 09</option>' +
    '<option value="item-10">Пункт 10</option>' +
    '<option value="item-11">Пункт 11</option>' +
    '<option value="item-12">Пункт 12</option>' +
    '<option value="item-13">Пункт 13</option>' +
    '<option value="item-14">Пункт 14</option>' +
    '<option value="item-15">Пункт 15</option>' +
    '<option value="item-16">Пункт 16 — последний</option>' +
    '</select>' +
    '<div class="row"><button id="btn-set-long">SetValue: item-12</button></div>' +
    '<div class="hint">Клавиши: Up / Down, Home / End, PgUp / PgDn, Enter / Space, Escape.</div>' +
    '</div>' +

    '<div class="panel">' +
    '<div class="section-title">04 / Чтение значения и проверка API</div>' +
    '<div class="muted">После выбора нажми «Считать значения». Для каждого select вызывается FPixieElement.GetValue.</div>' +
    '<div>Язык: <span id="value-basic" class="value">—</span></div>' +
    '<div>Компонент: <span id="value-groups" class="value">—</span></div>' +
    '<div>Длинный список: <span id="value-long" class="value">—</span></div>' +
    '<div class="row">' +
    '<button id="btn-read-values" class="primary">Считать значения</button>' +
    '<button id="btn-reset">Сбросить значения</button>' +
    '</div>' +
    '<div class="status" id="demo-status">Готово. Выбери значения и нажми «Считать значения».</div>' +
    '</div>' +

    '<div class="panel">' +
    '<div class="section-title">05 / Отключённый select</div>' +
    '<label class="field-label" for="select-disabled">Этот список отключён</label>' +
    '<select id="select-disabled" disabled>' +
    '<option value="locked" selected>Недоступный элемент</option>' +
    '<option value="locked-2">Ещё один недоступный элемент</option>' +
    '</select>' +
    '<div class="hint disabled-note">Попытка открыть или изменить список не должна менять его значение.</div>' +
    '</div>' +

    '<div class="hint">FMXPixie Select Demo · multiple не входит в текущий тест.</div>' +
    '</body></html>';
end;

// ---------------------------------------------------------------------------
// DOM helpers
// ---------------------------------------------------------------------------
procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, S);
end;

function GetSelectValue(const Id: String): String;
var
  H: NativeInt;
begin
  Result := '';
  H := Doc.GetElementById(Id);
  if H = 0 then
    Exit;

  Elem.FCreate(H);
  Result := Elem.GetValue;
end;

procedure SetSelectValue(const Id, Value: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then
    Exit;

  Elem.FCreate(H);
  Elem.SetValue(Value);
end;

procedure RefreshValues(const StatusText: String);
begin
  Doc.BeginUpdate;
  try
    SetTextById('value-basic', GetSelectValue('select-basic'));
    SetTextById('value-groups', GetSelectValue('select-groups'));
    SetTextById('value-long', GetSelectValue('select-long'));
    SetTextById('demo-status', StatusText);
  finally
    Doc.EndUpdate;
  end;
  Log('FMXPixie Select Demo: ' + StatusText);
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

// ---------------------------------------------------------------------------
// Event handling
// ---------------------------------------------------------------------------
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

  if Id = 'btn-read-values' then
  begin
    RefreshValues('Значения прочитаны через FPixieElement.GetValue.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-set-basic' then
  begin
    SetSelectValue('select-basic', 'en');
    RefreshValues('SetValue установил для select-basic значение en.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-set-group' then
  begin
    SetSelectValue('select-groups', 'skia');
    RefreshValues('SetValue установил для select-groups значение skia.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-set-long' then
  begin
    SetSelectValue('select-long', 'item-12');
    RefreshValues('SetValue установил для select-long значение item-12.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-reset' then
  begin
    SetSelectValue('select-basic', 'ru');
    SetSelectValue('select-groups', 'delphi');
    SetSelectValue('select-long', 'item-01');
    RefreshValues('Начальные значения восстановлены.');
    Result := True;
    Exit;
  end;
end;

// ---------------------------------------------------------------------------
// Title bar
// ---------------------------------------------------------------------------
procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TitleView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

// ---------------------------------------------------------------------------
// Initialization
// ---------------------------------------------------------------------------
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
  TempDir := ExpandConstant('{tmp}');

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);

  TitleView.FCreate(FMXForm.Handle);
  TitleView.Left(0);
  TitleView.Top(0);
  TitleView.Width(DEMO_FORM_WIDTH);
  TitleView.Height(TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@ViewMouseDown);
  TitleView.LoadFromString(BuildTitleBarHtml);

  View.FCreate(FMXForm.Handle);
  View.Left(0);
  View.Top(TITLEBAR_HEIGHT);
  View.Width(DEMO_FORM_WIDTH);
  View.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.BaseUrl(TempDir + '\');
  View.OnElementClick(@ElementClick);
  View.LoadFromStringUrl(BuildDemoHtml, TempDir + '\');

  Doc.FCreate(View.GetDocument);
  RefreshValues('Готово. Select / Option загружены.');
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
