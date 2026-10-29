; ============================================================================
; FMXPixie TagBar Demo for Inno Setup
;
; Демонстрирует: 
; Отображаются процент громкости и условное значение BASS_ATTRIB_VOL от 0.00 до 1.00.
; Используются только существующие обёртки:
;  - FPixiePaintBox рисует дорожку и бегунок.
;  - FPixieHtmlView обрабатывает нажатия и перемещение мыши.
;
; В коде отмечено место, куда добавить вызов изменения громкости аудиоканала.
;
; Требуемые файлы проекта:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll / Modules\FMXPixie_x64.dll (rebuilt with wrapper)
;   FMXPixie_TagBar_Interface.iss
;
; BASS не подключён - демонстрируется только регулировка значения.
; ============================================================================

#define DemoAppName "FMXPixie - Volume Slider Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
; SetupArchitecture=x64
OutputBaseFilename=FMXPixie - Volume Slider Demo
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
  DEMO_WIDTH = 880;
  DEMO_HEIGHT = 480;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 88;

  PAINT_LEFT = 70;
  PAINT_TOP = 170;
  PAINT_WIDTH = 740;
  PAINT_HEIGHT = 154;

  TRACK_LEFT = 54;
  TRACK_Y = 87;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  PaintBox: FPixiePaintBox;
  Elem: FPixieElement;

  VolumePercent: Integer;
  Dragging: Boolean;

function TrackWidth: Single;
begin
  Result := PAINT_WIDTH - TRACK_LEFT * 2;
end;

function VolumeValueText: String;
var
  Digits: String;
begin
  if VolumePercent >= 100 then
    Result := '1.00'
  else
  begin
    Digits := IntToStr(VolumePercent);
    if VolumePercent < 10 then
      Digits := '0' + Digits;
    Result := '0.' + Digits;
  end;
end;

function BuildTitleHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{margin:0;padding:0;width:100%;height:32px;overflow:hidden;}' +
    'body{background:#111a28;color:#e8eef7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.bar{position:relative;width:100%;height:32px;line-height:32px;' +
    'background:#111a28;border-bottom:1px solid #26364b;}' +
    '.caption{padding-left:14px;color:#80ddd5;font-weight:bold;}' +
    '.sub{padding-left:9px;color:#72869f;font-size:11px;}' +
    '.buttons{position:absolute;right:0;top:0;width:88px;height:32px;font-size:0;}' +
    '.button{display:inline-block;width:44px;height:32px;line-height:30px;' +
    'text-align:center;font-size:21px;color:#cbd5e1;cursor:pointer;}' +
    '.button:hover{background:#29384b;color:#fff;}' +
    '.close:hover{background:#d74747;}' +
    '</style></head><body><div class="bar">' +
    '<span class="caption">FMXPixie</span><span class="sub">/ simulated volume control</span>' +
    '<div class="buttons"><div id="title-minimize" class="button">−</div>' +
    '<div id="title-close" class="button close">×</div></div></div></body></html>';
end;

function BuildMainHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;-webkit-user-select:none;user-select:none;}' +
    'html,body{margin:0;padding:0;width:100%;height:448px;overflow:hidden;}' +
    'body{background:#0a101a;color:#e7eef7;font:13px "Segoe UI",Arial,sans-serif;}' +
    '.heading{position:absolute;left:34px;top:22px;color:#f3f7fc;font-size:21px;font-weight:600;}' +
    '.description{position:absolute;left:35px;top:54px;color:#93a5bb;font-size:12px;}' +
    '.note{position:absolute;left:72px;top:342px;width:736px;color:#aabbd0;font-size:12px;line-height:19px;}' +
    '.note strong{color:#74d8d0;font-weight:600;}' +
    '.small{color:#6f839d;font-size:11px;margin-top:3px;}' +
    '</style></head><body>' +
    '<div class="heading">A simple volume slider</div>' +
    '<div class="description">FPixiePaintBox draws the control; FPixieHtmlView receives mouse input.</div>' +
    '<div class="note"><strong>Demo only:</strong> the value changes here, but no audio is played and BASS is not loaded.' +
    '<div class="small">For a real player, pass the resulting value (0.00–1.00) to BASS_ChannelSetAttribute using BASS_ATTRIB_VOL.</div></div>' +
    '</body></html>';
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
  end
  else if Id = 'title-close' then
  begin
    CloseSetup;
    Result := True;
  end;
end;

procedure TitleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < DEMO_WIDTH - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

function MouseIsOnTrack(X, Y: Single): Boolean;
var
  StartX, EndX, CenterY: Single;
begin
  StartX := PAINT_LEFT + TRACK_LEFT;
  EndX := StartX + TrackWidth;
  CenterY := PAINT_TOP - TITLEBAR_HEIGHT + TRACK_Y;

  Result := (X >= StartX - 18) and (X <= EndX + 18) and
    (Y >= CenterY - 27) and (Y <= CenterY + 27);
end;

procedure SetVolumeFromMouse(X: Single);
var
  Pct: Integer;
  StartX: Single;
begin
  StartX := PAINT_LEFT + TRACK_LEFT;
  Pct := Round(((X - StartX) / TrackWidth) * 100);
  if Pct < 0 then Pct := 0;
  if Pct > 100 then Pct := 100;

  if Pct <> VolumePercent then
  begin
    VolumePercent := Pct;
    // In a real BASS player, use VolumePercent / 100.0 as BASS_ATTRIB_VOL.
    // This demo deliberately does not load BASS or require a channel handle.
    PaintBox.Repaint;
  end;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if MouseIsOnTrack(X, Y) then
  begin
    View.ClearSelection;
    Dragging := True;
    SetVolumeFromMouse(X);
  end;
end;

procedure ViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Dragging then
  begin
    View.ClearSelection;
    SetVolumeFromMouse(X);
  end;
end;

procedure ViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if not Dragging then Exit;
  View.ClearSelection;
  SetVolumeFromMouse(X);
  Dragging := False;
end;

procedure PaintBoxDraw(Sender: TObject);
var
  W, H: Single;
  FillW, KnobX: Single;
  ValueText: String;
  VolText: String;
begin
  W := PaintBox.GetWidth;
  H := PaintBox.GetHeight;
  if (W <= 0) or (H <= 0) then Exit;

  PaintBox.PenStyle(ppsSolid);
  PaintBox.PenWidth(1);
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor($FF111C2B);
  PaintBox.PenColor($FF26384E);
  PaintBox.RoundRect(0, 0, W - 1, H - 1, 12);

  PaintBox.FontFamily('Segoe UI');
  PaintBox.FontStyle([pfsBold]);
  PaintBox.FontSize(12);
  PaintBox.FontColor($FFEAF2FC);
  PaintBox.TextOut(24, 25, 'MASTER VOLUME');

  PaintBox.FontStyle([]);
  PaintBox.FontSize(10);
  PaintBox.FontColor($FF8196AF);
  PaintBox.TextOut(24, 47, 'SIMULATED BASS CONTROL');

  ValueText := IntToStr(VolumePercent) + '%';
  PaintBox.FontStyle([pfsBold]);
  PaintBox.FontSize(22);
  PaintBox.FontColor($FF65DED4);
  PaintBox.TextOut(W - PaintBox.TextWidth(ValueText) - 24, 34, ValueText);

  VolText := 'BASS_ATTRIB_VOL = ' + VolumeValueText;
  PaintBox.FontStyle([]);
  PaintBox.FontSize(10);
  PaintBox.FontColor($FFB7C7D9);
  PaintBox.TextOut(24, 65, VolText);

  // Track and fill.
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor($FF26374B);
  PaintBox.PenColor($FF26374B);
  PaintBox.RoundRect(TRACK_LEFT, TRACK_Y - 5, TrackWidth, 10, 5);

  FillW := TrackWidth * VolumePercent / 100;
  if FillW > 0 then
  begin
    PaintBox.BrushColor($FF55D6CC);
    PaintBox.PenColor($FF55D6CC);
    PaintBox.RoundRect(TRACK_LEFT, TRACK_Y - 4, FillW, 8, 4);
  end;

  // Three small marks make the scale easier to read.
  PaintBox.PenStyle(ppsSolid);
  PaintBox.PenWidth(1);
  PaintBox.PenColor($FF60758D);
  PaintBox.Line(TRACK_LEFT, TRACK_Y + 11, TRACK_LEFT, TRACK_Y + 16);
  PaintBox.Line(TRACK_LEFT + TrackWidth / 2, TRACK_Y + 11,
    TRACK_LEFT + TrackWidth / 2, TRACK_Y + 16);
  PaintBox.Line(TRACK_LEFT + TrackWidth, TRACK_Y + 11,
    TRACK_LEFT + TrackWidth, TRACK_Y + 16);

  // Handle.
  KnobX := TRACK_LEFT + FillW;
  PaintBox.BrushColor($FF15283A);
  PaintBox.PenColor($FF65DED4);
  PaintBox.PenWidth(2);
  PaintBox.Ellipse(KnobX - 10, TRACK_Y - 10, 20, 20);
  PaintBox.BrushColor($FFEAFDFC);
  PaintBox.PenColor($FFEAFDFC);
  PaintBox.Ellipse(KnobX - 3, TRACK_Y - 3, 6, 6);

  PaintBox.FontStyle([]);
  PaintBox.FontSize(9);
  PaintBox.FontColor($FF8196AF);
  PaintBox.TextOut(TRACK_LEFT - 2, 123, '0%');
  PaintBox.TextOut(TRACK_LEFT + TrackWidth / 2 - PaintBox.TextWidth('50%') / 2,
    123, '50%');
  PaintBox.TextOut(TRACK_LEFT + TrackWidth - PaintBox.TextWidth('100%') + 2,
    123, '100%');

  PaintBox.FontSize(9);
  PaintBox.FontColor($FF71869F);
  PaintBox.TextOut(24, H - 12, 'Click the track or drag the knob');
  PaintBox.TextOut(W - 166, H - 12, 'VALUE: 0.00 - 1.00');
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  TitleView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  PaintBox := InitPixiePaintBox;
  Elem := InitPixieElement;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure ConfigureSetupHost;
begin
  WizardForm.BorderStyle := bsNone;
  WizardForm.ClientWidth := DEMO_WIDTH;
  WizardForm.ClientHeight := DEMO_HEIGHT;
  WizardForm.Position := poScreenCenter;
end;

procedure InitializeWizard;
begin
  VolumePercent := 68;
  Dragging := False;

  ConfigureSetupHost;
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('FMXPixie - Volume Slider Demo');
  FMXForm.ChangeBorderColor($FF2B817C);
  FMXForm.StayOnTop(False);

  TitleView.FCreate(FMXForm.Handle);
  TitleView.SetBounds(0, 0, DEMO_WIDTH, TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.HitTest(True);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@TitleMouseDown);
  TitleView.LoadFromString(BuildTitleHtml);

  View.FCreate(FMXForm.Handle);
  View.SetBounds(0, TITLEBAR_HEIGHT, DEMO_WIDTH, DEMO_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.HitTest(True);
  View.Enabled(True);
  View.Visible(True);
  View.OnMouseDown(@ViewMouseDown);
  View.OnMouseMove(@ViewMouseMove);
  View.OnMouseUp(@ViewMouseUp);
  View.LoadFromString(BuildMainHtml);

  // PaintBox draws the slider. HitTest(False) lets the HTML view below it
  // receive mouse coordinates, while the slider itself stays an FMX drawing.
  PaintBox.FCreate(FMXForm.Handle);
  PaintBox.SetBounds(PAINT_LEFT, PAINT_TOP, PAINT_WIDTH, PAINT_HEIGHT);
  PaintBox.SetClipParent(True);
  PaintBox.SetClipChildren(False);
  PaintBox.FillBackground(True);
  PaintBox.BackgroundColor($FF111C2B);
  PaintBox.PenStyle(ppsSolid);
  PaintBox.PenWidth(1);
  PaintBox.BrushStyle(pbsSolid);
  PaintBox.BrushColor($FF111C2B);
  PaintBox.Opacity(1.0);
  PaintBox.Enabled(True);
  PaintBox.Visible(True);
  PaintBox.HitTest(False);
  PaintBox.OnPaint(@PaintBoxDraw);
  PaintBox.BringToFront;

  PaintBox.Repaint;
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
