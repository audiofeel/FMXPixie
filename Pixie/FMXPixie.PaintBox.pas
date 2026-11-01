
unit FMXPixie.PaintBox;

interface

uses
  System.Classes, System.SysUtils, System.UITypes,
  FMX.Controls, FMX.Types,
  Pixie.Types, Pixie.WebColor, Pixie.DrawingCanvas, Pixie.PaintBox.FMX;

// =============================================================================
// FPixiePaintBox
// =============================================================================
type
  TPixiePaintBoxEvent = procedure(Sender: TObject) of object;

  FPixiePaintBox = interface(IUnknown)
    ['{7D984A5E-4B46-49DE-80C4-D0A7DD34FE34}']
    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single); stdcall;
    procedure Position(X, Y: Single); stdcall;
    procedure Align(Al: TAlignLayout); stdcall;
    procedure Margins(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure Padding(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure SetHint(const FText: WideString); stdcall;
    procedure SetClipParent(FValue: Boolean); stdcall;
    procedure SetClipChildren(FValue: Boolean); stdcall;
    procedure BringToFront; stdcall;
    procedure SendToBack; stdcall;
    procedure FillBackground(FValue: Boolean); stdcall;
    procedure BackgroundColor(FColor: TAlphaColor); stdcall;
    procedure PenColor(FColor: TAlphaColor); stdcall;
    procedure PenWidth(FWidth: Single); stdcall;
    procedure PenStyle(FStyle: TPixiePenStyle); stdcall;
    procedure BrushColor(FColor: TAlphaColor); stdcall;
    procedure BrushStyle(FStyle: TPixieBrushStyle); stdcall;
    procedure FontFamily(const FFamily: WideString); stdcall;
    procedure FontSize(FSize: Single); stdcall;
    procedure FontColor(FColor: TAlphaColor); stdcall;
    procedure FontStyle(FStyle: TPixieDrawingFontStyles); stdcall;
    procedure Line(X1, Y1, X2, Y2: Single); stdcall;
    procedure Rectangle(X, Y, W, H: Single); stdcall;
    procedure FillRect(X, Y, W, H: Single); stdcall;
    procedure RoundRect(X, Y, W, H, Radius: Single); stdcall;
    procedure Ellipse(X, Y, W, H: Single); stdcall;
    procedure Circle(CX, CY, Radius: Single); stdcall;
    procedure Arc(X, Y, W, H, StartAngle, SweepAngle: Single); stdcall;
    procedure TextOut(X, Y: Single; const FText: WideString); stdcall;
    procedure TextRect(X, Y, W, H: Single; const FText: WideString;
      FHorzAlign: TPixieTextAlign; FVertAlign: TPixieVerticalAlign); stdcall;
    procedure SaveState; stdcall;
    procedure RestoreState; stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    procedure Repaint; stdcall;
    function TextWidth(const FText: WideString): Single; stdcall;
    function TextHeight: Single; stdcall;
    function GetFillBackground: Boolean; stdcall;
    function GetBackgroundColor: TAlphaColor; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnPaint(Event: TPixiePaintBoxEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

  TFPixiePaintBox = class(TInterfacedObject, FPixiePaintBox)
  private
    ControlPaintBox: TPixiePaintBox;
    FOnPaint: TPixiePaintBoxEvent;
    FActiveCanvas: TPixieDrawingCanvas;

    FFillBackground: Boolean;
    FBackgroundColor: TAlphaColor;

    FPenColor: TAlphaColor;
    FPenWidth: Single;
    FPenStyle: TPixiePenStyle;
    FBrushColor: TAlphaColor;
    FBrushStyle: TPixieBrushStyle;
    FFontFamily: string;
    FFontSize: Single;
    FFontColor: TAlphaColor;
    FFontStyle: TPixieDrawingFontStyles;

    procedure ControlPaint(Sender: TObject; ACanvas: TPixieDrawingCanvas);
    procedure ApplyDrawingState(ACanvas: TPixieDrawingCanvas);
  public
    constructor Create;
    destructor Destroy; override;

    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single); stdcall;
    procedure Position(X, Y: Single); stdcall;
    procedure Align(Al: TAlignLayout); stdcall;
    procedure Margins(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure Padding(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure SetHint(const FText: WideString); stdcall;
    procedure SetClipParent(FValue: Boolean); stdcall;
    procedure SetClipChildren(FValue: Boolean); stdcall;
    procedure BringToFront; stdcall;
    procedure SendToBack; stdcall;
    procedure FillBackground(FValue: Boolean); stdcall;
    procedure BackgroundColor(FColor: TAlphaColor); stdcall;
    procedure PenColor(FColor: TAlphaColor); stdcall;
    procedure PenWidth(FWidth: Single); stdcall;
    procedure PenStyle(FStyle: TPixiePenStyle); stdcall;
    procedure BrushColor(FColor: TAlphaColor); stdcall;
    procedure BrushStyle(FStyle: TPixieBrushStyle); stdcall;
    procedure FontFamily(const FFamily: WideString); stdcall;
    procedure FontSize(FSize: Single); stdcall;
    procedure FontColor(FColor: TAlphaColor); stdcall;
    procedure FontStyle(FStyle: TPixieDrawingFontStyles); stdcall;
    procedure Line(X1, Y1, X2, Y2: Single); stdcall;
    procedure Rectangle(X, Y, W, H: Single); stdcall;
    procedure FillRect(X, Y, W, H: Single); stdcall;
    procedure RoundRect(X, Y, W, H, Radius: Single); stdcall;
    procedure Ellipse(X, Y, W, H: Single); stdcall;
    procedure Circle(CX, CY, Radius: Single); stdcall;
    procedure Arc(X, Y, W, H, StartAngle, SweepAngle: Single); stdcall;
    procedure TextOut(X, Y: Single; const FText: WideString); stdcall;
    procedure TextRect(X, Y, W, H: Single; const FText: WideString;
      FHorzAlign: TPixieTextAlign; FVertAlign: TPixieVerticalAlign); stdcall;
    procedure SaveState; stdcall;
    procedure RestoreState; stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    procedure Repaint; stdcall;
    function TextWidth(const FText: WideString): Single; stdcall;
    function TextHeight: Single; stdcall;
    function GetFillBackground: Boolean; stdcall;
    function GetBackgroundColor: TAlphaColor; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnPaint(Event: TPixiePaintBoxEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

// =============================================================================
// Exports
// =============================================================================
function InitPixiePaintBox: FPixiePaintBox; stdcall;

implementation

// =============================================================================
// Color conversion
// =============================================================================
function AlphaColorToWebColor(Value: TAlphaColor): TPixieWebColor;
begin
  Result := TPixieWebColor.Create(
    Byte((Cardinal(Value) shr 16) and $FF),
    Byte((Cardinal(Value) shr 8) and $FF),
    Byte(Cardinal(Value) and $FF),
    Byte((Cardinal(Value) shr 24) and $FF));
end;

function WebColorToAlphaColor(const Value: TPixieWebColor): TAlphaColor;
begin
  Result := (Cardinal(Value.Alpha) shl 24) or
    (Cardinal(Value.Red) shl 16) or
    (Cardinal(Value.Green) shl 8) or Cardinal(Value.Blue);
end;

// =============================================================================
// FPixiePaintBox
// =============================================================================
constructor TFPixiePaintBox.Create;
begin
  inherited Create;

  FFillBackground := True;
  FBackgroundColor := $FFFFFFFF;

  FPenColor := $FF000000;
  FPenWidth := 1.0;
  FPenStyle := psSolid;

  FBrushColor := $FFFFFFFF;
  FBrushStyle := bsSolid;

  FFontFamily := 'sans-serif';
  FFontSize := 13.0;
  FFontColor := $FF000000;
  FFontStyle := [];
end;

destructor TFPixiePaintBox.Destroy;
begin
  FreeAndNil(ControlPaintBox);
  FActiveCanvas := nil;
  FOnPaint := nil;

  inherited Destroy;
end;

procedure TFPixiePaintBox.FCreate(FParent: TFmxObject);
begin
  ControlPaintBox := TPixiePaintBox.Create(nil);
  ControlPaintBox.Parent := TFmxObject(FParent);
  ControlPaintBox.OnPaint := ControlPaint;
  ControlPaintBox.FillBackground := FFillBackground;
  ControlPaintBox.BackgroundColor := AlphaColorToWebColor(FBackgroundColor);
end;

procedure TFPixiePaintBox.ControlPaint(Sender: TObject;
  ACanvas: TPixieDrawingCanvas);
var
  Callback: TPixiePaintBoxEvent;
begin
  FActiveCanvas := ACanvas;
  try
    ApplyDrawingState(ACanvas);

    Callback := FOnPaint;
    if Assigned(Callback) then
      Callback(Sender);
  finally
    FActiveCanvas := nil;
  end;
end;

procedure TFPixiePaintBox.ApplyDrawingState(ACanvas: TPixieDrawingCanvas);
begin
  ACanvas.Pen.Color := AlphaColorToWebColor(FPenColor);
  ACanvas.Pen.Width := FPenWidth;
  ACanvas.Pen.Style := FPenStyle;

  ACanvas.Brush.Color := AlphaColorToWebColor(FBrushColor);
  ACanvas.Brush.Style := FBrushStyle;

  ACanvas.Font.Family := FFontFamily;
  ACanvas.Font.Size := FFontSize;
  ACanvas.Font.Color := AlphaColorToWebColor(FFontColor);
  ACanvas.Font.Style := FFontStyle;
end;

procedure TFPixiePaintBox.Left(FLeft: Single);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Position.X := FLeft;
end;

procedure TFPixiePaintBox.Top(FTop: Single);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Position.Y := FTop;
end;

procedure TFPixiePaintBox.Width(FWidth: Single);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Size.Width := FWidth;
end;

procedure TFPixiePaintBox.Height(FHeight: Single);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Size.Height := FHeight;
end;

procedure TFPixiePaintBox.SetBounds(FLeft, FTop, FWidth, FHeight: Single);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TFPixiePaintBox.Position(X, Y: Single);
begin
  if ControlPaintBox = nil then
    Exit;

  ControlPaintBox.Position.X := X;
  ControlPaintBox.Position.Y := Y;
end;

procedure TFPixiePaintBox.Align(Al: TAlignLayout);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Align := TAlignLayout(Al);
end;

procedure TFPixiePaintBox.Margins(FLeft, FTop, FRight, FBottom: Single);
begin
  if ControlPaintBox = nil then
    Exit;

  with ControlPaintBox.Margins do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixiePaintBox.Padding(FLeft, FTop, FRight, FBottom: Single);
begin
  if ControlPaintBox = nil then
    Exit;

  with ControlPaintBox.Padding do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixiePaintBox.SetHint(const FText: WideString);
begin
  if ControlPaintBox = nil then
    Exit;

  ControlPaintBox.ShowHint := True;
  ControlPaintBox.Hint := string(FText);
end;

procedure TFPixiePaintBox.SetClipParent(FValue: Boolean);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.ClipParent := FValue;
end;

procedure TFPixiePaintBox.SetClipChildren(FValue: Boolean);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.ClipChildren := FValue;
end;

procedure TFPixiePaintBox.BringToFront;
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.BringToFront;
end;

procedure TFPixiePaintBox.SendToBack;
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.SendToBack;
end;

procedure TFPixiePaintBox.FillBackground(FValue: Boolean);
begin
  FFillBackground := FValue;

  if ControlPaintBox <> nil then
    ControlPaintBox.FillBackground := FValue;
end;

procedure TFPixiePaintBox.BackgroundColor(FColor: TAlphaColor);
begin
  FBackgroundColor := FColor;

  if ControlPaintBox <> nil then
    ControlPaintBox.BackgroundColor := AlphaColorToWebColor(FColor);
end;

procedure TFPixiePaintBox.PenColor(FColor: TAlphaColor);
begin
  FPenColor := FColor;

  if FActiveCanvas <> nil then
    FActiveCanvas.Pen.Color := AlphaColorToWebColor(FColor);
end;

procedure TFPixiePaintBox.PenWidth(FWidth: Single);
begin
  FPenWidth := FWidth;

  if FActiveCanvas <> nil then
    FActiveCanvas.Pen.Width := FWidth;
end;

procedure TFPixiePaintBox.PenStyle(FStyle: TPixiePenStyle);
begin
  FPenStyle := FStyle;

  if FActiveCanvas <> nil then
    FActiveCanvas.Pen.Style := FStyle;
end;

procedure TFPixiePaintBox.BrushColor(FColor: TAlphaColor);
begin
  FBrushColor := FColor;

  if FActiveCanvas <> nil then
    FActiveCanvas.Brush.Color := AlphaColorToWebColor(FColor);
end;

procedure TFPixiePaintBox.BrushStyle(FStyle: TPixieBrushStyle);
begin
  FBrushStyle := FStyle;

  if FActiveCanvas <> nil then
    FActiveCanvas.Brush.Style := FStyle;
end;

procedure TFPixiePaintBox.FontFamily(const FFamily: WideString);
begin
  FFontFamily := string(FFamily);

  if FActiveCanvas <> nil then
    FActiveCanvas.Font.Family := FFontFamily;
end;

procedure TFPixiePaintBox.FontSize(FSize: Single);
begin
  FFontSize := FSize;

  if FActiveCanvas <> nil then
    FActiveCanvas.Font.Size := FSize;
end;

procedure TFPixiePaintBox.FontColor(FColor: TAlphaColor);
begin
  FFontColor := FColor;

  if FActiveCanvas <> nil then
    FActiveCanvas.Font.Color := AlphaColorToWebColor(FColor);
end;

procedure TFPixiePaintBox.FontStyle(FStyle: TPixieDrawingFontStyles);
begin
  FFontStyle := FStyle;

  if FActiveCanvas <> nil then
    FActiveCanvas.Font.Style := FStyle;
end;

procedure TFPixiePaintBox.Line(X1, Y1, X2, Y2: Single);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.Line(X1, Y1, X2, Y2);
end;

procedure TFPixiePaintBox.Rectangle(X, Y, W, H: Single);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.Rectangle(X, Y, W, H);
end;

procedure TFPixiePaintBox.FillRect(X, Y, W, H: Single);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.FillRect(X, Y, W, H);
end;

procedure TFPixiePaintBox.RoundRect(X, Y, W, H, Radius: Single);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.RoundRect(X, Y, W, H, Radius);
end;

procedure TFPixiePaintBox.Ellipse(X, Y, W, H: Single);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.Ellipse(X, Y, W, H);
end;

procedure TFPixiePaintBox.Circle(CX, CY, Radius: Single);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.Circle(CX, CY, Radius);
end;

procedure TFPixiePaintBox.Arc(X, Y, W, H, StartAngle, SweepAngle: Single);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.Arc(X, Y, W, H, StartAngle, SweepAngle);
end;

procedure TFPixiePaintBox.TextOut(X, Y: Single; const FText: WideString);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.TextOut(X, Y, string(FText));
end;

procedure TFPixiePaintBox.TextRect(X, Y, W, H: Single; const FText: WideString;
  FHorzAlign: TPixieTextAlign; FVertAlign: TPixieVerticalAlign);
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.TextRect(X, Y, W, H, string(FText), FHorzAlign, FVertAlign);
end;

procedure TFPixiePaintBox.SaveState;
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.SaveState;
end;

procedure TFPixiePaintBox.RestoreState;
begin
  if FActiveCanvas <> nil then
    FActiveCanvas.RestoreState;
end;

procedure TFPixiePaintBox.Opacity(FOpacity: Single);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Opacity := FOpacity;
end;

procedure TFPixiePaintBox.Enabled(FEnabled: Boolean);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Enabled := FEnabled;
end;

procedure TFPixiePaintBox.Visible(FVisible: Boolean);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Visible := FVisible;
end;

procedure TFPixiePaintBox.HitTest(FEnabled: Boolean);
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.HitTest := FEnabled;
end;

procedure TFPixiePaintBox.Repaint;
begin
  if ControlPaintBox <> nil then
    ControlPaintBox.Repaint;
end;

function TFPixiePaintBox.TextWidth(const FText: WideString): Single;
begin
  Result := 0;

  if FActiveCanvas <> nil then
    Result := FActiveCanvas.TextWidth(string(FText));
end;

function TFPixiePaintBox.TextHeight: Single;
begin
  Result := 0;

  if FActiveCanvas <> nil then
    Result := FActiveCanvas.TextHeight;
end;

function TFPixiePaintBox.GetFillBackground: Boolean;
begin
  Result := FFillBackground;
end;

function TFPixiePaintBox.GetBackgroundColor: TAlphaColor;
begin
  Result := FBackgroundColor;
end;

function TFPixiePaintBox.GetLeft: Single;
begin
  Result := 0;

  if ControlPaintBox <> nil then
    Result := ControlPaintBox.Position.X;
end;

function TFPixiePaintBox.GetTop: Single;
begin
  Result := 0;

  if ControlPaintBox <> nil then
    Result := ControlPaintBox.Position.Y;
end;

function TFPixiePaintBox.GetWidth: Single;
begin
  Result := 0;

  if ControlPaintBox <> nil then
    Result := ControlPaintBox.Size.Width;
end;

function TFPixiePaintBox.GetHeight: Single;
begin
  Result := 0;

  if ControlPaintBox <> nil then
    Result := ControlPaintBox.Size.Height;
end;

function TFPixiePaintBox.GetObject: TFmxObject;
begin
  Result := TFmxObject(ControlPaintBox);
end;

procedure TFPixiePaintBox.OnPaint(Event: TPixiePaintBoxEvent);
begin
  FOnPaint := Event;
end;

function TFPixiePaintBox.Handle: TFmxObject;
begin
  Result := TFmxObject(ControlPaintBox);
end;

// =============================================================================
// Exports
// =============================================================================
function InitPixiePaintBox: FPixiePaintBox; stdcall;
begin
  Result := TFPixiePaintBox.Create;
end;

exports
  InitPixiePaintBox;

end.
