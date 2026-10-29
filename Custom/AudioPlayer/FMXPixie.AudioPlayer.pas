{*******************************************************}
{                                                       }
{                  FMXPixie.AudioPlayer                 }
{                                                       }
{              Copyright(c) 2026 Audiofeel              }
{                  All rights reserved                  }
{                                                       }
{*******************************************************}

unit FMXPixie.AudioPlayer;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs,
  System.Math, System.Generics.Collections,
  FMXAudio.Types, FMXAudio.Sources.MP3, FMXAudio.Audio.PCM;

// =============================================================================
// FPixieAudioPlayer
// =============================================================================
type
  FPixieAudioPlayer = interface(IUnknown)
    ['{C25A7AE4-56FA-4A92-B7A1-6A4E5C1D6E8B}']
    procedure Open(const FileName: WideString;
      AutoPlay, Loop: Boolean); stdcall;
    procedure Play; stdcall;
    procedure Pause; stdcall;
    procedure Stop; stdcall;
    procedure Close; stdcall;
    procedure ShutDown; stdcall;
    procedure SetVolume(Value: Single); stdcall;
    procedure Seek(PositionMs: Integer); stdcall;
    function GetState: Integer; stdcall;
    function GetPositionMs: Integer; stdcall;
    function GetDurationMs: Integer; stdcall;
    function GetOpening: Boolean; stdcall;
    function GetErrorText: WideString; stdcall;
    function GetCurrentFile: WideString; stdcall;
  end;

  TPixieAudioPlayerCommandKind = (pcOpen, pcPlay, pcPause, pcStop,
    pcClose, pcSeek);

  TPixieAudioPlayerCommand = record
    Kind: TPixieAudioPlayerCommandKind;
    FileName: string;
    Flag: Boolean;
    Loop: Boolean;
    PositionMs: Integer;
  end;

  TFPixieAudioPlayer = class(TInterfacedObject, FPixieAudioPlayer)
  private
    FLock: TCriticalSection;
    FWake: TEvent;
    FCommands: TQueue<TPixieAudioPlayerCommand>;
    FWorker: TThread;
    FShutDown: Boolean;
    FOpening: Boolean;
    FState: TPlayerState;
    FCurrentFile: string;
    FLastError: string;
    FPositionMs: Int64;
    FDurationMs: Int64;
    FVolume: Single;
    function QueueCommand(const Command: TPixieAudioPlayerCommand): Boolean;
    function PopCommand(out Command: TPixieAudioPlayerCommand): Boolean;
    function ReadVolume: Single;
    procedure PublishOpenStarted(const FileName: string);
    procedure PublishOpened(DurationUs: Int64; AutoPlay: Boolean);
    procedure PublishClosed;
    procedure PublishPosition(PositionMs: Int64);
    procedure PublishProgress(PositionMs: Int64);
    procedure PublishState(AState: TPlayerState);
    procedure PublishError(E: Exception);
    procedure SetLastError(const Value: string);
    function ReadState: TPlayerState;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Open(const FileName: WideString;
      AutoPlay, Loop: Boolean); stdcall;
    procedure Play; stdcall;
    procedure Pause; stdcall;
    procedure Stop; stdcall;
    procedure Close; stdcall;
    procedure ShutDown; stdcall;
    procedure SetVolume(Value: Single); stdcall;
    procedure Seek(PositionMs: Integer); stdcall;
    function GetState: Integer; stdcall;
    function GetPositionMs: Integer; stdcall;
    function GetDurationMs: Integer; stdcall;
    function GetOpening: Boolean; stdcall;
    function GetErrorText: WideString; stdcall;
    function GetCurrentFile: WideString; stdcall;
  end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieAudioPlayer: FPixieAudioPlayer; stdcall;

implementation

type
  TPixieMP3Worker = class(TThread)
  private
    FOwner: TFPixieAudioPlayer;
    procedure ProcessCommand(const Command: TPixieAudioPlayerCommand;
      var Stream: TFileStream; var Source: TMP3AudioSource;
      var Output: TPCMAudioOutput; var Pending: TAudioFrame;
      var HasPending, Playing, SourceEOF, OutputFlushed, LoopEnabled: Boolean;
      var SampleRate, Channels: Integer; var BaseSamplePosition: Int64);
    procedure UpdateProgress(Output: TPCMAudioOutput; SampleRate: Integer;
      BaseSamplePosition: Int64);
    procedure ResetSource(var Stream: TFileStream; var Source: TMP3AudioSource;
      var Output: TPCMAudioOutput; var Pending: TAudioFrame;
      var HasPending: Boolean);
    procedure MarkWorkerError(E: Exception; var Output: TPCMAudioOutput;
      var Playing: Boolean);
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TFPixieAudioPlayer);
  end;

// =============================================================================
// TFPixieAudioPlayer
// =============================================================================
constructor TFPixieAudioPlayer.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FWake := TEvent.Create(nil, False, False, '');
  FCommands := TQueue<TPixieAudioPlayerCommand>.Create;
  FState := TPlayerState.Closed;
  FVolume := 0.75;
  FWorker := TPixieMP3Worker.Create(Self);
  FWorker.Start;
end;

destructor TFPixieAudioPlayer.Destroy;
begin
  ShutDown;
  FCommands.Free;
  FWake.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TFPixieAudioPlayer.ShutDown;
var
  Worker: TThread;
begin
  FLock.Acquire;
  try
    if FShutDown then
      Exit;
    FShutDown := True;
    FOpening := False;
    FState := TPlayerState.Closed;
    FLastError := 'Audio player is shut down';
    FCommands.Clear;
    Worker := FWorker;
    FWorker := nil;
  finally
    FLock.Release;
  end;
  if Worker <> nil then
  begin
    Worker.Terminate;
    FWake.SetEvent;
    Worker.WaitFor;
    Worker.Free;
  end;
end;

function TFPixieAudioPlayer.QueueCommand(const Command
  : TPixieAudioPlayerCommand): Boolean;
begin
  Result := False;
  FLock.Acquire;
  try
    if FShutDown then
    begin
      FLastError := 'Audio player is shut down';
      Exit;
    end;
    FLastError := '';
    FCommands.Enqueue(Command);
    if Command.Kind = pcOpen then
    begin
      FOpening := True;
      FCurrentFile := Command.FileName;
      FPositionMs := 0;
      FDurationMs := 0;
      FState := TPlayerState.Closed;
    end;
    Result := True;
  finally
    FLock.Release;
  end;
  if Result then
    FWake.SetEvent;
end;

function TFPixieAudioPlayer.PopCommand(out Command
  : TPixieAudioPlayerCommand): Boolean;
begin
  FLock.Acquire;
  try
    Result := FCommands.Count > 0;
    if Result then
      Command := FCommands.Dequeue;
  finally
    FLock.Release;
  end;
end;

function TFPixieAudioPlayer.ReadVolume: Single;
begin
  FLock.Acquire;
  try
    Result := FVolume;
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.PublishOpenStarted(const FileName: string);
begin
  FLock.Acquire;
  try
    FCurrentFile := FileName;
    FOpening := True;
    FState := TPlayerState.Closed;
    FPositionMs := 0;
    FDurationMs := 0;
    FLastError := '';
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.PublishOpened(DurationUs: Int64;
  AutoPlay: Boolean);
begin
  FLock.Acquire;
  try
    FOpening := False;
    FDurationMs := DurationUs div 1000;
    FPositionMs := 0;
    if AutoPlay then
      FState := TPlayerState.Playing
    else
      FState := TPlayerState.Ready;
    FLastError := '';
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.PublishClosed;
begin
  FLock.Acquire;
  try
    FOpening := False;
    FState := TPlayerState.Closed;
    FCurrentFile := '';
    FPositionMs := 0;
    FDurationMs := 0;
    FLastError := '';
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.PublishPosition(PositionMs: Int64);
begin
  FLock.Acquire;
  try
    if PositionMs < 0 then
      PositionMs := 0;
    if (FDurationMs > 0) and (PositionMs > FDurationMs) then
      PositionMs := FDurationMs;
    FPositionMs := PositionMs;
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.PublishProgress(PositionMs: Int64);
begin
  PublishPosition(PositionMs);
end;

procedure TFPixieAudioPlayer.PublishState(AState: TPlayerState);
begin
  FLock.Acquire;
  try
    FState := AState;
    FOpening := False;
    if AState = TPlayerState.Ended then
      FPositionMs := FDurationMs;
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.PublishError(E: Exception);
begin
  FLock.Acquire;
  try
    FOpening := False;
    if E <> nil then
      FLastError := E.ClassName + ': ' + E.Message;
    FState := TPlayerState.Failed;
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.SetLastError(const Value: string);
begin
  FLock.Acquire;
  try
    FLastError := Value;
  finally
    FLock.Release;
  end;
end;

function TFPixieAudioPlayer.ReadState: TPlayerState;
begin
  FLock.Acquire;
  try
    Result := FState;
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.Open(const FileName: WideString;
  AutoPlay, Loop: Boolean);
var
  Command: TPixieAudioPlayerCommand;
begin
  if Trim(string(FileName)) = '' then
  begin
    SetLastError('MP3 file name is empty');
    Exit;
  end;
  Command := Default (TPixieAudioPlayerCommand);
  Command.Kind := pcOpen;
  Command.FileName := string(FileName);
  Command.Flag := AutoPlay;
  Command.Loop := Loop;
  QueueCommand(Command);
end;

procedure TFPixieAudioPlayer.Play;
var
  Command: TPixieAudioPlayerCommand;
begin
  Command := Default (TPixieAudioPlayerCommand);
  Command.Kind := pcPlay;
  QueueCommand(Command);
end;

procedure TFPixieAudioPlayer.Pause;
var
  Command: TPixieAudioPlayerCommand;
begin
  Command := Default (TPixieAudioPlayerCommand);
  Command.Kind := pcPause;
  QueueCommand(Command);
end;

procedure TFPixieAudioPlayer.Stop;
var
  Command: TPixieAudioPlayerCommand;
begin
  Command := Default (TPixieAudioPlayerCommand);
  Command.Kind := pcStop;
  QueueCommand(Command);
end;

procedure TFPixieAudioPlayer.Close;
var
  Command: TPixieAudioPlayerCommand;
begin
  Command := Default (TPixieAudioPlayerCommand);
  Command.Kind := pcClose;
  QueueCommand(Command);
end;

procedure TFPixieAudioPlayer.SetVolume(Value: Single);
begin
  FLock.Acquire;
  try
    if FShutDown then
    begin
      FLastError := 'Audio player is shut down';
      Exit;
    end;
    if IsNan(Value) or IsInfinite(Value) or (Value < 0) or (Value > 1) then
    begin
      FLastError := 'Volume must be in range 0..1';
      Exit;
    end;
    FVolume := Value;
    FLastError := '';
  finally
    FLock.Release;
  end;
end;

procedure TFPixieAudioPlayer.Seek(PositionMs: Integer);
var
  Command: TPixieAudioPlayerCommand;
begin
  if PositionMs < 0 then
  begin
    SetLastError('Seek position cannot be negative');
    Exit;
  end;
  Command := Default (TPixieAudioPlayerCommand);
  Command.Kind := pcSeek;
  Command.PositionMs := PositionMs;
  QueueCommand(Command);
end;

function TFPixieAudioPlayer.GetState: Integer;
begin
  FLock.Acquire;
  try
    Result := Ord(FState);
  finally
    FLock.Release;
  end;
end;

function TFPixieAudioPlayer.GetPositionMs: Integer;
begin
  FLock.Acquire;
  try
    Result := Integer(EnsureRange(FPositionMs, Int64(0), Int64(High(Integer))));
  finally
    FLock.Release;
  end;
end;

function TFPixieAudioPlayer.GetDurationMs: Integer;
begin
  FLock.Acquire;
  try
    Result := Integer(EnsureRange(FDurationMs, Int64(0), Int64(High(Integer))));
  finally
    FLock.Release;
  end;
end;

function TFPixieAudioPlayer.GetOpening: Boolean;
begin
  FLock.Acquire;
  try
    Result := FOpening;
  finally
    FLock.Release;
  end;
end;

function TFPixieAudioPlayer.GetErrorText: WideString;
begin
  FLock.Acquire;
  try
    Result := FLastError;
  finally
    FLock.Release;
  end;
end;

function TFPixieAudioPlayer.GetCurrentFile: WideString;
begin
  FLock.Acquire;
  try
    Result := FCurrentFile;
  finally
    FLock.Release;
  end;
end;

// =============================================================================
// TPixieMP3Worker
// =============================================================================
constructor TPixieMP3Worker.Create(AOwner: TFPixieAudioPlayer);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FOwner := AOwner;
end;

procedure TPixieMP3Worker.ResetSource(var Stream: TFileStream;
  var Source: TMP3AudioSource; var Output: TPCMAudioOutput;
  var Pending: TAudioFrame; var HasPending: Boolean);
begin
  FreeAndNil(Output);
  FreeAndNil(Source);
  FreeAndNil(Stream);
  Pending := Default (TAudioFrame);
  HasPending := False;
end;

procedure TPixieMP3Worker.UpdateProgress(Output: TPCMAudioOutput;
  SampleRate: Integer; BaseSamplePosition: Int64);
var
  Played: Int64;
begin
  if (Output = nil) or (SampleRate <= 0) then
    Exit;
  if Output.PlayedFrames(Played) then
    FOwner.PublishProgress((BaseSamplePosition + Played) * 1000 div SampleRate);
end;

procedure TPixieMP3Worker.MarkWorkerError(E: Exception;
  var Output: TPCMAudioOutput; var Playing: Boolean);
begin
  Playing := False;
  FreeAndNil(Output);
  FOwner.PublishError(E);
end;

procedure TPixieMP3Worker.ProcessCommand(const Command
  : TPixieAudioPlayerCommand; var Stream: TFileStream;
  var Source: TMP3AudioSource; var Output: TPCMAudioOutput;
  var Pending: TAudioFrame; var HasPending, Playing, SourceEOF, OutputFlushed,
  LoopEnabled: Boolean; var SampleRate, Channels: Integer;
  var BaseSamplePosition: Int64);
var
  AutoPlay: Boolean;
  WasPlaying: Boolean;
begin
  case Command.Kind of
    pcOpen:
      begin
        Playing := False;
        SourceEOF := False;
        OutputFlushed := False;
        LoopEnabled := Command.Loop;
        ResetSource(Stream, Source, Output, Pending, HasPending);
        SampleRate := 0;
        Channels := 0;
        BaseSamplePosition := 0;
        FOwner.PublishOpenStarted(Command.FileName);
        try
          Stream := TFileStream.Create(Command.FileName, fmOpenRead or
            fmShareDenyWrite);
          Source := TMP3AudioSource.Create(Stream);
          if not Source.ReadFrame(Pending) then
            raise EPlayerFormat.Create
              ('The MP3 contains no decoded audio frames');
          HasPending := True;
          SampleRate := Pending.SampleRate;
          Channels := Pending.Channels;
          BaseSamplePosition := Pending.SamplePosition;
          if (SampleRate <= 0) or not(Channels in [1, 2]) then
            raise EPlayerFormat.Create('Unsupported MP3 PCM format');
          AutoPlay := Command.Flag;
          Playing := AutoPlay;
          FOwner.PublishOpened(Source.GetDuration, AutoPlay);
        except
          on E: Exception do
          begin
            ResetSource(Stream, Source, Output, Pending, HasPending);
            Playing := False;
            SourceEOF := False;
            LoopEnabled := False;
            FOwner.PublishError(E);
          end;
        end;
      end;

    pcPlay:
      begin
        if Source = nil then
        begin
          FOwner.SetLastError('Open an MP3 file before calling Play');
          Exit;
        end;
        if SourceEOF then
        begin
          FreeAndNil(Output);
          Source.Seek(0);
          if not Source.ReadFrame(Pending) then
            raise EPlayerFormat.Create('The MP3 contains no audio frames');
          HasPending := True;
          BaseSamplePosition := Pending.SamplePosition;
          SourceEOF := False;
          OutputFlushed := False;
        end;
        Playing := True;
        if Output <> nil then
          Output.SetPaused(False);
        FOwner.PublishState(TPlayerState.Playing);
      end;

    pcPause:
      begin
        if Playing then
        begin
          UpdateProgress(Output, SampleRate, BaseSamplePosition);
          Playing := False;
          if Output <> nil then
            Output.SetPaused(True);
          FOwner.PublishState(TPlayerState.Paused);
        end;
      end;

    pcStop:
      begin
        if Source <> nil then
        begin
          Playing := False;
          FreeAndNil(Output);
          Source.Seek(0);
          if not Source.ReadFrame(Pending) then
            raise EPlayerFormat.Create('The MP3 contains no audio frames');
          HasPending := True;
          BaseSamplePosition := Pending.SamplePosition;
          SourceEOF := False;
          OutputFlushed := False;
          FOwner.PublishPosition(0);
          FOwner.PublishState(TPlayerState.Ready);
        end;
      end;

    pcClose:
      begin
        Playing := False;
        SourceEOF := False;
        OutputFlushed := False;
        LoopEnabled := False;
        ResetSource(Stream, Source, Output, Pending, HasPending);
        SampleRate := 0;
        Channels := 0;
        BaseSamplePosition := 0;
        FOwner.PublishClosed;
      end;

    pcSeek:
      begin
        if Source = nil then
        begin
          FOwner.SetLastError('Open an MP3 file before seeking');
          Exit;
        end;
        WasPlaying := Playing;
        FreeAndNil(Output);
        Source.Seek(Int64(Command.PositionMs) * 1000);
        HasPending := Source.ReadFrame(Pending);
        SourceEOF := not HasPending;
        OutputFlushed := False;
        if HasPending then
          BaseSamplePosition := Pending.SamplePosition
        else if SampleRate > 0 then
          BaseSamplePosition := Int64(Command.PositionMs) * SampleRate div 1000;
        if WasPlaying then
          Playing := True;
        if HasPending then
          FOwner.PublishPosition(BaseSamplePosition * 1000 div Max(1,
            SampleRate))
        else
          FOwner.PublishPosition(Source.GetDuration div 1000);
        if WasPlaying then
          FOwner.PublishState(TPlayerState.Playing)
        else if FOwner.ReadState <> TPlayerState.Paused then
          FOwner.PublishState(TPlayerState.Ready);
      end;
  end;
end;

procedure TPixieMP3Worker.Execute;
var
  Stream: TFileStream;
  Source: TMP3AudioSource;
  Output: TPCMAudioOutput;
  Pending: TAudioFrame;
  HasPending, Playing, SourceEOF, OutputFlushed, LoopEnabled: Boolean;
  SampleRate, Channels: Integer;
  BaseSamplePosition: Int64;
  Command: TPixieAudioPlayerCommand;
  I: Integer;
  Volume: Single;
begin
  Stream := nil;
  Source := nil;
  Output := nil;
  Pending := Default (TAudioFrame);
  HasPending := False;
  Playing := False;
  SourceEOF := False;
  OutputFlushed := False;
  LoopEnabled := False;
  SampleRate := 0;
  Channels := 0;
  BaseSamplePosition := 0;
  try
    while not Terminated do
    begin
      while FOwner.PopCommand(Command) do
      begin
        try
          ProcessCommand(Command, Stream, Source, Output, Pending, HasPending,
            Playing, SourceEOF, OutputFlushed, LoopEnabled, SampleRate,
            Channels, BaseSamplePosition);
        except
          on E: Exception do
            MarkWorkerError(E, Output, Playing);
        end;
        if Terminated then
          Break;
      end;
      if Terminated then
        Break;

      if Output <> nil then
        UpdateProgress(Output, SampleRate, BaseSamplePosition);

      if Playing and (Source <> nil) then
      begin
        try
          if SourceEOF then
          begin
            if Output <> nil then
            begin
              if not OutputFlushed then
              begin
                Output.Flush;
                OutputFlushed := True;
              end;
              if Output.BufferedFrames = 0 then
              begin
                UpdateProgress(Output, SampleRate, BaseSamplePosition);
                FreeAndNil(Output);
                if LoopEnabled then
                begin
                  Source.Seek(0);
                  if not Source.ReadFrame(Pending) then
                    raise EPlayerFormat.Create
                      ('The MP3 contains no audio frames');
                  HasPending := True;
                  BaseSamplePosition := Pending.SamplePosition;
                  SourceEOF := False;
                  OutputFlushed := False;
                  FOwner.PublishPosition(0);
                  FOwner.PublishState(TPlayerState.Playing);
                end
                else
                begin
                  Playing := False;
                  FOwner.PublishState(TPlayerState.Ended);
                end;
              end;
            end
            else
            begin
              if LoopEnabled then
              begin
                Source.Seek(0);
                if not Source.ReadFrame(Pending) then
                  raise EPlayerFormat.Create
                    ('The MP3 contains no audio frames');
                HasPending := True;
                BaseSamplePosition := Pending.SamplePosition;
                SourceEOF := False;
                OutputFlushed := False;
                FOwner.PublishPosition(0);
                FOwner.PublishState(TPlayerState.Playing);
              end
              else
              begin
                Playing := False;
                FOwner.PublishState(TPlayerState.Ended);
              end;
            end;
          end
          else
          begin
            if Output = nil then
            begin
              Output := TPCMAudioOutput.Create;
              Output.Open(SampleRate, Channels);
            end;

            if Output.BufferedFrames > SampleRate div 3 then
            begin
              FOwner.FWake.WaitFor(5);
              Continue;
            end;

            if not HasPending then
            begin
              if Source.ReadFrame(Pending) then
                HasPending := True
              else
              begin
                SourceEOF := True;
                if not OutputFlushed then
                begin
                  Output.Flush;
                  OutputFlushed := True;
                end;
              end;
            end;

            if HasPending then
            begin
              if (Pending.SampleRate <> SampleRate) or
                (Pending.Channels <> Channels) then
                raise EPlayerFormat.Create
                  ('The MP3 changed its PCM format during playback');
              Volume := FOwner.ReadVolume;
              if Volume < 1 then
                for I := 0 to High(Pending.Samples) do
                  Pending.Samples[I] :=
                    SmallInt(Round(Pending.Samples[I] * Volume));
              Output.Write(Pending);
              HasPending := False;
            end;
          end;
        except
          on E: Exception do
            MarkWorkerError(E, Output, Playing);
        end;
      end;
      FOwner.FWake.WaitFor(5);
    end;
  finally
    ResetSource(Stream, Source, Output, Pending, HasPending);
  end;
end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieAudioPlayer: FPixieAudioPlayer; stdcall;
begin
  Result := TFPixieAudioPlayer.Create;
end;

exports InitPixieAudioPlayer;

end.
