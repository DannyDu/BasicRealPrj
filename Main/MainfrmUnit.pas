unit MainfrmUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, CommonUnit, ThreadCommonUnit;

type
  TMainFrm = class(TForm)
    mm1: TMainMenu;
    MenuFile: TMenuItem;
    MenuQuit: TMenuItem;
    MenuItem: TMenuItem;
    MenuDiskSN: TMenuItem;
    NThread: TMenuItem;
    NResEXE: TMenuItem;
    NResString: TMenuItem;
    NResEdit: TMenuItem;
    procedure MenuDiskSNClick(Sender: TObject);
    procedure NThreadClick(Sender: TObject);
    procedure NResEXEClick(Sender: TObject);
    procedure NResStringClick(Sender: TObject);
    procedure NResEditClick(Sender: TObject);
  private
    { Private declarations }
    procedure RevMsgStr(var msg: TMessage); message WM_POSTSTRING;
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  frmResEditUnit;


{$R *.dfm}

var
  threadCom: ThreadCommon;
  Hnd:Cardinal;

procedure TMainFrm.MenuDiskSNClick(Sender: TObject);
begin
  ShowMessage(GetIdeNum());
end;

procedure TMainFrm.NThreadClick(Sender: TObject);
var
  i: Cardinal;
  PD: PItemData;
begin
  for i := 0 to 21000 do
  begin
    New(PD);
    PD^.ItemID := i;
    FillChar(PD^.ItemCode, 256, #0);
    FillChar(PD^.ItemName, 256, #0);
    StrCopy(PD^.ItemCode, PChar(formatdatetime('yyyy-dd-MM HH:mm:ss:zzz', Now)));
    StrCopy(PD^.ItemName, PChar(inttostr(i * 100)));
    PostThreadMessage(threadCom.ThreadID, WM_POSTITEMDATE, Integer(PD), i);
  end;
end;

procedure TMainFrm.RevMsgStr(var msg: TMessage);
var ps:PString;
begin
  ps:=pstring(msg.WParam);
  if (msg.LParam mod 1000) =0 then
  Caption := ps^;
  Dispose(ps);  
end;

procedure TMainFrm.NResEXEClick(Sender: TObject);
var Stream: TResourceStream;
begin

  if hnd > 0 then
  begin
    Stream:= TResourceStream.Create(Hnd, 'myexe', RT_RCDATA); // 使用装载得到的句柄
    Stream.SaveToFile('D:\Code\BasicRealPrj\Bin\myexe.exe');
    stream.Free;
  end;
end;

procedure TMainFrm.NResStringClick(Sender: TObject);
 var
    Buf: PChar;
begin
  if hnd > 0 then
  begin
    GetMem(Buf, 255);
    LoadString(Hnd, 2, Buf, 255); // 使用LoadString装载指定句柄的字符串
    ShowMessage(Buf);
    FreeMem(Buf, 255);
  end;
end;

procedure TMainFrm.NResEditClick(Sender: TObject);
begin
frmResEdit:=TfrmResEdit.Create(Self);
frmResEdit.ShowModal;
end;

initialization
  threadCom := ThreadCommon.Create(False);
  threadCom.FreeOnTerminate := True;
  threadCom.Resume;
  Hnd := LoadLibrary('resourceDLL.dll'); // 装载资源文件

finalization
  threadCom.Terminate;
  //threadCom.Free;
  FreeLibrary(hnd);
end.

