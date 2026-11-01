
unit FMXPixie.Utils;

interface

uses
  System.UITypes, System.Classes;

// =============================================================================
// Exports
// =============================================================================
function MbOrTb(Float: Extended; Decimal: Integer;
  const sMb, sGb, sTb: WideString): WideString; stdcall;

function MHzOrGHz(Float: Extended; Decimal: Integer): WideString; stdcall;

function ReadAllText(const FileName: WideString; out FText: WideString)
  : Boolean; stdcall;

function WriteAllText(const FileName, FText: WideString): Boolean; stdcall;

function AppendAllText(const FileName, FText: WideString): Boolean; stdcall;

procedure FMXPixieShutDown(const UnInstall: Boolean); stdcall;

implementation

uses
  System.IOUtils, System.SysUtils,
  Winapi.Windows,
  FMX.Forms, FMX.Platform.Win;

// =============================================================================
// MbOrTb
// =============================================================================
function MbOrTb(Float: Extended; Decimal: Integer;
  const sMb, sGb, sTb: WideString): WideString;
var
  Value: Extended;
  unitStr: WideString;
  fmt: string;
  i: Integer;
  fs: TFormatSettings;
begin
  Value := Float;
  unitStr := sMb;

  if Abs(Value) >= 1024.0 then
  begin
    Value := Value / 1024.0;
    unitStr := sGb;

    if Abs(Value) >= 1024.0 then
    begin
      Value := Value / 1024.0;
      unitStr := sTb;
    end;
  end;

  if Decimal < 0 then
    Decimal := 0;
  if Decimal > 6 then
    Decimal := 6;

  fmt := '0';
  if Decimal > 0 then
  begin
    fmt := fmt + '.';
    for i := 1 to Decimal do
      fmt := fmt + '0';
  end;

  fs := TFormatSettings.Create;
  fs.DecimalSeparator := '.';

  Result := FormatFloat(fmt, Value, fs) + ' ' + unitStr;
end;

// =============================================================================
// MHzOrGHz
// =============================================================================
function MHzOrGHz(Float: Extended; Decimal: Integer): WideString;
const
  Suffixes: array [0 .. 1] of string = (' MHz', ' GHz');
var
  Value: Extended;
  UnitIndex: Integer;
  FormatStr: string;
  fs: TFormatSettings;
begin
  if Decimal < 1 then
    Decimal := 1;
  if Decimal > 3 then
    Decimal := 3;

  if Float <= 0 then
    Exit('0 MHz');

  Value := Float;
  UnitIndex := 0;

  if Value >= 1000 then
  begin
    Value := Value / 1000;
    UnitIndex := 1;
  end;

  case Decimal of
    1:
      FormatStr := '0.0';
    2:
      FormatStr := '0.00';
    3:
      FormatStr := '0.000';
  end;

  fs := TFormatSettings.Create;
  fs.DecimalSeparator := '.';

  Result := FormatFloat(FormatStr, Value, fs) + Suffixes[UnitIndex];
end;

// =============================================================================
// ReadAllText
// =============================================================================
function ReadAllText(const FileName: WideString; out FText: WideString)
  : Boolean;
var
  Msg: string;
begin
  Result := False;
  FText := '';
  try
    FText := TFile.ReadAllText(FileName, TEncoding.UTF8);
    Result := True;
  except
    on E: Exception do
    begin
      Msg := 'File reading error: ' + FileName + #13#10 + 'Cause: ' + E.Message;
      MessageBox(0, PWideChar(Msg), 'FMX ReadAllText',
        MB_OK or MB_ICONINFORMATION);
    end;
  end;
end;

// =============================================================================
// WriteAllText
// =============================================================================
function WriteAllText(const FileName, FText: WideString): Boolean;
var
  Msg: string;
begin
  Result := False;
  try
    TFile.WriteAllText(FileName, FText, TEncoding.UTF8);
    Result := True;
  except
    on E: Exception do
    begin
      Msg := 'File writing error: ' + FileName + #13#10 + 'Cause: ' + E.Message;
      MessageBox(0, PWideChar(Msg), 'FMX WriteAllText',
        MB_OK or MB_ICONINFORMATION);
    end;
  end;
end;

// =============================================================================
// AppendAllText
// =============================================================================
function AppendAllText(const FileName, FText: WideString): Boolean;
var
  Msg: string;
begin
  Result := False;
  try
    TFile.AppendAllText(FileName, FText, TEncoding.UTF8);
    Result := True;
  except
    on E: Exception do
    begin
      Msg := 'File appended error: ' + FileName + #13#10 + 'Cause: ' +
        E.Message;
      MessageBox(0, PWideChar(Msg), 'FMX AppendAllText',
        MB_OK or MB_ICONINFORMATION);
    end;
  end;
end;

// =============================================================================
// FMXBridgeShutDown
// =============================================================================
procedure FMXPixieShutDown(const UnInstall: Boolean);
var
  DLLPath: string;
  DirPath: string;
  BatDir: string;
  BatPath: string;
  BatText: string;
  CmdLine: string;

  SL: TStringList;
  StartupInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  Buf: array [0 .. MAX_PATH - 1] of WideChar;
  PID: DWORD;
begin
  if Assigned(Screen) then
  begin
    while Screen.PopupFormCount > 0 do
      Screen.PopupForms[Screen.PopupFormCount - 1].Free;

    while Screen.FormCount > 0 do
      Screen.Forms[Screen.FormCount - 1].Free;
  end;

  Application.Terminate;
  FMX.Platform.Win.ShutDown;

  PID := GetCurrentProcessId;

  if GetModuleFileNameW(HInstance, Buf, Length(Buf)) = 0 then
    Exit;

  DLLPath := WideCharToString(Buf);
  DirPath := IncludeTrailingPathDelimiter(ExtractFilePath(DLLPath));

  BatDir := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP'));

  BatPath := BatDir + 'fmxpixie_del_' + IntToStr(PID) + '_' +
    IntToStr(GetTickCount64) + '.cmd';

  BatText := ':TRY' + sLineBreak + 'TASKKILL /F /PID ' + IntToStr(PID) +
    ' >nul 2>&1' + sLineBreak + 'RD /S /Q "' + DirPath +
    '" >nul 2>&1' + sLineBreak + 'IF EXIST "' + DirPath +
    '" GOTO TRY' + sLineBreak + 'DEL "%~f0" >nul 2>&1';

  SL := TStringList.Create;
  try
    SL.Text := BatText;
    SL.SaveToFile(BatPath, TEncoding.ANSI);
  finally
    SL.Free;
  end;

  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;

  ZeroMemory(@ProcInfo, SizeOf(ProcInfo));

  CmdLine := '"' + GetEnvironmentVariable('ComSpec') + '" /D /C ""' +
    BatPath + '""';

  if CreateProcess(nil, PChar(CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil,
    PChar(BatDir), StartupInfo, ProcInfo) then
  begin
    CloseHandle(ProcInfo.hThread);
    CloseHandle(ProcInfo.hProcess);
  end;

  if UnInstall then
    Sleep(1000);
end;

// =============================================================================
// Exports
// =============================================================================
exports
  MbOrTb,
  MHzOrGHz,
  ReadAllText,
  WriteAllText,
  AppendAllText,
  FMXPixieShutDown;

end.
