; ============================================================================
; FMXPixie Demo — Fluent Setup Wizard
;
; Three-stage installer mock-up inspired by WinUI 3 / Fluent Design:
;   1. Destination folder
;   2. Component selection
;   3. Installation progress and completion
;
; This is an UI/API demonstration only. No files are installed and no real
; directory picker or component installer is invoked. The progress screen is
; manually advanced so each simulated phase can be inspected.
;
; Required existing files:
;   Modules\FMXPixieHandle.iss
;   Modules\FMXPixie_x86.dll
;   Modules\FMXPixie_x64.dll
; ============================================================================

#define DemoAppName "FMXPixie - FluentInstaller Demo"
#define DemoAppVersion "1.0"

[Setup]
AppName={#DemoAppName}
AppVersion={#DemoAppVersion}
CreateAppDir=no
Uninstallable=no
OutputBaseFilename=FMXPixie - FluentInstaller Demo
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
  DEMO_FORM_WIDTH = 980;
  DEMO_FORM_HEIGHT = 720;
  TITLEBAR_HEIGHT = 34;
  TITLEBAR_BUTTONS_WIDTH = 92;
  STAGE_LOCATION = 1;
  STAGE_COMPONENTS = 2;
  STAGE_INSTALL = 3;
  INSTALL_PHASE_COUNT = 5;

var
  FMXForm: FForm;
  TitleView: FPixieHtmlView;
  View: FPixieHtmlView;
  Doc: FPixieDocument;
  Elem: FPixieElement;

  TempDir: String;
  InstallPath: String;
  BrowseStep: Integer;
  WizardStage: Integer;
  InstallStarted: Boolean;
  ProgressStep: Integer;
  IncludeDesktopShortcut: Boolean;
  IncludeStartMenuShortcut: Boolean;
  IncludeHighResAssets: Boolean;

function BuildTitleBarHtml: String; //#f7f8fa
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:transparent;color:#263244;font-family:"Segoe UI",Arial,sans-serif;font-size:12px;}' +
    '.titlebar{position:relative;width:100%;height:33px;line-height:32px;background:transparent;' +
    'border-bottom:1px solid #e5e7eb;overflow:hidden;}' +
    '.brand-mark{display:inline-block;vertical-align:middle;width:18px;height:18px;line-height:18px;' +
    'margin:0 8px 0 13px;text-align:center;border-radius:4px;background:#2563eb;color:#fff;' +
    'font-size:11px;font-weight:bold;}' +
    '.caption{color:#253247;font-weight:600;letter-spacing:.2px;}' +
    '.caption-note{margin-left:8px;color:#8a94a5;font-size:11px;}' +
    '.controls{position:absolute;right:0;top:0;width:92px;height:32px;font-size:0;}' +
    '.control{display:inline-block;vertical-align:top;width:46px;height:32px;line-height:31px;' +
    'text-align:center;color:#4b5563;font-size:20px;cursor:pointer;}' +
    '.control:hover{background:#e9edf3;color:#111827;}' +
    '.close{font-size:23px;}' +
    '.close:hover{background:#c42b1c;color:#fff;}' +
    '</style></head><body><div class="titlebar">' +
    '<span class="brand-mark">N</span><span class="caption">NORTHSTAR SETUP</span>' +
    '<span class="caption-note">INSTALLATION WIZARD / DEMO</span>' +
    '<div class="controls"><div id="title-minimize" class="control" title="Minimize">−</div>' +
    '<div id="title-close" class="control close" title="Close">×</div></div>' +
    '</div></body></html>';
end;

function BuildWizardHtml: String;
begin
  Result :=
    '<!doctype html><html><head><meta charset="utf-8"><style>' +
    '*{box-sizing:border-box;}' +
    'html,body{width:100%;height:100%;margin:0;padding:0;overflow:hidden;}' +
    'body{background:transparent;color:#202938;font-family:"Segoe UI",Arial,sans-serif;font-size:13px;}' +
    '.app{padding:17px 27px 9px 27px;width:100%;height:100%;}' +
    '.topbar{height:35px;display:flex;align-items:center;justify-content:space-between;}' +
    '.brand{display:flex;align-items:center;}' +
    '.app-icon{width:32px;height:32px;border-radius:7px;background:#2563eb;color:#fff;' +
    'font-weight:700;font-size:16px;line-height:32px;text-align:center;margin-right:10px;' +
    'box-shadow:0 2px 5px rgba(37,99,235,.2);}' +
    '.brand-name{font-size:14px;font-weight:650;letter-spacing:.2px;color:#1f2937;}' +
    '.brand-caption{font-size:10px;color:#8b95a5;margin-left:9px;letter-spacing:.6px;}' +
    '.demo-chip{display:inline-block;padding:5px 9px;border:1px solid #dbe6fb;border-radius:5px;' +
    'background:#eef4ff;color:#315ca8;font-size:10px;font-weight:600;letter-spacing:.5px;}' +
    '.stepper{display:flex;align-items:center;margin-top:17px;height:40px;}' +
    '.step{display:flex;align-items:center;white-space:nowrap;color:#8993a3;}' +
    '.step-number{width:25px;height:25px;border:1px solid #d4dae4;border-radius:50%;line-height:23px;' +
    'text-align:center;font-size:11px;font-weight:600;background:#fff;margin-right:8px;}' +
    '.step-label{font-size:11px;font-weight:600;}' +
    '.step-line{height:1px;background:#dce1e9;flex:1;margin:0 17px;min-width:18px;}' +
    '.step.is-active{color:#245cc5;}' +
    '.step.is-active .step-number{background:#2563eb;border-color:#2563eb;color:#fff;}' +
    '.step.is-done{color:#53657e;}' +
    '.step.is-done .step-number{background:#e8f1ff;border-color:#b9d0ff;color:#2058b5;}' +
    '.intro{margin-top:15px;}' +
    '.eyebrow{font-size:10px;text-transform:uppercase;letter-spacing:1.25px;color:#6d7b91;font-weight:700;}' +
    '.headline{font-size:25px;line-height:1.18;font-weight:600;letter-spacing:-.5px;margin-top:4px;color:#172033;}' +
    '.lede{font-size:12px;line-height:1.45;color:#737f91;margin-top:5px;}' +
    '.page-content{margin-top:14px;height:354px;}' +
    '.wizard-page{display:none;width:100%;height:100%;}' +
    '.wizard-page.is-visible{display:block;}' +
    '.content-grid{display:grid;grid-template-columns:1.65fr 1fr;gap:15px;height:100%;}' +
    '.panel{height:100%;background:#fff;border:1px solid #e1e5ec;border-radius:8px;padding:18px 19px;' +
    'box-shadow:0 2px 8px rgba(23,32,51,.025);overflow:hidden;}' +
    '.panel-title{font-size:14px;font-weight:650;color:#202b3c;}' +
    '.panel-subtitle{font-size:11px;line-height:1.45;color:#7a8698;margin-top:5px;}' +
    '.field-label{display:block;font-size:11px;font-weight:650;color:#566276;margin:20px 0 7px 0;}' +
    '.path-row{display:flex;align-items:center;border:1px solid #cfd6e1;border-radius:6px;background:#fff;' +
    'height:42px;overflow:hidden;}' +
    '.folder-icon{width:41px;text-align:center;color:#64748b;font-size:17px;}' +
    '.path-text{flex:1;min-width:0;color:#354258;font-size:11px;white-space:nowrap;overflow:hidden;' +
    'text-overflow:ellipsis;}' +
    '.path-button{height:40px;padding:0 13px;border:0;border-left:1px solid #d8dee8;background:#f8fafc;' +
    'color:#245cc5;font-size:11px;font-weight:650;cursor:pointer;}' +
    '.path-button:hover{background:#edf4ff;}' +
    '.hint{display:flex;margin-top:12px;font-size:10px;line-height:1.5;color:#8590a0;}' +
    '.hint-icon{margin-right:7px;color:#2563eb;font-weight:bold;}' +
    '.summary-heading{font-size:11px;font-weight:700;color:#536075;letter-spacing:.5px;text-transform:uppercase;}' +
    '.summary-illustration{height:104px;border-radius:7px;margin-top:14px;position:relative;overflow:hidden;' +
    'background:linear-gradient(135deg,#e8f0ff 0%,#f1f5ff 56%,#e5ecf9 100%);}' +
    '.orb-one{position:absolute;width:74px;height:74px;border-radius:50%;background:#c8d9ff;left:34px;top:17px;}' +
    '.orb-two{position:absolute;width:46px;height:46px;border-radius:50%;background:#8eb3ff;left:70px;top:36px;' +
    'border:7px solid #e8f0ff;}' +
    '.illustration-line{position:absolute;left:145px;top:27px;width:86px;height:7px;border-radius:4px;background:#b7cafa;}' +
    '.illustration-line.second{top:43px;width:64px;background:#cfdbf3;}' +
    '.illustration-line.third{top:59px;width:74px;background:#cfdbf3;}' +
    '.summary-list{margin-top:15px;}' +
    '.summary-row{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid #edf0f4;' +
    'font-size:11px;}' +
    '.summary-row:last-child{border-bottom:0;}' +
    '.summary-key{color:#8490a0;}' +
    '.summary-value{color:#344156;font-weight:600;text-align:right;}' +
    '.component-list{margin-top:14px;}' +
    '.component-row{display:flex;align-items:flex-start;padding:11px 10px;margin-top:7px;border:1px solid #e5e9f0;' +
    'border-radius:7px;background:#fff;cursor:pointer;}' +
    '.component-row:hover{background:#f8faff;border-color:#b9cafa;}' +
    '.component-row.is-selected{background:#f7faff;border-color:#c9d9fb;}' +
    '.checkmark{flex:none;width:17px;height:17px;border:1px solid #bac4d2;border-radius:4px;margin:1px 10px 0 0;' +
    'text-align:center;line-height:15px;color:#fff;font-size:12px;font-weight:bold;background:#fff;}' +
    '.checkmark.is-checked{background:#2563eb;border-color:#2563eb;}' +
    '.component-copy{flex:1;min-width:0;}' +
    '.component-name{font-size:12px;font-weight:650;color:#2b3648;}' +
    '.component-description{font-size:10px;line-height:1.4;color:#8390a1;margin-top:4px;}' +
    '.component-size{font-size:10px;color:#78869a;white-space:nowrap;margin-left:10px;padding-top:2px;}' +
    '.required-label{font-size:9px;color:#5273aa;background:#eaf1ff;padding:3px 6px;border-radius:4px;margin-left:7px;' +
    'font-weight:650;vertical-align:1px;}' +
    '.storage-card{padding:14px;border-radius:7px;background:#f8fafc;border:1px solid #e7ebf2;margin-top:16px;}' +
    '.storage-top{display:flex;justify-content:space-between;align-items:center;font-size:11px;}' +
    '.storage-top strong{font-size:12px;color:#35445b;}' +
    '.storage-track{height:6px;border-radius:6px;background:#e1e7f0;margin-top:10px;overflow:hidden;}' +
    '.storage-fill{height:6px;width:22%;background:#5b8def;border-radius:6px;}' +
    '.storage-note{font-size:10px;line-height:1.45;color:#8590a0;margin-top:8px;}' +
    '.review-list{margin-top:17px;border:1px solid #e7ebf2;border-radius:7px;overflow:hidden;}' +
    '.review-row{display:flex;justify-content:space-between;padding:10px 12px;border-bottom:1px solid #edf0f4;font-size:11px;}' +
    '.review-row:last-child{border-bottom:0;}' +
    '.review-key{color:#7e8999;}' +
    '.review-value{color:#344156;font-weight:600;text-align:right;max-width:64%;}' +
    '.notice{display:flex;margin-top:14px;padding:11px 12px;border:1px solid #d8e5fc;background:#f3f7ff;border-radius:7px;' +
    'font-size:10px;line-height:1.5;color:#647590;}' +
    '.notice-icon{color:#2563eb;font-size:14px;font-weight:bold;margin-right:9px;}' +
    '.state-panel{display:none;}' +
    '.state-panel.is-visible{display:block;}' +
    '.progress-top{display:flex;align-items:center;justify-content:space-between;margin-top:18px;}' +
    '.progress-title{font-size:12px;font-weight:650;color:#344156;}' +
    '.progress-percent{font-size:22px;line-height:1;font-weight:650;color:#2563eb;}' +
    '.progress-track{height:8px;background:#e8edf5;border-radius:8px;margin-top:11px;overflow:hidden;}' +
    '.progress-fill{height:8px;width:0%;background:#2563eb;border-radius:8px;}' +
    '.progress-status{font-size:11px;color:#68768a;margin-top:10px;min-height:18px;}' +
    '.phase-list{margin-top:15px;}' +
    '.phase-row{display:flex;align-items:center;padding:6px 0;border-bottom:1px solid #eef1f5;color:#8a95a5;font-size:11px;}' +
    '.phase-row:last-child{border-bottom:0;}' +
    '.phase-icon{width:21px;height:21px;line-height:19px;border:1px solid #dce2eb;border-radius:50%;' +
    'text-align:center;margin-right:10px;font-size:10px;background:#fff;}' +
    '.phase-row.is-done{color:#3d4d63;}' +
    '.phase-row.is-done .phase-icon{background:#e8f3ed;border-color:#b9dec8;color:#20804b;}' +
    '.finish-wrap{text-align:center;padding:16px 16px 8px 16px;}' +
    '.finish-icon{width:56px;height:56px;line-height:54px;border-radius:50%;background:#e6f5eb;border:1px solid #bde5cb;' +
    'color:#18834a;font-size:27px;font-weight:600;margin:0 auto 13px auto;}' +
    '.finish-title{font-size:21px;font-weight:650;color:#1f2d40;}' +
    '.finish-copy{font-size:11px;line-height:1.55;color:#738094;margin:8px auto 0 auto;max-width:380px;}' +
    '.finish-tag{display:inline-block;margin-top:13px;background:#f1f8f3;border:1px solid #d1ead9;color:#328253;' +
    'font-size:10px;padding:6px 10px;border-radius:5px;font-weight:650;}' +
    '.footer{display:flex;align-items:center;justify-content:space-between;margin-top:13px;height:39px;}' +
    '.footer-left,.footer-right{display:flex;align-items:center;gap:9px;}' +
    '.button{height:36px;padding:0 16px;border-radius:6px;border:1px solid #d6dce6;background:#fff;' +
    'color:#4b596e;font-family:"Segoe UI",Arial,sans-serif;font-size:11px;font-weight:600;cursor:pointer;}' +
    '.button:hover{background:#f0f4fa;border-color:#c3ccda;}' +
    '.button-primary{background:#2563eb;border-color:#2563eb;color:#fff;min-width:145px;}' +
    '.button-primary:hover{background:#1d4ed8;border-color:#1d4ed8;}' +
    '.button.is-hidden{visibility:hidden;}' +
    '.statusbar{margin-top:7px;display:flex;align-items:center;justify-content:space-between;color:#97a0ae;font-size:9px;}' +
    '.status-left{display:flex;align-items:center;}' +
    '.status-dot{display:inline-block;width:6px;height:6px;border-radius:50%;background:#6d9b82;margin-right:7px;}' +
    '.status-right{letter-spacing:.4px;}' +
    '</style></head><body><div class="app">' +
    '<div class="topbar"><div class="brand"><div class="app-icon">N</div>' +
    '<span class="brand-name">Northstar</span><span class="brand-caption">DESKTOP CLIENT</span></div>' +
    '<span class="demo-chip">SIMULATION MODE</span></div>' +
    '<div class="stepper">' +
    '<div id="step-1" class="step is-active"><span class="step-number">1</span><span class="step-label">Location</span></div>' +
    '<div class="step-line"></div>' +
    '<div id="step-2" class="step"><span class="step-number">2</span><span class="step-label">Components</span></div>' +
    '<div class="step-line"></div>' +
    '<div id="step-3" class="step"><span class="step-number">3</span><span class="step-label">Install</span></div>' +
    '</div>' +
    '<div class="intro"><div class="eyebrow" id="eyebrow">STEP 01 / DESTINATION</div>' +
    '<div class="headline" id="page-heading">Where should Northstar be installed?</div>' +
    '<div class="lede" id="page-lede">Choose the folder where the application will live. You can change this later.</div></div>' +
    '<div class="page-content">' +
    '<div id="page-location" class="wizard-page is-visible"><div class="content-grid">' +
    '<div class="panel"><div class="panel-title">Installation location</div>' +
    '<div class="panel-subtitle">The application files would be placed in this folder.</div>' +
    '<label class="field-label">DESTINATION FOLDER</label>' +
    '<div class="path-row"><div class="folder-icon">▰</div><div id="target-path" class="path-text">C:\\Program Files\\Northstar\\Desktop Client</div>' +
    '<button id="btn-browse" class="path-button">Change</button></div>' +
    '<div class="hint"><span class="hint-icon">ⓘ</span><span>This demonstration cycles through sample paths. It does not create folders or write files.</span></div>' +
    '<div class="storage-card"><div class="storage-top"><span>Estimated space required</span><strong id="required-size">920 MB</strong></div>' +
    '<div class="storage-track"><div id="storage-fill" class="storage-fill"></div></div>' +
    '<div class="storage-note">Disk space shown here is illustrative and does not check your actual drive.</div></div>' +
    '</div>' +
    '<div class="panel"><div class="summary-heading">Before you continue</div>' +
    '<div class="summary-illustration"><div class="orb-one"></div><div class="orb-two"></div>' +
    '<div class="illustration-line"></div><div class="illustration-line second"></div><div class="illustration-line third"></div></div>' +
    '<div class="summary-list"><div class="summary-row"><span class="summary-key">Product</span><span class="summary-value">Northstar Client</span></div>' +
    '<div class="summary-row"><span class="summary-key">Version</span><span class="summary-value">4.2.0 Demo</span></div>' +
    '<div class="summary-row"><span class="summary-key">Platform</span><span class="summary-value">Windows desktop</span></div>' +
    '<div class="summary-row"><span class="summary-key">Installer</span><span class="summary-value">Interactive mock-up</span></div></div>' +
    '</div></div></div>' +
    '<div id="page-components" class="wizard-page"><div class="content-grid">' +
    '<div class="panel"><div class="panel-title">Choose what to install</div>' +
    '<div class="panel-subtitle">Core files are required. The optional items can be switched on or off.</div>' +
    '<div class="component-list">' +
    '<div id="comp-core" class="component-row is-selected"><div class="checkmark is-checked">✓</div>' +
    '<div class="component-copy"><div class="component-name">Core application <span class="required-label">REQUIRED</span></div>' +
    '<div class="component-description">Main program files and built-in resources.</div></div><div class="component-size">920 MB</div></div>' +
    '<div id="comp-desktop" class="component-row is-selected"><div id="mark-desktop" class="checkmark is-checked">✓</div>' +
    '<div class="component-copy"><div class="component-name">Desktop shortcut</div><div class="component-description">Add a shortcut to your desktop.</div></div>' +
    '<div class="component-size">1 KB</div></div>' +
    '<div id="comp-startmenu" class="component-row is-selected"><div id="mark-startmenu" class="checkmark is-checked">✓</div>' +
    '<div class="component-copy"><div class="component-name">Start menu entries</div><div class="component-description">Create a Start menu folder and launch entry.</div></div>' +
    '<div class="component-size">2 KB</div></div>' +
    '<div id="comp-hd" class="component-row"><div id="mark-hd" class="checkmark"></div>' +
    '<div class="component-copy"><div class="component-name">High-resolution assets</div><div class="component-description">Optional high-detail artwork and extra textures.</div></div>' +
    '<div class="component-size">640 MB</div></div>' +
    '</div></div>' +
    '<div class="panel"><div class="summary-heading">Selection summary</div>' +
    '<div class="summary-list"><div class="summary-row"><span class="summary-key">Destination</span><span id="components-path" class="summary-value">C:\\Program Files...</span></div>' +
    '<div class="summary-row"><span class="summary-key">Core application</span><span class="summary-value">Included</span></div>' +
    '<div class="summary-row"><span class="summary-key">Desktop shortcut</span><span id="summary-desktop" class="summary-value">Included</span></div>' +
    '<div class="summary-row"><span class="summary-key">Start menu</span><span id="summary-startmenu" class="summary-value">Included</span></div>' +
    '<div class="summary-row"><span class="summary-key">HD assets</span><span id="summary-hd" class="summary-value">Not selected</span></div>' +
    '<div class="summary-row"><span class="summary-key">Total size</span><span id="components-size" class="summary-value">920 MB</span></div></div>' +
    '<div class="notice"><span class="notice-icon">ⓘ</span><span>This is a visual setup demo. Component choices update the summary only; no installation occurs.</span></div>' +
    '</div></div></div>' +
    '<div id="page-install" class="wizard-page"><div class="content-grid">' +
    '<div class="panel">' +
    '<div id="install-ready" class="state-panel is-visible"><div class="panel-title">Ready to install</div>' +
    '<div class="panel-subtitle">Review your choices, then start the simulated installation.</div>' +
    '<div class="review-list"><div class="review-row"><span class="review-key">Install to</span><span id="review-path" class="review-value">C:\\Program Files...</span></div>' +
    '<div class="review-row"><span class="review-key">Components</span><span id="review-components" class="review-value">Core, shortcuts</span></div>' +
    '<div class="review-row"><span class="review-key">Estimated size</span><span id="review-size" class="review-value">920 MB</span></div></div>' +
    '<div class="notice"><span class="notice-icon">ⓘ</span><span>Nothing will be installed. This step demonstrates the progress and completion UI.</span></div></div>' +
    '<div id="install-progress" class="state-panel"><div class="panel-title">Installing Northstar</div>' +
    '<div class="panel-subtitle">The status below changes as you advance through the simulated phases.</div>' +
    '<div class="progress-top"><span class="progress-title">Installation progress</span><span id="progress-percent" class="progress-percent">0%</span></div>' +
    '<div class="progress-track"><div id="progress-fill" class="progress-fill"></div></div>' +
    '<div id="progress-status" class="progress-status">Waiting to begin...</div>' +
    '<div class="phase-list">' +
    '<div id="phase-1" class="phase-row"><span id="phase-marker-1" class="phase-icon">1</span><span>Prepare installation</span></div>' +
    '<div id="phase-2" class="phase-row"><span id="phase-marker-2" class="phase-icon">2</span><span>Copy core application files</span></div>' +
    '<div id="phase-3" class="phase-row"><span id="phase-marker-3" class="phase-icon">3</span><span>Apply selected components</span></div>' +
    '<div id="phase-4" class="phase-row"><span id="phase-marker-4" class="phase-icon">4</span><span>Create shortcuts</span></div>' +
    '<div id="phase-5" class="phase-row"><span id="phase-marker-5" class="phase-icon">5</span><span>Finalize setup</span></div>' +
    '</div><div class="hint"><span class="hint-icon">↻</span><span>Click “Advance simulation” to move to the next phase.</span></div></div>' +
    '<div id="install-complete" class="state-panel"><div class="finish-wrap"><div class="finish-icon">✓</div>' +
    '<div class="finish-title">All done.</div><div class="finish-copy">Northstar Setup has completed the demonstration successfully. No application files were created or modified.</div>' +
    '<div class="finish-tag">SIMULATION COMPLETE</div></div></div>' +
    '</div>' +
    '<div class="panel"><div class="summary-heading">Installation details</div>' +
    '<div class="summary-illustration"><div class="orb-one"></div><div class="orb-two"></div>' +
    '<div class="illustration-line"></div><div class="illustration-line second"></div><div class="illustration-line third"></div></div>' +
    '<div class="summary-list"><div class="summary-row"><span class="summary-key">Application</span><span class="summary-value">Northstar Client</span></div>' +
    '<div class="summary-row"><span class="summary-key">Target folder</span><span id="install-summary-path" class="summary-value">C:\\Program Files...</span></div>' +
    '<div class="summary-row"><span class="summary-key">Optional assets</span><span id="install-summary-assets" class="summary-value">Standard</span></div>' +
    '<div class="summary-row"><span class="summary-key">Required space</span><span id="install-summary-size" class="summary-value">920 MB</span></div></div>' +
    '<div class="storage-card"><div class="storage-top"><span>Setup engine</span><strong id="engine-status">Ready</strong></div>' +
    '<div class="storage-note">A mock installer flow powered by HTML, CSS and Inno Pascal Script events.</div></div>' +
    '</div></div></div>' +
    '</div>' +
    '<div class="footer"><div class="footer-left"><button id="btn-exit" class="button">Exit demo</button></div>' +
    '<div class="footer-right"><button id="btn-back" class="button is-hidden">Back</button>' +
    '<button id="btn-primary" class="button button-primary">Next</button></div></div>' +
    '<div class="statusbar"><div class="status-left"><span class="status-dot"></span><span id="demo-status">Ready. This is a simulated installer.</span></div>' +
    '<div class="status-right">FMXPIXIE&nbsp; / &nbsp;FLUENT SETUP CONCEPT</div></div>' +
    '</div></body></html>';
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
  Log('FMXPixie Fluent Setup Demo: ' + S);
end;

function ComponentsSummary: String;
begin
  Result := 'Core application';
  if IncludeDesktopShortcut then
    Result := Result + ', desktop shortcut';
  if IncludeStartMenuShortcut then
    Result := Result + ', Start menu';
  if IncludeHighResAssets then
    Result := Result + ', HD assets';
end;

function RequiredSizeText: String;
begin
  if IncludeHighResAssets then
    Result := '1.56 GB'
  else
    Result := '920 MB';
end;

procedure UpdateComponentVisuals;
begin
  if IncludeDesktopShortcut then
  begin
    SetClassById('comp-desktop', 'component-row is-selected');
    SetClassById('mark-desktop', 'checkmark is-checked');
    SetTextById('mark-desktop', '✓');
    SetTextById('summary-desktop', 'Included');
  end
  else
  begin
    SetClassById('comp-desktop', 'component-row');
    SetClassById('mark-desktop', 'checkmark');
    SetTextById('mark-desktop', '');
    SetTextById('summary-desktop', 'Not selected');
  end;

  if IncludeStartMenuShortcut then
  begin
    SetClassById('comp-startmenu', 'component-row is-selected');
    SetClassById('mark-startmenu', 'checkmark is-checked');
    SetTextById('mark-startmenu', '✓');
    SetTextById('summary-startmenu', 'Included');
  end
  else
  begin
    SetClassById('comp-startmenu', 'component-row');
    SetClassById('mark-startmenu', 'checkmark');
    SetTextById('mark-startmenu', '');
    SetTextById('summary-startmenu', 'Not selected');
  end;

  if IncludeHighResAssets then
  begin
    SetClassById('comp-hd', 'component-row is-selected');
    SetClassById('mark-hd', 'checkmark is-checked');
    SetTextById('mark-hd', '✓');
    SetTextById('summary-hd', 'Included');
    SetTextById('install-summary-assets', 'High-resolution');
  end
  else
  begin
    SetClassById('comp-hd', 'component-row');
    SetClassById('mark-hd', 'checkmark');
    SetTextById('mark-hd', '');
    SetTextById('summary-hd', 'Not selected');
    SetTextById('install-summary-assets', 'Standard');
  end;

  SetTextById('required-size', RequiredSizeText);
  SetTextById('components-size', RequiredSizeText);
  SetTextById('install-summary-size', RequiredSizeText);
  SetTextById('review-size', RequiredSizeText);
  SetTextById('review-components', ComponentsSummary);
  SetStyleById('storage-fill', 'width:22%;');
  if IncludeHighResAssets then
    SetStyleById('storage-fill', 'width:38%;');
end;

procedure UpdatePathVisuals;
begin
  SetTextById('target-path', InstallPath);
  SetTextById('components-path', InstallPath);
  SetTextById('review-path', InstallPath);
  SetTextById('install-summary-path', InstallPath);
end;

procedure UpdateProgressVisuals;
var
  Percent: Integer;
  I: Integer;
begin
  Percent := 0;
  case ProgressStep of
    1: Percent := 18;
    2: Percent := 40;
    3: Percent := 62;
    4: Percent := 84;
    5: Percent := 100;
  end;

  SetTextById('progress-percent', IntToStr(Percent) + '%');
  SetStyleById('progress-fill', 'width:' + IntToStr(Percent) + '%;');

  case ProgressStep of
    0: SetTextById('progress-status', 'Waiting to begin...');
    1: SetTextById('progress-status', 'Preparing installation environment...');
    2: SetTextById('progress-status', 'Copying core application files...');
    3: SetTextById('progress-status', 'Applying selected components...');
    4: SetTextById('progress-status', 'Creating shortcuts and entries...');
    5: SetTextById('progress-status', 'Final checks completed successfully.');
  end;

  for I := 1 to INSTALL_PHASE_COUNT do
  begin
    if I <= ProgressStep then
    begin
      SetClassById('phase-' + IntToStr(I), 'phase-row is-done');
      SetTextById('phase-marker-' + IntToStr(I), '✓');
    end
    else
    begin
      SetClassById('phase-' + IntToStr(I), 'phase-row');
      SetTextById('phase-marker-' + IntToStr(I), IntToStr(I));
    end;
  end;
  if ProgressStep >= 1 then SetTextById('engine-status', 'Working')
  else SetTextById('engine-status', 'Ready');
  if ProgressStep >= 5 then SetTextById('engine-status', 'Complete');
end;

procedure RenderWizard;
begin
  UpdatePathVisuals;
  UpdateComponentVisuals;
  UpdateProgressVisuals;

  SetClassById('page-location', 'wizard-page');
  SetClassById('page-components', 'wizard-page');
  SetClassById('page-install', 'wizard-page');
  SetClassById('step-1', 'step');
  SetClassById('step-2', 'step');
  SetClassById('step-3', 'step');

  case WizardStage of
    STAGE_LOCATION:
      begin
        SetClassById('page-location', 'wizard-page is-visible');
        SetClassById('step-1', 'step is-active');
        SetTextById('eyebrow', 'STEP 01 / DESTINATION');
        SetTextById('page-heading', 'Where should Northstar be installed?');
        SetTextById('page-lede', 'Choose the folder where the application will live. You can change this later.');
        SetTextById('btn-primary', 'Next');
        SetClassById('btn-back', 'button is-hidden');
      end;
    STAGE_COMPONENTS:
      begin
        SetClassById('page-components', 'wizard-page is-visible');
        SetClassById('step-1', 'step is-done');
        SetClassById('step-2', 'step is-active');
        SetTextById('eyebrow', 'STEP 02 / FEATURES');
        SetTextById('page-heading', 'Choose your components.');
        SetTextById('page-lede', 'Keep the essentials or add optional shortcuts and high-resolution assets.');
        SetTextById('btn-primary', 'Review & install');
        SetClassById('btn-back', 'button');
      end;
    STAGE_INSTALL:
      begin
        SetClassById('page-install', 'wizard-page is-visible');
        SetClassById('step-1', 'step is-done');
        SetClassById('step-2', 'step is-done');
        SetClassById('step-3', 'step is-active');
        SetTextById('eyebrow', 'STEP 03 / INSTALLATION');
        if not InstallStarted then
        begin
          SetTextById('page-heading', 'Everything is ready to go.');
          SetTextById('page-lede', 'Review the destination and component summary before starting the demo.');
          SetClassById('install-ready', 'state-panel is-visible');
          SetClassById('install-progress', 'state-panel');
          SetClassById('install-complete', 'state-panel');
          SetTextById('btn-primary', 'Start installation');
          SetClassById('btn-back', 'button');
        end
        else if ProgressStep < INSTALL_PHASE_COUNT then
        begin
          SetTextById('page-heading', 'Installing Northstar.');
          SetTextById('page-lede', 'The progress below is simulated; advance each phase to inspect the complete flow.');
          SetClassById('install-ready', 'state-panel');
          SetClassById('install-progress', 'state-panel is-visible');
          SetClassById('install-complete', 'state-panel');
          SetTextById('btn-primary', 'Advance simulation');
          SetClassById('btn-back', 'button is-hidden');
        end
        else
        begin
          SetTextById('page-heading', 'Installation complete.');
          SetTextById('page-lede', 'The wizard has reached its successful finish state.');
          SetClassById('install-ready', 'state-panel');
          SetClassById('install-progress', 'state-panel');
          SetClassById('install-complete', 'state-panel is-visible');
          SetTextById('btn-primary', 'Finish');
          SetClassById('btn-back', 'button is-hidden');
        end;
      end;
  end;

  if (WizardStage = STAGE_INSTALL) and InstallStarted then
    SetClassById('btn-exit', 'button is-hidden')
  else
    SetClassById('btn-exit', 'button');

  if (WizardStage = STAGE_INSTALL) and InstallStarted and
     (ProgressStep >= INSTALL_PHASE_COUNT) then
    SetClassById('step-3', 'step is-done');

  Doc.Changed;
end;

procedure SetWizardStage(const NewStage: Integer);
begin
  Doc.BeginUpdate;
  try
    WizardStage := NewStage;
    RenderWizard;
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;
end;

procedure AdvanceProgress;
begin
  if ProgressStep < INSTALL_PHASE_COUNT then
    Inc(ProgressStep);

  Doc.BeginUpdate;
  try
    UpdateProgressVisuals;
    RenderWizard;
  finally
    Doc.EndUpdate;
  end;
  Doc.Changed;

  case ProgressStep of
    1: SetStatus('Phase 1/5: simulated preparation complete.');
    2: SetStatus('Phase 2/5: simulated core file copy complete.');
    3: SetStatus('Phase 3/5: simulated component selection applied.');
    4: SetStatus('Phase 4/5: simulated shortcuts created.');
    5: SetStatus('Phase 5/5: complete. No files were written.');
  end;
end;

procedure CloseSetup;
begin
  WizardForm.CancelButton.OnClick(WizardForm.CancelButton);
end;

// ---------------------------------------------------------------------------
// All HTML interactions are handled in Inno Pascal Script.
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

  if (Id = 'title-close') or (Id = 'btn-exit') then
  begin
    CloseSetup;
    Result := True;
    Exit;
  end;

  if Id = 'btn-browse' then
  begin
    BrowseStep := BrowseStep + 1;
    if BrowseStep > 3 then BrowseStep := 1;
    case BrowseStep of
      1: InstallPath := 'C:\Program Files\Northstar\Desktop Client';
      2: InstallPath := 'D:\Apps\Northstar Client';
      3: InstallPath := 'C:\Users\Public\Northstar';
    end;
    UpdatePathVisuals;
    SetStatus('Sample destination changed. No folder has been created.');
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if (Id = 'comp-desktop') or (Id = 'mark-desktop') then
  begin
    IncludeDesktopShortcut := not IncludeDesktopShortcut;
    Doc.BeginUpdate;
    try
      UpdateComponentVisuals;
      SetStatus('Desktop shortcut option updated.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if (Id = 'comp-startmenu') or (Id = 'mark-startmenu') then
  begin
    IncludeStartMenuShortcut := not IncludeStartMenuShortcut;
    Doc.BeginUpdate;
    try
      UpdateComponentVisuals;
      SetStatus('Start menu option updated.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if (Id = 'comp-hd') or (Id = 'mark-hd') then
  begin
    IncludeHighResAssets := not IncludeHighResAssets;
    Doc.BeginUpdate;
    try
      UpdateComponentVisuals;
      SetStatus('High-resolution assets option updated.');
    finally
      Doc.EndUpdate;
    end;
    Doc.Changed;
    Result := True;
    Exit;
  end;

  if Id = 'btn-back' then
  begin
    if WizardStage = STAGE_COMPONENTS then
      SetWizardStage(STAGE_LOCATION)
    else if (WizardStage = STAGE_INSTALL) and (not InstallStarted) then
      SetWizardStage(STAGE_COMPONENTS);
    SetStatus('Returned to the previous setup step.');
    Result := True;
    Exit;
  end;

  if Id = 'btn-primary' then
  begin
    if WizardStage = STAGE_LOCATION then
    begin
      SetWizardStage(STAGE_COMPONENTS);
      SetStatus('Choose optional components, then review the summary.');
    end
    else if WizardStage = STAGE_COMPONENTS then
    begin
      InstallStarted := False;
      ProgressStep := 0;
      SetWizardStage(STAGE_INSTALL);
      SetStatus('Review complete. The simulated installation is ready.');
    end
    else if WizardStage = STAGE_INSTALL then
    begin
      if not InstallStarted then
      begin
        InstallStarted := True;
        ProgressStep := 0;
        Doc.BeginUpdate;
        try
          UpdateProgressVisuals;
          RenderWizard;
          SetStatus('Simulation started. Click Advance simulation to proceed phase by phase.');
        finally
          Doc.EndUpdate;
        end;
        Doc.Changed;
      end
      else if ProgressStep < INSTALL_PHASE_COUNT then
        AdvanceProgress
      else
      begin
        SetStatus('Demo finished. Closing setup.');
        CloseSetup;
      end;
    end;
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
  InstallPath := 'C:\Program Files\Northstar\Desktop Client';
  BrowseStep := 1;
  WizardStage := STAGE_LOCATION;
  InstallStarted := False;
  ProgressStep := 0;
  IncludeDesktopShortcut := True;
  IncludeStartMenuShortcut := True;
  IncludeHighResAssets := False;

  EmptyWizardForm(DEMO_FORM_WIDTH, DEMO_FORM_HEIGHT);
  FMXForm.FCreateBackdropForm(WizardForm.Handle, btMain, False, True);

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
  View.LoadFromStringUrl(BuildWizardHtml, TempDir + '\');

  Doc.FCreate(View.GetDocument);
  RenderWizard;
  SetStatus('Ready. Choose a destination folder to begin the three-stage setup demo.');
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
