
// ########################################################################## \\
// #    FMXPixie Handle - v2.0.0.0                                          # \\
// #    Last Updated: 31.Oct.2026                                           # \\
// #    RAD Studio 13.2 Build: 37.0.60952.8797 RTM Update 2                 # \\
// ########################################################################## \\

[Code]
// =============================================================================
// Helper procedures and functions
// =============================================================================
procedure EmptyWizardForm(BaseWidth, BaseHeight: Integer);
begin
  with WizardForm do
  begin
    Height := BaseHeight;
    Width := BaseWidth;

    NextButton.SetBounds(0, 0, 0, 0);
    CancelButton.SetBounds(0, 0, 0, 0);
    BackButton.SetBounds(0, 0, 0, 0);
  end;
end;

function ExtractAndLoad(AFileName: String): String;
var
  AFile: String;
begin
  AFile := ExtractFileName(AFileName);

  if not FileExists(ExpandConstant('{tmp}\' + AFile)) then
    ExtractTemporaryFile(AFile);

  Result := ExpandConstant('{tmp}\' + AFile);
end;

function AddFontResource(FileName: String): Integer;
  external 'AddFontResourceW@gdi32.dll stdcall delayload';
function RemoveFontResource(FileName: String): BOOL;
  external 'RemoveFontResourceW@gdi32.dll stdcall delayload';

// =============================================================================
// FMX Enumerations
// =============================================================================
type
  TAlphaColor = Cardinal;
  TFmxObject = NativeInt;
  TBackdropType = (btAuto, btNone, btMain, btTabbed, btAcrylic);
  TGradientStyle = (gsLinear, gsRadial);
  TMouseEventF = procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Single);
  TMouseWheelEventF = procedure(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; var Handled: Boolean);
  TKeyEventF = procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar;
    Shift: TShiftState);
  TAlignLayout = (None, Top, TopLeft, TopCenter, TopRight, Left, LeftTop,
    LeftCenter, LeftBottom, Right, RightTop, RightCenter, RightBottom, Bottom,
    BottomLeft, BottomCenter, BottomRight, MostTop, MostBottom, MostLeft,
    MostRight, Client, Contents, Center, VertCenter, HorzCenter, Horizontal,
    Vertical, Scale, Fit, FitLeft, FitRight);
  TPixieAnchorClickEvent = procedure(Sender: TObject;
    El: TObject; const Url: string);

// =============================================================================
// FForm
// =============================================================================
type
  FForm = interface(IUnknown)
    '{C4797C10-4C8F-4102-9EFC-5EDC659D97EE}'
    procedure FCreateBackdropForm(FHost: HWND; FBackType: TBackdropType;
      FDark, FRound: Boolean);
    procedure FCreateBlurForm(FHost: HWND; FColor: TAlphaColor;
      FRound: Boolean);
    procedure FCreateBlankForm(FHost: HWND; FColor: TAlphaColor;
      const FImage: WideString; FRound: Boolean);
    procedure FCreateImageForm(FHost: HWND; FColor: TAlphaColor;
      const FImage: WideString; FOpacity: Boolean);
    procedure ChangeFormImage(const FImage: WideString);
    procedure ChangeFormColor(FColor: TAlphaColor);
    procedure ChangeDarkMode(const FDark: Boolean);
    procedure ChangeBorderColor(FColor: TAlphaColor);
    procedure GradientFormColors(FColor1, FColor2: TAlphaColor;
      FStyle: TGradientStyle);
    procedure GradientFormLinearAngle(FAngle: Single);
    procedure GradientFormRadialAngle(FAngle: Single);
    procedure GradientFormPosition(X1, Y1, X2, Y2: Single);
    procedure SetCursor(const CursorFile: WideString);
    procedure Caption(const FText: WideString);
    procedure StayOnTop(FValue: Boolean);
    procedure AddMouseDownControls(FControl: TFmxObject);
    procedure StartWindowDrag;
    procedure Show;
    procedure Minimize;
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure OnShow(Event: TNotifyEvent);
    procedure OnActivate(Event: TNotifyEvent);
    procedure OnDeactivate(Event: TNotifyEvent);
    procedure OnKeyDown(Event: TKeyEventF);
    procedure OnKeyUp(Event: TKeyEventF);
    procedure OnMouseDown(Event: TMouseEventF);
    procedure OnMouseUp(Event: TMouseEventF);
    procedure OnMouseWheel(Event: TMouseWheelEventF);
    function Handle: TFmxObject;
    function HandleHWND: HWND;
  end;

function InitFormHandle: FForm;
  external 'InitFormHandle@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FMsgForm
// =============================================================================
type
  FMsgForm = interface(IUnknown)
    '{F314BB73-FE86-42BA-A281-0D254C766425}'
    procedure FCreateBackdropForm(FOwner: HWND; FBackType: TBackdropType;
      FDark, FRound: Boolean);
    procedure FCreateBlurForm(FOwner: HWND; FColor: TAlphaColor;
      FRound: Boolean);
    procedure FCreateBlankForm(FOwner: HWND; FColor: TAlphaColor;
      const FImage: WideString; FRound: Boolean);
    procedure FCreateImageForm(FOwner: HWND; FColor: TAlphaColor;
      const FImage: WideString; FOpacity: Boolean);
    procedure Height(FHeight: Integer);
    procedure Width(FWidth: Integer);
    procedure ChangeFormImage(const FImage: WideString);
    procedure ChangeFormColor(FColor: TAlphaColor);
    procedure ChangeDarkMode(const FDark: Boolean);
    procedure ChangeBorderColor(FColor: TAlphaColor);
    procedure GradientFormColors(FColor1, FColor2: TAlphaColor;
      FStyle: TGradientStyle);
    procedure GradientFormLinearAngle(FAngle: Single);
    procedure GradientFormRadialAngle(FAngle: Single);
    procedure GradientFormPosition(X1, Y1, X2, Y2: Single);
    procedure Caption(const FText: WideString);
    procedure AddMouseDownControls(FControl: TFmxObject);
    procedure StartWindowDrag;
    procedure Show;
    procedure Close;
    function GetHeight: Integer;
    function GetWidth: Integer;
    function Handle: TFmxObject;
    function HandleHWND: HWND;
  end;

function InitMsgFormHandle: FMsgForm;
  external 'InitMsgFormHandle@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieHtmlView
// =============================================================================
type
  TPixieScrollbarVisibility = (svShow, svHide, svAuto);
  TPixieElementClickEvent = function(Sender: TObject;
    El: TObject): Boolean;
  TPixieMouseEvent = (meEnter, meLeave);
  TPixieElementMouseEvent = procedure(Sender, El: TObject;
    Event: TPixieMouseEvent);
  TPixieFetchCallback = procedure(const Url, FileName: string;
    var Success: Boolean);
  TPixieColorScheme = (pcsAuto, pcsLight, pcsDark);
  TMouseMoveEventF = procedure(Sender: TObject; Shift: TShiftState;
    X, Y: Single);

  FPixieHtmlView = interface(IUnknown)
    '{3FC1C0CD-DA10-4C25-8FF7-F40065A77F92}'
    procedure FCreate(FParent: TFmxObject);
    procedure Left(FLeft: Single);
    procedure Top(FTop: Single);
    procedure Height(FHeight: Single);
    procedure Width(FWidth: Single);
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single);
    procedure Position(X, Y: Single);
    procedure Align(Al: TAlignLayout);
    procedure Margins(FLeft, FTop, FRight, FBottom: Single);
    procedure Padding(FLeft, FTop, FRight, FBottom: Single);
    procedure SetClipParent(FValue: Boolean);
    procedure SetClipChildren(FValue: Boolean);
    procedure BringToFront;
    procedure SendToBack;
    procedure BaseUrl(const FUrl: WideString);
    procedure ColorScheme(FValue: TPixieColorScheme);
    procedure Lines(const FText: WideString);
    procedure LoadFromString(const FHtml: WideString);
    procedure LoadFromStringUrl(const FHtml, FBaseUrl: WideString);
    procedure LoadFromFile(const FileName: WideString);
    procedure UserCss(const FCss: WideString);
    procedure Zoom(FValue: Double);
    procedure ScrollY(FValue: Single);
    procedure SaveAsPdf(const FileName: WideString);
    procedure SaveAsPng(const FileName: WideString;
      FWidth, FHeight: Integer);
    function RegisterImageFromFile(
      const FName, FFileName: WideString): Boolean;
    procedure UnregisterImage(const FName: WideString);
    procedure SetScrollbarWidth(FValue: Integer);
    procedure SetScrollbarMargin(FValue: Integer);
    procedure SetScrollbarMinThumbHeight(FValue: Integer);
    procedure SetScrollbarThumbColor(FColor: TAlphaColor);
    procedure SetScrollbarTrackColor(FColor: TAlphaColor);
    procedure SetScrollbarVisibility(FType: TPixieScrollbarVisibility);
    procedure ClearSelection;
    procedure SelectAll;
    procedure SetAutoScrollSpeed(FValue: Integer);
    procedure SetAutoScrollEdge(FValue: Integer);
    procedure SetAutoScrollAccelThreshold(FValue: Integer);
    procedure SetAutoScrollAccelMax(FValue: Integer);
    procedure Opacity(FOpacity: Single);
    procedure RotationAngle(FValue: Single);
    procedure RotationCenter(X, Y: Single);
    procedure Enabled(FEnabled: Boolean);
    procedure Visible(FVisible: Boolean);
    procedure HitTest(FEnabled: Boolean);
    function GetScrollbarWidth: Integer;
    function GetScrollbarMargin: Integer;
    function GetScrollbarMinThumbHeight: Integer;
    function GetScrollbarThumbColor: TAlphaColor;
    function GetScrollbarTrackColor: TAlphaColor;
    function GetAutoScrollSpeed: Integer;
    function GetAutoScrollEdge: Integer;
    function GetAutoScrollAccelThreshold: Integer;
    function GetAutoScrollAccelMax: Integer;
    function GetDocument: NativeInt;
    function GetBaseUrl: WideString;
    function GetUserCss: WideString;
    function GetZoom: Double;
    function GetLeft: Single;
    function GetTop: Single;
    function GetWidth: Single;
    function GetHeight: Single;
    function GetContentHeight: Single;
    function GetScrollY: Single;
    function GetObject: TFmxObject;
    procedure OnAfterPaint(Event: TNotifyEvent);
    procedure OnAfterParse(Event: TNotifyEvent);
    procedure OnAnchorClick(Event: TPixieAnchorClickEvent);
    procedure OnBeforePaint(Event: TNotifyEvent);
    procedure OnBeforeParse(Event: TNotifyEvent);
    procedure OnElementClick(Event: TPixieElementClickEvent);
    procedure OnElementMouseEvent(Event: TPixieElementMouseEvent);
    procedure OnFetchUrl(Event: TPixieFetchCallback);
    procedure OnScrollChanged(Event: TNotifyEvent);
    procedure OnDblClick(Event: TNotifyEvent);
    procedure OnClick(Event: TNotifyEvent);
    procedure OnMouseDown(Event: TMouseEventF);
    procedure OnMouseEnter(Event: TNotifyEvent);
    procedure OnMouseLeave(Event: TNotifyEvent);
    procedure OnMouseUp(Event: TMouseEventF);
    procedure OnMouseMove(Event: TMouseMoveEventF);
    procedure OnMouseWheel(Event: TMouseWheelEventF);
    procedure OnKeyDown(Event: TKeyEventF);
    procedure OnKeyUp(Event: TKeyEventF);
    procedure OnResize(Event: TNotifyEvent);
    function Handle: TFmxObject;
  end;

function InitPixieHtmlView: FPixieHtmlView;
  external 'InitPixieHtmlView@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieElementList
// =============================================================================
type
  FPixieElementList = interface(IUnknown)
    '{4F088164-8F54-4F80-9A94-15C8C33B299F}'
    procedure FCreate(FList: NativeInt);
    function Count: Integer;
    function Item(FIndex: Integer): NativeInt;
    procedure Clear;
  end;

function InitPixieElementList: FPixieElementList;
  external 'InitPixieElementList@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieElement
// =============================================================================
type
  FPixieElement = interface(IUnknown)
    '{C77D460B-83E9-425E-9E68-73EF836AAD14}'
    procedure FCreate(FElement: NativeInt);
    function Parent: NativeInt;
    function ChildCount: Integer;
    function ChildAt(FIndex: Integer): NativeInt;
    function AppendChild(FChild: NativeInt): Boolean;
    function InsertBefore(FNewChild, FRefChild: NativeInt): Boolean;
    function RemoveChild(FChild: NativeInt): Boolean;
    function GetId: Integer;
    function GetTag: Integer;
    function GetTagName: WideString;
    procedure SetTagName(const FTagName: WideString);
    procedure SetAttr(const FName, FValue: WideString);
    function GetAttr(const FName, FDefault: WideString): WideString;
    function GetTextContent: WideString;
    procedure SetTextContent(const FText: WideString);
    procedure SetValue(const FValue: WideString);
  end;

function InitPixieElement: FPixieElement;
  external 'InitPixieElement@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieDocument
// =============================================================================
type
  FPixieDocument = interface(IUnknown)
    '{5BDDDA4C-9549-4114-A37B-A4CBBE5659C4}'
    procedure FCreate(FDocument: NativeInt);
    function GetRoot: NativeInt;
    function GetWidth: Single;
    function GetHeight: Single;
    function CreateTextNode(const FText: WideString): NativeInt;
    function CreateElement(const FTagName: WideString): NativeInt;
    function GetElementById(const FId: WideString): NativeInt;
    function FindAnchorTarget(const FName: WideString): NativeInt;
    function QuerySelector(const FSelector: WideString): NativeInt;
    function QuerySelectorAll(const FSelector: WideString): NativeInt;
    function HasSelection: Boolean;
    function GetSelectedText: WideString;
    procedure SetInnerHtml(FParent: NativeInt; const FHtml: WideString);
    procedure RemoveElement(FElement: NativeInt);
    procedure SetElementText(FElement: NativeInt;
      const FText: WideString);
    procedure Rebuild;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Changed;
  end;

function InitPixieDocument: FPixieDocument;
  external 'InitPixieDocument@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieSvgView
// =============================================================================
type
  TPixieSvgAlign = (saTopLeft, saCenterHorz, saCenterVert, saCenterBoth);

  FPixieSvgView = interface(IUnknown)
    '{6F5B2A47-4A17-4B76-95ED-43AF5D6CCB0A}'
    procedure FCreate(FParent: TFmxObject);
    procedure Left(FLeft: Single);
    procedure Top(FTop: Single);
    procedure Width(FWidth: Single);
    procedure Height(FHeight: Single);
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single);
    procedure Position(X, Y: Single);
    procedure Align(Al: TAlignLayout);
    procedure Margins(FLeft, FTop, FRight, FBottom: Single);
    procedure Padding(FLeft, FTop, FRight, FBottom: Single);
    procedure SetHint(const FText: WideString);
    procedure SetClipParent(FValue: Boolean);
    procedure SetClipChildren(FValue: Boolean);
    procedure BringToFront;
    procedure SendToBack;
    procedure SetTag(FTag: Integer);
    procedure LoadFromString(const FSvg: WideString);
    procedure LoadFromFile(const FileName: WideString);
    procedure SvgAlign(FType: TPixieSvgAlign);
    procedure Zoom(FValue: Double);
    procedure ColorInner(FColor: TAlphaColor);
    procedure ColorInnerBorder(FColor: TAlphaColor);
    procedure ColorCheckers(FColor: TAlphaColor);
    procedure CheckersSize(FValue: Integer);
    procedure SaveAsPng(const FileName: WideString;
      FWidth, FHeight: Integer);
    procedure Opacity(FOpacity: Single);
    procedure Enabled(FEnabled: Boolean);
    procedure Visible(FVisible: Boolean);
    procedure HitTest(FEnabled: Boolean);
    function GetZoom: Double;
    function GetColorInner: TAlphaColor;
    function GetColorInnerBorder: TAlphaColor;
    function GetColorCheckers: TAlphaColor;
    function GetCheckersSize: Integer;
    function GetImageWidth: Single;
    function GetImageHeight: Single;
    function IsVisible: Boolean;
    function GetTag: Integer;
    function GetLeft: Single;
    function GetTop: Single;
    function GetWidth: Single;
    function GetHeight: Single;
    function GetObject: TFmxObject;
    procedure OnClick(Event: TNotifyEvent);
    procedure OnMouseDown(Event: TMouseEventF);
    procedure OnMouseEnter(Event: TNotifyEvent);
    procedure OnMouseLeave(Event: TNotifyEvent);
    procedure OnMouseUp(Event: TMouseEventF);
    function Handle: TFmxObject;
  end;

function InitPixieSvgView: FPixieSvgView;
  external 'InitPixieSvgView@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieMarkdownView
// =============================================================================
type
  FPixieMarkdownView = interface(IUnknown)
    '{A63F7B59-613F-4B31-9B64-4CA6B8C16E24}'
    procedure FCreate(FParent: TFmxObject);
    procedure Left(FLeft: Single);
    procedure Top(FTop: Single);
    procedure Width(FWidth: Single);
    procedure Height(FHeight: Single);
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single);
    procedure Position(X, Y: Single);
    procedure Align(Al: TAlignLayout);
    procedure Margins(FLeft, FTop, FRight, FBottom: Single);
    procedure Padding(FLeft, FTop, FRight, FBottom: Single);
    procedure SetHint(const FText: WideString);
    procedure SetClipParent(FValue: Boolean);
    procedure SetClipChildren(FValue: Boolean);
    procedure BringToFront;
    procedure SendToBack;
    procedure SetTag(FTag: Integer);
    procedure BaseUrl(const FUrl: WideString);
    procedure LoadMarkdownFromString(
      const FMarkdown, FBaseUrl: WideString);
    procedure LoadMarkdownFromFile(const FileName: WideString);
    procedure UserCss(const FCss: WideString);
    procedure Zoom(FValue: Double);
    procedure SetUseDefaultStyles(FValue: Boolean);
    procedure Opacity(FOpacity: Single);
    procedure Enabled(FEnabled: Boolean);
    procedure Visible(FVisible: Boolean);
    procedure HitTest(FEnabled: Boolean);
    function GetMarkdownText: WideString;
    function GetBaseUrl: WideString;
    function GetUserCss: WideString;
    function GetZoom: Double;
    function GetUseDefaultStyles: Boolean;
    function IsVisible: Boolean;
    function GetTag: Integer;
    function GetLeft: Single;
    function GetTop: Single;
    function GetWidth: Single;
    function GetHeight: Single;
    function GetObject: TFmxObject;
    procedure OnAnchorClick(Event: TPixieAnchorClickEvent);
    procedure OnClick(Event: TNotifyEvent);
    procedure OnMouseEnter(Event: TNotifyEvent);
    procedure OnMouseLeave(Event: TNotifyEvent);
    function Handle: TFmxObject;
  end;

function InitPixieMarkdownView: FPixieMarkdownView;
  external 'InitPixieMarkdownView@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieTagBar
// =============================================================================
type
  TPixieTagBarOption = (tboShowAll, tboShowDismiss, tboAllowCheck,
    tboAllowCreate, tboAllowEdit, tboReadOnly,
    tboAlwaysChecked, tboShowColorSwatch);
  TPixieTagBarOptions = set of TPixieTagBarOption;
  TPixieTagShape = (tsRect, tsRoundedRect, tsPill);
  TPixieTagBarScrollMode = (smNone, smVertical, smHorizontal, smAuto);
  TPixieTagCheckedEvent = procedure(Sender: TObject; ID: Integer;
    Checked: Boolean);

  FPixieTagBar = interface(IUnknown)
    '{4EDC2B7F-57A8-4C72-8CB2-21F3E5B7626B}'
    procedure FCreate(FParent: TFmxObject);
    procedure Left(FLeft: Single);
    procedure Top(FTop: Single);
    procedure Width(FWidth: Single);
    procedure Height(FHeight: Single);
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single);
    procedure Position(X, Y: Single);
    procedure Align(Al: TAlignLayout);
    procedure Options(FType: TPixieTagBarOptions);
    procedure TagShape(FType: TPixieTagShape);
    procedure AutoHeight(FValue: Boolean);
    procedure ScrollMode(FType: TPixieTagBarScrollMode);
    procedure ShowBorder(FValue: Boolean);
    procedure BackgroundColor(FColor: TAlphaColor);
    procedure BorderColor(FColor: TAlphaColor);
    procedure FontFamily(const FFont: WideString);
    procedure FontSize(FSize: Single);
    procedure EmptyMessage(const FMessage: WideString);
    procedure DeleteTag(ID: Integer);
    procedure ClearTags;
    procedure UpdateTag(ID: Integer; const NewText: WideString;
      NewColor: TAlphaColor);
    procedure UpdateTagWithIcons(ID: Integer; const NewText: WideString;
      NewColor: TAlphaColor; const LeadIcon, TrailIcon: WideString);
    procedure CheckTag(ID: Integer; FCheck: Boolean);
    procedure CheckAll;
    procedure UncheckAll;
    procedure Visible(FVisible: Boolean);
    procedure Enabled(FEnabled: Boolean);
    procedure Opacity(FOpacity: Single);
    function GetAutoHeight: Boolean;
    function GetShowBorder: Boolean;
    function GetBackgroundColor: TAlphaColor;
    function GetBorderColor: TAlphaColor;
    function GetFontFamily: WideString;
    function GetFontSize: Single;
    function GetEmptyMessage: WideString;
    function AddTag(const FText: WideString): Integer;
    function AddTagWithColor(const FText: WideString; FColor: TAlphaColor)
      : Integer;
    function AddTagWithIcons(const FText: WideString; FColor: TAlphaColor;
      const LeadIcon, TrailIcon: WideString): Integer;
    function TagCount: Integer;
    function GetTagID(FTagID: Integer): Integer;
    function GetTagText(FTagText: Integer): WideString;
    function GetTagColor(FTagColor: Integer): TAlphaColor;
    function IsChecked(ID: Integer): Boolean;
    procedure OnTagChecked(Event: TPixieTagCheckedEvent);
    procedure OnChanged(Event: TNotifyEvent);
    function GetObject: TFmxObject;
    function Handle: TFmxObject;
  end;

function InitPixieTagBar: FPixieTagBar;
  external 'InitPixieTagBar@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixiePaintBox
// =============================================================================
type
  TPixiePaintBoxEvent = procedure(Sender: TObject);
  TPixiePenStyle = (ppsSolid, ppsDash, ppsDot, ppsClear);
  TPixieBrushStyle = (pbsSolid, pbsClear);
  TPixieDrawingFontStyle = (pfsBold, pfsItalic);
  TPixieDrawingFontStyles = set of TPixieDrawingFontStyle;
  TPixieTextAlign = (ptaLeft, ptaRight, ptaCenter,
    ptaJustify, ptaBlockCenter, ptaBlockLeft, ptaBlockRight);

  TPixieVerticalAlign = (pvaBaseline, pvaSub, pvaSuper, pvaTop,
    pvaTextTop, pvaMiddle, pvaBottom, pvaTextBottom);

  FPixiePaintBox = interface(IUnknown)
    '{7D984A5E-4B46-49DE-80C4-D0A7DD34FE34}'
    procedure FCreate(FParent: TFmxObject);
    procedure Left(FLeft: Single);
    procedure Top(FTop: Single);
    procedure Width(FWidth: Single);
    procedure Height(FHeight: Single);
    procedure SetBounds(FLeft, FTop, FWidth, FHeight: Single);
    procedure Position(X, Y: Single);
    procedure Align(Al: TAlignLayout);
    procedure Margins(FLeft, FTop, FRight, FBottom: Single);
    procedure Padding(FLeft, FTop, FRight, FBottom: Single);
    procedure SetHint(const FText: WideString);
    procedure SetClipParent(FValue: Boolean);
    procedure SetClipChildren(FValue: Boolean);
    procedure BringToFront;
    procedure SendToBack;
    procedure FillBackground(FValue: Boolean);
    procedure BackgroundColor(FColor: TAlphaColor);
    procedure PenColor(FColor: TAlphaColor);
    procedure PenWidth(FWidth: Single);
    procedure PenStyle(FStyle: TPixiePenStyle);
    procedure BrushColor(FColor: TAlphaColor);
    procedure BrushStyle(FStyle: TPixieBrushStyle);
    procedure FontFamily(const FFamily: WideString);
    procedure FontSize(FSize: Single);
    procedure FontColor(FColor: TAlphaColor);
    procedure FontStyle(FStyle: TPixieDrawingFontStyles);
    procedure Line(X1, Y1, X2, Y2: Single);
    procedure Rectangle(X, Y, W, H: Single);
    procedure FillRect(X, Y, W, H: Single);
    procedure RoundRect(X, Y, W, H, Radius: Single);
    procedure Ellipse(X, Y, W, H: Single);
    procedure Circle(CX, CY, Radius: Single);
    procedure Arc(X, Y, W, H, StartAngle, SweepAngle: Single);
    procedure TextOut(X, Y: Single; const FText: WideString);
    procedure TextRect(X, Y, W, H: Single; const FText: WideString;
      FHorzAlign: TPixieTextAlign; FVertAlign: TPixieVerticalAlign);
    procedure SaveState;
    procedure RestoreState;
    procedure Opacity(FOpacity: Single);
    procedure Enabled(FEnabled: Boolean);
    procedure Visible(FVisible: Boolean);
    procedure HitTest(FEnabled: Boolean);
    procedure Repaint;
    function TextWidth(const FText: WideString): Single;
    function TextHeight: Single;
    function GetFillBackground: Boolean;
    function GetBackgroundColor: TAlphaColor;
    function GetLeft: Single;
    function GetTop: Single;
    function GetWidth: Single;
    function GetHeight: Single;
    function GetObject: TFmxObject;
    procedure OnPaint(Event: TPixiePaintBoxEvent);
    function Handle: TFmxObject;
  end;

function InitPixiePaintBox: FPixiePaintBox;
  external 'InitPixiePaintBox@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FPixieAudioPlayer
// =============================================================================
type
  FPixieAudioPlayer = interface(IUnknown)
    '{C25A7AE4-56FA-4A92-B7A1-6A4E5C1D6E8B}'
    procedure Open(const FileName: WideString;
      AutoPlay, Loop: Boolean);
    procedure Play;
    procedure Pause;
    procedure Stop;
    procedure Close;
    procedure ShutDown;
    procedure SetVolume(Value: Single);
    procedure Seek(PositionMs: Integer);
    function GetState: Integer;
    function GetPositionMs: Integer;
    function GetDurationMs: Integer;
    function GetOpening: Boolean;
    function GetErrorText: WideString;
    function GetCurrentFile: WideString;
  end;

function InitPixieAudioPlayer: FPixieAudioPlayer;
  external 'InitPixieAudioPlayer@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FStorageInfo
// =============================================================================
type
  TDriveType = (dtUnknown, dtNoRootDir, dtRemovable,
    dtFixed, dtRemote, dtCDROM, dtRAMDisk);

  FStorageInfo = interface(IUnknown)
    '{B1DFE8C4-D827-4D2C-A363-309320AFDC3F}'
    procedure Refresh;
    function Count: Integer;
    function Letter(const Index: Integer): WideString;
    function LetterToIndex(const Letter: WideString): Integer;
    function Name(const Index: Integer): WideString;
    function IsRemovable(const Index: Integer): Boolean;
    function MediaType(const Index: Integer): TDriveType;
    function SpaceFree(const Index: Integer): Double;
    function SpaceUsed(const Index: Integer): Double;
    function SpaceTotal(const Index: Integer): Double;
    function DiskLoad(const Index: Integer): Cardinal;
  end;

function InitStorageInfo: FStorageInfo;
  external 'InitStorageInfo@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FSystemInfo
// =============================================================================
type
  FSystemInfo = interface(IUnknown)
    '{06F37AEC-7E76-4EB2-ACB2-648FDE4012FD}'
    function OSCaption: WideString;
    function OSVersion: WideString;
    function OSBuildNumber: WideString;
    function GPUName: WideString;
    function GPUMemory: UInt64;
    function GPUFeatureLevel: WideString;
    function RamLoad: Cardinal;
    function TotalRam: Double;
    function FreeRam: Double;
    function UsedRam: Double;
    function CPUName: WideString;
    function CPUCores: Cardinal;
    function CPUThreads: Cardinal;
    function CPUSpeed: Cardinal;
    function CPULoad: Cardinal;
    function UserName: WideString;
    function UserDomain: WideString;
    function UserProfilePath: WideString;
    function UserType: TUserType;
    function UserIsElevated: Boolean;
  end;

function InitSystemInfo: FSystemInfo;
  external 'InitSystemInfo@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// Utils
// =============================================================================
function MbOrTb(Float: Extended; Decimal: Integer;
  const sMb, sGb, sTb: WideString): WideString;
  external 'MbOrTb@files:FMXPixie.dll stdcall delayload';
function MHzOrGHz(Float: Extended; Decimal: Integer): WideString;
  external 'MHzOrGHz@files:FMXPixie.dll stdcall delayload';
function ReadAllText(const FileName: WideString; out FText: WideString)
  : Boolean;
  external 'ReadAllText@files:FMXPixie.dll stdcall delayload';
function WriteAllText(const FileName, FText: WideString): Boolean;
  external 'WriteAllText@files:FMXPixie.dll stdcall delayload';
function AppendAllText(const FileName, FText: WideString): Boolean;
  external 'AppendAllText@files:FMXPixie.dll stdcall delayload';

// =============================================================================
// FMX ShutDown
// =============================================================================
procedure _FMXPixieShutDown(const UnInstall: Boolean);
  external 'FMXPixieShutDown@files:FMXPixie.dll stdcall delayload';
procedure _FMXPixieShutDownUn(const UnInstall: Boolean);
  external 'FMXPixieShutDown@{tmp}\FMXPixie.dll uninstallonly stdcall delayload';
function EndTask(HWND: HWND; fShutDown, fForce: BOOL): BOOL;
  external 'EndTask@user32.dll stdcall delayload';
function EndTaskUn(HWND: HWND; fShutDown, fForce: BOOL): BOOL;
  external 'EndTask@user32.dll uninstallonly stdcall delayload';

procedure FMXPixieShutDown;
begin
  _FMXPixieShutDown(False);
  EndTask(WizardForm.Handle, False, True);
end;

procedure FMXPixieShutDownUn;
begin
  _FMXPixieShutDownUn(True);
  EndTaskUn(UninstallProgressForm.Handle, False, True);
end;
