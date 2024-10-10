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

    function Find: TArray<TEntidade>; overload;
    function Find(const aId: Integer): TEntidade; overload;
    function Insert(const aValue: TEntidade): iModel;
    function Update(const aValue: TEntidade): iModel;
    function Delete(const aId: Integer): iModel;
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
  FModel := nil;
  inherited;
end;

class function TControllerModel.New: iController;
begin
  Result := Self.Create;
end;

function TControllerModel.Find: TArray<TEntidade>;
begin
  Result := FModel.Find;
end;

function TControllerModel.Find(const aId: Integer): TEntidade;
begin
  Result := FModel.Find(aId);
end;

function TControllerModel.Insert(const aValue: TEntidade): iModel;
begin
  Result := FModel.Insert(aValue);
end;

function TControllerModel.Update(const aValue: TEntidade): iModel;
begin
  Result := FModel.Update(aValue);
end;

function TControllerModel.Delete(const aId: Integer): iModel;
begin
  Result := FModel.Delete(aId);
end;

{ TControllerEntidade<T> }

constructor TControllerEntidade<T>.Create;
begin
  inherited;
  FModel := TModel<T>.New;
end;

end.
