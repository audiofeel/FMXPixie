unit Pixie.ElSelect;

// Owner-drawn HTML <select>, <option> and <optgroup> controls.

{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}

interface

uses
  SysUtils, Classes, Math, Generics.Collections,
  Pixie.Types, Pixie.WebColor, Pixie.Borders,
  Pixie.Element, Pixie.HtmlTag, Pixie.Canvas;

type
  TPixieElOption = class(TPixieHtmlTag)
  private
    FSelected: Boolean;
    FAttributesParsed: Boolean;
  public
    procedure ResetStyle; override;
    procedure ParseAttributes; override;
    procedure ComputeStyles(Recursive: Boolean = True); override;
    function GetLabel: string;
    function GetValue: string;
    procedure SetSelected(Value: Boolean);
    function IsOptionDisabled: Boolean;
    property Selected: Boolean read FSelected;
  end;

  TPixieElOptGroup = class(TPixieHtmlTag)
  public
    procedure ResetStyle; override;
    procedure ParseAttributes; override;
    procedure ComputeStyles(Recursive: Boolean = True); override;
  end;

  TPixieSelectItemKind = (sikOption, sikGroup);
  TPixieSelectItem = record
    Kind: TPixieSelectItemKind;
    Option: TPixieElOption;
    Node: TPixieHtmlTag;
    Text: string;
    Disabled: Boolean;
  end;

  TPixieElSelect = class(TPixieHtmlTag)
  private
    FItems: TList<TPixieSelectItem>;
    FSelectedOption: TPixieElOption;
    FOpenSelectedOption: TPixieElOption;
    FOpen: Boolean;
    FPopupScrollIndex: Integer;
    FPopupHoverIndex: Integer;
    FPopupHoverStyleIndex: Integer;
    procedure SetPopupItemHover(Index: Integer; Hovered: Boolean);
    procedure AddOptionNodes(Node: TPixieElement;
      const GroupLabel: string; GroupDisabled: Boolean);
    procedure BuildItems;
    procedure SetSelectedOption(Option: TPixieElOption;
      NotifyHost: Boolean);
    function FindItemIndex(Option: TPixieElOption): Integer;
    function GetSelectedIndex: Integer;
    procedure SetSelectedIndex(Value: Integer);
    procedure OpenPopup;
    procedure ClosePopup(Cancel: Boolean);
    procedure EnsurePopupSelectionVisible;
    function MoveSelection(Direction: Integer): Boolean;
    function SelectBoundary(Last: Boolean): Boolean;
    function PopupRowHeight: Single;
    function GetCanvas: TPixieCanvas;
  public
    constructor Create(ADoc: TObject);
    destructor Destroy; override;

    procedure ResetStyle; override;
    procedure ParseAttributes; override;
    procedure GetContentSize(var Sz: TPixieSize;
      MaxWidth: TPixiePixel); override;
    procedure Draw(Hdc: PtrUInt; X, Y: TPixiePixel;
      Clip: PPixiePosition; Ri: Pointer); override;
    function CreateRenderItem(ParentRi: Pointer): Pointer; override;

    function IsFocusable: Boolean; override;
    function IsReplaced: Boolean; override;
    function OnLButtonDown: Boolean; override;
    procedure OnBlur; override;
    function OnKeyDown(Key: Word; Shift: TShiftState): Boolean; override;

    function GetValue: string;
    procedure SetValue(const Value: string);
    function GetSelectedText: string;
    property Value: string read GetValue write SetValue;
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    property IsOpen: Boolean read FOpen;

    // Popup integration used by TPixieHtmlViewCore. Coordinates are in
    // viewport CSS pixels; ScrollY is the document's current vertical offset.
    function GetPopupRect(ViewW, ViewH, ScrollY: Single;
      out Rect: TPixiePosition; out FirstItem, VisibleCount: Integer): Boolean;
    procedure DrawPopup(const Cv: TPixieCanvas;
      const Rect: TPixiePosition; FirstItem, VisibleCount: Integer);
    function PopupHitTest(X, Y, ViewW, ViewH, ScrollY: Single;
      out ItemIndex: Integer): Boolean;
    function PopupMouseMove(X, Y, ViewW, ViewH, ScrollY: Single): Boolean;
    function ClearPopupHover: Boolean;
    function ScrollPopup(Delta: Integer; ViewW, ViewH, ScrollY: Single): Boolean;
    procedure SelectPopupItem(ItemIndex: Integer);
  end;

implementation

uses
  Pixie.Document, Pixie.StringId, Pixie.RenderItem,
  Pixie.RenderInput, Pixie.NativeContainer, Pixie.Container;

const
  SelectDefaultWidth = 150;
  SelectMinWidth = 96;
  SelectMaxWidth = 320;
  SelectMaxPopupHeight = 216;
  SelectHorizontalPadding = 8;
  SelectArrowWidth = 18;

function TPixieElOption.GetLabel: string;
var
  S: string;
begin
  S := GetAttr('label', #1);
  if S <> #1 then
    Result := Trim(S)
  else
  begin
    Result := '';
    GetText(Result);
    Result := Trim(Result);
  end;
end;

function TPixieElOption.GetValue: string;
var
  S: string;
begin
  S := GetAttr('value', #1);
  if S <> #1 then
    Result := S
  else
  begin
    Result := '';
    GetText(Result);
    Result := Trim(Result);
  end;
end;

procedure TPixieElOption.ResetStyle;
begin
  inherited ResetStyle;
  FAttributesParsed := False;
  SetPseudoClass(Ord(psid_hover), False);
end;

procedure TPixieElOption.ParseAttributes;
begin
  // RefreshStyles calls ParseAttributes when a pseudo-class changes. Do not
  // overwrite the live selection with the original HTML selected attribute.
  if not FAttributesParsed then
  begin
    FSelected := GetAttr('selected', #1) <> #1;
    FAttributesParsed := True;
  end;
  SetPseudoClass(Ord(psid_checked), FSelected);
  SetPseudoClass(Ord(psid_disabled), IsOptionDisabled);
  inherited ParseAttributes;
end;

procedure TPixieElOption.ComputeStyles(Recursive: Boolean);
begin
  inherited ComputeStyles(Recursive);
  // Options are represented by the owning select's popup, not in document flow.
  FCss.Display := displayNone;
end;

procedure TPixieElOption.SetSelected(Value: Boolean);
begin
  if FSelected = Value then
    Exit;
  FSelected := Value;
  if SetPseudoClass(Ord(psid_checked), FSelected) then
    FindStylesChanges(nil);
end;

function TPixieElOption.IsOptionDisabled: Boolean;
var
  Node: TPixieElement;
begin
  Result := GetAttr('disabled', #1) <> #1;
  if Result then
    Exit;
  Node := Parent;
  while Node <> nil do
  begin
    if (Node is TPixieHtmlTag) and
       (TPixieHtmlTag(Node).GetTagName = 'optgroup') and
       (TPixieHtmlTag(Node).GetAttr('disabled', #1) <> #1) then
      Exit(True);
    Node := Node.Parent;
  end;
end;

procedure TPixieElOptGroup.ResetStyle;
begin
  inherited ResetStyle;
  SetPseudoClass(Ord(psid_hover), False);
end;

procedure TPixieElOptGroup.ParseAttributes;
begin
  SetPseudoClass(Ord(psid_disabled),
    GetAttr('disabled', #1) <> #1);
  inherited ParseAttributes;
end;

procedure TPixieElOptGroup.ComputeStyles(Recursive: Boolean);
begin
  inherited ComputeStyles(Recursive);
  // Optgroup and its options are drawn by the select popup.
  FCss.Display := displayNone;
end;

constructor TPixieElSelect.Create(ADoc: TObject);
begin
  inherited Create(ADoc);
  FItems := TList<TPixieSelectItem>.Create;
  FSelectedOption := nil;
  FOpenSelectedOption := nil;
  FOpen := False;
  FPopupScrollIndex := 0;
  FPopupHoverIndex := -1;
  FPopupHoverStyleIndex := -1;
end;

destructor TPixieElSelect.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TPixieElSelect.ResetStyle;
begin
  inherited ResetStyle;
  FPopupHoverStyleIndex := -1;
end;

procedure TPixieElSelect.AddOptionNodes(Node: TPixieElement;
  const GroupLabel: string; GroupDisabled: Boolean);
var
  I, StartCount: Integer;
  Child: TPixieElement;
  Item: TPixieSelectItem;
  NewGroupLabel: string;
  NewGroupDisabled: Boolean;
begin
  if Node = nil then
    Exit;

  for I := 0 to Node.Children.Count - 1 do
  begin
    Child := Node.Children[I];
    if Child is TPixieElOption then
    begin
      Item := Default(TPixieSelectItem);
      Item.Kind := sikOption;
      Item.Option := TPixieElOption(Child);
      Item.Node := TPixieElOption(Child);
      Item.Text := TPixieElOption(Child).GetLabel;
      Item.Disabled := GroupDisabled or
        TPixieElOption(Child).IsOptionDisabled;
      FItems.Add(Item);
    end
    else if Child is TPixieElOptGroup then
    begin
      NewGroupLabel := TPixieHtmlTag(Child).GetAttr('label', '');
      NewGroupDisabled := GroupDisabled or
        (TPixieHtmlTag(Child).GetAttr('disabled', #1) <> #1);
      StartCount := FItems.Count;

      if NewGroupLabel <> '' then
      begin
        Item := Default(TPixieSelectItem);
        Item.Kind := sikGroup;
        Item.Option := nil;
        Item.Node := TPixieElOptGroup(Child);
        Item.Text := NewGroupLabel;
        Item.Disabled := NewGroupDisabled;
        FItems.Add(Item);
      end;

      AddOptionNodes(Child, NewGroupLabel, NewGroupDisabled);

      if (NewGroupLabel <> '') and (FItems.Count = StartCount + 1) then
        FItems.Delete(StartCount);
    end
    else
      AddOptionNodes(Child, GroupLabel, GroupDisabled);
  end;
end;

procedure TPixieElSelect.BuildItems;
begin
  FItems.Clear;
  AddOptionNodes(Self, '', False);
end;

procedure TPixieElSelect.SetSelectedOption(Option: TPixieElOption;
  NotifyHost: Boolean);
var
  I: Integer;
  Changed: Boolean;
  Item: TPixieSelectItem;
  Doc: TPixieDocument;
begin
  Changed := FSelectedOption <> Option;
  FSelectedOption := Option;

  for I := 0 to FItems.Count - 1 do
  begin
    Item := FItems[I];
    if Item.Kind = sikOption then
      Item.Option.SetSelected(Item.Option = FSelectedOption);
  end;

  if FOpen then
  begin
    FPopupHoverIndex := FindItemIndex(FSelectedOption);
    EnsurePopupSelectionVisible;
  end;

  if Changed and NotifyHost and (FDoc is TPixieDocument) then
  begin
    Doc := TPixieDocument(FDoc);
    if Assigned(Doc.OnChange) then
      Doc.OnChange(Doc);
  end;
end;

function TPixieElSelect.FindItemIndex(Option: TPixieElOption): Integer;
var
  I: Integer;
begin
  Result := -1;
  if Option = nil then
    Exit;
  for I := 0 to FItems.Count - 1 do
    if (FItems[I].Kind = sikOption) and (FItems[I].Option = Option) then
      Exit(I);
end;

function TPixieElSelect.GetSelectedIndex: Integer;
var
  I, OptionIndex: Integer;
begin
  Result := -1;
  OptionIndex := 0;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Kind = sikOption then
    begin
      if FItems[I].Option = FSelectedOption then
        Exit(OptionIndex);
      Inc(OptionIndex);
    end;
end;

procedure TPixieElSelect.SetSelectedIndex(Value: Integer);
var
  I, OptionIndex: Integer;
  Option: TPixieElOption;
begin
  Option := nil;
  OptionIndex := 0;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Kind = sikOption then
    begin
      if OptionIndex = Value then
      begin
        Option := FItems[I].Option;
        Break;
      end;
      Inc(OptionIndex);
    end;
  if (Option <> nil) and Option.IsOptionDisabled then
    Exit;
  SetSelectedOption(Option, True);
end;

procedure TPixieElSelect.ParseAttributes;
var
  PreviousOption, InitialOption: TPixieElOption;
  I: Integer;
  Item: TPixieSelectItem;
begin
  PreviousOption := FSelectedOption;
  inherited ParseAttributes;
  BuildItems;

  InitialOption := nil;
  if (PreviousOption <> nil) and (FindItemIndex(PreviousOption) >= 0) then
    InitialOption := PreviousOption
  else
    for I := 0 to FItems.Count - 1 do
    begin
      Item := FItems[I];
      if (Item.Kind = sikOption) and Item.Option.Selected then
      begin
        InitialOption := Item.Option;
        Break;
      end;
    end;

  if InitialOption = nil then
    for I := 0 to FItems.Count - 1 do
    begin
      Item := FItems[I];
      if (Item.Kind = sikOption) and not Item.Disabled then
      begin
        InitialOption := Item.Option;
        Break;
      end;
    end;

  SetSelectedOption(InitialOption, False);
  FOpen := False;
  FOpenSelectedOption := nil;
  FPopupScrollIndex := 0;
  FPopupHoverIndex := FindItemIndex(FSelectedOption);
end;

function TPixieElSelect.GetCanvas: TPixieCanvas;
var
  Cont: TPixieContainer;
begin
  Result := nil;
  Cont := GetDocContainer;
  if Cont is TPixieNativeContainer then
    Result := TPixieNativeContainer(Cont).Canvas;
end;

procedure TPixieElSelect.GetContentSize(var Sz: TPixieSize;
  MaxWidth: TPixiePixel);
var
  Cv: TPixieCanvas;
  I: Integer;
  Item: TPixieSelectItem;
  TextWidth, DesiredWidth, DesiredHeight: Single;
begin
  Cv := GetCanvas;
  DesiredWidth := SelectDefaultWidth;

  if (Cv <> nil) and (FCss.Font <> 0) then
    for I := 0 to FItems.Count - 1 do
    begin
      Item := FItems[I];
      if Item.Kind = sikOption then
      begin
        TextWidth := Cv.MeasureText(Item.Text, FCss.Font) +
          SelectHorizontalPadding * 2 + SelectArrowWidth;
        if TextWidth > DesiredWidth then
          DesiredWidth := TextWidth;
      end;
    end;

  DesiredWidth := EnsureRange(DesiredWidth,
    SelectMinWidth, SelectMaxWidth);
  if MaxWidth > 0 then
    DesiredWidth := Min(DesiredWidth, MaxWidth);

  DesiredHeight := Max(24, FCss.IntrinsicLineHeight + 10);
  Sz.Width := DesiredWidth;
  Sz.Height := DesiredHeight;
end;

function TPixieElSelect.IsFocusable: Boolean;
begin
  Result := not IsEffectivelyDisabled;
end;

function TPixieElSelect.IsReplaced: Boolean;
begin
  Result := True;
end;

procedure TPixieElSelect.OpenPopup;
var
  VisibleCount, SelectedItem: Integer;
begin
  if IsEffectivelyDisabled or FOpen then
    Exit;

  ClearPopupHover;
  BuildItems;
  FOpen := True;
  FOpenSelectedOption := FSelectedOption;
  FPopupHoverIndex := FindItemIndex(FSelectedOption);

  VisibleCount := Max(1, Trunc(SelectMaxPopupHeight / PopupRowHeight));
  SelectedItem := FindItemIndex(FSelectedOption);
  if SelectedItem >= 0 then
    FPopupScrollIndex := Max(0, SelectedItem - VisibleCount + 1)
  else
    FPopupScrollIndex := 0;

  if FPopupScrollIndex > FItems.Count - VisibleCount then
    FPopupScrollIndex := Max(0, FItems.Count - VisibleCount);
  EnsurePopupSelectionVisible;
end;

procedure TPixieElSelect.ClosePopup(Cancel: Boolean);
begin
  if not FOpen then
    Exit;
  ClearPopupHover;
  FOpen := False;
  FPopupHoverIndex := -1;
  if Cancel and (FSelectedOption <> FOpenSelectedOption) then
    SetSelectedOption(FOpenSelectedOption, True);
  FOpenSelectedOption := nil;
end;

procedure TPixieElSelect.EnsurePopupSelectionVisible;
var
  SelectedItem, VisibleCount: Integer;
  Cont: TPixieContainer;
  Viewport: TPixiePosition;
  PopupHeight: Single;
begin
  if not FOpen then
    Exit;
  SelectedItem := FindItemIndex(FSelectedOption);
  if SelectedItem < 0 then
    Exit;

  PopupHeight := SelectMaxPopupHeight;
  Cont := GetDocContainer;
  if Cont <> nil then
  begin
    Cont.GetViewport(Viewport);
    if Viewport.Height > 0 then
      PopupHeight := Min(PopupHeight, Viewport.Height);
  end;
  VisibleCount := Max(1, Trunc(PopupHeight / PopupRowHeight));
  if SelectedItem < FPopupScrollIndex then
    FPopupScrollIndex := SelectedItem
  else if SelectedItem >= FPopupScrollIndex + VisibleCount then
    FPopupScrollIndex := SelectedItem - VisibleCount + 1;
  FPopupScrollIndex := EnsureRange(FPopupScrollIndex, 0,
    Max(0, FItems.Count - VisibleCount));
end;

function TPixieElSelect.OnLButtonDown: Boolean;
var
  Doc: TPixieDocument;
begin
  if IsEffectivelyDisabled then
    Exit(False);
  if not (FDoc is TPixieDocument) then
    Exit(False);

  inherited OnLButtonDown;
  Doc := TPixieDocument(FDoc);
  Doc.SetFocus(Self);

  if FOpen then
    ClosePopup(False)
  else
    OpenPopup;
  Result := True;
end;

procedure TPixieElSelect.OnBlur;
begin
  ClosePopup(False);
  inherited OnBlur;
end;

function TPixieElSelect.MoveSelection(Direction: Integer): Boolean;
var
  I, StartIndex, Step, N, TargetIndex, Steps: Integer;
  Item: TPixieSelectItem;
  TargetOption: TPixieElOption;
begin
  Result := False;
  if (FItems.Count = 0) or (Direction = 0) then
    Exit;

  if Direction > 0 then
    Step := 1
  else
    Step := -1;
  Steps := Abs(Direction);
  StartIndex := FindItemIndex(FSelectedOption);
  TargetIndex := StartIndex;
  TargetOption := FSelectedOption;

  for N := 1 to Steps do
  begin
    I := TargetIndex + Step;
    if TargetIndex < 0 then
    begin
      if Step > 0 then
        I := 0
      else
        I := FItems.Count - 1;
    end;

    while (I >= 0) and (I < FItems.Count) do
    begin
      Item := FItems[I];
      if (Item.Kind = sikOption) and not Item.Disabled then
      begin
        TargetIndex := I;
        TargetOption := Item.Option;
        Break;
      end;
      Inc(I, Step);
    end;

    if (I < 0) or (I >= FItems.Count) then
      Break;
  end;

  if TargetOption <> FSelectedOption then
  begin
    SetSelectedOption(TargetOption, True);
    FPopupHoverIndex := TargetIndex;
    EnsurePopupSelectionVisible;
    Result := True;
  end;
end;

function TPixieElSelect.SelectBoundary(Last: Boolean): Boolean;
var
  I, Step: Integer;
  Item: TPixieSelectItem;
begin
  Result := False;
  if Last then
  begin
    I := FItems.Count - 1;
    Step := -1;
  end
  else
  begin
    I := 0;
    Step := 1;
  end;

  while (I >= 0) and (I < FItems.Count) do
  begin
    Item := FItems[I];
    if (Item.Kind = sikOption) and not Item.Disabled then
    begin
      SetSelectedOption(Item.Option, True);
      FPopupHoverIndex := I;
      Exit(True);
    end;
    Inc(I, Step);
  end;
end;

function TPixieElSelect.OnKeyDown(Key: Word;
  Shift: TShiftState): Boolean;
const
  VK_RETURN = $0D;
  VK_SPACE  = $20;
  VK_ESCAPE = $1B;
  VK_HOME   = $24;
  VK_END    = $23;
  VK_UP     = $26;
  VK_DOWN   = $28;
  VK_PRIOR  = $21;
  VK_NEXT   = $22;
begin
  Result := False;
  if IsEffectivelyDisabled then
    Exit;

  case Key of
    VK_RETURN, VK_SPACE:
    begin
      if FOpen then
        ClosePopup(False)
      else
        OpenPopup;
      Result := True;
    end;
    VK_ESCAPE:
    begin
      if FOpen then
      begin
        ClosePopup(True);
        Result := True;
      end;
    end;
    VK_DOWN:
    begin
      if not FOpen then
        OpenPopup;
      MoveSelection(1);
      Result := True;
    end;
    VK_UP:
    begin
      if not FOpen then
        OpenPopup;
      MoveSelection(-1);
      Result := True;
    end;
    VK_HOME:
    begin
      SelectBoundary(False);
      Result := True;
    end;
    VK_END:
    begin
      SelectBoundary(True);
      Result := True;
    end;
    VK_PRIOR:
    begin
      if not FOpen then
        OpenPopup;
      MoveSelection(-8);
      Result := True;
    end;
    VK_NEXT:
    begin
      if not FOpen then
        OpenPopup;
      MoveSelection(8);
      Result := True;
    end;
  end;
end;

function TPixieElSelect.GetValue: string;
begin
  if FSelectedOption <> nil then
    Result := FSelectedOption.GetValue
  else
    Result := '';
end;

function TPixieElSelect.GetSelectedText: string;
begin
  if FSelectedOption <> nil then
    Result := FSelectedOption.GetLabel
  else
    Result := '';
end;

procedure TPixieElSelect.SetValue(const Value: string);
var
  I: Integer;
  Item: TPixieSelectItem;
  Found: TPixieElOption;
begin
  BuildItems;
  Found := nil;
  for I := 0 to FItems.Count - 1 do
  begin
    Item := FItems[I];
    if (Item.Kind = sikOption) and (Item.Option.GetValue = Value) then
    begin
      Found := Item.Option;
      Break;
    end;
  end;
  if (Found <> nil) and Found.IsOptionDisabled then
    Exit;
  SetSelectedOption(Found, True);
end;

function TPixieElSelect.PopupRowHeight: Single;
begin
  Result := Max(24, FCss.FontMetrics.Height + 8);
end;

function TPixieElSelect.GetPopupRect(ViewW, ViewH, ScrollY: Single;
  out Rect: TPixiePosition; out FirstItem, VisibleCount: Integer): Boolean;
var
  Ri: TPixieRenderItem;
  AbsPos: TPixiePosition;
  Cv: TPixieCanvas;
  I: Integer;
  Item: TPixieSelectItem;
  PopupWidth, PopupHeight, RowHeight, ControlY, SpaceAbove, SpaceBelow: Single;
begin
  Rect := TPixiePosition.Create(0, 0, 0, 0);
  FirstItem := 0;
  VisibleCount := 0;
  Result := False;

  if not FOpen or (FItems.Count = 0) then
    Exit;

  Ri := TPixieRenderItem(GetRenderItem);
  if Ri = nil then
    Exit;

  AbsPos := Ri.AbsolutePos;
  ControlY := AbsPos.Y - ScrollY;
  RowHeight := PopupRowHeight;
  VisibleCount := Min(FItems.Count,
    Max(1, Trunc(SelectMaxPopupHeight / RowHeight)));
  if ViewH > 0 then
    VisibleCount := Min(VisibleCount, Max(1, Trunc(ViewH / RowHeight)));
  PopupHeight := VisibleCount * RowHeight;

  PopupWidth := Max(AbsPos.Width, SelectMinWidth);
  Cv := GetCanvas;
  if (Cv <> nil) and (FCss.Font <> 0) then
    for I := 0 to FItems.Count - 1 do
    begin
      Item := FItems[I];
      if Item.Kind = sikOption then
        PopupWidth := Max(PopupWidth,
          Cv.MeasureText(Item.Text, FCss.Font) + 32)
      else
        PopupWidth := Max(PopupWidth,
          Cv.MeasureText(Item.Text, FCss.Font) + 20);
    end;
  PopupWidth := Min(PopupWidth, ViewW);
  if PopupWidth <= 0 then
    Exit;

  Rect.X := EnsureRange(AbsPos.X, 0, Max(0, ViewW - PopupWidth));
  Rect.Width := PopupWidth;
  Rect.Height := PopupHeight;

  SpaceAbove := ControlY;
  SpaceBelow := ViewH - (ControlY + AbsPos.Height);
  if (ControlY + AbsPos.Height + PopupHeight <= ViewH) or
     (SpaceBelow >= SpaceAbove) then
    Rect.Y := Min(ViewH - PopupHeight, ControlY + AbsPos.Height)
  else
    Rect.Y := Max(0, ControlY - PopupHeight);

  FirstItem := EnsureRange(FPopupScrollIndex, 0,
    Max(0, FItems.Count - VisibleCount));
  FPopupScrollIndex := FirstItem;
  Result := True;
end;

procedure TPixieElSelect.Draw(Hdc: PtrUInt; X, Y: TPixiePixel;
  Clip: PPixiePosition; Ri: Pointer);
var
  RenderIt: TPixieRenderItem;
  P: TPixiePosition;
  Cv: TPixieCanvas;
  LabelText: string;
  TextColor: TPixieWebColor;
  ArrowX, ArrowY: Single;
begin
  inherited Draw(Hdc, X, Y, Clip, Ri);

  Cv := GetCanvas;
  if Cv = nil then
    Exit;

  RenderIt := TPixieRenderItem(Ri);
  P := RenderIt.Pos;
  P.X := P.X + X;
  P.Y := P.Y + Y;

  if (Clip <> nil) and not P.DoesIntersect(Clip^) then
    Exit;
  if (P.Width <= 0) or (P.Height <= 0) then
    Exit;

  // inherited Draw already paints the CSS background, border, radius,
  // shadow and outline. Draw only the select's text and dropdown arrow here.
  TextColor := FCss.Color;
  LabelText := GetSelectedText;
  if (LabelText = '') then
    LabelText := GetAttr('placeholder', '');

  if (LabelText <> '') and (FCss.Font <> 0) then
    Cv.TextRect(LabelText, FCss.Font, FCss.FontMetrics, TextColor,
      P.X + SelectHorizontalPadding, P.Y,
      Max(0, P.Width - SelectArrowWidth - SelectHorizontalPadding * 2),
      P.Height, taLeft, vaMiddle);

  ArrowX := P.X + P.Width - 12;
  ArrowY := P.Y + P.Height / 2;
  Cv.StrokePolyline([ArrowX - 3.5, ArrowY - 1.5,
    ArrowX, ArrowY + 2.5, ArrowX + 3.5, ArrowY - 1.5],
    TextColor, 1.5);
end;

function TPixieElSelect.CreateRenderItem(ParentRi: Pointer): Pointer;
var
  Ret: TPixieRenderInput;
begin
  Ret := TPixieRenderInput.Create(Self);
  Ret.SetParent(TPixieRenderItem(ParentRi));
  Result := Ret;
end;

procedure TPixieElSelect.DrawPopup(const Cv: TPixieCanvas;
  const Rect: TPixiePosition; FirstItem, VisibleCount: Integer);
var
  I, ItemIndex: Integer;
  RowY, RowHeight, TextX: Single;
  Item: TPixieSelectItem;
  FillColor, TextColor: TPixieWebColor;
  Rad, ItemRad: TPixieBorderRadiuses;
  Borders: TPixieBorders;
  Shadow: TPixieBoxShadow;
  RowRect: TPixiePosition;
begin
  if (Cv = nil) or (VisibleCount <= 0) then
    Exit;

  RowHeight := PopupRowHeight;

  // Popup surface follows the select's CSS background, border and radius.
  FillColor := FCss.Bg.Color;
  if FillColor.Alpha = 0 then
    FillColor := TPixieWebColor.Create(31, 41, 55);

  Rad := FCss.CssBorders.Radius.CalcPercents(Rect.Width, Rect.Height);

  Shadow := Default(TPixieBoxShadow);
  Shadow.OffsetY := 3;
  Shadow.BlurRadius := 12;
  Shadow.Color := TPixieWebColor.Create(0, 0, 0, 100);
  Cv.DrawBoxShadow(Rect.X, Rect.Y, Rect.Width, Rect.Height, Rad, Shadow);

  Cv.FillRoundedRect(Rect.X, Rect.Y, Rect.Width, Rect.Height, Rad, FillColor);

  if FCss.CssBorders.IsVisible then
    Borders.InitFromCss(FCss.CssBorders)
  else
    Borders.InitUniform(1, bsSolid, TPixieWebColor.Create(71, 85, 105));
  Borders.Radius := Rad;
  Cv.DrawBorders(Borders, Rect, False);

  for I := 0 to VisibleCount - 1 do
  begin
    ItemIndex := FirstItem + I;
    if (ItemIndex < 0) or (ItemIndex >= FItems.Count) then
      Break;
    Item := FItems[ItemIndex];
    RowY := Rect.Y + I * RowHeight;
    if Item.Node = nil then
      Continue;

    RowRect := TPixiePosition.Create(Rect.X + 4, RowY + 2,
      Rect.Width - 8, RowHeight - 4);
    FillColor := Item.Node.Css.Bg.Color;
    TextColor := Item.Node.Css.Color;
    ItemRad := Item.Node.Css.CssBorders.Radius.CalcPercents(
      RowRect.Width, RowRect.Height);

    if Item.Kind = sikOption then
    begin
      // CSS on the option wins. The built-in colors remain only as a fallback
      // for documents that do not define a background for the current state.
      if FillColor.Alpha > 0 then
        Cv.FillRoundedRect(RowRect.X, RowRect.Y, RowRect.Width,
          RowRect.Height, ItemRad, FillColor)
      else if Item.Option = FSelectedOption then
        Cv.FillRoundedRect(RowRect.X, RowRect.Y, RowRect.Width,
          RowRect.Height, 5, TPixieWebColor.Create(37, 99, 235))
      else if (ItemIndex = FPopupHoverIndex) or
              (ItemIndex = FPopupHoverStyleIndex) then
        Cv.FillRoundedRect(RowRect.X, RowRect.Y, RowRect.Width,
          RowRect.Height, 5, TPixieWebColor.Create(51, 65, 85));

      if Item.Disabled and
         (TextColor.Red = FCss.Color.Red) and
         (TextColor.Green = FCss.Color.Green) and
         (TextColor.Blue = FCss.Color.Blue) then
        TextColor := TPixieWebColor.Create(100, 116, 139);

      TextX := Rect.X + 18;
    end
    else
    begin
      if FillColor.Alpha > 0 then
        Cv.FillRoundedRect(RowRect.X, RowRect.Y, RowRect.Width,
          RowRect.Height, ItemRad, FillColor)
      else
        Cv.FillRoundedRect(RowRect.X, RowRect.Y, RowRect.Width,
          RowRect.Height, 5, TPixieWebColor.Create(38, 52, 73));

      if Item.Disabled and
         (TextColor.Red = FCss.Color.Red) and
         (TextColor.Green = FCss.Color.Green) and
         (TextColor.Blue = FCss.Color.Blue) then
        TextColor := TPixieWebColor.Create(100, 116, 139)
      else if (TextColor.Red = FCss.Color.Red) and
              (TextColor.Green = FCss.Color.Green) and
              (TextColor.Blue = FCss.Color.Blue) then
        TextColor := TPixieWebColor.Create(148, 163, 184);

      TextX := Rect.X + 10;
    end;

    if Item.Node.Css.CssBorders.IsVisible then
    begin
      Borders.InitFromCss(Item.Node.Css.CssBorders);
      Borders.Radius := ItemRad;
      Cv.DrawBorders(Borders, RowRect, False);
    end;

    if (Item.Node.Css.Font <> 0) and (Item.Text <> '') then
      Cv.TextRect(Item.Text, Item.Node.Css.Font,
        Item.Node.Css.FontMetrics, TextColor, TextX, RowY,
        Max(0, Rect.X + Rect.Width - TextX - 6),
        RowHeight, taLeft, vaMiddle)
    else if (FCss.Font <> 0) and (Item.Text <> '') then
      Cv.TextRect(Item.Text, FCss.Font, FCss.FontMetrics, TextColor,
        TextX, RowY, Max(0, Rect.X + Rect.Width - TextX - 6),
        RowHeight, taLeft, vaMiddle);
  end;
end;

function TPixieElSelect.PopupHitTest(X, Y, ViewW, ViewH, ScrollY: Single;
  out ItemIndex: Integer): Boolean;
var
  Rect: TPixiePosition;
  FirstItem, VisibleCount: Integer;
  Row: Integer;
begin
  ItemIndex := -1;
  Result := GetPopupRect(ViewW, ViewH, ScrollY,
    Rect, FirstItem, VisibleCount);
  if not Result then
    Exit;

  Result := (X >= Rect.X) and (X < Rect.X + Rect.Width) and
    (Y >= Rect.Y) and (Y < Rect.Y + Rect.Height);
  if Result then
  begin
    Row := Trunc((Y - Rect.Y) / PopupRowHeight);
    ItemIndex := FirstItem + Row;
    if (ItemIndex < FirstItem) or
       (ItemIndex >= FirstItem + VisibleCount) or
       (ItemIndex >= FItems.Count) then
      ItemIndex := -1;
  end;
end;

procedure TPixieElSelect.SetPopupItemHover(Index: Integer;
  Hovered: Boolean);
var
  El: TPixieElement;
begin
  if (Index < 0) or (Index >= FItems.Count) then
    Exit;

  El := FItems[Index].Node;
  while (El <> nil) and (El <> Self) do
  begin
    if El.SetPseudoClass(Ord(psid_hover), Hovered) then
      El.FindStylesChanges(nil);
    El := El.Parent;
  end;
end;

function TPixieElSelect.ClearPopupHover: Boolean;
begin
  Result := FPopupHoverStyleIndex >= 0;
  if Result then
    SetPopupItemHover(FPopupHoverStyleIndex, False);
  FPopupHoverStyleIndex := -1;
  if FPopupHoverIndex >= 0 then
    Result := True;
  FPopupHoverIndex := -1;
end;

function TPixieElSelect.PopupMouseMove(X, Y, ViewW, ViewH,
  ScrollY: Single): Boolean;
var
  ItemIndex: Integer;
  OldIndex, OldStyleIndex: Integer;
begin
  Result := False;
  if not PopupHitTest(X, Y, ViewW, ViewH, ScrollY, ItemIndex) then
    Exit;

  OldIndex := FPopupHoverIndex;
  OldStyleIndex := FPopupHoverStyleIndex;

  if ItemIndex <> FPopupHoverStyleIndex then
  begin
    if FPopupHoverStyleIndex >= 0 then
      SetPopupItemHover(FPopupHoverStyleIndex, False);
    FPopupHoverStyleIndex := ItemIndex;
    if FPopupHoverStyleIndex >= 0 then
      SetPopupItemHover(FPopupHoverStyleIndex, True);
  end;

  if (ItemIndex >= 0) and (FItems[ItemIndex].Kind = sikOption) and
     not FItems[ItemIndex].Disabled then
    FPopupHoverIndex := ItemIndex
  else
    FPopupHoverIndex := -1;

  Result := (OldIndex <> FPopupHoverIndex) or
            (OldStyleIndex <> FPopupHoverStyleIndex);
end;

function TPixieElSelect.ScrollPopup(Delta: Integer;
  ViewW, ViewH, ScrollY: Single): Boolean;
var
  Rect: TPixiePosition;
  FirstItem, VisibleCount, NewIndex: Integer;
begin
  Result := False;
  if not GetPopupRect(ViewW, ViewH, ScrollY,
    Rect, FirstItem, VisibleCount) then
    Exit;
  if FItems.Count <= VisibleCount then
    Exit;

  NewIndex := FPopupScrollIndex;
  if Delta > 0 then
    Dec(NewIndex, 3)
  else if Delta < 0 then
    Inc(NewIndex, 3);
  NewIndex := EnsureRange(NewIndex, 0, FItems.Count - VisibleCount);
  if NewIndex <> FPopupScrollIndex then
  begin
    FPopupScrollIndex := NewIndex;
    Result := True;
  end;
end;

procedure TPixieElSelect.SelectPopupItem(ItemIndex: Integer);
var
  Item: TPixieSelectItem;
begin
  if (ItemIndex < 0) or (ItemIndex >= FItems.Count) then
    Exit;

  Item := FItems[ItemIndex];
  if (Item.Kind <> sikOption) or Item.Disabled then
    Exit;

  SetSelectedOption(Item.Option, True);
  ClosePopup(False);
end;

end.
