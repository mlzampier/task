unit Task.Model.Entidade;

interface

uses Rtti, System.SysUtils, Variants, DB, System.TypInfo, DateUtils, Json;

type
  TAttributeSimples = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(Name: string);
    property Name: string read FName;
  end;

  Tabela = class(TAttributeSimples);
  Campo = class(TAttributeSimples);
  PK = class(TCustomAttribute);
  AutoInc = class(TAttributeSimples);
  User = class(TCustomAttribute);

  TEntidade = class
  public
    class function _Tabela: string;
    class function _CampoID: string;
    class function _CampoUser: string;
    class function _Campos: TArray<string>;
    class function _Generator: string;
    function _Valor(NomeCampo: string; SQL: Boolean = False): variant;
    procedure _From(Value: TDataSet);
  end;

  TFEntidade = class of TEntidade;

implementation

{ TEntidadeAttribute }

constructor TAttributeSimples.Create(Name: string);
begin
  FName := Name
end;

{ TEntidade }

class function TEntidade._Tabela: string;
var
  LContexto: TRttiContext;
  LTipo: TRttiType;
  LAtributo: TCustomAttribute;
begin
  LContexto := TRttiContext.Create;
  try
    LTipo := LContexto.GetType(self.ClassInfo);
    for LAtributo in LTipo.GetAttributes do
      if (LAtributo is Tabela) then
        Exit(Tabela(LAtributo).Name);
  finally
    LContexto.Free;
  end;
end;

class function TEntidade._CampoID: string;
var
  Leh: Boolean;
  LContexto: TRttiContext;
  LTipo: TRttiType;
  LPropriedade : TRttiProperty;
  LAtributo: TCustomAttribute;
begin
  Result := '';
  LContexto := TRttiContext.Create;
  try
    LTipo := LContexto.GetType(self.ClassInfo);
    for LPropriedade in LTipo.GetProperties do
    begin
      Leh := False;
      for LAtributo in LPropriedade.GetAttributes do
        if (LAtributo is PK) then
          Leh := True;
      if Leh then
        for LAtributo in LPropriedade.GetAttributes do
          if (LAtributo is Campo) then
            Exit((LAtributo as Campo).Name);
    end;
  finally
    LContexto.Free;
  end;
end;

class function TEntidade._CampoUser: string;
var
  Leh: Boolean;
  LContexto: TRttiContext;
  LTipo: TRttiType;
  LPropriedade : TRttiProperty;
  LAtributo: TCustomAttribute;
begin
  Result := '';
  LContexto := TRttiContext.Create;
  try
    LTipo := LContexto.GetType(self.ClassInfo);
    for LPropriedade in LTipo.GetProperties do
    begin
      Leh := False;
      for LAtributo in LPropriedade.GetAttributes do
        if (LAtributo is User) then
          Leh := True;
      if Leh then
        for LAtributo in LPropriedade.GetAttributes do
          if (LAtributo is Campo) then
            Exit((LAtributo as Campo).Name);
    end;
  finally
    LContexto.Free;
  end;
end;

class function TEntidade._Campos: TArray<string>;
var
  i: Integer;
  LContexto: TRttiContext;
  LTipo: TRttiType;
  LPropriedade : TRttiProperty;
  LAtributo: TCustomAttribute;
begin
  I := 0;
  Result := TArray<string>.Create();
  LContexto := TRttiContext.Create;
  try
    LTipo := LContexto.GetType(self.ClassInfo);
    for LPropriedade in LTipo.GetProperties do
      for LAtributo in LPropriedade.GetAttributes do
        if (LAtributo is Campo) then
        begin
          SetLength(Result, I+1);
          Result[I] := (LAtributo as Campo).Name;
          Inc(I);
          Break;
        end;
  finally
    LContexto.Free;
  end;
end;

class function TEntidade._Generator: string;
var
  LContexto: TRttiContext;
  LTipo: TRttiType;
  LPropriedade : TRttiProperty;
  LAtributo: TCustomAttribute;
begin
  Result := '';
  LContexto := TRttiContext.Create;
  try
    LTipo := LContexto.GetType(self.ClassInfo);
    for LPropriedade in LTipo.GetProperties do
    begin
      for LAtributo in LPropriedade.GetAttributes do
        if (LAtributo is AutoInc) then
          Exit(AutoInc(LAtributo).Name);
    end;
  finally
    LContexto.Free;
  end;
end;

function TEntidade._Valor(NomeCampo: string; SQL: Boolean = False): variant;
var
  LContexto: TRttiContext;
  LTipo: TRttiType;
  LPropriedade : TRttiProperty;
  LAtributo: TCustomAttribute;
begin
  LContexto := TRttiContext.Create;
  try
    LTipo := LContexto.GetType(Self.ClassInfo);
    for LPropriedade in LTipo.GetProperties do
      for LAtributo in LPropriedade.GetAttributes do
        if (LAtributo is Campo) then
          if (LAtributo as Campo).Name = NomeCampo then
            if SQL and (LPropriedade.PropertyType.TypeKind = tkFloat) then
            begin
              if LPropriedade.GetValue(Pointer(Self)).TypeInfo = TypeInfo(TDate) then
              begin
                if LPropriedade.GetValue(Pointer(Self)).ToString = '' then
                  Exit(Null)
                else
                  Exit(FormatDateTime('mm/dd/yyyy', StrToDate(LPropriedade.GetValue(Pointer(Self)).ToString)));
              end else
                Exit(string(LPropriedade.GetValue(Pointer(Self)).AsVariant).Replace('.','').Replace(',','.'))
            end
            else
              Exit(string(LPropriedade.GetValue(Pointer(Self)).AsVariant));
  finally
    LContexto.Free;
  end;
end;

procedure TEntidade._From(Value: TDataSet);
var
  LField: TField;
  LContexto: TRttiContext;
  LTipo: TRttiType;
  LPropriedade : TRttiProperty;
  LAtributo: TCustomAttribute;
begin
  LContexto := TRttiContext.Create;
  try
    LTipo := LContexto.GetType(Self.ClassInfo);

    for LField in Value.Fields do
    begin
      for LPropriedade in LTipo.GetProperties do
        for LAtributo in LPropriedade.GetAttributes do
          if (LAtributo is Campo) then
            if (LAtributo as Campo).Name = LField.FieldName then
              if LPropriedade.GetValue(Pointer(Self)).ToString <> LField.AsString then
              begin
                if LPropriedade.PropertyType.TypeKind = tkFloat then
                begin
                  if LPropriedade.GetValue(Pointer(Self)).TypeInfo = TypeInfo(TDate) then
                    LPropriedade.SetValue(Pointer(Self), LField.AsDateTime)
                  else
                    LPropriedade.SetValue(Pointer(Self), LField.AsCurrency)
                end
                else
                  LPropriedade.SetValue(Pointer(Self), TValue.FromVariant(LField.AsVariant));
                Break;
              end;
    end;
  finally
    LContexto.Free;
  end;
end;

end.
