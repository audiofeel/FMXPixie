; ============================================================================
; FMXPixie — MarkdownView Demo
;
; Демонстрирует:
;   - отдельную FMX-форму с кастомным титлбаром (перетаскивание / свернуть / закрыть)
;   - TPixieMarkdownView с оформленным Markdown и прокруткой
;   - заголовки, списки, цитаты, таблицу, inline code и fenced code block
;   - OnAnchorClick: внешние HTTP(S)-ссылки открываются в браузере по умолчанию
;   - Zoom, перезагрузку Markdown-файла и переключение UseDefaultStyles
;
; Требуемые файлы проекта:
;   Modules\FMXPixieHandle.iss (с FPixieMarkdownView и OnAnchorClick)
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;   FMXPixie_MarkdownView_Demo.md
;
; Это демонстрация интерфейса, приложение не устанавливается.
; ============================================================================

#define DemoAppName "FMXPixie - MarkdownView Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie_MarkdownView_Demo
; SetupArchitecture=x64
SetupIconFile=Files\setup.ico

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
Source: "Files\FMXPixie_MarkdownView.md"; Flags: dontcopy

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  DEMO_FORM_WIDTH = 1000;
  DEMO_FORM_HEIGHT = 760;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;
  TOOLBAR_HEIGHT = 48;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  ToolbarView: FPixieHtmlView;
  ToolbarDoc: FPixieDocument;
  Markdown: FPixieMarkdownView;
  Elem: FPixieElement;

  MarkdownFileName: String;
  ZoomFactor: Double;

function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#111827;color:#e5e7eb;font-family:Segoe UI,Arial,sans-serif;font-size:13px;}' +
    '.titlebar{position:relative;width:100%;height:31px;line-height:31px;' +
    'background:#111827;border-bottom:1px solid #263247;overflow:hidden;}' +
    '.brand{margin-left:12px;color:#93c5fd;font-weight:bold;}' +
    '.subtitle{margin-left:9px;color:#94a3b8;font-size:11px;}' +
    '.controls{position:absolute;right:0;top:0;width:92px;height:31px;font-size:0;}' +
    '.button{display:inline-block;vertical-align:top;width:46px;height:31px;' +
    'line-height:30px;text-align:center;color:#d1d5db;cursor:pointer;font-size:22px;}' +
    '.min:hover{background:#25344b;color:#fff;}' +
    '.close{font-size:25px;line-height:27px;}' +
    '.close:hover{background:#dc2626;color:#fff;}' +
    '.button:active{background:#1d4ed8;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="brand">FMXPixie</span>' +
    '<span class="subtitle">MarkdownView / LIVE PREVIEW</span>' +
    '<div class="controls">' +
    '<div id="title-minimize" class="button min" title="Свернуть">−</div>' +
    '<div id="title-close" class="button close" title="Закрыть">×</div>' +
    '</div></div></body></html>';
end;

function BuildToolbarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{box-sizing:border-box;background:#0d1727;color:#cbd5e1;' +
    'font-family:Segoe UI,Arial,sans-serif;font-size:12px;padding:7px 12px;' +
    'border-bottom:1px solid #263247;}' +
    '.actions{white-space:nowrap;}' +
    '.action{display:inline-block;vertical-align:middle;margin-right:5px;padding:6px 10px;' +
    'background:#17243a;border:1px solid #334b69;color:#dbeafe;text-decoration:none;' +
    'line-height:16px;cursor:pointer;}' +
    '.action:hover{background:#243c5d;border-color:#60a5fa;color:#fff;}' +
    '.accent{background:#17345a;border-color:#315b8c;color:#bfdbfe;}' +
    '.status{display:inline-block;vertical-align:middle;margin-left:7px;color:#94a3b8;' +
    'font-size:11px;overflow:hidden;}' +
    '</style></head><body>' +
    '<div class="actions">' +
    '<a id="reload-markdown" class="action accent" href="#">↻ Перезагрузить Markdown</a>' +
    '<a id="zoom-out" class="action" href="#">−</a>' +
    '<a id="zoom-reset" class="action" href="#">100%</a>' +
    '<a id="zoom-in" class="action" href="#">+</a>' +
    '<a id="toggle-styles" class="action" href="#">UseDefaultStyles</a>' +
    '<span id="toolbar-status" class="status">Готово · внешние ссылки открываются в браузере</span>' +
    '</div></body></html>';
end;

function BuildMarkdownCss: String;
begin
  Result :=
    'body { background: #0d1727; color: #dbe4f0; ' +
    'font-family: "Segoe UI", Arial, sans-serif; font-size: 14px; ' +
    'line-height: 1.6; padding: 24px 30px 38px; } ' +
    'h1 { color: #f8fafc; font-size: 30px; padding-bottom: 12px; ' +
    'border-bottom: 2px solid #26364f; margin-top: 3px; margin-bottom: 14px; } ' +
    'h2 { color: #93c5fd; font-size: 21px; margin-top: 30px; ' +
    'padding-bottom: 6px; border-bottom: 1px solid #263247; } ' +
    'h3 { color: #bfdbfe; font-size: 16px; } ' +
    'p { margin-top: 9px; margin-bottom: 10px; } ' +
    'a { color: #7dd3fc; text-decoration: underline; } ' +
    'a:hover { color: #86efac; } ' +
    'strong { color: #f8fafc; } ' +
    'blockquote { background: #101a2b; border-left: 3px solid #60a5fa; ' +
    'color: #cbd5e1; margin: 16px 0; padding: 9px 15px; } ' +
    'code { background: #17243a; color: #a7f3d0; padding: 2px 5px; } ' +
    'pre { background: #07101f; border: 1px solid #263247; padding: 14px; margin: 13px 0; } ' +
    'pre code { background: transparent; color: #c7d2fe; padding: 0; } ' +
    'table { border-collapse: collapse; width: 100%; margin: 14px 0; } ' +
    'th, td { border: 1px solid #334155; padding: 8px 10px; } ' +
    'th { background: #17243a; color: #bfdbfe; } ' +
    'hr { border: 0; border-top: 1px solid #263247; margin: 24px 0; } ' +
    'li { margin-top: 4px; margin-bottom: 5px; }';
end;

function BooleanText(Value: Boolean): String;
begin
  if Value then
    Result := 'TRUE'
  else
    Result := 'FALSE';
end;

procedure SetStatus(const S: String);
var
  H: NativeInt;
begin
  H := ToolbarDoc.GetElementById('toolbar-status');
  if H <> 0 then
  begin
    ToolbarDoc.SetElementText(H, S);
    ToolbarDoc.Changed;
  end;
  Log('FMXPixie MarkdownView: ' + S);
end;

procedure SetZoom(NewZoom: Double);
begin
  if NewZoom < 0.75 then NewZoom := 0.75;
  if NewZoom > 1.50 then NewZoom := 1.50;
  ZoomFactor := NewZoom;
  Markdown.Zoom(ZoomFactor);
  SetStatus('Масштаб Markdown: ' + IntToStr(Round(ZoomFactor * 100)) + '%');
end;

procedure CloseDemo;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
  NewStyles: Boolean;
begin
  Result := False;
  if El = nil then Exit;

  H := NativeInt(El);
  Id := '';
  while H <> 0 do
  begin
    Elem.FCreate(H);
    Id := Elem.GetAttr('id', '');
    if Id <> '' then Break;
    H := Elem.Parent;
  end;
  if H = 0 then Exit;

  if Id = 'title-minimize' then
  begin
    FMXForm.Minimize;
    Result := True;
    Exit;
  end;

  if Id = 'title-close' then
  begin
    CloseDemo;
    Result := True;
    Exit;
  end;

  if Id = 'reload-markdown' then
  begin
    Markdown.LoadMarkdownFromFile(MarkdownFileName);
    SetStatus('Markdown-файл перезагружен');
    Result := True;
    Exit;
  end;

  if Id = 'zoom-out' then
  begin
    SetZoom(ZoomFactor - 0.10);
    Result := True;
    Exit;
  end;

  if Id = 'zoom-reset' then
  begin
    SetZoom(1.0);
    Result := True;
    Exit;
  end;

  if Id = 'zoom-in' then
  begin
    SetZoom(ZoomFactor + 0.10);
    Result := True;
    Exit;
  end;

  if Id = 'toggle-styles' then
  begin
    NewStyles := not Markdown.GetUseDefaultStyles;
    Markdown.SetUseDefaultStyles(NewStyles);
    if NewStyles then
      SetStatus('UseDefaultStyles включён')
    else
      SetStatus('UseDefaultStyles выключен');
    Result := True;
    Exit;
  end;
end;

procedure MarkdownAnchorClick(Sender, El: TObject; const Url: String);
var
  UrlLower: String;
  ResultCode: Integer;
begin
  Log('FMXPixie MarkdownView: OnAnchorClick URL=' + Url);
  UrlLower := Lowercase(Url);

  if (Copy(UrlLower, 1, 7) = 'http://') or
     (Copy(UrlLower, 1, 8) = 'https://') then
  begin
    if ShellExec('', Url, '', '', SW_SHOWNORMAL, ewNoWait, ResultCode) then
      SetStatus('Ссылка открыта в браузере по умолчанию')
    else
      SetStatus('Не удалось открыть ссылку. Код: ' + IntToStr(ResultCode));
    Exit;
  end;

  if Copy(UrlLower, 1, 7) = 'mailto:' then
  begin
    if ShellExec('', Url, '', '', SW_SHOWNORMAL, ewNoWait, ResultCode) then
      SetStatus('Открыт почтовый клиент')
    else
      SetStatus('Не удалось открыть почтовую ссылку. Код: ' + IntToStr(ResultCode));
    Exit;
  end;

  SetStatus('Получен URL: ' + Url);
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TitleView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

function InitializeSetup(): Boolean;
begin
  FMXForm := InitFormHandle;
  TitleView := InitPixieHtmlView;
  ToolbarView := InitPixieHtmlView;
  ToolbarDoc := InitPixieDocument;
  Markdown := InitPixieMarkdownView;
  Elem := InitPixieElement;
  ZoomFactor := 1.0;
  Result := True;
end;

procedure InitializeWizard;
begin
  MarkdownFileName := ExpandConstant('{tmp}') + '\FMXPixie_MarkdownView.md';
  ExtractTemporaryFile('FMXPixie_MarkdownView.md');

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FFF3F5F8, '', True);

  { Отдельный верхний слой: титлбар не прокручивается вместе с Markdown. }
  TitleView.FCreate(FMXForm.Handle);
  TitleView.SetBounds(0, 0, DEMO_FORM_WIDTH, TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@ViewMouseDown);
  TitleView.LoadFromString(BuildTitleBarHtml);

  ToolbarView.FCreate(FMXForm.Handle);
  ToolbarView.SetBounds(0, TITLEBAR_HEIGHT, DEMO_FORM_WIDTH, TOOLBAR_HEIGHT);
  ToolbarView.ColorScheme(pcsDark);
  ToolbarView.OnElementClick(@ElementClick);
  ToolbarView.LoadFromString(BuildToolbarHtml);
  ToolbarDoc.FCreate(ToolbarView.GetDocument);

  Markdown.FCreate(FMXForm.Handle);
  Markdown.SetBounds(0, TITLEBAR_HEIGHT + TOOLBAR_HEIGHT,
    DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT - TOOLBAR_HEIGHT);
  Markdown.SetHint('Markdown content rendered by TPixieMarkdownView');
  Markdown.SetUseDefaultStyles(False);
  Markdown.UserCss(BuildMarkdownCss);
  Markdown.Zoom(ZoomFactor);
  Markdown.HitTest(True);
  Markdown.OnAnchorClick(@MarkdownAnchorClick);
  Markdown.LoadMarkdownFromFile(MarkdownFileName);

  SetStatus('Готово · нажми ссылку в Markdown, чтобы открыть её в браузере');
  FMXForm.Show;
  Log('FMXPixie MarkdownView Demo: ready');
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := False;
end;

procedure DeinitializeSetup;
begin
  FMXPixieShutDown;
end;
