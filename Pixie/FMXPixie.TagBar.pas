
unit FMXPixie.TagBar;

interface

uses
  System.Classes, System.SysUtils, System.UITypes,
  FMX.Controls, FMX.Types,
  Pixie.TagBar.FMX, Pixie.TagBar.Base, Pixie.TagBar.Render,
  Pixie.WebColor;

// =============================================================================
// FPixieTagBar
// =============================================================================
type
  TPixieTagAddingCallback = procedure(Sender: TObject;
    const Text: WideString; Color: TAlphaColor;
    var Allow: Boolean) of object;

  TPixieTagDeletingCallback = procedure(Sender: TObject;
    ID: Integer; var Allow: Boolean) of object;

  TPixieTagChangingCallback = procedure(Sender: TObject;
    ID: Integer; const NewText: WideString;
    NewColor: TAlphaColor; var Allow: Boolean) of object;

  FPixieTagBar = interface(IUnknown)
    ['{4EDC2B7F-57A8-4C72-8CB2-21F3E5B7626B}']
    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single); stdcall;
    procedure Position(X, Y: Single); stdcall;
    procedure Align(Al: TAlignLayout); stdcall;
    procedure Options(FType: TPixieTagBarOptions); stdcall;
    procedure TagShape(FType: TPixieTagShape); stdcall;
    procedure AutoHeight(FValue: Boolean); stdcall;
    procedure ScrollMode(FType: TPixieTagBarScrollMode); stdcall;
    procedure ShowBorder(FValue: Boolean); stdcall;
    procedure BackgroundColor(FColor: TAlphaColor); stdcall;
    procedure BorderColor(FColor: TAlphaColor); stdcall;
    procedure FontFamily(const FFont: WideString); stdcall;
    procedure FontSize(FSize: Single); stdcall;
    procedure EmptyMessage(const FMessage: WideString); stdcall;
    procedure DeleteTag(ID: Integer); stdcall;
    procedure ClearTags; stdcall;
    procedure UpdateTag(ID: Integer; const NewText: WideString;
      NewColor: TAlphaColor); stdcall;
    procedure UpdateTagWithIcons(ID: Integer; const NewText: WideString;
      NewColor: TAlphaColor; const LeadIcon, TrailIcon: WideString); stdcall;
    procedure CheckTag(ID: Integer; FCheck: Boolean); stdcall;
    procedure CheckAll; stdcall;
    procedure UncheckAll; stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    function GetAutoHeight: Boolean; stdcall;
    function GetShowBorder: Boolean; stdcall;
    function GetBackgroundColor: TAlphaColor; stdcall;
    function GetBorderColor: TAlphaColor; stdcall;
    function GetFontFamily: WideString; stdcall;
    function GetFontSize: Single; stdcall;
    function GetEmptyMessage: WideString; stdcall;
    function AddTag(const FText: WideString): Integer; stdcall;
    function AddTagWithColor(const FText: WideString; FColor: TAlphaColor)
      : Integer; stdcall;
    function AddTagWithIcons(const FText: WideString; FColor: TAlphaColor;
      const LeadIcon, TrailIcon: WideString): Integer; stdcall;
    function TagCount: Integer; stdcall;
    function GetTagID(FTagID: Integer): Integer; stdcall;
    function GetTagText(FTagText: Integer): WideString; stdcall;
    function GetTagColor(FTagColor: Integer): TAlphaColor; stdcall;
    function IsChecked(ID: Integer): Boolean; stdcall;
    function GetCheckedCount: Integer; stdcall;
    function GetCheckedID(Index: Integer): Integer; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnTagChecked(Event: TPixieTagCheckedEvent); stdcall;
    procedure OnChanged(Event: TNotifyEvent); stdcall;
    procedure OnTagAdding(Event: TPixieTagAddingCallback); stdcall;
    procedure OnTagDeleting(Event: TPixieTagDeletingCallback); stdcall;
    procedure OnTagChanging(Event: TPixieTagChangingCallback); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

  TFPixieTagBar = class(TInterfacedObject, FPixieTagBar)
  private
    ControlTagBar: TPixieTagBar;
    FEventBridge: TComponent;
  public
    procedure FCreate(FParent: TFmxObject); stdcall;
    procedure Left(FLeft: Single); stdcall;
    procedure Top(FTop: Single); stdcall;
    procedure Width(FWidth: Single); stdcall;
    procedure Height(FHeight: Single); stdcall;
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single); stdcall;
    procedure Position(X, Y: Single); stdcall;
    procedure Align(Al: TAlignLayout); stdcall;
    procedure Options(FType: TPixieTagBarOptions); stdcall;
    procedure TagShape(FType: TPixieTagShape); stdcall;
    procedure AutoHeight(FValue: Boolean); stdcall;
    procedure ScrollMode(FType: TPixieTagBarScrollMode); stdcall;
    procedure ShowBorder(FValue: Boolean); stdcall;
    procedure BackgroundColor(FColor: TAlphaColor); stdcall;
    procedure BorderColor(FColor: TAlphaColor); stdcall;
    procedure FontFamily(const FFont: WideString); stdcall;
    procedure FontSize(FSize: Single); stdcall;
    procedure EmptyMessage(const FMessage: WideString); stdcall;
    procedure DeleteTag(ID: Integer); stdcall;
    procedure ClearTags; stdcall;
    procedure UpdateTag(ID: Integer; const NewText: WideString;
      NewColor: TAlphaColor); stdcall;
    procedure UpdateTagWithIcons(ID: Integer; const NewText: WideString;
      NewColor: TAlphaColor; const LeadIcon, TrailIcon: WideString); stdcall;
    procedure CheckTag(ID: Integer; FCheck: Boolean); stdcall;
    procedure CheckAll; stdcall;
    procedure UncheckAll; stdcall;
    procedure Visible(FVisible: Boolean); stdcall;
    procedure Enabled(FEnabled: Boolean); stdcall;
    procedure Opacity(FOpacity: Single); stdcall;
    function GetAutoHeight: Boolean; stdcall;
    function GetShowBorder: Boolean; stdcall;
    function GetBackgroundColor: TAlphaColor; stdcall;
    function GetBorderColor: TAlphaColor; stdcall;
    function GetFontFamily: WideString; stdcall;
    function GetFontSize: Single; stdcall;
    function GetEmptyMessage: WideString; stdcall;
    function AddTag(const FText: WideString): Integer; stdcall;
    function AddTagWithColor(const FText: WideString; FColor: TAlphaColor)
      : Integer; stdcall;
    function AddTagWithIcons(const FText: WideString; FColor: TAlphaColor;
      const LeadIcon, TrailIcon: WideString): Integer; stdcall;
    function TagCount: Integer; stdcall;
    function GetTagID(FTagID: Integer): Integer; stdcall;
    function GetTagText(FTagText: Integer): WideString; stdcall;
    function GetTagColor(FTagColor: Integer): TAlphaColor; stdcall;
    function IsChecked(ID: Integer): Boolean; stdcall;
    function GetCheckedCount: Integer; stdcall;
    function GetCheckedID(Index: Integer): Integer; stdcall;
    function GetObject: TFmxObject; stdcall;
    procedure OnTagChecked(Event: TPixieTagCheckedEvent); stdcall;
    procedure OnChanged(Event: TNotifyEvent); stdcall;
    procedure OnTagAdding(Event: TPixieTagAddingCallback); stdcall;
    procedure OnTagDeleting(Event: TPixieTagDeletingCallback); stdcall;
    procedure OnTagChanging(Event: TPixieTagChangingCallback); stdcall;
    function Handle: TFmxObject; stdcall;
  end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieTagBar: FPixieTagBar; stdcall;

implementation

type
  TTagBarEventBridge = class(TComponent)
  private
    FOnTagAdding: TPixieTagAddingCallback;
    FOnTagDeleting: TPixieTagDeletingCallback;
    FOnTagChanging: TPixieTagChangingCallback;

    procedure DoTagAdding(Sender: TObject;
      const Text: string; Color: TPixieWebColor;
      var Allow: Boolean);

    procedure DoTagDeleting(Sender: TObject;
      ID: Integer; var Allow: Boolean);

    procedure DoTagChanging(Sender: TObject;
      ID: Integer; const NewText: string;
      NewColor: TPixieWebColor; var Allow: Boolean);
  end;

function AlphaColorToWebColor(Value: TAlphaColor): TPixieWebColor;
begin
  Result := TPixieWebColor.Create(Byte((Cardinal(Value) shr 16) and $FF),
    Byte((Cardinal(Value) shr 8) and $FF), Byte(Cardinal(Value) and $FF),
    Byte((Cardinal(Value) shr 24) and $FF));
end;

function WebColorToAlphaColor(const Value: TPixieWebColor): TAlphaColor;
begin
  Result := (Cardinal(Value.Alpha) shl 24) or (Cardinal(Value.Red) shl 16) or
    (Cardinal(Value.Green) shl 8) or Cardinal(Value.Blue);
end;

procedure TTagBarEventBridge.DoTagAdding(Sender: TObject;
  const Text: string; Color: TPixieWebColor;
  var Allow: Boolean);
begin
  if Assigned(FOnTagAdding) then
    FOnTagAdding(Sender, WideString(Text),
      WebColorToAlphaColor(Color), Allow);
end;

procedure TTagBarEventBridge.DoTagDeleting(Sender: TObject;
  ID: Integer; var Allow: Boolean);
begin
  if Assigned(FOnTagDeleting) then
    FOnTagDeleting(Sender, ID, Allow);
end;

procedure TTagBarEventBridge.DoTagChanging(Sender: TObject;
  ID: Integer; const NewText: string;
  NewColor: TPixieWebColor; var Allow: Boolean);
begin
  if Assigned(FOnTagChanging) then
    FOnTagChanging(Sender, ID, WideString(NewText),
      WebColorToAlphaColor(NewColor), Allow);
end;

// =============================================================================
// FPixieTagBar
// =============================================================================
procedure TFPixieTagBar.FCreate(FParent: TFmxObject);
begin
  if ControlTagBar = nil then
  begin
    ControlTagBar := TPixieTagBar.Create(nil);

    FEventBridge := TTagBarEventBridge.Create(ControlTagBar);

    ControlTagBar.OnTagAdding :=
      TTagBarEventBridge(FEventBridge).DoTagAdding;
    ControlTagBar.OnTagDeleting :=
      TTagBarEventBridge(FEventBridge).DoTagDeleting;
    ControlTagBar.OnTagChanging :=
      TTagBarEventBridge(FEventBridge).DoTagChanging;
  end;

  ControlTagBar.Parent := TFmxObject(FParent);
end;

procedure TFPixieTagBar.Left(FLeft: Single);
begin
  ControlTagBar.Position.X := FLeft;
end;

procedure TFPixieTagBar.Top(FTop: Single);
begin
  ControlTagBar.Position.Y := FTop;
end;

procedure TFPixieTagBar.Width(FWidth: Single);
begin
  ControlTagBar.Size.Width := FWidth;
end;

procedure TFPixieTagBar.Height(FHeight: Single);
begin
  ControlTagBar.Size.Height := FHeight;
end;

procedure TFPixieTagBar.SetBounds(FLeft, FTop, FWidth, FHeight: Single);
begin
  ControlTagBar.SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TFPixieTagBar.Position(X, Y: Single);
begin
  ControlTagBar.Position.X := X;
  ControlTagBar.Position.Y := Y;
end;

procedure TFPixieTagBar.Align(Al: TAlignLayout);
begin
  ControlTagBar.Align := TAlignLayout(Al);
end;

procedure TFPixieTagBar.Options(FType: TPixieTagBarOptions);
begin
  ControlTagBar.Options := TPixieTagBarOptions(FType);
end;

procedure TFPixieTagBar.TagShape(FType: TPixieTagShape);
begin
  ControlTagBar.TagShape := TPixieTagShape(FType);
end;

procedure TFPixieTagBar.AutoHeight(FValue: Boolean);
begin
  ControlTagBar.AutoHeight := FValue;
end;

procedure TFPixieTagBar.ScrollMode(FType: TPixieTagBarScrollMode);
begin
  ControlTagBar.ScrollMode := TPixieTagBarScrollMode(FType);
end;

procedure TFPixieTagBar.ShowBorder(FValue: Boolean);
begin
  ControlTagBar.ShowBorder := FValue;
end;

procedure TFPixieTagBar.BackgroundColor(FColor: TAlphaColor);
begin
  ControlTagBar.BackgroundColor := AlphaColorToWebColor(FColor);
end;

procedure TFPixieTagBar.BorderColor(FColor: TAlphaColor);
begin
  ControlTagBar.BorderColor := AlphaColorToWebColor(FColor);
end;

procedure TFPixieTagBar.FontFamily(const FFont: WideString);
begin
  ControlTagBar.FontFamily := string(FFont);
end;

procedure TFPixieTagBar.FontSize(FSize: Single);
begin
  ControlTagBar.FontSize := FSize;
end;

procedure TFPixieTagBar.EmptyMessage(const FMessage: WideString);
begin
  ControlTagBar.EmptyMessage := string(FMessage);
end;

procedure TFPixieTagBar.DeleteTag(ID: Integer);
begin
  ControlTagBar.DeleteTag(ID);
end;

procedure TFPixieTagBar.ClearTags;
begin
  ControlTagBar.ClearTags;
end;

procedure TFPixieTagBar.UpdateTag(ID: Integer; const NewText: WideString;
  NewColor: TAlphaColor);
begin
  ControlTagBar.UpdateTag(ID, string(NewText),
    AlphaColorToWebColor(NewColor));
end;

procedure TFPixieTagBar.UpdateTagWithIcons(ID: Integer;
  const NewText: WideString; NewColor: TAlphaColor;
  const LeadIcon, TrailIcon: WideString);
begin
  ControlTagBar.UpdateTag(ID, string(NewText), AlphaColorToWebColor(NewColor),
    string(LeadIcon), string(TrailIcon));
end;

procedure TFPixieTagBar.CheckTag(ID: Integer; FCheck: Boolean);
begin
  ControlTagBar.CheckTag(ID, FCheck);
end;

procedure TFPixieTagBar.CheckAll;
begin
  ControlTagBar.CheckAll;
end;

procedure TFPixieTagBar.UncheckAll;
begin
  ControlTagBar.UncheckAll;
end;

procedure TFPixieTagBar.Visible(FVisible: Boolean);
begin
  ControlTagBar.Visible := FVisible;
end;

procedure TFPixieTagBar.Enabled(FEnabled: Boolean);
begin
  ControlTagBar.Enabled := FEnabled;
end;

procedure TFPixieTagBar.Opacity(FOpacity: Single);
begin
  ControlTagBar.Opacity := FOpacity;
end;

function TFPixieTagBar.GetAutoHeight: Boolean;
begin
  Result := ControlTagBar.AutoHeight;
end;

function TFPixieTagBar.GetShowBorder: Boolean;
begin
  Result := ControlTagBar.ShowBorder;
end;

function TFPixieTagBar.GetBackgroundColor: TAlphaColor;
begin
  Result := WebColorToAlphaColor(ControlTagBar.BackgroundColor);
end;

function TFPixieTagBar.GetBorderColor: TAlphaColor;
begin
  Result := WebColorToAlphaColor(ControlTagBar.BorderColor);
end;

function TFPixieTagBar.GetFontFamily: WideString;
begin
  Result := WideString(ControlTagBar.FontFamily);
end;

function TFPixieTagBar.GetFontSize: Single;
begin
  Result := ControlTagBar.FontSize;
end;

function TFPixieTagBar.GetEmptyMessage: WideString;
begin
  Result := WideString(ControlTagBar.EmptyMessage);
end;

function TFPixieTagBar.AddTag(const FText: WideString): Integer;
begin
  Result := ControlTagBar.AddTag(string(FText));
end;

function TFPixieTagBar.AddTagWithColor(const FText: WideString;
  FColor: TAlphaColor): Integer;
begin
  Result := ControlTagBar.AddTag(string(FText), AlphaColorToWebColor(FColor));
end;

function TFPixieTagBar.AddTagWithIcons(const FText: WideString;
  FColor: TAlphaColor; const LeadIcon, TrailIcon: WideString): Integer;
begin
  Result := ControlTagBar.AddTag(string(FText), AlphaColorToWebColor(FColor),
    string(LeadIcon), string(TrailIcon));
end;

function TFPixieTagBar.TagCount: Integer;
begin
  Result := ControlTagBar.TagCount;
end;

function TFPixieTagBar.GetTagID(FTagID: Integer): Integer;
var
  Tag: TPixieTagDef;
begin
  Result := -1;

  if (FTagID < 0) or (FTagID >= ControlTagBar.TagCount) then
    Exit;

  Tag := ControlTagBar.GetTag(FTagID);
  Result := Tag.ID;
end;

function TFPixieTagBar.GetTagText(FTagText: Integer): WideString;
var
  Tag: TPixieTagDef;
begin
  Result := '';

  if (FTagText < 0) or (FTagText >= ControlTagBar.TagCount) then
    Exit;

  Tag := ControlTagBar.GetTag(FTagText);
  Result := WideString(Tag.Text);
end;

function TFPixieTagBar.GetTagColor(FTagColor: Integer): TAlphaColor;
var
  Tag: TPixieTagDef;
begin
  Result := 0;

  if (FTagColor < 0) or (FTagColor >= ControlTagBar.TagCount) then
    Exit;

  Tag := ControlTagBar.GetTag(FTagColor);
  Result := WebColorToAlphaColor(Tag.Color);
end;

function TFPixieTagBar.IsChecked(ID: Integer): Boolean;
begin
  Result := ControlTagBar.IsChecked(ID);
end;

function TFPixieTagBar.GetObject: TFmxObject;
begin
  Result := TFmxObject(ControlTagBar);
end;

function TFPixieTagBar.GetCheckedCount: Integer;
var
  IDs: TArray<Integer>;
begin
  IDs := ControlTagBar.GetCheckedIDs;
  Result := Length(IDs);
end;

function TFPixieTagBar.GetCheckedID(Index: Integer): Integer;
var
  IDs: TArray<Integer>;
begin
  Result := -1;

  if Index < 0 then
    Exit;

  IDs := ControlTagBar.GetCheckedIDs;

  if Index >= Length(IDs) then
    Exit;

  Result := IDs[Index];
end;

procedure TFPixieTagBar.OnTagChecked(Event: TPixieTagCheckedEvent);
begin
  ControlTagBar.OnTagChecked := Event;
end;

procedure TFPixieTagBar.OnChanged(Event: TNotifyEvent);
begin
  ControlTagBar.OnChanged := Event;
end;

procedure TFPixieTagBar.OnTagAdding(Event: TPixieTagAddingCallback);
begin
  if FEventBridge <> nil then
    TTagBarEventBridge(FEventBridge).FOnTagAdding := Event;
end;

procedure TFPixieTagBar.OnTagDeleting(Event: TPixieTagDeletingCallback);
begin
  if FEventBridge <> nil then
    TTagBarEventBridge(FEventBridge).FOnTagDeleting := Event;
end;

procedure TFPixieTagBar.OnTagChanging(Event: TPixieTagChangingCallback);
begin
  if FEventBridge <> nil then
    TTagBarEventBridge(FEventBridge).FOnTagChanging := Event;
end;

function TFPixieTagBar.Handle: TFmxObject;
begin
  Result := TFmxObject(ControlTagBar);
end;

// =============================================================================
// Exports
// =============================================================================
function InitPixieTagBar: FPixieTagBar; stdcall;
begin
  Result := TFPixieTagBar.Create;
end;

exports
  InitPixieTagBar;

end.
