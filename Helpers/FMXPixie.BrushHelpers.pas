{*******************************************************}
{                                                       }
{                 FMXPixie.BrushHelpers                 }
{                                                       }
{              Copyright(c) 2026 Audiofeel              }
{                  All rights reserved                  }
{                                                       }
{*******************************************************}

unit FMXPixie.BrushHelpers;

interface

uses
  System.UITypes, FMX.Graphics;

type
  TBrushHelper = class
  public
    class procedure ApplyGradient(FBrush: TBrush; FColor1, FColor2: TAlphaColor;
      FStyle: TGradientStyle); static;
    class procedure ApplyLinearAngle(FBrush: TBrush; FAngle: Single); static;
    class procedure ApplyRadialAngle(FBrush: TBrush; FAngle: Single); static;
    class procedure SetGradientPosition(FBrush: TBrush;
      X1, Y1, X2, Y2: Single); static;
  end;

implementation

uses
  System.Types, System.Math;

// =============================================================================
// Gradient Utilities
// =============================================================================
class procedure TBrushHelper.ApplyGradient(FBrush: TBrush;
  FColor1, FColor2: TAlphaColor; FStyle: TGradientStyle);
begin
  FBrush.Kind := TBrushKind.Gradient;
  FBrush.Gradient.Style := FStyle;
  FBrush.Gradient.Points.Clear;

  with TGradientPoint(FBrush.Gradient.Points.Add) do
  begin
    Offset := 0.0;
    Color := FColor1;
  end;

  with TGradientPoint(FBrush.Gradient.Points.Add) do
  begin
    Offset := 1.0;
    Color := FColor2;
  end;
end;

class procedure TBrushHelper.ApplyLinearAngle(FBrush: TBrush; FAngle: Single);
var
  dx, dy: Single;
begin
  dx := Cos(DegToRad(FAngle));
  dy := Sin(DegToRad(FAngle));

  FBrush.Gradient.StartPosition.Point :=
    TPointF.Create(0.5 - dx * 0.5, 0.5 - dy * 0.5);
  FBrush.Gradient.StopPosition.Point :=
    TPointF.Create(0.5 + dx * 0.5, 0.5 + dy * 0.5);
end;

class procedure TBrushHelper.ApplyRadialAngle(FBrush: TBrush; FAngle: Single);
var
  cx, cy, dx, dy: Single;
begin
  cx := 0.5;
  cy := 0.5;

  dx := Cos(DegToRad(FAngle)) * 0.5;
  dy := Sin(DegToRad(FAngle)) * 0.5;

  FBrush.Gradient.StartPosition.Point := TPointF.Create(cx, cy);
  FBrush.Gradient.StopPosition.Point := TPointF.Create(cx + dx, cy + dy);
end;

class procedure TBrushHelper.SetGradientPosition(FBrush: TBrush;
  X1, Y1, X2, Y2: Single);
begin
  FBrush.Gradient.StartPosition.Point := TPointF.Create(X1, Y1);
  FBrush.Gradient.StopPosition.Point := TPointF.Create(X2, Y2);
end;

end.
