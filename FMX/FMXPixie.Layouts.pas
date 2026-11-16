
unit FMXPixie.Layouts;

interface

uses
  System.Classes, System.UITypes,
  FMX.Types, FMX.Layouts;

// =============================================================================
// FLayout
// =============================================================================
type
  FLayout = interface(IUnknown)
    ['{05AA3448-0DBB-4327-82F0-DA671C6729C6}']
    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Cursor(FCursor: TCursor); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
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
    procedure Repaint; stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure RotationAngle(FValue: Single); stdcall;
    procedure RotationCenter(X, Y: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function IsVisible: Boolean; stdcall;
    function GetTag: Integer; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnClick(Event: TNotifyEvent); stdcall;
    procedure OnMouseDown(Event: TMouseEvent); stdcall;
    procedure OnMouseEnter(Event: TNotifyEvent); stdcall;
    procedure OnMouseLeave(Event: TNotifyEvent); stdcall;
    procedure OnMouseUp(Event: TMouseEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

  TFLayout = class(TInterfacedObject, FLayout)
  private
    ControlLayout: TLayout;
  public
    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Cursor(FCursor: TCursor); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
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
    procedure Repaint; stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure RotationAngle(FValue: Single); stdcall;
    procedure RotationCenter(X, Y: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function IsVisible: Boolean; stdcall;
    function GetTag: Integer; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetWidth: Single; stdcall;
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
function InitLayoutHandle: FLayout; stdcall;

implementation

// =============================================================================
// FLayout
// =============================================================================
procedure TFLayout.FCreate(FParent: TFmxObject);
begin
  ControlLayout := TLayout.Create(nil);
  ControlLayout.Parent := FParent;
end;

procedure TFLayout.Cursor(FCursor: TCursor);
begin
  ControlLayout.Cursor := TCursor(FCursor);
end;

procedure TFLayout.Left(FLeft: Single);
begin
  ControlLayout.Position.X := FLeft;
end;

procedure TFLayout.Top(FTop: Single);
begin
  ControlLayout.Position.Y := FTop;
end;

procedure TFLayout.Height(FHeight: Single);
begin
  ControlLayout.Size.Height := FHeight;
end;

procedure TFLayout.Width(FWidth: Single);
begin
  ControlLayout.Size.Width := FWidth;
end;

procedure TFLayout.SetBounds(FLeft, FTop, FWidth, FHeight: Single);
begin
  ControlLayout.SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TFLayout.Position(X, Y: Single);
begin
  ControlLayout.Position.X := X;
  ControlLayout.Position.Y := Y;
end;

procedure TFLayout.Align(Al: TAlignLayout);
begin
  ControlLayout.Align := TAlignLayout(Al);
end;

procedure TFLayout.Margins(FLeft, FTop, FRight, FBottom: Single);
begin
  ControlLayout.Margins.Left := FLeft;
  ControlLayout.Margins.Top := FTop;
  ControlLayout.Margins.Right := FRight;
  ControlLayout.Margins.Bottom := FBottom;
end;

procedure TFLayout.Padding(FLeft, FTop, FRight, FBottom: Single);
begin
  ControlLayout.Padding.Left := FLeft;
  ControlLayout.Padding.Top := FTop;
  ControlLayout.Padding.Right := FRight;
  ControlLayout.Padding.Bottom := FBottom;
end;

procedure TFLayout.SetHint(const FText: WideString);
begin
  ControlLayout.ShowHint := True;
  ControlLayout.Hint := string(FText);
end;

procedure TFLayout.SetClipChildren(FValue: Boolean);
begin
  ControlLayout.ClipChildren := FValue;
end;

procedure TFLayout.SetClipParent(FValue: Boolean);
begin
  ControlLayout.ClipParent := FValue;
end;

procedure TFLayout.BringToFront;
begin
  ControlLayout.BringToFront;
end;

procedure TFLayout.SendToBack;
begin
  ControlLayout.SendToBack;
end;

procedure TFLayout.SetTag(FTag: Integer);
begin
  ControlLayout.Tag := FTag;
end;

procedure TFLayout.Repaint;
begin
  ControlLayout.Repaint;
end;

procedure TFLayout.Opacity(FOpacity: Single);
begin
  ControlLayout.Opacity := FOpacity;
end;

procedure TFLayout.RotationAngle(FValue: Single);
begin
  ControlLayout.RotationAngle := FValue;
end;

procedure TFLayout.RotationCenter(X, Y: Single);
begin
  ControlLayout.RotationCenter.X := X;
  ControlLayout.RotationCenter.Y := Y;
end;

procedure TFLayout.Enabled(FEnabled: Boolean);
begin
  ControlLayout.Enabled := FEnabled;
end;

procedure TFLayout.Visible(FVisible: Boolean);
begin
  ControlLayout.Visible := FVisible;
end;

procedure TFLayout.HitTest(FEnabled: Boolean);
begin
  ControlLayout.HitTest := FEnabled;
end;

function TFLayout.IsVisible: Boolean;
begin
  Result := ControlLayout.Visible;
end;

function TFLayout.GetTag: Integer;
begin
  Result := ControlLayout.Tag;
end;

function TFLayout.GetLeft: Single;
begin
  Result := ControlLayout.Position.X;
end;

function TFLayout.GetTop: Single;
begin
  Result := ControlLayout.Position.Y;
end;

function TFLayout.GetHeight: Single;
begin
  Result := ControlLayout.Size.Height;
end;

function TFLayout.GetWidth: Single;
begin
  Result := ControlLayout.Size.Width;
end;

function TFLayout.GetObject: TFmxObject;
begin
  Result := ControlLayout;
end;

procedure TFLayout.OnClick(Event: TNotifyEvent);
begin
  ControlLayout.OnClick := TNotifyEvent(Event);
end;

procedure TFLayout.OnMouseDown(Event: TMouseEvent);
begin
  ControlLayout.OnMouseDown := TMouseEvent(Event);
end;

procedure TFLayout.OnMouseEnter(Event: TNotifyEvent);
begin
  ControlLayout.OnMouseEnter := TNotifyEvent(Event);
end;

procedure TFLayout.OnMouseLeave(Event: TNotifyEvent);
begin
  ControlLayout.OnMouseLeave := TNotifyEvent(Event);
end;

procedure TFLayout.OnMouseUp(Event: TMouseEvent);
begin
  ControlLayout.OnMouseUp := TMouseEvent(Event);
end;

function TFLayout.Handle: TFmxObject;
begin
  Result := ControlLayout;
end;

// =============================================================================
// Exports
// =============================================================================
function InitLayoutHandle: FLayout;
begin
  Result := TFLayout.Create;
end;

exports
  InitLayoutHandle;

end.
