unit Task.Model.Interfaces;

interface

uses Variants, System.JSON, REST.JSON, Data.DB, StrUtils, Task.Model.Entidade;

type
  iModel = interface
    ['{CC841DC4-35D1-4468-ABB1-51B4FA31DBD1}']
    function Find: TArray<TEntidade>; overload;
    function Find(const aId: Integer): TEntidade; overload;
    function Insert(const aValue: TEntidade): iModel;
    function Update(const aValue: TEntidade): iModel;
    function Delete(const aId: Integer): iModel;
  end;

implementation

end.
