unit Task.Controller.Server;

interface

uses  System.Classes, System.SysUtils, IniFiles,
  Task.Model.Connection.BDD;

type
  TConfiguracoes = record
    Horse_Porta: Integer;
    BDD_DriverName: string;
    BDD_DataBase: string;
    BDD_Usuario: string;
    BDD_Senha: string;
  end;

  TSecao = record
    CodUsuario: Integer;
    Usuario: string;
  end;

  TServer = class
  private
    FConfiguracoes: TConfiguracoes;
  public
    procedure Load_Config;

    function NewConnnection: iConnection;

    property Configuracoes: TConfiguracoes read FConfiguracoes;
  end;

  TControllerServer = class
  private
    class var FInstance: TServer;
  public
    class function GetInstance: TServer;
    class threadvar Secao: TSecao;
  end;

implementation

{ TServer }

procedure TServer.Load_Config;
var
  LFileName: string;
  LArqINI: TIniFile;
begin
  LFileName := ParamStr(0);
  LFileName := ChangeFileExt(LFileName, '.ini');

  LArqINI := TIniFile.Create(LFileName);
  try
    FConfiguracoes.Horse_Porta := LArqINI.ReadInteger('Horse', 'Porta', 9000);
    FConfiguracoes.BDD_DriverName := LArqINI.ReadString('BDD', 'DriverName', '');
    FConfiguracoes.BDD_DataBase := LArqINI.ReadString('BDD', 'DataBase', '');
    FConfiguracoes.BDD_Usuario := LArqINI.ReadString('BDD', 'Usuario', '');
    FConfiguracoes.BDD_Senha := LArqINI.ReadString('BDD', 'Senha', '');
  finally
    LArqINI.Free;
  end;
end;

function TServer.NewConnnection: iConnection;
begin
  Result := TModelConnection.New
    .DriverName(FConfiguracoes.BDD_DriverName)
    .Database(FConfiguracoes.BDD_Database)
    .Usuario(FConfiguracoes.BDD_Usuario)
    .Senha(FConfiguracoes.BDD_Senha)
    .Connected(True);
end;

{ TControllerServer }

class function TControllerServer.GetInstance: TServer;
begin
  if not Assigned(FInstance) then
    FInstance := TServer.Create;
  Result := FInstance;
end;

initialization

finalization
  if Assigned(TControllerServer.FInstance) then
    TControllerServer.FInstance.Free;

end.
