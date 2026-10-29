{*******************************************************}
{                                                       }
{                     FMXPixie.Utils                    }
{                                                       }
{              Copyright(c) 2026 Audiofeel              }
{                  All rights reserved                  }
{                                                       }
{*******************************************************}

unit FMXPixie.Utils;

interface

uses
  System.UITypes, System.Classes;

// =============================================================================
// Exports
// =============================================================================
procedure FMXPixieShutDown(const UnInstall: Boolean); stdcall;

implementation

uses
  System.SysUtils,
  Winapi.Windows,
  FMX.Forms, FMX.Platform.Win;

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
  FMXPixieShutDown;

end.
