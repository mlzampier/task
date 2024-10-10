unit Task.Route.Auth;

interface

uses
  Classes, System.SysUtils, Variants, System.JSON, REST.JSON,
  Horse, GBSwagger.Model.Interfaces;

type
  TReqAuth = class
  private
    fUsername: string;
    fPassword: string;
  public
    property username: string read fUsername write fUsername;
    property password: string read fPassword write fPassword;
  end;

  TResAuth = class
  private
    fCriacao: TDateTime;
    fExpiracao: TDateTime;
    fTokenAcesso: string;
  public
    property criacao: TDateTime read fCriacao write fCriacao;
    property expiracao: TDateTime read fExpiracao write fExpiracao;
    property tokenAcesso: string read fTokenAcesso write fTokenAcesso;
  end;

  TRoutersAuth = class
  private
    class procedure Auth(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  public
    class procedure Registry;
  end;

implementation

{ TRoutersAuth }

uses Task.Controller.API, Task.Controller.Server, Task.Model.Connection.DataSet, Task.Util.Cript, Task.Controller.Auth;

class procedure TRoutersAuth.Auth(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LJsonBody: TJSONObject;
  LUsername: string;
  LPassword: string;
  LDataSet: iDataSet;
  LAuthReposta: TResAuth;
begin
  LJsonBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  if LJsonBody = nil then
    raise EHorseException.New
      .Error('Parâmetros para autenticação inválidos')
      .Status(THTTPStatus.BadRequest);

  try
    if (not LJsonBody.TryGetValue<string>('username', LUsername)) or (LUsername = '') then
      raise EHorseException.New
        .Error('Parâmetros para autenticação com usuário não definido')
        .Status(THTTPStatus.BadRequest);

    if (not LJsonBody.TryGetValue<string>('password', LPassword)) or (LPassword = '') then
      raise EHorseException.New
        .Error('Parâmetros para autenticação com senha não definida')
        .Status(THTTPStatus.BadRequest);
  finally
    LJsonBody.Free;
  end;

  TControllerServer.GetInstance.NewConnnection.Reader(LDataSet, 'select CODIGO_USU, SENHA_USU from USUARIO where CODIGO_USU > 0 and DESCRICAO_USU = :DESC', [LUsername]);

  if LDataSet.IsEmpty then
    raise EHorseException.New
      .Error('Usuário inválido para autenticação')
      .Status(THTTPStatus.Unauthorized);

  if TCript.Decrypt(LDataSet.FieldByName('SENHA_USU').AsString) <> LPassword then
    raise EHorseException.New
      .Error('Usuário ou senha inválidos para autenticação')
      .Status(THTTPStatus.Unauthorized);

  LAuthReposta := TResAuth.Create;
  try
    with TAuth.CriarJWT(LDataSet.FieldByName('CODIGO_USU').AsInteger, LUsername, LPassword) do
    begin
      LAuthReposta.Criacao := Criacao;
      LAuthReposta.Expiracao := Expiracao;
      LAuthReposta.TokenAcesso := TokenAcesso;
    end;
    Res
      .Send<TJSONObject>(TJson.ObjectToJsonObject(LAuthReposta))
      .Status(THTTPStatus.Created);
  finally
    LAuthReposta.Free
  end;
end;

class procedure TRoutersAuth.Registry;
begin
  THorse
    .Post('auth', Auth);

  Swagger.Path('auth')
    .Tag('auth')
    .Post('Autenticação')
    .AddParamBody('Request').Schema(TReqAuth).Required(True).&End
    .AddResponse(Integer(THTTPStatus.Created), 'Successful Operation').Schema(TResAuth).&End
    .AddResponse(Integer(THTTPStatus.Unauthorized)).&End
    .AddResponse(Integer(THTTPStatus.InternalServerError), 'Internal Server Error').Schema(TAPIError).&End;
end;

end.
