program Task.Client;

uses
  System.StartUpCopy,
  FMX.Forms,
  Task.Define.Constantes in 'Define\Task.Define.Constantes.pas',
  Task.Define.Constantes.Client in 'Define\Task.Define.Constantes.Client.pas',
  Task.Controller.Client in 'Controller\Task.Controller.Client.pas',
  Task.Controller.Login in 'Controller\Task.Controller.Login.pas',
  Task.Model.Client in 'Model\Task.Model.Client.pas',
  Task.Model.Interfaces in 'Model\Task.Model.Interfaces.pas',
  Task.Model.Entidade in 'Model\Entidade\Task.Model.Entidade.pas',
  Task.Model.Entidade.Task in 'Model\Entidade\Task.Model.Entidade.Task.pas',
  Task.View.Principal in 'View\Task.View.Principal.pas' {FPrincipal},
  Task.Controller.Task in 'Controller\Task.Controller.Task.pas',
  Task.Controller in 'Controller\Task.Controller.pas',
  Task.Controller.Interfaces in 'Controller\Task.Controller.Interfaces.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.Run;
end.
