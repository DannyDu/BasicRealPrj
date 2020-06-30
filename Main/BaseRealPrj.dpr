program BaseRealPrj;

uses
  Forms,
  MainfrmUnit in 'MainfrmUnit.pas' {MainFrm},
  CommonUnit in '..\Common\CommonUnit.pas',
  ThreadCommonUnit in '..\Common\ThreadCommonUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
