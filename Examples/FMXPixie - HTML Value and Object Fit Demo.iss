; ============================================================================
; FMXPixie - HTML Value API and object-fit / object-position Demo
;
; Demonstrates:
;   FPixieElement.GetValue / SetValue:
;     - input type=text
;     - textarea
;     - input type=checkbox / radio (HTML value attribute)
;     - input type=range
;     - select
;   FPixieElement.GetChecked / SetChecked:
;     - checkbox / radio checked state (separate from value)
;   CSS image presentation:
;     - object-fit: fill / contain / cover / none / scale-down
;     - object-position: keyword and percentage positions
;
; The range control is disabled intentionally: this demo tests programmatic
; SetValue / GetValue, not pointer dragging of the slider.
; ============================================================================

#define DemoAppName "FMXPixie - HTML Value and Object Fit Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - HTML Value and Object Fit Demo
//SetupArchitecture=x64
SetupIconFile=Files\setup.ico

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
Source: "Files\FMXPixie_SvgView_Demo.svg"; Flags: dontcopy

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  DEMO_FORM_WIDTH = 920;
  DEMO_FORM_HEIGHT = 820;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;
  TempDir: String;

// ---------------------------------------------------------------------------
// HTML
// ---------------------------------------------------------------------------
function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:32px;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#111827;color:#e5e7eb;font-family:"Segoe UI",Arial,sans-serif;font-size:14px;}' +
    '.titlebar{position:relative;width:100%;height:31px;overflow:hidden;background:#111827;border-bottom:1px solid #263247;line-height:31px;}' +
    '.title-caption{margin-left:12px;color:#93c5fd;font-weight:bold;}' +
    '.title-controls{position:absolute;top:0;right:0;width:92px;height:31px;font-size:0;}' +
    '.title-button{display:inline-block;vertical-align:top;overflow:hidden;width:46px;height:31px;line-height:31px;text-align:center;color:#d1d5db;cursor:pointer;font-size:23px;}' +
    '.title-close{font-size:25px;line-height:28px;}' +
    '.title-minimize:hover{background:#25344b;color:#fff;}' +
    '.title-close:hover{background:#dc2626;color:#fff;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="title-caption">FMXPIXIE / HTML VALUE API + OBJECT FIT</span>' +
    '<div class="title-controls">' +
    '<div id="title-minimize" class="title-button title-minimize" title="Свернуть">−</div>' +
    '<div id="title-close" class="title-button title-close" title="Закрыть">×</div>' +
    '</div></div></body></html>';
end;

function BuildDemoHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'body{margin:0;padding:16px;background:transparent;color:#e5e7eb;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;line-height:1.35;}' +
    '.intro,.panel{background:#111827;border:1px solid #263247;padding:12px;margin:0 0 10px 0;}' +
    '.brand{color:#93c5fd;font-size:22px;font-weight:bold;}' +
    '.sub,.hint{color:#9ca3af;font-size:11px;margin-top:4px;}' +
    '.section-title{color:#93c5fd;font-weight:bold;font-size:13px;margin-bottom:8px;}' +
    '.field{display:inline-block;vertical-align:top;width:48%;margin:0 1% 7px 0;}' +
    '.field-label{display:block;color:#cbd5e1;margin:0 0 4px 0;}' +
    'input[type=text],textarea,select{display:block;box-sizing:border-box;width:100%;background:#1f2937;color:#f9fafb;border:1px solid #475569;border-radius:4px;padding:6px 8px;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    'input[type=text],select{height:32px;}' +
    'textarea{height:62px;resize:none;}' +
    '.choice{display:inline-block;vertical-align:top;margin:5px 14px 4px 0;color:#d1d5db;}' +
    '.choice input{margin-right:5px;}' +
    '.range-line{margin:5px 0;color:#d1d5db;}' +
    'input[type=range]{width:210px;vertical-align:middle;}' +
    'button{margin:5px 7px 0 0;padding:7px 11px;background:#25344b;color:#f9fafb;border:1px solid #40516b;border-radius:4px;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;cursor:pointer;}' +
    'button:hover{background:#2563a6;border-color:#60a5fa;}' +
    '.primary{background:#1d4ed8;border-color:#3b82f6;}' +
    '.readout{margin-top:8px;padding:8px;background:#07101f;border:1px solid #263247;color:#a7f3d0;white-space:pre-wrap;font-family:Consolas,"Courier New",monospace;font-size:11px;}' +
    '.note{margin-top:7px;padding:7px;background:#0b1728;border:1px solid #334155;color:#bfdbfe;font-size:11px;}' +
    '.gallery{margin-top:3px;}' +
    '.sample{display:inline-block;vertical-align:top;width:160px;margin:0 7px 8px 0;}' +
    '.sample-title{color:#cbd5e1;font-size:11px;font-weight:bold;margin-bottom:4px;}' +
    '.frame{width:158px;height:104px;overflow:hidden;background:#080f1c;border:1px solid #475569;border-radius:4px;}' +
    '.frame img{display:block;width:100%;height:100%;border-radius:3px;}' +
    '#fit-fill{object-fit:fill;object-position:center center;}' +
    '#fit-contain{object-fit:contain;object-position:center center;}' +
    '#fit-cover{object-fit:cover;object-position:75% 20%;}' +
    '#fit-none{object-fit:none;object-position:left top;}' +
    '#fit-scale-down{object-fit:scale-down;object-position:center center;}' +
    '.fit-caption{font-size:10px;color:#9ca3af;margin-top:3px;}' +
    '</style></head><body>' +

    '<div class="intro">' +
    '<div class="brand">HTML values + image fitting</div>' +
    '<div class="sub">Первая часть проверяет программное чтение и запись значений элементов через FPixieElement. Вторая показывает размещение одного SVG в одинаковых областях с разными object-fit / object-position.</div>' +
    '</div>' +

    '<div class="panel">' +
    '<div class="section-title">01 / GetValue и SetValue</div>' +
    '<div class="field"><label class="field-label" for="install-path">Text — путь установки</label>' +
    '<input id="install-path" type="text" value="C:\\Program Files\\NOVA"></div>' +
    '<div class="field"><label class="field-label" for="install-channel">Select — канал выпуска</label>' +
    '<select id="install-channel"><option value="stable" selected>Stable</option><option value="beta">Beta</option><option value="nightly">Nightly</option></select></div>' +
    '<div class="field"><label class="field-label" for="install-notes">Textarea — заметки конфигурации</label>' +
    '<textarea id="install-notes" rows="3">Install for the current user. Keep existing settings.</textarea></div>' +
    '<div class="field"><div class="field-label">Range — размер кэша (программное значение)</div>' +
    '<div class="range-line"><input id="cache-size" type="range" min="0" max="100" step="5" value="40" disabled><span id="cache-size-label">40%</span></div>' +
    '<div class="hint">Ползунок отключён: здесь проверяется именно SetValue / GetValue для числового значения.</div></div>' +

    '<div class="field-label">Checkbox — значение и состояние разделены</div>' +
    '<label class="choice"><input id="desktop-shortcut" type="checkbox" value="desktop-shortcut" checked>Создать ярлык</label>' +
    '<div class="hint">GetValue читает value="desktop-shortcut". GetChecked отдельно сообщает, установлена ли галочка.</div>' +

    '<div class="field-label" style="margin-top:7px">Radio — значение выбранного варианта и checked</div>' +
    '<label class="choice"><input id="package-full" type="radio" name="package" value="full" checked>Полная</label>' +
    '<label class="choice"><input id="package-portable" type="radio" name="package" value="portable">Portable</label>' +
    '<div class="buttons">' +
    '<button id="btn-fill" class="primary">SetValue / SetChecked: заполнить</button>' +
    '<button id="btn-read">GetValue / GetChecked: прочитать</button>' +
    '<button id="btn-reset">Сбросить</button>' +
    '</div>' +
    '<div id="value-readout" class="readout">Нажми «Прочитать», чтобы получить значения элементов.</div>' +
    '<div class="note">Для Checkbox / Radio значение value — это строка, отправляемая формой. Состояние выбора — отдельное Boolean-свойство Checked. Поэтому SetValue не заменяет SetChecked.</div>' +
    '</div>' +

    '<div class="panel">' +
    '<div class="section-title">02 / object-fit и object-position</div>' +
    '<div class="sub">Все пять областей имеют одинаковые размеры. Разница видна в том, как исходное изображение вписывается и обрезается.</div>' +
    '<div class="gallery">' +
    '<div class="sample"><div class="sample-title">fill</div><div class="frame"><img id="fit-fill" src="FMXPixie_SvgView_Demo.svg" alt="SVG sample"></div><div class="fit-caption">Растягивает по ширине и высоте</div></div>' +
    '<div class="sample"><div class="sample-title">contain</div><div class="frame"><img id="fit-contain" src="FMXPixie_SvgView_Demo.svg" alt="SVG sample"></div><div class="fit-caption">Целиком, без обрезки</div></div>' +
    '<div class="sample"><div class="sample-title">cover</div><div class="frame"><img id="fit-cover" src="FMXPixie_SvgView_Demo.svg" alt="SVG sample"></div><div class="fit-caption">Заполнение с обрезкой; позиция 75% 20%</div></div>' +
    '<div class="sample"><div class="sample-title">none</div><div class="frame"><img id="fit-none" src="FMXPixie_SvgView_Demo.svg" alt="SVG sample"></div><div class="fit-caption">Натуральный размер; позиция left top</div></div>' +
    '<div class="sample"><div class="sample-title">scale-down</div><div class="frame"><img id="fit-scale-down" src="FMXPixie_SvgView_Demo.svg" alt="SVG sample"></div><div class="fit-caption">Contain или натуральный размер — меньший</div></div>' +
    '</div>' +
    '<div class="note">object-position задаёт точку изображения, которая совмещается с такой же точкой области. Например, 75% 20% смещает фокус к правой верхней части изображения.</div>' +
    '</div>' +

    '</body></html>';
end;

// ---------------------------------------------------------------------------
// DOM helpers
// ---------------------------------------------------------------------------
procedure SetValueById(const Id, Value: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  Elem.SetValue(Value);
end;

function GetValueById(const Id: String): String;
var
  H: NativeInt;
begin
  Result := '';
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  Result := Elem.GetValue;
end;

procedure SetCheckedById(const Id: String; Value: Boolean);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  Elem.SetChecked(Value);
end;

function GetCheckedById(const Id: String): Boolean;
var
  H: NativeInt;
begin
  Result := False;
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  Result := Elem.GetChecked;
end;

procedure SetTextById(const Id, Value: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then Exit;
  Doc.SetElementText(H, Value);
end;

procedure ReadAndDisplayValues;
var
  PackageValue: String;
  PackageChecked: String;
  DesktopState: String;
  H: NativeInt;
begin
  PackageValue := '';
  PackageChecked := '';
  if GetCheckedById('package-portable') then
  begin
    PackageValue := GetValueById('package-portable');
    PackageChecked := 'Portable (checked=True)';
  end
  else
  begin
    PackageValue := GetValueById('package-full');
    PackageChecked := 'Full (checked=' + BoolToStr(GetCheckedById('package-full'), True) + ')';
  end;

  if GetCheckedById('desktop-shortcut') then
    DesktopState := 'True'
  else
    DesktopState := 'False';

  Doc.BeginUpdate;
  try
    SetTextById('cache-size-label', GetValueById('cache-size') + '%');
    SetTextById('value-readout',
      'Text path: ' + GetValueById('install-path') + #13#10 +
      'Textarea: ' + GetValueById('install-notes') + #13#10 +
      'Select: ' + GetValueById('install-channel') + #13#10 +
      'Range: ' + GetValueById('cache-size') + #13#10 +
      'Checkbox value: ' + GetValueById('desktop-shortcut') + #13#10 +
      'Checkbox checked: ' + DesktopState + #13#10 +
      'Radio value: ' + PackageValue + #13#10 +
      'Radio state: ' + PackageChecked);
  finally
    Doc.EndUpdate;
  end;
end;

procedure FillDemoValues;
begin
  Doc.BeginUpdate;
  try
    SetValueById('install-path', 'D:\\Apps\\NOVA Studio');
    SetValueById('install-notes',
      'Install for all users.' + #13#10 + 'Create shortcuts and file associations.');
    SetValueById('install-channel', 'beta');
    SetValueById('cache-size', '75');

    // SetValue changes the submitted value attribute; SetChecked controls
    // whether the checkbox/radio is selected.
    SetValueById('desktop-shortcut', 'desktop-link');
    SetCheckedById('desktop-shortcut', True);
    SetValueById('package-full', 'full');
    SetValueById('package-portable', 'portable');
    SetCheckedById('package-full', False);
    SetCheckedById('package-portable', True);
  finally
    Doc.EndUpdate;
  end;
  ReadAndDisplayValues;
end;

procedure ResetDemoValues;
begin
  Doc.BeginUpdate;
  try
    SetValueById('install-path', 'C:\\Program Files\\NOVA');
    SetValueById('install-notes',
      'Install for the current user. Keep existing settings.');
    SetValueById('install-channel', 'stable');
    SetValueById('cache-size', '40');
    SetValueById('desktop-shortcut', 'desktop-shortcut');
    SetCheckedById('desktop-shortcut', True);
    SetValueById('package-full', 'full');
    SetValueById('package-portable', 'portable');
    SetCheckedById('package-full', True);
    SetCheckedById('package-portable', False);
  finally
    Doc.EndUpdate;
  end;
  ReadAndDisplayValues;
end;

// ---------------------------------------------------------------------------
// Click handling — existing OnElementClick API, no form-event callbacks.
// ---------------------------------------------------------------------------
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

  if Id = 'btn-fill' then
  begin
    FillDemoValues;
    Result := True;
    Exit;
  end;

  if Id = 'btn-read' then
  begin
    ReadAndDisplayValues;
    Result := True;
    Exit;
  end;

  if Id = 'btn-reset' then
  begin
    ResetDemoValues;
    Result := True;
    Exit;
  end;
end;

// ---------------------------------------------------------------------------
// Title bar drag
// ---------------------------------------------------------------------------
procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
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
  ExtractTemporaryFile('FMXPixie_SvgView_Demo.svg');

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
  View.SetScrollbarVisibility(svAuto);
  View.BaseUrl(TempDir + '\\');
  View.OnElementClick(@ElementClick);
  View.LoadFromStringUrl(BuildDemoHtml, TempDir + '\\');

  Doc.FCreate(View.GetDocument);
  ReadAndDisplayValues;
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
