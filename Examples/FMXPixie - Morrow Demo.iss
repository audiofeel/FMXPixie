; ============================================================================
; FMXPixie Demo 02 — MORROW / Object Archive
;
; Другая демонстрация FMXPixie: интерфейс небольшого дизайн-каталога вместо
; страницы с флагами установки и прогрессом.
;
; Что показывает:
;   - композицию реального приложения на HTML/CSS внутри FMX-формы;
;   - CSS Grid / Flexbox, градиенты и интерактивные карточки;
;   - фильтрацию карточек по категории через DOM;
;   - выбор объекта, изменение связанных DOM-элементов;
;   - состояние избранного и корзины;
;   - пакетное обновление DOM через BeginUpdate / EndUpdate;
;   - отдельную строку заголовка FMX-формы с перетаскиванием, сворачиванием
;     и закрытием;
;   - обратный вызов OnAnchorClick для ссылки на проект Pixie.
;
; Все товары и действия демонстрационные. Установки реального приложения нет.
; Внешние изображения, JavaScript и дополнительные файлы ресурсов не нужны.
;
; Требуются существующие файлы обёртки:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
; ============================================================================

#define DemoAppName "FMXPixie - Morrow Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - Morrow Demo
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
  DEMO_FORM_WIDTH = 1040;
  DEMO_FORM_HEIGHT = 760;
  TITLEBAR_HEIGHT = 34;
  TITLEBAR_BUTTONS_WIDTH = 92;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;

  TempDir: String;
  SelectedProduct: Integer;
  CartCount: Integer;
  IsSaved: Boolean;
  CurrentFilter: String;

function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#14231f;color:#e9e6dc;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.titlebar{position:relative;width:100%;height:33px;line-height:32px;' +
    'background:#14231f;border-bottom:1px solid #34463e;overflow:hidden;}' +
    '.caption{margin-left:13px;color:#d8b28a;font-weight:bold;letter-spacing:1.4px;}' +
    '.subcaption{margin-left:9px;color:#87958d;font-size:11px;}' +
    '.controls{position:absolute;right:0;top:0;width:92px;height:32px;font-size:0;}' +
    '.control{display:inline-block;width:46px;height:32px;line-height:31px;text-align:center;' +
    'vertical-align:top;color:#d5ddd7;font-family:"Segoe UI",Arial,sans-serif;' +
    'font-size:21px;cursor:pointer;}' +
    '.minimize:hover{background:#2d4038;color:#fff;}' +
    '.close{font-size:24px;line-height:29px;}' +
    '.close:hover{background:#b84c3b;color:#fff;}' +
    '</style></head><body>' +
    '<div class="titlebar">' +
    '<span class="caption">MORROW</span><span class="subcaption">OBJECT ARCHIVE / FMXPIXIE</span>' +
    '<div class="controls"><div id="title-minimize" class="control minimize" title="Свернуть">−</div>' +
    '<div id="title-close" class="control close" title="Закрыть">×</div></div>' +
    '</div></body></html>';
end;

function BuildDemoHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;min-height:100%;margin:0;padding:0;}' +
    'body{background:#f2efe7;color:#23362f;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.app{padding:17px 23px 13px 23px;}' +
    '.masthead{height:43px;display:flex;align-items:center;justify-content:space-between;' +
    'border-bottom:1px solid #d9d5c9;padding-bottom:11px;}' +
    '.brand{display:flex;align-items:center;}' +
    '.brand-mark{width:30px;height:30px;line-height:28px;text-align:center;' +
    'border:1px solid #b85f3d;color:#b85f3d;font-family:Georgia,serif;font-size:18px;' +
    'margin-right:10px;}' +
    '.brand-name{font-family:Georgia,serif;font-size:21px;letter-spacing:1.1px;color:#20382f;}' +
    '.brand-note{margin-left:10px;color:#8b8b7e;font-size:9px;letter-spacing:1.6px;}' +
    '.nav{display:flex;align-items:center;}' +
    '.nav-link{display:inline-block;margin-left:23px;padding:7px 0 6px 0;color:#777c70;' +
    'font-size:10px;font-weight:bold;letter-spacing:1.5px;cursor:pointer;border-bottom:2px solid transparent;}' +
    '.nav-link:hover{color:#b85f3d;}' +
    '.nav-link.active{color:#23362f;border-bottom-color:#b85f3d;}' +
    '.bag{margin-left:24px;padding:8px 11px;background:#20382f;color:#f7f2e8;border:0;' +
    'font-size:10px;font-weight:bold;letter-spacing:1px;cursor:pointer;}' +
    '.bag:hover{background:#b85f3d;}' +
    '.bag-count{display:inline-block;min-width:18px;margin-left:8px;padding:2px 4px;' +
    'background:#d8b28a;color:#20382f;text-align:center;}' +
    '.hero{display:grid;grid-template-columns:1.02fr .98fr;min-height:166px;margin-top:15px;overflow:hidden;}' +
    '.hero-copy{background:#20382f;padding:19px 23px 17px 23px;color:#f2efe7;position:relative;}' +
    '.eyebrow{font-size:9px;font-weight:bold;letter-spacing:2px;color:#d8b28a;}' +
    '.hero-title{font-family:Georgia,serif;font-size:31px;line-height:1.03;font-weight:normal;' +
    'margin:9px 0 7px 0;color:#f8f3e9;}' +
    '.hero-description{font-size:11px;line-height:1.5;color:#c0c9bd;max-width:340px;}' +
    '.hero-action{margin-top:11px;padding:8px 12px;background:#d8b28a;border:0;color:#20382f;' +
    'font-size:9px;font-weight:bold;letter-spacing:1.2px;cursor:pointer;}' +
    '.hero-action:hover{background:#f2d6b6;}' +
    '.hero-visual{position:relative;min-height:166px;overflow:hidden;' +
    'background:radial-gradient(circle at 55% 38%,#dfbd8c 0%,#bd8a62 38%,#6e7964 100%);}' +
    '.sun-disc{position:absolute;width:128px;height:128px;border:1px solid rgba(250,239,218,.6);' +
    'border-radius:50%;left:50%;top:18px;margin-left:-64px;}' +
    '.sun-inner{position:absolute;width:94px;height:94px;border:1px solid rgba(250,239,218,.35);' +
    'border-radius:50%;left:50%;top:35px;margin-left:-47px;}' +
    '.hero-lamp-shade{position:absolute;width:105px;height:48px;left:50%;top:38px;margin-left:-52px;' +
    'border-radius:55px 55px 8px 8px;background:linear-gradient(135deg,#f0d4a8 0%,#b87548 100%);' +
    'border-bottom:4px solid #8e593b;}' +
    '.hero-lamp-neck{position:absolute;width:10px;height:47px;left:50%;top:82px;margin-left:-5px;' +
    'background:linear-gradient(90deg,#58665a,#2e4035);}' +
    '.hero-lamp-foot{position:absolute;width:65px;height:12px;left:50%;top:124px;margin-left:-32px;' +
    'border-radius:50%;background:#2c4035;}' +
    '.art-label{position:absolute;right:14px;bottom:12px;color:#f9edda;font-size:9px;' +
    'letter-spacing:2px;text-align:right;}' +
    '.section-head{display:flex;align-items:end;justify-content:space-between;margin:17px 0 9px 0;}' +
    '.section-kicker{font-size:9px;letter-spacing:1.9px;font-weight:bold;color:#b85f3d;}' +
    '.section-title{font-family:Georgia,serif;font-size:22px;line-height:1.1;font-weight:normal;' +
    'margin-top:3px;color:#20382f;}' +
    '.section-note{font-size:10px;color:#8b8b7e;text-align:right;}' +
    '.product-grid{display:grid;grid-template-columns:repeat(3,1fr);column-gap:12px;}' +
    '.product-card{min-width:0;background:#faf8f2;border:1px solid #ded9cd;cursor:pointer;overflow:hidden;}' +
    '.product-card:hover{border-color:#b8a18b;}' +
    '.product-card.is-selected{border-color:#b85f3d;}' +
    '.product-art{height:112px;position:relative;overflow:hidden;}' +
    '.art-lamp{background:linear-gradient(135deg,#d6ddd0 0%,#b4c0b0 100%);}' +
    '.lamp-halo{position:absolute;width:83px;height:83px;left:50%;top:13px;margin-left:-41px;' +
    'border:1px solid rgba(255,255,255,.6);border-radius:50%;}' +
    '.lamp-shade{position:absolute;width:66px;height:31px;left:50%;top:25px;margin-left:-33px;' +
    'border-radius:38px 38px 5px 5px;background:linear-gradient(135deg,#e7c69b,#a56e47);' +
    'border-bottom:3px solid #8c5d40;}' +
    '.lamp-neck{position:absolute;width:7px;height:34px;left:50%;top:54px;margin-left:-3px;background:#43554a;}' +
    '.lamp-base{position:absolute;width:47px;height:9px;left:50%;top:86px;margin-left:-23px;' +
    'border-radius:50%;background:#43554a;}' +
    '.art-vase{background:linear-gradient(145deg,#ead8c7,#d4a992);}' +
    '.vase-halo{position:absolute;width:86px;height:86px;left:50%;top:11px;margin-left:-43px;' +
    'border:1px solid rgba(255,255,255,.52);border-radius:50%;}' +
    '.vase-neck{position:absolute;width:28px;height:27px;left:50%;top:23px;margin-left:-14px;' +
    'background:linear-gradient(90deg,#a9624d,#d28d70);border-radius:7px 7px 2px 2px;}' +
    '.vase-body{position:absolute;width:66px;height:60px;left:50%;top:43px;margin-left:-33px;' +
    'background:linear-gradient(110deg,#d29a7d,#a75d49);border-radius:17px 17px 25px 25px;' +
    'border-top:2px solid #e6b79b;}' +
    '.art-speaker{background:linear-gradient(135deg,#d7dfd6,#b5c6bd);}' +
    '.speaker-halo{position:absolute;width:91px;height:91px;left:50%;top:10px;margin-left:-45px;' +
    'border:1px solid rgba(255,255,255,.6);border-radius:50%;}' +
    '.speaker-body{position:absolute;width:61px;height:78px;left:50%;top:17px;margin-left:-30px;' +
    'border-radius:13px 13px 15px 15px;background:linear-gradient(100deg,#31483e,#617466);' +
    'border:2px solid #718678;}' +
    '.speaker-ring{position:absolute;width:35px;height:35px;left:50%;top:36px;margin-left:-17px;' +
    'border:2px solid #d3c3a8;border-radius:50%;}' +
    '.speaker-center{position:absolute;width:9px;height:9px;left:50%;top:49px;margin-left:-4px;' +
    'background:#d3c3a8;border-radius:50%;}' +
    '.art-number{position:absolute;left:10px;top:8px;font-size:9px;letter-spacing:1px;color:rgba(32,56,47,.65);}' +
    '.product-info{padding:9px 11px 10px 11px;}' +
    '.product-topline{display:flex;align-items:center;justify-content:space-between;}' +
    '.product-name{font-family:Georgia,serif;font-size:16px;color:#20382f;}' +
    '.product-price{font-size:11px;font-weight:bold;color:#b85f3d;}' +
    '.product-category{margin-top:4px;color:#85877a;font-size:9px;letter-spacing:1.2px;text-transform:uppercase;}' +
    '.selection-strip{display:flex;align-items:center;justify-content:space-between;margin-top:11px;' +
    'padding:10px 13px;background:#e7e2d7;border:1px solid #d9d2c4;}' +
    '.selected-overline{font-size:8px;font-weight:bold;letter-spacing:1.5px;color:#8b7562;}' +
    '.selected-name{font-family:Georgia,serif;font-size:16px;color:#20382f;margin-top:2px;}' +
    '.selected-description{font-size:10px;color:#777c70;margin-top:2px;}' +
    '.strip-actions{display:flex;align-items:center;}' +
    '.save-button{padding:9px 11px;margin-right:7px;background:transparent;border:1px solid #a9a797;' +
    'color:#536357;font-size:9px;font-weight:bold;letter-spacing:1px;cursor:pointer;}' +
    '.save-button:hover{border-color:#b85f3d;color:#b85f3d;}' +
    '.add-button{padding:10px 13px;background:#b85f3d;border:1px solid #b85f3d;color:#fff7eb;' +
    'font-size:9px;font-weight:bold;letter-spacing:1px;cursor:pointer;}' +
    '.add-button:hover{background:#94482f;border-color:#94482f;}' +
    '.footer{display:flex;align-items:center;justify-content:space-between;margin-top:12px;color:#8a8d80;' +
    'font-size:9px;}' +
    '.live-dot{display:inline-block;width:6px;height:6px;border-radius:50%;background:#71916f;margin-right:6px;}' +
    '.status{display:inline-block;margin-left:7px;color:#596d5f;}' +
    '.footer a{color:#b85f3d;text-decoration:none;}' +
    '.footer a:hover{text-decoration:underline;}' +
    '</style></head><body><div class="app">' +
    '<div class="masthead">' +
    '<div class="brand"><div class="brand-mark">m.</div><span class="brand-name">morrow</span>' +
    '<span class="brand-note">OBJECTS FOR EVERYDAY RITUALS</span></div>' +
    '<div class="nav">' +
    '<span id="nav-discover" class="nav-link active">DISCOVER</span>' +
    '<span id="nav-lighting" class="nav-link">LIGHTING</span>' +
    '<span id="nav-objects" class="nav-link">OBJECTS</span>' +
    '<button id="btn-open-bag" class="bag">BAG <span class="bag-count" id="bag-count">0</span></button>' +
    '</div></div>' +
    '<div class="hero">' +
    '<div class="hero-copy"><div class="eyebrow">A MORE THOUGHTFUL EVERYDAY</div>' +
    '<div class="hero-title">Objects for<br>everyday rituals.</div>' +
    '<div class="hero-description">Considered forms, honest materials, and small details that make a space feel like yours.</div>' +
    '<button id="btn-explore" class="hero-action">EXPLORE THE COLLECTION&nbsp; ↗</button></div>' +
    '<div class="hero-visual"><div class="sun-disc"></div><div class="sun-inner"></div>' +
    '<div class="hero-lamp-shade"></div><div class="hero-lamp-neck"></div><div class="hero-lamp-foot"></div>' +
    '<div class="art-label">FORM FOLLOWS FEELING<br>COLLECTION Nº 04</div></div></div>' +
    '<div class="section-head"><div><div class="section-kicker">THE SMALL COLLECTION / 01—03</div>' +
    '<div class="section-title">Useful things, beautifully made.</div></div>' +
    '<div id="filter-caption" class="section-note">Three considered pieces. Choose one to see its details.</div></div>' +
    '<div class="product-grid">' +
    '<div id="card-mira" class="product-card is-selected"><div class="product-art art-lamp">' +
    '<div class="art-number">01 / LIGHT</div><div class="lamp-halo"></div><div class="lamp-shade"></div>' +
    '<div class="lamp-neck"></div><div class="lamp-base"></div></div>' +
    '<div class="product-info"><div class="product-topline"><span class="product-name">Mira Lamp</span>' +
    '<span class="product-price">$148</span></div><div class="product-category">Brushed metal · linen</div></div></div>' +
    '<div id="card-forma" class="product-card"><div class="product-art art-vase">' +
    '<div class="art-number">02 / FORM</div><div class="vase-halo"></div><div class="vase-neck"></div>' +
    '<div class="vase-body"></div></div>' +
    '<div class="product-info"><div class="product-topline"><span class="product-name">Forma Vessel</span>' +
    '<span class="product-price">$86</span></div><div class="product-category">Hand-thrown · stoneware</div></div></div>' +
    '<div id="card-arc" class="product-card"><div class="product-art art-speaker">' +
    '<div class="art-number">03 / SOUND</div><div class="speaker-halo"></div><div class="speaker-body"></div>' +
    '<div class="speaker-ring"></div><div class="speaker-center"></div></div>' +
    '<div class="product-info"><div class="product-topline"><span class="product-name">Arc Speaker</span>' +
    '<span class="product-price">$129</span></div><div class="product-category">Portable · woven composite</div></div></div>' +
    '</div>' +
    '<div class="selection-strip"><div><div class="selected-overline">YOUR CURRENT SELECTION</div>' +
    '<div id="selected-name" class="selected-name">Mira Lamp · $148</div>' +
    '<div id="selected-description" class="selected-description">Warm, diffused light with a linen shade and brushed-metal finish.</div></div>' +
    '<div class="strip-actions"><button id="btn-save" class="save-button">♡ SAVE PIECE</button>' +
    '<button id="btn-add" class="add-button">ADD TO BAG · $148</button></div></div>' +
    '<div class="footer"><div><span class="live-dot"></span>LIVE INTERFACE DEMO' +
    '<span id="demo-status" class="status">Select a piece to explore the interaction.</span></div>' +
    '<div>HTML / CSS RENDERED BY <a id="pixie-link" href="https://gitlab.com/retrofoxed/pixie">PIXIE</a>' +
    '&nbsp;&nbsp;·&nbsp;&nbsp; NO REAL PURCHASES</div></div>' +
    '</div></body></html>';
end;

// ---------------------------------------------------------------------------
// DOM helpers — uses only wrapper calls already used in the first demo.
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

procedure SetStyleById(const Id, StyleText: String);
var
  H: NativeInt;
begin
  H := Doc.GetElementById(Id);
  if H = 0 then
    Exit;
  Elem.FCreate(H);
  Elem.SetAttr('style', StyleText);
end;

procedure SetStatus(const S: String);
begin
  SetTextById('demo-status', S);
  Log('FMXPixie Morrow Demo: ' + S);
end;

procedure UpdateSelection;
begin
  case SelectedProduct of
    1:
      begin
        SetClassById('card-mira', 'product-card is-selected');
        SetClassById('card-forma', 'product-card');
        SetClassById('card-arc', 'product-card');
        SetTextById('selected-name', 'Mira Lamp · $148');
        SetTextById('selected-description', 'Warm, diffused light with a linen shade and brushed-metal finish.');
        SetTextById('btn-add', 'ADD TO BAG · $148');
      end;
    2:
      begin
        SetClassById('card-mira', 'product-card');
        SetClassById('card-forma', 'product-card is-selected');
        SetClassById('card-arc', 'product-card');
        SetTextById('selected-name', 'Forma Vessel · $86');
        SetTextById('selected-description', 'A hand-thrown stoneware vessel; each surface carries its own small variations.');
        SetTextById('btn-add', 'ADD TO BAG · $86');
      end;
    3:
      begin
        SetClassById('card-mira', 'product-card');
        SetClassById('card-forma', 'product-card');
        SetClassById('card-arc', 'product-card is-selected');
        SetTextById('selected-name', 'Arc Speaker · $129');
        SetTextById('selected-description', 'Compact sound with a tactile woven-composite shell and a quiet silhouette.');
        SetTextById('btn-add', 'ADD TO BAG · $129');
      end;
  end;

  if IsSaved then
    SetTextById('btn-save', 'SAVED TO WISHLIST ✓')
  else
    SetTextById('btn-save', '♡ SAVE PIECE');
end;

procedure ApplyFilter(const FilterName: String);
begin
  CurrentFilter := FilterName;
  Doc.BeginUpdate;
  try
    SetClassById('nav-discover', 'nav-link');
    SetClassById('nav-lighting', 'nav-link');
    SetClassById('nav-objects', 'nav-link');

    if CurrentFilter = 'all' then
    begin
      SetClassById('nav-discover', 'nav-link active');
      SetStyleById('card-mira', 'display:block;');
      SetStyleById('card-forma', 'display:block;');
      SetStyleById('card-arc', 'display:block;');
      SetTextById('filter-caption', 'Three considered pieces. Choose one to see its details.');
    end
    else if CurrentFilter = 'lighting' then
    begin
      SetClassById('nav-lighting', 'nav-link active');
      SetStyleById('card-mira', 'display:block;');
      SetStyleById('card-forma', 'display:none;');
      SetStyleById('card-arc', 'display:none;');
      SelectedProduct := 1;
      IsSaved := False;
      SetTextById('filter-caption', 'Lighting / one piece in this collection.');
    end
    else
    begin
      SetClassById('nav-objects', 'nav-link active');
      SetStyleById('card-mira', 'display:none;');
      SetStyleById('card-forma', 'display:block;');
      SetStyleById('card-arc', 'display:block;');
      if SelectedProduct = 1 then
        SelectedProduct := 2;
      IsSaved := False;
      SetTextById('filter-caption', 'Objects / two forms, different everyday rituals.');
    end;

    UpdateSelection;
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure ResetDemo;
begin
  SelectedProduct := 1;
  CartCount := 0;
  IsSaved := False;
  CurrentFilter := 'all';
  Doc.BeginUpdate;
  try
    SetTextById('bag-count', '0');
    SetStyleById('card-mira', 'display:block;');
    SetStyleById('card-forma', 'display:block;');
    SetStyleById('card-arc', 'display:block;');
    UpdateSelection;
    SetClassById('nav-discover', 'nav-link active');
    SetClassById('nav-lighting', 'nav-link');
    SetClassById('nav-objects', 'nav-link');
    SetTextById('filter-caption', 'Three considered pieces. Choose one to see its details.');
    SetStatus('Demo reset. Choose a piece to explore the interaction.');
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

// ---------------------------------------------------------------------------
// All click handling lives in Inno Pascal Script; HTML contains no JavaScript.
// ---------------------------------------------------------------------------
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

  if Id = 'nav-discover' then
  begin
    ApplyFilter('all');
    SetStatus('Discover: showing the complete collection.');
    Result := True;
    Exit;
  end;

  if Id = 'nav-lighting' then
  begin
    ApplyFilter('lighting');
    SetStatus('Lighting: filtered by category.');
    Result := True;
    Exit;
  end;

  if Id = 'nav-objects' then
  begin
    ApplyFilter('objects');
    SetStatus('Objects: filtered by category.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-explore' then
  begin
    ApplyFilter('all');
    SelectedProduct := 1;
    IsSaved := False;
    Doc.BeginUpdate;
    try
      UpdateSelection;
      SetStatus('Collection opened. Click any product card to change the selection.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'card-mira' then
  begin
    SelectedProduct := 1;
    IsSaved := False;
    Doc.BeginUpdate;
    try
      UpdateSelection;
      SetStatus('Selected Mira Lamp — DOM text and selected-card styling updated.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'card-forma' then
  begin
    SelectedProduct := 2;
    IsSaved := False;
    Doc.BeginUpdate;
    try
      UpdateSelection;
      SetStatus('Selected Forma Vessel — DOM text and selected-card styling updated.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'card-arc' then
  begin
    SelectedProduct := 3;
    IsSaved := False;
    Doc.BeginUpdate;
    try
      UpdateSelection;
      SetStatus('Selected Arc Speaker — DOM text and selected-card styling updated.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-save' then
  begin
    IsSaved := not IsSaved;
    Doc.BeginUpdate;
    try
      UpdateSelection;
      if IsSaved then
        SetStatus('Current piece saved to the demo wishlist.')
      else
        SetStatus('Current piece removed from the demo wishlist.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-add' then
  begin
    Inc(CartCount);
    Doc.BeginUpdate;
    try
      SetTextById('bag-count', IntToStr(CartCount));
      case SelectedProduct of
        1: SetStatus('Mira Lamp added to the demo bag.');
        2: SetStatus('Forma Vessel added to the demo bag.');
        3: SetStatus('Arc Speaker added to the demo bag.');
      end;
      SetTextById('btn-add', 'ADDED TO BAG ✓');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if (Id = 'btn-open-bag') or (Id = 'bag-count') then
  begin
    if CartCount = 0 then
      SetStatus('Your demo bag is empty. Choose a piece and press ADD TO BAG.')
    else
      SetStatus('Demo bag contains ' + IntToStr(CartCount) + ' piece(s). No real purchase is made.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

end;

procedure ViewAnchorClick(Sender: TObject; El: TObject; const Url: String);
begin
  Log('FMXPixie Morrow Demo OnAnchorClick URL=' + Url);
  SetStatus('OnAnchorClick received URL: ' + Url);
end;

procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> mbLeft then
    Exit;

  if (Y >= 0) and (Y < TITLEBAR_HEIGHT) and
     (X < TitleView.GetWidth - TITLEBAR_BUTTONS_WIDTH) then
    FMXForm.StartWindowDrag;
end;

procedure FMXInit;
begin
  FMXForm := InitFormHandle;
  TitleView := InitPixieHtmlView;
  View := InitPixieHtmlView;
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
  SelectedProduct := 1;
  CartCount := 0;
  IsSaved := False;
  CurrentFilter := 'all';

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FFF2EFE7, '', True);

  // Отдельная полоса заголовка не перекрывается содержимым каталога.
  TitleView.FCreate(FMXForm.Handle);
  TitleView.Left(0);
  TitleView.Top(0);
  TitleView.Width(DEMO_FORM_WIDTH);
  TitleView.Height(TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@ViewMouseDown);
  TitleView.LoadFromString(BuildTitleBarHtml);

  View.FCreate(FMXForm.Handle);
  View.Left(0);
  View.Top(TITLEBAR_HEIGHT);
  View.Width(DEMO_FORM_WIDTH);
  View.Height(DEMO_FORM_HEIGHT - TITLEBAR_HEIGHT);
  View.ColorScheme(pcsDark);
  View.BaseUrl(TempDir + '\');
  View.OnElementClick(@ElementClick);
  View.OnAnchorClick(@ViewAnchorClick);
  View.LoadFromStringUrl(BuildDemoHtml, TempDir + '\');

  Doc.FCreate(View.GetDocument);
  ResetDemo;
  SetStatus('Ready. Select a product card, change category, save a piece or fill the demo bag.');
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
