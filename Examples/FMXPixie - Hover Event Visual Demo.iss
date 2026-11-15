#define DemoAppName "FMXPixie - Hover Event Visual Demo"
#define DemoAppVersion "2.0"

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
  CONTENT_WIDTH = 600;

var
  FMXForm: FForm;
  HeaderView: FPixieHtmlView;
  View: FPixieHtmlView;
  MonitorView: FPixieHtmlView;
  Doc: FPixieDocument;
  ContentDoc: FPixieDocument;
  Elem: FPixieElement;

  SelectedCore: Boolean;
  SelectedIcons: Boolean;
  SelectedThemes: Boolean;
  SelectedExamples: Boolean;
  CurrentHoverTarget: String;
  IsConfirmed: Boolean;
  DocumentReady: Boolean;

function BuildTitlebarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{margin:0;padding:0;width:100%;height:100%;overflow:hidden;}' +
    'body{background:#17212f;color:#edf3fa;font-family:"Segoe UI",Arial,sans-serif;}' +
    '.bar{position:relative;width:100%;height:34px;line-height:33px;background:#17212f;border-bottom:1px solid #344255;}' +
    '.brand{margin-left:17px;color:#9dd8ce;font-size:12px;font-weight:bold;letter-spacing:1.3px;}' +
    '.caption{margin-left:11px;color:#9ba9ba;font-size:10px;}' +
    '.controls{position:absolute;right:0;top:0;width:92px;height:33px;font-size:0;}' +
    '.control{display:inline-block;vertical-align:top;width:46px;height:33px;text-align:center;line-height:32px;color:#d7e0ec;font-size:20px;cursor:pointer;}' +
    '.control:hover{background:#334155;color:#fff;}.close:hover{background:#c43c4a;color:#fff;}' +
    '</style></head><body><div class="bar">' +
    '<span class="brand">PIXIE</span><span class="caption">Мастер установки</span>' +
    '<div class="controls"><div id="title-minimize" class="control">−</div>' +
    '<div id="title-close" class="control close">×</div></div></div></body></html>';
end;

function BuildContentHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#f3f5f8;color:#202936;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.page{padding:21px 22px;}' +
    '.eyebrow{font-size:9px;font-weight:bold;letter-spacing:1.7px;color:#0f766e;text-transform:uppercase;}' +
    '.headline{margin:7px 0 6px;font-size:24px;line-height:1.15;font-weight:650;color:#17212f;}' +
    '.intro{margin:0;color:#617083;font-size:11px;line-height:1.5;}' +
    '.tiles{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:22px;}' +
    '.tile{height:174px;padding:14px;border:1px solid #cfd8e2;background:#fff;cursor:pointer;overflow:hidden;}' +
    '.tile:hover{background:#e0f5f0;border-color:#109889;}' +
    '.tile:active{background:#c6ebe3;border-color:#087f73;}' +
    '.tile.selected{background:#e7f4ff;border:2px solid #2679ad;padding:13px;}' +
    '.top{display:flex;align-items:center;justify-content:space-between;}' +
    '.kind{padding:4px 6px;background:#e9eef4;color:#63758a;font-size:9px;font-weight:bold;}' +
    '.symbol{width:29px;height:29px;line-height:27px;border:1px solid #c9d5df;border-radius:50%;text-align:center;color:#718096;font-size:15px;}' +
    '.tile:hover .kind,.tile.selected .kind{background:#0f766e;color:#fff;}' +
    '.tile:hover .symbol,.tile.selected .symbol{background:#0f766e;border-color:#0f766e;color:#fff;}' +
    '.name{margin-top:15px;font-size:14px;font-weight:650;color:#253449;}' +
    '.desc{margin-top:6px;color:#718096;font-size:10px;line-height:1.45;}' +
    '.hint{margin-top:11px;color:#0f766e;font-size:9px;font-weight:bold;letter-spacing:.5px;}' +
    '.tile:not(.selected) .hint{color:#8a97a6;}' +
    '.footer{margin-top:17px;padding-top:11px;border-top:1px solid #d7dfe7;color:#7b8999;font-size:10px;}' +
    '</style></head><body><div class="page">' +
    '<div class="eyebrow">PIXIE Setup · Шаг 1 из 2</div>' +
    '<div class="headline">Выберите дополнительные компоненты</div>' +
    '<p class="intro">Наведите курсор, чтобы узнать, что входит в каждый набор. Нажмите на карточку, чтобы добавить компонент в установку.</p>' +
    '<div class="tiles">' +
    '<div id="tile-alpha" class="tile"><div class="top"><span class="kind">ОБЯЗАТЕЛЬНО</span><span class="symbol">✦</span></div><div class="name">Основные файлы</div><div class="desc">Ядро PIXIE и файлы, необходимые для запуска приложения.</div><div class="hint">ВХОДИТ В УСТАНОВКУ</div></div>' +
    '<div id="tile-beta" class="tile"><div class="top"><span class="kind">ОФОРМЛЕНИЕ</span><span class="symbol">◈</span></div><div class="name">Набор иконок</div><div class="desc">Готовые значки и изображения для оформления интерфейса.</div><div class="hint">ДОБАВИТЬ КОМПОНЕНТ</div></div>' +
    '<div id="tile-gamma" class="tile"><div class="top"><span class="kind">ВНЕШНИЙ ВИД</span><span class="symbol">◇</span></div><div class="name">Темы оформления</div><div class="desc">Дополнительные цветовые схемы и варианты внешнего вида.</div><div class="hint">ДОБАВИТЬ КОМПОНЕНТ</div></div>' +
    '<div id="tile-delta" class="tile"><div class="top"><span class="kind">ДЛЯ РАЗРАБОТЧИКА</span><span class="symbol">◎</span></div><div class="name">Примеры интерфейсов</div><div class="desc">Готовые страницы и шаблоны для собственных проектов.</div><div class="hint">ДОБАВИТЬ КОМПОНЕНТ</div></div>' +
    '</div>' +
    '<div class="footer">Выбранные компоненты появятся справа. Выбор можно изменить до подтверждения.</div>' +
    '</div></body></html>';
end;

function BuildMonitorHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#fff;color:#202936;font-family:"Segoe UI",Arial,sans-serif;}' +
    '.page{padding:22px 19px;}' +
    '.eyebrow{color:#0f766e;font-size:9px;font-weight:bold;letter-spacing:1.5px;text-transform:uppercase;}' +
    '.headline{margin-top:7px;color:#17212f;font-size:20px;font-weight:650;line-height:1.2;}' +
    '.copy{margin-top:8px;color:#617083;font-size:10px;line-height:1.5;}' +
    '.preview{margin-top:20px;padding:14px;background:#f0f5f8;border:1px solid #d5e0e8;min-height:130px;}' +
    '.preview-name{font-size:14px;font-weight:bold;color:#223247;}' +
    '.preview-copy{margin-top:8px;color:#617083;font-size:10px;line-height:1.5;}' +
    '.preview-state{margin-top:12px;padding:7px 8px;background:#e5f4f0;border:1px solid #b7ded4;color:#0f766e;font-size:9px;font-weight:bold;}' +
    '.selection{margin-top:22px;padding-top:15px;border-top:1px solid #dbe3ea;}' +
    '.selection-title{font-size:9px;font-weight:bold;letter-spacing:.8px;color:#68788b;text-transform:uppercase;}' +
    '.selection-count{margin-top:7px;color:#0f766e;font-size:21px;font-weight:650;}' +
    '.selection-list{margin-top:9px;min-height:92px;color:#526276;font-size:10px;line-height:1.6;white-space:pre-wrap;}' +
    '.tip{margin-top:14px;color:#8793a1;font-size:9px;line-height:1.45;}' +
    'button{width:100%;margin-top:18px;padding:11px 12px;background:#16766e;color:#fff;border:1px solid #2b9c90;border-radius:5px;font:12px "Segoe UI",Arial,sans-serif;font-weight:bold;cursor:pointer;}' +
    'button:hover{background:#209287;border-color:#16766e;}' +
    '</style></head><body><div class="page">' +
    '<div class="eyebrow">Предварительный просмотр</div>' +
    '<div class="headline">Состав установки</div>' +
    '<div class="copy">Наведите курсор на компонент слева, чтобы прочитать описание. Нажмите на карточку, чтобы добавить или убрать его.</div>' +
    '<div class="preview"><div id="preview-name" class="preview-name">Дополнительные компоненты</div>' +
    '<div id="preview-copy" class="preview-copy">Здесь появится описание выбранного вами компонента.</div>' +
    '<div id="preview-state" class="preview-state">Выберите компонент слева</div></div>' +
    '<div class="selection"><div class="selection-title">Вы выбрали</div>' +
    '<div id="selected-count" class="selection-count">0 компонентов</div>' +
    '<div id="selected-list" class="selection-list">Пока выбраны только обязательные файлы.</div></div>' +
    '<div class="tip">Основные файлы входят в установку автоматически и не могут быть удалены.</div>' +
    '<button id="btn-next">Далее</button>' +
    '</div></body></html>';
end;

function BuildSummaryHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#f3f5f8;color:#202936;font-family:"Segoe UI",Arial,sans-serif;}' +
    '.page{padding:27px 31px;}' +
    '.eyebrow{color:#0f766e;font-size:9px;font-weight:bold;letter-spacing:1.5px;text-transform:uppercase;}' +
    '.headline{margin-top:8px;color:#17212f;font-size:25px;font-weight:650;}' +
    '.copy{margin-top:8px;color:#617083;font-size:11px;line-height:1.5;}' +
    '.list{margin-top:24px;padding:18px 20px;background:#fff;border:1px solid #d5e0e8;color:#334155;font-size:12px;line-height:1.8;white-space:pre-wrap;}' +
    '.done{margin-top:16px;padding:12px 14px;background:#e5f4f0;border:1px solid #b7ded4;color:#0f766e;font-size:11px;line-height:1.5;}' +
    '.actions{margin-top:22px;padding-top:14px;border-top:1px solid #d7dfe7;}' +
    'button{padding:10px 18px;margin-right:8px;background:#eef3f7;color:#334155;border:1px solid #cbd5e1;border-radius:5px;font:12px "Segoe UI",Arial,sans-serif;cursor:pointer;}' +
    'button:hover{background:#dfe9f0;border-color:#91a6b9;}' +
    'button.primary{float:right;background:#16766e;border-color:#2b9c90;color:#fff;font-weight:bold;}' +
    'button.primary:hover{background:#209287;}' +
    '</style></head><body><div class="page">' +
    '<div class="eyebrow">PIXIE Setup · Шаг 2 из 2</div>' +
    '<div class="headline">Проверьте состав установки</div>' +
    '<div class="copy">В установку будут добавлены следующие компоненты:</div>' +
    '<div id="summary-list" class="list"></div>' +
    '<div id="summary-state" class="done">Если всё верно, подтвердите выбор. Вернуться и изменить его можно кнопкой «Назад».</div>' +
    '<div class="actions"><button id="btn-back">Назад</button><button id="btn-confirm" class="primary">Подтвердить выбор</button></div>' +
    '</div></body></html>';
end;

function SelectedCount: Integer;
begin
  Result := 1;
  if SelectedIcons then Inc(Result);
  if SelectedThemes then Inc(Result);
  if SelectedExamples then Inc(Result);
end;

function SelectedList: String;
begin
  Result := 'Основные файлы';
  if SelectedIcons then Result := Result + #13#10 + 'Набор иконок';
  if SelectedThemes then Result := Result + #13#10 + 'Темы оформления';
  if SelectedExamples then Result := Result + #13#10 + 'Примеры интерфейсов';
end;

procedure SetTextById(const Id, S: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H <> 0 then
    Doc.SetElementText(H, S);
end;

procedure SetTileSelected(const Id: String; Value: Boolean);
var
  H: NativeInt;
begin
  H := ContentDoc.GetElementById(Id);
  if H = 0 then Exit;
  Elem.FCreate(H);
  if Value then
    Elem.SetAttr('class', 'tile selected')
  else
    Elem.SetAttr('class', 'tile');
end;

procedure UpdateSelection;
var
  Count: Integer;
begin
  if not DocumentReady then Exit;

  SetTileSelected('tile-alpha', True);
  SetTileSelected('tile-beta', SelectedIcons);
  SetTileSelected('tile-gamma', SelectedThemes);
  SetTileSelected('tile-delta', SelectedExamples);
  ContentDoc.Changed;

  Count := SelectedCount;
  if Count = 1 then
    SetTextById('selected-count', '1 компонент')
  else
    SetTextById('selected-count', IntToStr(Count) + ' компонента');
  SetTextById('selected-list', SelectedList);
  Doc.Changed;
end;

procedure UpdateHoverPreview;
var
  NameText, DescriptionText, StateText: String;
begin
  if not DocumentReady then Exit;

  NameText := 'Дополнительные компоненты';
  DescriptionText := 'Наведите курсор на компонент слева, чтобы прочитать его описание.';
  StateText := 'Выберите компонент слева';

  if CurrentHoverTarget = 'tile-alpha' then
  begin
    NameText := 'Основные файлы';
    DescriptionText := 'Ядро PIXIE и файлы, необходимые для запуска приложения.';
    StateText := 'Входит в установку обязательно';
  end
  else if CurrentHoverTarget = 'tile-beta' then
  begin
    NameText := 'Набор иконок';
    DescriptionText := 'Готовые значки и изображения для оформления интерфейса.';
    if SelectedIcons then StateText := 'Уже добавлено в установку'
    else StateText := 'Нажмите карточку, чтобы добавить';
  end
  else if CurrentHoverTarget = 'tile-gamma' then
  begin
    NameText := 'Темы оформления';
    DescriptionText := 'Дополнительные цветовые схемы и варианты внешнего вида.';
    if SelectedThemes then StateText := 'Уже добавлено в установку'
    else StateText := 'Нажмите карточку, чтобы добавить';
  end
  else if CurrentHoverTarget = 'tile-delta' then
  begin
    NameText := 'Примеры интерфейсов';
    DescriptionText := 'Готовые страницы и шаблоны для собственных проектов.';
    if SelectedExamples then StateText := 'Уже добавлено в установку'
    else StateText := 'Нажмите карточку, чтобы добавить';
  end;

  SetTextById('preview-name', NameText);
  SetTextById('preview-copy', DescriptionText);
  SetTextById('preview-state', StateText);
  Doc.Changed;
end;

procedure ShowOptionsPage;
begin
  MonitorView.Visible(True);
  View.SetBounds(0, TITLEBAR_HEIGHT, CONTENT_WIDTH,
    DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.LoadFromString(BuildContentHtml);
  ContentDoc.FCreate(View.GetDocument);
  Doc.FCreate(MonitorView.GetDocument);
  UpdateSelection;
  UpdateHoverPreview;
end;

procedure ShowSummaryPage;
begin
  View.SetBounds(0, TITLEBAR_HEIGHT, DEMO_FORM_WIDTH,
    DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.LoadFromString(BuildSummaryHtml);
  MonitorView.Visible(False);
  Doc.FCreate(View.GetDocument);
  SetTextById('summary-list', SelectedList);
  SetTextById('summary-state', 'Проверьте выбранные компоненты. Вернитесь назад, если хотите изменить состав.');
  Doc.Changed;
  IsConfirmed := False;
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
    CloseSetup;
    Result := True;
    Exit;
  end;

  if (Id = 'tile-alpha') or (Id = 'tile-beta') or
     (Id = 'tile-gamma') or (Id = 'tile-delta') then
  begin
    if Id = 'tile-beta' then SelectedIcons := not SelectedIcons
    else if Id = 'tile-gamma' then SelectedThemes := not SelectedThemes
    else if Id = 'tile-delta' then SelectedExamples := not SelectedExamples;
    UpdateSelection;
    UpdateHoverPreview;
    Result := True;
    Exit;
  end;

  if Id = 'btn-next' then
  begin
    ShowSummaryPage;
    Result := True;
    Exit;
  end;

  if Id = 'btn-back' then
  begin
    ShowOptionsPage;
    Result := True;
    Exit;
  end;

  if Id = 'btn-confirm' then
  begin
    if IsConfirmed then
      CloseSetup
    else
    begin
      IsConfirmed := True;
      SetTextById('summary-state', 'Готово. Выбранные компоненты переданы установщику. В этом примере файлы не копируются.');
      SetTextById('btn-confirm', 'Завершить');
      Doc.Changed;
    end;
    Result := True;
    Exit;
  end;
end;

procedure ViewElementMouseEvent(Sender, El: TObject; Event: TPixieMouseEvent);
var
  Id: String;
begin
  if El = nil then Exit;
  Elem.FCreate(NativeInt(El));
  Id := Elem.GetAttr('id', '');
  if (Id <> 'tile-alpha') and (Id <> 'tile-beta') and
     (Id <> 'tile-gamma') and (Id <> 'tile-delta') then
    Exit;

  if Event = meEnter then
    CurrentHoverTarget := Id
  else if (Event = meLeave) and (CurrentHoverTarget = Id) then
    CurrentHoverTarget := '';

  UpdateHoverPreview;
end;

procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then Exit;
  if (X < HeaderView.GetWidth - TITLEBAR_BUTTONS_WIDTH) and
     (Y >= 0) and (Y < TITLEBAR_HEIGHT) then
    FMXForm.StartWindowDrag;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  HeaderView := InitPixieHtmlView;
  View := InitPixieHtmlView;
  MonitorView := InitPixieHtmlView;
  Doc := InitPixieDocument;
  ContentDoc := InitPixieDocument;
  Elem := InitPixieElement;
end;

function InitializeSetup(): Boolean;
begin
  FMXInit;
  Result := True;
end;

procedure InitializeWizard;
begin
  SelectedIcons := False;
  SelectedThemes := False;
  SelectedExamples := False;
  CurrentHoverTarget := '';
  IsConfirmed := False;
  DocumentReady := False;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FFF3F5F8, '', True);

  HeaderView.FCreate(FMXForm.Handle);
  HeaderView.SetBounds(0, 0, DEMO_FORM_WIDTH, TITLEBAR_HEIGHT);
  HeaderView.ColorScheme(pcsDark);
  HeaderView.OnElementClick(@ElementClick);
  HeaderView.OnMouseDown(@HeaderMouseDown);
  HeaderView.LoadFromString(BuildTitlebarHtml);

  View.FCreate(FMXForm.Handle);
  View.SetBounds(0, TITLEBAR_HEIGHT, CONTENT_WIDTH,
    DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsLight);
  View.HitTest(True);
  View.OnElementClick(@ElementClick);
  View.OnElementMouseEvent(@ViewElementMouseEvent);

  MonitorView.FCreate(FMXForm.Handle);
  MonitorView.SetBounds(CONTENT_WIDTH, TITLEBAR_HEIGHT,
    DEMO_FORM_WIDTH - CONTENT_WIDTH, DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  MonitorView.ColorScheme(pcsLight);
  MonitorView.HitTest(True);
  MonitorView.OnElementClick(@ElementClick);
  MonitorView.LoadFromString(BuildMonitorHtml);

  Doc.FCreate(MonitorView.GetDocument);
  DocumentReady := True;
  ShowOptionsPage;
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
