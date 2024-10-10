unit Task.Controller.Task;

interface

uses Task.Controller, Task.Model.Entidade.Task;

type
  TControllerTask = class(TControllerEntidade<TEntidadeTask>)
  private
    FEntidade: TEntidadeTask;
  public
    property Entidade: TEntidadeTask read FEntidade write FEntidade;
  end;

implementation

end.
