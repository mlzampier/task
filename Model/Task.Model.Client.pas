unit Task.Model.Client;

interface

uses System.SysUtils, System.Classes, Variants, System.JSON, REST.JSON, Data.DB, StrUtils,
  Task.Model.Entidade, Task.Model.Interfaces,
  RESTRequest4D;

type
  TModel<T: TEntidade, constructor> = class(TInterfacedObject, iModel)
  public
    class function New: iModel;

    function Find: TArray<TEntidade>; overload;
    function Find(const aId: Integer): TEntidade; overload;
    function Insert(const aValue: TEntidade): iModel;
    function Update(const aValue: TEntidade): iModel;
    function Delete(const aId: Integer): iModel;
  end;

implementation

uses Task.Controller.Client;

class function TModel<T>.New: iModel;
begin
  Result := Self.Create;
end;

function TModel<T>.Find: TArray<TEntidade>;
var
  I: Integer;
  LResponse: IResponse;
  LJsonArray: TJSONArray;
  LJsonObject: TJSONObject;
  LEntidade: T;
begin
  LResponse := TRequest.New.BaseURL(TControllerClient.GetInstance.Configuracoes.Servidor_URL)
    .Resource('task')
    .AddHeader('authorization', 'Bearer ' + TControllerClient.GetInstance.Secao.Autorization, [poDoNotEncode])
    .Accept('application/json')
    .Get;
  if LResponse.StatusCode <> 200 then
    raise Exception.Create(LResponse.Content);

  LJsonArray := TJSONObject.ParseJSONValue(LResponse.Content) as TJSONArray;
  if not Assigned(LJsonArray) then
    raise Exception.Create('Retorno inválido');

  try
    SetLength(Result, LJsonArray.Count);
    for I := 0 to LJsonArray.Count -1 do
      if LJsonArray.Items[I].TryGetValue(LJsonObject) then
      begin
        LEntidade := T.Create;
        TJson.JsonToObject(LEntidade, LJsonObject);
        Result[I] := LEntidade;
      end;
  finally
    LJsonArray.Free;
  end;
end;

function TModel<T>.Find(const aId: Integer): TEntidade;
var
  LResponse: IResponse;
  LJsonObject: TJSONObject;
  LEntidade: T;
begin
  LResponse := TRequest.New.BaseURL(TControllerClient.GetInstance.Configuracoes.Servidor_URL)
    .Resource('task/' + IntToStr(aId))
    .AddHeader('authorization', 'Bearer ' + TControllerClient.GetInstance.Secao.Autorization, [poDoNotEncode])
    .Accept('application/json')
    .Get;
  if LResponse.StatusCode <> 200 then
    raise Exception.Create(LResponse.Content);

  LJsonObject := TJSONObject.ParseJSONValue(LResponse.Content) as TJSONObject;
  if not Assigned(LJsonObject) then
    raise Exception.Create('Retorno inválido');

  try
    LEntidade := T.Create;
    TJson.JsonToObject(LEntidade, LJsonObject);
  finally
    LJsonObject.Free;
  end;
end;

function TModel<T>.Insert(const aValue: TEntidade): iModel;
var
  LJson: TJSONObject;
  LResponse: IResponse;
begin
  Result := Self;

  LResponse := TRequest.New.BaseURL(TControllerClient.GetInstance.Configuracoes.Servidor_URL)
    .Resource('task')
    .AddHeader('authorization', 'Bearer ' + TControllerClient.GetInstance.Secao.Autorization, [poDoNotEncode])
    .AddBody(TJson.ObjectToJsonObject(aValue))
    .Accept('application/json')
    .Post;
  if LResponse.StatusCode <> 201 then
    raise Exception.Create(LResponse.Content);
end;

function TModel<T>.Update(const aValue: TEntidade): iModel;
var
  LJson: TJSONObject;
  LResponse: IResponse;
begin
  Result := Self;

  LResponse := TRequest.New.BaseURL(TControllerClient.GetInstance.Configuracoes.Servidor_URL)
    .Resource('task')
    .AddHeader('authorization', 'Bearer ' + TControllerClient.GetInstance.Secao.Autorization, [poDoNotEncode])
    .AddBody(TJson.ObjectToJsonObject(aValue))
    .Accept('application/json')
    .Put;
  if LResponse.StatusCode <> 200 then
    raise Exception.Create(LResponse.Content);
end;

function TModel<T>.Delete(const aId: Integer): iModel;
var
  LResponse: IResponse;
begin
  Result := Self;

  LResponse := TRequest.New.BaseURL(TControllerClient.GetInstance.Configuracoes.Servidor_URL)
    .Resource('task/' + IntToStr(aId))
    .AddHeader('authorization', 'Bearer ' + TControllerClient.GetInstance.Secao.Autorization, [poDoNotEncode])
    .Accept('application/json')
    .Delete;
  if LResponse.StatusCode <> 200 then
    raise Exception.Create(LResponse.Content);
end;

end.
