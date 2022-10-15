unit ufrmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  DosCommand;

type
  TfrmMain = class(TForm)
    tlbMain: TToolBar;
    statMain: TStatusBar;
    lblYTURLHeader: TLabel;
    edtURL: TEdit;
    btnDownload: TEditButton;
    pbProgress: TProgressBar;
    lblProgress: TLabel;
    lblLogHeader: TLabel;
    mmoLog: TMemo;
    dscmndYTDL: TDosCommand;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  FILE_YTDDL = '.\yt-dlp.exe';
  TEMPLATE_PROGRESS = '[yt-dlp] | %(progress.downloaded_bytes)s | %(progress.total_bytes)s | %(progress.speed)s | %(progress.eta)s | %(progress._eta_str)s';

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

end.
