unit Creditos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Ani;

type
  TFormCreditos = class(TForm)
    Image1: TImage;
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCreditos: TFormCreditos;

implementation

{$R *.fmx}

uses TraduzTextos;

procedure TFormCreditos.Image1Click(Sender: TObject);
begin
  FormCreditos.visible := False;
end;

end.
