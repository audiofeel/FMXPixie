; ============================================================================
; FMXPixie Demo 03 — MASS EFFECT / LEGENDARY COMMAND
;
; Концепт лаунчера Mass Effect Legendary Edition на HTML/CSS внутри FMX-формы.
;
; Демонстрирует:
;   - три карточки выбора: Mass Effect 1, 2 и 3;
;   - переход на отдельную страницу настроек;
;   - выбор языка и переключатель English VO;
;   - размер субтитров Small / Medium / Large;
;   - переключатели субтитров и вибрации контроллера;
;   - сохранение настроек демо в отдельный INI-профиль;
;   - выбор папки игры, поиск типовых путей и запуск exe каждой игры;
;   - отдельный заголовок FMX-формы: перетаскивание / свернуть / закрыть;
;   - управление DOM из Inno Pascal Script без JavaScript.
;
; ВАЖНО:
;   Это UI-прототип. Настройки сохраняются в профиль самого демо, но не
;   переписывают конфигурационные файлы Mass Effect. Запуск EXE игры работает
;   после указания корневой папки установки; Steam / EA App могут потребовать
;   собственную авторизацию.
;
; Необходимые существующие файлы:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
; ============================================================================

#define DemoAppName "FMXPixie - MELE Launcher Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - MELE Launcher Demo
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
  DEMO_FORM_WIDTH = 1080;
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
  SettingsDir: String;
  SettingsFile: String;
  GameRoot: String;
  SelectedGame: Integer;
  LanguageIndex: Integer;
  SubtitleSizeIndex: Integer;
  EnglishVoice: Boolean;
  SubtitlesEnabled: Boolean;
  VibrationEnabled: Boolean;
  HasUnsavedChanges: Boolean;

function BuildTitleBarHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#080e17;color:#dce7f1;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.titlebar{position:relative;width:100%;height:33px;line-height:32px;' +
    'background:#080e17;border-bottom:1px solid #253448;overflow:hidden;}' +
    '.brand-mark{display:inline-block;margin-left:13px;margin-right:9px;padding:0 6px;' +
    'height:21px;line-height:21px;background:#d83b3b;color:#fff;font-size:12px;' +
    'font-weight:bold;font-style:italic;letter-spacing:1px;vertical-align:middle;}' +
    '.title-caption{color:#f1f5f9;font-weight:bold;letter-spacing:1.7px;vertical-align:middle;}' +
    '.sub-caption{margin-left:10px;color:#7e91a5;font-size:10px;letter-spacing:1.2px;vertical-align:middle;}' +
    '.controls{position:absolute;right:0;top:0;width:92px;height:32px;font-size:0;}' +
    '.control{display:inline-block;width:46px;height:32px;line-height:31px;text-align:center;' +
    'vertical-align:top;color:#c8d5e2;font-family:"Segoe UI",Arial,sans-serif;font-size:21px;cursor:pointer;}' +
    '.minimize:hover{background:#1c2c3e;color:#fff;}' +
    '.close{font-size:24px;line-height:29px;}' +
    '.close:hover{background:#c62e36;color:#fff;}' +
    '</style></head><body><div class="titlebar">' +
    '<span class="brand-mark">N7</span><span class="title-caption">MASS EFFECT</span>' +
    '<span class="sub-caption">LEGENDARY COMMAND INTERFACE</span>' +
    '<div class="controls"><div id="title-minimize" class="control minimize" title="Свернуть">−</div>' +
    '<div id="title-close" class="control close" title="Закрыть">×</div></div>' +
    '</div></body></html>';
end;

function BuildLauncherHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:#080e17;color:#d9e4ef;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.frame{position:relative;min-height:100%;background:#080e17;overflow:hidden;}' +
    '.page{padding:17px 25px 57px 25px;}' +
    '.topbar{height:48px;display:flex;align-items:center;justify-content:space-between;' +
    'border-bottom:1px solid #223246;padding-bottom:10px;}' +
    '.brand{display:flex;align-items:center;}' +
    '.brand-n7{width:40px;height:29px;line-height:29px;text-align:center;background:#d63a3e;' +
    'color:#fff;font-size:15px;font-weight:bold;font-style:italic;letter-spacing:1px;margin-right:11px;}' +
    '.brand-title{font-size:16px;font-weight:bold;letter-spacing:2px;color:#eff5fb;}' +
    '.brand-sub{margin-top:3px;font-size:9px;color:#8b9caf;letter-spacing:2px;}' +
    '.top-actions{display:flex;align-items:center;}' +
    '.build-tag{padding:7px 9px;margin-right:11px;border:1px solid #2a4057;color:#93a8bb;' +
    'font-size:9px;font-weight:bold;letter-spacing:1.3px;}' +
    '.button{border:1px solid #344b62;background:#132235;color:#dbe8f4;padding:10px 13px;' +
    'font-family:"Segoe UI",Arial,sans-serif;font-size:10px;font-weight:bold;letter-spacing:1.1px;cursor:pointer;}' +
    '.button:hover{background:#203850;border-color:#7292ad;color:#fff;}' +
    '.button-primary{background:#d63a3e;border-color:#e14a4d;color:#fff;}' +
    '.button-primary:hover{background:#f04c51;border-color:#ff777a;color:#fff;}' +
    '.button-quiet{background:transparent;border-color:#2d4054;color:#a9bbcb;}' +
    '.hero{height:149px;display:grid;grid-template-columns:1.08fr .92fr;margin-top:14px;' +
    'border:1px solid #26394d;overflow:hidden;background:linear-gradient(110deg,#121f30 0%,#0e1725 55%,#111e2d 100%);}' +
    '.hero-copy{padding:17px 22px;position:relative;z-index:2;}' +
    '.eyebrow{font-size:9px;font-weight:bold;letter-spacing:2.2px;color:#e2595c;}' +
    '.hero-title{font-family:Georgia,serif;font-size:29px;line-height:1.03;font-weight:normal;' +
    'letter-spacing:.4px;margin:8px 0 7px 0;color:#f0f5fb;}' +
    '.hero-desc{max-width:490px;font-size:11px;line-height:1.45;color:#9eafc0;}' +
    '.hero-meta{margin-top:11px;font-size:9px;letter-spacing:1.5px;color:#607a91;}' +
    '.hero-art{position:relative;overflow:hidden;background:radial-gradient(ellipse at 52% 85%,#243d54 0%,#132538 40%,#0c1624 75%);}' +
    '.hero-planet{position:absolute;width:138px;height:138px;left:52%;top:17px;margin-left:-69px;border-radius:50%;' +
    'background:radial-gradient(circle at 30% 25%,#a9c9d4 0%,#457c9a 22%,#1d3b58 53%,#0a1726 74%);' +
    'box-shadow:0 0 33px rgba(66,143,178,.28);}' +
    '.hero-ring{position:absolute;width:260px;height:78px;left:52%;top:54px;margin-left:-130px;' +
    'border:1px solid rgba(139,188,212,.48);border-radius:50%;transform:rotate(-19deg);}' +
    '.hero-ring2{position:absolute;width:225px;height:59px;left:52%;top:66px;margin-left:-112px;' +
    'border:1px solid rgba(204,114,90,.43);border-radius:50%;transform:rotate(-19deg);}' +
    '.hero-n7{position:absolute;right:20px;bottom:12px;color:#e65356;font-size:19px;font-weight:bold;' +
    'font-style:italic;letter-spacing:1.5px;}' +
    '.hero-code{position:absolute;left:15px;bottom:13px;color:#6c8ba4;font-size:8px;letter-spacing:1.6px;}' +
    '.section-head{display:flex;align-items:end;justify-content:space-between;margin:17px 0 10px 0;}' +
    '.section-kicker{font-size:9px;font-weight:bold;letter-spacing:2px;color:#e2595c;}' +
    '.section-title{font-family:Georgia,serif;font-size:21px;line-height:1.1;font-weight:normal;' +
    'margin-top:4px;color:#edf3f8;}' +
    '.section-note{text-align:right;color:#6f8498;font-size:9px;letter-spacing:.8px;}' +
    '.game-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));column-gap:13px;}' +
    '.game-card{min-width:0;background:#101b29;border:1px solid #263a4f;overflow:hidden;cursor:pointer;}' +
    '.game-card:hover{border-color:#56748e;}' +
    '.game-card.selected{border-color:#df454a;}' +
    '.game-art{height:132px;position:relative;overflow:hidden;}' +
    '.art-me1{background:radial-gradient(circle at 25% 43%,#3b718c 0%,#1b415d 27%,#10293f 48%,#0a1726 78%);}' +
    '.art-me2{background:radial-gradient(circle at 69% 44%,#9c4e32 0%,#6b302a 25%,#312434 51%,#111b2a 79%);}' +
    '.art-me3{background:radial-gradient(ellipse at 48% 112%,#ba4941 0%,#732e36 28%,#362434 54%,#101b2a 83%);}' +
    '.art-label{position:absolute;left:12px;top:10px;font-size:8px;letter-spacing:1.5px;color:rgba(225,239,249,.67);}' +
    '.art-year{position:absolute;right:12px;top:10px;font-size:9px;letter-spacing:1.8px;color:rgba(235,243,249,.56);}' +
    '.planet{position:absolute;width:94px;height:94px;left:53%;top:32px;margin-left:-47px;border-radius:50%;}' +
    '.planet-one{background:radial-gradient(circle at 30% 24%,#acd7df 0%,#4e91b4 19%,#275575 43%,#0d2034 77%);' +
    'box-shadow:0 0 24px rgba(84,166,208,.3);}' +
    '.planet-two{width:107px;height:107px;top:24px;margin-left:-53px;background:radial-gradient(circle at 30% 23%,#f4c398 0%,#d57c4c 19%,#853e35 46%,#251e2b 79%);' +
    'box-shadow:0 0 26px rgba(228,106,64,.29);}' +
    '.planet-three{width:128px;height:128px;top:43px;margin-left:-64px;background:radial-gradient(circle at 31% 15%,#f0b8a4 0%,#b4524e 21%,#642c3b 47%,#172032 77%);' +
    'box-shadow:0 0 30px rgba(204,65,72,.27);}' +
    '.orbit{position:absolute;left:53%;top:54px;width:190px;height:53px;margin-left:-95px;' +
    'border:1px solid rgba(175,208,225,.55);border-radius:50%;transform:rotate(-20deg);}' +
    '.orbit-orange{border-color:rgba(246,177,128,.55);transform:rotate(17deg);}' +
    '.orbit-red{border-color:rgba(237,135,130,.49);transform:rotate(-30deg);}' +
    '.starline{position:absolute;left:0;right:0;bottom:0;height:31px;' +
    'background:linear-gradient(180deg,rgba(8,14,23,0),rgba(8,14,23,.73));}' +
    '.game-copy{padding:11px 13px 12px 13px;}' +
    '.game-chapter{font-size:8px;font-weight:bold;letter-spacing:1.8px;color:#7890a5;}' +
    '.game-title{font-family:Georgia,serif;font-size:22px;line-height:1.1;margin-top:4px;color:#eff5fa;}' +
    '.game-subtitle{height:28px;margin-top:5px;font-size:10px;line-height:1.35;color:#8fa1b1;}' +
    '.game-bottom{display:flex;align-items:center;justify-content:space-between;margin-top:9px;padding-top:9px;border-top:1px solid #24364a;}' +
    '.game-state{font-size:8px;font-weight:bold;letter-spacing:1px;color:#cb7778;}' +
    '.game-state.is-ready{color:#76b7a1;}' +
    '.start-game{border:1px solid #384f65;background:#16263a;color:#dce8f3;padding:8px 9px;' +
    'font-size:8px;font-weight:bold;letter-spacing:1.2px;cursor:pointer;}' +
    '.start-game:hover{border-color:#e15356;background:#bd3339;color:#fff;}' +
    '.game-card.selected .start-game{background:#d63a3e;border-color:#e34b4f;color:#fff;}' +
    '.home-bottom{display:flex;align-items:center;justify-content:space-between;margin-top:13px;padding-top:10px;' +
    'border-top:1px solid #203146;color:#62788d;font-size:9px;letter-spacing:.6px;}' +
    '.home-bottom strong{color:#99adc0;font-weight:bold;}' +
    '.home-bottom-right{color:#6f8ba1;text-align:right;}' +
    '.settings-heading{display:flex;align-items:end;justify-content:space-between;margin:1px 0 14px 0;}' +
    '.settings-title{font-family:Georgia,serif;font-size:29px;line-height:1.05;font-weight:normal;color:#eff4f8;margin-top:5px;}' +
    '.settings-subtitle{font-size:10px;color:#8296a8;margin-top:5px;}' +
    '.settings-grid{display:grid;grid-template-columns:1fr 1fr;column-gap:13px;}' +
    '.settings-column{min-width:0;}' +
    '.settings-card{background:#101b29;border:1px solid #283c50;padding:13px 15px;margin-bottom:11px;}' +
    '.settings-card-title{display:flex;align-items:center;justify-content:space-between;padding-bottom:9px;' +
    'border-bottom:1px solid #26384b;margin-bottom:8px;}' +
    '.settings-card-name{font-size:10px;font-weight:bold;letter-spacing:1.6px;color:#dce7f1;}' +
    '.settings-card-index{font-size:9px;color:#d8585b;letter-spacing:1.5px;}' +
    '.setting-row{display:flex;align-items:center;justify-content:space-between;padding:8px 0;border-bottom:1px solid rgba(48,68,88,.55);}' +
    '.setting-row:last-child{border-bottom:0;}' +
    '.setting-name{font-size:11px;color:#d2deea;}' +
    '.setting-help{font-size:9px;line-height:1.35;color:#73899d;margin-top:3px;max-width:255px;}' +
    '.value-button{min-width:132px;text-align:center;border:1px solid #38516a;background:#17283b;color:#e2edf6;' +
    'padding:9px 10px;font-size:9px;font-weight:bold;letter-spacing:1px;cursor:pointer;}' +
    '.value-button:hover{border-color:#80a0b8;background:#20374d;}' +
    '.toggle-button{min-width:84px;text-align:center;border:1px solid #455364;background:#1c2938;color:#9baebf;' +
    'padding:8px 10px;font-size:9px;font-weight:bold;letter-spacing:1.1px;cursor:pointer;}' +
    '.toggle-button.is-on{background:#173b3c;border-color:#3d8e83;color:#8de0c8;}' +
    '.size-choices{display:flex;align-items:center;margin-top:10px;}' +
    '.size-choice{flex:1;text-align:center;padding:10px 5px;margin-right:6px;border:1px solid #33495e;' +
    'background:#152437;color:#91a4b6;font-size:9px;font-weight:bold;letter-spacing:1px;cursor:pointer;}' +
    '.size-choice:last-child{margin-right:0;}' +
    '.size-choice:hover{border-color:#829eb4;color:#e4edf5;}' +
    '.size-choice.is-active{border-color:#d7484c;background:#3a202d;color:#fff;}' +
    '.preview-box{margin-top:10px;padding:10px 12px;border-left:2px solid #d7484c;background:#0b1420;color:#dce7f0;}' +
    '.preview-label{font-size:8px;letter-spacing:1.4px;color:#72899d;margin-bottom:6px;}' +
    '.subtitle-preview{font-size:12px;line-height:1.3;color:#f0f5fa;}' +
    '.subtitle-preview.preview-small{font-size:10px;}' +
    '.subtitle-preview.preview-medium{font-size:13px;}' +
    '.subtitle-preview.preview-large{font-size:16px;}' +
    '.path-display{background:#0b1420;border:1px solid #25384c;padding:9px 10px;margin-top:8px;' +
    'font-family:Consolas,"Courier New",monospace;font-size:9px;line-height:1.4;color:#91a8bc;word-wrap:break-word;}' +
    '.path-state{font-size:8px;letter-spacing:1.3px;color:#dc797b;margin-top:7px;}' +
    '.path-state.is-ready{color:#79c3a9;}' +
    '.settings-actions{display:flex;align-items:center;justify-content:space-between;margin-top:1px;}' +
    '.settings-actions-left{display:flex;align-items:center;}' +
    '.settings-actions-left .button{margin-right:7px;}' +
    '.settings-actions-right{display:flex;align-items:center;}' +
    '.settings-actions-right .button{margin-left:7px;}' +
    '.profile-note{margin-top:8px;color:#6f8497;font-size:9px;line-height:1.35;}' +
    '.global-status{position:absolute;left:25px;right:25px;bottom:0;height:35px;border-top:1px solid #203247;' +
    'display:flex;align-items:center;justify-content:space-between;color:#7c93a7;font-size:9px;letter-spacing:.6px;}' +
    '.status-left{color:#7992a7;}' +
    '.status-dot{display:inline-block;width:6px;height:6px;border-radius:50%;background:#73c3a6;margin-right:7px;}' +
    '.status-text{margin-left:8px;color:#afbfce;letter-spacing:0;}' +
    '.status-right{color:#5f778d;text-align:right;}' +
    '</style></head><body><div class="frame">' +

    '<div id="page-home" class="page">' +
    '<div class="topbar"><div class="brand"><div class="brand-n7">N7</div><div>' +
    '<div class="brand-title">MASS EFFECT</div><div class="brand-sub">LEGENDARY EDITION</div></div></div>' +
    '<div class="top-actions"><div class="build-tag">COMMAND / 2186</div>' +
    '<button id="btn-settings-top" class="button button-quiet">⚙ НАСТРОЙКИ</button></div></div>' +

    '<div class="hero"><div class="hero-copy"><div class="eyebrow">N7 // GALACTIC ARCHIVE</div>' +
    '<div class="hero-title">Одна галактика.<br>Три легенды.</div>' +
    '<div class="hero-desc">Выбери главу истории коммандера Шепарда. Три кампании, одно решение — судьба Млечного Пути.</div>' +
    '<div class="hero-meta">SPECTRE ACCESS GRANTED&nbsp;&nbsp; / &nbsp;&nbsp;SYSTEMS NOMINAL</div></div>' +
    '<div class="hero-art"><div class="hero-planet"></div><div class="hero-ring"></div><div class="hero-ring2"></div>' +
    '<div class="hero-code">CITADEL SPACE / RELAY NETWORK</div><div class="hero-n7">N7</div></div></div>' +

    '<div class="section-head"><div><div class="section-kicker">TRILOGY ACCESS / 01—03</div>' +
    '<div class="section-title">Выбери свою историю</div></div>' +
    '<div class="section-note">SELECT CAMPAIGN<br>LAUNCH INDIVIDUALLY</div></div>' +

    '<div class="game-grid">' +
    '<div id="card-me1" class="game-card selected"><div class="game-art art-me1">' +
    '<div class="art-label">FIRST CONTACT WAR</div><div class="art-year">2183</div>' +
    '<div class="planet planet-one"></div><div class="orbit"></div><div class="starline"></div></div>' +
    '<div class="game-copy"><div class="game-chapter">CHAPTER 01 / THE BEGINNING</div>' +
    '<div class="game-title">Mass Effect</div><div class="game-subtitle">Начало пути. Первый контакт и тайна протеан.</div>' +
    '<div class="game-bottom"><span id="game1-state" class="game-state">ПУТЬ НЕ УКАЗАН</span>' +
    '<button id="btn-launch-me1" class="start-game">ЗАПУСТИТЬ ↗</button></div></div></div>' +

    '<div id="card-me2" class="game-card"><div class="game-art art-me2">' +
    '<div class="art-label">THE COLLECTOR CRISIS</div><div class="art-year">2185</div>' +
    '<div class="planet planet-two"></div><div class="orbit orbit-orange"></div><div class="starline"></div></div>' +
    '<div class="game-copy"><div class="game-chapter">CHAPTER 02 / THE SUICIDE MISSION</div>' +
    '<div class="game-title">Mass Effect 2</div><div class="game-subtitle">Собери команду. Приготовься к невозможной миссии.</div>' +
    '<div class="game-bottom"><span id="game2-state" class="game-state">ПУТЬ НЕ УКАЗАН</span>' +
    '<button id="btn-launch-me2" class="start-game">ЗАПУСТИТЬ ↗</button></div></div></div>' +

    '<div id="card-me3" class="game-card"><div class="game-art art-me3">' +
    '<div class="art-label">THE REAPER WAR</div><div class="art-year">2186</div>' +
    '<div class="planet planet-three"></div><div class="orbit orbit-red"></div><div class="starline"></div></div>' +
    '<div class="game-copy"><div class="game-chapter">CHAPTER 03 / THE FINAL STAND</div>' +
    '<div class="game-title">Mass Effect 3</div><div class="game-subtitle">Объедини галактику. Последняя битва уже началась.</div>' +
    '<div class="game-bottom"><span id="game3-state" class="game-state">ПУТЬ НЕ УКАЗАН</span>' +
    '<button id="btn-launch-me3" class="start-game">ЗАПУСТИТЬ ↗</button></div></div></div>' +
    '</div>' +

    '<div class="home-bottom"><div><strong>N7 COMMAND</strong>&nbsp;&nbsp; / &nbsp;&nbsp;LAUNCHER CONCEPT' +
    '&nbsp;&nbsp; · &nbsp;&nbsp;PROFILE <span id="profile-state">UNSAVED</span></div>' +
    '<div class="home-bottom-right" id="home-root-state">КАТАЛОГ ИГР НЕ УКАЗАН</div></div>' +
    '</div>' +

    '<div id="page-settings" class="page" style="display:none;">' +
    '<div class="topbar"><div class="brand"><div class="brand-n7">N7</div><div>' +
    '<div class="brand-title">MISSION PARAMETERS</div><div class="brand-sub">MASS EFFECT LEGENDARY EDITION / CONFIGURATION</div></div></div>' +
    '<div class="top-actions"><div class="build-tag">LOCAL PROFILE</div>' +
    '<button id="btn-settings-back-top" class="button button-quiet">← К ТРИЛОГИИ</button></div></div>' +

    '<div class="settings-heading"><div><div class="section-kicker">SYSTEM CONFIGURATION / USER PROFILE</div>' +
    '<div class="settings-title">Настройки миссии</div>' +
    '<div class="settings-subtitle">Язык, читаемость субтитров и параметры управления.</div></div>' +
    '<div class="section-note">CHANGES ARE LOCAL<br>PROFILE ONLY</div></div>' +

    '<div class="settings-grid"><div class="settings-column">' +
    '<div class="settings-card"><div class="settings-card-title"><span class="settings-card-name">01 / LANGUAGE & DIALOGUE</span>' +
    '<span class="settings-card-index">COMMS</span></div>' +
    '<div class="setting-row"><div><div class="setting-name">Язык текста и диалогов</div>' +
    '<div class="setting-help">Доступные локализации Legendary Edition.</div></div>' +
    '<button id="btn-language" class="value-button">РУССКИЙ / RUS ↻</button></div>' +
    '<div class="setting-row"><div><div class="setting-name">Английская озвучка</div>' +
    '<div class="setting-help">Принудительно использовать English VO.</div></div>' +
    '<button id="btn-english-vo" class="toggle-button">ВЫКЛ</button></div>' +
    '</div>' +

    '<div class="settings-card"><div class="settings-card-title"><span class="settings-card-name">02 / GAME LIBRARY</span>' +
    '<span class="settings-card-index">INSTALL PATH</span></div>' +
    '<div class="setting-name">Корневая папка Mass Effect Legendary Edition</div>' +
    '<div class="setting-help">Выбери папку, внутри которой находится каталог Game.</div>' +
    '<div id="game-root-value" class="path-display">Папка игры не выбрана.</div>' +
    '<div id="game-path-state" class="path-state">GAME DIRECTORY NOT FOUND</div>' +
    '<div style="margin-top:9px"><button id="btn-game-folder" class="button">ВЫБРАТЬ ПАПКУ…</button></div>' +
    '</div>' +
    '</div><div class="settings-column">' +

    '<div class="settings-card"><div class="settings-card-title"><span class="settings-card-name">03 / SUBTITLE DISPLAY</span>' +
    '<span class="settings-card-index">ACCESSIBILITY</span></div>' +
    '<div class="setting-name">Размер шрифта субтитров</div>' +
    '<div class="setting-help">Предварительный просмотр ниже показывает выбранный размер.</div>' +
    '<div class="size-choices"><button id="size-small" class="size-choice is-active">SMALL</button>' +
    '<button id="size-medium" class="size-choice">MEDIUM</button><button id="size-large" class="size-choice">LARGE</button></div>' +
    '<div class="preview-box"><div class="preview-label">SUBTITLE PREVIEW / NORMANDY</div>' +
    '<div id="subtitle-preview" class="subtitle-preview preview-small">Нам пора двигаться. Вся галактика рассчитывает на нас.</div></div>' +
    '<div class="setting-row" style="margin-top:6px"><div><div class="setting-name">Показывать субтитры</div>' +
    '<div class="setting-help">Состояние переключателя в профиле демо.</div></div>' +
    '<button id="btn-subtitles" class="toggle-button">ВЫКЛ</button></div>' +
    '</div>' +

    '<div class="settings-card"><div class="settings-card-title"><span class="settings-card-name">04 / CONTROLLER</span>' +
    '<span class="settings-card-index">INPUT</span></div>' +
    '<div class="setting-row"><div><div class="setting-name">Вибрация контроллера</div>' +
    '<div class="setting-help">Переключатель предпочтения в профиле.</div></div>' +
    '<button id="btn-vibration" class="toggle-button is-on">ВКЛ</button></div>' +
    '</div>' +
    '</div></div>' +

    '<div class="settings-actions"><div class="settings-actions-left">' +
    '<button id="btn-defaults" class="button button-quiet">СБРОСИТЬ ПАРАМЕТРЫ</button></div>' +
    '<div class="settings-actions-right"><button id="btn-settings-cancel" class="button button-quiet">ОТМЕНА</button>' +
    '<button id="btn-save-settings" class="button button-primary">СОХРАНИТЬ ПРОФИЛЬ ✓</button></div></div>' +
    '<div class="profile-note">Примечание: эта демонстрация сохраняет настройки в собственный INI-профиль. Для применения размера субтитров, языка и других опций непосредственно в игре потребуется отдельная интеграция с конфигурацией Mass Effect.</div>' +
    '</div>' +

    '<div class="global-status"><div class="status-left"><span class="status-dot"></span>N7 COMMAND' +
    '<span id="demo-status" class="status-text">Система готова. Выбери кампанию или открой настройки.</span></div>' +
    '<div class="status-right">FMXPIXIE / HTML + CSS / NO JAVASCRIPT</div></div>' +
    '</div></body></html>';
end;

// ---------------------------------------------------------------------------
// DOM helpers — только вызовы уже используемые в проверенном демо MORROW.
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
  Log('FMXPixie MELE Demo: ' + S);
end;

function LanguageCode: String;
begin
  case LanguageIndex of
    0: Result := 'RUS';
    1: Result := 'INT';
    2: Result := 'FRA';
    3: Result := 'DEU';
    4: Result := 'ITA';
    5: Result := 'ESN';
    6: Result := 'JPN';
    7: Result := 'POL';
  else
    Result := 'RUS';
  end;
end;

function LanguageLabel: String;
begin
  case LanguageIndex of
    0: Result := 'РУССКИЙ / RUS ↻';
    1: Result := 'ENGLISH / INT ↻';
    2: Result := 'FRANÇAIS / FRA ↻';
    3: Result := 'DEUTSCH / DEU ↻';
    4: Result := 'ITALIANO / ITA ↻';
    5: Result := 'ESPAÑOL / ESN ↻';
    6: Result := '日本語 / JPN ↻';
    7: Result := 'POLSKI / POL ↻';
  else
    Result := 'РУССКИЙ / RUS ↻';
  end;
end;

function SubtitleSizeName: String;
begin
  case SubtitleSizeIndex of
    1: Result := 'SMALL';
    2: Result := 'MEDIUM';
    3: Result := 'LARGE';
  else
    Result := 'SMALL';
  end;
end;

function HasGameExecutable(const Root: String; GameIndex: Integer): Boolean;
var
  ExePath: String;
begin
  ExePath := '';
  case GameIndex of
    1: ExePath := Root + '\Game\ME1\Binaries\Win64\MassEffect1.exe';
    2: ExePath := Root + '\Game\ME2\Binaries\Win64\MassEffect2.exe';
    3: ExePath := Root + '\Game\ME3\Binaries\Win64\MassEffect3.exe';
  end;
  Result := (ExePath <> '') and FileExists(ExePath);
end;

function IsGameRootUsable(const Root: String): Boolean;
begin
  Result := (Root <> '') and
    (HasGameExecutable(Root, 1) or HasGameExecutable(Root, 2) or HasGameExecutable(Root, 3));
end;

procedure TryDefaultGameRoot(const Candidate: String);
begin
  if (GameRoot = '') and IsGameRootUsable(Candidate) then
    GameRoot := Candidate;
end;

procedure DetectGameRoot;
begin
  if IsGameRootUsable(GameRoot) then
    Exit;

  GameRoot := '';
  TryDefaultGameRoot(ExpandConstant('{commonpf32}\Steam\steamapps\common\Mass Effect Legendary Edition'));
  if IsWin64 then
    TryDefaultGameRoot(ExpandConstant('{commonpf64}\EA Games\Mass Effect Legendary Edition'));
  TryDefaultGameRoot(ExpandConstant('{commonpf32}\Origin Games\Mass Effect Legendary Edition'));
end;

procedure UpdateGameAvailability;
var
  S: String;
begin
  if HasGameExecutable(GameRoot, 1) then
  begin
    SetTextById('game1-state', 'GAME READY');
    SetClassById('game1-state', 'game-state is-ready');
  end
  else
  begin
    SetTextById('game1-state', 'НЕ НАЙДЕНА');
    SetClassById('game1-state', 'game-state');
  end;

  if HasGameExecutable(GameRoot, 2) then
  begin
    SetTextById('game2-state', 'GAME READY');
    SetClassById('game2-state', 'game-state is-ready');
  end
  else
  begin
    SetTextById('game2-state', 'НЕ НАЙДЕНА');
    SetClassById('game2-state', 'game-state');
  end;

  if HasGameExecutable(GameRoot, 3) then
  begin
    SetTextById('game3-state', 'GAME READY');
    SetClassById('game3-state', 'game-state is-ready');
  end
  else
  begin
    SetTextById('game3-state', 'НЕ НАЙДЕНА');
    SetClassById('game3-state', 'game-state');
  end;

  if GameRoot = '' then
  begin
    S := 'КАТАЛОГ ИГР НЕ УКАЗАН';
    SetTextById('game-root-value', 'Папка игры не выбрана.');
    SetTextById('game-path-state', 'GAME DIRECTORY NOT FOUND');
    SetClassById('game-path-state', 'path-state');
  end
  else if IsGameRootUsable(GameRoot) then
  begin
    S := 'ПАПКА ИГРЫ НАЙДЕНА';
    SetTextById('game-root-value', GameRoot);
    SetTextById('game-path-state', 'ОБНАРУЖЕНЫ ДОСТУПНЫЕ ИСПОЛНЯЕМЫЕ ФАЙЛЫ');
    SetClassById('game-path-state', 'path-state is-ready');
  end
  else
  begin
    S := 'ПРОВЕРЬ ПАПКУ ИГРЫ';
    SetTextById('game-root-value', GameRoot);
    SetTextById('game-path-state', 'ИСПОЛНЯЕМЫЕ ФАЙЛЫ ИГР НЕ НАЙДЕНЫ');
    SetClassById('game-path-state', 'path-state');
  end;
  SetTextById('home-root-state', S);
end;

procedure UpdateSettingsUI;
begin
  SetTextById('btn-language', LanguageLabel);

  if EnglishVoice then
  begin
    SetTextById('btn-english-vo', 'ВКЛ');
    SetClassById('btn-english-vo', 'toggle-button is-on');
  end
  else
  begin
    SetTextById('btn-english-vo', 'ВЫКЛ');
    SetClassById('btn-english-vo', 'toggle-button');
  end;

  SetClassById('size-small', 'size-choice');
  SetClassById('size-medium', 'size-choice');
  SetClassById('size-large', 'size-choice');
  case SubtitleSizeIndex of
    1:
      begin
        SetClassById('size-small', 'size-choice is-active');
        SetClassById('subtitle-preview', 'subtitle-preview preview-small');
      end;
    2:
      begin
        SetClassById('size-medium', 'size-choice is-active');
        SetClassById('subtitle-preview', 'subtitle-preview preview-medium');
      end;
    3:
      begin
        SetClassById('size-large', 'size-choice is-active');
        SetClassById('subtitle-preview', 'subtitle-preview preview-large');
      end;
  end;

  if SubtitlesEnabled then
  begin
    SetTextById('btn-subtitles', 'ВКЛ');
    SetClassById('btn-subtitles', 'toggle-button is-on');
  end
  else
  begin
    SetTextById('btn-subtitles', 'ВЫКЛ');
    SetClassById('btn-subtitles', 'toggle-button');
  end;

  if VibrationEnabled then
  begin
    SetTextById('btn-vibration', 'ВКЛ');
    SetClassById('btn-vibration', 'toggle-button is-on');
  end
  else
  begin
    SetTextById('btn-vibration', 'ВЫКЛ');
    SetClassById('btn-vibration', 'toggle-button');
  end;

  if HasUnsavedChanges then
    SetTextById('profile-state', 'UNSAVED')
  else
    SetTextById('profile-state', 'SAVED');
end;

procedure LoadSettings;
var
  L: String;
  SizeName: String;
begin
  GameRoot := GetIniString('Paths', 'GameRoot', '', SettingsFile);
  DetectGameRoot;

  L := GetIniString('Preferences', 'Language', 'RUS', SettingsFile);
  if L = 'INT' then LanguageIndex := 1
  else if L = 'FRA' then LanguageIndex := 2
  else if L = 'DEU' then LanguageIndex := 3
  else if L = 'ITA' then LanguageIndex := 4
  else if L = 'ESN' then LanguageIndex := 5
  else if L = 'JPN' then LanguageIndex := 6
  else if L = 'POL' then LanguageIndex := 7
  else LanguageIndex := 0;

  EnglishVoice := GetIniBool('Preferences', 'EnglishVoice', False, SettingsFile);
  SizeName := GetIniString('Preferences', 'SubtitleSize', 'SMALL', SettingsFile);
  if SizeName = 'MEDIUM' then SubtitleSizeIndex := 2
  else if SizeName = 'LARGE' then SubtitleSizeIndex := 3
  else SubtitleSizeIndex := 1;
  SubtitlesEnabled := GetIniBool('Preferences', 'Subtitles', False, SettingsFile);
  VibrationEnabled := GetIniBool('Preferences', 'ControllerVibration', True, SettingsFile);
  HasUnsavedChanges := False;
end;

procedure SaveSettings;
var
  Ok: Boolean;
begin
  if not ForceDirectories(SettingsDir) then
  begin
    SetStatus('Не удалось создать папку профиля: ' + SettingsDir);
    Exit;
  end;

  Ok := True;
  if not SetIniString('Paths', 'GameRoot', GameRoot, SettingsFile) then Ok := False;
  if not SetIniString('Preferences', 'Language', LanguageCode, SettingsFile) then Ok := False;
  if not SetIniBool('Preferences', 'EnglishVoice', EnglishVoice, SettingsFile) then Ok := False;
  if not SetIniString('Preferences', 'SubtitleSize', SubtitleSizeName, SettingsFile) then Ok := False;
  if not SetIniBool('Preferences', 'Subtitles', SubtitlesEnabled, SettingsFile) then Ok := False;
  if not SetIniBool('Preferences', 'ControllerVibration', VibrationEnabled, SettingsFile) then Ok := False;

  if Ok then
  begin
    HasUnsavedChanges := False;
    UpdateSettingsUI;
    SetStatus('Профиль сохранён: ' + SettingsFile + '. Параметры самой игры этим демо не изменяются.');
  end
  else
    SetStatus('Не удалось полностью сохранить профиль: ' + SettingsFile);
end;

procedure UpdateGameSelection;
begin
  SetClassById('card-me1', 'game-card');
  SetClassById('card-me2', 'game-card');
  SetClassById('card-me3', 'game-card');
  case SelectedGame of
    1: SetClassById('card-me1', 'game-card selected');
    2: SetClassById('card-me2', 'game-card selected');
    3: SetClassById('card-me3', 'game-card selected');
  end;
end;

procedure SelectGame(GameIndex: Integer);
begin
  SelectedGame := GameIndex;
  UpdateGameSelection;
  case SelectedGame of
    1: SetStatus('Выбрана Mass Effect. Нажми «Запустить» на карточке или открой настройки.');
    2: SetStatus('Выбрана Mass Effect 2. Нажми «Запустить» на карточке или открой настройки.');
    3: SetStatus('Выбрана Mass Effect 3. Нажми «Запустить» на карточке или открой настройки.');
  end;
end;

procedure ShowHomePage;
begin
  SetStyleById('page-home', 'display:block;');
  SetStyleById('page-settings', 'display:none;');
  UpdateGameSelection;
  UpdateGameAvailability;
  SetStatus('Система готова. Выбери кампанию или открой настройки.');
  Doc.Changed;
end;

procedure ShowSettingsPage;
begin
  SetStyleById('page-home', 'display:none;');
  SetStyleById('page-settings', 'display:block;');
  UpdateSettingsUI;
  UpdateGameAvailability;
  SetStatus('Настройки открыты. Изменения будут сохранены в профиль лаунчера.');
  Doc.Changed;
end;

procedure MarkChanged;
begin
  HasUnsavedChanges := True;
  UpdateSettingsUI;
end;

procedure ResetPreferences;
begin
  LanguageIndex := 0;
  EnglishVoice := False;
  SubtitleSizeIndex := 1;
  SubtitlesEnabled := False;
  VibrationEnabled := True;
  MarkChanged;
  SetStatus('Параметры демо возвращены к значениям по умолчанию. Нажми «Сохранить профиль».');
  Doc.Changed;
end;

procedure ChooseGameRoot;
var
  ChosenFolder: String;
begin
  ChosenFolder := GameRoot;
  if ChosenFolder = '' then
    ChosenFolder := ExpandConstant('{commonpf32}\Steam\steamapps\common\Mass Effect Legendary Edition');

  if BrowseForFolder('Выбери корневую папку Mass Effect Legendary Edition (в ней должна быть папка Game)',
    ChosenFolder, True) then
  begin
    GameRoot := ChosenFolder;
    if IsGameRootUsable(GameRoot) then
    begin
      UpdateGameAvailability;
      SetStatus('Папка игры выбрана. Найденные EXE отмечены как GAME READY.');
      SaveSettings;
    end
    else
    begin
      UpdateGameAvailability;
      SetStatus('В выбранной папке не найдены MassEffect1.exe, MassEffect2.exe или MassEffect3.exe. Проверь корневую папку.');
    end;
  end;
  Doc.Changed;
end;

function GameExePath(GameIndex: Integer): String;
begin
  case GameIndex of
    1: Result := GameRoot + '\Game\ME1\Binaries\Win64\MassEffect1.exe';
    2: Result := GameRoot + '\Game\ME2\Binaries\Win64\MassEffect2.exe';
    3: Result := GameRoot + '\Game\ME3\Binaries\Win64\MassEffect3.exe';
  else
    Result := '';
  end;
end;

procedure StartGame(GameIndex: Integer);
var
  ExePath: String;
  ResultCode: Integer;
  GameName: String;
begin
  case GameIndex of
    1: GameName := 'Mass Effect';
    2: GameName := 'Mass Effect 2';
    3: GameName := 'Mass Effect 3';
  else
    GameName := 'Mass Effect';
  end;

  ExePath := GameExePath(GameIndex);
  if (GameRoot = '') or (not FileExists(ExePath)) then
  begin
    ShowSettingsPage;
    SetStatus('Исполняемый файл ' + GameName + ' не найден. Укажи корневую папку игры.');
    Exit;
  end;

  if HasUnsavedChanges then
    SaveSettings;

  if Exec(ExePath, '', ExtractFileDir(ExePath), SW_SHOWNORMAL, ewNoWait, ResultCode) then
  begin
    SetStatus('Запущен ' + GameName + '. Сохранённый профиль демо пока не применяется к внутренним настройкам игры.');
    FMXForm.Minimize;
  end
  else
    SetStatus('Не удалось запустить ' + GameName + '. Код ошибки Windows: ' + IntToStr(ResultCode));
end;

procedure CloseSetup;
begin
  if HasUnsavedChanges then
    SaveSettings;
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

// ---------------------------------------------------------------------------
// Clicks are handled in Pascal Script. No JavaScript is used in the HTML.
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

  if Id = 'btn-settings-top' then
  begin
    ShowSettingsPage;
    Result := True;
    Exit;
  end;

  if Id = 'btn-settings-back-top' then
  begin
    ShowHomePage;
    Result := True;
    Exit;
  end;

  if Id = 'btn-settings-cancel' then
  begin
    if HasUnsavedChanges then
      LoadSettings;
    ShowHomePage;
    SetStatus('Возврат на главную страницу. Несохранённые изменения отброшены.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-save-settings' then
  begin
    SaveSettings;
    Result := True;
    Exit;
  end;

  if Id = 'btn-defaults' then
  begin
    ResetPreferences;
    Result := True;
    Exit;
  end;

  if Id = 'btn-game-folder' then
  begin
    ChooseGameRoot;
    Result := True;
    Exit;
  end;

  if Id = 'btn-language' then
  begin
    LanguageIndex := LanguageIndex + 1;
    if LanguageIndex > 7 then LanguageIndex := 0;
    MarkChanged;
    SetStatus('Выбран язык ' + LanguageCode + '. Сохрани профиль, чтобы оставить выбор.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-english-vo' then
  begin
    EnglishVoice := not EnglishVoice;
    MarkChanged;
    if EnglishVoice then
      SetStatus('English VO override включён в профиле демо.')
    else
      SetStatus('English VO override выключен в профиле демо.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'size-small' then
  begin
    SubtitleSizeIndex := 1;
    MarkChanged;
    SetStatus('Размер субтитров: SMALL. Это предварительный просмотр профиля демо.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'size-medium' then
  begin
    SubtitleSizeIndex := 2;
    MarkChanged;
    SetStatus('Размер субтитров: MEDIUM. Это предварительный просмотр профиля демо.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'size-large' then
  begin
    SubtitleSizeIndex := 3;
    MarkChanged;
    SetStatus('Размер субтитров: LARGE. Это предварительный просмотр профиля демо.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-subtitles' then
  begin
    SubtitlesEnabled := not SubtitlesEnabled;
    MarkChanged;
    if SubtitlesEnabled then
      SetStatus('Субтитры включены в профиле демо.')
    else
      SetStatus('Субтитры выключены в профиле демо.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-vibration' then
  begin
    VibrationEnabled := not VibrationEnabled;
    MarkChanged;
    if VibrationEnabled then
      SetStatus('Вибрация контроллера включена в профиле демо.')
    else
      SetStatus('Вибрация контроллера выключена в профиле демо.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if (Id = 'card-me1') or (Id = 'game1-state') then
  begin
    SelectGame(1);
    Result := True;
    Exit;
  end;

  if (Id = 'card-me2') or (Id = 'game2-state') then
  begin
    SelectGame(2);
    Result := True;
    Exit;
  end;

  if (Id = 'card-me3') or (Id = 'game3-state') then
  begin
    SelectGame(3);
    Result := True;
    Exit;
  end;

  if Id = 'btn-launch-me1' then
  begin
    StartGame(1);
    Result := True;
    Exit;
  end;

  if Id = 'btn-launch-me2' then
  begin
    StartGame(2);
    Result := True;
    Exit;
  end;

  if Id = 'btn-launch-me3' then
  begin
    StartGame(3);
    Result := True;
    Exit;
  end;
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
  SettingsDir := ExpandConstant('{localappdata}\FMXPixie\MELELauncherDemo');
  SettingsFile := SettingsDir + '\settings.ini';
  SelectedGame := 1;
  LanguageIndex := 0;
  SubtitleSizeIndex := 1;
  EnglishVoice := False;
  SubtitlesEnabled := False;
  VibrationEnabled := True;
  HasUnsavedChanges := False;

  ForceDirectories(SettingsDir);

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBlankForm(WizardForm.Handle, $FF080E17, '', True);

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
  View.LoadFromStringUrl(BuildLauncherHtml, TempDir + '\');

  Doc.FCreate(View.GetDocument);
  LoadSettings;
  UpdateSettingsUI;
  UpdateGameAvailability;
  UpdateGameSelection;
  SetStatus('Система готова. Выбери кампанию или открой настройки.');
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
