unit Task.Controller;

interface

uses Task.Controller.Interfaces, Task.Model.Interfaces, Task.Model.Entidade;

type
  TControllerModel = class(TInterfacedObject, iController)
  private
    FModel: iModel;
    [weak]
    FParent: iController;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    class function New: iController;

    function Model: iModel;
    function &End: iController;
  end;

  TControllerEntidade<T: TEntidade, constructor> = class(TControllerModel)
  public
    constructor Create; override;
  end;

implementation

uses {$IfDef SERVER} Task.Model.Server {$ELSE} Task.Model.Client {$EndIf};


{ TControllerModel }

constructor TControllerModel.Create;
begin
  FParent := Self;
end;

destructor TControllerModel.Destroy;
begin

  inherited;
end;

class function TControllerModel.New: iController;
begin
  Result := Self.Create;
end;

function TControllerModel.Model: iModel;
begin
  Result := FModel;
end;

function TControllerModel.&End: iController;
begin
  Result := FParent;
end;

{ TControllerEntidade<T> }

constructor TControllerEntidade<T>.Create;
begin
  inherited;
  FModel := TModel<T>.New;
end;

end.
