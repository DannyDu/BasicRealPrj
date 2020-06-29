unit MainfrmUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TMainFrm = class(TForm)
    mm1: TMainMenu;
    MenuFile: TMenuItem;
    MenuQuit: TMenuItem;
    MenuItem: TMenuItem;
    MenuDiskSN: TMenuItem;
    procedure MenuDiskSNClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  CommonUnit;

{$R *.dfm}


procedure TMainFrm.MenuDiskSNClick(Sender: TObject);
begin
  ShowMessage(GetIdeNum());
end;

initialization

finalization

end.
