; ============================================================================
; FMXPixie - CSS Opacity Transition Test
;
; Focused test for the opacity-only transition prototype:
;   transition: opacity 600ms linear;
;
; The report measures the duration of TPixieHtmlView's OnBeforePaint/OnAfterPaint
; interval and the interval between paint starts using QueryPerformanceCounter.
; Paint intervals are NOT the same as monitor-presented FPS.
;
; Place this file in the Examples folder beside Modules\FMXPixieHandle.iss and
; Modules\FMXPixie_x86.dll / Modules\FMXPixie_x64.dll.
; ============================================================================

#define DemoAppName "FMXPixie - CSS Opacity Transition Test"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - CSS Opacity Transition Test
; Uncomment for an x64 build if that is how this project's other demos are built:
; SetupArchitecture=x64

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  TEST_FORM_WIDTH = 880;
  TEST_FORM_HEIGHT = 650;
  TITLEBAR_HEIGHT = 40;

var
  FMXForm: FForm;
  View: FPixieHtmlView;
  Elem: FPixieElement;

  FQpcFrequency: Int64;
  FPaintStartCounter: Int64;
  FLastPaintStartCounter: Int64;
  FHasPaintStart: Boolean;
  FHasLastPaintStart: Boolean;
  FPaintCount: Integer;
  FIntervalCount: Integer;
  FTotalPaintTicks: Int64;
  FMaxPaintTicks: Int64;
  FTotalIntervalTicks: Int64;
  FMaxIntervalTicks: Int64;

function QueryPerformanceCounter(var Counter: Int64): Longint;
  external 'QueryPerformanceCounter@kernel32.dll stdcall';
function QueryPerformanceFrequency(var Frequency: Int64): Longint;
  external 'QueryPerformanceFrequency@kernel32.dll stdcall';

procedure EmptyWizardForm(BaseWidth, BaseHeight: Integer);
begin
  with WizardForm do
  begin
    Height := BaseHeight;
    Width := BaseWidth;
    NextButton.SetBounds(0, 0, 0, 0);
    CancelButton.SetBounds(0, 0, 0, 0);
    BackButton.SetBounds(0, 0, 0, 0);
  end;
end;

procedure ResetMeasurements;
begin
  FPaintStartCounter := 0;
  FLastPaintStartCounter := 0;
  FHasPaintStart := False;
  FHasLastPaintStart := False;
  FPaintCount := 0;
  FIntervalCount := 0;
  FTotalPaintTicks := 0;
  FMaxPaintTicks := 0;
  FTotalIntervalTicks := 0;
  FMaxIntervalTicks := 0;
end;

function TicksToMicroseconds(Ticks: Int64): Int64;
begin
  if FQpcFrequency <= 0 then
    Result := 0
  else
    Result := Round((Ticks / FQpcFrequency) * 1000000.0);
end;

function TicksToMillisecondsText(Ticks: Int64): String;
var
  Tenths: Int64;
begin
  if FQpcFrequency <= 0 then
  begin
    Result := 'n/a';
    Exit;
  end;

  Tenths := Round((Ticks / FQpcFrequency) * 10000.0);
  Result := IntToStr(Tenths div 10) + '.' + IntToStr(Tenths mod 10);
end;

function BuildTestHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{margin:0;width:100%;height:100%;overflow:hidden;}' +
    'body{background:#0b1220;color:#e5e7eb;font-family:"Segoe UI",Arial,sans-serif;font-size:14px;}' +
    '.titlebar{height:40px;padding:0 16px;display:flex;align-items:center;' +
    'background:#101827;border-bottom:1px solid #263248;color:#cbd5e1;' +
    'font-size:12px;letter-spacing:1.2px;text-transform:uppercase;position:relative;}' +
    '.title-close{position:absolute;right:10px;top:7px;width:46px;height:25px;' +
    'border:1px solid #334155;border-radius:5px;text-align:center;line-height:23px;' +
    'font-size:13px;letter-spacing:0;cursor:pointer;}' +
    '.title-close:hover{background:#991b1b;border-color:#ef4444;color:#fff;}' +
    '.content{padding:26px 30px;}' +
    '.eyebrow{font-size:11px;letter-spacing:2px;color:#93c5fd;text-transform:uppercase;}' +
    'h1{font-size:26px;font-weight:600;margin:8px 0 6px;color:#f8fafc;}' +
    '.muted{color:#9ca3af;line-height:1.55;margin:0;}' +
    '#transition-card{height:170px;margin-top:22px;border:1px solid #60a5fa;' +
    'border-radius:16px;background:#2563eb;opacity:0.15;' +
    'transition:opacity 600ms linear;display:flex;flex-direction:column;' +
    'justify-content:center;align-items:center;text-align:center;cursor:default;}' +
    '#transition-card:hover{opacity:1;}' +
    '#transition-card strong{font-size:25px;font-weight:600;color:#fff;}' +
    '#transition-card span{margin-top:8px;color:#dbeafe;font-size:13px;}' +
    '.buttons{display:flex;gap:10px;margin-top:20px;}' +
    'button{border:1px solid #334155;border-radius:7px;padding:10px 14px;' +
    'background:#172033;color:#e5e7eb;font:13px "Segoe UI",Arial,sans-serif;cursor:pointer;}' +
    '#btn-reset{background:#1d4ed8;border-color:#3b82f6;}' +
    '.note{margin-top:22px;padding-top:15px;border-top:1px solid #253248;' +
    'font-size:12px;color:#94a3b8;line-height:1.7;}' +
    '.code{font-family:Consolas,monospace;color:#bfdbfe;}' +
    '</style></head><body>' +
    '<div class="titlebar">FMXPixie / Paint + CSS transition' +
    '<div id="btn-close" class="title-close">X</div></div>' +
    '<div class="content">' +
    '<div class="eyebrow">Focused rendering test</div>' +
    '<h1>CSS opacity transition</h1>' +
    '<p class="muted">Hover the blue panel. Only opacity should animate; its layout and dimensions stay fixed.</p>' +
    '<div id="transition-card"><strong>HOVER ME</strong>' +
    '<span>opacity: 0.15 &rarr; 1.0 · 600 ms · linear</span></div>' +
    '<div class="buttons">' +
    '<button id="btn-reset">Reset measurements</button>' +
    '<button id="btn-report">Show paint report</button>' +
    '</div>' +
    '<div class="note">' +
    'Test sequence: click Reset, move onto the blue panel, then move off and let the transition finish. ' +
    'Click Show paint report to read the timing counters.<br>' +
    'The report measures paint-handler time and paint-start intervals. It does not measure GPU presentation or true monitor FPS.<br>' +
    '<span class="code">transition: opacity 600ms linear;</span>' +
    '</div></div></body></html>';
end;

procedure ViewBeforePaint(Sender: TObject);
var
  CurrentCounter, Delta: Int64;
begin
  if QueryPerformanceCounter(CurrentCounter) = 0 then
    Exit;

  if FHasLastPaintStart then
  begin
    Delta := CurrentCounter - FLastPaintStartCounter;
    if Delta >= 0 then
    begin
      Inc(FIntervalCount);
      FTotalIntervalTicks := FTotalIntervalTicks + Delta;
      if Delta > FMaxIntervalTicks then
        FMaxIntervalTicks := Delta;
    end;
  end;

  FLastPaintStartCounter := CurrentCounter;
  FPaintStartCounter := CurrentCounter;
  FHasLastPaintStart := True;
  FHasPaintStart := True;
end;

procedure ViewAfterPaint(Sender: TObject);
var
  CurrentCounter, Delta: Int64;
begin
  if not FHasPaintStart then
    Exit;
  if QueryPerformanceCounter(CurrentCounter) = 0 then
    Exit;

  Delta := CurrentCounter - FPaintStartCounter;
  FHasPaintStart := False;
  if Delta < 0 then
    Exit;

  Inc(FPaintCount);
  FTotalPaintTicks := FTotalPaintTicks + Delta;
  if Delta > FMaxPaintTicks then
    FMaxPaintTicks := Delta;
end;

procedure ShowPaintReport;
var
  Report: String;
  AveragePaintTicks, AverageIntervalTicks: Int64;
begin
  Report := 'FMXPixie CSS opacity transition test' + #13#10#13#10 +
    'Completed paint callbacks: ' + IntToStr(FPaintCount) + #13#10;

  if FPaintCount > 0 then
  begin
    AveragePaintTicks := FTotalPaintTicks div FPaintCount;
    Report := Report +
      'Average paint handler: ' + TicksToMillisecondsText(AveragePaintTicks) +
      ' ms (' + IntToStr(TicksToMicroseconds(AveragePaintTicks)) + ' us)' + #13#10 +
      'Maximum paint handler: ' + TicksToMillisecondsText(FMaxPaintTicks) +
      ' ms (' + IntToStr(TicksToMicroseconds(FMaxPaintTicks)) + ' us)' + #13#10;
  end
  else
    Report := Report + 'Paint timing: no completed paint callbacks recorded.' + #13#10;

  Report := Report + #13#10 +
    'Intervals between paint starts: ' + IntToStr(FIntervalCount) + #13#10;
  if FIntervalCount > 0 then
  begin
    AverageIntervalTicks := FTotalIntervalTicks div FIntervalCount;
    Report := Report +
      'Average interval: ' + TicksToMillisecondsText(AverageIntervalTicks) + ' ms' + #13#10 +
      'Maximum interval: ' + TicksToMillisecondsText(FMaxIntervalTicks) + ' ms' + #13#10;
  end;

  Report := Report + #13#10 +
    'Note: these are paint-handler timings, not GPU-presented FPS.';
  MsgBox(Report, mbInformation, MB_OK);
end;

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

  if Id = 'btn-reset' then
  begin
    ResetMeasurements;
    Result := True;
    Exit;
  end;

  if Id = 'btn-report' then
  begin
    ShowPaintReport;
    Result := True;
    Exit;
  end;

  if Id = 'btn-close' then
  begin
    WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
    Result := True;
    Exit;
  end;
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if (Button = mbLeft) and (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TEST_FORM_WIDTH - 70) then
    FMXForm.StartWindowDrag;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  View := InitPixieHtmlView;
  Elem := InitPixieElement;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  ResetMeasurements;
  FQpcFrequency := 0;
  Result := QueryPerformanceFrequency(FQpcFrequency) <> 0;
  if not Result then
    MsgBox('QueryPerformanceFrequency is not available on this system.', mbError, MB_OK);
end;

procedure InitializeWizard;
begin
  EmptyWizardForm(TEST_FORM_WIDTH, TEST_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);
  FMXForm.Caption('FMXPixie - CSS Opacity Transition Test');

  View.FCreate(FMXForm.Handle);
  View.SetBounds(0, 0, TEST_FORM_WIDTH, TEST_FORM_HEIGHT);
  View.ColorScheme(pcsDark);
  View.OnElementClick(@ElementClick);
  View.OnMouseDown(@ViewMouseDown);
  View.OnBeforePaint(@ViewBeforePaint);
  View.OnAfterPaint(@ViewAfterPaint);
  View.LoadFromString(BuildTestHtml);

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
