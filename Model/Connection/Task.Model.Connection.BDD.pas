unit Task.Model.Connection.BDD;

interface

uses System.SysUtils, Variants, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.DApt, FireDAC.Comp.Client,
  Task.Model.Connection.DataSet;

type
  iConnection = interface
    ['{D70C21D2-5231-4905-98B3-1A72703F9A75}']

    function DriverName(aValue: string): iConnection;
    function DataBase(aValue: string): iConnection;
    function Usuario(aValue: string): iConnection;
    function Senha(aValue: string): iConnection;

    function Connected(aValue: boolean): iConnection; overload;
    function Connected: boolean; overload;

    function Command(aSQL: string; aParams: array of Variant): Integer;
    function Reader(var aDataSet: iDataSet; aSQL: string; aParams: array of Variant): iConnection;
    function Scalar(aSql: string; aParams: array of variant): Variant;

    function Connection: TFDConnection;
  end;

  TModelConnection = class(TInterfacedObject, iConnection)
  private
    FConnection: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iConnection;

    function Connection: TFDConnection;

    function DriverName(aValue: string): iConnection;
    function DataBase(aValue: string): iConnection;
    function Usuario(aValue: string): iConnection;
    function Senha(aValue: string): iConnection;

    function Connected(aValue: boolean): iConnection; overload;
    function Connected: boolean; overload;

    function Command(aSQL: string; aParams: array of Variant): Integer;
    function Reader(var aDataSet: iDataSet; aSQL: string; aParams: array of Variant): iConnection;
    function Scalar(aSql: string; aParams: array of variant): Variant;
  end;

implementation

{ TModelConnection }

constructor TModelConnection.Create;
begin
  FConnection := TFDConnection.Create(nil);
  FConnection.LoginPrompt := False;
end;

destructor TModelConnection.Destroy;
begin
  FConnection.Free;
  inherited;
end;

class function TModelConnection.New: iConnection;
begin
  Result := Self.Create;
end;

function TModelConnection.Connection: TFDConnection;
begin
  Result := FConnection;
end;

function TModelConnection.DriverName(aValue: string): iConnection;
begin
  Result := Self;
  FConnection.DriverName := aValue;
end;

function TModelConnection.DataBase(aValue: string): iConnection;
begin
  Result := Self;
  FConnection.Params.Database := aValue;
end;

function TModelConnection.Usuario(aValue: string): iConnection;
begin
  Result := Self;
  FConnection.Params.UserName := aValue;
end;

function TModelConnection.Senha(aValue: string): iConnection;
begin
  Result := Self;
  FConnection.Params.Password := aValue;
end;

function TModelConnection.Connected(aValue: boolean): iConnection;
begin
  Result := Self;
  FConnection.Connected := aValue;
end;

function TModelConnection.Connected: boolean;
begin
  Result := FConnection.Connected;
end;

function TModelConnection.Command(aSQL: string; aParams: array of Variant): Integer;
begin
  Result := FConnection.ExecSQL(aSQL, aParams);
end;

function TModelConnection.Reader(var aDataSet: iDataSet; aSQL: string; aParams: array of Variant): iConnection;
begin
  if aDataSet = nil then
    aDataSet := TModelDataSet.New(FConnection);

  aDataSet.SQL.Text := aSQL;
  aDataSet.Open(aParams);
end;

function TModelConnection.Scalar(aSql: string; aParams: array of variant): Variant;
begin
  Result := FConnection.ExecSQLScalar(aSql, aParams);
end;

end.
