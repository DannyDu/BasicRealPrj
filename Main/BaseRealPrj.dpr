program BaseRealPrj;

uses
  Forms,
  MainfrmUnit in 'MainfrmUnit.pas' {MainFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
