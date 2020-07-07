program BaseRealPrj;

uses
  Forms,
  MainfrmUnit in 'MainfrmUnit.pas' {MainFrm},
  CommonUnit in '..\Common\CommonUnit.pas',
  ThreadCommonUnit in '..\Common\ThreadCommonUnit.pas',
  frmResEditUnit in '..\..\filetobase64\frmResEditUnit.pas' {frmResEdit};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);

  Application.Run;
end.
