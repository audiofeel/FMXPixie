; ============================================================================
; Демонстрация FMXPixie для Inno Setup
; Демонстрирует обёртку FMXPixie DLL для интерфейсов установщика и запуска программы. 
;
; Необходимые файлы проекта:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;
; Представленные здесь протестированные шаблоны API:
;   - создание хост-формы FMX и подключение отдельных заголовков и содержимого TPixieHtmlViews
;   - загрузка HTML из строки с базовым URL
;   - CSS :hover
;   - обработка кликов по HTML-элементам и обратных вызовов по ссылкам
;   - пакетная обработка обновлений DOM (BeginUpdate / EndUpdate)
;   - выбор элементов по CSS-селектору
;   - изменение CSS-класса / встроенного стиля с помощью скрипта Inno Pascal
;   - изменение масштаба
;   - экспорт отрендеренной страницы в PDF / PNG
;   - запуск внешнего исполняемого файла (пример с Notepad)
;
; Эта демонстрация не устанавливает настоящее приложение. Индикатор выполнения симулирован.
; ============================================================================

#define DemoAppName "FMXPixie - Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Demo
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
  DEMO_FORM_WIDTH = 900;
  DEMO_FORM_HEIGHT = 690;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92; // две кнопки по 46 px справа

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;
  FoundList: FPixieElementList;

  TempDir: String;
  ClickCount: Integer;
  DemoProgress: Integer;
  ZoomFactor: Double;
  SystemEnabled: Boolean;
  DesktopShortcut: Boolean;
  LaunchAfterInstall: Boolean;

  PdfFileName: String;
  PngFileName: String;

function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html>' +
    '<html><head><meta charset="utf-8">' +
    '<style>' +
    'html, body { width: 100%; height: 32px; margin: 0; padding: 0;' +
    '  overflow: hidden; }' +
    'body { background: #111827; color: #e5e7eb;' +
    '  font-family: "Segoe UI", Arial, sans-serif; font-size: 14px; }' +
    '.titlebar { position: relative; width: 100%; height: 31px; overflow: hidden;' +
    '  background: #111827; border-bottom: 1px solid #263247;' +
    '  color: #e5e7eb; line-height: 31px; }' +
    '.title-caption { margin-left: 10px; color: #93c5fd; font-weight: bold; }' +
    '.title-controls { position: absolute; top: 0; right: 0; width: 92px;' +
    '  height: 31px; font-size: 0; }' +
    '.title-button { display: inline-block; vertical-align: top; overflow: hidden;' +
    '  width: 46px; height: 31px; line-height: 31px; text-align: center;' +
    '  color: #d1d5db; cursor: pointer; font-size: 23px; }' +
    '.title-close { font-size: 25px; line-height: 28px; }' +
    '.title-minimize:hover { background: #25344b; color: #ffffff; }' +
    '.title-close:hover { background: #dc2626; color: #ffffff; }' +
    '.title-button:active { background: #1d4ed8; }' +
    '</style></head><body>' +
    '<div id="demo-titlebar" class="titlebar">' +
    '  <span class="title-caption">FMXPixie Demo</span>' +
    '  <div class="title-controls">' +
    '    <div id="title-minimize" class="title-button title-minimize" title="Свернуть">−</div>' +
    '    <div id="title-close" class="title-button title-close" title="Закрыть">×</div>' +
    '  </div>' +
    '</div>' +
    '</body></html>';
end;

function BuildDemoHtml: String;
begin
  Result :=
    '<!doctype html>' +
    '<html><head><meta charset="utf-8">' +
    '<style>' +
    'body {' +
    '  margin: 0; padding: 22px; background: transparent; color: #e5e7eb;' +
    '  font-family: "Segoe UI", Arial, sans-serif; font-size: 14px;' +
    '}' +
    '.topline { background: #111827; border: 1px solid #263247; padding: 18px;' +
    '  margin-bottom: 14px; }' +
    '.brand { color: #93c5fd; font-size: 25px; font-weight: bold; }' +
    '.sub { color: #9ca3af; margin-top: 4px; }' +
    '.tag { color: #a7f3d0; border: 1px solid #276749; padding: 4px 8px;' +
    '  margin-top: 10px; display: inline-block; }' +
    '.panel { background: #111827; border: 1px solid #263247; padding: 16px;' +
    '  margin-bottom: 14px; }' +
    '.section-title { color: #93c5fd; font-weight: bold; margin-bottom: 10px; }' +
    '.muted { color: #9ca3af; }' +
    '.button-row { margin-top: 10px; }' +
    'button { background: #25344b; color: #f9fafb; border: 1px solid #40516b;' +
    '  padding: 9px 12px; margin: 3px 5px 3px 0; cursor: pointer; }' +
    'button:hover { background: #2563a6; border-color: #60a5fa; }' +
    'button:active { background: #174477; }' +
    '.primary { background: #1d4ed8; border-color: #3b82f6; }' +
    '.feature-card { background: #0f172a; border: 1px solid #263247;' +
    '  padding: 12px; margin: 8px 0; }' +
    '.feature-card:hover { background: #17243a; border-color: #3b82f6; }' +
    '.check-row { margin: 9px 0; }' +
    '.check { display: inline-block; width: 15px; height: 15px;' +
    '  border: 1px solid #64748b; margin-right: 8px; }' +
    '.check.is-on { background: #16a34a; border-color: #4ade80; }' +
    '.state-pill { display: inline-block; padding: 5px 9px; margin-left: 5px;' +
    '  border: 1px solid #276749; color: #a7f3d0; }' +
    '.state-pill.is-off { color: #fecaca; border-color: #9f1239; }' +
    '.progress-track { height: 14px; background: #263247; margin: 8px 0;' +
    '  border: 1px solid #40516b; }' +
    '.progress-fill { height: 14px; width: 0%; background: #22c55e; }' +
    '.status { background: #07101f; border: 1px solid #263247; padding: 10px;' +
    '  color: #bfdbfe; margin-top: 12px; }' +
    'a { color: #93c5fd; text-decoration: underline; }' +
    'a:hover { color: #4ade80; }' +
    '.small { font-size: 12px; color: #9ca3af; }' +
    '</style></head><body>' +

    '<div class="topline">' +
    '  <div class="brand">FMXPixie</div>' +
    '  <div class="sub">HTML + CSS внутри FMX-формы Inno Setup</div>' +
    '  <div class="tag">DEMO · INSTALLER / LAUNCHER UI</div>' +
    '</div>' +

    '<div class="panel">' +
    '  <div class="section-title">01 / СОБЫТИЯ И DOM</div>' +
    '  <div class="muted">Кнопки вызывают Pascal Script через OnElementClick.' +
    ' Изменение текста и классов выполняется через FPixieDocument / FPixieElement.</div>' +
    '  <div class="button-row">' +
    '    <button id="btn-counter" class="primary">Увеличить счётчик</button>' +
    '    <button id="btn-toggle">Переключить состояние</button>' +
    '    <button id="btn-query">QuerySelectorAll</button>' +
    '    <button id="btn-close">Закрыть демо</button>' +
    '  </div>' +
    '  <div class="feature-card" id="feature-css"><b>CSS :hover</b>' +
    '    <div class="muted">Наведи курсор на эту карточку или на кнопку.</div></div>' +
    '  <div class="feature-card" id="feature-events"><b>События</b>' +
    '    <div class="muted">Клик по кнопке и HTML-ссылке обрабатывается в ISS.</div></div>' +
    '  <div class="feature-card" id="feature-dom"><b>Обновление DOM</b>' +
    '    <div class="muted">Изменения объединяются через BeginUpdate / EndUpdate.</div></div>' +
    '  <div>Счётчик: <b id="counter-value">0</b>' +
    '    &nbsp; Состояние: <span id="state-value" class="state-pill">Включено</span></div>' +
    '  <div id="query-result" class="small">QuerySelectorAll ещё не запускался.</div>' +
    '</div>' +

    '<div class="panel">' +
    '  <div class="section-title">02 / ПАРАМЕТРЫ УСТАНОВКИ</div>' +
    '  <div class="muted">Это демонстрационные флаги. В реальном установщике их значения' +
    ' используются при создании ярлыков, выборе компонентов и запуске приложения.</div>' +
    '  <div class="check-row"><div id="opt-desktop" class="check is-on"></div>' +
    '    Создать ярлык на рабочем столе' +
    '    <span id="desktop-value" class="small">Включено</span></div>' +
    '  <div class="check-row"><div id="opt-launch" class="check"></div>' +
    '    Запустить приложение после установки' +
    '    <span id="launch-value" class="small">Выключено</span></div>' +
    '  <div class="section-title">Пример обновления прогресса</div>' +
    '  <div class="progress-track"><div id="progress-fill" class="progress-fill"></div></div>' +
    '  <div>Прогресс: <b id="progress-value">0%</b></div>' +
    '  <div class="button-row"><button id="btn-progress">Симулировать +10%</button>' +
    '    <button id="btn-reset">Сбросить демо</button></div>' +
    '</div>' +

    '<div class="panel">' +
    '  <div class="section-title">03 / ФУНКЦИИ HTML VIEW</div>' +
    '  <div class="button-row">' +
    '    <button id="btn-zoom-in">Увеличить масштаб</button>' +
    '    <button id="btn-zoom-reset">Масштаб 100%</button>' +
    '    <button id="btn-pdf">Экспорт PDF</button>' +
    '    <button id="btn-png">Экспорт PNG</button>' +
    '    <button id="btn-launch-notepad">Запустить Блокнот</button>' +
    '  </div>' +
    '  <div class="muted">Масштаб: <b id="zoom-value">100%</b></div>' +
    '  <div style="margin-top:10px">' +
    '    Внешняя ссылка — только проверка события, она не открывает браузер:' +
    '    <a id="demo-anchor" href="https://example.com/">OnAnchorClick</a>' +
    '  </div>' +
    '  <div class="small" style="margin-top:8px">PDF и PNG сохраняются во временный каталог Inno Setup.</div>' +
    '  <div id="demo-status" class="status">Готово. Нажми любую кнопку для демонстрации.</div>' +
    '</div>' +

    '<div class="small">FMXPixie Demo · демонстрационный интерфейс, без установки реального приложения.</div>' +
    '</body></html>';
end;

// ---------------------------------------------------------------------------
// DOM helpers
// ---------------------------------------------------------------------------
procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, S);
end;

procedure SetClassById(const Id, ClassName: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then
    Exit;
  Elem.FCreate(H);
  Elem.SetAttr('class', ClassName);
end;

procedure SetStatus(const S: String);
begin
  SetTextById('demo-status', S);
  Log('FMXPixie Demo: ' + S);
end;

procedure UpdateProgressVisual;
var
  H: NativeInt;
begin
  H := Doc.GetElementById('progress-fill');
  if H <> 0 then
  begin
    Elem.FCreate(H);
    Elem.SetAttr('style', 'width:' + IntToStr(DemoProgress) + '%');
  end;
  SetTextById('progress-value', IntToStr(DemoProgress) + '%');
end;

procedure ApplyInitialState;
begin
  Doc.BeginUpdate;
  try
    SetTextById('counter-value', IntToStr(ClickCount));
    SetTextById('state-value', 'Включено');
    SetClassById('state-value', 'state-pill');
    SetClassById('opt-desktop', 'check is-on');
    SetClassById('opt-launch', 'check');
    SetTextById('desktop-value', 'Включено');
    SetTextById('launch-value', 'Выключено');
    SetTextById('query-result', 'QuerySelectorAll ещё не запускался.');
    SetTextById('zoom-value', '100%');
    UpdateProgressVisual;
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure ToggleOption(const Id: String);
begin
  if Id = 'opt-desktop' then
  begin
    DesktopShortcut := not DesktopShortcut;
    if DesktopShortcut then
    begin
      SetClassById('opt-desktop', 'check is-on');
      SetTextById('desktop-value', 'Включено');
    end
    else
    begin
      SetClassById('opt-desktop', 'check');
      SetTextById('desktop-value', 'Выключено');
    end;
    SetStatus('Параметр ярлыка изменён. В реальном проекте используй DesktopShortcut при создании ярлыка.');
  end
  else if Id = 'opt-launch' then
  begin
    LaunchAfterInstall := not LaunchAfterInstall;
    if LaunchAfterInstall then
    begin
      SetClassById('opt-launch', 'check is-on');
      SetTextById('launch-value', 'Включено');
    end
    else
    begin
      SetClassById('opt-launch', 'check');
      SetTextById('launch-value', 'Выключено');
    end;
    SetStatus('Параметр запуска изменён. В реальном проекте проверяй LaunchAfterInstall в конце установки.');
  end;
  Doc.Changed;
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

// ---------------------------------------------------------------------------
// Обработка кликов: подъем по родительским элементам DOM до ближайшего 
// элемента с идентификатором.
// ---------------------------------------------------------------------------
function ElementClick(Sender, El: TObject): Boolean;
var
  H: NativeInt;
  Id: String;
  ResultCode: Integer;
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

  if (Id = 'opt-desktop') or (Id = 'opt-launch') then
  begin
    Doc.BeginUpdate;
    try
      ToggleOption(Id);
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

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

  if Id = 'btn-counter' then
  begin
    Inc(ClickCount);
    Doc.BeginUpdate;
    try
      SetTextById('counter-value', IntToStr(ClickCount));
      SetStatus('Клик обработан в Pascal Script; текст в HTML обновлён через DOM.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-toggle' then
  begin
    SystemEnabled := not SystemEnabled;
    Doc.BeginUpdate;
    try
      if SystemEnabled then
      begin
        SetClassById('state-value', 'state-pill');
        SetTextById('state-value', 'Включено');
      end
      else
      begin
        SetClassById('state-value', 'state-pill is-off');
        SetTextById('state-value', 'Выключено');
      end;
      if SystemEnabled then
        SetStatus('Состояние включено.')
      else
        SetStatus('Состояние выключено.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-query' then
  begin
    FoundList := InitPixieElementList;
    FoundList.FCreate(Doc.QuerySelectorAll('.feature-card'));
    SetTextById('query-result', 'QuerySelectorAll(''.feature-card'') нашёл карточек: ' +
      IntToStr(FoundList.Count));
    SetStatus('CSS-селектор выполнен через FPixieDocument.QuerySelectorAll.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-progress' then
  begin
    DemoProgress := DemoProgress + 10;
    if DemoProgress > 100 then
      DemoProgress := 0;
    Doc.BeginUpdate;
    try
      UpdateProgressVisual;
      SetStatus('Прогресс обновлён из Inno Pascal Script: ' + IntToStr(DemoProgress) + '%.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-reset' then
  begin
    ClickCount := 0;
    DemoProgress := 0;
    ZoomFactor := 1.0;
    SystemEnabled := True;
    DesktopShortcut := True;
    LaunchAfterInstall := False;
    View.Zoom(ZoomFactor);
    Doc.BeginUpdate;
    try
      ApplyInitialState;
      SetStatus('Демо сброшено к начальному состоянию.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-zoom-in' then
  begin
    ZoomFactor := ZoomFactor + 0.1;
    if ZoomFactor > 1.6 then
      ZoomFactor := 1.6;
    View.Zoom(ZoomFactor);
    SetTextById('zoom-value', IntToStr(Round(ZoomFactor * 100)) + '%');
    SetStatus('Масштаб HTML: ' + IntToStr(Round(ZoomFactor * 100)) + '%.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-zoom-reset' then
  begin
    ZoomFactor := 1.0;
    View.Zoom(ZoomFactor);
    SetTextById('zoom-value', '100%');
    SetStatus('Масштаб возвращён к 100%.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-pdf' then
  begin
    PdfFileName := TempDir + '\FMXPixie_Demo.pdf';
    View.SaveAsPdf(PdfFileName);
    if FileExists(PdfFileName) then
      SetStatus('PDF сохранён: ' + PdfFileName)
    else
      SetStatus('SaveAsPdf завершился, но файл не найден: ' + PdfFileName);
    Result := True;
    Exit;
  end;

  if Id = 'btn-png' then
  begin
    PngFileName := TempDir + '\FMXPixie_Demo.png';
    View.SaveAsPng(PngFileName, DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
    if FileExists(PngFileName) then
      SetStatus('PNG сохранён: ' + PngFileName)
    else
      SetStatus('SaveAsPng завершился, но файл не найден: ' + PngFileName);
    Result := True;
    Exit;
  end;

  if Id = 'btn-launch-notepad' then
  begin
    if Exec(ExpandConstant('{sys}\notepad.exe'), '', '', SW_SHOWNORMAL,
      ewNoWait, ResultCode) then
      SetStatus('Блокнот запущен. В своём лаунчере замени путь на EXE приложения.')
    else
      SetStatus('Не удалось запустить Блокнот. Код ошибки: ' + IntToStr(ResultCode));
    Result := True;
    Exit;
  end;

  if Id = 'btn-close' then
  begin
    CloseSetup;
    Result := True;
    Exit;
  end;
end;

// ---------------------------------------------------------------------------
// Обратный вызов привязки: в этой демонстрации URL-адрес записывается в журнал
// и отображается в области статуса. Браузер не открывается автоматически.
// ---------------------------------------------------------------------------
procedure ViewAnchorClick(Sender, El: TObject; const Url: String);
begin
  Log('FMXPixie OnAnchorClick URL=' + Url);
  SetStatus('OnAnchorClick получен URL: ' + Url);
end;

procedure ViewAfterParse(Sender: TObject);
begin
  Log('FMXPixie OnAfterParse');
end;

procedure ViewMouseEnter(Sender: TObject);
begin
  Log('FMXPixie OnMouseEnter');
end;

procedure ViewMouseLeave(Sender: TObject);
begin
  Log('FMXPixie OnMouseLeave');
end;

// ---------------------------------------------------------------------------
// Пользовательская перетаскиваемая строка заголовка. Это событие относится 
// к TitleView, поэтому координаты являются локальными для независимого заголовка
// размером 32 пикселя, а не для прокручиваемого содержимого. 
// Крайние правые 92 пикселей зарезервированы для кнопок в строке заголовка. 
// ---------------------------------------------------------------------------
procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TitleView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

// ---------------------------------------------------------------------------
// Initialization
// ---------------------------------------------------------------------------
procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  TitleView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  Doc := InitPixieDocument;
  Elem := InitPixieElement;
  FoundList := InitPixieElementList;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  TempDir := ExpandConstant('{tmp}');

  ClickCount := 0;
  DemoProgress := 0;
  ZoomFactor := 1.0;
  SystemEnabled := True;
  DesktopShortcut := True;
  LaunchAfterInstall := False;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, True, True);

// Выделенный вид сверху: область содержимого и полоса прокрутки начинаются под ней,
// поэтому полосу прокрутки нельзя наложить на кнопки сворачивания и закрытия.
  TitleView.FCreate(FMXForm.Handle);
  TitleView.Left(0);
  TitleView.Top(0);
  TitleView.Width(DEMO_FORM_WIDTH);
  TitleView.Height(TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@ViewMouseDown);
  TitleView.LoadFromString(BuildTitleBarHtml);

// Основной прокручиваемый HTML-контент занимает только область под строкой заголовка.
  View.FCreate(FMXForm.Handle);
  View.Left(0);
  View.Top(TITLEBAR_HEIGHT);
  View.Width(DEMO_FORM_WIDTH);
  View.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.BaseUrl(TempDir + '\');
  View.Zoom(ZoomFactor);
  View.OnElementClick(@ElementClick);
  View.OnAnchorClick(@ViewAnchorClick);
  View.OnAfterParse(@ViewAfterParse);
  View.OnMouseEnter(@ViewMouseEnter);
  View.OnMouseLeave(@ViewMouseLeave);

  View.LoadFromStringUrl(BuildDemoHtml, TempDir + '\');
  Doc.FCreate(View.GetDocument);
  ApplyInitialState;

  SetStatus('Готово. HTML загружен из строки; CSS, события и DOM готовы к работе.');
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
