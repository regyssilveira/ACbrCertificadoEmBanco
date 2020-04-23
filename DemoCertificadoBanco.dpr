program DemoCertificadoBanco;

uses
  Vcl.Forms,
  UPrincipal in 'UPrincipal.pas' {TFrmPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTFrmPrincipal, TFrmPrincipal);
  Application.Run;
end.
