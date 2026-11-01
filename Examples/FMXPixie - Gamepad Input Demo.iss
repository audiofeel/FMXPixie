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

  ACTION_XBOX_NEXT = 111;
  ACTION_XBOX_BACK = 112;
  ACTION_XBOX_CANCEL = 113;

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
  InputTimerID: UINT_PTR;
  NextDeviceCheck: Int64;
  CaptureAction: Integer;

  InputAvailable: Boolean;
  Closing: Boolean;

  ActionNextDown: Boolean;
  ActionBackDown: Boolean;
  ActionCancelDown: Boolean;

  XboxNextDown: Boolean;
  XboxBackDown: Boolean;
  XboxCancelDown: Boolean;

  CustomNextAssigned: Boolean;
  CustomBackAssigned: Boolean;
  CustomCancelAssigned: Boolean;

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
  if (Action = ACTION_NEXT) or (Action = ACTION_XBOX_NEXT) then
    Result := 'Далее'
  else if (Action = ACTION_BACK) or (Action = ACTION_XBOX_BACK) then
    Result := 'Назад'
  else if (Action = ACTION_CANCEL) or (Action = ACTION_XBOX_CANCEL) then
    Result := 'Отмена'
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
    'body{background:#0b1220;color:#e5e7eb;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.app{width:100%;height:100%;padding:20px 22px 15px 22px;}' +
    '.header{height:55px;display:flex;align-items:center;justify-content:space-between;}' +
    '.brand{font-size:20px;font-weight:700;color:#f1f5f9;letter-spacing:.2px;}' +
    '.sub{font-size:11px;color:#8796aa;margin-top:4px;}' +
    '.status{height:32px;line-height:30px;padding:0 11px;margin:9px 0 16px 0;' +
    'background:#111d30;border:1px solid #25364f;border-radius:6px;color:#a9bdd7;font-size:11px;}' +
    '.status-dot{display:inline-block;width:7px;height:7px;border-radius:50%;' +
    'background:#64748b;margin-right:8px;}' +
    '.status-dot.on{background:#34d399;}' +
    '.workspace{display:flex;width:100%;height:calc(100% - 112px);}' +
    '.panel{flex:1;min-width:0;background:#101a2a;border:1px solid #26364d;' +
    'border-radius:9px;padding:17px;overflow:hidden;}' +
    '.custom-panel{margin-left:14px;}' +
    '.panel-head{display:flex;align-items:center;justify-content:space-between;' +
    'font-size:14px;font-weight:700;color:#e5edf8;padding-bottom:11px;' +
    'border-bottom:1px solid #26364d;}' +
    '.panel-caption{font-size:9px;font-weight:600;color:#8292a8;letter-spacing:.8px;}' +
    '.panel-note{font-size:10px;line-height:15px;color:#8999ae;margin:12px 0 15px 0;}' +
    '.xbox-row{display:flex;align-items:center;justify-content:space-between;' +
    'min-height:70px;padding:10px 12px;margin:0 0 9px 0;' +
    'background:#162338;border:1px solid #2b3e58;border-radius:7px;}' +
    '.xbox-row.is-down{background:#173d36;border-color:#38b78a;}' +
    '.xbox-copy{display:flex;flex-direction:column;}' +
    '.xbox-hint{margin-top:4px;}' +
    '.xbox-title{font-size:15px;font-weight:600;color:#f1f5f9;}' +
    '.xbox-hint{font-size:10px;color:#8292a8;}' +
    '.xbox-right{display:flex;align-items:center;}' +
    '.xbox-state{font-size:9px;color:#71839b;letter-spacing:.5px;font-weight:700;margin-right:12px;}' +
    '.xbox-state.is-down{color:#9af0c8;}' +
    '.xbox-key{display:flex;align-items:center;justify-content:center;' +
    'width:38px;height:38px;border-radius:50%;color:#fff;font-size:16px;font-weight:800;' +
    'border:1px solid rgba(255,255,255,.28);' +
    'box-shadow:inset 0 -3px 0 rgba(0,0,0,.22),0 2px 5px rgba(0,0,0,.25);}' +
    '.xbox-a{background:#168a43;}' +
    '.xbox-b{background:#c73535;}' +
    '.xbox-x{background:#286bc3;}' +
    '.xbox-status{margin-top:13px;padding:10px 11px;border-radius:6px;' +
    'background:#111e30;border:1px solid #26364d;color:#91a6c1;font-size:10px;line-height:15px;}' +
    '.custom-row{display:flex;align-items:center;justify-content:space-between;' +
    'min-height:66px;padding:9px 10px;margin:0 0 9px 0;' +
    'background:#162338;border:1px solid #2b3e58;border-radius:7px;}' +
    '.custom-copy{display:flex;flex-direction:column;min-width:0;}' +
    '.custom-title{font-size:13px;font-weight:600;color:#e5edf8;}' +
    '.custom-binding{font-size:10px;color:#8292a8;white-space:nowrap;margin-top:5px;' +
    'overflow:hidden;text-overflow:ellipsis;max-width:265px;}' +
    '.custom-right{display:flex;align-items:center;flex-shrink:0;}' +
    '.custom-state{font-size:9px;color:#71839b;font-weight:700;letter-spacing:.4px;margin-right:10px;}' +
    '.custom-state.is-down{color:#9af0c8;}' +
    '.custom-row.is-down{background:#173d36;border-color:#38b78a;}' +
    'button{font:11px "Segoe UI",Arial,sans-serif;cursor:pointer;}' +
    '.assign-btn{flex-shrink:0;min-width:94px;height:31px;padding:0 11px;' +
    'border:1px solid #3b6da0;border-radius:5px;background:#1d4d78;color:#e4f1ff;}' +
    '.assign-btn:hover{background:#28618f;border-color:#6aa2d8;color:#fff;}' +
    '.capture-status{min-height:42px;margin-top:13px;padding:9px 10px;' +
    'background:#111e30;border:1px solid #26364d;border-radius:6px;' +
    'font-size:10px;line-height:15px;color:#9fb2cb;}' +
    '.is-hidden{display:none;}' +
    '</style></head><body><div class="app">' +

    '<div class="header"><div>' +
    '<div class="brand">GAME MENU</div>' +
    '<div class="sub">Пример управления игровым меню с помощью контроллера, клавиатуры или мыши</div>' +
    '</div></div>' +

    '<div class="status"><span id="status-dot" class="status-dot"></span>' +
    '<span id="input-status">Подключите Xbox-контроллер или назначьте свои кнопки справа.</span>' +
    '<span style="float:right" id="input-state">ВВОД: --</span></div>' +

    '<div class="workspace">' +

    '<div class="panel">' +
    '<div class="panel-head"><span>XBOX — ГОТОВАЯ РАСКЛАДКА</span><span class="panel-caption">XINPUT</span></div>' +
    '<div class="panel-note">Готовая схема Xbox. При подключении XInput-контроллера A / B / X назначатся автоматически.</div>' +

    '<div id="xbox-row-next" class="xbox-row">' +
    '<div class="xbox-copy"><span class="xbox-title">Далее</span><span class="xbox-hint">Продолжить / подтвердить</span></div>' +
    '<div class="xbox-right"><span id="xbox-state-next" class="xbox-state">NO PAD</span><span class="xbox-key xbox-a">A</span></div></div>' +

    '<div id="xbox-row-back" class="xbox-row">' +
    '<div class="xbox-copy"><span class="xbox-title">Назад</span><span class="xbox-hint">Вернуться к предыдущему шагу</span></div>' +
    '<div class="xbox-right"><span id="xbox-state-back" class="xbox-state">NO PAD</span><span class="xbox-key xbox-b">B</span></div></div>' +

    '<div id="xbox-row-cancel" class="xbox-row">' +
    '<div class="xbox-copy"><span class="xbox-title">Отмена</span><span class="xbox-hint">Закрыть / отменить действие</span></div>' +
    '<div class="xbox-right"><span id="xbox-state-cancel" class="xbox-state">NO PAD</span><span class="xbox-key xbox-x">X</span></div></div>' +

    '<div id="xbox-status" class="xbox-status">Ожидание Xbox-контроллера. Раскладка: A — Далее, B — Назад, X — Отмена.</div>' +
    '</div>' +

    '<div class="panel custom-panel">' +
    '<div class="panel-head"><span>СВОИ НАЗНАЧЕНИЯ</span><span class="panel-caption">ЛЮБОЙ ВВОД</span></div>' +
    '<div class="panel-note">Здесь можно добавить свои клавиши или кнопки. Нажми «Назначить», затем нажми нужную кнопку на клавиатуре, мыши или контроллере.</div>' +

    '<div id="custom-row-next" class="custom-row"><div class="custom-copy"><span class="custom-title">Далее</span>' +
    '<span id="custom-binding-next" class="custom-binding">Не назначено</span></div>' +
    '<div class="custom-right"><span id="custom-state-next" class="custom-state">—</span>' +
    '<button id="custom-assign-next" class="assign-btn" type="button">Назначить</button></div></div>' +

    '<div id="custom-row-back" class="custom-row"><div class="custom-copy"><span class="custom-title">Назад</span>' +
    '<span id="custom-binding-back" class="custom-binding">Не назначено</span></div>' +
    '<div class="custom-right"><span id="custom-state-back" class="custom-state">—</span>' +
    '<button id="custom-assign-back" class="assign-btn" type="button">Назначить</button></div></div>' +

    '<div id="custom-row-cancel" class="custom-row"><div class="custom-copy"><span class="custom-title">Отмена</span>' +
    '<span id="custom-binding-cancel" class="custom-binding">Не назначено</span></div>' +
    '<div class="custom-right"><span id="custom-state-cancel" class="custom-state">—</span>' +
    '<button id="custom-assign-cancel" class="assign-btn" type="button">Назначить</button></div></div>' +

    '<div id="capture-status" class="capture-status">Отдельная раскладка для клавиатуры, мыши или другого контроллера. Она проверяется независимо от кнопок Xbox.</div>' +
    '</div>' +

    '</div></div></body></html>';
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
    SetTextById('input-state', 'ВВОД: НЕТ');
    SetClassById('status-dot', 'status-dot');
  end
  else if Input = nil then
  begin
    SetTextById('input-state', 'ВВОД: НЕТ');
    SetClassById('status-dot', 'status-dot');
  end
  else if Input.IsEnabled then
  begin
    SetTextById('input-state', 'ВВОД: ВКЛ');
    SetClassById('status-dot', 'status-dot on');
  end
  else
  begin
    SetTextById('input-state', 'ВВОД: ПАУЗА');
    SetClassById('status-dot', 'status-dot');
  end;
end;

procedure SetBindingText(Action: Integer; const S: String);
begin
  if Action = ACTION_NEXT then
  begin
    CustomNextAssigned := True;
    SetTextById('custom-binding-next', S);
    SetClassById('custom-state-next', 'custom-state');
    SetTextById('custom-state-next', 'RELEASED');
  end
  else if Action = ACTION_BACK then
  begin
    CustomBackAssigned := True;
    SetTextById('custom-binding-back', S);
    SetClassById('custom-state-back', 'custom-state');
    SetTextById('custom-state-back', 'RELEASED');
  end
  else if Action = ACTION_CANCEL then
  begin
    CustomCancelAssigned := True;
    SetTextById('custom-binding-cancel', S);
    SetClassById('custom-state-cancel', 'custom-state');
    SetTextById('custom-state-cancel', 'RELEASED');
  end;
end;

procedure SetActionStateVisual(Action: Integer; Down: Boolean);
var
  Id, RowId, TextValue: String;
begin
  if Action = ACTION_XBOX_NEXT then
  begin
    Id := 'xbox-state-next';
    RowId := 'xbox-row-next';
  end
  else if Action = ACTION_XBOX_BACK then
  begin
    Id := 'xbox-state-back';
    RowId := 'xbox-row-back';
  end
  else
  begin
    Id := 'xbox-state-cancel';
    RowId := 'xbox-row-cancel';
  end;

  if Down then
  begin
    SetClassById(Id, 'xbox-state is-down');
    SetClassById(RowId, 'xbox-row is-down');
    TextValue := 'PRESSED';
  end
  else
  begin
    SetClassById(Id, 'xbox-state');
    SetClassById(RowId, 'xbox-row');
    TextValue := 'RELEASED';
  end;
  SetTextById(Id, TextValue);
end;

procedure SetCustomActionStateVisual(Action: Integer; Down: Boolean);
var
  Id, RowId, TextValue: String;
begin
  if Action = ACTION_NEXT then
  begin
    Id := 'custom-state-next';
    RowId := 'custom-row-next';
  end
  else if Action = ACTION_BACK then
  begin
    Id := 'custom-state-back';
    RowId := 'custom-row-back';
  end
  else
  begin
    Id := 'custom-state-cancel';
    RowId := 'custom-row-cancel';
  end;

  if Down then
  begin
    SetClassById(Id, 'custom-state is-down');
    SetClassById(RowId, 'custom-row is-down');
    TextValue := 'PRESSED';
  end
  else
  begin
    SetClassById(Id, 'custom-state');
    SetClassById(RowId, 'custom-row');
    TextValue := 'RELEASED';
  end;
  SetTextById(Id, TextValue);
end;

// ---------------------------------------------------------------------------
// Device enumeration and element list
// ---------------------------------------------------------------------------
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

procedure ApplyDefaultXboxBindings;
var
  I: Integer;
  DeviceID: String;
  DeviceName: String;
  ErrorText: String;
begin
  ErrorText := '';
  if (Input = nil) or not InputAvailable or DefaultXboxBindingsApplied then
    Exit;

  for I := 0 to Input.DeviceCount - 1 do
  begin
    if (Input.DeviceKind(I) = Ord(Controller)) and
       Input.DeviceAvailable(I) then
    begin
      DeviceID := Input.DeviceID(I);
      if Copy(DeviceID, 1, Length(XINPUT_DEVICE_ID_PREFIX)) =
         XINPUT_DEVICE_ID_PREFIX then
      begin
        DeviceName := Input.DeviceName(I);

        if not Input.Bind(ACTION_XBOX_NEXT, DeviceID, Ord(Button),
          XINPUT_BUTTON_A_CODE, 0) then
          ErrorText := Input.LastError
        else if not Input.Bind(ACTION_XBOX_BACK, DeviceID, Ord(Button),
          XINPUT_BUTTON_B_CODE, 0) then
        begin
          ErrorText := Input.LastError;
          Input.RemoveBindings(ACTION_XBOX_NEXT);
        end
        else if not Input.Bind(ACTION_XBOX_CANCEL, DeviceID, Ord(Button),
          XINPUT_BUTTON_X_CODE, 0) then
        begin
          ErrorText := Input.LastError;
          Input.RemoveBindings(ACTION_XBOX_NEXT);
          Input.RemoveBindings(ACTION_XBOX_BACK);
        end;

        if ErrorText <> '' then
        begin
          SetTextById('xbox-status',
            'Не удалось назначить стандартные кнопки Xbox: ' + ErrorText);
          SetInputStatus('Не удалось назначить Xbox A / B / X: ' + ErrorText);
          Exit;
        end;

        DefaultXboxBindingsApplied := True;
        SetActionStateVisual(ACTION_XBOX_NEXT, False);
        SetActionStateVisual(ACTION_XBOX_BACK, False);
        SetActionStateVisual(ACTION_XBOX_CANCEL, False);
        SetTextById('xbox-status',
          DeviceName + ': A — Далее, B — Назад, X — Отмена. Готово к работе.');
        SetInputStatus('Xbox-контроллер подключён. A / B / X готовы.');
        Exit;
      end;
    end;
  end;

  SetTextById('xbox-status',
    'Xbox-контроллер не найден. Значки A / B / X показаны как пример стандартной раскладки.');
end;

procedure PopulateDevices;
var
  I: Integer;
begin
  if Input = nil then
    Exit;

  DeviceIDs.Clear;
  for I := 0 to Input.DeviceCount - 1 do
    DeviceIDs.Add(Input.DeviceID(I));

  // Device enumeration is kept internal. The demo UI does not need a technical list.
  ApplyDefaultXboxBindings;
end;

// ---------------------------------------------------------------------------
// Capture and bindings
// ---------------------------------------------------------------------------
procedure StartCapture(Action: Integer);
begin
  if (Input = nil) or not InputAvailable then
    Exit;

  if not Input.IsEnabled then
  begin
    SetInputStatus('Ввод приостановлен. Возобновите его перед назначением кнопок.');
    SetTextById('capture-status', 'Сейчас ввод приостановлен.');
    Doc.Changed;
    Exit;
  end;

  CaptureAction := 0;
  if Input.Capturing then
    Input.CancelCapture;

  // Empty DeviceID captures from any enumerated keyboard, mouse or controller.
  if Input.BeginCapture(Action, '', False) then
  begin
    CaptureAction := Action;
    SetTextById('capture-status',
      'Нажми нужную клавишу или кнопку. Ожидается назначение для действия ' +
      InputActionName(Action) + '.');
    SetInputStatus('Ожидание кнопки для действия ' + InputActionName(Action) + '.');
    Doc.Changed;
  end
  else
  begin
    SetTextById('capture-status', 'Не удалось начать назначение: ' + Input.LastError);
    SetInputStatus('Не удалось начать назначение: ' + Input.LastError);
  end;
end;

function CapturedInputText: String;
var
  I: Integer;
  J: Integer;
  Kind: Integer;
  Code: Integer;
  DeviceID: String;
  DeviceName: String;
  ElementName: String;
begin
  Result := '';
  if Input = nil then
    Exit;

  DeviceID := Input.CapturedDeviceID;
  DeviceName := Input.CapturedDeviceName;
  Kind := Input.CapturedKind;
  Code := Input.CapturedCode;
  ElementName := '';

  if Copy(DeviceID, 1, Length(XINPUT_DEVICE_ID_PREFIX)) =
     XINPUT_DEVICE_ID_PREFIX then
  begin
    if Kind = Ord(Button) then
      case Code of
        0: ElementName := 'D-pad Up';
        1: ElementName := 'D-pad Down';
        2: ElementName := 'D-pad Left';
        3: ElementName := 'D-pad Right';
        4: ElementName := 'START';
        5: ElementName := 'BACK';
        6: ElementName := 'Left Stick';
        7: ElementName := 'Right Stick';
        8: ElementName := 'LB';
        9: ElementName := 'RB';
        12: ElementName := 'A';
        13: ElementName := 'B';
        14: ElementName := 'X';
        15: ElementName := 'Y';
      end
    else if Kind = Ord(Axis) then
      case Code of
        0: ElementName := 'Left Stick X';
        1: ElementName := 'Left Stick Y';
        2: ElementName := 'Right Stick X';
        3: ElementName := 'Right Stick Y';
        4: ElementName := 'Left Trigger';
        5: ElementName := 'Right Trigger';
      end;
  end
  else
  begin
    for I := 0 to Input.DeviceCount - 1 do
      if Input.DeviceID(I) = DeviceID then
      begin
        for J := 0 to Input.ElementCount(I) - 1 do
          if (Input.ElementKind(I, J) = Kind) and
             (Input.ElementCode(I, J) = Code) then
          begin
            ElementName := Input.ElementName(I, J);
            Break;
          end;
        Break;
      end;
  end;

  if DeviceName = 'Keyboard' then
    DeviceName := 'Клавиатура'
  else if DeviceName = 'Mouse' then
  begin
    DeviceName := 'Мышь';
    if Kind = Ord(Button) then
      case Code of
        0: ElementName := 'Левая кнопка';
        1: ElementName := 'Правая кнопка';
        2: ElementName := 'Средняя кнопка';
        3: ElementName := 'Назад';
        4: ElementName := 'Вперёд';
      end
    else if Kind = Ord(RelativeAxis) then
      case Code of
        2: ElementName := 'Колесо';
        3: ElementName := 'Горизонтальное колесо';
      end;
  end
  else if DeviceName = '' then
    DeviceName := 'Устройство';

  if ElementName = '' then
    ElementName := InputElementKindName(Kind) + ' ' + IntToStr(Code);

  Result := DeviceName + ' / ' + ElementName;
end;

procedure HandleCapturedInput;
var
  Action: Integer;
  Kind: Integer;
  Direction: Integer;
  BindingText: String;
begin
  if Input = nil then
    Exit;
  if not Input.HasCaptured then
    Exit;

  Action := CaptureAction;
  Kind := Input.CapturedKind;
  Direction := Input.CapturedDirection;

  BindingText := CapturedInputText;
  if (Kind = Ord(Axis)) or (Kind = Ord(RelativeAxis)) or
     (Kind = Ord(Hat)) then
  begin
    if Direction < 0 then
      BindingText := BindingText + ' (−)'
    else
      BindingText := BindingText + ' (+)';
  end;

  if Input.AcceptCaptured then
  begin
    SetBindingText(Action, BindingText);
    SetTextById('capture-status', 'Готово: ' + InputActionName(Action) +
      ' — ' + BindingText + '. Нажми назначенную кнопку, чтобы проверить.');
    SetInputStatus('Назначено действие «' + InputActionName(Action) + '».');
  end
  else
  begin
    SetTextById('capture-status', 'Не удалось назначить кнопку: ' + Input.LastError);
    SetInputStatus('Не удалось назначить ввод: ' + Input.LastError);
  end;

  CaptureAction := 0;
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
    Down := Input.IsEnabled and Input.IsPressed(ACTION_XBOX_NEXT);
    if Down <> XboxNextDown then
    begin
      XboxNextDown := Down;
      SetActionStateVisual(ACTION_XBOX_NEXT, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_XBOX_NEXT) then
    begin
      SetInputStatus('Xbox A — Далее');
      Changed := True;
    end;

    Down := Input.IsEnabled and Input.IsPressed(ACTION_XBOX_BACK);
    if Down <> XboxBackDown then
    begin
      XboxBackDown := Down;
      SetActionStateVisual(ACTION_XBOX_BACK, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_XBOX_BACK) then
    begin
      SetInputStatus('Xbox B — Назад');
      Changed := True;
    end;

    Down := Input.IsEnabled and Input.IsPressed(ACTION_XBOX_CANCEL);
    if Down <> XboxCancelDown then
    begin
      XboxCancelDown := Down;
      SetActionStateVisual(ACTION_XBOX_CANCEL, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_XBOX_CANCEL) then
    begin
      SetInputStatus('Xbox X — Отмена');
      Changed := True;
    end;

    Down := Input.IsEnabled and Input.IsPressed(ACTION_NEXT);
    if Down <> ActionNextDown then
    begin
      ActionNextDown := Down;
      if CustomNextAssigned then
        SetCustomActionStateVisual(ACTION_NEXT, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_NEXT) then
    begin
      SetInputStatus('Своё назначение — Далее');
      Changed := True;
    end;

    Down := Input.IsEnabled and Input.IsPressed(ACTION_BACK);
    if Down <> ActionBackDown then
    begin
      ActionBackDown := Down;
      if CustomBackAssigned then
        SetCustomActionStateVisual(ACTION_BACK, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_BACK) then
    begin
      SetInputStatus('Своё назначение — Назад');
      Changed := True;
    end;

    Down := Input.IsEnabled and Input.IsPressed(ACTION_CANCEL);
    if Down <> ActionCancelDown then
    begin
      ActionCancelDown := Down;
      if CustomCancelAssigned then
        SetCustomActionStateVisual(ACTION_CANCEL, Down);
      Changed := True;
    end;
    if Input.WasPressed(ACTION_CANCEL) then
    begin
      SetInputStatus('Своё назначение — Отмена');
      Changed := True;
    end;
  finally
    Doc.EndUpdate;
  end;

  if Changed then
    Doc.Changed;
end;

// ---------------------------------------------------------------------------
// HTML click routing
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
    WizardForm.Close;
    Result := True;
    Exit;
  end;

  if Id = 'custom-assign-next' then
    StartCapture(ACTION_NEXT)
  else if Id = 'custom-assign-back' then
    StartCapture(ACTION_BACK)
  else if Id = 'custom-assign-cancel' then
    StartCapture(ACTION_CANCEL)
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
      SetInputStatus('Опрос устройств остановлен: ' + Input.LastError);
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
    SetInputStatus('Ошибка ввода: ' + ErrorText);
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
  DefaultXboxBindingsApplied := False;

  ActionNextDown := False;
  ActionBackDown := False;
  ActionCancelDown := False;

  XboxNextDown := False;
  XboxBackDown := False;
  XboxCancelDown := False;

  CustomNextAssigned := False;
  CustomBackAssigned := False;
  CustomCancelAssigned := False;

  DeviceIDs := TStringList.Create;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('FMXPixie - Game Menu Input Demo');
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
    SetInputStatus('Ошибка инициализации ввода: ' + GetExceptionMessage);
  end;

  if InputAvailable then
  begin
    if Input.Refresh then
    begin
      PopulateDevices;
      if DefaultXboxBindingsApplied then
        SetInputStatus('Xbox-контроллер подключен. Стандартные кнопки готовы.')
      else
        SetInputStatus('Ввод готов. Подключите Xbox или назначьте свои кнопки справа.');
    end
    else
      SetInputStatus('Не удалось обновить устройства: ' + Input.LastError);

    NextDeviceCheck := GetTickCount64External +
      INPUT_DEVICE_CHECK_INTERVAL;

    InputTimerID := SetTimer(0, 0, INPUT_POLL_INTERVAL,
      CreateCallback(@InputTimerProc));
    if InputTimerID = 0 then
    begin
      InputAvailable := False;
      SetInputStatus('Не удалось запустить таймер опроса устройств.');
    end;
  end
  else
    SetInputStatus('Служба ввода недоступна. Проверь DLL и причину ошибки инициализации.');

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
