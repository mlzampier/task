unit Task.Controller.API;

interface

uses System.SysUtils, Horse, Horse.GBSwagger, Horse.Jhonson, Horse.HandleException, Horse.Compression;

type
  TControllerAPI = class
  private
    class procedure Config_Horse;
    class procedure Config_Documentacao;
    class procedure Registrar_Rotas;
  public
    class procedure Build;
  end;

  TAPIError = class
  private
    Ferror: string;
  public
    property error: string read Ferror write Ferror;
  end;

implementation

uses Task.Controller.Server, Task.Model.Entidade.Task, Task.Routers.CRUD, Task.Controller.Task, Task.Controller.Interfaces, Task.Define.Constantes, Task.Route.Auth,
  Task.Define.Constantes.Server;

{ TControllerAPI }

class procedure TControllerAPI.Config_Horse;
begin
  THorse
    .Use(Compression())
    .Use(Jhonson)
    .Use(HandleException)
    .Use(HorseSwagger);

  THorse.Port := TControllerServer.GetInstance.Configuracoes.Horse_Porta;
end;

class procedure TControllerAPI.Config_Documentacao;
begin
  Swagger
    .Info
      .Version(cSoftware_Versao)
      .Title(cSoftware_Titulo)
      .Description(cSoftware_Descricao)
      .Contact
        .Name(cDesenvolvedor_Nome)
        .Email(cDesenvolvedor_Email);
end;

class procedure TControllerAPI.Registrar_Rotas;
begin
  THorse.Use(HorseSwagger('/doc', '/doc/json'));

  TRoutersAuth.Registry;

  TRoutersCRUD.Registry('task',
    function (): iController
    begin
      Result := TControllerTask.New;
    end,
    TEntidadeTask);

  {TRoutersCRUD.Registry('usuario',
    function (): iController
    begin
      Result := TControllerUsuario.New;
    end,
    TEntidadeUsuario);}
end;

class procedure TControllerAPI.Build;
begin
  TControllerServer.GetInstance.Load_Config;

  Config_Horse;
  Config_Documentacao;
  Registrar_Rotas;

  THorse.Listen(
    procedure
    begin
      Writeln('Titulo: ' + cSoftware_Titulo);
      Writeln('Descrição: ' + cSoftware_Descricao);
      Writeln('Versão: ' + cSoftware_Versao);
      Writeln(Format('Server is runing on %s:%d', [THorse.Host, THorse.Port]));
    end);
end;

end.
