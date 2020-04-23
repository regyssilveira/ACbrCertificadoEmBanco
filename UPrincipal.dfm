object TFrmPrincipal: TTFrmPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Demo uso de Certificado'
  ClientHeight = 299
  ClientWidth = 438
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object BtnWebserviceStatus: TButton
    Left = 235
    Top = 242
    Width = 186
    Height = 41
    Caption = 'Verificar Status'
    TabOrder = 3
    OnClick = BtnWebserviceStatusClick
  end
  object LstDadosCertificado: TListBox
    Left = 15
    Top = 102
    Width = 406
    Height = 134
    ItemHeight = 13
    TabOrder = 1
  end
  object PageControl1: TPageControl
    Left = 15
    Top = 18
    Width = 406
    Height = 78
    ActivePage = TabSheet2
    TabOrder = 0
    TabStop = False
    TabWidth = 180
    object TabSheet1: TTabSheet
      Caption = 'Utilizar via Banco de dados'
      object BtnCertificadoLerBD: TButton
        Left = 195
        Top = 3
        Width = 186
        Height = 41
        Caption = 'Ler certificado do banco de dados'
        TabOrder = 1
        OnClick = BtnCertificadoLerBDClick
      end
      object BtnCertificadoGravarBD: TButton
        Left = 3
        Top = 3
        Width = 186
        Height = 41
        Caption = 'Gravar aquivo no banco de dados'
        TabOrder = 0
        OnClick = BtnCertificadoGravarBDClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Utilizar Via URL'
      ImageIndex = 1
      object BtnCertificadoLerURL: TButton
        Left = 3
        Top = 3
        Width = 186
        Height = 41
        Caption = 'Carregar Certificado de URL'
        TabOrder = 0
        OnClick = BtnCertificadoLerURLClick
      end
    end
  end
  object BtnLimpar: TButton
    Left = 15
    Top = 242
    Width = 186
    Height = 41
    Caption = 'Limpar'
    TabOrder = 2
    OnClick = BtnLimparClick
  end
  object ACBrNFe1: TACBrNFe
    Configuracoes.Geral.SSLLib = libNone
    Configuracoes.Geral.SSLCryptLib = cryNone
    Configuracoes.Geral.SSLHttpLib = httpNone
    Configuracoes.Geral.SSLXmlSignLib = xsNone
    Configuracoes.Geral.FormatoAlerta = 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.'
    Configuracoes.Geral.VersaoQRCode = veqr000
    Configuracoes.Arquivos.OrdenacaoPath = <>
    Configuracoes.WebServices.Visualizar = True
    Configuracoes.WebServices.UF = 'SP'
    Configuracoes.WebServices.AguardarConsultaRet = 0
    Configuracoes.WebServices.QuebradeLinha = '|'
    Configuracoes.RespTec.IdCSRT = 0
    Left = 140
    Top = 130
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.pfx'
    Filter = 'Arquivos de certificado|*.pfx'
    Title = 'Carregar Certificado'
    Left = 60
    Top = 130
  end
  object FDConn: TFDConnection
    Params.Strings = (
      
        'Database=D:\WKACBrMobile\Exemplo Certificado no Banco\bin\DADOS.' +
        'FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    BeforeConnect = FDConnBeforeConnect
    Left = 60
    Top = 180
  end
  object QryCertificado: TFDQuery
    Connection = FDConn
    SQL.Strings = (
      'select FIRST 1 '
      '  DT_CADASTRO, '
      '  CERTIFICADO,'
      '  SENHA'
      'from '
      '  tb_certificado'
      'ORDER BY '
      '  DT_CADASTRO DESC')
    Left = 140
    Top = 180
    object QryCertificadoDT_CADASTRO: TSQLTimeStampField
      FieldName = 'DT_CADASTRO'
      Origin = 'DT_CADASTRO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object QryCertificadoCERTIFICADO: TBlobField
      FieldName = 'CERTIFICADO'
      Origin = 'CERTIFICADO'
    end
    object QryCertificadoSENHA: TStringField
      FieldName = 'SENHA'
      Origin = 'SENHA'
      Size = 100
    end
  end
end
