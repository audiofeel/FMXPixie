#define DemoAppName "FMXPixie - Form Values Demo"
#define DemoAppVersion "1.2"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Form Values Demo
//SetupArchitecture=x64

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
  DEMO_FORM_HEIGHT = 630;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;

  TEST_TEXTAREA_VALUE = 'Textarea value set through FPixieElement.SetValue';
  TEST_CHECKBOX_VALUE = 'notifications-v2';
  TEST_RADIO_A_VALUE = 'desktop-v2';
  TEST_RADIO_B_VALUE = 'portable-v2';
  TEST_RANGE_REQUEST = '7.3';
  TEST_RANGE_RESULT = '7.5';
  TEST_RANGE_MAX_REQUEST = '12';
  TEST_RANGE_MAX_RESULT = '10';
  TEST_RANGE_MIN_REQUEST = '-2';
  TEST_RANGE_MIN_RESULT = '0';

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;

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
    '<span class="caption">FMXPixie</span><span class="sub">/ value API regression test</span>' +
    '<div class="buttons"><div id="title-minimize" class="button">−</div>' +
    '<div id="title-close" class="button close">×</div></div></div></body></html>';
end;

function BuildMainHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;padding:0;width:100%;height:598px;overflow:hidden;}' +
    'body{padding:12px 14px;background:#0b1220;color:#e5edf7;font:12px "Segoe UI",Arial,sans-serif;}' +
    '.intro{height:48px;margin-bottom:8px;}' +
    '.title{font-size:19px;font-weight:650;color:#8dd8ce;}' +
    '.subtitle{margin-top:4px;color:#9aabc0;font-size:11px;}' +
    '.toolbar{height:38px;margin-bottom:8px;padding:3px 0;}' +
    'button{margin:0 7px 0 0;padding:8px 12px;background:#23364f;color:#eaf2fa;border:1px solid #48617f;border-radius:5px;cursor:pointer;font:12px "Segoe UI",Arial,sans-serif;}' +
    'button:hover{background:#315477;border-color:#80c9c2;color:#fff;}' +
    'button.primary{background:#176b67;border-color:#2b9a8c;color:#fff;font-weight:bold;}' +
    '.summary{display:inline-block;margin-left:8px;color:#b6c7d8;font-size:11px;}' +
    '.grid-row{height:218px;margin-bottom:9px;white-space:normal;}' +
    '.card{display:inline-block;vertical-align:top;width:48.8%;height:218px;margin-right:1%;padding:11px 12px;background:#121e30;border:1px solid #2a3a52;border-radius:5px;white-space:normal;}' +
    '.heading{margin-bottom:7px;color:#8dd8ce;font-weight:bold;font-size:13px;}' +
    '.description{height:27px;margin-bottom:6px;color:#9aabc0;font-size:10px;line-height:1.35;}' +
    '.field-label{display:block;margin-bottom:4px;color:#c3cfdd;font-size:11px;}' +
    'textarea{display:block;width:100%;height:57px;padding:6px 8px;background:#0b1524;color:#edf4fb;border:1px solid #40536d;border-radius:4px;font:11px "Segoe UI",Arial,sans-serif;resize:none;}' +
    'input[type=range]{width:100%;margin:10px 0 4px;}' +
    'input[type=checkbox],input[type=radio]{vertical-align:middle;margin-right:5px;}' +
    'label.choice{display:inline-block;margin:5px 16px 4px 0;color:#d8e2ee;font-size:12px;}' +
    '.hint{margin:5px 0 7px;color:#8498af;font-size:10px;line-height:1.35;}' +
    '.result{margin-top:7px;padding:7px 8px;background:#091522;border:1px solid #2c4057;border-radius:4px;}' +
    '.result-line{margin:2px 0;color:#9aabc0;font-size:10px;line-height:1.35;}' +
    '.result-value{color:#e4edf6;font-family:Consolas,monospace;font-size:10px;word-wrap:break-word;}' +
    '.status{margin-left:7px;color:#8dd8ce;font-weight:bold;font-size:10px;}' +
    '.footer{margin-top:1px;color:#72869d;font-size:10px;}' +
    '</style></head><body>' +

    '<div class="intro">' +
    '<div class="title">Что именно проверяется</div>' +
    '<div class="subtitle">Только четыре добавления этой ветки: SetValue/GetValue для Textarea, Checkbox, Radio и Range. Text и Select здесь не тестируются — они поддерживались раньше.</div>' +
    '</div>' +

    '<div class="toolbar">' +
    '<button id="btn-run-test" class="primary">Запустить 4 проверки</button>' +
    '<button id="btn-read-current">Прочитать текущие значения</button>' +
    '<span id="test-summary" class="summary">Проверка ещё не запускалась.</span>' +
    '</div>' +

    '<div class="grid-row">' +
    '<div class="card">' +
    '<div class="heading">1. Textarea — программная запись текста</div>' +
    '<div class="description">Проверяет новый общий SetValue в текстовом базовом классе. Ранее Textarea можно было читать, но нельзя было записывать через этот API.</div>' +
    '<label class="field-label" for="field-textarea">Текстовое поле (можно также изменить вручную)</label>' +
    '<textarea id="field-textarea" rows="2">Исходное значение</textarea>' +
    '<div class="result">' +
    '<div class="result-line">Ожидается: <span id="res-textarea-expected" class="result-value">—</span><span id="res-textarea-status" class="status">—</span></div>' +
    '<div class="result-line">GetValue вернул: <span id="res-textarea-actual" class="result-value">—</span></div>' +
    '</div>' +
    '</div>' +

    '<div class="card">' +
    '<div class="heading">2. Range — программная запись числа</div>' +
    '<div class="description">Проверяет шаг и границы: 7.3 → 7.5; 12 → максимум 10; -2 → минимум 0. После проверки ползунок остаётся на 7.5.</div>' +
    '<label class="field-label" for="field-range">Ползунок (можно перемещать вручную)</label>' +
    '<input id="field-range" type="range" min="0" max="10" step="0.5" value="2.5">' +
    '<div class="hint">SetValue("7.3") → ограничение по min/max и округление по step.</div>' +
    '<div class="result">' +
    '<div class="result-line">Ожидается: <span id="res-range-expected" class="result-value">—</span><span id="res-range-status" class="status">—</span></div>' +
    '<div class="result-line">GetValue вернул: <span id="res-range-actual" class="result-value">—</span></div>' +
    '</div>' +
    '</div>' +
    '</div>' +

    '<div class="grid-row">' +
    '<div class="card">' +
    '<div class="heading">3. Checkbox — value отдельно от checked</div>' +
    '<div class="description">SetValue меняет атрибут value, а не состояние флажка. Тест проверяет оба значения до и после записи.</div>' +
    '<label class="choice"><input id="field-checkbox" type="checkbox" value="notifications" checked>Получать уведомления</label>' +
    '<div class="hint">Можно поставить или снять флажок перед запуском: тест запомнит его состояние и проверит, что SetValue его не изменил.</div>' +
    '<div class="result">' +
    '<div class="result-line">Ожидается: <span id="res-checkbox-expected" class="result-value">—</span><span id="res-checkbox-status" class="status">—</span></div>' +
    '<div class="result-line">Получено: <span id="res-checkbox-actual" class="result-value">—</span></div>' +
    '</div>' +
    '</div>' +

    '<div class="card">' +
    '<div class="heading">4. Radio — value отдельно от checked</div>' +
    '<div class="description">Проверяет SetValue для обеих радиокнопок. Атрибут value должен измениться, выбранный вариант — остаться прежним.</div>' +
    '<label class="choice"><input id="field-radio-a" type="radio" name="mode" value="desktop" checked>Desktop</label>' +
    '<label class="choice"><input id="field-radio-b" type="radio" name="mode" value="portable">Portable</label>' +
    '<div class="hint">Можно выбрать любой вариант перед запуском: тест сохранит текущее состояние группы.</div>' +
    '<div class="result">' +
    '<div class="result-line">Ожидается: <span id="res-radio-expected" class="result-value">—</span><span id="res-radio-status" class="status">—</span></div>' +
    '<div class="result-line">Получено: <span id="res-radio-actual" class="result-value">—</span></div>' +
    '</div>' +
    '</div>' +
    '</div>' +

    '<div class="footer">PASS — фактический результат совпал с ожидаемым. CURRENT — только чтение текущего значения после ручного изменения.</div>' +
    '</body></html>';
end;

// ---------------------------------------------------------------------------
// FPixieElement helpers
// ---------------------------------------------------------------------------
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

function BoolText(Value: Boolean): String;
begin
  if Value then
    Result := 'TRUE'
  else
    Result := 'FALSE';
end;

function ReadCheckboxState: String;
begin
  Result := 'value="' + ReadValue('field-checkbox') +
    '", checked=' + BoolText(ReadChecked('field-checkbox'));
end;

function ReadRadioState: String;
begin
  Result := 'A: value="' + ReadValue('field-radio-a') +
    '", checked=' + BoolText(ReadChecked('field-radio-a')) +
    '; B: value="' + ReadValue('field-radio-b') +
    '", checked=' + BoolText(ReadChecked('field-radio-b'));
end;

procedure SetOutput(const Id, Value: String);
var
  H: NativeInt;
begin
  H := ElementHandle(Id);
  if H <> 0 then
    Doc.SetElementText(H, Value);
end;

procedure SetTestResult(const RowId, ExpectedText, ActualText: String;
  Passed: Boolean);
begin
  SetOutput(RowId + '-expected', ExpectedText);
  SetOutput(RowId + '-actual', ActualText);

  if Passed then
    SetOutput(RowId + '-status', 'PASS')
  else
    SetOutput(RowId + '-status', 'FAIL');
end;

procedure SetCurrentResult(const RowId, ActualText: String);
begin
  SetOutput(RowId + '-expected', 'ручной ввод');
  SetOutput(RowId + '-actual', ActualText);
  SetOutput(RowId + '-status', 'CURRENT');
end;

procedure RunTests;
var
  CheckboxBefore, RadioABefore, RadioBBefore: Boolean;
  ActualTextArea, ActualCheckbox, ActualRadio, ActualRange: String;
  ActualRangeStep, ActualRangeMax, ActualRangeMin: String;
  ExpectedCheckbox, ExpectedRadio: String;
  PassedCount, FailedCount: Integer;
  CheckboxPassed, RadioPassed, RangePassed: Boolean;
begin
  // Сохраняем checked до SetValue: значение value не должно его менять.
  CheckboxBefore := ReadChecked('field-checkbox');
  RadioABefore := ReadChecked('field-radio-a');
  RadioBBefore := ReadChecked('field-radio-b');

  // Проверяем только новые возможности этой ветки.
  Doc.BeginUpdate;
  try
    WriteValue('field-textarea', TEST_TEXTAREA_VALUE);
    WriteValue('field-checkbox', TEST_CHECKBOX_VALUE);
    WriteValue('field-radio-a', TEST_RADIO_A_VALUE);
    WriteValue('field-radio-b', TEST_RADIO_B_VALUE);

    WriteValue('field-range', TEST_RANGE_REQUEST);
    ActualRangeStep := ReadValue('field-range');
    WriteValue('field-range', TEST_RANGE_MAX_REQUEST);
    ActualRangeMax := ReadValue('field-range');
    WriteValue('field-range', TEST_RANGE_MIN_REQUEST);
    ActualRangeMin := ReadValue('field-range');
    WriteValue('field-range', TEST_RANGE_REQUEST);
    ActualRange := ReadValue('field-range');
  finally
    Doc.EndUpdate;
  end;

  // Читаем результаты обратно через FPixieElement.GetValue.
  ActualTextArea := ReadValue('field-textarea');
  ActualCheckbox := ReadCheckboxState;
  ActualRadio := ReadRadioState;

  ExpectedCheckbox := 'value="' + TEST_CHECKBOX_VALUE +
    '", checked=' + BoolText(CheckboxBefore);
  ExpectedRadio := 'A: value="' + TEST_RADIO_A_VALUE +
    '", checked=' + BoolText(RadioABefore) +
    '; B: value="' + TEST_RADIO_B_VALUE +
    '", checked=' + BoolText(RadioBBefore);

  CheckboxPassed :=
    (ReadValue('field-checkbox') = TEST_CHECKBOX_VALUE) and
    (ReadChecked('field-checkbox') = CheckboxBefore);

  RadioPassed :=
    (ReadValue('field-radio-a') = TEST_RADIO_A_VALUE) and
    (ReadValue('field-radio-b') = TEST_RADIO_B_VALUE) and
    (ReadChecked('field-radio-a') = RadioABefore) and
    (ReadChecked('field-radio-b') = RadioBBefore);

  RangePassed :=
    (ActualRangeStep = TEST_RANGE_RESULT) and
    (ActualRangeMax = TEST_RANGE_MAX_RESULT) and
    (ActualRangeMin = TEST_RANGE_MIN_RESULT) and
    (ActualRange = TEST_RANGE_RESULT);

  PassedCount := 0;
  FailedCount := 0;

  Doc.BeginUpdate;
  try
    if ActualTextArea = TEST_TEXTAREA_VALUE then Inc(PassedCount)
    else Inc(FailedCount);
    SetTestResult('res-textarea', TEST_TEXTAREA_VALUE, ActualTextArea,
      ActualTextArea = TEST_TEXTAREA_VALUE);

    if CheckboxPassed then Inc(PassedCount)
    else Inc(FailedCount);
    SetTestResult('res-checkbox', ExpectedCheckbox, ActualCheckbox,
      CheckboxPassed);

    if RadioPassed then Inc(PassedCount)
    else Inc(FailedCount);
    SetTestResult('res-radio', ExpectedRadio, ActualRadio, RadioPassed);

    if RangePassed then Inc(PassedCount)
    else Inc(FailedCount);
    SetTestResult('res-range', 'step=' + TEST_RANGE_RESULT +
      '; max=' + TEST_RANGE_MAX_RESULT + '; min=' + TEST_RANGE_MIN_RESULT,
      'step=' + ActualRangeStep + '; max=' + ActualRangeMax +
      '; min=' + ActualRangeMin + '; final=' + ActualRange,
      RangePassed);

    if FailedCount = 0 then
      SetOutput('test-summary', 'PASS: ' + IntToStr(PassedCount) + '/4')
    else
      SetOutput('test-summary', 'FAIL: ' + IntToStr(FailedCount) +
        ' из 4. Смотри строки FAIL.');
  finally
    Doc.EndUpdate;
  end;

  Log('FMXPixie Form Values Demo: PASS=' + IntToStr(PassedCount) +
    ', FAIL=' + IntToStr(FailedCount));
end;

procedure ReadCurrentValues;
begin
  Doc.BeginUpdate;
  try
    SetCurrentResult('res-textarea', ReadValue('field-textarea'));
    SetCurrentResult('res-checkbox', ReadCheckboxState);
    SetCurrentResult('res-radio', ReadRadioState);
    SetCurrentResult('res-range', ReadValue('field-range'));
    SetOutput('test-summary', 'Текущие значения считаны через GetValue.');
  finally
    Doc.EndUpdate;
  end;

  Log('FMXPixie Form Values Demo: current values read.');
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

  if Id = 'btn-run-test' then
  begin
    RunTests;
    Result := True;
    Exit;
  end;

  if Id = 'btn-read-current' then
  begin
    ReadCurrentValues;
    Result := True;
    Exit;
  end;
end;

// ---------------------------------------------------------------------------
// Window
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
  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('FMXPixie - Form Values Demo');
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
  View.LoadFromString(BuildMainHtml);

  Doc.FCreate(View.GetDocument);
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
