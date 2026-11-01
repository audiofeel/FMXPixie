; ============================================================================
; FMXPixie - Gamepad Input Demo
;
; FMXPixie is the UI host:
;   - Inno Setup only hosts the DLL and provides the process lifetime.
;   - The window, title bar, device list and input monitor are FMXPixie /
;     TPixieHtmlView.
;   - HTML clicks are routed to Pascal Script through OnElementClick.
;   - FMXInput is polled on the Setup UI thread using a WinAPI timer.
;
; Required:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;
; This demo does not install an application.
; ============================================================================

#define DemoAppName "FMXPixie - Gamepad Input Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
DisableProgramGroupPage=yes
OutputBaseFilename=FMXPixie - Gamepad Input Demo
SetupIconFile=Files\setup.ico
PrivilegesRequired=lowest

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  DEMO_FORM_WIDTH = 1020;
  DEMO_FORM_HEIGHT = 720;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;

  INPUT_POLL_INTERVAL = 16;
  INPUT_DEVICE_CHECK_INTERVAL = 1000;

  ACTION_NEXT = 101;
  ACTION_BACK = 102;
  ACTION_CANCEL = 103;

  XINPUT_BUTTON_A_CODE = 12;
  XINPUT_BUTTON_B_CODE = 13;
  XINPUT_BUTTON_X_CODE = 14;
  XINPUT_DEVICE_ID_PREFIX = 'windows:xinput:slot:';


var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;
  Input: FInput;

  DeviceIDs: TStringList;
  SelectedDeviceID: String;
  ProfileFileName: String;

  InputTimerID: UINT_PTR;
  NextDeviceCheck: Int64;
  CaptureAction: Integer;
  EventCount: Integer;

  InputAvailable: Boolean;
  Closing: Boolean;

  ActionNextDown: Boolean;
  ActionBackDown: Boolean;
  ActionCancelDown: Boolean;

  BindingTextNext: String;
  BindingTextBack: String;
  BindingTextCancel: String;

  DefaultXboxBindingsApplied: Boolean;

// ---------------------------------------------------------------------------
// WinAPI timer. The callback runs on the Setup UI thread. This is required
// because TInputManager verifies the thread that created the manager.
// ---------------------------------------------------------------------------
function SetTimer(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT;
  lpTimerFunc: NativeInt): UINT_PTR;
  external 'SetTimer@user32.dll stdcall';

function KillTimer(hWnd: HWND; uIDEvent: UINT_PTR): BOOL;
  external 'KillTimer@user32.dll stdcall';

function GetTickCount64External: Int64;
  external 'GetTickCount64@kernel32.dll stdcall';

// ---------------------------------------------------------------------------
// Enum names. Values are the ordinal values of the shared types declared in
// FMXPixieHandle.iss and the corresponding FMXInput enums.
// ---------------------------------------------------------------------------
function InputDeviceKindName(Kind: Integer): String;
begin
  if Kind = Ord(Keyboard) then
    Result := 'Keyboard'
  else if Kind = Ord(Controller) then
    Result := 'Controller'
  else if Kind = Ord(Mouse) then
    Result := 'Mouse'
  else
    Result := 'Unknown';
end;

function InputElementKindName(Kind: Integer): String;
begin
  if Kind = Ord(Key) then
    Result := 'Key'
  else if Kind = Ord(Button) then
    Result := 'Button'
  else if Kind = Ord(Axis) then
    Result := 'Axis'
  else if Kind = Ord(Hat) then
    Result := 'Hat / D-Pad'
  else if Kind = Ord(RelativeAxis) then
    Result := 'Relative axis'
  else
    Result := 'Unknown';
end;

function InputActionName(Action: Integer): String;
begin
  if Action = ACTION_NEXT then
    Result := 'Next'
  else if Action = ACTION_BACK then
    Result := 'Back'
  else if Action = ACTION_CANCEL then
    Result := 'Cancel'
  else
    Result := 'Unknown';
end;

// ---------------------------------------------------------------------------
// HTML
// ---------------------------------------------------------------------------
function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#111827;color:#e5e7eb;font:12px "Segoe UI",Arial,sans-serif;}' +
    '.bar{position:relative;height:31px;line-height:31px;border-bottom:1px solid #263247;}' +
    '.caption{margin-left:12px;color:#93c5fd;font-weight:700;letter-spacing:.4px;}' +
    '.note{margin-left:9px;color:#77869b;font-size:10px;}' +
    '.controls{position:absolute;right:0;top:0;width:92px;height:31px;font-size:0;}' +
    '.win{display:inline-block;width:46px;height:31px;line-height:30px;text-align:center;' +
    'color:#cbd5e1;font-size:20px;cursor:pointer;}' +
    '.win:hover{background:#29374c;color:#fff;}' +
    '.close:hover{background:#c42b1c;color:#fff;}' +
    '</style></head><body><div class="bar">' +
    '<span class="caption">FMXPIXIE / INPUT DEMO</span>' +
    '<span class="note">Keyboard / Mouse / Controller</span>' +
    '<div class="controls">' +
    '<div id="title-minimize" class="win">−</div>' +
    '<div id="title-close" class="win close">×</div>' +
    '</div></div></body></html>';
end;

function BuildInputHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#0b1220;color:#e5e7eb;font:12px "Segoe UI",Arial,sans-serif;}' +
    '.app{width:100%;height:100%;padding:15px 17px 12px 17px;}' +
    '.header{height:38px;display:flex;align-items:center;justify-content:space-between;}' +
    '.brand{font-size:17px;font-weight:700;color:#f1f5f9;letter-spacing:.2px;}' +
    '.sub{font-size:10px;color:#8492a8;margin-top:3px;}' +
    '.status{height:30px;line-height:29px;padding:0 10px;margin:8px 0 12px 0;' +
    'background:#111d30;border:1px solid #25364f;border-radius:5px;color:#a9bdd7;}' +
    '.status-dot{display:inline-block;width:7px;height:7px;border-radius:50%;' +
    'background:#64748b;margin-right:8px;}' +
    '.status-dot.on{background:#34d399;}' +
    '.workspace{display:flex;width:100%;height:calc(100% - 111px);}' +
    '.panel{min-width:0;background:#101a2a;border:1px solid #26364d;border-radius:7px;' +
    'padding:12px;margin-right:10px;overflow:hidden;}' +
    '.panel:last-child{margin-right:0;}' +
    '.devices{width:29%;}' +
    '.elements{width:35%;}' +
    '.actions{flex:1;}' +
    '.panel-head{height:26px;display:flex;align-items:center;justify-content:space-between;' +
    'color:#dce7f5;font-size:12px;font-weight:700;}' +
    '.panel-caption{font-size:10px;color:#7f90a8;font-weight:400;}' +
    '.panel-hint{font-size:9px;line-height:13px;color:#8292a8;margin:4px 0 7px 0;}' +
    '.device-list{height:calc(100% - 134px);overflow-y:auto;margin-top:4px;}' +
    '.device-row{display:block;width:100%;height:32px;margin:0 0 5px 0;padding:0 8px;' +
    'text-align:left;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;' +
    'background:#162338;border:1px solid #293b55;border-radius:4px;color:#aebed2;' +
    'font:10px "Segoe UI",Arial,sans-serif;cursor:pointer;}' +
    '.device-row:hover{background:#1b2d47;border-color:#5274a4;color:#fff;}' +
    '.device-row.is-selected{background:#1b3553;border-color:#4e83bd;color:#e6f2ff;}' +
    '.device-row.is-unavailable{color:#78869a;border-color:#303947;}' +
    '.selected-info{margin-top:8px;padding-top:8px;border-top:1px solid #26364d;}' +
    '.selected-name{font-size:11px;font-weight:700;color:#dbeafe;}' +
    '.selected-id{margin-top:3px;font-size:9px;color:#6f829c;white-space:nowrap;' +
    'overflow:hidden;text-overflow:ellipsis;}' +
    '.device-note{margin-top:5px;font-size:9px;color:#8190a5;}' +
    '.element-summary{font-size:10px;color:#8292a8;margin:5px 0 8px 0;}' +
    '.element-list{height:calc(100% - 62px);overflow-y:auto;}' +
    '.element-row{height:26px;line-height:25px;padding:0 7px;margin-bottom:3px;' +
    'background:#142136;border:1px solid #24364e;border-radius:3px;' +
    'font-size:10px;color:#b7c7dc;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}' +
    '.element-row:nth-child(even){background:#111e31;}' +
    '.empty{color:#687b95;font-style:italic;}' +
    '.action-help{font-size:9px;line-height:13px;color:#8292a8;margin:6px 0 8px 0;}' +
    '.game-action-list{margin-top:8px;}' +
    '.game-action{display:flex;align-items:center;justify-content:space-between;width:100%;' +
    'min-height:48px;padding:6px 10px;margin:0 0 7px 0;text-align:left;' +
    'background:#162338;border:1px solid #2d405b;border-radius:5px;color:#e5edf8;' +
    'font:12px "Segoe UI",Arial,sans-serif;cursor:pointer;}' +
    '.game-action:hover{background:#1c2f49;border-color:#5274a4;}' +
    '.game-action.is-down{background:#173d36;border-color:#38b78a;color:#d9fff0;}' +
    '.game-action-copy{display:flex;flex-direction:column;gap:3px;}' +
    '.game-action-label{font-size:13px;font-weight:600;}' +
    '.game-action-binding{font-size:9px;color:#8093ad;}' +
    '.game-action-right{display:flex;align-items:center;gap:9px;}' +
    '.xbox-key{display:inline-block;width:27px;height:27px;line-height:27px;' +
    'border-radius:50%;text-align:center;color:#fff;font-size:12px;font-weight:700;' +
    'border:1px solid rgba(255,255,255,.24);box-shadow:inset 0 -2px 0 rgba(0,0,0,.24);}' +
    '.xbox-a{background:#168a43;}' +
    '.xbox-b{background:#c73535;}' +
    '.xbox-x{background:#286bc3;}' +
    '.action-card{padding:8px 9px;margin-top:6px;background:#142136;border:1px solid #2a3c56;border-radius:5px;}' +
    '.action-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:4px;}' +
    '.action-name{font-size:11px;font-weight:700;color:#dbeafe;}' +
    '.action-state{padding:2px 7px;border-radius:3px;background:#263449;color:#91a2b9;' +
    'font-size:9px;font-weight:700;letter-spacing:.4px;}' +
    '.action-state.is-down{background:#14553f;color:#9af0c8;}' +
    '.binding{font-size:9px;color:#91a3ba;min-height:14px;margin-bottom:7px;}' +
    'button{font:10px "Segoe UI",Arial,sans-serif;cursor:pointer;}' +
    '.btn{height:26px;padding:0 9px;margin:0 4px 4px 0;border:1px solid #3a5272;' +
    'border-radius:4px;background:#20344f;color:#dceaff;}' +
    '.btn:hover{background:#2a486c;border-color:#6593c7;color:#fff;}' +
    '.btn.primary{background:#1d4d78;border-color:#3976ad;}' +
    '.btn.danger{background:#472b35;border-color:#74404b;color:#ffd8df;}' +
    '.btn.small{height:23px;padding:0 7px;font-size:9px;}' +
    '.toolbar{margin-top:10px;padding-top:8px;border-top:1px solid #293a51;}' +
    '.toolbar-title{font-size:9px;color:#7e91aa;text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px;}' +
    '.capture-status{min-height:34px;margin-top:7px;padding:6px 7px;background:#111e30;' +
    'border:1px solid #26364d;border-radius:4px;font-size:9px;color:#9fb2cb;}' +
    '.footer{height:21px;line-height:20px;margin-top:8px;padding:0 3px;color:#71839b;font-size:9px;}' +
    '.footer-event{display:inline-block;max-width:80%;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}' +
    '.footer-count{float:right;color:#8ba2bf;}' +
    '.is-hidden{display:none;}' +
    '</style></head><body><div class="app">' +

    '<div class="header"><div><div class="brand">Input device monitor</div>' +
    '<div class="sub">1. Select a device  &gt;  2. Assign an action  &gt;  3. Press it to test</div></div>' +
    '<div><button id="refresh-devices" class="btn small">Refresh devices</button></div></div>' +

    '<div class="status"><span id="status-dot" class="status-dot"></span>' +
    '<span id="input-status">Initializing FMXInput...</span>' +
    '<span style="float:right" id="input-state">INPUT: --</span></div>' +

    '<div class="workspace">' +

    '<div class="panel devices">' +
    '<div class="panel-head"><span>1. CHOOSE A DEVICE</span><span id="device-count" class="panel-caption">0 found</span></div>' +
    '<div class="panel-hint">Select a keyboard, mouse, or controller.</div>' +
    '<div id="device-list" class="device-list"></div>' +
    '<div class="selected-info">' +
    '<div id="selected-device-name" class="selected-name">No device selected</div>' +
    '<div id="selected-device-id" class="selected-id"></div>' +
    '<div id="selected-device-note" class="device-note">Choose a device from the list above.</div></div>' +
    '</div>' +

    '<div class="panel elements">' +
    '<div class="panel-head"><span>DEVICE CONTROLS</span><span id="element-total" class="panel-caption">0 controls</span></div>' +
    '<div id="element-summary" class="element-summary">Reference list: keys, buttons, axes and other controls found on the selected device.</div>' +
    '<div id="element-list" class="element-list"></div>' +
    '</div>' +

    '<div class="panel actions">' +
    '<div class="panel-head"><span>GAME UI PREVIEW</span><span class="panel-caption">Xbox layout</span></div>' +
    '<div class="action-help">Готовые игровые подсказки. Нажми кнопку на контроллере — соответствующая строка подсветится.</div>' +
    '<div class="game-action-list">' +
    '<button id="game-next" class="game-action" type="button">' +
    '<span class="game-action-copy"><span class="game-action-label">Далее</span><span id="binding-next" class="game-action-binding">Не назначено</span></span>' +
    '<span class="game-action-right"><span id="state-next" class="action-state">RELEASED</span><span class="xbox-key xbox-a">A</span></span></button>' +
    '<button id="game-back" class="game-action" type="button">' +
    '<span class="game-action-copy"><span class="game-action-label">Назад</span><span id="binding-back" class="game-action-binding">Не назначено</span></span>' +
    '<span class="game-action-right"><span id="state-back" class="action-state">RELEASED</span><span class="xbox-key xbox-b">B</span></span></button>' +
    '<button id="game-cancel" class="game-action" type="button">' +
    '<span class="game-action-copy"><span class="game-action-label">Отмена</span><span id="binding-cancel" class="game-action-binding">Не назначено</span></span>' +
    '<span class="game-action-right"><span id="state-cancel" class="action-state">RELEASED</span><span class="xbox-key xbox-x">X</span></span></button>' +
    '</div>' +
    '<div id="gamepad-map-info" class="capture-status">Ожидание Xbox-контроллера. Для теста используются A — Далее, B — Назад, X — Отмена.</div>' +
    '<div class="toolbar"><div class="toolbar-title">ДОБАВИТЬ ДРУГОЙ ВВОД</div>' +
    '<button id="capture-next" class="btn primary small">Добавить ввод: Далее</button>' +
    '<button id="capture-back" class="btn primary small">Добавить ввод: Назад</button>' +
    '<button id="capture-cancel" class="btn primary small">Добавить ввод: Отмена</button>' +
    '</div>' +
    '<div id="capture-status" class="capture-status">Можно добавить клавиатуру или мышь к уже назначенным кнопкам контроллера.</div>' +

    '<div class="toolbar"><div class="toolbar-title">EXTRA OPTIONS</div>' +
    '<button id="toggle-input" class="btn small">Pause input</button>' +
    '<button id="cancel-capture" class="btn small">Stop assignment</button>' +
    '<button id="clear-bindings" class="btn danger small">Clear assignments</button>' +
    '</div>' +

    '<div class="toolbar"><div class="toolbar-title">TEMP PROFILE / CONTROLLER</div>' +
    '<button id="save-profile" class="btn small">Save profile</button>' +
    '<button id="load-profile" class="btn small">Load profile</button>' +
    '<button id="rumble" class="btn small is-hidden">Test vibration</button>' +
    '</div>' +
    '</div>' +

    '</div>' +
    '<div class="footer"><span id="last-event" class="footer-event">No input events yet.</span>' +
    '<span id="event-count" class="footer-count">0 events</span></div>' +
    '</div></body></html>';
end;

// ---------------------------------------------------------------------------
// DOM helpers
// ---------------------------------------------------------------------------
function HtmlEscapeText(const S: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    case S[I] of
      '&': Result := Result + '&amp;';
      '<': Result := Result + '&lt;';
      '>': Result := Result + '&gt;';
    else
      Result := Result + S[I];
    end;
end;

procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, S);
end;

procedure SetClassById(const Id, ClassName: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then
    Exit;
  Elem.FCreate(H);
  Elem.SetAttr('class', ClassName);
end;

procedure SetInputStatus(const S: String);
begin
  SetTextById('input-status', S);
  if not InputAvailable then
  begin
    SetTextById('input-state', 'INPUT: OFFLINE');
    SetClassById('status-dot', 'status-dot');
  end
  else if Input = nil then
  begin
    SetTextById('input-state', 'INPUT: OFFLINE');
    SetClassById('status-dot', 'status-dot');
  end
  else if Input.IsEnabled then
  begin
    SetTextById('input-state', 'INPUT: ON');
    SetClassById('status-dot', 'status-dot on');
  end
  else
  begin
    SetTextById('input-state', 'INPUT: PAUSED');
    SetClassById('status-dot', 'status-dot');
  end;
end;

procedure AddEventLog(const S: String);
begin
  Inc(EventCount);
  SetTextById('last-event',
    GetDateTimeString('hh:nn:ss', #0, ':') + '  ' + S);
  SetTextById('event-count', IntToStr(EventCount) + ' events');
end;

procedure SetBindingText(Action: Integer; const S: String);
begin
  if Action = ACTION_NEXT then
  begin
    BindingTextNext := S;
    SetTextById('binding-next', S);
  end
  else if Action = ACTION_BACK then
  begin
    BindingTextBack := S;
    SetTextById('binding-back', S);
  end
  else if Action = ACTION_CANCEL then
  begin
    BindingTextCancel := S;
    SetTextById('binding-cancel', S);
  end;
end;

procedure SetActionStateVisual(Action: Integer; Down: Boolean);
var
  Id, ButtonId, TextValue: String;
begin
  if Action = ACTION_NEXT then
  begin
    Id := 'state-next';
    ButtonId := 'game-next';
  end
  else if Action = ACTION_BACK then
  begin
    Id := 'state-back';
    ButtonId := 'game-back';
  end
  else
  begin
    Id := 'state-cancel';
    ButtonId := 'game-cancel';
  end;

  if Down then
  begin
    SetClassById(Id, 'action-state is-down');
    SetClassById(ButtonId, 'game-action is-down');
    TextValue := 'PRESSED';
  end
  else
  begin
    SetClassById(Id, 'action-state');
    SetClassById(ButtonId, 'game-action');
    TextValue := 'RELEASED';
  end;
  SetTextById(Id, TextValue);
end;

// ---------------------------------------------------------------------------
// Device enumeration and element list
// ---------------------------------------------------------------------------
function FindSelectedDeviceIndex: Integer;
begin
  Result := -1;
  if (Input = nil) or (SelectedDeviceID = '') then
    Exit;
  Result := DeviceIDs.IndexOf(SelectedDeviceID);
end;

function DeviceListChanged: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Input = nil then
    Exit;

  if DeviceIDs.Count <> Input.DeviceCount then
  begin
    Result := True;
    Exit;
  end;

  for I := 0 to DeviceIDs.Count - 1 do
    if DeviceIDs[I] <> Input.DeviceID(I) then
    begin
      Result := True;
      Exit;
    end;
end;

procedure UpdateSelectedDevice;
var
  DeviceIndex: Integer;
  I: Integer;
  Count: Integer;
  Kind: Integer;
  Code: Integer;
  Line: String;
  DeviceNote: String;
  ElementsHtml: String;
  ElementListHandle: NativeInt;
begin
  DeviceIndex := FindSelectedDeviceIndex;
  ElementListHandle := Doc.GetElementById('element-list');

  Doc.BeginUpdate;
  try
    if DeviceIndex < 0 then
    begin
      if ElementListHandle <> 0 then
        Doc.SetInnerHtml(ElementListHandle, '');
      SetTextById('selected-device-name', 'No device selected');
      SetTextById('selected-device-id', '');
      SetTextById('selected-device-note', 'Choose a device from the list above.');
      SetTextById('element-total', '0 controls');
      SetTextById('element-summary', 'Select a device in Step 1 to inspect its controls.');
      SetClassById('rumble', 'btn small is-hidden');
    end
    else
    begin
      SetTextById('selected-device-name', Input.DeviceName(DeviceIndex));
      SetTextById('selected-device-id', SelectedDeviceID);

      if Input.DeviceAvailable(DeviceIndex) then
        DeviceNote := InputDeviceKindName(Input.DeviceKind(DeviceIndex)) + ' / available'
      else
        DeviceNote := InputDeviceKindName(Input.DeviceKind(DeviceIndex)) +
          ' / unavailable: ' + Input.DeviceError(DeviceIndex);
      SetTextById('selected-device-note', DeviceNote);

      if Input.DeviceRumbleSupported(DeviceIndex) then
        SetClassById('rumble', 'btn small')
      else
        SetClassById('rumble', 'btn small is-hidden');

      Count := Input.ElementCount(DeviceIndex);
      SetTextById('element-total', IntToStr(Count) + ' controls');
      SetTextById('element-summary',
        'Reference list of keys, buttons, axes and other controls found on this device.');

      ElementsHtml := '';
      for I := 0 to Count - 1 do
      begin
        Kind := Input.ElementKind(DeviceIndex, I);
        Code := Input.ElementCode(DeviceIndex, I);
        Line := InputElementKindName(Kind) + '  |  ' +
          Input.ElementName(DeviceIndex, I) + '  |  code ' + IntToStr(Code);
        ElementsHtml := ElementsHtml +
          '<div id="element-' + IntToStr(I) + '" class="element-row">' +
          HtmlEscapeText(Line) + '</div>';
      end;

      if ElementListHandle <> 0 then
        Doc.SetInnerHtml(ElementListHandle, ElementsHtml);
    end;
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure ApplyDefaultXboxBindings;
var
  I: Integer;
  DeviceID: String;
  DeviceName: String;
  ErrorText: String;
begin
  if (Input = nil) or not InputAvailable or DefaultXboxBindingsApplied then
    Exit;

  for I := 0 to Input.DeviceCount - 1 do
  begin
    if (Input.DeviceKind(I) <> Ord(Controller)) or
       not Input.DeviceAvailable(I) then
      Continue;

    DeviceID := Input.DeviceID(I);
    if Copy(DeviceID, 1, Length(XINPUT_DEVICE_ID_PREFIX)) <>
       XINPUT_DEVICE_ID_PREFIX then
      Continue;

    DeviceName := Input.DeviceName(I);

    if not Input.Bind(ACTION_NEXT, DeviceID, Ord(Button),
      XINPUT_BUTTON_A_CODE, 0) then
      ErrorText := Input.LastError
    else if not Input.Bind(ACTION_BACK, DeviceID, Ord(Button),
      XINPUT_BUTTON_B_CODE, 0) then
    begin
      ErrorText := Input.LastError;
      Input.RemoveBindings(ACTION_NEXT);
    end
    else if not Input.Bind(ACTION_CANCEL, DeviceID, Ord(Button),
      XINPUT_BUTTON_X_CODE, 0) then
    begin
      ErrorText := Input.LastError;
      Input.RemoveBindings(ACTION_NEXT);
      Input.RemoveBindings(ACTION_BACK);
    end;

    if ErrorText <> '' then
    begin
      SetTextById('gamepad-map-info',
        'Не удалось назначить кнопки Xbox: ' + ErrorText);
      SetInputStatus('Default Xbox assignment failed: ' + ErrorText);
      Exit;
    end;

    DefaultXboxBindingsApplied := True;
    SetBindingText(ACTION_NEXT, DeviceName + ' / A');
    SetBindingText(ACTION_BACK, DeviceName + ' / B');
    SetBindingText(ACTION_CANCEL, DeviceName + ' / X');
    SetTextById('gamepad-map-info',
      'Назначено автоматически: A — Далее, B — Назад, X — Отмена. Нажми кнопки на контроллере для проверки.');
    SetInputStatus('Xbox controller found. Default A / B / X controls are ready.');
    AddEventLog('Default Xbox A / B / X controls assigned.');
    Exit;
  end;

  SetTextById('gamepad-map-info',
    'Xbox-контроллер не обнаружен. Подключи XInput-контроллер или добавь свой ввод вручную.');
end;

procedure PopulateDevices;
var
  I: Integer;
  Count: Integer;
  SelectedIndex: Integer;
  PreviousID: String;
  NameText: String;
  RowClass: String;
  DevicesHtml: String;
  DeviceListHandle: NativeInt;
begin
  if Input = nil then
    Exit;

  PreviousID := SelectedDeviceID;
  DeviceIDs.Clear;
  Count := Input.DeviceCount;

  for I := 0 to Count - 1 do
    DeviceIDs.Add(Input.DeviceID(I));

  SelectedIndex := DeviceIDs.IndexOf(PreviousID);
  if SelectedIndex < 0 then
  begin
    SelectedIndex := -1;

    // Prefer a native XInput controller for this Xbox-oriented demo.
    for I := 0 to DeviceIDs.Count - 1 do
      if Input.DeviceAvailable(I) and
        (Copy(DeviceIDs[I], 1, Length(XINPUT_DEVICE_ID_PREFIX)) =
          XINPUT_DEVICE_ID_PREFIX) then
      begin
        SelectedIndex := I;
        Break;
      end;

    // Fall back to the first available keyboard, mouse or controller.
    if SelectedIndex < 0 then
      for I := 0 to DeviceIDs.Count - 1 do
        if Input.DeviceAvailable(I) then
        begin
          SelectedIndex := I;
          Break;
        end;

    if (SelectedIndex < 0) and (DeviceIDs.Count > 0) then
      SelectedIndex := 0;
  end;

  if SelectedIndex >= 0 then
    SelectedDeviceID := DeviceIDs[SelectedIndex]
  else
    SelectedDeviceID := '';

  DeviceListHandle := Doc.GetElementById('device-list');
  DevicesHtml := '';

  Doc.BeginUpdate;
  try
    SetTextById('device-count', IntToStr(DeviceIDs.Count) + ' detected');

    for I := 0 to DeviceIDs.Count - 1 do
    begin
      NameText := InputDeviceKindName(Input.DeviceKind(I)) + '  |  ' +
        Input.DeviceName(I);
      if not Input.DeviceAvailable(I) then
        NameText := NameText + '  [unavailable]';

      RowClass := 'device-row';
      if not Input.DeviceAvailable(I) then
        RowClass := RowClass + ' is-unavailable';
      if DeviceIDs[I] = SelectedDeviceID then
        RowClass := RowClass + ' is-selected';

      DevicesHtml := DevicesHtml +
        '<button id="device-' + IntToStr(I) + '" class="' + RowClass +
        '" type="button">' + HtmlEscapeText(NameText) + '</button>';
    end;

    if DeviceIDs.Count = 0 then
      DevicesHtml := '<div class="empty">No devices found. Connect a keyboard, mouse, or controller, then click Refresh.</div>';

    if DeviceListHandle <> 0 then
      Doc.SetInnerHtml(DeviceListHandle, DevicesHtml);

    if DeviceIDs.Count = 0 then
      SetInputStatus('No input devices detected. Connect a keyboard, mouse or controller.')
    else
      SetInputStatus('Enumerated ' + IntToStr(DeviceIDs.Count) + ' input devices.');
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;

  UpdateSelectedDevice;
  ApplyDefaultXboxBindings;
end;

procedure CancelCurrentCapture;
begin
  if Input <> nil then
    if Input.Capturing then
    begin
      Input.CancelCapture;
      AddEventLog('Assignment cancelled.');
      SetTextById('capture-status', 'Назначение отменено. Уже назначенные кнопки контроллера сохранены.');
    end
    else
      SetTextById('capture-status', 'Сейчас ничего не назначается. Можно добавить клавиатуру или мышь к игровым действиям.');
  CaptureAction := 0;
  Doc.Changed;
end;

procedure SelectDevice(Index: Integer);
var
  I: Integer;
  H: NativeInt;
  RowClass: String;
begin
  if (Index < 0) or (Index >= DeviceIDs.Count) then
    Exit;

  if Input <> nil then
    if Input.Capturing then
      CancelCurrentCapture;

  SelectedDeviceID := DeviceIDs[Index];
  Doc.BeginUpdate;
  try
    for I := 0 to DeviceIDs.Count - 1 do
    begin
      H := Doc.GetElementById('device-' + IntToStr(I));
      if H <> 0 then
      begin
        RowClass := 'device-row';
        if not Input.DeviceAvailable(I) then
          RowClass := RowClass + ' is-unavailable';
        if I = Index then
          RowClass := RowClass + ' is-selected';
        Elem.FCreate(H);
        Elem.SetAttr('class', RowClass);
      end;
    end;
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
  UpdateSelectedDevice;
end;

procedure RefreshInputDevices;
begin
  if (Input = nil) or not InputAvailable then
    Exit;

  if Input.Refresh then
  begin
    PopulateDevices;
    NextDeviceCheck := GetTickCount64External +
      INPUT_DEVICE_CHECK_INTERVAL;
    AddEventLog('Device enumeration refreshed.');
  end
  else
    SetInputStatus('Refresh failed: ' + Input.LastError);
end;

// ---------------------------------------------------------------------------
// Capture and bindings
// ---------------------------------------------------------------------------
procedure StartCapture(Action: Integer);
var
  DeviceIndex: Integer;
begin
  if (Input = nil) or not InputAvailable then
    Exit;

  DeviceIndex := FindSelectedDeviceIndex;
  if DeviceIndex < 0 then
  begin
    SetInputStatus('Select a device in Step 1 first.');
    SetTextById('capture-status', 'Select a device in the left panel before assigning an action.');
    Doc.Changed;
    Exit;
  end;

  if not Input.IsEnabled then
  begin
    SetInputStatus('Input is paused. Resume input before assigning controls.');
    SetTextById('capture-status', 'Input is paused. Click Resume input under Extra Options, then try again.');
    Doc.Changed;
    Exit;
  end;

  if SelectedDeviceID = '' then
  begin
    SetInputStatus('Select an input device first.');
    Exit;
  end;

  if Input.Capturing then
    Input.CancelCapture;

  if Input.BeginCapture(Action, SelectedDeviceID, True) then
  begin
    CaptureAction := Action;
    SetTextById('capture-status',
      'Нажми клавишу, кнопку мыши или контроллера для действия ' +
      InputActionName(Action) + '.');
    SetInputStatus('Waiting for a control on ' + Input.DeviceName(DeviceIndex) + '.');
    AddEventLog('Started assigning ' + InputActionName(Action) + '.');
    Doc.Changed;
  end
  else
  begin
    SetInputStatus('Could not start assignment: ' + Input.LastError);
    SetTextById('capture-status', 'Assignment could not be started: ' + Input.LastError);
  end;
end;

procedure HandleCapturedInput;
var
  Action: Integer;
  Kind: Integer;
  Code: Integer;
  Direction: Integer;
  DeviceName: String;
  BindingText: String;
begin
  if Input = nil then
    Exit;
  if not Input.HasCaptured then
    Exit;

  Action := CaptureAction;
  Kind := Input.CapturedKind;
  Code := Input.CapturedCode;
  Direction := Input.CapturedDirection;
  DeviceName := Input.CapturedDeviceName;

  BindingText := DeviceName + ' / ' + InputElementKindName(Kind) +
    ' / code ' + IntToStr(Code);
  if (Kind = Ord(Axis)) or (Kind = Ord(RelativeAxis)) or
     (Kind = Ord(Hat)) then
    BindingText := BindingText + ' / direction ' + IntToStr(Direction);

  if Input.AcceptCaptured then
  begin
    SetBindingText(Action, BindingText);
    SetTextById('capture-status', InputActionName(Action) +
      ': дополнительный ввод назначен. Проверь его нажатием.');
    SetInputStatus(InputActionName(Action) + ' assigned successfully.');
    AddEventLog('Assigned ' + InputActionName(Action) + '.');
  end
  else
  begin
    SetTextById('capture-status', 'Assignment failed: ' + Input.LastError);
    SetInputStatus('Unable to assign this control: ' + Input.LastError);
  end;

  CaptureAction := 0;
  Doc.Changed;
end;

procedure ClearAllBindings;
begin
  if Input = nil then
    Exit;

  Input.CancelCapture;
  Input.ClearBindings;
  CaptureAction := 0;

  SetBindingText(ACTION_NEXT, 'Not assigned');
  SetBindingText(ACTION_BACK, 'Not assigned');
  SetBindingText(ACTION_CANCEL, 'Not assigned');

  ActionNextDown := False;
  ActionBackDown := False;
  ActionCancelDown := False;
  SetActionStateVisual(ACTION_NEXT, False);
  SetActionStateVisual(ACTION_BACK, False);
  SetActionStateVisual(ACTION_CANCEL, False);

  SetTextById('capture-status', 'Все назначения очищены. Стандартные кнопки A / B / X также удалены.');
  SetTextById('gamepad-map-info', 'Назначения очищены. Добавь ввод вручную или перезапусти демо для автоматической схемы Xbox.');
  SetInputStatus('All action assignments cleared.');
  AddEventLog('All assignments cleared.');
  Doc.Changed;
end;

// ---------------------------------------------------------------------------
// Input action state
// ---------------------------------------------------------------------------
procedure UpdateActionState;
var
  Down: Boolean;
  Changed: Boolean;
begin
  if (Input = nil) or not InputAvailable then
    Exit;

  Changed := False;
  Doc.BeginUpdate;
  try
    Down := Input.IsEnabled and Input.IsPressed(ACTION_NEXT);
    if Down <> ActionNextDown then
    begin
      ActionNextDown := Down;
      SetActionStateVisual(ACTION_NEXT, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_NEXT) then
    begin
      AddEventLog('NEXT action pressed.');
      SetInputStatus('NEXT action received from its assigned control.');
      Changed := True;
    end;

    Down := Input.IsEnabled and Input.IsPressed(ACTION_BACK);
    if Down <> ActionBackDown then
    begin
      ActionBackDown := Down;
      SetActionStateVisual(ACTION_BACK, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_BACK) then
    begin
      AddEventLog('BACK action pressed.');
      SetInputStatus('BACK action received from its assigned control.');
      Changed := True;
    end;

    Down := Input.IsEnabled and Input.IsPressed(ACTION_CANCEL);
    if Down <> ActionCancelDown then
    begin
      ActionCancelDown := Down;
      SetActionStateVisual(ACTION_CANCEL, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_CANCEL) then
    begin
      AddEventLog('CANCEL action pressed.');
      SetInputStatus('CANCEL action received from its assigned control.');
      Changed := True;
    end;
  finally
    Doc.EndUpdate;
  end;

  if Changed then
    Doc.Changed;
end;

// ---------------------------------------------------------------------------
// Profile and rumble
// ---------------------------------------------------------------------------
procedure SaveInputProfile;
begin
  if Input = nil then
    Exit;

  if Input.SaveProfile(ProfileFileName) then
  begin
    SetInputStatus('Profile saved to the Setup temporary directory.');
    AddEventLog('Input profile saved.');
  end
  else
    SetInputStatus('Profile save failed: ' + Input.LastError);
end;

procedure LoadInputProfile;
begin
  if Input = nil then
    Exit;

  if not FileExists(ProfileFileName) then
  begin
    SetInputStatus('No saved profile exists in this Setup session.');
    Exit;
  end;

  if Input.LoadProfile(ProfileFileName) then
  begin
    SetBindingText(ACTION_NEXT, 'Assigned (restored from profile)');
    SetBindingText(ACTION_BACK, 'Assigned (restored from profile)');
    SetBindingText(ACTION_CANCEL, 'Assigned (restored from profile)');
    SetInputStatus('Profile loaded. Saved assignments are active.');
    SetTextById('capture-status', 'Profile loaded. The saved assignments are active; press a bound control to test them.');
    UpdateActionState;
    AddEventLog('Input profile loaded.');
  end
  else
    SetInputStatus('Profile load failed: ' + Input.LastError);
  Doc.Changed;
end;

procedure TestRumble;
var
  DeviceIndex: Integer;
begin
  if Input = nil then
    Exit;

  DeviceIndex := FindSelectedDeviceIndex;
  if DeviceIndex < 0 then
  begin
    SetInputStatus('Select an input device first.');
    Exit;
  end;

  if not Input.DeviceRumbleSupported(DeviceIndex) then
  begin
    SetInputStatus('Rumble is not supported by the selected device.');
    Exit;
  end;

  if Input.SetRumble(SelectedDeviceID, 30000, 52000, 350) then
  begin
    SetInputStatus('Vibration test sent (350 ms).');
    AddEventLog('Vibration test sent to the selected controller.');
  end
  else
    SetInputStatus('Vibration test failed: ' + Input.LastError);
end;

// ---------------------------------------------------------------------------
// HTML click routing
// ---------------------------------------------------------------------------
function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
  Index: Integer;
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

  if Copy(Id, 1, 7) = 'device-' then
  begin
    Index := StrToInt(Copy(Id, 8, Length(Id) - 7));
    SelectDevice(Index);
    Result := True;
    Exit;
  end;

  if Id = 'title-minimize' then
  begin
    FMXForm.Minimize;
    Result := True;
    Exit;
  end;

  if Id = 'game-next' then
  begin
    AddEventLog('UI button clicked: Далее.');
    SetInputStatus('Кнопка интерфейса «Далее» нажата мышью.');
    Result := True;
    Exit;
  end
  else if Id = 'game-back' then
  begin
    AddEventLog('UI button clicked: Назад.');
    SetInputStatus('Кнопка интерфейса «Назад» нажата мышью.');
    Result := True;
    Exit;
  end
  else if Id = 'game-cancel' then
  begin
    AddEventLog('UI button clicked: Отмена.');
    SetInputStatus('Кнопка интерфейса «Отмена» нажата мышью.');
    Result := True;
    Exit;
  end;

  if Id = 'title-close' then
  begin
    WizardForm.Close;
    Result := True;
    Exit;
  end;

  if Id = 'refresh-devices' then
    RefreshInputDevices
  else if Id = 'capture-next' then
    StartCapture(ACTION_NEXT)
  else if Id = 'capture-back' then
    StartCapture(ACTION_BACK)
  else if Id = 'capture-cancel' then
    StartCapture(ACTION_CANCEL)
  else if Id = 'cancel-capture' then
    CancelCurrentCapture
  else if Id = 'clear-bindings' then
    ClearAllBindings
  else if Id = 'save-profile' then
    SaveInputProfile
  else if Id = 'load-profile' then
    LoadInputProfile
  else if Id = 'rumble' then
    TestRumble
  else if Id = 'toggle-input' then
  begin
    if Input <> nil then
    begin
      Input.Enabled(not Input.IsEnabled);
      if Input.IsEnabled then
      begin
        SetTextById('toggle-input', 'Pause input');
        SetInputStatus('Input resumed.');
        AddEventLog('Input resumed.');
      end
      else
      begin
        SetTextById('toggle-input', 'Resume input');
        CancelCurrentCapture;
        SetInputStatus('Input paused.');
        AddEventLog('Input paused.');
      end;
      UpdateActionState;
    end;
  end
  else
    Exit;

  Doc.Changed;
  Result := True;
end;

// ---------------------------------------------------------------------------
// Window dragging
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
// Input timer
// ---------------------------------------------------------------------------
procedure InputTimerProc(hWnd: HWND; uMsg: UINT; idEvent: UINT_PTR;
  dwTime: DWORD);
var
  ErrorText: String;
  Tick: Int64;
begin
  if Closing or (Input = nil) or not InputAvailable then
    Exit;

  try
    if not Input.Poll then
    begin
      InputAvailable := False;
      SetInputStatus('Input polling stopped: ' + Input.LastError);
      AddEventLog('POLL ERROR: ' + Input.LastError);
      Doc.Changed;
      KillTimer(0, InputTimerID);
      InputTimerID := 0;
      Exit;
    end;

    Tick := GetTickCount64External;
    if Tick >= NextDeviceCheck then
    begin
      if DeviceListChanged then
        PopulateDevices;
      NextDeviceCheck := Tick + INPUT_DEVICE_CHECK_INTERVAL;
    end;

    HandleCapturedInput;
    UpdateActionState;
  except
    ErrorText := GetExceptionMessage;
    InputAvailable := False;
    SetInputStatus('INPUT ERROR: ' + ErrorText);
    AddEventLog('Input timer stopped: ' + ErrorText);
    Doc.Changed;
    KillTimer(0, InputTimerID);
    InputTimerID := 0;
  end;
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
  Closing := False;
  InputAvailable := False;
  InputTimerID := 0;
  NextDeviceCheck := 0;
  CaptureAction := 0;
  EventCount := 0;
  DefaultXboxBindingsApplied := False;

  ActionNextDown := False;
  ActionBackDown := False;
  ActionCancelDown := False;

  BindingTextNext := 'Not assigned';
  BindingTextBack := 'Not assigned';
  BindingTextCancel := 'Not assigned';

  SelectedDeviceID := '';
  DeviceIDs := TStringList.Create;

  ProfileFileName := ExpandConstant('{tmp}') + '\FMXPixieInputProfile.json';

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('FMXPixie - Input Demo');
  FMXForm.ChangeBorderColor($FF2D5278);

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
  View.OnElementClick(@ElementClick);
  View.LoadFromString(BuildInputHtml);

  Doc.FCreate(View.GetDocument);

  // Input is created here, on the same thread that owns the Setup UI.
  try
    Input := InitInput;
    InputAvailable := Input <> nil;
  except
    SetInputStatus('FMXInput initialization failed: ' + GetExceptionMessage);
    AddEventLog('FMXInput initialization failed.');
  end;

  if InputAvailable then
  begin
    if Input.Refresh then
    begin
      PopulateDevices;
      SetInputStatus('FMXInput initialized and device enumeration completed.');
    end
    else
      SetInputStatus('Initial device refresh failed: ' + Input.LastError);

    NextDeviceCheck := GetTickCount64External +
      INPUT_DEVICE_CHECK_INTERVAL;

    InputTimerID := SetTimer(0, 0, INPUT_POLL_INTERVAL,
      CreateCallback(@InputTimerProc));
    if InputTimerID = 0 then
    begin
      InputAvailable := False;
      SetInputStatus('Unable to create the input polling timer.');
    end;
  end
  else
    SetInputStatus('FMXInput is unavailable. Check the DLL and initialization error.');

  FMXForm.Show;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := False;
end;

procedure DeinitializeSetup;
begin
  Closing := True;

  if InputTimerID <> 0 then
  begin
    KillTimer(0, InputTimerID);
    InputTimerID := 0;
  end;

  if Input <> nil then
  begin
    if Input.Capturing then
      Input.CancelCapture;
    Input.Shutdown;
    Input := nil;
  end;

  if DeviceIDs <> nil then
  begin
    DeviceIDs.Free;
    DeviceIDs := nil;
  end;

  FMXPixieShutDown;
end;
