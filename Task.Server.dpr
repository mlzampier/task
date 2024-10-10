program Task.Server;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Task.Define.Constantes in 'Define\Task.Define.Constantes.pas',
  Task.Define.Constantes.Server in 'Define\Task.Define.Constantes.Server.pas',
  Task.Controller in 'Controller\Task.Controller.pas',
  Task.Controller.API in 'Controller\Task.Controller.API.pas',
  Task.Controller.Interfaces in 'Controller\Task.Controller.Interfaces.pas',
  Task.Controller.Server in 'Controller\Task.Controller.Server.pas',
  Task.Controller.Auth in 'Controller\Task.Controller.Auth.pas',
  Task.Controller.Task in 'Controller\Task.Controller.Task.pas',
  Task.Controller.Usuario in 'Controller\Task.Controller.Usuario.pas',
  Task.Model.Server in 'Model\Task.Model.Server.pas',
  Task.Model.Interfaces in 'Model\Task.Model.Interfaces.pas',
  Task.Model.Connection.BDD in 'Model\Connection\Task.Model.Connection.BDD.pas',
  Task.Model.Connection.DataSet in 'Model\Connection\Task.Model.Connection.DataSet.pas',
  Task.Model.Entidade in 'Model\Entidade\Task.Model.Entidade.pas',
  Task.Model.Entidade.Task in 'Model\Entidade\Task.Model.Entidade.Task.pas',
  Task.Model.Entidade.Usuario in 'Model\Entidade\Task.Model.Entidade.Usuario.pas',
  Task.Route.Auth in 'Routers\Task.Route.Auth.pas',
  Task.Routers.CRUD in 'Routers\Task.Routers.CRUD.pas',
  Task.Util.Cript in 'Util\Task.Util.Cript.pas';

begin
  try
    TControllerAPI.Build;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
