program Demo;

uses
  Forms,
  Mainfrm in 'Mainfrm.pas' {MainForm},
  SortFrm in 'SortFrm.pas' {SortForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSortForm, SortForm);
  Application.Run;
end.
