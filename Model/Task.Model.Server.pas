unit Task.Model.Server;

interface

uses Variants, System.JSON, REST.JSON, Data.DB, StrUtils,
  Horse.Exception, Horse.Commons,
  Task.Model.Entidade, Task.Model.Interfaces, Task.Model.Connection.BDD, Task.Model.Connection.DataSet;

type
  TModel<T: TEntidade, constructor> = class(TInterfacedObject, iModel)
  private
    FConnection: iConnection;
  public
    constructor Create;
    destructor Destroy; override;

    class function New: iModel;

    function Find: TArray<TEntidade>; overload;
    function Find(const aId: Integer): TEntidade; overload;
    function Insert(const aValue: TEntidade): iModel;
    function Update(const aValue: TEntidade): iModel;
    function Delete(const aId: Integer): iModel;
  end;

implementation

uses System.SysUtils, System.Classes, Task.Controller.Server;

constructor TModel<T>.Create;
begin
  FConnection := TControllerServer.GetInstance.NewConnnection;
end;

destructor TModel<T>.Destroy;
begin
  inherited;
end;

class function TModel<T>.New: iModel;
begin
  Result := Self.Create;
end;

function TModel<T>.Find: TArray<TEntidade>;
var
  I: Integer;
  LField: string; 
  LFieldUser: string; 
  LSQL: string;
  LEntidade: T;
  LDataSet: iDataSet;
begin
  LSQL := '';
  for LField in T._Campos do
    LSQL := IfThen(LSQL <> '', LSQL + ',') + LField + sLineBreak;
  LSQL :=
    'select' + sLineBreak +
    LSQL +
    'from ' + T._Tabela + sLineBreak;

  // Carregar apenas registros do usuario
  LFieldUser := T._CampoUser;
  if LFieldUser <> '' then
    LSQL := LSQL + 'where ' + LFieldUser + ' = ' + IntToStr(TControllerServer.Secao.CodUsuario);

  FConnection.Reader(LDataSet, LSQL, []);

  I := 0;
  SetLength(Result, LDataSet.RecordCount);
  LDataSet.First;
  while not LDataSet.Eof do
  begin
    LEntidade := T.Create;
    LEntidade._From(LDataSet.DataSet);
    Result[I] := LEntidade;
    Inc(I);
    LDataSet.Next;
  end;
end;

function TModel<T>.Find(const aId: Integer): TEntidade;
var
  LField: string;  
  LFieldUser: string; 
  LSQL: string;
  LEntidade: T;
  LDataSet: iDataSet;
begin
  LSQL := '';
  for LField in T._Campos do
    LSQL := IfThen(LSQL <> '', LSQL + ',') + LField + sLineBreak;
  LSQL :=
    'select' + sLineBreak +
    LSQL +
    'from ' + T._Tabela + sLineBreak +
    'where ' + T._CampoID + ' = :COD' + sLineBreak;

  // Carregar apenas registros do usuario
  LFieldUser := T._CampoUser;
  if LFieldUser <> '' then
    LSQL := LSQL + '  and ' + LFieldUser + ' = ' + IntToStr(TControllerServer.Secao.CodUsuario);
  
  FConnection.Reader(LDataSet, LSQL, [aId]);

  if LDataSet.IsEmpty then
    raise EHorseException.Create
      .Error('Registro não encontrado')
      .Status(THTTPStatus.NotFound);

  LEntidade := T.Create;
  LEntidade._From(LDataSet.DataSet);
  Result := LEntidade;
end;

function TModel<T>.Insert(const aValue: TEntidade): iModel;
var
  I: Integer;   
  LSQL: string;
  LField: string;   
  LFieldID: string;  
  LFields: string;
  LValues: string;
  LFieldValue: Variant;  
  LFieldUser: string; 
  LVetValues: array of Variant;   
  LGenerator: string;
  LProxCodigo: Integer;  
begin
  Result := Self;  
          
  LFieldID := T._CampoID;    
  LFieldUser := T._CampoUser;

  I := 0;
  for LField in T._Campos do
  begin
    // Campo AutoInc e Usuario nao aceita da requisicao, popula no processo interno
    if (LField = LFieldID) or (LField = LFieldUser) then
      Continue;

    LFieldValue := aValue._Valor(LField);
    if LFieldValue = Unassigned then
      Continue;
      
    LFields := IfThen(LFields <> '', LFields + ',') + LField;
    LValues := IfThen(LValues <> '', LValues + ',') + ':' + LField;

    SetLength(LVetValues, I+1);
    LVetValues[I] := LFieldValue;
    Inc(I);
  end;

  // Vincular o registro ao usuario
  if LFieldUser <> '' then
  begin
    LFields := IfThen(LFields <> '', LFields + ',') + LFieldUser;
    LValues := IfThen(LValues <> '', LValues + ',') + ':' + LFieldUser;  
    
    SetLength(LVetValues, I+1);
    LVetValues[I] := TControllerServer.Secao.CodUsuario;
    Inc(I);
  end;

  // Gerar o AutoInc da tabela
  LGenerator := T._Generator;
  if LGenerator <> '' then 
  begin     
    LFields := IfThen(LFields <> '', LFields + ',') + LFieldID;
    LValues := IfThen(LValues <> '', LValues + ',') + ':' + LFieldID;

    LSQL := 'select gen_id(' + LGenerator + ', 1) from rdb$database';
    LProxCodigo := FConnection.Scalar(LSQL, []);
    
    SetLength(LVetValues, I+1);
    LVetValues[I] := LProxCodigo;
    Inc(I);
  end;

  LSQL :=
    'insert into ' + T._Tabela + sLineBreak +
    ' (' + LFields + ') ' + sLineBreak +
    ' values (' + LValues + ')';

  FConnection.Command(LSQL, LVetValues);
end;

function TModel<T>.Update(const aValue: TEntidade): iModel;
var        
  I: Integer;
  LSQL: string;
  LField: string;    
  LFieldID: string;    
  LFieldUser: string; 
  LFieldValue: Variant; 
  LVetValues: array of Variant;
begin
  Result := Self;
          
  LFieldID := T._CampoID; 
  LFieldUser := T._CampoUser;
  
  LSQL := '';
  I := 0;
  for LField in T._Campos do
  begin
    // Campo AutoInc e Usuario nao aceita alteracoes
    if (LField = LFieldID) or (LField = LFieldUser) then
      Continue;   

    LFieldValue := aValue._Valor(LField);
    if LFieldValue = Unassigned then
      Continue;
      
    LSQL := IfThen(LSQL <> '', LSQL + ',') + LField + ' = :' + LField + sLineBreak;

    SetLength(LVetValues, I+1);
    LVetValues[I] := LFieldValue;
    Inc(I);
  end;
          
  SetLength(LVetValues, I+1);
  LVetValues[I] := aValue._Valor(LFieldID);
    
  LSQL :=
    'update ' + T._Tabela + ' set ' + sLineBreak +
    LSQL +
    'where ' + LFieldID + ' = :' + LFieldID;

  if FConnection.Command(LSQL, LVetValues) = 0 then
    raise EHorseException.Create
      .Error('Registro não encontrado')
      .Status(THTTPStatus.NotFound);
end;

function TModel<T>.Delete(const aId: Integer): iModel;
var
  LFieldUser: string;
  LSQL: string;
begin
  Result := Self;

  LSQL :=
    'delete from ' + T._Tabela + sLineBreak +
    'where ' + T._CampoID + ' = :COD' + sLineBreak;

  // Apenas registros do usuario
  LFieldUser := T._CampoUser;
  if LFieldUser <> '' then
    LSQL := LSQL + '  and ' + LFieldUser + ' = ' + IntToStr(TControllerServer.Secao.CodUsuario);

  if FConnection.Command(LSQL, [aId]) = 0 then
    raise EHorseException.Create
      .Error('Registro não encontrado')
      .Status(THTTPStatus.NotFound);
end;

end.
