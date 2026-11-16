unit FMXPixie.RenderCache;

interface

uses
  System.SysUtils,
  System.Types,
  FMX.Graphics;

type
  TRenderCacheProc = procedure(ACanvas: TCanvas;
    const ASize: TSizeF) of object;

  TRenderCache = class
  private
    FBitmap: TBitmap;
    FDirty: Boolean;
    FRendering: Boolean;
    FCacheWidth: Single;
    FCacheHeight: Single;
    FCacheScale: Single;
    FRebuildCount: UInt64;
    function NeedsRebuild(const ASize: TSizeF;
      AScale: Single): Boolean;
    function Rebuild(ACanvas: TCanvas; const ASize: TSizeF;
      AScale: Single; const ARender: TRenderCacheProc): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Invalidate;
    procedure Draw(ACanvas: TCanvas; const ASize: TSizeF;
      const AOpacity: Single; const ARender: TRenderCacheProc);

    property Dirty: Boolean read FDirty;
    property RebuildCount: UInt64 read FRebuildCount;
  end;

implementation

uses
  System.Math;

constructor TRenderCache.Create;
begin
  inherited Create;
  FBitmap := nil;
  FDirty := True;
  FRendering := False;
  FCacheWidth := 0;
  FCacheHeight := 0;
  FCacheScale := 0;
  FRebuildCount := 0;
end;

destructor TRenderCache.Destroy;
begin
  FreeAndNil(FBitmap);
  inherited Destroy;
end;

procedure TRenderCache.Invalidate;
begin
  FDirty := True;
end;

function TRenderCache.NeedsRebuild(const ASize: TSizeF;
  AScale: Single): Boolean;
begin
  Result := FDirty or (FBitmap = nil) or
    (Abs(FCacheWidth - ASize.Width) > 0.001) or
    (Abs(FCacheHeight - ASize.Height) > 0.001) or
    (Abs(FCacheScale - AScale) > 0.001);
end;

function TRenderCache.Rebuild(ACanvas: TCanvas; const ASize: TSizeF;
  AScale: Single; const ARender: TRenderCacheProc): Boolean;
var
  PixelWidth: Integer;
  PixelHeight: Integer;
  BitmapCanvas: TCanvas;
  SceneStarted: Boolean;
begin
  Result := False;

  if FRendering then
    Exit;

  FRendering := True;
  try
    try
      if FBitmap = nil then
        FBitmap := TBitmap.Create;

      PixelWidth := Max(1, Ceil(ASize.Width * AScale));
      PixelHeight := Max(1, Ceil(ASize.Height * AScale));

      if FBitmap.CanvasQuality <> ACanvas.Quality then
        FBitmap.CanvasQuality := ACanvas.Quality;

      // Bitmap dimensions are physical pixels. BitmapScale keeps its logical
      // size equal to ASize and gives its Canvas the matching HiDPI scale.
      if (FBitmap.Width <> PixelWidth) or
         (FBitmap.Height <> PixelHeight) or
         (Abs(FBitmap.BitmapScale - AScale) > 0.001) then
      begin
        FBitmap.BitmapScale := AScale;
        FBitmap.SetSize(PixelWidth, PixelHeight);
      end;

      // The HTML view background is transparent. Clear previous pixels before
      // a full redraw so transparent areas cannot retain stale content.
      FBitmap.Clear(0);

      BitmapCanvas := FBitmap.Canvas;
      if BitmapCanvas = nil then
        Exit;

      SceneStarted := BitmapCanvas.BeginScene;
      if not SceneStarted then
        Exit;

      try
        // Clear before rendering, not after: invalidations raised from inside
        // HandlePaint must remain pending for the next Paint.
        FDirty := False;
        ARender(BitmapCanvas, ASize);
      finally
        BitmapCanvas.EndScene;
      end;

      FCacheWidth := ASize.Width;
      FCacheHeight := ASize.Height;
      FCacheScale := AScale;
      Inc(FRebuildCount);
      Result := True;
    except
      FDirty := True;
      raise;
    end;
  finally
    // Do not clear FDirty here. An invalidation raised by ARender is valid
    // and must cause another rebuild.
    FRendering := False;
  end;
end;

procedure TRenderCache.Draw(ACanvas: TCanvas; const ASize: TSizeF;
  const AOpacity: Single; const ARender: TRenderCacheProc);
var
  Scale: Single;
  SourceRect: TRectF;
  DestRect: TRectF;
begin
  if (ACanvas = nil) or not Assigned(ARender) then
    Exit;

  if (ASize.Width <= 0) or (ASize.Height <= 0) then
    Exit;

  Scale := ACanvas.Scale;
  if Scale <= 0 then
    Scale := 1.0;

  // Avoid recursively rebuilding the same cache.
  if FRendering then
  begin
    ARender(ACanvas, ASize);
    Exit;
  end;

  if NeedsRebuild(ASize, Scale) then
  begin
    if not Rebuild(ACanvas, ASize, Scale, ARender) then
    begin
      // Some FMX canvas backends may refuse an off-screen scene. Keep the
      // cache dirty and render this frame directly instead of showing stale
      // cached pixels.
      FDirty := True;
      ARender(ACanvas, ASize);
      Exit;
    end;
  end;

  if (FBitmap = nil) or (FBitmap.Width <= 0) or
     (FBitmap.Height <= 0) then
    Exit;

  SourceRect := TRectF.Create(0, 0, FBitmap.Width, FBitmap.Height);
  DestRect := TRectF.Create(0, 0, ASize.Width, ASize.Height);
  ACanvas.DrawBitmap(FBitmap, SourceRect, DestRect, AOpacity, False);
end;

end.
