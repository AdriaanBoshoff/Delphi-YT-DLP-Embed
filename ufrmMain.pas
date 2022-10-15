unit ufrmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  DosCommand, System.IOUtils;

type
  TYTProgress = record
    downloadedBytes: Int64;
    totalBytes: Int64;
    speed: Double;
    eta: Int64;
    etaFormatted: string;
  end;

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
    procedure btnDownloadClick(Sender: TObject);
    procedure dscmndYTDLNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
    procedure dscmndYTDLTerminated(Sender: TObject);
  private
    { Private declarations }
    function ParseProgress(const Data: string): TYTProgress;
  public
    { Public declarations }
  end;

  // Change below to your liking
const
  FILE_YTDLP        = '.\yt-dlp.exe';
  TEMPLATE_PROGRESS = '[yt-dlp] | %(progress.downloaded_bytes)s | %(progress.total_bytes)s | %(progress.speed)s | %(progress.eta)s | %(progress._eta_str)s';

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.btnDownloadClick(Sender: TObject);
begin
  // Check if edit box is empty
  if edtURL.Text.Trim.IsEmpty then
  begin
    ShowMessage('URL cannot be empty so I filled it in for you ;)');
    edtURL.Text := 'https://youtu.be/dQw4w9WgXcQ';
  end;

  // Check if yt-dlp.exe is present
  if not TFile.Exists(FILE_YTDLP) then
  begin
    ShowMessage('yt-dlp.exe not present!');
    Exit;
  end;

  // Set Command Line
  dscmndYTDL.CommandLine := '.\yt-dlp.exe --progress-template "' + TEMPLATE_PROGRESS + '" "' + edtURL.Text.Trim + '" -o %(title)s.%(ext)s';

  // Execite DosCommand
  dscmndYTDL.Execute;
end;

procedure TfrmMain.dscmndYTDLNewLine(ASender: TObject; const ANewLine: string; AOutputType: TOutputType);
begin
  // Check if entire line is supplied
  if AOutputType <> TOutputType.otEntireLine then
    Exit;

  // Check if progress
  if ANewLine.Trim.ToLower.StartsWith('[yt-dlp]') then
  begin
    var progress     := ParseProgress(ANewLine);
    pbProgress.Max   := progress.totalBytes;
    pbProgress.Value := progress.downloadedBytes;

    lblProgress.Text := Format('%d bytes of %d bytes downloaded and %d seconds remaining...', [progress.downloadedBytes, progress.totalBytes, progress.eta]);
  end
  else // If not progress then add to log
  begin
    mmoLog.Lines.Add(ANewLine.Trim);
  end;
end;

procedure TfrmMain.dscmndYTDLTerminated(Sender: TObject);
begin
  // yt-dlp is done.
  mmoLog.Lines.Add('YT-DLP Terminated.');
end;

function TfrmMain.ParseProgress(const Data: string): TYTProgress;
var
  fs: TFormatSettings;
begin
  // Avoid regional conflicts
  fs.DecimalSeparator := '.';

  var sl := TStringList.Create;
  try
    // Split the data
    sl.StrictDelimiter := True;
    sl.Delimiter       := '|';
    sl.DelimitedText   := Data;

    // Dummy vars
    var downloadedBytes: Int64;
    var totalBytes     : Int64;
    var speed          : Double;
    var eta            : Int64;

    // Checks for strings before converting

    // Downloaded Bytes
    if not TryStrToInt64(sl[1].Trim, downloadedBytes) then
      sl[1] := '0';

    // Total Bytes
    if not TryStrToInt64(sl[2].Trim, totalBytes) then
      sl[2] := '0';

    // Speed
    if not TryStrToFloat(sl[3].Trim, speed, fs) then
      sl[3] := '0';

    // ETA seconds
    if not TryStrToInt64(sl[4].Trim, eta) then
      sl[4] := '0';

    // Result
    Result.downloadedBytes := sl[1].Trim.ToInt64;
    Result.totalBytes      := sl[2].Trim.ToInt64;
    Result.speed           := StrToFloat(sl[3].Trim, fs);
    Result.eta             := sl[4].Trim.ToInt64;
    Result.etaFormatted    := sl[5].Trim;
  finally
    sl.Free;
  end;
end;

end.

