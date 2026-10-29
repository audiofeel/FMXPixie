{*******************************************************}
{                                                       }
{                    FMXPixie.SvgView                   }
{                                                       }
{              Copyright(c) 2026 Audiofeel              }
{                  All rights reserved                  }
{                                                       }
{*******************************************************}

unit FMXPixie.SvgView;

interface

uses
  System.Classes, System.SysUtils, System.UITypes,
  FMX.Controls, FMX.Types,
  Pixie.SvgView.FMX;

// =============================================================================
// FPixieSvgView
// =============================================================================
type
  FPixieSvgView = interface(IUnknown)
    ['{6F5B2A47-4A17-4B76-95ED-43AF5D6CCB0A}']
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
    procedure SetTag(FTag: Integer); stdcall;
    procedure LoadFromString(const FSvg: WideString); stdcall;
    procedure LoadFromFile(const FileName: WideString); stdcall;
    procedure SvgAlign(FType: TPixieSvgAlign); stdcall;
    procedure Zoom(FValue: Double); stdcall;
    procedure ColorInner(FColor: TAlphaColor); stdcall;
    procedure ColorInnerBorder(FColor: TAlphaColor); stdcall;
    procedure ColorCheckers(FColor: TAlphaColor); stdcall;
    procedure CheckersSize(FValue: Integer); stdcall;
    procedure SaveAsPng(const FileName: WideString;
      FWidth, FHeight: Integer); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function GetZoom: Double; stdcall;
    function GetColorInner: TAlphaColor; stdcall;
    function GetColorInnerBorder: TAlphaColor; stdcall;
    function GetColorCheckers: TAlphaColor; stdcall;
    function GetCheckersSize: Integer; stdcall;
    function GetImageWidth: Single; stdcall;
    function GetImageHeight: Single; stdcall;
    function IsVisible: Boolean; stdcall;
    function GetTag: Integer; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnClick(Event: TNotifyEvent); stdcall;
    procedure OnMouseDown(Event: TMouseEvent); stdcall;
    procedure OnMouseEnter(Event: TNotifyEvent); stdcall;
    procedure OnMouseLeave(Event: TNotifyEvent); stdcall;
    procedure OnMouseUp(Event: TMouseEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

  TFPixieSvgView = class(TInterfacedObject, FPixieSvgView)
  private
    ControlSvgView: TPixieSvgView;
  public
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
    procedure SetTag(FTag: Integer); stdcall;
    procedure LoadFromString(const FSvg: WideString); stdcall;
    procedure LoadFromFile(const FileName: WideString); stdcall;
    procedure SvgAlign(FType: TPixieSvgAlign); stdcall;
    procedure Zoom(FValue: Double); stdcall;
    procedure ColorInner(FColor: TAlphaColor); stdcall;
    procedure ColorInnerBorder(FColor: TAlphaColor); stdcall;
    procedure ColorCheckers(FColor: TAlphaColor); stdcall;
    procedure CheckersSize(FValue: Integer); stdcall;
    procedure SaveAsPng(const FileName: WideString;
      FWidth, FHeight: Integer); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function GetZoom: Double; stdcall;
    function GetColorInner: TAlphaColor; stdcall;
    function GetColorInnerBorder: TAlphaColor; stdcall;
    function GetColorCheckers: TAlphaColor; stdcall;
    function GetCheckersSize: Integer; stdcall;
    function GetImageWidth: Single; stdcall;
    function GetImageHeight: Single; stdcall;
    function IsVisible: Boolean; stdcall;
    function GetTag: Integer; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnClick(Event: TNotifyEvent); stdcall;
    procedure OnMouseDown(Event: TMouseEvent); stdcall;
    procedure OnMouseEnter(Event: TNotifyEvent); stdcall;
    procedure OnMouseLeave(Event: TNotifyEvent); stdcall;
    procedure OnMouseUp(Event: TMouseEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieSvgView: FPixieSvgView; stdcall;

implementation

// =============================================================================
// FPixieSvgView
// =============================================================================
procedure TFPixieSvgView.FCreate(FParent: TFmxObject);
begin
  if ControlSvgView = nil then
    ControlSvgView := TPixieSvgView.Create(nil);

  ControlSvgView.Parent := TFmxObject(FParent);
end;

procedure TFPixieSvgView.Left(FLeft: Single);
begin
  ControlSvgView.Position.X := FLeft;
end;

procedure TFPixieSvgView.Top(FTop: Single);
begin
  ControlSvgView.Position.Y := FTop;
end;

procedure TFPixieSvgView.Width(FWidth: Single);
begin
  ControlSvgView.Width := FWidth;
end;

procedure TFPixieSvgView.Height(FHeight: Single);
begin
  ControlSvgView.Height := FHeight;
end;

procedure TFPixieSvgView.SetBounds(FLeft, FTop, FWidth, FHeight: Single);
begin
  ControlSvgView.SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TFPixieSvgView.Position(X, Y: Single);
begin
  ControlSvgView.Position.X := X;
  ControlSvgView.Position.Y := Y;
end;

procedure TFPixieSvgView.Align(Al: TAlignLayout);
begin
  ControlSvgView.Align := TAlignLayout(Al);
end;

procedure TFPixieSvgView.Margins(FLeft, FTop, FRight, FBottom: Single);
begin
  with ControlSvgView.Margins do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixieSvgView.Padding(FLeft, FTop, FRight, FBottom: Single);
begin
  with ControlSvgView.Padding do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixieSvgView.SetHint(const FText: WideString);
begin
  ControlSvgView.ShowHint := True;
  ControlSvgView.Hint := string(FText);
end;

procedure TFPixieSvgView.SetClipParent(FValue: Boolean);
begin
  ControlSvgView.ClipChildren := FValue;
end;

procedure TFPixieSvgView.SetClipChildren(FValue: Boolean);
begin
  ControlSvgView.ClipParent := FValue;
end;

procedure TFPixieSvgView.BringToFront;
begin
  ControlSvgView.BringToFront;
end;

procedure TFPixieSvgView.SendToBack;
begin
  ControlSvgView.SendToBack;
end;

procedure TFPixieSvgView.SetTag(FTag: Integer);
begin
  ControlSvgView.Tag := FTag;
end;

procedure TFPixieSvgView.LoadFromString(const FSvg: WideString);
begin
  ControlSvgView.Lines.Text := string(FSvg);
end;

procedure TFPixieSvgView.LoadFromFile(const FileName: WideString);
begin
  ControlSvgView.LoadFromFile(string(FileName));
end;

procedure TFPixieSvgView.SvgAlign(FType: TPixieSvgAlign);
begin
  ControlSvgView.Alignment := TPixieSvgAlign(FType);
end;

procedure TFPixieSvgView.Zoom(FValue: Double);
begin
  ControlSvgView.Zoom := FValue;
end;

procedure TFPixieSvgView.ColorInner(FColor: TAlphaColor);
begin
  ControlSvgView.ColorInner := TAlphaColor(FColor);
end;

procedure TFPixieSvgView.ColorInnerBorder(FColor: TAlphaColor);
begin
  ControlSvgView.ColorInnerBorder := TAlphaColor(FColor);
end;

procedure TFPixieSvgView.ColorCheckers(FColor: TAlphaColor);
begin
  ControlSvgView.ColorCheckers := TAlphaColor(FColor);
end;

procedure TFPixieSvgView.CheckersSize(FValue: Integer);
begin
  ControlSvgView.CheckersSize := FValue;
end;

procedure TFPixieSvgView.SaveAsPng(
  const FileName: WideString; FWidth, FHeight: Integer);
begin
  ControlSvgView.SaveAsPng(string(FileName), FWidth, FHeight);
end;

procedure TFPixieSvgView.Opacity(FOpacity: Single);
begin
  ControlSvgView.Opacity := FOpacity;
end;

procedure TFPixieSvgView.Enabled(FEnabled: Boolean);
begin
  ControlSvgView.Enabled := FEnabled;
end;

procedure TFPixieSvgView.Visible(FVisible: Boolean);
begin
  ControlSvgView.Visible := FVisible;
end;

procedure TFPixieSvgView.HitTest(FEnabled: Boolean);
begin
  ControlSvgView.HitTest := FEnabled;
end;

function TFPixieSvgView.GetZoom: Double;
begin
  Result := ControlSvgView.Zoom;
end;

function TFPixieSvgView.GetColorInner: TAlphaColor;
begin
  Result := ControlSvgView.ColorInner;
end;

function TFPixieSvgView.GetColorInnerBorder: TAlphaColor;
begin
  Result := ControlSvgView.ColorInnerBorder;
end;

function TFPixieSvgView.GetColorCheckers: TAlphaColor;
begin
  Result := ControlSvgView.ColorCheckers;
end;

function TFPixieSvgView.GetCheckersSize: Integer;
begin
  Result := ControlSvgView.CheckersSize;
end;

function TFPixieSvgView.GetImageWidth: Single;
begin
  Result := ControlSvgView.ImageWidth;
end;

function TFPixieSvgView.GetImageHeight: Single;
begin
  Result := ControlSvgView.ImageHeight;
end;

function TFPixieSvgView.IsVisible: Boolean;
begin
  Result := ControlSvgView.Visible;
end;

function TFPixieSvgView.GetTag: Integer;
begin
  Result := ControlSvgView.Tag;
end;

function TFPixieSvgView.GetLeft: Single;
begin
  Result := ControlSvgView.Position.X;
end;

function TFPixieSvgView.GetTop: Single;
begin
  Result := ControlSvgView.Position.Y;
end;

function TFPixieSvgView.GetWidth: Single;
begin
  Result := ControlSvgView.Width;
end;

function TFPixieSvgView.GetHeight: Single;
begin
  Result := ControlSvgView.Height;
end;

function TFPixieSvgView.GetObject: TFmxObject;
begin
  Result := TFmxObject(ControlSvgView);
end;

procedure TFPixieSvgView.OnClick(Event: TNotifyEvent);
begin
  ControlSvgView.OnClick := TNotifyEvent(Event);
end;

procedure TFPixieSvgView.OnMouseDown(Event: TMouseEvent);
begin
  ControlSvgView.OnMouseDown := TMouseEvent(Event);
end;

procedure TFPixieSvgView.OnMouseEnter(Event: TNotifyEvent);
begin
  ControlSvgView.OnMouseEnter := TNotifyEvent(Event);
end;

procedure TFPixieSvgView.OnMouseLeave(Event: TNotifyEvent);
begin
  ControlSvgView.OnMouseLeave := TNotifyEvent(Event);
end;

procedure TFPixieSvgView.OnMouseUp(Event: TMouseEvent);
begin
  ControlSvgView.OnMouseUp := TMouseEvent(Event);
end;

function TFPixieSvgView.Handle: TFmxObject;
begin
  Result := TFmxObject(ControlSvgView);
end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieSvgView: FPixieSvgView; stdcall;
begin
  Result := TFPixieSvgView.Create;
end;

exports
  InitPixieSvgView;

end.
