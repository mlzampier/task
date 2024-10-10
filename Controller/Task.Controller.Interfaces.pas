unit Task.Controller.Interfaces;

interface

uses Task.Model.Interfaces, Task.Model.Entidade;

type
  iController = interface
    ['{D0D86AB1-CC8A-4AF8-B502-8D6DBD1EDD3F}']

    function Find: TArray<TEntidade>; overload;
    function Find(const aId: Integer): TEntidade; overload;
    function Insert(const aValue: TEntidade): iModel;
    function Update(const aValue: TEntidade): iModel;
    function Delete(const aId: Integer): iModel;
  end;

implementation

end.
