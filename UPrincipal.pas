unit UPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.StdCtrls, ACBrBase, ACBrDFe,
  ACBrNFe, FireDAC.VCLUI.Error, FireDAC.VCLUI.Login, FireDAC.VCLUI.Async,
  FireDAC.VCLUI.Script, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, FireDAC.Comp.UI;

type
  TForm1 = class(TForm)
    ACBrNFe1: TACBrNFe;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    FDConn: TFDConnection;
    QryCertificado: TFDQuery;
    QryCertificadoDT_CADASTRO: TSQLTimeStampField;
    QryCertificadoCERTIFICADO: TBlobField;
    QryCertificadoSENHA: TStringField;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure FDConnBeforeConnect(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  blcksock, ACBrDFeSSL;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    QryCertificado.Open;
    try
      QryCertificado.Append;
      QryCertificadoDT_CADASTRO.AsDateTime := NOW;
      QryCertificadoSENHA.AsString := InputBox('Senha', 'Informe a senha do certificado:', '');
      QryCertificadoCERTIFICADO.LoadFromFile(OpenDialog1.FileName);
      QryCertificado.Post;
    finally
      QryCertificado.Close;
    end;

    ShowMessage('Certificado carregado com sucesso!');
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  QryCertificado.Open;
  try
    ACBrNFe1.Configuracoes.Geral.SSLLib          := TSSLLib.libWinCrypt;
    ACBrNFe1.SSL.SSLType                         := TSSLType.LT_TLSv1_2;

    ACBrNFe1.Configuracoes.Certificados.DadosPFX := QryCertificadoCERTIFICADO.AsAnsiString;
    ACBrNFe1.Configuracoes.Certificados.Senha    := QryCertificadoSENHA.AsString;

    ListBox1.Clear;
    ListBox1.Items.Add('Número de Série: '    + ACBrNFe1.SSL.CertNumeroSerie);
    ListBox1.Items.Add('Razão Social: '       + ACBrNFe1.SSL.CertRazaoSocial);
    ListBox1.Items.Add('CNPJ: '               + ACBrNFe1.SSL.CertCNPJ);
    ListBox1.Items.Add('Data de Vencimento: ' + DateTimeToStr(ACBrNFe1.SSL.CertDataVenc));

    case ACBrNFe1.SSL.CertTipo of
      tpcDesconhecido : ListBox1.Items.Add('Tipo: Desconhecido');
      tpcA1           : ListBox1.Items.Add('Tipo: A1');
      tpcA3           : ListBox1.Items.Add('Tipo: A3');
    end;
  finally
    QryCertificado.Close;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Mensagem: string;
  CodigoStatus: Integer;
begin
  ACBrNFe1.WebServices.StatusServico.Executar;
  CodigoStatus := ACBrNFe1.WebServices.StatusServico.cStat;
  case CodigoStatus of
    107: // serviço em operação
      begin
        Mensagem := Trim(
          Format('Código:%d'#13'Mensagem: %s'#13'Tempo médio: %d segundo(s)', [
            ACBrNFe1.WebServices.StatusServico.cStat,
            ACBrNFe1.WebServices.StatusServico.xMotivo,
            ACBrNFe1.WebServices.StatusServico.TMed
          ])
        );

        MessageDlg(Mensagem, mtInformation, [mbOK], 0);
      end;

    108, 109: // serviço paralisado temporariamente (108) ou sem previsão (109)
      begin
        Mensagem := Trim(
          Format('Código:%d'#13'Motivo: %s'#13'%s', [
            ACBrNFe1.WebServices.StatusServico.cStat,
            ACBrNFe1.WebServices.StatusServico.xMotivo,
            ACBrNFe1.WebServices.StatusServico.xObs
          ])
        );

        MessageDlg(Mensagem, mtError, [mbOK], 0);
      end;
  else
    // qualquer outro retorno
    if CodigoStatus > 0 then
    begin
      Mensagem := Trim(
        Format('Webservice indisponível:'#13'Código:%d'#13'Motivo: %s'#13'%s', [
          ACBrNFe1.WebServices.StatusServico.cStat,
          ACBrNFe1.WebServices.StatusServico.xMotivo,
          ACBrNFe1.WebServices.StatusServico.xObs
        ])
      );
    end
    else
    begin
      Mensagem := 'Webservice indisponível e retorno em branco, tente novamente!';
    end;

    MessageDlg(Mensagem, mtInformation, [mbOK], 0);
  end;
end;

procedure TForm1.FDConnBeforeConnect(Sender: TObject);
begin
  FDConn.Params.Values['database'] := ExtractFilePath(ParamStr(0)) + 'dados.fdb';
end;

end.
