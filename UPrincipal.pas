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
  FireDAC.Phys.FB, FireDAC.Comp.UI, Vcl.ComCtrls;

type
  TTFrmPrincipal = class(TForm)
    ACBrNFe1: TACBrNFe;
    BtnWebserviceStatus: TButton;
    OpenDialog1: TOpenDialog;
    FDConn: TFDConnection;
    QryCertificado: TFDQuery;
    QryCertificadoDT_CADASTRO: TSQLTimeStampField;
    QryCertificadoCERTIFICADO: TBlobField;
    QryCertificadoSENHA: TStringField;
    LstDadosCertificado: TListBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    BtnCertificadoLerBD: TButton;
    BtnCertificadoGravarBD: TButton;
    BtnCertificadoLerURL: TButton;
    BtnLimpar: TButton;
    procedure BtnCertificadoGravarBDClick(Sender: TObject);
    procedure FDConnBeforeConnect(Sender: TObject);
    procedure BtnCertificadoLerBDClick(Sender: TObject);
    procedure BtnWebserviceStatusClick(Sender: TObject);
    procedure BtnCertificadoLerURLClick(Sender: TObject);
    procedure BtnLimparClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure PopularDadosCertificado;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TFrmPrincipal: TTFrmPrincipal;

implementation

uses
  blcksock, ACBrDFeSSL;

{$R *.dfm}

procedure TTFrmPrincipal.PopularDadosCertificado;
begin
  LstDadosCertificado.Clear;
  LstDadosCertificado.Items.Add('Número de Série: '    + ACBrNFe1.SSL.CertNumeroSerie);
  LstDadosCertificado.Items.Add('Razão Social: '       + ACBrNFe1.SSL.CertRazaoSocial);
  LstDadosCertificado.Items.Add('CNPJ: '               + ACBrNFe1.SSL.CertCNPJ);
  LstDadosCertificado.Items.Add('Data de Vencimento: ' + DateTimeToStr(ACBrNFe1.SSL.CertDataVenc));

  case ACBrNFe1.SSL.CertTipo of
    tpcDesconhecido : LstDadosCertificado.Items.Add('Tipo: Desconhecido');
    tpcA1           : LstDadosCertificado.Items.Add('Tipo: A1');
    tpcA3           : LstDadosCertificado.Items.Add('Tipo: A3');
  end;
end;

procedure TTFrmPrincipal.BtnCertificadoGravarBDClick(Sender: TObject);
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

procedure TTFrmPrincipal.BtnCertificadoLerBDClick(Sender: TObject);
begin
  QryCertificado.Open;
  try
    ACBrNFe1.Configuracoes.Geral.SSLLib          := TSSLLib.libWinCrypt;
    ACBrNFe1.SSL.SSLType                         := TSSLType.LT_TLSv1_2;

    ACBrNFe1.Configuracoes.Certificados.DadosPFX := QryCertificadoCERTIFICADO.AsAnsiString;
    ACBrNFe1.Configuracoes.Certificados.Senha    := QryCertificadoSENHA.AsString;

    PopularDadosCertificado;
  finally
    QryCertificado.Close;
  end;
end;

procedure TTFrmPrincipal.BtnCertificadoLerURLClick(Sender: TObject);
begin
  ACBrNFe1.Configuracoes.Geral.SSLLib          := TSSLLib.libWinCrypt;
  ACBrNFe1.SSL.SSLType                         := TSSLType.LT_TLSv1_2;

  // informar caminho do arquivo para que o ACBr faça cache local
  // o ACBr sempre vai tentar baixar novamente quando:
  //   - faltarem 10 dias ou menos para vencimento do certificado
  //   - não for encontrado arquivo no caminho especificado em ArquivoPFX
  ACBrNFe1.Configuracoes.Certificados.ArquivoPFX := ExtractFilePath(ParamStr(0)) + 'certificado.pfx';

  ACBrNFe1.Configuracoes.Certificados.URLPFX     := InputBox('Certificado', 'Informe a URL do certificado:', '');
  ACBrNFe1.Configuracoes.Certificados.Senha      := InputBox('Senha', 'Informe a senha do certificado:', '');

  PopularDadosCertificado;
end;

procedure TTFrmPrincipal.BtnLimparClick(Sender: TObject);
begin
  LstDadosCertificado.Clear;
end;

procedure TTFrmPrincipal.BtnWebserviceStatusClick(Sender: TObject);
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

procedure TTFrmPrincipal.FDConnBeforeConnect(Sender: TObject);
begin
  FDConn.Params.Values['database'] := ExtractFilePath(ParamStr(0)) + 'dados.fdb';
end;

procedure TTFrmPrincipal.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
end;

end.

