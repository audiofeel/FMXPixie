; ============================================================================
; FMXPixie — SVGView Demo
;
; Демонстрирует:
;   - отдельную FMX-форму с кастомным титлбаром (перетаскивание / свернуть / закрыть)
;   - крупную векторную иллюстрацию в TPixieSvgView
;   - загрузку SVG из файла и из строки
;   - изменение масштаба и режима выравнивания SVG
;   - переключение фона, рамки и шахматной подложки прозрачности
;   - чтение размеров исходного SVG и текущего масштаба
;
; Требуемые файлы проекта:
;   Modules\FMXPixieHandle.iss (с FPixieSvgView и InitPixieSvgView)
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
;   FMXPixie_SvgView_Demo.svg
;
; Это демонстрация интерфейса, приложение не устанавливается.
; ============================================================================

#define DemoAppName "FMXPixie - SVGView Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
AppCopyright=audiofeel
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie_SvgView_Demo
; SetupArchitecture=x64
SetupIconFile=Files\setup.ico

[Files]
#if SetupSetting("SetupArchitecture") == "x64"
Source: "Modules\FMXPixie_x64.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#else
Source: "Modules\FMXPixie_x86.dll"; DestName: "FMXPixie.dll"; Flags: dontcopy
#endif
Source: "Files\FMXPixie_SvgView_Demo.svg"; Flags: dontcopy

[Code]
#include "Modules\FMXPixieHandle.iss"

const
  DEMO_FORM_WIDTH = 1000;
  DEMO_FORM_HEIGHT = 760;
  TITLEBAR_HEIGHT = 32;
  TITLEBAR_BUTTONS_WIDTH = 92;
  TOOLBAR_HEIGHT = 78;
  SVG_LEFT = 18;
  SVG_TOP = 112;
  SVG_WIDTH = 964;
  SVG_HEIGHT = 594;
  FOOTER_TOP = 708;
  FOOTER_HEIGHT = 52;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  ToolbarView: FPixieHtmlView;
  FooterView: FPixieHtmlView;
  FooterDoc: FPixieDocument;
  Svg: FPixieSvgView;
  Elem: FPixieElement;

  SvgFileName: String;
  SvgSourceLabel: String;
  ZoomFactor: Double;
  DarkBackground: Boolean;
  CheckerboardEnabled: Boolean;
  BorderEnabled: Boolean;

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
    '<span class="subtitle">SVGView / VECTOR LAB</span>' +
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
    '.row{height:31px;white-space:nowrap;}' +
    '.action{display:inline-block;vertical-align:middle;margin-right:5px;padding:5px 10px;' +
    'background:#17243a;border:1px solid #334b69;color:#dbeafe;text-decoration:none;' +
    'line-height:16px;cursor:pointer;}' +
    '.action:hover{background:#243c5d;border-color:#60a5fa;color:#fff;}' +
    '.accent{background:#17345a;border-color:#315b8c;color:#bfdbfe;}' +
    '.accent:hover{background:#225080;}' +
    '.quiet{color:#94a3b8;}' +
    '</style></head><body>' +
    '<div class="row">' +
    '<a id="load-file" class="action accent" href="#">Load SVG file</a>' +
    '<a id="load-string" class="action" href="#">Load SVG string</a>' +
    '<a id="zoom-out" class="action" href="#">− Zoom</a>' +
    '<a id="zoom-reset" class="action" href="#">100%</a>' +
    '<a id="zoom-in" class="action" href="#">+ Zoom</a>' +
    '<a id="align-center" class="action" href="#">Center SVG</a>' +
    '</div>' +
    '<div class="row">' +
    '<a id="align-topleft" class="action" href="#">Top-left</a>' +
    '<a id="toggle-background" class="action" href="#">Toggle background</a>' +
    '<a id="toggle-checkers" class="action" href="#">Checkerboard</a>' +
    '<a id="toggle-border" class="action" href="#">Toggle border</a>' +
    '<a id="restore" class="action accent" href="#">Restore demo</a>' +
    '<span class="quiet">SVG controls · FMXPixie</span>' +
    '</div></body></html>';
end;

function BuildFooterHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{box-sizing:border-box;background:#111827;border-top:1px solid #263247;' +
    'font-family:Segoe UI,Arial,sans-serif;font-size:11px;padding:8px 14px;color:#cbd5e1;}' +
    '.status{color:#bfdbfe;}' +
    '.meta{float:right;color:#94a3b8;}' +
    '.dot{display:inline-block;width:6px;height:6px;border-radius:50%;' +
    'background:#34d399;margin-right:8px;vertical-align:middle;}' +
    '</style></head><body>' +
    '<span class="dot"></span><span id="footer-status" class="status">Ready</span>' +
    '<span id="footer-meta" class="meta">SVG 680 × 480 · Zoom 100%</span>' +
    '</body></html>';
end;

function BuildInlineSvg: String;
begin
  { Второй рисунок специально отличается от SVG-файла: это проверка загрузки строки. }
  Result :=
    '<svg xmlns="http://www.w3.org/2000/svg" width="680" height="480" viewBox="0 0 680 480">' +
    '<circle cx="340" cy="240" r="190" fill="#111827" stroke="#334155" stroke-width="2"/>' +
    '<circle cx="340" cy="240" r="154" fill="none" stroke="#475569" stroke-width="2"/>' +
    '<circle cx="340" cy="240" r="112" fill="#172554" stroke="#60a5fa" stroke-width="3"/>' +
    '<path d="M340 102 L370 190 L462 190 L388 244 L416 332 L340 280 L264 332 L292 244 L218 190 L310 190 Z" fill="#2563eb" stroke="#bfdbfe" stroke-width="3" stroke-linejoin="round"/>' +
    '<path d="M340 102 L340 280 L264 332 L292 244 L218 190 L310 190 Z" fill="#1d4ed8" stroke="#93c5fd" stroke-width="1.5" stroke-linejoin="round"/>' +
    '<circle cx="340" cy="240" r="50" fill="#0f172a" stroke="#a5f3fc" stroke-width="3"/>' +
    '<circle cx="340" cy="240" r="33" fill="#0e7490" stroke="#67e8f9" stroke-width="2"/>' +
    '<circle cx="340" cy="240" r="17" fill="#e0f2fe" stroke="#ffffff" stroke-width="2"/>' +
    '<path d="M340 30 L349 54 L373 63 L349 72 L340 96 L331 72 L307 63 L331 54 Z" fill="#fbbf24" stroke="#fde68a" stroke-width="2" stroke-linejoin="round"/>' +
    '<path d="M340 384 L348 405 L369 413 L348 421 L340 442 L332 421 L311 413 L332 405 Z" fill="#34d399" stroke="#a7f3d0" stroke-width="2" stroke-linejoin="round"/>' +
    '<circle cx="173" cy="240" r="10" fill="#0f172a" stroke="#38bdf8" stroke-width="3"/>' +
    '<circle cx="507" cy="240" r="10" fill="#0f172a" stroke="#a78bfa" stroke-width="3"/>' +
    '<circle cx="340" cy="112" r="7" fill="#38bdf8"/>' +
    '<circle cx="340" cy="368" r="7" fill="#a78bfa"/>' +
    '<path d="M120 240 C180 112 500 112 560 240 C500 368 180 368 120 240 Z" fill="none" stroke="#64748b" stroke-width="2"/>' +
    '<path d="M340 54 L340 88 M340 392 L340 426 M128 240 L158 240 M522 240 L552 240" stroke="#94a3b8" stroke-width="2" stroke-linecap="round"/>' +
    '<circle cx="138" cy="145" r="6" fill="#34d399"/>' +
    '<circle cx="542" cy="335" r="6" fill="#f472b6"/>' +
    '<circle cx="512" cy="130" r="5" fill="#fbbf24"/>' +
    '<circle cx="165" cy="345" r="5" fill="#a78bfa"/>' +
    '</svg>';
end;

function BooleanText(Value: Boolean): String;
begin
  if Value then Result := 'ON' else Result := 'OFF';
end;

procedure UpdateFooter(const Message: String);
var
  H: NativeInt;
  MetaText: String;
begin
  if FooterDoc = nil then Exit;

  H := FooterDoc.GetElementById('footer-status');
  if H <> 0 then
    FooterDoc.SetElementText(H, Message);

  MetaText := SvgSourceLabel + ' · SVG ' + IntToStr(Round(Svg.GetImageWidth)) + ' × ' +
    IntToStr(Round(Svg.GetImageHeight)) + ' · Zoom ' +
    IntToStr(Round(ZoomFactor * 100)) + '% · BG ' + BooleanText(DarkBackground) +
    ' · Checker ' + BooleanText(CheckerboardEnabled);
  H := FooterDoc.GetElementById('footer-meta');
  if H <> 0 then
    FooterDoc.SetElementText(H, MetaText);

  FooterDoc.Changed;
  Log('FMXPixie SVGView: ' + Message + '; ' + MetaText);
end;

procedure SetZoom(NewZoom: Double);
begin
  if NewZoom < 0.55 then NewZoom := 0.55;
  if NewZoom > 1.40 then NewZoom := 1.40;
  ZoomFactor := NewZoom;
  Svg.Zoom(ZoomFactor);
  UpdateFooter('SVG scale updated');
end;

procedure SetAlignment(Value: Integer; const Description: String);
begin
  Svg.SvgAlign(TPixieSvgAlign(Value));
  UpdateFooter('Alignment: ' + Description);
end;

procedure RestoreDemo;
begin
  ZoomFactor := 1.0;
  DarkBackground := True;
  CheckerboardEnabled := False;
  BorderEnabled := True;
  Svg.LoadFromFile(SvgFileName);
  SvgSourceLabel := 'SVG file / Vector 01';
  Svg.Zoom(ZoomFactor);
  Svg.SvgAlign(TPixieSvgAlign(3));
  Svg.ColorInner($FF0B1020);
  Svg.ColorCheckers($00000000);
  Svg.ColorInnerBorder($FF334155);
  Svg.CheckersSize(12);
  UpdateFooter('Demo restored · loaded from SVG file');
end;

procedure CloseDemo;
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
    CloseDemo;
    Result := True;
    Exit;
  end;

  if Id = 'load-file' then
  begin
    Svg.LoadFromFile(SvgFileName);
    SvgSourceLabel := 'SVG file / Vector 01';
    UpdateFooter('Loaded SVG from file');
    Result := True;
    Exit;
  end;

  if Id = 'load-string' then
  begin
    Svg.LoadFromString(BuildInlineSvg);
    SvgSourceLabel := 'inline string / Vector 02';
    UpdateFooter('Loaded SVG from string');
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

  if Id = 'align-center' then
  begin
    SetAlignment(3, 'center both');
    Result := True;
    Exit;
  end;

  if Id = 'align-topleft' then
  begin
    SetAlignment(0, 'top-left');
    Result := True;
    Exit;
  end;

  if Id = 'toggle-background' then
  begin
    DarkBackground := not DarkBackground;
    if DarkBackground then
      Svg.ColorInner($FF0B1020)
    else
      Svg.ColorInner($00000000);
    UpdateFooter('Background: ' + BooleanText(DarkBackground));
    Result := True;
    Exit;
  end;

  if Id = 'toggle-checkers' then
  begin
    CheckerboardEnabled := not CheckerboardEnabled;
    if CheckerboardEnabled then
    begin
      Svg.ColorCheckers($FF26364F);
      Svg.CheckersSize(12);
    end
    else
      Svg.ColorCheckers($00000000);
    UpdateFooter('Checkerboard: ' + BooleanText(CheckerboardEnabled));
    Result := True;
    Exit;
  end;

  if Id = 'toggle-border' then
  begin
    BorderEnabled := not BorderEnabled;
    if BorderEnabled then
      Svg.ColorInnerBorder($FF334155)
    else
      Svg.ColorInnerBorder($00000000);
    UpdateFooter('SVG frame: ' + BooleanText(BorderEnabled));
    Result := True;
    Exit;
  end;

  if Id = 'restore' then
  begin
    RestoreDemo;
    Result := True;
    Exit;
  end;
end;

procedure TitleMouseDown(Sender: TObject; Button: TMouseButton;
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
  FooterView := InitPixieHtmlView;
  FooterDoc := InitPixieDocument;
  Svg := InitPixieSvgView;
  Elem := InitPixieElement;

  ZoomFactor := 1.0;
  DarkBackground := True;
  CheckerboardEnabled := False;
  BorderEnabled := True;
  SvgSourceLabel := 'SVG file / Vector 01';
  Result := True;
end;

procedure InitializeWizard;
begin
  SvgFileName := ExpandConstant('{tmp}') + '\FMXPixie_SvgView_Demo.svg';
  ExtractTemporaryFile('FMXPixie_SvgView_Demo.svg');

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF0D1727, '', True);

  TitleView.FCreate(FMXForm.Handle);
  TitleView.SetBounds(0, 0, DEMO_FORM_WIDTH, TITLEBAR_HEIGHT);
  TitleView.ColorScheme(pcsDark);
  TitleView.OnElementClick(@ElementClick);
  TitleView.OnMouseDown(@TitleMouseDown);
  TitleView.LoadFromString(BuildTitleBarHtml);

  ToolbarView.FCreate(FMXForm.Handle);
  ToolbarView.SetBounds(0, TITLEBAR_HEIGHT, DEMO_FORM_WIDTH, TOOLBAR_HEIGHT);
  ToolbarView.ColorScheme(pcsDark);
  ToolbarView.OnElementClick(@ElementClick);
  ToolbarView.LoadFromString(BuildToolbarHtml);

  Svg.FCreate(FMXForm.Handle);
  Svg.SetBounds(SVG_LEFT, SVG_TOP, SVG_WIDTH, SVG_HEIGHT);
  Svg.SvgAlign(TPixieSvgAlign(3));
  Svg.Zoom(ZoomFactor);
  Svg.ColorInner($FF0B1020);
  Svg.ColorInnerBorder($FF334155);
  Svg.ColorCheckers($00000000);
  Svg.CheckersSize(12);
  Svg.LoadFromFile(SvgFileName);

  FooterView.FCreate(FMXForm.Handle);
  FooterView.SetBounds(0, FOOTER_TOP, DEMO_FORM_WIDTH, FOOTER_HEIGHT);
  FooterView.ColorScheme(pcsDark);
  FooterView.LoadFromString(BuildFooterHtml);
  FooterDoc.FCreate(FooterView.GetDocument);

  UpdateFooter('Ready · click Load SVG string to switch artwork');
  FMXForm.Show;
  Log('FMXPixie SVGView Demo: ready; source=' + SvgSourceLabel);
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := False;
end;

procedure DeinitializeSetup;
begin
  FMXPixieShutDown;
end;
