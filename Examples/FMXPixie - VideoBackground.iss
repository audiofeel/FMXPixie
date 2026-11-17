
#define DemoAppName "FMXPixie Video Background"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
SetupIconFile=Files\setup.ico
SetupArchitecture=x64
OutputBaseFilename={#DemoAppName}

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
  DEMO_HEIGHT = 540;
  TITLEBAR_HEIGHT = 40;
  TITLEBAR_BUTTONS_WIDTH = 92;

  VOLUME_LEFT = 366;
  VOLUME_TOP = 470;
  VOLUME_WIDTH = 166;
  VOLUME_HEIGHT = 24;
  VOLUME_INSET = 6;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  VolumeBox: FPixiePaintBox;
  Doc: FPixieDocument;
  Elem: FPixieElement;
  VideoBackground: FVideoBackground;

  VideoFileName: String;
  VolumeValue: Single;
  LoopEnabled: Boolean;
  DraggingVolume: Boolean;

// Inno Setup / DOM helpers
procedure SetTextById(const Id, Value: String);
var
  H: NativeInt;
begin
  if Doc = nil then
    Exit;

  H := Doc.GetElementById(Id);
  if H <> 0 then
  begin
    Doc.SetElementText(H, Value);
    Doc.Changed;
  end;
end;

procedure SetClassById(const Id, ClassName: String);
var
  H: NativeInt;
begin
  if (Doc = nil) or (Elem = nil) then
    Exit;

  H := Doc.GetElementById(Id);
  if H = 0 then
    Exit;

  Elem.FCreate(H);
  Elem.SetAttr('class', ClassName);
  Doc.Changed;
end;

procedure SetStatus(const Value: String);
begin
  SetTextById('status-value', Value);
  Log('FMXPixie Video Background: ' + Value);
end;

procedure UpdateLoopButton;
begin
  if LoopEnabled then
  begin
    SetTextById('video-loop', 'LOOP  ON');
    SetClassById('video-loop', 'control-button loop-button active');
  end
  else
  begin
    SetTextById('video-loop', 'LOOP  OFF');
    SetClassById('video-loop', 'control-button loop-button');
  end;
end;

// Playback and volume
procedure SetPlayerVolume(NewVolume: Single);
begin
  if NewVolume < 0 then
    NewVolume := 0;
  if NewVolume > 1 then
    NewVolume := 1;

  VolumeValue := NewVolume;
  if VideoBackground <> nil then
    VideoBackground.Volume(VolumeValue);

  SetTextById('volume-value', IntToStr(Round(VolumeValue * 100)) + '%');

  if VolumeBox <> nil then
    VolumeBox.Repaint;
end;

procedure SetVolumeFromMouse(X: Single);
var
  TrackLeft, TrackWidth, Fraction: Single;
begin
  TrackLeft := VOLUME_LEFT + VOLUME_INSET;
  TrackWidth := VOLUME_WIDTH - VOLUME_INSET * 2;
  if TrackWidth <= 0 then
    Exit;

  Fraction := (X - TrackLeft) / TrackWidth;
  if Fraction < 0 then
    Fraction := 0;
  if Fraction > 1 then
    Fraction := 1;

  { While dragging, update only the slider's visual state. }
  VolumeValue := Fraction;
  if VolumeBox <> nil then
    VolumeBox.Repaint;
end;

function VolumeMouseHit(X, Y: Single): Boolean;
var
  TrackLeft, TrackRight, CenterY: Single;
begin
  TrackLeft := VOLUME_LEFT + VOLUME_INSET;
  TrackRight := VOLUME_LEFT + VOLUME_WIDTH - VOLUME_INSET;
  CenterY := VOLUME_TOP + VOLUME_HEIGHT / 2;

  Result := (X >= TrackLeft - 9) and (X <= TrackRight + 9) and
    (Y >= CenterY - 12) and (Y <= CenterY + 12);
end;

procedure VolumePaintBoxDraw(Sender: TObject);
var
  W, H, TrackWidth, FillWidth, KnobX: Single;
begin
  if VolumeBox = nil then
    Exit;

  W := VolumeBox.GetWidth;
  H := VolumeBox.GetHeight;
  if (W <= 0) or (H <= 0) then
    Exit;

  TrackWidth := W - VOLUME_INSET * 2;
  FillWidth := TrackWidth * VolumeValue;
  KnobX := VOLUME_INSET + FillWidth;

  VolumeBox.PenStyle(ppsSolid);
  VolumeBox.PenWidth(1);
  VolumeBox.BrushStyle(pbsSolid);
  VolumeBox.BrushColor($FF273B4B);
  VolumeBox.PenColor($FF273B4B);
  VolumeBox.RoundRect(VOLUME_INSET, H / 2 - 2, TrackWidth, 4, 2);

  if FillWidth > 0 then
  begin
    VolumeBox.BrushColor($FF5ED9C2);
    VolumeBox.PenColor($FF5ED9C2);
    VolumeBox.RoundRect(VOLUME_INSET, H / 2 - 2, FillWidth, 4, 2);
  end;

  VolumeBox.BrushColor($FF102331);
  VolumeBox.PenColor($FF9AF0E1);
  VolumeBox.PenWidth(2);
  VolumeBox.Ellipse(KnobX - 5, H / 2 - 5, 10, 10);

  VolumeBox.BrushColor($FFE9FFFA);
  VolumeBox.PenColor($FFE9FFFA);
  VolumeBox.PenWidth(1);
  VolumeBox.Ellipse(KnobX - 2, H / 2 - 2, 4, 4);
end;

// HTML interaction
function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
begin
  Result := False;
  if El = nil then
    Exit;

  { Walk up the DOM so clicks on nested text/spans resolve to the parent ID. }
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

  if Id = 'win-minimize' then
  begin
    FMXForm.Minimize;
    Result := True;
  end
  else if Id = 'win-close' then
  begin
    WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
    Result := True;
  end
  else if Id = 'video-play' then
  begin
    VideoBackground.Play;
    SetStatus('PLAY REQUESTED');
    Result := True;
  end
  else if Id = 'video-pause' then
  begin
    VideoBackground.Pause;
    SetStatus('PAUSE REQUESTED');
    Result := True;
  end
  else if Id = 'video-stop' then
  begin
    VideoBackground.Stop;
    SetStatus('STOP REQUESTED');
    Result := True;
  end
  else if Id = 'video-loop' then
  begin
    LoopEnabled := not LoopEnabled;
    VideoBackground.Loop(LoopEnabled);
    UpdateLoopButton;
    if LoopEnabled then
      SetStatus('LOOP ENABLED')
    else
      SetStatus('LOOP DISABLED');
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
  end;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if VolumeMouseHit(X, Y) then
  begin
    View.ClearSelection;
    DraggingVolume := True;
    SetVolumeFromMouse(X);
  end;
end;

procedure TitleViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if (Button = mbLeft) and (X >= 0) and
     (X < DEMO_WIDTH - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

procedure ViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if DraggingVolume then
    SetVolumeFromMouse(X);
end;

procedure ViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if (Button = mbLeft) and DraggingVolume then
  begin
    View.ClearSelection;
    SetVolumeFromMouse(X);
    DraggingVolume := False;

    { Apply final volume and update the HTML label once after dragging. }
    if VideoBackground <> nil then
      VideoBackground.Volume(VolumeValue);
    SetTextById('volume-value', IntToStr(Round(VolumeValue * 100)) + '%');
    if VolumeBox <> nil then
      VolumeBox.Repaint;
  end;
end;

// HTML / CSS
function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:40px;margin:0;padding:0;overflow:hidden;}' +
    'body{font-family:"Segoe UI",Arial,sans-serif;font-size:12px;color:#eff8f8;}' +
    '.topbar{position:relative;width:100%;height:40px;overflow:hidden;' +
      'background:rgba(7,14,23,.82);border-bottom:1px solid rgba(190,225,232,.18);}' +
    '.brand{position:absolute;left:23px;top:0;height:39px;line-height:39px;' +
      'color:#eff8f8;font-size:12px;font-weight:800;letter-spacing:2.8px;}' +
    '.brand-accent{color:#61dfcf;}' +
    '.brand-sub{position:absolute;left:148px;top:0;height:39px;line-height:39px;' +
      'color:#91a7b3;font-size:9px;letter-spacing:1.5px;}' +
    '.win-buttons{position:absolute;right:0;top:0;width:92px;height:39px;font-size:0;}' +
    '.win-btn{display:inline-block;width:46px;height:39px;line-height:38px;text-align:center;' +
      'vertical-align:top;color:#b8cbd1;font-size:20px;cursor:pointer;}' +
    '.win-btn:hover{background:rgba(120,170,184,.22);color:#fff;}' +
    '.win-close:hover{background:#b94352;color:#fff;}' +
    '</style></head><body>' +
    '<div class="topbar">' +
      '<span class="brand">FMX<span class="brand-accent">PIXIE</span></span>' +
      '<span class="brand-sub">VIDEO BACKGROUND / DEMO</span>' +
      '<div class="win-buttons">' +
        '<div id="win-minimize" class="win-btn" title="Minimize">−</div>' +
        '<div id="win-close" class="win-btn win-close" title="Close">×</div>' +
      '</div>' +
    '</div>' +
    '</body></html>';
end;

function BuildDemoHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;-webkit-user-select:none;user-select:none;}' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;background:transparent;}' +
    'body{position:relative;color:#edf5f7;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;}' +

    '.panel{position:absolute;left:22px;bottom:18px;width:916px;height:110px;' +
      'background:rgba(7,15,24,.88);border:1px solid rgba(149,203,211,.28);' +
      'border-radius:9px;overflow:hidden;}' +
    '.panel-title{position:absolute;left:18px;top:13px;color:#eaf5f6;' +
      'font-size:10px;font-weight:800;letter-spacing:1.8px;}' +
    '.panel-note{position:absolute;left:160px;top:14px;color:#78939e;' +
      'font-size:9px;letter-spacing:.9px;}' +
    '.status{position:absolute;left:759px;top:10px;width:140px;height:22px;line-height:20px;' +
      'padding:0 9px;border:1px solid rgba(91,211,194,.35);border-radius:3px;' +
      'background:rgba(31,91,91,.24);color:#7de5d6;font-size:8px;font-weight:700;letter-spacing:1px;}' +
    '.control-button{position:absolute;top:48px;height:34px;line-height:32px;' +
      'text-align:center;border:1px solid rgba(132,173,185,.32);border-radius:4px;' +
      'background:rgba(22,40,53,.92);color:#d4e6e9;font-size:9px;font-weight:800;' +
      'letter-spacing:1px;cursor:pointer;}' +
    '.control-button:hover{background:rgba(39,79,91,.98);border-color:#69cfc5;color:#fff;}' +
    '#video-play{left:18px;width:72px;background:rgba(37,105,104,.88);border-color:#4dada5;color:#f4ffff;}' +
    '#video-play:hover{background:#317f7a;border-color:#7be6d9;}' +
    '#video-pause{left:98px;width:72px;}' +
    '#video-stop{left:178px;width:72px;}' +
    '.volume-label{position:absolute;left:267px;top:59px;height:18px;line-height:18px;' +
      'color:#8da8b0;font-size:8px;font-weight:700;letter-spacing:1.3px;}' +
    '.volume-value{position:absolute;left:514px;top:56px;width:42px;height:22px;line-height:22px;' +
      'color:#e5f5f5;font-size:10px;text-align:center;font-variant-numeric:tabular-nums;}' +
    '.volume-nudge{position:absolute;top:52px;width:23px;height:26px;line-height:24px;' +
      'text-align:center;border:1px solid rgba(132,173,185,.25);border-radius:3px;' +
      'background:rgba(17,34,46,.92);color:#c7e2e3;font-size:14px;cursor:pointer;}' +
    '.volume-nudge:hover{border-color:#66cfc4;background:#214957;color:#fff;}' +
    '#volume-down{left:558px;}#volume-up{left:585px;}' +
    '.loop-button{left:632px;width:90px;}' +
    '.loop-button.active{border-color:rgba(88,213,180,.58);background:rgba(29,87,73,.58);color:#8ee9cd;}' +
    '.loop-button.active:hover{background:rgba(39,119,94,.82);}' +
    '.panel-foot{position:absolute;left:19px;bottom:8px;color:#5e7883;' +
      'font-size:8px;letter-spacing:1px;}' +
    '.format-note{position:absolute;left:718px;bottom:8px;width:180px;color:#5e7883;' +
      'font-size:8px;letter-spacing:1px;}' +
    '</style></head><body>' +

    '<div class="panel">' +
      '<div class="panel-title">VIDEO BACKGROUND</div>' +
      '<div class="panel-note">MEDIA FOUNDATION  /  FMX LAYER</div>' +
      '<div class="status">STATE&nbsp; <span id="status-value">STARTING</span></div>' +
      '<div id="video-play" class="control-button">PLAY</div>' +
      '<div id="video-pause" class="control-button">PAUSE</div>' +
      '<div id="video-stop" class="control-button">STOP</div>' +
      '<div class="volume-label">VOLUME</div>' +
      '<div id="volume-value" class="volume-value">70%</div>' +
      '<div id="volume-down" class="volume-nudge" title="Lower volume">−</div>' +
      '<div id="volume-up" class="volume-nudge" title="Raise volume">+</div>' +
      '<div id="video-loop" class="control-button loop-button active">LOOP&nbsp; ON</div>' +
      '<div class="panel-foot">PIXIE HTML / CSS OVERLAY</div>' +
      '<div class="format-note">MP4  ·  H.264 / AAC</div>' +
    '</div>' +
    '</body></html>';
end;

// Initialization / shutdown
function InitializeSetup: Boolean;
begin
  Result := False;
  DraggingVolume := False;
  LoopEnabled := True;
  VolumeValue := 0.70;

  try
    FMXForm := InitFormHandle;
    TitleView := InitPixieHtmlView;
    View := InitPixieHtmlView;
    VolumeBox := InitPixiePaintBox;
    Doc := InitPixieDocument;
    Elem := InitPixieElement;
    VideoBackground := InitVideoBackground;
    Result := True;
  except
    MsgBox('FMXPixie video demo initialization failed:' + #13#10 +
      GetExceptionMessage, mbError, MB_OK);
  end;
end;

procedure InitializeWizard;
begin
  EmptyWizardForm(DEMO_WIDTH, DEMO_HEIGHT);

  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF101820, '', True);

  { Keep the video as a normal FMX child object at the back of the form. }
  VideoFileName := ExpandConstant('{src}\background.mp4');
  VideoBackground.FCreate(FMXForm.Handle, VideoFileName, True);
  VideoBackground.MaxOutputSize(960, 540);
  VideoBackground.Volume(VolumeValue);
  VideoBackground.SendToBack;

  { The Pixie view is transparent, so the video remains visible underneath. }
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
  View.LoadFromString(BuildDemoHtml);
  View.BringToFront;

  Doc.FCreate(View.GetDocument);

  { The titlebar is a separate HTMLView, matching the other Pixie demos. }
  TitleView.FCreate(FMXForm.Handle);
  TitleView.SetBounds(0, 0, DEMO_WIDTH, TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.SetScrollbarVisibility(svHide);
  TitleView.HitTest(True);
  TitleView.Enabled(True);
  TitleView.Visible(True);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@TitleViewMouseDown);
  TitleView.LoadFromString(BuildTitleBarHtml);
  TitleView.BringToFront;

  { PaintBox draws the slider only; mouse input is handled by the HTML view. }
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

  UpdateLoopButton;
  SetPlayerVolume(VolumeValue);
  SetStatus('PLAY REQUESTED');

  FMXForm.Show;
  VideoBackground.Play;
end;

procedure DeinitializeSetup;
begin
  if VideoBackground <> nil then
    VideoBackground.Stop;

  FMXPixieShutDown;
end;
