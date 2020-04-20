object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Demo uso certificado no banco de dados'
  ClientHeight = 187
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 30
    Top = 25
    Width = 186
    Height = 41
    Caption = 'Carregar Certificado no Banco'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 30
    Top = 72
    Width = 186
    Height = 41
    Caption = 'Ler configura'#231#245'es'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 30
    Top = 119
    Width = 186
    Height = 41
    Caption = 'Verificar Status'
    TabOrder = 3
    OnClick = Button3Click
  end
  object ListBox1: TListBox
    Left = 230
    Top = 25
    Width = 376
    Height = 135
    ItemHeight = 13
    TabOrder = 2
  end
  object ACBrNFe1: TACBrNFe
    Configuracoes.Geral.SSLLib = libNone
    Configuracoes.Geral.SSLCryptLib = cryNone
    Configuracoes.Geral.SSLHttpLib = httpNone
    Configuracoes.Geral.SSLXmlSignLib = xsNone
    Configuracoes.Geral.FormatoAlerta = 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.'
    Configuracoes.Geral.VersaoQRCode = veqr000
    Configuracoes.Arquivos.OrdenacaoPath = <>
    Configuracoes.WebServices.UF = 'SP'
    Configuracoes.WebServices.AguardarConsultaRet = 0
    Configuracoes.WebServices.QuebradeLinha = '|'
    Configuracoes.RespTec.IdCSRT = 0
    Left = 350
    Top = 40
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.pfx'
    Filter = 'Arquivos de certificado|*.pfx'
    Title = 'Carregar Certificado'
    Left = 270
    Top = 40
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
    Left = 275
    Top = 105
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
    Left = 350
    Top = 105
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
