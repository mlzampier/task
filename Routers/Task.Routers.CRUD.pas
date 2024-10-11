unit Task.Routers.CRUD;

interface

uses System.Classes, System.SysUtils, Vcl.Forms, System.JSON, REST.JSON,
  Horse, Horse.Exception, Horse.GBSwagger, GBSwagger.Model, GBSwagger.Model.Interfaces,
  Task.Controller.Interfaces, Task.Model.Entidade, Task.Controller.API, Task.Controller;
 
type
  TRoutersCRUD = class
  protected
    class procedure List(Controller: iController; Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Get(Controller: iController; Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Controller: iController; pEntidade: TFEntidade; Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Controller: iController; pEntidade: TFEntidade; Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Controller: iController; Req: THorseRequest; Res: THorseResponse; Next: TProc);
  public
    class procedure Registry(pPath: string; pCreateController: TFunc<iController>; pEntidade: TFEntidade;
      pList: Boolean = True; pGet: Boolean = True; pPost: Boolean = True; pPut: Boolean = True; pDelete: Boolean = True);
  end;

  TControllerEntidade<T: TEntidade, constructor> = class(TControllerModel);

implementation

uses Task.Model.Server, Task.Controller.Auth;

class procedure TRoutersCRUD.List(Controller: iController; Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  I: Integer;
  LEntidades: TArray<TEntidade>;
  LJsonArray: TJSONArray;
begin
  LEntidades := Controller.Find;
  try
    LJsonArray := TJSONArray.Create;
    for I := Low(LEntidades) to High(LEntidades) do
      LJsonArray.AddElement(TJson.ObjectToJsonObject(LEntidades[I]));
    Res.Send<TJSONArray>(LJsonArray).Status(THTTPStatus.OK);
  finally
    for I := High(LEntidades) downto Low(LEntidades) do
      LEntidades[I].Free;
  end;
end;

class procedure TRoutersCRUD.Get(Controller: iController; Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LId: string;
  LEntidade: TEntidade;
begin
  if (not Req.Params.TryGetValue('id', LId)) or (LId = '') then
    raise EHorseException.Create
      .Error('Id do registro inválido')
      .Status(THTTPStatus.BadRequest);

  LEntidade := Controller.Find(StrToInt(LId));
  try
    Res.Send<TJSONObject>(TJson.ObjectToJsonObject(LEntidade)).Status(THTTPStatus.OK);
  finally
    LEntidade.Free;
  end;
end;

class procedure TRoutersCRUD.Post(Controller: iController; pEntidade: TFEntidade; Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJson: TJSONObject;
  LEntidade: TEntidade;
begin
  LJson := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;
  if not Assigned(LJson) then
    raise EHorseException.Create
      .Error('Body inválido')
      .Status(THTTPStatus.BadRequest);

  LEntidade := pEntidade.Create;
  try
    TJson.JsonToObject(LEntidade, LJson);
    Controller.Insert(LEntidade);
  finally
    LEntidade.Free;
    LJson.Free;
  end;
  Res.Status(THTTPStatus.Created).Send('Sucesso');
end;

class procedure TRoutersCRUD.Put(Controller: iController; pEntidade: TFEntidade; Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJson: TJSONObject;
  LEntidade: TEntidade;
begin
  LJson := TJSONObject.ParseJSONValue(Req.Body) AS TJSONObject;
  if not Assigned(LJson) then
    raise EHorseException.Create
      .Error('Body inválido')
      .Status(THTTPStatus.BadRequest);

  LEntidade := pEntidade.Create;
  try
    TJson.JsonToObject(LEntidade, LJson);
    Controller.Update(LEntidade);
  finally
    LEntidade.Free;
    LJson.Free;
  end;
  Res.Status(THTTPStatus.OK).Send('Sucesso');
end;

class procedure TRoutersCRUD.Delete(Controller: iController; Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LId: string;
begin
  if (not Req.Params.TryGetValue('id', LId)) or (LId = '') then
    raise EHorseException.Create
      .Error('Id do registro inválido')
      .Status(THTTPStatus.BadRequest);

  Controller.Delete(StrToInt(LId));
  Res.Status(THTTPStatus.OK).Send('Sucesso');
end;

class procedure TRoutersCRUD.Registry(pPath: string; pCreateController: TFunc<iController>; pEntidade: TFEntidade; pList, pGet, pPost, pPut, pDelete: Boolean);
begin
  if pList then
  begin
    THorse
      .AddCallback(TAuth.CallBack_Bearer)
      .Get('/' + pPath,
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        List(pCreateController, Req, Res, Next);
      end);

    Swagger.Path(pPath)
      .Tag(pPath)
      .Get('List', 'List All Records')
        .AddResponse(Integer(THTTPStatus.OK), 'Successful Operation').{Schema(pEntidade).}IsArray(True).&End
        .AddResponse(Integer(THTTPStatus.BadRequest), 'Bad Request').Schema(TAPIError).&End
        .AddResponse(Integer(THTTPStatus.InternalServerError), 'Internal Server Error').Schema(TAPIError).&End
        .AddSecurity('Bearer');
  end;

  if pGet then
  begin
    THorse
      .AddCallback(TAuth.CallBack_Bearer)
      .Get('/' + pPath + '/:id',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Get(pCreateController, Req, Res, Next);
      end);

    Swagger.Path(pPath + '/:id')
      .Tag(pPath)
      .Get('Record of Id')
        .AddParamPath('ID', 'Id of Record').&End
        .AddResponse(Integer(THTTPStatus.OK), 'Successful Operation').{Schema(pEntidade).}&End
        .AddResponse(Integer(THTTPStatus.BadRequest), 'Bad Request').Schema(TAPIError).&End
        .AddResponse(Integer(THTTPStatus.NotFound), 'Not Found').Schema(TAPIError).&End
        .AddResponse(Integer(THTTPStatus.InternalServerError), 'Internal Server Error').Schema(TAPIError).&End
        .AddSecurity('Bearer');
  end;

  if pPost then
  begin
    THorse
      .AddCallback(TAuth.CallBack_Bearer)
      .Post('/' + pPath,
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Post(pCreateController, pEntidade, Req, Res, Next);
      end);

    Swagger.Path(pPath)
      .Tag(pPath)
      .Post('Insert', 'Insert Record')
        .AddParamBody('Record', 'Record in Json').{Schema(pEntidade).}&End
        .AddResponse(Integer(THTTPStatus.OK), 'Successful Operation').&End
        .AddResponse(Integer(THTTPStatus.InternalServerError), 'Internal Server Error').Schema(TAPIError).&End
        .AddSecurity('Bearer');
  end;

  if pPut then
  begin
    THorse
      .AddCallback(TAuth.CallBack_Bearer)
      .Put('/' + pPath,
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Put(pCreateController, pEntidade, Req, Res, Next);
      end);

    Swagger.Path(pPath)
      .Tag(pPath)
      .Put('Update', 'Update of Id')
        .AddParamBody('Record', 'Record in Json').{Schema(pEntidade).}&End
        .AddResponse(Integer(THTTPStatus.OK), 'Successful Operation').&End
        .AddResponse(Integer(THTTPStatus.BadRequest), 'Bad Request').Schema(TAPIError).&End
        .AddResponse(Integer(THTTPStatus.NotFound), 'Not Found').Schema(TAPIError).&End
        .AddResponse(Integer(THTTPStatus.InternalServerError), 'Internal Server Error').Schema(TAPIError).&End
        .AddSecurity('Bearer');
  end;

  if pDelete then
  begin
    THorse
      .AddCallback(TAuth.CallBack_Bearer)
      .Delete('/' + pPath + '/:id',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Delete(pCreateController, Req, Res, Next);
      end);

    Swagger.Path(pPath)
      .Tag(pPath)
      .Delete('Delete', 'Delete of Id')
        .AddParamPath('ID', 'Id of Record').&End
        .AddResponse(Integer(THTTPStatus.OK), 'Successful Operation').&End
        .AddResponse(Integer(THTTPStatus.BadRequest), 'Bad Request').Schema(TAPIError).&End
        .AddResponse(Integer(THTTPStatus.NotFound), 'Not Found').Schema(TAPIError).&End
        .AddResponse(Integer(THTTPStatus.InternalServerError), 'Internal Server Error').Schema(TAPIError).&End
        .AddSecurity('Bearer');
  end;
end;

end.
