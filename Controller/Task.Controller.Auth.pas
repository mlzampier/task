unit Task.Controller.Auth;

interface

uses
  Classes, System.SysUtils, Variants, System.JSON, DBClient, SqlExpr, System.DateUtils, StrUtils,
  Horse, JOSE.Core.JWT, Horse.JWT, JOSE.Core.Builder, JOSE.Types.JSON;

type
  TResultJWT = record
    Criacao: TDateTime;
    Expiracao: TDateTime;
    TokenAcesso: string;
  end;

  TAuth = class
  private
    const cChaveJWT = 'DE846132-AEE9-4C6A-8D1B-F9GDDE33CD96';
  public
    class function CriarJWT(const pCodUsuario: Integer; const pUsuario, pSenha: string): TResultJWT;

    class procedure CallBack_Bearer(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
  end;

implementation

{ TAuth }

uses Task.Util.Cript, Task.Define.Constantes, Task.Controller.Server;

class function TAuth.CriarJWT(const pCodUsuario: Integer; const pUsuario, pSenha: string): TResultJWT;
var
  LJWT: TJWT;
  LJson: TJsonObject;
begin
  LJWT := TJWT.Create;
  try
    LJWT.Claims.Issuer := cDesenvolvedor_Nome;
    LJWT.Claims.Subject := pUsuario;
    LJWT.Claims.IssuedAt := Now;
    LJWT.Claims.Expiration := IncHour(Now, 8);

    LJson := TJsonObject.Create;
    try
      LJson.AddPair('codigo', TJSONNumber.Create(pCodUsuario));
      LJson.AddPair('username', pUsuario);
      LJson.AddPair('password', pSenha);
      LJWT.Claims.Json.AddPair('params', TCript.Encrypt(LJson.ToJson));
    finally
      LJson.Free;
    end;

    Result.Criacao := LJWT.Claims.IssuedAt;
    Result.Expiracao := LJWT.Claims.Expiration;
    Result.TokenAcesso := TJOSE.SHA256CompactToken(cChaveJWT, LJWT);
  finally
    LJWT.Free;
  end;
end;

class procedure TAuth.CallBack_Bearer(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
begin
  Horse.JWT.HorseJWT
    (cChaveJWT)
    (AReq, ARes,
    procedure
    var
      LParams: string;
      LUsername: string;
      LPassword: string;
      LJson: TJsonObject;
    begin
      LJson := AReq.Session<TJsonObject>;
      LParams := LJson.GetValue<string>('params', '');
      LParams := TCript.Decrypt(LParams);

      LJson := TJSONObject.ParseJSONValue(LParams) as TJsonObject;
      if not Assigned(LJson) then
        raise EHorseException.Create
          .Error('Parametros de autenticada inválidos')
          .Status(THTTPStatus.Unauthorized);

      try
        if (not LJson.TryGetValue('username', LUsername)) or (LUsername = '') or
           (not LJson.TryGetValue('password', LPassword)) or (LPassword = '') then
          raise EHorseException.Create
            .Error('Requisição não autenticada')
            .Status(THTTPStatus.Unauthorized);

        TControllerServer.Secao.CodUsuario := LJson.GetValue<Integer>('codigo', 0);
        TControllerServer.Secao.Usuario := LUsername;
      finally
        LJson.Free;
      end;

      ANext;
    end);
end;

end.
