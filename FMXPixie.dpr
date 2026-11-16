
library FMXPixie;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$IFDEF WIN32}
  {$LIBSUFFIX '_x86'}
{$ELSE}
  {$LIBSUFFIX '_x64'}
{$ENDIF}

{$R FMXPixie.res}

uses
  FMXPixie.Forms in 'Forms\FMXPixie.Forms.pas',
  FMXPixie.BrushHelpers in 'Helpers\FMXPixie.BrushHelpers.pas',
  FMXPixie.Utils in 'Custom\FMXPixie.Utils.pas',
  FMXPixie.HtmlView in 'Pixie\FMXPixie.HtmlView.pas',
  FMXPixie.SvgView in 'Pixie\FMXPixie.SvgView.pas',
  FMXPixie.MarkdownView in 'Pixie\FMXPixie.MarkdownView.pas',
  FMXPixie.TagBar in 'Pixie\FMXPixie.TagBar.pas',
  FMXPixie.PaintBox in 'Pixie\FMXPixie.PaintBox.pas',
  FMXPixie.SystemInfo in 'Custom\FMXPixie.SystemInfo.pas',
  FMXPixie.System in 'FMX\FMXPixie.System.pas',
  FMXPixie.AudioPlayer in 'ThirdParty\FMXPixie.AudioPlayer.pas',
  FMXPixie.Input in 'ThirdParty\FMXPixie.Input.pas',
  FMXPixie.VideoBackground in 'ThirdParty\FMXPixie.VideoBackground.pas',
  FMXPixie.Layouts in 'FMX\FMXPixie.Layouts.pas';

begin
//
end.
