; ============================================================================
; FMXPixie - Gamepad Input Demo
;
; Exercises the FMXInput wrapper from Inno Setup:
;   - enumerates keyboard, mouse and game controllers;
;   - lists the elements exposed by the selected device;
;   - captures a physical control and binds it to an installer action;
;   - drives the real Inno Setup Next / Back / Cancel buttons;
;   - optionally tests XInput vibration.
;
; Required files:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;
; The demo does not install an application.
; ============================================================================

#define DemoAppName "FMXPixie - Gamepad Input Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
AppCopyright=audiofeel
CreateAppDir=no
Uninstallable=no
DisableProgramGroupPage=yes
OutputBaseFilename=FMXPixie - Gamepad Input Demo
; SetupArchitecture=x64
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
  ACTION_NEXT = 101;
  ACTION_BACK = 102;
  ACTION_CANCEL = 103;

  INPUT_POLL_INTERVAL = 16;


var
  Input: FInput;
  InputPage: TWizardPage;
  DeviceCombo: TNewComboBox;
  ActionCombo: TNewComboBox;
  RefreshButton: TNewButton;
  CaptureButton: TNewButton;
  ClearButton: TNewButton;
  RumbleButton: TNewButton;
  ElementsMemo: TNewMemo;
  EventsMemo: TNewMemo;
  DeviceStatusLabel: TNewStaticText;
  CaptureStatusLabel: TNewStaticText;
  ActionStateLabel: TNewStaticText;

  DeviceIDs: TStringList;
  InputTimerID: UINT_PTR;
  Closing: Boolean;
  InputAvailable: Boolean;

// ---------------------------------------------------------------------------
// WinAPI timer. SetTimer callback runs on the Setup UI thread; this is
// important because TInputManager enforces creation-thread polling.
// ---------------------------------------------------------------------------
function SetTimer(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT;
  lpTimerFunc: NativeInt): UINT_PTR;
  external 'SetTimer@user32.dll stdcall';

function KillTimer(hWnd: HWND; uIDEvent: UINT_PTR): BOOL;
  external 'KillTimer@user32.dll stdcall';

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

function InputActionName(Action: Integer): String;
begin
  case Action of
    ACTION_NEXT: Result := 'Next / Install / Finish';
    ACTION_BACK: Result := 'Back';
    ACTION_CANCEL: Result := 'Cancel';
  else
    Result := 'Unknown action';
  end;
end;

function InputActionFromIndex(Index: Integer): Integer;
begin
  case Index of
    0: Result := ACTION_NEXT;
    1: Result := ACTION_BACK;
    2: Result := ACTION_CANCEL;
  else
    Result := -1;
  end;
end;

function DirectionName(Kind, Direction: Integer): String;
begin
  Result := '';
  if Kind = Ord(Axis) then
  begin
    if Direction < 0 then
      Result := ' (negative direction)'
    else
      Result := ' (positive direction)';
  end
  else if Kind = Ord(RelativeAxis) then
  begin
    if Direction < 0 then
      Result := ' (negative direction)'
    else
      Result := ' (positive direction)';
  end
  else if Kind = Ord(Hat) then
  begin
    case Direction of
      0: Result := ' (Up)';
      1: Result := ' (Up-right)';
      2: Result := ' (Right)';
      3: Result := ' (Down-right)';
      4: Result := ' (Down)';
      5: Result := ' (Down-left)';
      6: Result := ' (Left)';
      7: Result := ' (Up-left)';
    end;
  end;
end;

procedure AddEventLog(const Text: String);
begin
  if EventsMemo = nil then
    Exit;

  EventsMemo.Lines.Add(GetDateTimeString('hh:nn:ss', #0, ':') + '  ' + Text);
  while EventsMemo.Lines.Count > 100 do
    EventsMemo.Lines.Delete(0);
  EventsMemo.SelStart := Length(EventsMemo.Text);
  EventsMemo.SelLength := 0;
end;

function GetSelectedDeviceID: String;
begin
  Result := '';
  if (DeviceCombo <> nil) and (DeviceCombo.ItemIndex >= 0) and
     (DeviceCombo.ItemIndex < DeviceIDs.Count) then
    Result := DeviceIDs[DeviceCombo.ItemIndex];
end;

procedure UpdateElements;
var
  DeviceIndex: Integer;
  I: Integer;
  Kind: Integer;
  Code: Integer;
  Line: String;
begin
  if (Input = nil) or (ElementsMemo = nil) then
    Exit;

  DeviceIndex := DeviceCombo.ItemIndex;
  ElementsMemo.Lines.BeginUpdate;
  try
    ElementsMemo.Clear;

    if (DeviceIndex < 0) or (DeviceIndex >= DeviceIDs.Count) then
    begin
      ElementsMemo.Lines.Add('No input device selected.');
      DeviceStatusLabel.Caption := 'Select an available input device.';
      RumbleButton.Enabled := False;
      CaptureButton.Enabled := False;
      Exit;
    end;

    DeviceStatusLabel.Caption :=
      Input.DeviceName(DeviceIndex) + '  [' + GetSelectedDeviceID + ']';

    if not Input.DeviceAvailable(DeviceIndex) then
    begin
      DeviceStatusLabel.Caption := DeviceStatusLabel.Caption +
        '  |  unavailable: ' + Input.DeviceError(DeviceIndex);
      RumbleButton.Enabled := False;
      CaptureButton.Enabled := Input.Capturing;
    end
    else
    begin
      RumbleButton.Enabled := Input.DeviceRumbleSupported(DeviceIndex);
      CaptureButton.Enabled := Input.Capturing or Input.IsEnabled;
    end;

    for I := 0 to Input.ElementCount(DeviceIndex) - 1 do
    begin
      Kind := Input.ElementKind(DeviceIndex, I);
      Code := Input.ElementCode(DeviceIndex, I);
      Line := InputElementKindName(Kind) + '  ' +
        Input.ElementName(DeviceIndex, I) + '  [code ' + IntToStr(Code) + ']';
      ElementsMemo.Lines.Add(Line);
    end;

    if ElementsMemo.Lines.Count = 0 then
      ElementsMemo.Lines.Add('This device exposes no controls.');
  finally
    ElementsMemo.Lines.EndUpdate;
  end;
end;

procedure PopulateDevices;
var
  I: Integer;
  Kind: Integer;
  SelectedIndex: Integer;
  FirstAvailable: Integer;
  NameText: String;
  CaptionText: String;
  ID: String;
begin
  if (Input = nil) or (DeviceCombo = nil) then
    Exit;

  DeviceIDs.Clear;
  DeviceCombo.Items.Clear;
  SelectedIndex := -1;
  FirstAvailable := -1;

  for I := 0 to Input.DeviceCount - 1 do
  begin
    ID := Input.DeviceID(I);
    NameText := Input.DeviceName(I);
    Kind := Input.DeviceKind(I);
    CaptionText := InputDeviceKindName(Kind) + '  |  ' + NameText;

    if not Input.DeviceAvailable(I) then
      CaptionText := CaptionText + '  |  unavailable';

    DeviceIDs.Add(ID);
    DeviceCombo.Items.Add(CaptionText);

    if Input.DeviceAvailable(I) and (FirstAvailable < 0) then
      FirstAvailable := I;

    if Input.DeviceAvailable(I) and
       (Kind = Ord(Controller)) and (SelectedIndex < 0) then
      SelectedIndex := I;
  end;

  if SelectedIndex < 0 then
    SelectedIndex := FirstAvailable;

  DeviceCombo.ItemIndex := SelectedIndex;
  UpdateElements;

  if DeviceIDs.Count = 0 then
  begin
    DeviceStatusLabel.Caption := 'No input devices were enumerated.';
    ElementsMemo.Lines.Text := 'Connect a controller and click Refresh.';
    CaptureButton.Enabled := False;
    RumbleButton.Enabled := False;
  end
  else
    CaptureButton.Enabled := Input.IsEnabled;
end;

function DeviceListChanged: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Input = nil then
    Exit;

  if DeviceIDs.Count <> Input.DeviceCount then
    Exit(True);

  for I := 0 to DeviceIDs.Count - 1 do
    if DeviceIDs[I] <> Input.DeviceID(I) then
      Exit(True);
end;

procedure RefreshButtonClick(Sender: TObject);
begin
  if Input = nil then
    Exit;

  if Input.Refresh then
  begin
    PopulateDevices;
    AddEventLog('Device enumeration refreshed.');
  end
  else
    AddEventLog('Refresh failed: ' + Input.LastError);
end;

procedure DeviceComboChange(Sender: TObject);
begin
  UpdateElements;
end;

procedure CaptureButtonClick(Sender: TObject);
var
  Action: Integer;
  DeviceID: String;
begin
  if (Input = nil) or not InputAvailable then
    Exit;

  if ActionCombo.ItemIndex < 0 then
  begin
    CaptureStatusLabel.Caption := 'Select an installer action first.';
    Exit;
  end;

  DeviceID := GetSelectedDeviceID;
  if DeviceID = '' then
  begin
    CaptureStatusLabel.Caption := 'Select an input device first.';
    Exit;
  end;

  if Input.Capturing then
  begin
    Input.CancelCapture;
    ActionCombo.Enabled := True;
    CaptureButton.Caption := 'Capture';
    CaptureButton.Enabled := (DeviceCombo.ItemIndex >= 0) and
      Input.DeviceAvailable(DeviceCombo.ItemIndex);
    CaptureStatusLabel.Caption := 'Capture cancelled.';
    AddEventLog('Capture cancelled.');
    Exit;
  end;

  if not Input.DeviceAvailable(DeviceCombo.ItemIndex) then
  begin
    CaptureStatusLabel.Caption := 'The selected device is unavailable.';
    Exit;
  end;

  Action := InputActionFromIndex(ActionCombo.ItemIndex);

  if Input.BeginCapture(Action, DeviceID, False) then
  begin
    ActionCombo.Enabled := False;
    CaptureStatusLabel.Caption := 'Press a button, move an axis or press the D-Pad...';
    AddEventLog('Capture started for "' + InputActionName(Action) +
      '" on ' + Input.DeviceName(DeviceCombo.ItemIndex) + '.');
    CaptureButton.Caption := 'Cancel capture';
    CaptureButton.Enabled := True;
  end
  else
    CaptureStatusLabel.Caption := 'Capture failed: ' + Input.LastError;
end;

procedure ClearButtonClick(Sender: TObject);
begin
  if Input = nil then
    Exit;

  Input.CancelCapture;
  Input.ClearBindings;
  ActionCombo.Enabled := True;
  CaptureButton.Caption := 'Capture';
  CaptureButton.Enabled := InputAvailable and
    ((Input.Capturing) or ((DeviceCombo.ItemIndex >= 0) and
    Input.DeviceAvailable(DeviceCombo.ItemIndex)));
  CaptureStatusLabel.Caption := 'All bindings cleared.';
  ActionStateLabel.Caption := 'NEXT: up   BACK: up   CANCEL: up';
  AddEventLog('All action bindings cleared.');
end;

procedure RumbleButtonClick(Sender: TObject);
var
  DeviceID: String;
begin
  if (Input = nil) or (DeviceCombo.ItemIndex < 0) then
    Exit;

  DeviceID := GetSelectedDeviceID;
  if Input.SetRumble(DeviceID, 30000, 52000, 350) then
    AddEventLog('XInput vibration pulse sent to ' + Input.DeviceName(DeviceCombo.ItemIndex) + '.')
  else
    AddEventLog('Vibration unavailable: ' + Input.LastError);
end;

procedure HandleCapturedInput;
var
  Action: Integer;
  DeviceName: String;
  Kind: Integer;
  Code: Integer;
  Direction: Integer;
  BindingText: String;
begin
  if not Input.HasCaptured then
    Exit;

  Action := InputActionFromIndex(ActionCombo.ItemIndex);
  DeviceName := Input.CapturedDeviceName;
  Kind := Input.CapturedKind;
  Code := Input.CapturedCode;
  Direction := Input.CapturedDirection;

  BindingText := DeviceName + ': ' + InputElementKindName(Kind) +
    ' code ' + IntToStr(Code) + DirectionName(Kind, Direction);

  if Input.AcceptCaptured then
  begin
    CaptureStatusLabel.Caption := InputActionName(Action) + ' assigned to ' + BindingText;
    AddEventLog('BOUND  ' + InputActionName(Action) + '  <-  ' + BindingText);
  end
  else
    CaptureStatusLabel.Caption := 'Binding failed: ' + Input.LastError;

  ActionCombo.Enabled := True;
  CaptureButton.Caption := 'Capture';
  CaptureButton.Enabled := InputAvailable and (DeviceCombo.ItemIndex >= 0) and
    Input.DeviceAvailable(DeviceCombo.ItemIndex);
end;

procedure UpdateActionState;
var
  NextText: String;
  BackText: String;
  CancelText: String;
begin
  NextText := 'up';
  BackText := 'up';
  CancelText := 'up';

  if Input.IsPressed(ACTION_NEXT) then
    NextText := 'DOWN';
  if Input.IsPressed(ACTION_BACK) then
    BackText := 'DOWN';
  if Input.IsPressed(ACTION_CANCEL) then
    CancelText := 'DOWN';

  ActionStateLabel.Caption :=
    'NEXT: ' + NextText + '    BACK: ' + BackText +
    '    CANCEL: ' + CancelText;
end;

procedure InputTimerProc(hWnd: HWND; uMsg: UINT; idEvent: UINT_PTR;
  dwTime: DWORD);
begin
  if Closing or (Input = nil) or not InputAvailable then
    Exit;

  try
    if not Input.Poll then
    begin
      CaptureStatusLabel.Caption := 'Input polling stopped: ' + Input.LastError;
      AddEventLog('POLL ERROR: ' + Input.LastError);
      KillTimer(0, InputTimerID);
      InputTimerID := 0;
      Exit;
    end;

    if DeviceListChanged then
      PopulateDevices;

    HandleCapturedInput;
    UpdateActionState;

    // WasPressed consumes a rising-edge event. Holding a button therefore
    // cannot repeatedly click the same installer control.
    if Input.WasPressed(ACTION_CANCEL) then
    begin
      AddEventLog('Controller action: Cancel.');
      if WizardForm.CancelButton.Enabled then
        WizardForm.CancelButton.Click;
      Exit;
    end;

    if Input.WasPressed(ACTION_BACK) then
    begin
      AddEventLog('Controller action: Back.');
      if WizardForm.BackButton.Enabled then
        WizardForm.BackButton.Click;
      Exit;
    end;

    if Input.WasPressed(ACTION_NEXT) then
    begin
      AddEventLog('Controller action: Next / Install / Finish.');
      if WizardForm.NextButton.Enabled then
        WizardForm.NextButton.Click;
      Exit;
    end;
  except
    on E: Exception do
    begin
      CaptureStatusLabel.Caption := E.ClassName + ': ' + E.Message;
      AddEventLog('INPUT ERROR: ' + E.ClassName + ': ' + E.Message);
      KillTimer(0, InputTimerID);
      InputTimerID := 0;
    end;
  end;
end;

procedure CreateInputPage;
var
  LabelControl: TNewStaticText;
  PageWidth: Integer;
  MemoTop: Integer;
begin
  InputPage := CreateCustomPage(wpWelcome,
    'Controller and keyboard input',
    'Capture physical controls and use them to operate the real Setup wizard.');

  PageWidth := InputPage.SurfaceWidth;

  LabelControl := TNewStaticText.Create(InputPage);
  LabelControl.Parent := InputPage.Surface;
  LabelControl.Left := 0;
  LabelControl.Top := 0;
  LabelControl.Caption := 'Input device:';
  LabelControl.AutoSize := True;

  DeviceCombo := TNewComboBox.Create(InputPage);
  DeviceCombo.Parent := InputPage.Surface;
  DeviceCombo.Left := 0;
  DeviceCombo.Top := ScaleY(20);
  DeviceCombo.Width := PageWidth - ScaleX(104);
  DeviceCombo.Style := csDropDownList;
  DeviceCombo.OnChange := @DeviceComboChange;

  RefreshButton := TNewButton.Create(InputPage);
  RefreshButton.Parent := InputPage.Surface;
  RefreshButton.Left := DeviceCombo.Left + DeviceCombo.Width + ScaleX(6);
  RefreshButton.Top := DeviceCombo.Top;
  RefreshButton.Width := ScaleX(98);
  RefreshButton.Height := DeviceCombo.Height;
  RefreshButton.Caption := 'Refresh';
  RefreshButton.OnClick := @RefreshButtonClick;

  LabelControl := TNewStaticText.Create(InputPage);
  LabelControl.Parent := InputPage.Surface;
  LabelControl.Left := 0;
  LabelControl.Top := ScaleY(53);
  LabelControl.Caption := 'Controls exposed by the selected device:';
  LabelControl.AutoSize := True;

  ElementsMemo := TNewMemo.Create(InputPage);
  ElementsMemo.Parent := InputPage.Surface;
  ElementsMemo.Left := 0;
  ElementsMemo.Top := ScaleY(72);
  ElementsMemo.Width := PageWidth;
  ElementsMemo.Height := ScaleY(82);
  ElementsMemo.Anchors := [akLeft, akTop, akRight];
  ElementsMemo.ReadOnly := True;
  ElementsMemo.ScrollBars := ssVertical;
  ElementsMemo.WordWrap := False;

  LabelControl := TNewStaticText.Create(InputPage);
  LabelControl.Parent := InputPage.Surface;
  LabelControl.Left := 0;
  LabelControl.Top := ScaleY(163);
  LabelControl.Caption := 'Assign a control to an installer action:';
  LabelControl.AutoSize := True;

  ActionCombo := TNewComboBox.Create(InputPage);
  ActionCombo.Parent := InputPage.Surface;
  ActionCombo.Left := 0;
  ActionCombo.Top := ScaleY(183);
  ActionCombo.Width := ScaleX(190);
  ActionCombo.Style := csDropDownList;
  ActionCombo.Items.Add('Next / Install / Finish');
  ActionCombo.Items.Add('Back');
  ActionCombo.Items.Add('Cancel');
  ActionCombo.ItemIndex := 0;

  CaptureButton := TNewButton.Create(InputPage);
  CaptureButton.Parent := InputPage.Surface;
  CaptureButton.Left := ActionCombo.Left + ActionCombo.Width + ScaleX(6);
  CaptureButton.Top := ActionCombo.Top;
  CaptureButton.Width := ScaleX(112);
  CaptureButton.Height := ActionCombo.Height;
  CaptureButton.Caption := 'Capture';
  CaptureButton.OnClick := @CaptureButtonClick;

  ClearButton := TNewButton.Create(InputPage);
  ClearButton.Parent := InputPage.Surface;
  ClearButton.Left := CaptureButton.Left + CaptureButton.Width + ScaleX(6);
  ClearButton.Top := ActionCombo.Top;
  ClearButton.Width := ScaleX(82);
  ClearButton.Height := ActionCombo.Height;
  ClearButton.Caption := 'Clear';
  ClearButton.OnClick := @ClearButtonClick;

  RumbleButton := TNewButton.Create(InputPage);
  RumbleButton.Parent := InputPage.Surface;
  RumbleButton.Left := 0;
  RumbleButton.Top := ScaleY(216);
  RumbleButton.Width := ScaleX(130);
  RumbleButton.Height := ScaleY(24);
  RumbleButton.Caption := 'Test vibration';
  RumbleButton.Enabled := False;
  RumbleButton.OnClick := @RumbleButtonClick;

  DeviceStatusLabel := TNewStaticText.Create(InputPage);
  DeviceStatusLabel.Parent := InputPage.Surface;
  DeviceStatusLabel.Left := RumbleButton.Left + RumbleButton.Width + ScaleX(8);
  DeviceStatusLabel.Top := ScaleY(219);
  DeviceStatusLabel.Width := PageWidth - DeviceStatusLabel.Left;
  DeviceStatusLabel.Height := ScaleY(20);
  DeviceStatusLabel.AutoSize := False;
  DeviceStatusLabel.Caption := 'No device selected.';

  CaptureStatusLabel := TNewStaticText.Create(InputPage);
  CaptureStatusLabel.Parent := InputPage.Surface;
  CaptureStatusLabel.Left := 0;
  CaptureStatusLabel.Top := ScaleY(247);
  CaptureStatusLabel.Width := PageWidth;
  CaptureStatusLabel.Height := ScaleY(22);
  CaptureStatusLabel.AutoSize := False;
  CaptureStatusLabel.Caption := 'Choose a device and action, then click Capture.';

  ActionStateLabel := TNewStaticText.Create(InputPage);
  ActionStateLabel.Parent := InputPage.Surface;
  ActionStateLabel.Left := 0;
  ActionStateLabel.Top := ScaleY(271);
  ActionStateLabel.Width := PageWidth;
  ActionStateLabel.Height := ScaleY(20);
  ActionStateLabel.AutoSize := False;
  ActionStateLabel.Caption := 'NEXT: up   BACK: up   CANCEL: up';

  MemoTop := ScaleY(296);
  EventsMemo := TNewMemo.Create(InputPage);
  EventsMemo.Parent := InputPage.Surface;
  EventsMemo.Left := 0;
  EventsMemo.Top := MemoTop;
  EventsMemo.Width := PageWidth;
  EventsMemo.Height := InputPage.SurfaceHeight - MemoTop - ScaleY(4);
  if EventsMemo.Height < ScaleY(48) then
    EventsMemo.Height := ScaleY(48);
  EventsMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  EventsMemo.ReadOnly := True;
  EventsMemo.ScrollBars := ssVertical;
  EventsMemo.WordWrap := False;
  EventsMemo.Lines.Add('Input event log.');
end;

// ---------------------------------------------------------------------------
// Inno Setup lifecycle
// ---------------------------------------------------------------------------
procedure InitializeWizard;
begin
  Closing := False;
  InputTimerID := 0;
  InputAvailable := False;
  DeviceIDs := TStringList.Create;

  WizardForm.ClientWidth := ScaleX(640);
  WizardForm.ClientHeight := ScaleY(560);
  WizardForm.Position := poScreenCenter;

  CreateInputPage;

  // This is the same DLL extraction scheme used by the other FMXPixie demos.
  ExtractTemporaryFile('FMXPixie.dll');

  try
    Input := InitInput;
    InputAvailable := Input <> nil;
    if InputAvailable then
      AddEventLog('FMXInput initialized.');
  except
    on E: Exception do
      AddEventLog('FMXInput initialization failed: ' + E.ClassName + ': ' + E.Message);
  end;

  if InputAvailable then
  begin
    if Input.Refresh then
      PopulateDevices
    else
      AddEventLog('Initial device refresh failed: ' + Input.LastError);

    InputTimerID := SetTimer(0, 0, INPUT_POLL_INTERVAL,
      CreateCallback(@InputTimerProc));

    if InputTimerID = 0 then
      AddEventLog('Unable to create the input polling timer.');
  end
  else
  begin
    DeviceStatusLabel.Caption := 'FMXInput could not be initialized. Check the DLL and log.';
    CaptureButton.Enabled := False;
    RefreshButton.Enabled := False;
    RumbleButton.Enabled := False;
  end;
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
    Input.StopPolling;
    Input.CancelCapture;
    Input.StopRumble('');
    Input.Shutdown;
    Input := nil;
  end;

  if DeviceIDs <> nil then
  begin
    DeviceIDs.Free;
    DeviceIDs := nil;
  end;
end;
