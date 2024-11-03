program AzureTranslator;



{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  Creditos in 'Creditos.pas' {FormCreditos},
  TraduzTextos in 'TraduzTextos.pas' {FormPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.CreateForm(TFormCreditos, FormCreditos);
  Application.Run;

end.
