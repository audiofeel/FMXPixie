{*******************************************************}
{                                                       }
{                 FMXPixie.MarkdownView                 }
{                                                       }
{              Copyright(c) 2026 Audiofeel              }
{                  All rights reserved                  }
{                                                       }
{*******************************************************}

unit FMXPixie.MarkdownView;

interface

uses
  System.Classes, System.SysUtils,
  FMX.Controls, FMX.Types,
  Pixie.MarkdownView.FMX, Pixie.NativeContainer;

// =============================================================================
// FPixieMarkdownView
// =============================================================================
type
  FPixieMarkdownView = interface(IUnknown)
    ['{A63F7B59-613F-4B31-9B64-4CA6B8C16E24}']
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
    procedure BaseUrl(const FUrl: WideString); stdcall;
    procedure LoadMarkdownFromString(
      const FMarkdown, FBaseUrl: WideString); stdcall;
    procedure LoadMarkdownFromFile(const FileName: WideString); stdcall;
    procedure UserCss(const FCss: WideString); stdcall;
    procedure Zoom(FValue: Double); stdcall;
    procedure SetUseDefaultStyles(FValue: Boolean); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function GetMarkdownText: WideString; stdcall;
    function GetBaseUrl: WideString; stdcall;
    function GetUserCss: WideString; stdcall;
    function GetZoom: Double; stdcall;
    function GetUseDefaultStyles: Boolean; stdcall;
    function IsVisible: Boolean; stdcall;
    function GetTag: Integer; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnAnchorClick(Event: TPixieAnchorClickEvent); stdcall;
    procedure OnClick(Event: TNotifyEvent); stdcall;
    procedure OnMouseEnter(Event: TNotifyEvent); stdcall;
    procedure OnMouseLeave(Event: TNotifyEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

  TFPixieMarkdownView = class(TInterfacedObject, FPixieMarkdownView)
  private
    ControlMarkdownView: TPixieMarkdownView;
    FMarkdownText: TStringList;
    FBaseUrl: string;
    FUseDefaultStyles: Boolean;
    procedure SyncMarkdown;
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
    procedure SetTag(FTag: Integer); stdcall;
    procedure BaseUrl(const FUrl: WideString); stdcall;
    procedure LoadMarkdownFromString(
      const FMarkdown, FBaseUrl: WideString); stdcall;
    procedure LoadMarkdownFromFile(const FileName: WideString); stdcall;
    procedure UserCss(const FCss: WideString); stdcall;
    procedure Zoom(FValue: Double); stdcall;
    procedure SetUseDefaultStyles(FValue: Boolean); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure HitTest(FEnabled: Boolean); stdcall;
    function GetMarkdownText: WideString; stdcall;
    function GetBaseUrl: WideString; stdcall;
    function GetUserCss: WideString; stdcall;
    function GetZoom: Double; stdcall;
    function GetUseDefaultStyles: Boolean; stdcall;
    function IsVisible: Boolean; stdcall;
    function GetTag: Integer; stdcall;
    function GetLeft: Single; stdcall;
    function GetTop: Single; stdcall;
    function GetWidth: Single; stdcall;
    function GetHeight: Single; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnAnchorClick(Event: TPixieAnchorClickEvent); stdcall;
    procedure OnClick(Event: TNotifyEvent); stdcall;
    procedure OnMouseEnter(Event: TNotifyEvent); stdcall;
    procedure OnMouseLeave(Event: TNotifyEvent); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieMarkdownView: FPixieMarkdownView; stdcall;

implementation

// =============================================================================
// FPixieMarkdownView
// =============================================================================
constructor TFPixieMarkdownView.Create;
begin
  inherited Create;
  ControlMarkdownView := nil;
  FMarkdownText := TStringList.Create;
  FBaseUrl := '';
  FUseDefaultStyles := True;
end;

destructor TFPixieMarkdownView.Destroy;
begin
  FreeAndNil(FMarkdownText);
  inherited Destroy;
end;

procedure TFPixieMarkdownView.FCreate(FParent: TFmxObject);
begin
  if ControlMarkdownView = nil then
  begin
    ControlMarkdownView := TPixieMarkdownView.Create(nil);
    ControlMarkdownView.UseDefaultStyles := FUseDefaultStyles;
  end;

  ControlMarkdownView.Parent := TFmxObject(FParent);
  SyncMarkdown;
end;

procedure TFPixieMarkdownView.SyncMarkdown;
begin
  if ControlMarkdownView = nil then
    Exit;

  { LoadMarkdownFromString updates the component's private base URL. The
    Markdown.Assign that follows also populates its internal Markdown list.
    This matters because the upstream UseDefaultStyles setter rebuilds HTML
    from that list, while LoadMarkdownFromString alone does not populate it. }
  ControlMarkdownView.LoadMarkdownFromString(FMarkdownText.Text, FBaseUrl);
  ControlMarkdownView.Markdown.Assign(FMarkdownText);
  ControlMarkdownView.UseDefaultStyles := FUseDefaultStyles;
end;

procedure TFPixieMarkdownView.Left(FLeft: Single);
begin
  ControlMarkdownView.Position.X := FLeft;
end;

procedure TFPixieMarkdownView.Top(FTop: Single);
begin
  ControlMarkdownView.Position.Y := FTop;
end;

procedure TFPixieMarkdownView.Width(FWidth: Single);
begin
  ControlMarkdownView.Size.Width := FWidth;
end;

procedure TFPixieMarkdownView.Height(FHeight: Single);
begin
  ControlMarkdownView.Size.Height := FHeight;
end;

procedure TFPixieMarkdownView.SetBounds(FLeft, FTop, FWidth, FHeight: Single);
begin
  ControlMarkdownView.SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TFPixieMarkdownView.Position(X, Y: Single);
begin
  ControlMarkdownView.Position.X := X;
  ControlMarkdownView.Position.Y := Y;
end;

procedure TFPixieMarkdownView.Align(Al: TAlignLayout);
begin
  ControlMarkdownView.Align := TAlignLayout(Al);
end;

procedure TFPixieMarkdownView.Margins(FLeft, FTop, FRight, FBottom: Single);
begin
  with ControlMarkdownView.Margins do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixieMarkdownView.Padding(FLeft, FTop, FRight, FBottom: Single);
begin
  with ControlMarkdownView.Padding do
  begin
    Left := FLeft;
    Top := FTop;
    Right := FRight;
    Bottom := FBottom;
  end;
end;

procedure TFPixieMarkdownView.SetHint(const FText: WideString);
begin
  ControlMarkdownView.ShowHint := True;
  ControlMarkdownView.Hint := string(FText);
end;

procedure TFPixieMarkdownView.SetClipParent(FValue: Boolean);
begin
  ControlMarkdownView.ClipParent := FValue;
end;

procedure TFPixieMarkdownView.SetClipChildren(FValue: Boolean);
begin
  ControlMarkdownView.ClipChildren := FValue;
end;

procedure TFPixieMarkdownView.BringToFront;
begin
  ControlMarkdownView.BringToFront;
end;

procedure TFPixieMarkdownView.SendToBack;
begin
  ControlMarkdownView.SendToBack;
end;

procedure TFPixieMarkdownView.SetTag(FTag: Integer);
begin
  ControlMarkdownView.Tag := FTag;
end;

procedure TFPixieMarkdownView.BaseUrl(const FUrl: WideString);
begin
  FBaseUrl := string(FUrl);
  if ControlMarkdownView <> nil then SyncMarkdown;
end;

procedure TFPixieMarkdownView.LoadMarkdownFromString(
  const FMarkdown, FBaseUrl: WideString);
begin
  FMarkdownText.Text := string(FMarkdown);
  Self.FBaseUrl := string(FBaseUrl);
  SyncMarkdown;
end;

procedure TFPixieMarkdownView.LoadMarkdownFromFile(const FileName: WideString);
begin
  if ControlMarkdownView <> nil then
  begin
    ControlMarkdownView.LoadMarkdownFromFile(string(FileName));
    FBaseUrl := ExtractFilePath(string(FileName));
    FMarkdownText.LoadFromFile(string(FileName));
    ControlMarkdownView.Markdown.Assign(FMarkdownText);
    ControlMarkdownView.UseDefaultStyles := FUseDefaultStyles;
  end
  else
  begin
    FMarkdownText.LoadFromFile(string(FileName));
    FBaseUrl := ExtractFilePath(string(FileName));
  end;
end;

procedure TFPixieMarkdownView.UserCss(const FCss: WideString);
begin
  ControlMarkdownView.UserCss := string(FCss);
end;

procedure TFPixieMarkdownView.Zoom(FValue: Double);
begin
  ControlMarkdownView.Zoom := FValue;
end;

procedure TFPixieMarkdownView.SetUseDefaultStyles(FValue: Boolean);
begin
  FUseDefaultStyles := FValue;

  if ControlMarkdownView <> nil then
  begin
    { Ensure the component's private Markdown list has the current content
      before its setter rebuilds HTML. }
    ControlMarkdownView.Markdown.Assign(FMarkdownText);
    ControlMarkdownView.UseDefaultStyles := FValue;
  end;
end;

procedure TFPixieMarkdownView.Opacity(FOpacity: Single);
begin
  ControlMarkdownView.Opacity := FOpacity;
end;

procedure TFPixieMarkdownView.Enabled(FEnabled: Boolean);
begin
  ControlMarkdownView.Enabled := FEnabled;
end;

procedure TFPixieMarkdownView.Visible(FVisible: Boolean);
begin
  ControlMarkdownView.Visible := FVisible;
end;

procedure TFPixieMarkdownView.HitTest(FEnabled: Boolean);
begin
  ControlMarkdownView.HitTest := FEnabled;
end;

function TFPixieMarkdownView.GetMarkdownText: WideString;
begin
  Result := FMarkdownText.Text;
end;

function TFPixieMarkdownView.GetBaseUrl: WideString;
begin
  Result := FBaseUrl;
end;

function TFPixieMarkdownView.GetUserCss: WideString;
begin
  Result := ControlMarkdownView.UserCss;
end;

function TFPixieMarkdownView.GetZoom: Double;
begin
  Result := ControlMarkdownView.Zoom;
end;

function TFPixieMarkdownView.GetUseDefaultStyles: Boolean;
begin
  Result := ControlMarkdownView.UseDefaultStyles;
end;

function TFPixieMarkdownView.IsVisible: Boolean;
begin
  Result := ControlMarkdownView.Visible;
end;

function TFPixieMarkdownView.GetTag: Integer;
begin
  Result := ControlMarkdownView.Tag;
end;

function TFPixieMarkdownView.GetLeft: Single;
begin
  Result := ControlMarkdownView.Position.X;
end;

function TFPixieMarkdownView.GetTop: Single;
begin
  Result := ControlMarkdownView.Position.Y;
end;

function TFPixieMarkdownView.GetWidth: Single;
begin
  Result := ControlMarkdownView.Size.Width;
end;

function TFPixieMarkdownView.GetHeight: Single;
begin
  Result := ControlMarkdownView.Size.Height;
end;

function TFPixieMarkdownView.GetObject: TFmxObject;
begin
  Result := TFmxObject(ControlMarkdownView);
end;

procedure TFPixieMarkdownView.OnAnchorClick(Event: TPixieAnchorClickEvent);
begin
  ControlMarkdownView.OnAnchorClick := Event;
end;

procedure TFPixieMarkdownView.OnClick(Event: TNotifyEvent);
begin
  ControlMarkdownView.OnClick := Event;
end;

procedure TFPixieMarkdownView.OnMouseEnter(Event: TNotifyEvent);
begin
  ControlMarkdownView.OnMouseEnter := Event;
end;

procedure TFPixieMarkdownView.OnMouseLeave(Event: TNotifyEvent);
begin
  ControlMarkdownView.OnMouseLeave := Event;
end;

function TFPixieMarkdownView.Handle: TFmxObject;
begin
  Result := TFmxObject(ControlMarkdownView);
end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieMarkdownView: FPixieMarkdownView; stdcall;
begin
  Result := TFPixieMarkdownView.Create;
end;

exports
  InitPixieMarkdownView;

end.
