unit Task.Model.Connection.DataSet;

interface

uses System.Classes, Data.DB, Variants,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  iDataSet = interface
    ['{C7F8A319-EEB6-4B7E-AADA-28F62F79E0A7}']
    function DataSet: TDataSet;

    function SQL: TStrings;
    function ExecCommand(aParams: array of Variant): iDataSet;
    function Open(aParams: array of Variant): iDataSet;
    function IsEmpty: Boolean;
    function RecordCount: Integer;
    function FieldByName(aFieldName: string): TField;
    procedure First;
    procedure Next;
    function Eof: Boolean;
  end;

  TModelDataSet = class(TInterfacedObject, iDataSet)
  private
    FDataSet: TFDQuery;
  public
    constructor Create;
    destructor Destroy; override;

    class function New(aConnection: TFDConnection) : iDataSet;

    function DataSet: TDataSet;

    function SQL: TStrings;
    function ExecCommand(aParams: array of Variant): iDataSet;
    function Open(aParams: array of Variant): iDataSet;

    function IsEmpty: Boolean;
    function RecordCount: Integer;
    function FieldByName(aFieldName: string): TField;

    procedure First;
    procedure Next;
    function Eof: Boolean;
  end;

implementation

{ TModelDataSet }

constructor TModelDataSet.Create;
begin
  FDataSet := TFDQuery.Create(nil);
end;

destructor TModelDataSet.Destroy;
begin
  FDataSet.Free;
  inherited;
end;

class function TModelDataSet.New(aConnection : TFDConnection): iDataSet;
begin
  Result := Self.Create;
  TFDQuery(Result.DataSet).Connection := aConnection;
end;

function TModelDataSet.DataSet: TDataSet;
begin
  Result := TDataSet(FDataSet);
end;

function TModelDataSet.SQL: TStrings;
begin
  Result := FDataSet.SQL;
end;

function TModelDataSet.ExecCommand(aParams: array of Variant): iDataSet;
begin
  Result := Self;
  FDataSet.ExecSQL(FDataSet.SQL.Text, aParams);
end;

function TModelDataSet.Open(aParams: array of Variant): iDataSet;
begin
  Result := Self;
  FDataSet.Open(FDataSet.SQL.Text, aParams);
end;

function TModelDataSet.IsEmpty: Boolean;
begin
  Result := FDataSet.IsEmpty;
end;

function TModelDataSet.RecordCount: Integer;
begin
  Result := FDataSet.RecordCount;
end;

function TModelDataSet.FieldByName(aFieldName: string): TField;
begin
  Result := FDataSet.FieldByName(aFieldName);
end;

procedure TModelDataSet.First;
begin
  FDataSet.First;
end;

procedure TModelDataSet.Next;
begin
  FDataSet.Next;
end;

function TModelDataSet.Eof: Boolean;
begin
  Result := FDataSet.Eof;
end;

end.
