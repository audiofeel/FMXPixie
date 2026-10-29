; ============================================================================
; FMXPixie - Installer Welcome Page + Background Music
;
; Visual test of a polished first installer page. It does not install files.
; The only audio controls are: choose/toggle music, volume down, volume slider,
; and volume up. Playback is provided by FPixieAudioPlayer.
;
; Required project files:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll / Modules\FMXPixie_x64.dll
;
; The handle include already declares FPixieAudioPlayer and
; InitPixieAudioPlayer. Do not include a duplicate audio interface.
; ============================================================================

#define DemoAppName "FMXPixie - AudioPlayer Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
AppCopyright=audiofeel
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - AudioPlayer Demo
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
  DEMO_WIDTH = 960;
  DEMO_HEIGHT = 620;
  TITLEBAR_HEIGHT = 40;
  TITLEBAR_BUTTONS_WIDTH = 92;

  { Coordinates are relative to the full-size HTML view. }
  VOLUME_LEFT = 119;
  VOLUME_TOP = 569;
  VOLUME_WIDTH = 128;
  VOLUME_HEIGHT = 23;
  VOLUME_INSET = 5;

  VK_LBUTTON = 1;

var
  FMXForm: FForm;
  View: FPixieHtmlView;
  VolumeBox: FPixiePaintBox;
  Doc: FPixieDocument;
  Elem: FPixieElement;
  AudioPlayer: FPixieAudioPlayer;

  UiTimerId: UINT_PTR;
  IsClosing: Boolean;
  DraggingVolume: Boolean;
  VolumeValue: Single;
  UiChanged: Boolean;
  PlaybackOverrideActive: Boolean;
  PlaybackDesiredPlaying: Boolean;
  PlaybackOverrideDeadline: Int64;
  LastMusicButton, LastMusicState, LastVolumeText: String;

function SetTimer(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT;
  lpTimerFunc: NativeInt): UINT_PTR;
  external 'SetTimer@user32.dll stdcall';

function KillTimer(hWnd: HWND; uIDEvent: UINT_PTR): BOOL;
  external 'KillTimer@user32.dll stdcall';

function GetAsyncKeyState(vKey: Integer): SmallInt;
  external 'GetAsyncKeyState@user32.dll stdcall';

function GetTickCount64External: Int64;
  external 'GetTickCount64@kernel32.dll stdcall';

function BuildWelcomeHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;-webkit-user-select:none;user-select:none;}' +
    'html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;}' +
    'body{position:relative;background:#080e1a;color:#edf3fc;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.topbar{position:absolute;left:0;top:0;width:100%;height:40px;background:#0c1422;border-bottom:1px solid #24344a;line-height:39px;}' +
    '.brand{margin-left:24px;color:#80ead8;font-size:12px;font-weight:800;letter-spacing:3px;}' +
    '.brand-slash{margin-left:11px;color:#41546e;}' +
    '.brand-sub{margin-left:11px;color:#8798b1;font-size:10px;letter-spacing:1.7px;}' +
    '.win-buttons{position:absolute;right:0;top:0;width:92px;height:39px;font-size:0;}' +
    '.win-btn{display:inline-block;width:46px;height:39px;line-height:38px;text-align:center;font-size:20px;color:#aabbd0;cursor:pointer;}' +
    '.win-btn:hover{background:#223149;color:#fff;}' +
    '.win-close:hover{background:#bd4051;color:#fff;}' +
    '.eyebrow{position:absolute;left:54px;top:78px;color:#5fe0ca;font-size:10px;font-weight:700;letter-spacing:2.5px;}' +
    '.eyebrow-mark{color:#a1f4e5;}' +
    'h1{position:absolute;left:51px;top:111px;width:485px;margin:0;color:#f4f7fc;font-size:41px;font-weight:600;line-height:1.14;letter-spacing:-1.2px;}' +
    '.accent{color:#6de4d1;}' +
    '.lead{position:absolute;left:55px;top:225px;width:395px;color:#9cacc1;font-size:14px;line-height:23px;}' +
    '.release{position:absolute;left:55px;top:296px;height:29px;padding:8px 11px;border:1px solid #284d4d;background:#102627;color:#89e8d8;font-size:9px;font-weight:700;letter-spacing:1.5px;}' +
    '.visual{position:absolute;right:46px;top:73px;width:376px;height:346px;overflow:hidden;border:1px solid #20334a;background:linear-gradient(145deg,#101c30,#0b1321 65%,#101b2e);}' +
    '.visual-grid{position:absolute;left:0;top:0;width:100%;height:100%;opacity:.48;background-image:linear-gradient(#1d2c40 1px,transparent 1px),linear-gradient(90deg,#1d2c40 1px,transparent 1px);background-size:28px 28px;}' +
    '.orbit{position:absolute;left:58px;top:19px;width:260px;height:260px;border:1px solid #27465c;border-radius:50%;}' +
    '.orbit-two{left:80px;top:40px;width:216px;height:216px;border-color:#294a5a;}' +
    '.planet{position:absolute;left:111px;top:71px;width:154px;height:154px;border-radius:50%;background:radial-gradient(circle at 32% 25%,#8af1d9 0,#39b8b5 18%,#1c647f 43%,#102643 72%,#0b1425 100%);box-shadow:0 0 55px #1b9b9b55, inset -16px -18px 32px #06101f;}' +
    '.planet-cut{position:absolute;left:103px;top:144px;width:176px;height:37px;border-top:1px solid #8aeadb;border-bottom:1px solid #3c8d9c;transform:rotate(-24deg);opacity:.82;}' +
    '.orbit-dot{position:absolute;left:280px;top:94px;width:9px;height:9px;border-radius:50%;background:#a1f4e1;box-shadow:0 0 15px #5de4d1;}' +
    '.visual-tag{position:absolute;left:20px;bottom:18px;color:#7693aa;font-size:9px;letter-spacing:1.7px;}' +
    '.visual-code{position:absolute;right:16px;bottom:17px;color:#59d9c8;font-size:9px;letter-spacing:1px;}' +
    '.feature-row{position:absolute;left:54px;top:371px;width:470px;height:84px;border-top:1px solid #24344a;border-bottom:1px solid #24344a;}' +
    '.feature{position:absolute;top:18px;width:150px;}' +
    '.feature-a{left:0;}.feature-b{left:160px;}.feature-c{left:320px;}' +
    '.feature-icon{display:inline-block;width:22px;height:22px;line-height:20px;text-align:center;border:1px solid #315268;color:#70e4d0;font-size:11px;margin-right:7px;vertical-align:middle;}' +
    '.feature-title{display:inline-block;color:#dce8f5;font-weight:600;font-size:11px;vertical-align:middle;}' +
    '.feature-desc{margin-top:7px;color:#7488a3;font-size:10px;}' +
    '.bottom-rule{position:absolute;left:0;bottom:91px;width:100%;height:1px;background:#202e42;}' +
    '.music-label{position:absolute;left:44px;bottom:67px;color:#8096b0;font-size:9px;font-weight:700;letter-spacing:1.8px;}' +
    '.music-toggle,.vol-button{position:absolute;top:569px;height:23px;line-height:21px;text-align:center;cursor:pointer;border:1px solid #2f4e63;background:#132438;color:#cce8f0;font-weight:700;font-size:13px;}' +
    '.music-toggle{left:44px;top:569px;width:34px;color:#7de8d2;font-size:15px;}' +
    '.vol-down{left:86px;width:26px;}.vol-up{left:250px;width:26px;}' +
    '.music-toggle:hover,.vol-button:hover{background:#1d3a4d;border-color:#59cdbd;color:#fff;}' +
    '.vol-percent{position:absolute;left:282px;top:573px;width:38px;color:#c3d4e7;font-size:10px;text-align:right;font-variant-numeric:tabular-nums;}' +
    '.music-state{position:absolute;left:328px;top:573px;width:305px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:#6f849e;font-size:10px;letter-spacing:.3px;}' +
    '.nav-button{position:absolute;bottom:28px;height:38px;line-height:36px;text-align:center;cursor:pointer;font-size:10px;font-weight:700;letter-spacing:1.3px;}' +
    '.cancel{right:147px;width:88px;border:1px solid #31425a;color:#9aabc0;background:#101a2a;}' +
    '.next{right:43px;width:92px;border:1px solid #64dfca;background:#5ed9c2;color:#071a22;}' +
    '.cancel:hover{background:#1b2b40;color:#fff;}.next:hover{background:#94f0df;}' +
    '.footer-note{position:absolute;right:44px;bottom:10px;color:#394c63;font-size:8px;letter-spacing:1.2px;}' +
    '</style></head><body>' +
    '<div class="topbar"><span class="brand">ORBIT</span><span class="brand-slash">/</span><span class="brand-sub">DESKTOP SUITE INSTALLER</span>' +
    '<div class="win-buttons"><div id="win-minimize" class="win-btn">-</div><div id="win-close" class="win-btn win-close">X</div></div></div>' +
    '<div class="eyebrow"><span class="eyebrow-mark">01</span> &nbsp; INSTALLATION WIZARD &nbsp; / &nbsp; WELCOME</div>' +
    '<h1>Everything in place.<br><span class="accent">Ready when you are.</span></h1>' +
    '<div class="lead">A clean, considered setup for a smoother desktop experience. This wizard will guide you through a few simple steps.</div>' +
    '<div class="release">+ &nbsp; STABLE RELEASE &nbsp; / &nbsp; VERSION 1.4.2</div>' +
    '<div class="visual"><div class="visual-grid"></div><div class="orbit"></div><div class="orbit orbit-two"></div><div class="planet"></div><div class="planet-cut"></div><div class="orbit-dot"></div><div class="visual-tag">ORBIT / CORE SYSTEM</div><div class="visual-code">READY_001</div></div>' +
    '<div class="feature-row">' +
    '<div class="feature feature-a"><div><span class="feature-icon">01</span><span class="feature-title">Lightweight</span></div><div class="feature-desc">Minimal footprint</div></div>' +
    '<div class="feature feature-b"><div><span class="feature-icon">02</span><span class="feature-title">Integrated</span></div><div class="feature-desc">One guided setup</div></div>' +
    '<div class="feature feature-c"><div><span class="feature-icon">03</span><span class="feature-title">Straightforward</span></div><div class="feature-desc">Ready in minutes</div></div>' +
    '</div>' +
    '<div class="bottom-rule"></div>' +
    '<div class="music-label">BACKGROUND MUSIC</div>' +
    '<div id="music-toggle" class="music-toggle" title="Choose music or play/pause">&gt;</div>' +
    '<div id="volume-down" class="vol-button vol-down" title="Lower volume">-</div>' +
    '<div id="volume-up" class="vol-button vol-up" title="Raise volume">+</div>' +
    '<div id="volume-value" class="vol-percent">65%</div>' +
    '<div id="music-state" class="music-state">CLICK PLAY TO CHOOSE AN MP3 SOUNDTRACK</div>' +
    '<div id="btn-cancel" class="nav-button cancel">CANCEL</div>' +
    '<div id="btn-next" class="nav-button next">NEXT &nbsp; &gt;</div>' +
    '<div class="footer-note">NO FILES ARE INSTALLED IN THIS DEMO</div>' +
    '</body></html>';
end;

function GetCachedText(const Id: String): String;
begin
  Result := #1;
  if Id = 'music-toggle' then Result := LastMusicButton
  else if Id = 'music-state' then Result := LastMusicState
  else if Id = 'volume-value' then Result := LastVolumeText;
end;

procedure CacheText(const Id, Value: String);
begin
  if Id = 'music-toggle' then LastMusicButton := Value
  else if Id = 'music-state' then LastMusicState := Value
  else if Id = 'volume-value' then LastVolumeText := Value;
end;

procedure SetTextById(const Id, Value: String);
var
  H: NativeInt;
begin
  if Doc = nil then Exit;
  if GetCachedText(Id) = Value then Exit;
  H := Doc.GetElementById(Id);
  if H <> 0 then
  begin
    Doc.SetElementText(H, Value);
    CacheText(Id, Value);
    UiChanged := True;
  end;
end;

procedure SetPlayerVolume(NewVolume: Single);
begin
  if NewVolume < 0 then NewVolume := 0;
  if NewVolume > 1 then NewVolume := 1;
  if Abs(NewVolume - VolumeValue) < 0.001 then Exit;
  VolumeValue := NewVolume;
  if AudioPlayer <> nil then AudioPlayer.SetVolume(VolumeValue);
  if VolumeBox <> nil then VolumeBox.Repaint;
  SetTextById('volume-value', IntToStr(Round(VolumeValue * 100)) + '%');
  if (Doc <> nil) and UiChanged then
  begin
    Doc.Changed;
    UiChanged := False;
  end;
end;

procedure SetVolumeFromMouse(X: Single);
var
  TrackLeft, TrackWidth, Fraction: Single;
begin
  TrackLeft := VOLUME_LEFT + VOLUME_INSET;
  TrackWidth := VOLUME_WIDTH - VOLUME_INSET * 2;
  Fraction := (X - TrackLeft) / TrackWidth;
  if Fraction < 0 then Fraction := 0;
  if Fraction > 1 then Fraction := 1;
  SetPlayerVolume(Fraction);
end;

function VolumeMouseHit(X, Y: Single): Boolean;
var
  TrackLeft, TrackRight, CenterY: Single;
begin
  TrackLeft := VOLUME_LEFT + VOLUME_INSET;
  TrackRight := VOLUME_LEFT + VOLUME_WIDTH - VOLUME_INSET;
  CenterY := VOLUME_TOP + VOLUME_HEIGHT / 2;
  Result := (X >= TrackLeft - 8) and (X <= TrackRight + 8) and
    (Y >= CenterY - 12) and (Y <= CenterY + 12);
end;

procedure ChooseMusic;
var
  SelectedFile: String;
begin
  if AudioPlayer = nil then Exit;
  SelectedFile := AudioPlayer.GetCurrentFile;
  if GetOpenFileName('Choose background music', SelectedFile,
    ExtractFileDir(SelectedFile),
    'MP3 audio (*.mp3)|*.mp3|All files (*.*)|*.*', 'mp3') then
  begin
    try
      AudioPlayer.Open(SelectedFile, True, True);
      AudioPlayer.SetVolume(VolumeValue);
    except
      MsgBox('Could not start the selected MP3 file:' + #13#10 +
        GetExceptionMessage, mbError, MB_OK);
    end;
  end;
end;

procedure ToggleMusic;
var
  State: Integer;
  ShouldPlay: Boolean;
begin
  if AudioPlayer = nil then Exit;
  if AudioPlayer.GetCurrentFile = '' then
  begin
    ChooseMusic;
    Exit;
  end;
  if AudioPlayer.GetOpening then Exit;

  { Commands are queued on the audio worker. Use the last requested state while
    a command is in flight, otherwise a fast second click can enqueue Pause twice. }
  if PlaybackOverrideActive then
    ShouldPlay := not PlaybackDesiredPlaying
  else
  begin
    State := AudioPlayer.GetState;
    ShouldPlay := State <> 2;
  end;

  if ShouldPlay then
    AudioPlayer.Play
  else
    AudioPlayer.Pause;

  { The worker reports its state asynchronously. Show the intended state at once
    and let UpdateMusicUI reconcile it with the worker's state. }
  PlaybackDesiredPlaying := ShouldPlay;
  PlaybackOverrideActive := True;
  PlaybackOverrideDeadline := GetTickCount64External + 2000;
end;

procedure UpdateMusicUI;
var
  CurrentFile, StateText, ButtonText: String;
  State: Integer;
  StateReached: Boolean;
begin
  if (AudioPlayer = nil) or (Doc = nil) then Exit;
  UiChanged := False;
  CurrentFile := AudioPlayer.GetCurrentFile;
  State := AudioPlayer.GetState;

  if AudioPlayer.GetOpening then
  begin
    PlaybackOverrideActive := False;
    StateText := 'LOADING MUSIC...';
    ButtonText := '..';
  end
  else if CurrentFile = '' then
  begin
    PlaybackOverrideActive := False;
    StateText := 'CLICK PLAY TO CHOOSE AN MP3 SOUNDTRACK';
    ButtonText := '>';
  end
  else
  begin
    StateReached := (PlaybackDesiredPlaying and (State = 2)) or
      ((not PlaybackDesiredPlaying) and (State = 3));
    if PlaybackOverrideActive and
       (StateReached or (State = 5) or
        (GetTickCount64External >= PlaybackOverrideDeadline)) then
      PlaybackOverrideActive := False;

    if PlaybackOverrideActive then
    begin
      if PlaybackDesiredPlaying then State := 2 else State := 3;
    end;

    case State of
      2: begin StateText := 'PLAYING  /  ' + ExtractFileName(CurrentFile); ButtonText := '||'; end;
      3: begin StateText := 'PAUSED  /  ' + ExtractFileName(CurrentFile); ButtonText := '>'; end;
      4: begin StateText := 'TRACK FINISHED  /  ' + ExtractFileName(CurrentFile); ButtonText := '>'; end;
      5: begin StateText := 'AUDIO ERROR  /  ' + AudioPlayer.GetErrorText; ButtonText := '>'; end;
    else
      begin StateText := 'READY  /  ' + ExtractFileName(CurrentFile); ButtonText := '>'; end;
    end;
  end;

  SetTextById('music-toggle', ButtonText);
  SetTextById('music-state', StateText);
  SetTextById('volume-value', IntToStr(Round(VolumeValue * 100)) + '%');
  if UiChanged then Doc.Changed;
end;

procedure CancelDemo;
begin
  if IsClosing then Exit;
  IsClosing := True;
  if UiTimerId <> 0 then
  begin
    KillTimer(0, UiTimerId);
    UiTimerId := 0;
  end;
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

  if Id = 'win-minimize' then
  begin
    FMXForm.Minimize;
    Result := True;
  end
  else if Id = 'win-close' then
  begin
    CancelDemo;
    Result := True;
  end
  else if Id = 'music-toggle' then
  begin
    ToggleMusic;
    Result := True;
  end
  else if Id = 'volume-down' then
  begin
    SetPlayerVolume(VolumeValue - 0.05);
    Result := True;
  end
  else if Id = 'volume-up' then
  begin
    SetPlayerVolume(VolumeValue + 0.05);
    Result := True;
  end
  else if Id = 'btn-cancel' then
  begin
    CancelDemo;
    Result := True;
  end
  else if Id = 'btn-next' then
  begin
    MsgBox('This is a visual welcome-page demo. No files will be installed.',
      mbInformation, MB_OK);
    Result := True;
  end;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if VolumeMouseHit(X, Y) then
  begin
    View.ClearSelection;
    DraggingVolume := True;
    SetVolumeFromMouse(X);
    Exit;
  end;
  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < DEMO_WIDTH - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

procedure ViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if DraggingVolume then
  begin
    View.ClearSelection;
    SetVolumeFromMouse(X);
  end;
end;

procedure ViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if (Button = mbLeft) and DraggingVolume then
  begin
    View.ClearSelection;
    SetVolumeFromMouse(X);
    DraggingVolume := False;
  end;
end;

procedure VolumePaintBoxDraw(Sender: TObject);
var
  W, H, TrackWidth, FillWidth, KnobX: Single;
begin
  if VolumeBox = nil then Exit;
  W := VolumeBox.GetWidth;
  H := VolumeBox.GetHeight;
  if (W <= 0) or (H <= 0) then Exit;
  TrackWidth := W - VOLUME_INSET * 2;
  FillWidth := TrackWidth * VolumeValue;
  KnobX := VOLUME_INSET + FillWidth;

  VolumeBox.PenStyle(ppsSolid);
  VolumeBox.PenWidth(1);
  VolumeBox.BrushStyle(pbsSolid);
  VolumeBox.BrushColor($FF223247);
  VolumeBox.PenColor($FF223247);
  VolumeBox.RoundRect(VOLUME_INSET, H / 2 - 2, TrackWidth, 4, 2);
  if FillWidth > 0 then
  begin
    VolumeBox.BrushColor($FF62DCC7);
    VolumeBox.PenColor($FF62DCC7);
    VolumeBox.RoundRect(VOLUME_INSET, H / 2 - 2, FillWidth, 4, 2);
  end;
  VolumeBox.BrushColor($FF142A3C);
  VolumeBox.PenColor($FF8DECDD);
  VolumeBox.PenWidth(2);
  VolumeBox.Ellipse(KnobX - 5, H / 2 - 5, 10, 10);
  VolumeBox.BrushColor($FFE8FFF9);
  VolumeBox.PenColor($FFE8FFF9);
  VolumeBox.Ellipse(KnobX - 2, H / 2 - 2, 4, 4);
end;

procedure AudioUiTimerProc(hWnd: HWND; uMsg: UINT; idEvent: UINT_PTR;
  dwTime: DWORD);
begin
  if IsClosing then Exit;
  { Don't mutate the HTML DOM during mouse dispatch or while the volume slider is dragged. }
  if GetAsyncKeyState(VK_LBUTTON) < 0 then Exit;
  DraggingVolume := False;
  UpdateMusicUI;
end;

function InitializeSetup: Boolean;
begin
  Result := False;
  IsClosing := False;
  UiTimerId := 0;
  DraggingVolume := False;
  PlaybackOverrideActive := False;
  PlaybackDesiredPlaying := False;
  PlaybackOverrideDeadline := 0;
  VolumeValue := 0.65;
  try
    FMXForm := InitFormHandle;
    View := InitPixieHtmlView;
    VolumeBox := InitPixiePaintBox;
    Doc := InitPixieDocument;
    Elem := InitPixieElement;
    AudioPlayer := InitPixieAudioPlayer;
    AudioPlayer.SetVolume(VolumeValue);
    Result := True;
  except
    MsgBox('FMXPixie welcome demo initialization failed:' + #13#10 +
      GetExceptionMessage, mbError, MB_OK);
  end;
end;

procedure InitializeWizard;
begin
  EmptyWizardForm(DEMO_WIDTH, DEMO_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF0D1727, '', True);
  FMXForm.Caption('ORBIT - Desktop Suite Setup');

  View.FCreate(FMXForm.Handle);
  View.SetBounds(0, 0, DEMO_WIDTH, DEMO_HEIGHT);
  View.ColorScheme(pcsDark);
  View.SetScrollbarVisibility(svHide);
  View.HitTest(True);
  View.Enabled(True);
  View.Visible(True);
  View.OnElementClick(@ElementClick);
  View.OnMouseDown(@ViewMouseDown);
  View.OnMouseMove(@ViewMouseMove);
  View.OnMouseUp(@ViewMouseUp);
  View.LoadFromString(BuildWelcomeHtml);
  Doc.FCreate(View.GetDocument);

  VolumeBox.FCreate(FMXForm.Handle);
  VolumeBox.SetBounds(VOLUME_LEFT, VOLUME_TOP, VOLUME_WIDTH, VOLUME_HEIGHT);
  VolumeBox.SetClipParent(True);
  VolumeBox.SetClipChildren(False);
  VolumeBox.FillBackground(False);
  VolumeBox.Opacity(1.0);
  VolumeBox.Enabled(True);
  VolumeBox.Visible(True);
  VolumeBox.HitTest(False);
  VolumeBox.OnPaint(@VolumePaintBoxDraw);
  VolumeBox.BringToFront;
  VolumeBox.Repaint;

  UpdateMusicUI;
  FMXForm.Show;
  UiTimerId := SetTimer(0, 0, 60, CreateCallback(@AudioUiTimerProc));
  if UiTimerId = 0 then
    Log('ORBIT welcome demo: unable to create the music-state timer.');
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := False;
end;

procedure DeinitializeSetup;
begin
  IsClosing := True;
  if UiTimerId <> 0 then
  begin
    KillTimer(0, UiTimerId);
    UiTimerId := 0;
  end;
  if AudioPlayer <> nil then
  begin
    AudioPlayer.ShutDown;
    AudioPlayer := nil;
  end;
  FMXPixieShutDown;
end;
