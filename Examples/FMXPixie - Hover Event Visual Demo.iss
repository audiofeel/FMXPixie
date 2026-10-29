; ============================================================================
; FMXPixie Hover Event Visual Demo/Test
;
; Три отдельные HTML-view в одном FMX-окне:
;   1. HeaderView — системоподобный заголовок, minimize/close.
;   2. View — тестовые карточки и исходное CSS :hover / :active.
;   3. MonitorView — экранные счётчики и история callback-событий.
;
; Ключевая изоляция: callback срабатывает в HeaderView или View, но обновляет
; DOM только MonitorView. DOM карточек не меняется при обработке hover-событий;
; CSS-подсветка остаётся штатным поведением Pixie.
;
; Журнал для основной проверки не требуется. JavaScript не используется.
; Требуются обновлённый Modules\FMXPixieHandle.iss и DLL с hover callback bridge.
; Файл следует компилировать рядом с существующим каталогом Modules.
; ============================================================================

#define DemoAppName "FMXPixie - Hover Event Visual Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Hover Event Visual Demo
//SetupArchitecture=x64
SetupIconFile=Files\setup.ico

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  DEMO_FORM_WIDTH = 960;
  DEMO_FORM_HEIGHT = 700;
  TITLEBAR_HEIGHT = 34;
  TITLEBAR_BUTTONS_WIDTH = 92;
  CONTENT_WIDTH = 555;

var
  FMXForm: FForm;
  HeaderView: FPixieHtmlView;
  View: FPixieHtmlView;
  MonitorView: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;
  TempDir: String;
  ViewEnterCount: Integer;
  ViewLeaveCount: Integer;
  ElementEnterCount: Integer;
  ElementLeaveCount: Integer;
  CardClickCount: Integer;
  DocumentReady: Boolean;
  CurrentHoverTarget: String;
  LastHoverEvent: String;
  LastEnterTarget: String;
  LastLeaveTarget: String;
  LastClickTarget: String;
  RecentEvent1: String;
  RecentEvent2: String;
  RecentEvent3: String;

function BuildTitlebarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;}' +
    'body{background:#17212f;color:#edf3fa;font-family:"Segoe UI",Arial,sans-serif;}' +
    '.titlebar{position:relative;width:100%;height:34px;line-height:33px;background:#17212f;border-bottom:1px solid #344255;overflow:hidden;}' +
    '.brand{margin-left:17px;color:#9dd8ce;font-size:12px;font-weight:bold;letter-spacing:1.3px;}' +
    '.title-note{margin-left:11px;color:#9ba9ba;font-size:10px;letter-spacing:.7px;}' +
    '.window-controls{position:absolute;right:0;top:0;width:92px;height:33px;font-size:0;}' +
    '.window-button{display:inline-block;vertical-align:top;width:46px;height:33px;line-height:32px;text-align:center;font-size:20px;color:#d7e0ec;cursor:pointer;}' +
    '.window-button:hover{background:#334155;color:#fff;}.window-close:hover{background:#c43c4a;color:#fff;}' +
    '</style></head><body><div class="titlebar">' +
    '<span class="brand">FMXPIXIE</span><span class="title-note">/ VISUAL HOVER CALLBACK TEST</span>' +
    '<div class="window-controls"><div id="title-minimize" class="window-button" title="Свернуть">−</div>' +
    '<div id="title-close" class="window-button window-close" title="Закрыть">×</div></div></div></body></html>';
end;

function BuildContentHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#f3f5f8;color:#202936;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.page{padding:18px 18px 14px 18px;}' +
    '.eyebrow{font-size:9px;font-weight:bold;letter-spacing:1.8px;color:#0f766e;text-transform:uppercase;}' +
    '.headline{margin:5px 0 5px 0;font-size:24px;line-height:1.1;font-weight:600;letter-spacing:-.5px;color:#17212f;}' +
    '.intro{margin:0;color:#617083;font-size:11px;line-height:1.45;}' +
    '.badges{margin-top:9px;}' +
    '.badge{display:inline-block;padding:5px 7px;margin-right:5px;border:1px solid #b7c8d7;background:#e9eff5;color:#42556a;font-size:8px;font-weight:bold;letter-spacing:.3px;}' +
    '.badge-ok{background:#e2f5f0;border-color:#a8dbd0;color:#0f766e;}' +
    '.section-head{margin-top:14px;margin-bottom:7px;display:flex;justify-content:space-between;align-items:center;}' +
    '.section-title{font-size:10px;font-weight:bold;letter-spacing:1px;color:#475569;text-transform:uppercase;}' +
    '.section-sub{font-size:9px;color:#8a96a5;}' +
    '.tiles{display:grid;grid-template-columns:1fr 1fr;gap:10px;}' +
    '.tile{height:132px;position:relative;padding:13px;border:1px solid #cfd8e2;background:#fff;cursor:pointer;overflow:hidden;}' +
    '.tile:hover{background:#e0f5f0;border-color:#109889;}' +
    '.tile:active{background:#c6ebe3;border-color:#087f73;}' +
    '.tile-top{display:flex;align-items:center;justify-content:space-between;}' +
    '.tile-number{display:inline-block;padding:4px 6px;background:#e9eef4;color:#63758a;font-size:9px;font-weight:bold;}' +
    '.tile:hover .tile-number{background:#0f766e;color:#fff;}' +
    '.tile-symbol{width:27px;height:27px;line-height:25px;border:1px solid #c9d5df;border-radius:50%;text-align:center;color:#718096;font-size:14px;}' +
    '.tile:hover .tile-symbol{background:#0f766e;border-color:#0f766e;color:#fff;}' +
    '.tile-title{margin-top:11px;font-size:14px;font-weight:600;color:#253244;}.tile:hover .tile-title{color:#075c55;}' +
    '.tile-desc{margin-top:4px;font-size:10px;line-height:1.35;color:#748195;}.tile:hover .tile-desc{color:#326e68;}' +
    '.tile-hint{position:absolute;right:11px;bottom:9px;font-size:8px;font-weight:bold;letter-spacing:.7px;color:#9aa6b5;}' +
    '.tile:hover .tile-hint{color:#0f766e;}' +
    '.css-note{margin-top:12px;padding:10px 11px;background:#eef6fb;border:1px solid #cadfeb;color:#49667b;font-size:10px;line-height:1.45;}' +
    '.css-note strong{color:#244c66;}' +
    '.footer{margin-top:12px;padding-top:8px;border-top:1px solid #d7dfe7;display:flex;justify-content:space-between;color:#8b97a5;font-size:8px;letter-spacing:.35px;}' +
    '</style></head><body><div class="page">' +
    '<div class="eyebrow">IN-ENGINE CSS REGRESSION</div>' +
    '<div class="headline">Наведение без JavaScript</div>' +
    '<p class="intro">Эти карточки проверяют старое поведение Pixie. CSS должен сам менять фон, рамку и цвет текста при :hover и возвращать исходный вид после ухода мыши.</p>' +
    '<div class="badges"><span class="badge badge-ok">CSS :hover / PIXIE</span><span class="badge">SEPARATE DOCUMENT FROM EVENT MONITOR</span></div>' +
    '<div class="section-head"><span class="section-title">01 / Объекты наведения</span><span class="section-sub">Наведи, убери, нажми</span></div>' +
    '<div class="tiles">' +
    '<div id="tile-alpha" class="tile"><div class="tile-top"><span class="tile-number">TARGET 01</span><span class="tile-symbol">↗</span></div><div class="tile-title">Alpha / Card</div><div class="tile-desc">Фон, рамка и текст меняются через CSS.</div><div class="tile-hint">HOVER ME</div></div>' +
    '<div id="tile-beta" class="tile"><div class="tile-top"><span class="tile-number">TARGET 02</span><span class="tile-symbol">✳</span></div><div class="tile-title">Beta / Tile</div><div class="tile-desc">Отдельный HTML-элемент с собственным id.</div><div class="tile-hint">HOVER ME</div></div>' +
    '<div id="tile-gamma" class="tile"><div class="tile-top"><span class="tile-number">TARGET 03</span><span class="tile-symbol">◇</span></div><div class="tile-title">Gamma / Item</div><div class="tile-desc">Переходи между карточками и вложенным текстом.</div><div class="tile-hint">HOVER ME</div></div>' +
    '<div id="tile-delta" class="tile"><div class="tile-top"><span class="tile-number">TARGET 04</span><span class="tile-symbol">◎</span></div><div class="tile-title">Delta / Panel</div><div class="tile-desc">Нажми для проверки прежнего click callback.</div><div class="tile-hint">HOVER + CLICK</div></div>' +
    '</div>' +
    '<div class="css-note"><strong>Проверка CSS:</strong> при наведении карточка становится мятно-зелёной; после ухода снова белая. Код Inno не задаёт цвет карточки. Счётчики находятся в другом HTML-документе, поэтому обновление панели не меняет DOM этой области.</div>' +
    '<div class="footer"><span>CSS :HOVER · CSS :ACTIVE</span><span>CONTENT VIEW / 555 × 666</span></div>' +
    '</div></body></html>';
end;

function BuildMonitorHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#f3f5f8;color:#202936;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;}' +
    '.page{padding:14px 13px;}' +
    '.eyebrow{font-size:9px;font-weight:bold;letter-spacing:1.6px;color:#0f766e;text-transform:uppercase;}' +
    '.headline{margin:5px 0 4px 0;font-size:20px;line-height:1.1;font-weight:600;color:#17212f;}' +
    '.intro{margin:0;color:#617083;font-size:10px;line-height:1.4;}' +
    '.status{display:inline-block;margin-top:8px;padding:5px 7px;background:#fff2df;border:1px solid #e8cda3;color:#92540b;font-size:8px;font-weight:bold;letter-spacing:.4px;}' +
    '.status-ok{background:#e2f5f0;border-color:#a8dbd0;color:#0f766e;}' +
    '.panel{margin-top:11px;border:1px solid #d1dae4;background:#fff;padding:11px;}' +
    '.panel-title{font-size:12px;font-weight:bold;color:#233144;margin-bottom:3px;}' +
    '.panel-copy{font-size:9px;line-height:1.4;color:#748195;margin-bottom:7px;}' +
    '.metric-list{border-top:1px solid #e4e9ef;}' +
    '.metric{display:flex;align-items:center;justify-content:space-between;padding:5px 0;border-bottom:1px solid #e4e9ef;font-size:9px;color:#5f6d7f;}' +
    '.metric strong{font-size:13px;color:#1f2937;font-variant-numeric:tabular-nums;}' +
    '.metric-click strong{color:#0f766e;}' +
    '.last-event{margin-top:8px;padding:7px 8px;background:#f0f4f8;border-left:3px solid #98a8bb;}' +
    '.last-label{font-size:8px;font-weight:bold;letter-spacing:.8px;color:#78869a;text-transform:uppercase;}' +
    '.last-value{margin-top:4px;font-size:11px;line-height:1.35;color:#334155;white-space:nowrap;overflow:hidden;}' +
    '.event-pair{display:grid;grid-template-columns:1fr 1fr;gap:7px;margin-top:8px;}' +
    '.event-chip{padding:7px 8px;border:1px solid #d7e2e9;}' +
    '.event-in{background:#e2f5f0;border-color:#a8dbd0;}.event-out{background:#fff2df;border-color:#e8cda3;}' +
    '.event-chip-label{font-size:8px;font-weight:bold;letter-spacing:.6px;color:#607184;}' +
    '.event-chip-value{margin-top:3px;font-size:10px;font-weight:bold;white-space:nowrap;overflow:hidden;color:#26384b;}' +
    '.history{margin-top:8px;padding:7px 8px;background:#f7f9fb;border:1px solid #e0e6ed;}' +
    '.history-head{font-size:8px;font-weight:bold;letter-spacing:.8px;color:#78869a;margin-bottom:3px;}' +
    '.history-row{height:15px;line-height:15px;font-size:9px;color:#45566b;white-space:nowrap;overflow:hidden;}' +
    '.test-note{margin-top:8px;padding:8px;background:#eef6fb;border:1px solid #cadfeb;color:#49667b;font-size:9px;line-height:1.4;}' +
    '.test-note strong{color:#244c66;}' +
    '.footer{margin-top:9px;padding-top:7px;border-top:1px solid #d7dfe7;display:flex;justify-content:space-between;color:#8b97a5;font-size:8px;letter-spacing:.25px;}' +
    '</style></head><body><div class="page">' +
    '<div class="eyebrow">LIVE EVENT TEST</div><div class="headline">Inno callback monitor</div>' +
    '<p class="intro">Счётчики и последние события ниже обновляет Pascal Script по фактическому callback. Журнал для основной проверки не нужен.</p>' +
    '<div id="callback-status" class="status">CALLBACK — WAITING FOR EVENT</div>' +
    '<div class="panel"><div class="panel-title">События, полученные Inno Setup</div>' +
    '<div class="panel-copy">Учитываются только 4 карточки и 2 кнопки заголовка. Вложенные элементы без собственного id отфильтрованы.</div>' +
    '<div class="metric-list">' +
    '<div class="metric"><span>OnElementMouseEvent / meEnter</span><strong id="element-enter-count">0</strong></div>' +
    '<div class="metric"><span>OnElementMouseEvent / meLeave</span><strong id="element-leave-count">0</strong></div>' +
    '<div class="metric metric-click"><span>OnElementClick / cards</span><strong id="element-click-count">0</strong></div>' +
    '<div class="metric"><span>Content View Enter / Leave</span><strong id="view-count">0 / 0</strong></div>' +
    '</div>' +
    '<div class="last-event"><div class="last-label">Последний callback</div><div id="last-hover-event" class="last-value">Ожидание meEnter или meLeave...</div></div>' +
    '<div class="event-pair"><div class="event-chip event-in"><div class="event-chip-label">ПОСЛЕДНИЙ ENTER</div><div id="last-enter" class="event-chip-value">—</div></div>' +
    '<div class="event-chip event-out"><div class="event-chip-label">ПОСЛЕДНИЙ LEAVE</div><div id="last-leave" class="event-chip-value">—</div></div></div>' +
    '<div class="last-event"><div class="last-label">Цель, отслеживаемая callback</div><div id="current-hover-target" class="last-value">(none)</div></div>' +
    '<div class="last-event"><div class="last-label">Последний клик по карточке</div><div id="last-click-target" class="last-value">(none)</div></div>' +
    '<div class="history"><div class="history-head">ПОСЛЕДНИЕ ТРИ CALLBACK-СОБЫТИЯ</div>' +
    '<div id="history-1" class="history-row">1. Ожидание...</div><div id="history-2" class="history-row">2. —</div><div id="history-3" class="history-row">3. —</div></div>' +
    '<div class="test-note"><strong>Два независимых результата:</strong> цвет карточки должен меняться CSS :hover в Content View; счётчики и события должны обновляться здесь, в отдельном документе.</div>' +
    '<div class="footer"><span>ENTER / LEAVE / CLICK</span><span>MONITOR VIEW</span></div>' +
    '</div></body></html>';
end;

procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, S);
end;

procedure UpdateViewFeedback;
begin
  if not DocumentReady then
    Exit;
  Doc.BeginUpdate;
  try
    SetTextById('view-count', IntToStr(ViewEnterCount) + ' / ' + IntToStr(ViewLeaveCount));
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure UpdateClickFeedback;
begin
  if not DocumentReady then
    Exit;
  Doc.BeginUpdate;
  try
    SetTextById('element-click-count', IntToStr(CardClickCount));
    SetTextById('last-click-target', LastClickTarget);
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

function IsHoverTestTarget(const Id: String): Boolean;
begin
  Result := (Id = 'tile-alpha') or (Id = 'tile-beta') or
    (Id = 'tile-gamma') or (Id = 'tile-delta') or
    (Id = 'title-minimize') or (Id = 'title-close');
end;

procedure UpdateHoverFeedback;
var
  H: NativeInt;
begin
  if not DocumentReady then
    Exit;

  Doc.BeginUpdate;
  try
    SetTextById('element-enter-count', IntToStr(ElementEnterCount));
    SetTextById('element-leave-count', IntToStr(ElementLeaveCount));
    SetTextById('callback-status', 'CALLBACK — RECEIVED');
    H := Doc.GetElementById('callback-status');
    if H <> 0 then
    begin
      Elem.FCreate(H);
      Elem.SetAttr('class', 'status status-ok');
    end;
    SetTextById('last-hover-event', LastHoverEvent);
    SetTextById('current-hover-target', CurrentHoverTarget);
    SetTextById('last-enter', LastEnterTarget);
    SetTextById('last-leave', LastLeaveTarget);
    SetTextById('history-1', '1. ' + RecentEvent1);
    SetTextById('history-2', '2. ' + RecentEvent2);
    SetTextById('history-3', '3. ' + RecentEvent3);
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure ViewElementMouseEvent(Sender, El: TObject;
  Event: TPixieMouseEvent);
var
  Id: String;
  EventName: String;
begin
  if El = nil then
    Exit;

  Elem.FCreate(NativeInt(El));
  Id := Elem.GetAttr('id', '');

  // Track only the exact elements with the six demo IDs. No ancestor lookup.
  if not IsHoverTestTarget(Id) then
    Exit;

  case Event of
    meEnter:
      begin
        Inc(ElementEnterCount);
        EventName := 'meEnter';
        CurrentHoverTarget := Id;
        LastEnterTarget := Id;
        LastHoverEvent := EventName + ' / ' + Id;
        RecentEvent3 := RecentEvent2;
        RecentEvent2 := RecentEvent1;
        RecentEvent1 := EventName + ' | ' + Id;
      end;
    meLeave:
      begin
        Inc(ElementLeaveCount);
        EventName := 'meLeave';
        if CurrentHoverTarget = Id then
          CurrentHoverTarget := '(none)';
        LastLeaveTarget := Id;
        LastHoverEvent := EventName + ' / ' + Id;
        RecentEvent3 := RecentEvent2;
        RecentEvent2 := RecentEvent1;
        RecentEvent1 := EventName + ' | ' + Id;
      end;
  else
    Exit;
  end;

  // Only MonitorView is changed here. The originating HTML document is untouched.
  UpdateHoverFeedback;
end;

procedure ViewMouseEnter(Sender: TObject);
begin
  Inc(ViewEnterCount);
  UpdateViewFeedback;
end;

procedure ViewMouseLeave(Sender: TObject);
begin
  Inc(ViewLeaveCount);
  UpdateViewFeedback;
end;

procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if (X < HeaderView.GetWidth - TITLEBAR_BUTTONS_WIDTH) and
     (Y >= 0) and (Y < TITLEBAR_HEIGHT) then
    FMXForm.StartWindowDrag;
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
begin
  Result := False;
  if El = nil then
    Exit;

  H := NativeInt(El);
  Id := '';
  while H <> 0 do
  begin
    Elem.FCreate(H);
    Id := Elem.GetAttr('id', '');
    if Id <> '' then
      Break;
    H := Elem.Parent;
  end;
  if H = 0 then
    Exit;

  if Id = 'title-minimize' then
  begin
    FMXForm.Minimize;
    Result := True;
    Exit;
  end;

  if Id = 'title-close' then
  begin
    CloseSetup;
    Result := True;
    Exit;
  end;

  if (Id = 'tile-alpha') or (Id = 'tile-beta') or
     (Id = 'tile-gamma') or (Id = 'tile-delta') then
  begin
    Inc(CardClickCount);
    LastClickTarget := Id;
    UpdateClickFeedback;
    Result := True;
    Exit;
  end;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  HeaderView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  MonitorView := InitPixieHtmlView;
  Doc := InitPixieDocument;
  Elem := InitPixieElement;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  TempDir := ExpandConstant('{tmp}');
  ViewEnterCount := 0;
  ViewLeaveCount := 0;
  ElementEnterCount := 0;
  ElementLeaveCount := 0;
  CardClickCount := 0;
  CurrentHoverTarget := '(none)';
  LastHoverEvent := 'Waiting for meEnter or meLeave...';
  LastEnterTarget := '—';
  LastLeaveTarget := '—';
  LastClickTarget := '(none)';
  RecentEvent1 := 'Waiting...';
  RecentEvent2 := '—';
  RecentEvent3 := '—';
  DocumentReady := False;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FFF3F5F8, '', True);

  HeaderView.FCreate(FMXForm.Handle);
  HeaderView.Left(0);
  HeaderView.Top(0);
  HeaderView.Width(DEMO_FORM_WIDTH);
  HeaderView.Height(TITLEBAR_HEIGHT);
  HeaderView.ColorScheme(pcsDark);
  HeaderView.BaseUrl(TempDir + '\');
  HeaderView.OnElementClick(@ElementClick);
  HeaderView.OnElementMouseEvent(@ViewElementMouseEvent);
  HeaderView.OnMouseDown(@HeaderMouseDown);
  HeaderView.LoadFromStringUrl(BuildTitlebarHtml, TempDir + '\');

  View.FCreate(FMXForm.Handle);
  View.Left(0);
  View.Top(TITLEBAR_HEIGHT);
  View.Width(CONTENT_WIDTH);
  View.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.BaseUrl(TempDir + '\');
  View.OnElementClick(@ElementClick);
  View.OnElementMouseEvent(@ViewElementMouseEvent);
  View.OnMouseEnter(@ViewMouseEnter);
  View.OnMouseLeave(@ViewMouseLeave);
  View.LoadFromStringUrl(BuildContentHtml, TempDir + '\');

  MonitorView.FCreate(FMXForm.Handle);
  MonitorView.Left(CONTENT_WIDTH);
  MonitorView.Top(TITLEBAR_HEIGHT);
  MonitorView.Width(DEMO_FORM_WIDTH - CONTENT_WIDTH);
  MonitorView.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  MonitorView.ColorScheme(pcsDark);
  MonitorView.BaseUrl(TempDir + '\');
  MonitorView.LoadFromStringUrl(BuildMonitorHtml, TempDir + '\');

  Doc.FCreate(MonitorView.GetDocument);
  DocumentReady := True;
  FMXForm.Show;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := False;
end;

procedure DeinitializeSetup;
begin
  FMXPixieShutDown;
end;
