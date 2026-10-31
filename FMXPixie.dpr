{*******************************************************}
{                                                       }
{                        FMXPixie                       }
{                                                       }
{              Copyright(c) 2026 Audiofeel              }
{                  All rights reserved                  }
{                                                       }
{*******************************************************}

library FMXPixie;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$IFDEF WIN32}
  {$LIBSUFFIX '_x86'}
{$ELSE}
  {$LIBSUFFIX '_x64'}
{$ENDIF}

uses
  FMXPixie.Forms in 'Forms\FMXPixie.Forms.pas',
  FMXPixie.BrushHelpers in 'Helpers\FMXPixie.BrushHelpers.pas',
  FMXPixie.Utils in 'Custom\FMXPixie.Utils.pas',
  FMXPixie.HtmlView in 'Pixie\FMXPixie.HtmlView.pas',
  FMXPixie.SvgView in 'Pixie\FMXPixie.SvgView.pas',
  FMXPixie.MarkdownView in 'Pixie\FMXPixie.MarkdownView.pas',
  FMXPixie.TagBar in 'Pixie\FMXPixie.TagBar.pas',
  FMXPixie.PaintBox in 'Pixie\FMXPixie.PaintBox.pas',
  FMXPixie.AudioPlayer in 'Custom\AudioPlayer\FMXPixie.AudioPlayer.pas',
  FMXBridge.SystemInfo in 'Custom\FMXBridge.SystemInfo.pas';

{$R *.res}
begin
//
end.
