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
    N1: TMenuItem;
    procedure MenuDiskSNClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
    procedure RevMsgStr(var msg: TMessage); message WM_POSTSTRING;
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation


{$R *.dfm}

var
  threadCom: ThreadCommon;

procedure TMainFrm.MenuDiskSNClick(Sender: TObject);
begin
  ShowMessage(GetIdeNum());
end;

procedure TMainFrm.N1Click(Sender: TObject);
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

initialization
  threadCom := ThreadCommon.Create(False);
  threadCom.FreeOnTerminate := True;
  threadCom.Resume

finalization
  threadCom.Terminate;
  //threadCom.Free;

end.

