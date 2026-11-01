{*******************************************************}
{                                                       }
{                   FMXPixie.HtmlView                   }
{                                                       }
{              Copyright(c) 2026 Audiofeel              }
{                  All rights reserved                  }
{                                                       }
{*******************************************************}

unit FMXPixie.HtmlView;

interface

uses
  System.Classes, System.UITypes,
  FMX.Types,
  Pixie.HtmlView.Core, Pixie.HtmlView.FMX, Pixie.NativeContainer,
  Pixie.Container, Pixie.Types, Pixie.Document, Pixie.Element;

// =============================================================================
// FPixieHtmlView
// =============================================================================
type
  TPixieFetchCallback = procedure(const Url, FileName: string;
    var Success: Boolean) of object;

  FPixieHtmlView = interface(IUnknown)
    ['{3FC1C0CD-DA10-4C25-8FF7-F40065A77F92}']
    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single); stdcall;
    procedure Position(X, Y: Single); stdcall;
    procedure Align(Al: TAlignLayout); stdcall;
    procedure Margins(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure Padding(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure SetClipParent(FValue: Boolean); stdcall;
    procedure SetClipChildren(FValue: Boolean); stdcall;
    procedure BringToFront; stdcall;
    procedure SendToBack; stdcall;
    procedure BaseUrl(const FUrl: WideString); stdcall;
    procedure ColorScheme(FValue: TPixieColorScheme); stdcall;
    procedure Lines(const FText: WideString); stdcall;
    procedure LoadFromString(const FHtml: WideString); stdcall;
    procedure LoadFromStringUrl(const FHtml, FBaseUrl: WideString); stdcall;
    procedure LoadFromFile(const FileName: WideString); stdcall;
    procedure UserCss(const FCss: WideString); stdcall;
    procedure Zoom(FValue: Double); stdcall;
    procedure ScrollY(FValue: Single); stdcall;
    procedure SaveAsPdf(const FileName: WideString); stdcall;
    procedure SaveAsPng(const FileName: WideString;
      FWidth, FHeight: Integer); stdcall;
    function RegisterImageFromFile(
      const FName, FFileName: WideString): Boolean; stdcall;
    procedure UnregisterImage(const FName: WideString); stdcall;
    procedure SetScrollbarWidth(FValue: Integer); stdcall;
    procedure SetScrollbarMargin(FValue: Integer); stdcall;
    procedure SetScrollbarMinThumbHeight(FValue: Integer); stdcall;
    procedure SetScrollbarThumbColor(FColor: TAlphaColor); stdcall;
    procedure SetScrollbarTrackColor(FColor: TAlphaColor); stdcall;
    procedure SetScrollbarVisibility(FType: TPixieScrollbarVisibility); stdcall;
    procedure ClearSelection; stdcall;
    procedure SelectAll; stdcall;
    procedure SetAutoScrollSpeed(FValue: Integer); stdcall;
    procedure SetAutoScrollEdge(FValue: Integer); stdcall;
    procedure SetAutoScrollAccelThreshold(FValue: Integer); stdcall;
    procedure SetAutoScrollAccelMax(FValue: Integer); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure RotationAngle(FValue: Single); stdcall;
    procedure RotationCenter(X, Y: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function GetScrollbarWidth: Integer; stdcall;
    function GetScrollbarMargin: Integer; stdcall;
    function GetScrollbarMinThumbHeight: Integer; stdcall;
    function GetScrollbarThumbColor: TAlphaColor; stdcall;
    function GetScrollbarTrackColor: TAlphaColor; stdcall;
    function GetAutoScrollSpeed: Integer; stdcall;
    function GetAutoScrollEdge: Integer; stdcall;
    function GetAutoScrollAccelThreshold: Integer; stdcall;
    function GetAutoScrollAccelMax: Integer; stdcall;
    function GetDocument: NativeInt; stdcall;
    function GetBaseUrl: WideString; stdcall;
    function GetUserCss: WideString; stdcall;
    function GetZoom: Double; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetContentHeight: Single; stdcall;
    function GetScrollY: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnAfterPaint(Event: TNotifyEvent); stdcall;
    procedure OnAfterParse(Event: TNotifyEvent); stdcall;
    procedure OnAnchorClick(Event: TPixieAnchorClickEvent); stdcall;
    procedure OnBeforePaint(Event: TNotifyEvent); stdcall;
    procedure OnBeforeParse(Event: TNotifyEvent); stdcall;
    procedure OnElementClick(Event: TPixieElementClickEvent); stdcall;
    procedure OnElementMouseEvent(Event: TPixieElementMouseEvent); stdcall;
    procedure OnFetchUrl(Event: TPixieFetchCallback); stdcall;
    procedure OnScrollChanged(Event: TNotifyEvent); stdcall;
    procedure OnDblClick(Event: TNotifyEvent); stdcall;
    procedure OnClick(Event: TNotifyEvent); stdcall;
    procedure OnMouseDown(Event: TMouseEvent); stdcall;
    procedure OnMouseEnter(Event: TNotifyEvent); stdcall;
    procedure OnMouseLeave(Event: TNotifyEvent); stdcall;
    procedure OnMouseUp(Event: TMouseEvent); stdcall;
    procedure OnMouseMove(Event: TMouseMoveEvent); stdcall;
    procedure OnMouseWheel(Event: TMouseWheelEvent); stdcall;
    procedure OnKeyDown(Event: TKeyEvent); stdcall;
    procedure OnKeyUp(Event: TKeyEvent); stdcall;
    procedure OnResize(Event: TNotifyEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

  TFPixieHtmlView = class(TInterfacedObject, FPixieHtmlView)
  private
    ControlPixieHtmlView: TPixieHtmlView;

    FColorScheme: TPixieColorScheme;
    FFetchUrlEvent: TPixieFetchCallback;

    procedure HandleFetchUrl(Sender: TObject; const Url: string;
      Stream: TStream; var Success: Boolean);
  public
    destructor Destroy; override;

    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single); stdcall;
    procedure Position(X, Y: Single); stdcall;
    procedure Align(Al: TAlignLayout); stdcall;
    procedure Margins(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure Padding(FLeft, FTop, FRight, FBottom: Single); stdcall;
    procedure SetClipParent(FValue: Boolean); stdcall;
    procedure SetClipChildren(FValue: Boolean); stdcall;
    procedure BringToFront; stdcall;
    procedure SendToBack; stdcall;
    procedure BaseUrl(const FUrl: WideString); stdcall;
    procedure ColorScheme(FValue: TPixieColorScheme); stdcall;
    procedure Lines(const FText: WideString); stdcall;
    procedure LoadFromString(const FHtml: WideString); stdcall;
    procedure LoadFromStringUrl(const FHtml, FBaseUrl: WideString); stdcall;
    procedure LoadFromFile(const FileName: WideString); stdcall;
    procedure UserCss(const FCss: WideString); stdcall;
    procedure Zoom(FValue: Double); stdcall;
    procedure ScrollY(FValue: Single); stdcall;
    procedure SaveAsPdf(const FileName: WideString); stdcall;
    procedure SaveAsPng(const FileName: WideString;
      FWidth, FHeight: Integer); stdcall;
    function RegisterImageFromFile(
      const FName, FFileName: WideString): Boolean; stdcall;
    procedure UnregisterImage(const FName: WideString); stdcall;
    procedure SetScrollbarWidth(FValue: Integer); stdcall;
    procedure SetScrollbarMargin(FValue: Integer); stdcall;
    procedure SetScrollbarMinThumbHeight(FValue: Integer); stdcall;
    procedure SetScrollbarThumbColor(FColor: TAlphaColor); stdcall;
    procedure SetScrollbarTrackColor(FColor: TAlphaColor); stdcall;
    procedure SetScrollbarVisibility(FType: TPixieScrollbarVisibility); stdcall;
    procedure ClearSelection; stdcall;
    procedure SelectAll; stdcall;
    procedure SetAutoScrollSpeed(FValue: Integer); stdcall;
    procedure SetAutoScrollEdge(FValue: Integer); stdcall;
    procedure SetAutoScrollAccelThreshold(FValue: Integer); stdcall;
    procedure SetAutoScrollAccelMax(FValue: Integer); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure RotationAngle(FValue: Single); stdcall;
    procedure RotationCenter(X, Y: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function GetScrollbarWidth: Integer; stdcall;
    function GetScrollbarMargin: Integer; stdcall;
    function GetScrollbarMinThumbHeight: Integer; stdcall;
    function GetScrollbarThumbColor: TAlphaColor; stdcall;
    function GetScrollbarTrackColor: TAlphaColor; stdcall;
    function GetAutoScrollSpeed: Integer; stdcall;
    function GetAutoScrollEdge: Integer; stdcall;
    function GetAutoScrollAccelThreshold: Integer; stdcall;
    function GetAutoScrollAccelMax: Integer; stdcall;
    function GetDocument: NativeInt; stdcall;
    function GetBaseUrl: WideString; stdcall;
    function GetUserCss: WideString; stdcall;
    function GetZoom: Double; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetContentHeight: Single; stdcall;
    function GetScrollY: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnAfterPaint(Event: TNotifyEvent); stdcall;
    procedure OnAfterParse(Event: TNotifyEvent); stdcall;
    procedure OnAnchorClick(Event: TPixieAnchorClickEvent); stdcall;
    procedure OnBeforePaint(Event: TNotifyEvent); stdcall;
    procedure OnBeforeParse(Event: TNotifyEvent); stdcall;
    procedure OnElementClick(Event: TPixieElementClickEvent); stdcall;
    procedure OnElementMouseEvent(Event: TPixieElementMouseEvent); stdcall;
    procedure OnFetchUrl(Event: TPixieFetchCallback); stdcall;
    procedure OnScrollChanged(Event: TNotifyEvent); stdcall;
    procedure OnDblClick(Event: TNotifyEvent); stdcall;
    procedure OnClick(Event: TNotifyEvent); stdcall;
    procedure OnMouseDown(Event: TMouseEvent); stdcall;
    procedure OnMouseEnter(Event: TNotifyEvent); stdcall;
    procedure OnMouseLeave(Event: TNotifyEvent); stdcall;
    procedure OnMouseUp(Event: TMouseEvent); stdcall;
    procedure OnMouseMove(Event: TMouseMoveEvent); stdcall;
    procedure OnMouseWheel(Event: TMouseWheelEvent); stdcall;
    procedure OnKeyDown(Event: TKeyEvent); stdcall;
    procedure OnKeyUp(Event: TKeyEvent); stdcall;
    procedure OnResize(Event: TNotifyEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

// =============================================================================
// FPixieElementList
// =============================================================================
type
  FPixieElementList = interface(IUnknown)
    ['{4F088164-8F54-4F80-9A94-15C8C33B299F}']
    procedure FCreate(FList: NativeInt); stdcall;
    function Count: Integer; stdcall;
    function Item(FIndex: Integer): NativeInt; stdcall;
    procedure Clear; stdcall;
  end;

  TFPixieElementList = class(TInterfacedObject, FPixieElementList)
  private
    ControlElementList: TPixieElementList;
  public
    destructor Destroy; override;

    procedure FCreate(FList: NativeInt); stdcall;
    function Count: Integer; stdcall;
    function Item(FIndex: Integer): NativeInt; stdcall;
    procedure Clear; stdcall;
  end;

// =============================================================================
// FPixieElement
// =============================================================================
type
  FPixieElement = interface(IUnknown)
    ['{C77D460B-83E9-425E-9E68-73EF836AAD14}']
    procedure FCreate(FElement: NativeInt); stdcall;
    function Parent: NativeInt; stdcall;
    function ChildCount: Integer; stdcall;
    function ChildAt(FIndex: Integer): NativeInt; stdcall;
    function AppendChild(FChild: NativeInt): Boolean; stdcall;
    function InsertBefore(FNewChild, FRefChild: NativeInt): Boolean; stdcall;
    function RemoveChild(FChild: NativeInt): Boolean; stdcall;
    function GetId: Integer; stdcall;
    function GetTag: Integer; stdcall;
    procedure SetTagName(const FTagName: WideString); stdcall;
    function GetTagName: WideString; stdcall;
    procedure SetAttr(const FName, FValue: WideString); stdcall;
    function GetAttr(const FName, FDefault: WideString): WideString; stdcall;
    procedure SetTextContent(const FText: WideString); stdcall;
    function GetTextContent: WideString; stdcall;
    procedure SetValue(const FValue: WideString); stdcall;
    function GetValue: WideString; stdcall;
    procedure SetChecked(FValue: Boolean); stdcall;
    function GetChecked: Boolean; stdcall;
  end;

  TFPixieElement = class(TInterfacedObject, FPixieElement)
  private
    ControlElement: TPixieElement;
  public
    procedure FCreate(FElement: NativeInt); stdcall;
    function Parent: NativeInt; stdcall;
    function ChildCount: Integer; stdcall;
    function ChildAt(FIndex: Integer): NativeInt; stdcall;
    function AppendChild(FChild: NativeInt): Boolean; stdcall;
    function InsertBefore(FNewChild, FRefChild: NativeInt): Boolean; stdcall;
    function RemoveChild(FChild: NativeInt): Boolean; stdcall;
    function GetId: Integer; stdcall;
    function GetTag: Integer; stdcall;
    procedure SetTagName(const FTagName: WideString); stdcall;
    function GetTagName: WideString; stdcall;
    procedure SetAttr(const FName, FValue: WideString); stdcall;
    function GetAttr(const FName, FDefault: WideString): WideString; stdcall;
    procedure SetTextContent(const FText: WideString); stdcall;
    function GetTextContent: WideString; stdcall;
    procedure SetValue(const FValue: WideString); stdcall;
    function GetValue: WideString; stdcall;
    procedure SetChecked(FValue: Boolean); stdcall;
    function GetChecked: Boolean; stdcall;
  end;

// =============================================================================
// FPixieDocument
// =============================================================================
type
  FPixieDocument = interface(IUnknown)
    ['{5BDDDA4C-9549-4114-A37B-A4CBBE5659C4}']
    procedure FCreate(FDocument: NativeInt); stdcall;
    function GetRoot: NativeInt; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function CreateTextNode(const FText: WideString): NativeInt; stdcall;
    function CreateElement(const FTagName: WideString): NativeInt; stdcall;
    function GetElementById(const FId: WideString): NativeInt; stdcall;
    function FindAnchorTarget(const FName: WideString): NativeInt; stdcall;
    function QuerySelector(const FSelector: WideString): NativeInt; stdcall;
    function QuerySelectorAll(const FSelector: WideString): NativeInt; stdcall;
    function HasSelection: Boolean; stdcall;
    function GetSelectedText: WideString; stdcall;
    procedure SetInnerHtml(FParent: NativeInt; const FHtml: WideString); stdcall;
    procedure RemoveElement(FElement: NativeInt); stdcall;
    procedure SetElementText(FElement: NativeInt;
      const FText: WideString); stdcall;
    procedure Rebuild; stdcall;
    procedure BeginUpdate; stdcall;
    procedure EndUpdate; stdcall;
    procedure Changed; stdcall;
  end;

  TFPixieDocument = class(TInterfacedObject, FPixieDocument)
  private
    ControlDocument: TPixieDocument;
  public
    procedure FCreate(FDocument: NativeInt); stdcall;
    function GetRoot: NativeInt; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function CreateTextNode(const FText: WideString): NativeInt; stdcall;
    function CreateElement(const FTagName: WideString): NativeInt; stdcall;
    function GetElementById(const FId: WideString): NativeInt; stdcall;
    function FindAnchorTarget(const FName: WideString): NativeInt; stdcall;
    function QuerySelector(const FSelector: WideString): NativeInt; stdcall;
    function QuerySelectorAll(const FSelector: WideString): NativeInt; stdcall;
    function HasSelection: Boolean; stdcall;
    function GetSelectedText: WideString; stdcall;
    procedure SetInnerHtml(FParent: NativeInt; const FHtml: WideString); stdcall;
    procedure RemoveElement(FElement: NativeInt); stdcall;
    procedure SetElementText(FElement: NativeInt;
      const FText: WideString); stdcall;
    procedure Rebuild; stdcall;
    procedure BeginUpdate; stdcall;
    procedure EndUpdate; stdcall;
    procedure Changed; stdcall;
  end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieHtmlView: FPixieHtmlView; stdcall;
function InitPixieElementList: FPixieElementList; stdcall;
function InitPixieElement: FPixieElement; stdcall;
function InitPixieDocument: FPixieDocument; stdcall;

implementation

uses
  System.SysUtils, System.IOUtils,
  Pixie.PdfExport, Pixie.WebColor, Pixie.ElTextInput, Pixie.ElInput;

function AlphaColorToPixieColor(AColor: TAlphaColor): TPixieWebColor;
begin
  Result := TPixieWebColor.Create(Byte((AColor shr 16) and $FF),
    Byte((AColor shr 8) and $FF), Byte(AColor and $FF),
      Byte((AColor shr 24) and $FF));
end;

function PixieColorToAlphaColor(const AColor: TPixieWebColor): TAlphaColor;
begin
  Result := (TAlphaColor(AColor.Alpha) shl 24) or
    (TAlphaColor(AColor.Red) shl 16) or (TAlphaColor(AColor.Green) shl 8) or
    TAlphaColor(AColor.Blue);
end;

// =============================================================================
// FPixieHtmlView
// =============================================================================
procedure TFPixieHtmlView.FCreate(FParent: TFmxObject);
begin
  if ControlPixieHtmlView = nil then
    ControlPixieHtmlView := TPixieHtmlView.Create(nil);

  ControlPixieHtmlView.Parent := TFmxObject(FParent);
end;

destructor TFPixieHtmlView.Destroy;
begin
  FreeAndNil(ControlPixieHtmlView);

  inherited;
end;

procedure TFPixieHtmlView.Left(FLeft: Single);
begin
  ControlPixieHtmlView.Position.X := FLeft;
end;

procedure TFPixieHtmlView.Top(FTop: Single);
begin
  ControlPixieHtmlView.Position.Y := FTop;
end;

procedure TFPixieHtmlView.Height(FHeight: Single);
begin
  ControlPixieHtmlView.Size.Height := FHeight;
end;

procedure TFPixieHtmlView.Width(FWidth: Single);
begin
  ControlPixieHtmlView.Size.Width := FWidth;
end;

procedure TFPixieHtmlView.SetBounds(FLeft, FTop, FWidth, FHeight: Single);
begin
  ControlPixieHtmlView.SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TFPixieHtmlView.Position(X, Y: Single);
begin
  ControlPixieHtmlView.Position.X := X;
  ControlPixieHtmlView.Position.Y := Y;
end;

procedure TFPixieHtmlView.Align(Al: TAlignLayout);
begin
  ControlPixieHtmlView.Align := TAlignLayout(Al);
end;

procedure TFPixieHtmlView.Margins(FLeft, FTop, FRight, FBottom: Single);
begin
  with ControlPixieHtmlView.Margins do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixieHtmlView.Padding(FLeft, FTop, FRight, FBottom: Single);
begin
  with ControlPixieHtmlView.Padding do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixieHtmlView.SetClipParent(FValue: Boolean);
begin
  ControlPixieHtmlView.ClipParent := FValue;
end;

procedure TFPixieHtmlView.SetClipChildren(FValue: Boolean);
begin
  ControlPixieHtmlView.ClipChildren := FValue;
end;

procedure TFPixieHtmlView.BringToFront;
begin
  ControlPixieHtmlView.BringToFront;
end;

procedure TFPixieHtmlView.SendToBack;
begin
  ControlPixieHtmlView.SendToBack;
end;

procedure TFPixieHtmlView.BaseUrl(const FUrl: WideString);
begin
  ControlPixieHtmlView.BaseUrl := string(FUrl);
end;

procedure TFPixieHtmlView.ColorScheme(FValue: TPixieColorScheme);
begin
  FColorScheme := FValue;
end;

procedure TFPixieHtmlView.Lines(const FText: WideString);
begin
  ControlPixieHtmlView.Lines.Text := string(FText);
end;

procedure TFPixieHtmlView.LoadFromString(const FHtml: WideString);
begin
  ControlPixieHtmlView.LoadFromString(string(FHtml));
end;

procedure TFPixieHtmlView.LoadFromStringUrl(const FHtml, FBaseUrl: WideString);
begin
  ControlPixieHtmlView.LoadFromString(string(FHtml), string(FBaseUrl));
end;

procedure TFPixieHtmlView.LoadFromFile(const FileName: WideString);
begin
  ControlPixieHtmlView.LoadFromFile(string(FileName));
end;

procedure TFPixieHtmlView.UserCss(const FCss: WideString);
begin
  ControlPixieHtmlView.UserCss := string(FCss);
end;

procedure TFPixieHtmlView.Zoom(FValue: Double);
begin
  ControlPixieHtmlView.Zoom := FValue;
end;

procedure TFPixieHtmlView.ScrollY(FValue: Single);
begin
  ControlPixieHtmlView.ScrollY := FValue;
  ControlPixieHtmlView.Repaint;
end;

procedure TFPixieHtmlView.SaveAsPdf(const FileName: WideString);
var
  Pdf: TPixiePdfExport;
begin
  if ControlPixieHtmlView = nil then
    Exit;

  Pdf := TPixiePdfExport.Create;
  try
    Pdf.BaseUrl := ControlPixieHtmlView.BaseUrl;
    Pdf.UserCss := ControlPixieHtmlView.UserCss;

    if Assigned(FFetchUrlEvent) then
      Pdf.OnFetchUrl := HandleFetchUrl;

    Pdf.SaveToFile(ControlPixieHtmlView.Lines.Text, string(FileName));
  finally
    Pdf.Free;
  end;
end;

procedure TFPixieHtmlView.SaveAsPng(
  const FileName: WideString; FWidth, FHeight: Integer);
begin
  ControlPixieHtmlView.SaveAsPng(string(FileName), FWidth, FHeight);
end;

function TFPixieHtmlView.RegisterImageFromFile(
  const FName, FFileName: WideString): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;

  if (FName = '') or (FFileName = '') then
    Exit;

  Stream := nil;
  try
    try
      Stream := TFileStream.Create(
        string(FFileName), fmOpenRead or fmShareDenyWrite);

      ControlPixieHtmlView.RegisterImage(string(FName), Stream);
      ControlPixieHtmlView.Repaint;

      Result := True;
    except
      Result := False;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TFPixieHtmlView.UnregisterImage(const FName: WideString);
begin
  ControlPixieHtmlView.UnregisterImage(string(FName));
  ControlPixieHtmlView.Repaint;
end;

procedure TFPixieHtmlView.SetScrollbarWidth(FValue: Integer);
begin
  ControlPixieHtmlView.Scrollbar.Width := FValue;
end;

procedure TFPixieHtmlView.SetScrollbarMargin(FValue: Integer);
begin
  ControlPixieHtmlView.Scrollbar.Margin := FValue;
end;

procedure TFPixieHtmlView.SetScrollbarMinThumbHeight(FValue: Integer);
begin
  ControlPixieHtmlView.Scrollbar.MinThumbHeight := FValue;
end;

procedure TFPixieHtmlView.SetScrollbarThumbColor(FColor: TAlphaColor);
begin
  ControlPixieHtmlView.Scrollbar.ThumbColor :=
    AlphaColorToPixieColor(FColor);
end;

procedure TFPixieHtmlView.SetScrollbarTrackColor(FColor: TAlphaColor);
begin
  ControlPixieHtmlView.Scrollbar.TrackColor :=
    AlphaColorToPixieColor(FColor);
end;

procedure TFPixieHtmlView.SetScrollbarVisibility(
  FType: TPixieScrollbarVisibility);
begin
  ControlPixieHtmlView.Scrollbar.Visibility :=
    TPixieScrollbarVisibility(TPixieScrollbarVisibility(FType));
end;

procedure TFPixieHtmlView.ClearSelection;
begin
  if ControlPixieHtmlView.Document <> nil then
  begin
    ControlPixieHtmlView.Document.ClearSelection;
    ControlPixieHtmlView.Repaint;
  end;
end;

procedure TFPixieHtmlView.SelectAll;
begin
  if ControlPixieHtmlView.Document <> nil then
  begin
    ControlPixieHtmlView.Document.SelectAll;
    ControlPixieHtmlView.Repaint;
  end;
end;

procedure TFPixieHtmlView.SetAutoScrollSpeed(FValue: Integer);
begin
  ControlPixieHtmlView.AutoScrollSpeed := FValue;
end;

procedure TFPixieHtmlView.SetAutoScrollEdge(FValue: Integer);
begin
  ControlPixieHtmlView.AutoScrollEdge := FValue;
end;

procedure TFPixieHtmlView.SetAutoScrollAccelThreshold(FValue: Integer);
begin
  ControlPixieHtmlView.AutoScrollAccelThreshold := FValue;
end;

procedure TFPixieHtmlView.SetAutoScrollAccelMax(FValue: Integer);
begin
  ControlPixieHtmlView.AutoScrollAccelMax := FValue;
end;

procedure TFPixieHtmlView.Opacity(FOpacity: Single);
begin
  ControlPixieHtmlView.Opacity := FOpacity;
end;

procedure TFPixieHtmlView.RotationAngle(FValue: Single);
begin
  ControlPixieHtmlView.RotationAngle := FValue;
end;

procedure TFPixieHtmlView.RotationCenter(X, Y: Single);
begin
  ControlPixieHtmlView.RotationCenter.X := X;
  ControlPixieHtmlView.RotationCenter.Y := Y;
end;

procedure TFPixieHtmlView.Enabled(FEnabled: Boolean);
begin
  ControlPixieHtmlView.Enabled := FEnabled;
end;

procedure TFPixieHtmlView.Visible(FVisible: Boolean);
begin
  ControlPixieHtmlView.Visible := FVisible;
end;

procedure TFPixieHtmlView.HitTest(FEnabled: Boolean);
begin
  ControlPixieHtmlView.HitTest := FEnabled;
end;

function TFPixieHtmlView.GetScrollbarWidth: Integer;
begin
  Result := ControlPixieHtmlView.Scrollbar.Width;
end;

function TFPixieHtmlView.GetScrollbarMargin: Integer;
begin
  Result := ControlPixieHtmlView.Scrollbar.Margin;
end;

function TFPixieHtmlView.GetScrollbarMinThumbHeight: Integer;
begin
  Result := ControlPixieHtmlView.Scrollbar.MinThumbHeight;
end;

function TFPixieHtmlView.GetScrollbarThumbColor: TAlphaColor;
begin
  Result := PixieColorToAlphaColor(
    ControlPixieHtmlView.Scrollbar.ThumbColor);
end;

function TFPixieHtmlView.GetScrollbarTrackColor: TAlphaColor;
begin
  Result := PixieColorToAlphaColor(
    ControlPixieHtmlView.Scrollbar.TrackColor);
end;

function TFPixieHtmlView.GetAutoScrollSpeed: Integer;
begin
  Result := ControlPixieHtmlView.AutoScrollSpeed;
end;

function TFPixieHtmlView.GetAutoScrollEdge: Integer;
begin
  Result := ControlPixieHtmlView.AutoScrollEdge;
end;

function TFPixieHtmlView.GetAutoScrollAccelThreshold: Integer;
begin
  Result := ControlPixieHtmlView.AutoScrollAccelThreshold;
end;

function TFPixieHtmlView.GetAutoScrollAccelMax: Integer;
begin
  Result := ControlPixieHtmlView.AutoScrollAccelMax;
end;

function TFPixieHtmlView.GetDocument: NativeInt;
begin
  Result := 0;

  if ControlPixieHtmlView <> nil then
    Result := NativeInt(Pointer(ControlPixieHtmlView.Document));
end;

function TFPixieHtmlView.GetBaseUrl: WideString;
begin
  Result := ControlPixieHtmlView.BaseUrl;
end;

function TFPixieHtmlView.GetUserCss: WideString;
begin
  Result := ControlPixieHtmlView.UserCss;
end;

function TFPixieHtmlView.GetZoom: Double;
begin
  Result := ControlPixieHtmlView.Zoom;
end;

function TFPixieHtmlView.GetLeft: Single;
begin
  Result := ControlPixieHtmlView.Position.X;
end;

function TFPixieHtmlView.GetTop: Single;
begin
  Result := ControlPixieHtmlView.Position.Y;
end;

function TFPixieHtmlView.GetWidth: Single;
begin
  Result := ControlPixieHtmlView.Size.Width;
end;

function TFPixieHtmlView.GetHeight: Single;
begin
  Result := ControlPixieHtmlView.Size.Height;
end;

function TFPixieHtmlView.GetContentHeight: Single;
begin
  Result := ControlPixieHtmlView.ContentHeight;
end;

function TFPixieHtmlView.GetScrollY: Single;
begin
  Result := ControlPixieHtmlView.ScrollY;
end;

function TFPixieHtmlView.GetObject: TFmxObject;
begin
  Result := TFmxObject(ControlPixieHtmlView);
end;

procedure TFPixieHtmlView.OnAfterPaint(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnAfterPaint := Event;
end;

procedure TFPixieHtmlView.OnAfterParse(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnAfterParse := Event;
end;

procedure TFPixieHtmlView.OnAnchorClick(Event: TPixieAnchorClickEvent);
begin
  ControlPixieHtmlView.OnAnchorClick := Event;
end;

procedure TFPixieHtmlView.OnBeforePaint(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnBeforePaint := Event;
end;

procedure TFPixieHtmlView.OnBeforeParse(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnBeforeParse := Event;
end;

procedure TFPixieHtmlView.OnElementClick(Event: TPixieElementClickEvent);
begin
  ControlPixieHtmlView.OnElementClick := Event;
end;

procedure TFPixieHtmlView.OnElementMouseEvent(
  Event: TPixieElementMouseEvent);
begin
  ControlPixieHtmlView.OnElementMouseEvent := Event;
end;

procedure TFPixieHtmlView.HandleFetchUrl(Sender: TObject;
  const Url: string; Stream: TStream; var Success: Boolean);
var
  TempFileName: string;
  SourceStream: TFileStream;
begin
  Success := False;

  if (Stream = nil) or not Assigned(FFetchUrlEvent) then
    Exit;

  TempFileName := TPath.GetTempFileName;
  try
    DeleteFile(TempFileName);

    try
      FFetchUrlEvent(Url, TempFileName, Success);

      if not Success then
        Exit;

      if not FileExists(TempFileName) then
      begin
        Success := False;
        Exit;
      end;

      SourceStream := TFileStream.Create(
        TempFileName, fmOpenRead or fmShareDenyNone);
      try
        Stream.Size := 0;
        Stream.Position := 0;
        Stream.CopyFrom(SourceStream, 0);
        Stream.Position := 0;
      finally
        SourceStream.Free;
      end;
    except
      Success := False;
    end;
  finally
    if FileExists(TempFileName) then
      DeleteFile(TempFileName);
  end;
end;

procedure TFPixieHtmlView.OnFetchUrl(Event: TPixieFetchCallback);
begin
  FFetchUrlEvent := Event;

  if ControlPixieHtmlView <> nil then
  begin
    if Assigned(Event) then
      ControlPixieHtmlView.OnFetchUrl := HandleFetchUrl
    else
      ControlPixieHtmlView.OnFetchUrl := nil;
  end;
end;

procedure TFPixieHtmlView.OnScrollChanged(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnScrollChanged := Event;
end;

procedure TFPixieHtmlView.OnDblClick(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnDblClick := Event;
end;

procedure TFPixieHtmlView.OnClick(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnClick := Event;
end;

procedure TFPixieHtmlView.OnMouseDown(Event: TMouseEvent);
begin
  ControlPixieHtmlView.OnMouseDown := Event;
end;

procedure TFPixieHtmlView.OnMouseUp(Event: TMouseEvent);
begin
  ControlPixieHtmlView.OnMouseUp := Event;
end;

procedure TFPixieHtmlView.OnMouseEnter(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnMouseEnter := Event;
end;

procedure TFPixieHtmlView.OnMouseLeave(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnMouseLeave := Event;
end;

procedure TFPixieHtmlView.OnMouseMove(Event: TMouseMoveEvent);
begin
  ControlPixieHtmlView.OnMouseMove := Event;
end;

procedure TFPixieHtmlView.OnMouseWheel(Event: TMouseWheelEvent);
begin
  ControlPixieHtmlView.OnMouseWheel := Event;
end;

procedure TFPixieHtmlView.OnKeyDown(Event: TKeyEvent);
begin
  ControlPixieHtmlView.OnKeyDown := Event;
end;

procedure TFPixieHtmlView.OnKeyUp(Event: TKeyEvent);
begin
  ControlPixieHtmlView.OnKeyUp := Event;
end;

procedure TFPixieHtmlView.OnResize(Event: TNotifyEvent);
begin
  ControlPixieHtmlView.OnResize := Event;
end;

function TFPixieHtmlView.Handle: TFmxObject;
begin
  Result := TFmxObject(ControlPixieHtmlView);
end;

// =============================================================================
// FPixieElementList
// =============================================================================
procedure TFPixieElementList.FCreate(FList: NativeInt);
var
  NewList: TPixieElementList;
begin
  NewList := TPixieElementList(Pointer(FList));

  if ControlElementList <> NewList then
  begin
    ControlElementList.Free;
    ControlElementList := NewList;
  end;
end;

destructor TFPixieElementList.Destroy;
begin
  ControlElementList.Free;
  ControlElementList := nil;

  inherited;
end;

function TFPixieElementList.Count: Integer;
begin
  if ControlElementList <> nil then
    Result := ControlElementList.Count
  else
    Result := 0;
end;

function TFPixieElementList.Item(FIndex: Integer): NativeInt;
begin
  Result := 0;

  if (ControlElementList <> nil) and (FIndex >= 0) and
     (FIndex < ControlElementList.Count) then
    Result := NativeInt(Pointer(ControlElementList[FIndex]));
end;

procedure TFPixieElementList.Clear;
begin
  if ControlElementList <> nil then
    ControlElementList.Clear;
end;

// =============================================================================
// FPixieElement
// =============================================================================
procedure TFPixieElement.FCreate(FElement: NativeInt);
begin
  ControlElement := TPixieElement(Pointer(FElement));
end;

function TFPixieElement.Parent: NativeInt;
begin
  Result := 0;

  if ControlElement <> nil then
    Result := NativeInt(Pointer(ControlElement.Parent));
end;

function TFPixieElement.ChildCount: Integer;
begin
  if ControlElement <> nil then
    Result := ControlElement.Children.Count
  else
    Result := 0;
end;

function TFPixieElement.ChildAt(FIndex: Integer): NativeInt;
begin
  Result := 0;

  if (ControlElement <> nil) and (FIndex >= 0) and
     (FIndex < ControlElement.Children.Count) then
    Result := NativeInt(Pointer(ControlElement.Children[FIndex]));
end;

function TFPixieElement.AppendChild(FChild: NativeInt): Boolean;
begin
  Result := False;

  if ControlElement <> nil then
    Result := ControlElement.AppendChild(TPixieElement(Pointer(FChild)));
end;

function TFPixieElement.InsertBefore(FNewChild, FRefChild: NativeInt): Boolean;
begin
  Result := False;

  if ControlElement <> nil then
    Result := ControlElement.InsertBefore(TPixieElement(Pointer(FNewChild)),
      TPixieElement(Pointer(FRefChild)));
end;

function TFPixieElement.RemoveChild(FChild: NativeInt): Boolean;
begin
  Result := False;

  if ControlElement <> nil then
    Result := ControlElement.RemoveChild(TPixieElement(Pointer(FChild)));
end;

function TFPixieElement.GetId: Integer;
begin
  if ControlElement <> nil then
    Result := ControlElement.GetId
  else
    Result := -1;
end;

function TFPixieElement.GetTag: Integer;
begin
  if ControlElement <> nil then
    Result := ControlElement.GetTag
  else
    Result := -1;
end;

function TFPixieElement.GetTagName: WideString;
begin
  Result := '';

  if ControlElement <> nil then
    Result := ControlElement.GetTagName;
end;

procedure TFPixieElement.SetTagName(const FTagName: WideString);
begin
  if ControlElement <> nil then
    ControlElement.SetTagName(string(FTagName));
end;

procedure TFPixieElement.SetAttr(const FName, FValue: WideString);
begin
  if ControlElement <> nil then
    ControlElement.SetAttr(string(FName), string(FValue));
end;

function TFPixieElement.GetAttr(const FName, FDefault: WideString): WideString;
begin
  Result := FDefault;

  if ControlElement <> nil then
    Result := ControlElement.GetAttr(string(FName), string(FDefault));
end;

function TFPixieElement.GetTextContent: WideString;
begin
  Result := '';

  if ControlElement <> nil then
    Result := ControlElement.GetTextContent;
end;

procedure TFPixieElement.SetTextContent(const FText: WideString);
begin
  if ControlElement <> nil then
    ControlElement.SetTextContent(string(FText));
end;

procedure TFPixieElement.SetValue(const FValue: WideString);
begin
  if ControlElement is TPixieElTextInput then
    TPixieElTextInput(ControlElement).SetValue(string(FValue));
end;

function TFPixieElement.GetChecked: Boolean;
begin
  Result := False;

  if ControlElement is TPixieElCheckbox then
    Result := TPixieElCheckbox(ControlElement).Checked
  else
  if ControlElement is TPixieElRadio then
    Result := TPixieElRadio(ControlElement).Checked;
end;

procedure TFPixieElement.SetChecked(FValue: Boolean);
begin
  if ControlElement is TPixieElCheckbox then
    TPixieElCheckbox(ControlElement).SetChecked(FValue)
  else
  if ControlElement is TPixieElRadio then
    TPixieElRadio(ControlElement).SetChecked(FValue);
end;

function TFPixieElement.GetValue: WideString;
begin
  Result := '';

  if ControlElement is TPixieElTextBase then
    Result := TPixieElTextBase(ControlElement).Value;
end;

// =============================================================================
// FPixieDocument
// =============================================================================
procedure TFPixieDocument.FCreate(FDocument: NativeInt);
begin
  ControlDocument := TPixieDocument(Pointer(FDocument));
end;

function TFPixieDocument.GetRoot: NativeInt;
begin
  Result := 0;

  if ControlDocument <> nil then
    Result := NativeInt(Pointer(ControlDocument.Root));
end;

function TFPixieDocument.GetWidth: Single;
begin
  if ControlDocument <> nil then
    Result := ControlDocument.Width
  else
    Result := 0;
end;

function TFPixieDocument.GetHeight: Single;
begin
  if ControlDocument <> nil then
    Result := ControlDocument.Height
  else
    Result := 0;
end;

function TFPixieDocument.CreateTextNode(const FText: WideString): NativeInt;
begin
  Result := 0;

  if ControlDocument <> nil then
    Result := NativeInt(
      Pointer(ControlDocument.CreateTextNode(string(FText))));
end;

function TFPixieDocument.CreateElement(const FTagName: WideString): NativeInt;
begin
  Result := 0;

  if ControlDocument <> nil then
    Result := NativeInt(
      Pointer(ControlDocument.CreateElement(string(FTagName), nil)));
end;

function TFPixieDocument.GetElementById(const FId: WideString): NativeInt;
begin
  Result := 0;

  if ControlDocument <> nil then
    Result := NativeInt(
      Pointer(ControlDocument.GetElementById(string(FId))));
end;

function TFPixieDocument.FindAnchorTarget(const FName: WideString): NativeInt;
begin
  Result := 0;

  if ControlDocument <> nil then
    Result := NativeInt(
      Pointer(ControlDocument.FindAnchorTarget(string(FName))));
end;

function TFPixieDocument.QuerySelector(const FSelector: WideString): NativeInt;
begin
  Result := 0;

  if ControlDocument <> nil then
    Result := NativeInt(
      Pointer(ControlDocument.QuerySelector(string(FSelector))));
end;

function TFPixieDocument.QuerySelectorAll(
  const FSelector: WideString): NativeInt;
begin
  Result := 0;

  if ControlDocument <> nil then
    Result := NativeInt(
      Pointer(ControlDocument.QuerySelectorAll(string(FSelector))));
end;

function TFPixieDocument.HasSelection: Boolean;
begin
  Result := False;

  if ControlDocument <> nil then
    Result := ControlDocument.HasRangeSelection;
end;

function TFPixieDocument.GetSelectedText: WideString;
begin
  Result := '';

  if ControlDocument <> nil then
    Result := ControlDocument.GetSelectedText;
end;

procedure TFPixieDocument.SetInnerHtml(
  FParent: NativeInt; const FHtml: WideString);
begin
  if ControlDocument <> nil then
    ControlDocument.SetInnerHtml(TPixieElement(Pointer(FParent)), string(FHtml));
end;

procedure TFPixieDocument.RemoveElement(FElement: NativeInt);
begin
  if ControlDocument <> nil then
    ControlDocument.RemoveElement(TPixieElement(Pointer(FElement)));
end;

procedure TFPixieDocument.SetElementText(
  FElement: NativeInt; const FText: WideString);
begin
  if ControlDocument <> nil then
    ControlDocument.SetElementText(
      TPixieElement(Pointer(FElement)), string(FText));
end;

procedure TFPixieDocument.Rebuild;
begin
  if ControlDocument <> nil then
    ControlDocument.Rebuild;
end;

procedure TFPixieDocument.BeginUpdate;
begin
  if ControlDocument <> nil then
    ControlDocument.BeginUpdate;
end;

procedure TFPixieDocument.EndUpdate;
begin
  if ControlDocument <> nil then
    ControlDocument.EndUpdate;
end;

procedure TFPixieDocument.Changed;
begin
  if ControlDocument <> nil then
    ControlDocument.Changed;
end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieHtmlView: FPixieHtmlView;
begin
  Result := TFPixieHtmlView.Create;
end;

function InitPixieElementList: FPixieElementList;
begin
  Result := TFPixieElementList.Create;
end;

function InitPixieElement: FPixieElement;
begin
  Result := TFPixieElement.Create;
end;

function InitPixieDocument: FPixieDocument;
begin
  Result := TFPixieDocument.Create;
end;

exports
  InitPixieHtmlView,
  InitPixieElementList,
  InitPixieElement,
  InitPixieDocument;

end.

