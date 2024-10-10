unit Task.Controller.Login;

interface

uses System.Classes, System.SysUtils, Json, RESTRequest4D;

type
  TControllerLogin = class
  public
    class procedure Logar(const aUsuario, aSenha: string; const pLembraSenha: Boolean);
  end;

implementation

{ TControllerClient }

uses Task.Controller.Client;

class procedure TControllerLogin.Logar(const aUsuario, aSenha: string; const pLembraSenha: Boolean);
var
  LJsonReq: TJSONObject;
  LJsonRes: TJSONObject;
  LResponse: IResponse;
begin
  if TControllerClient.GetInstance.Configuracoes.Servidor_URL = '' then
    raise Exception.Create('Configuração do servidor ainda não realizado. Acesse o menu de configurações para realizar');

  LJsonReq := TJSONObject.Create;
  LJsonReq.AddPair('username', aUsuario);
  LJsonReq.AddPair('password', aSenha);

  LResponse := TRequest.New.BaseURL(TControllerClient.GetInstance.Configuracoes.Servidor_URL)
    .Resource('auth')
    .AddBody(LJsonReq)
    .Accept('application/json')
    .Post;
  if LResponse.StatusCode <> 201 then
    raise Exception.Create(LResponse.Content);

  LJsonRes := TJSONObject.ParseJSONValue(LResponse.Content) as TJSONObject;
  if not Assigned(LJsonRes) then
    raise Exception.Create('Retorno invalido');
  try
    TControllerClient.GetInstance.Save_Auth(LJsonRes.GetValue<string>('tokenAcesso', ''));
  finally
    LJsonRes.Free;
  end;

  if pLembraSenha then
    TControllerClient.GetInstance.Save_Login(aUsuario, aSenha)
  else
    TControllerClient.GetInstance.Save_Login(aUsuario, '');
end;

end.
