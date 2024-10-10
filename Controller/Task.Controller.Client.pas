unit Task.Controller.Client;

interface

uses  System.Classes, System.SysUtils, IniFiles;

type
  TConfiguracoes = record
    Servidor_URL: string;
  end;

  TSecao = record
    Usuario: string;
    Senha: string;
    Autorization: string;
  end;

  TClient = class
  private
    FNomeArquivo: string;
    FConfiguracoes: TConfiguracoes;
    FSecao: TSecao;
  public
    procedure Load;

    procedure Save_Config(const pURL: string);
    procedure Save_Login(const pUsuario, pSenha: string);
    procedure Save_Auth(const pValue: string);

    property Configuracoes: TConfiguracoes read FConfiguracoes;
    property Secao: TSecao read FSecao;
  end;

  TControllerClient = class
  private
    class var FInstance: TClient;
  public
    class function GetInstance: TClient;
  end;

implementation

{ TClient }

procedure TClient.Load;
var
  LArqINI: TIniFile;
begin
  FNomeArquivo := ParamStr(0);
  FNomeArquivo := ChangeFileExt(FNomeArquivo, '.ini');

  LArqINI := TIniFile.Create(FNomeArquivo);
  try
    FConfiguracoes.Servidor_URL := LArqINI.ReadString('Servidor', 'URL', 'http://localhost:9000');
    FSecao.Usuario := LArqINI.ReadString('Login', 'Usuario', '');
    FSecao.Senha := LArqINI.ReadString('Login', 'Senha', '');
  finally
    LArqINI.Free;
  end;
end;

procedure TClient.Save_Auth(const pValue: string);
begin
  FSecao.Autorization := pValue;
end;

procedure TClient.Save_Config(const pURL: string);
var
  LArqINI: TIniFile;
begin
  LArqINI := TIniFile.Create(FNomeArquivo);
  try
    LArqINI.WriteString('Servidor', 'URL', pURL);
  finally
    LArqINI.Free;
  end;
  FConfiguracoes.Servidor_URL := pURL;
end;

procedure TClient.Save_Login(const pUsuario, pSenha: string);
var
  LArqINI: TIniFile;
begin
  LArqINI := TIniFile.Create(FNomeArquivo);
  try
    LArqINI.WriteString('Login', 'Usuario', pUsuario);
    LArqINI.WriteString('Login', 'Senha', pSenha);
  finally
    LArqINI.Free;
  end;
  FSecao.Usuario := pUsuario;
  FSecao.Senha := pSenha;
end;

{ TControllerClient }

class function TControllerClient.GetInstance: TClient;
begin
  if not Assigned(FInstance) then
    FInstance := TClient.Create;
  Result := FInstance;
end;

initialization

finalization
  if Assigned(TControllerClient.FInstance) then
    TControllerClient.FInstance.Free;

end.
