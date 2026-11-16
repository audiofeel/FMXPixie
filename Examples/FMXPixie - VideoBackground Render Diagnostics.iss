; ============================================================================
; FMXPixie - Video Background Render Diagnostics
;
; TEMPORARY TEST:
;   VIDEO = video frames presented to TImage per second
;   TITLE = TitleView OnAfterPaint calls per second
;   CTRL  = ControlsView OnAfterPaint calls per second
;
; The independent FMX test button hides/shows only the two Pixie HTML layers.
; Video playback continues unchanged.
;
; Remove this test and the temporary counters after measurements are complete.
; ============================================================================

#define DemoAppName "FMXPixie Video Background Render Diagnostics"
#define DemoAppVersion "1.0"

[Setup]
AppId=FMXPixieVideoBackgroundRenderDiagnostics
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
AppCopyright=audiofeel
CreateAppDir=no
Uninstallable=no
DisableWelcomePage=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyMemo=yes
SetupIconFile=Files\setup.ico
SetupArchitecture=x64
OutputBaseFilename=FMXPixie_VideoBackground_Render_Diagnostics
Compression=lzma2
SolidCompression=yes
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
  DEMO_WIDTH = 960;
  DEMO_HEIGHT = 540;
  TITLE_HEIGHT = 40;
  CONTROLS_LEFT = 22;
  CONTROLS_TOP = 412;
  CONTROLS_WIDTH = 916;
  CONTROLS_HEIGHT = 110;

  TEST_LEFT = 688;
  TEST_TOP = 54;
  TEST_WIDTH = 250;
  TEST_HEIGHT = 64;

var
  FMXForm: FForm;
  VideoLayer: FLayout;
  TitleLayer: FLayout;
  ControlsLayer: FLayout;
  TestLayer: FLayout;

  TitleView: FPixieHtmlView;
  ControlsView: FPixieHtmlView;
  TestPaint: FPixiePaintBox;
  VideoBackground: FVideoBackground;
  MeasureTimer: FTimer;

  PixieViewsVisible: Boolean;
  TestButtonText: String;
  DiagnosticText: String;

  TitlePaintCount: Integer;
  ControlsPaintCount: Integer;
  LastVideoFrameCount: Integer;

procedure TitleViewAfterPaint(Sender: TObject);
begin
  Inc(TitlePaintCount);
end;

procedure ControlsViewAfterPaint(Sender: TObject);
begin
  Inc(ControlsPaintCount);
end;

procedure MeasureTimerTick(Sender: TObject);
var
  CurrentVideoFrames: Integer;
  VideoFPS, TitleFPS, ControlsFPS: Integer;
begin
  CurrentVideoFrames := VideoBackground.GetPresentedFrameCount;
  VideoFPS := CurrentVideoFrames - LastVideoFrameCount;
  LastVideoFrameCount := CurrentVideoFrames;

  TitleFPS := TitlePaintCount;
  ControlsFPS := ControlsPaintCount;
  TitlePaintCount := 0;
  ControlsPaintCount := 0;

  DiagnosticText := 'VIDEO ' + IntToStr(VideoFPS) +
    ' | TITLE ' + IntToStr(TitleFPS) +
    ' | CTRL ' + IntToStr(ControlsFPS);

  if TestPaint <> nil then
    TestPaint.Repaint;

  Log('Render diagnostics: video=' + IntToStr(VideoFPS) +
    ' fps; title OnAfterPaint=' + IntToStr(TitleFPS) +
    '/s; controls OnAfterPaint=' + IntToStr(ControlsFPS) + '/s');
end;

procedure TestButtonPaint(Sender: TObject);
var
  W, H: Single;
begin
  if TestPaint = nil then
    Exit;

  W := TestPaint.GetWidth;
  H := TestPaint.GetHeight;
  if (W <= 0) or (H <= 0) then
    Exit;

  TestPaint.PenStyle(ppsSolid);
  TestPaint.PenWidth(1);
  TestPaint.BrushStyle(pbsSolid);
  TestPaint.BrushColor($E61A303B);
  TestPaint.PenColor($FF63D7C8);
  TestPaint.RoundRect(0.5, 0.5, W - 1, H - 1, 6);

  TestPaint.FontFamily('Segoe UI');
  TestPaint.FontSize(10);
  TestPaint.FontStyle([pfsBold]);
  TestPaint.FontColor($FFF0FFFC);
  TestPaint.TextRect(0, 0, W, 36, TestButtonText, ptaCenter, pvaMiddle);

  TestPaint.PenColor($FF385461);
  TestPaint.Line(10, 38, W - 10, 38);
  TestPaint.FontSize(8);
  TestPaint.FontStyle([]);
  TestPaint.FontColor($FFAAC0C8);
  TestPaint.TextRect(5, 40, W - 10, 20, DiagnosticText, ptaCenter, pvaMiddle);
end;

procedure UpdateTestButton;
begin
  if PixieViewsVisible then
    TestButtonText := 'HIDE PIXIE VIEWS'
  else
    TestButtonText := 'SHOW PIXIE VIEWS';

  if TestPaint <> nil then
    TestPaint.Repaint;
end;

procedure TogglePixieViews(Sender: TObject);
begin
  PixieViewsVisible := not PixieViewsVisible;

  if TitleLayer <> nil then
    TitleLayer.Visible(PixieViewsVisible);
  if ControlsLayer <> nil then
    ControlsLayer.Visible(PixieViewsVisible);

  UpdateTestButton;

  if PixieViewsVisible then
    Log('Pixie HTMLViews shown; video playback was not changed.')
  else
    Log('Pixie HTMLViews hidden; video playback was not changed.');
end;

function BuildTitleHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:960px;height:40px;margin:0;padding:0;overflow:hidden;background:transparent;}' +
    'body{font-family:"Segoe UI",Arial,sans-serif;color:#eff8f8;}' +
    '.bar{width:960px;height:40px;padding:0 22px;line-height:40px;' +
      'background:rgba(7,14,23,.72);border-bottom:1px solid rgba(190,225,232,.14);}' +
    '.brand{font-size:12px;font-weight:800;letter-spacing:2.8px;}' +
    '.accent{color:#61dfcf;}' +
    '.note{margin-left:18px;color:#91a7b3;font-size:9px;letter-spacing:1.5px;}' +
    '</style></head><body>' +
    '<div class="bar"><span class="brand">FMX<span class="accent">PIXIE</span></span>' +
    '<span class="note">VIDEO BACKGROUND / RENDER DIAGNOSTICS</span></div>' +
    '</body></html>';
end;

function BuildControlsHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:916px;height:110px;margin:0;padding:0;overflow:hidden;background:transparent;}' +
    'body{font-family:"Segoe UI",Arial,sans-serif;color:#edf5f7;}' +
    '.panel{position:absolute;left:0;top:0;width:916px;height:110px;overflow:hidden;' +
      'background:rgba(7,15,24,.88);border:1px solid rgba(149,203,211,.28);border-radius:9px;}' +
    '.title{position:absolute;left:18px;top:13px;color:#eaf5f6;font-size:10px;' +
      'font-weight:800;letter-spacing:1.8px;white-space:nowrap;}' +
    '.note{position:absolute;left:160px;top:14px;color:#78939e;font-size:9px;' +
      'letter-spacing:.9px;white-space:nowrap;}' +
    '.button{position:absolute;top:48px;height:34px;line-height:32px;text-align:center;' +
      'border:1px solid rgba(132,173,185,.32);border-radius:4px;' +
      'background:rgba(22,40,53,.92);color:#d4e6e9;font-size:9px;' +
      'font-weight:800;letter-spacing:1px;}' +
    '.play{left:18px;width:72px;background:rgba(37,105,104,.88);border-color:#4dada5;}' +
    '.pause{left:98px;width:72px;}.stop{left:178px;width:72px;}' +
    '.description{position:absolute;left:270px;top:57px;color:#91aab3;' +
      'font-size:9px;letter-spacing:.8px;white-space:nowrap;}' +
    '.state{position:absolute;right:17px;top:10px;height:22px;line-height:20px;' +
      'padding:0 9px;border:1px solid rgba(91,211,194,.35);border-radius:3px;' +
      'background:rgba(31,91,91,.24);color:#7de5d6;font-size:8px;' +
      'font-weight:700;letter-spacing:1px;white-space:nowrap;}' +
    '</style></head><body>' +
    '<div class="panel">' +
      '<div class="title">VIDEO BACKGROUND</div>' +
      '<div class="note">MEDIA FOUNDATION / FMX LAYER</div>' +
      '<div class="state">PLAYING</div>' +
      '<div class="button play">PLAY</div>' +
      '<div class="button pause">PAUSE</div>' +
      '<div class="button stop">STOP</div>' +
      '<div class="description">TWO PIXIE HTMLVIEWS / PAINT COUNTERS ACTIVE</div>' +
    '</div></body></html>';
end;

function InitializeSetup: Boolean;
begin
  Result := False;

  try
    FMXForm := InitFormHandle;
    VideoLayer := InitLayoutHandle;
    TitleLayer := InitLayoutHandle;
    ControlsLayer := InitLayoutHandle;
    TestLayer := InitLayoutHandle;

    TitleView := InitPixieHtmlView;
    ControlsView := InitPixieHtmlView;
    TestPaint := InitPixiePaintBox;
    VideoBackground := InitVideoBackground;
    MeasureTimer := InitTimer;

    Result := True;
  except
    MsgBox('FMXPixie render diagnostics initialization failed:' + #13#10 +
      GetExceptionMessage, mbError, MB_OK);
  end;
end;

procedure InitializeWizard;
var
  VideoFileName: String;
begin
  EmptyWizardForm(DEMO_WIDTH, DEMO_HEIGHT);

  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF101820, '', True);
  FMXForm.Caption('FMXPixie - Video Background Render Diagnostics');
  FMXForm.ChangeBorderColor($FF315766);
  FMXForm.StayOnTop(False);

  VideoFileName := ExpandConstant('{src}\background.mp4');

  { Video: one full-size FMX image layer, remains visible during the test. }
  VideoLayer.FCreate(FMXForm.Handle);
  VideoLayer.SetBounds(0, 0, DEMO_WIDTH, DEMO_HEIGHT);
  VideoLayer.SetClipChildren(True);

  VideoBackground.FCreate(VideoLayer.Handle, VideoFileName, True);
  VideoBackground.Align(Contents);
  VideoBackground.MaxOutputSize(DEMO_WIDTH, DEMO_HEIGHT);
  VideoBackground.SendToBack;
  VideoLayer.SendToBack;

  { Pixie view 1: title bar. }
  TitleLayer.FCreate(FMXForm.Handle);
  TitleLayer.SetBounds(0, 0, DEMO_WIDTH, TITLE_HEIGHT);
  TitleLayer.SetClipChildren(True);

  TitleView.FCreate(TitleLayer.Handle);
  TitleView.SetBounds(0, 0, DEMO_WIDTH, TITLE_HEIGHT);
  TitleView.SetClipParent(True);
  TitleView.Enabled(True);
  TitleView.Visible(True);
  TitleView.HitTest(True);
  TitleView.ColorScheme(pcsDark);
  TitleView.SetScrollbarVisibility(svHide);
  TitleView.OnAfterPaint(@TitleViewAfterPaint);
  TitleView.LoadFromString(BuildTitleHtml);
  TitleLayer.BringToFront;

  { Pixie view 2: bottom controls panel. }
  ControlsLayer.FCreate(FMXForm.Handle);
  ControlsLayer.SetBounds(CONTROLS_LEFT, CONTROLS_TOP,
    CONTROLS_WIDTH, CONTROLS_HEIGHT);
  ControlsLayer.SetClipChildren(True);

  ControlsView.FCreate(ControlsLayer.Handle);
  ControlsView.SetBounds(0, 0, CONTROLS_WIDTH, CONTROLS_HEIGHT);
  ControlsView.SetClipParent(True);
  ControlsView.Enabled(True);
  ControlsView.Visible(True);
  ControlsView.HitTest(True);
  ControlsView.ColorScheme(pcsDark);
  ControlsView.SetScrollbarVisibility(svHide);
  ControlsView.OnAfterPaint(@ControlsViewAfterPaint);
  ControlsView.LoadFromString(BuildControlsHtml);
  ControlsLayer.BringToFront;

  { Independent FMX button and counter display. }
  TestLayer.FCreate(FMXForm.Handle);
  TestLayer.SetBounds(TEST_LEFT, TEST_TOP, TEST_WIDTH, TEST_HEIGHT);
  TestLayer.SetClipChildren(True);
  TestLayer.HitTest(True);
  TestLayer.OnClick(@TogglePixieViews);

  TestPaint.FCreate(TestLayer.Handle);
  TestPaint.SetBounds(0, 0, TEST_WIDTH, TEST_HEIGHT);
  TestPaint.SetClipParent(True);
  TestPaint.FillBackground(False);
  TestPaint.OnPaint(@TestButtonPaint);
  TestPaint.HitTest(False);
  TestLayer.BringToFront;

  PixieViewsVisible := True;
  TestButtonText := 'HIDE PIXIE VIEWS';
  DiagnosticText := 'VIDEO -- | TITLE -- | CTRL --';

  MeasureTimer.FCreate(FMXForm.Handle);
  MeasureTimer.Interval(1000);
  MeasureTimer.OnTimer(@MeasureTimerTick);

  FMXForm.Show;
  VideoBackground.Play;
  LastVideoFrameCount := VideoBackground.GetPresentedFrameCount;
  MeasureTimer.Enabled(True);
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := False;
end;

procedure DeinitializeSetup;
begin
  if MeasureTimer <> nil then
    MeasureTimer.Enabled(False);

  if VideoBackground <> nil then
    VideoBackground.Stop;

  FMXPixieShutDown;
end;
