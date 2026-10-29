unit Pixie.PaintBox.FMX;

// TPixiePaintBox — Delphi FMX simple drawing surface.
// Renders via FMX canvas, fires OnPaint with TPixieDrawingCanvas.

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  FMX.Controls, FMX.Types, FMX.Graphics,
  Pixie.Types, Pixie.WebColor, Pixie.Canvas, Pixie.Canvas.FMX,
  Pixie.DrawingCanvas;

type
  { TPixiePaintBox }

  TPixiePaintBox = class(TControl)
  private
    FPixieCanvas: TPixieCanvas;
    FDrawingCanvas: TPixieDrawingCanvas;
    FOnPaint: TPixiePaintEvent;
    FFillBackground: Boolean;
    FBackgroundColor: TPixieWebColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnPaint: TPixiePaintEvent read FOnPaint write FOnPaint;
    property FillBackground: Boolean read FFillBackground
      write FFillBackground;
    property BackgroundColor: TPixieWebColor read FBackgroundColor
      write FBackgroundColor;
    property Align;
    property Anchors;
    property Size;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResized;
  end;

implementation

constructor TPixiePaintBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Width := 200;
  Height := 150;

  FPixieCanvas := TPixieFmxCanvas.Create;
  FDrawingCanvas := TPixieDrawingCanvas.Create;

  FFillBackground := True;

  FBackgroundColor :=TPixieWebColor.Create($FF, $FF, $FF, $FF);
end;

destructor TPixiePaintBox.Destroy;
begin
  FDrawingCanvas.Free;
  FPixieCanvas.Free;

  inherited Destroy;
end;

procedure TPixiePaintBox.Paint;
begin
  if (FPixieCanvas = nil) or
     (Canvas = nil) then
    Exit;

  FPixieCanvas.SetViewSize(Round(Width), Round(Height), 1);

  FPixieCanvas.BeginPaint(PtrUInt(Pointer(Canvas)));

  try
    // FMX does not automatically apply AbsoluteOpacity to arbitrary calls
    // made directly on the Canvas. Pixie's FMX backend uses per-operation
    // opacity, so propagate the control's effective opacity into that backend.
    FPixieCanvas.PushOpacity(AbsoluteOpacity);
    try
      if FFillBackground then
        FPixieCanvas.FillRect(0, 0, Width, Height, FBackgroundColor);

      if Assigned(FOnPaint) then
      begin
        FDrawingCanvas.Bind(FPixieCanvas);
        try
          FOnPaint(Self, FDrawingCanvas);
        finally
          FDrawingCanvas.Unbind;
        end;
      end;
    finally
      FPixieCanvas.PopOpacity;
    end;
  finally
    FPixieCanvas.EndPaint;
  end;
end;

end.

