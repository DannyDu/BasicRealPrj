program BaseRealPrj;

uses
  Forms,
  MainfrmUnit in 'MainfrmUnit.pas' {MainFrm},
  CommonUnit in '..\Common\CommonUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
