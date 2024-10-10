unit Task.Util.Cript;

interface

uses Classes, System.SysUtils, Variants;

const cKeyDefault = 15315;

type
  TCript = class
  private
    const CKEY1 = 53761;
    const CKEY2 = 32618;
  public
    class function Encrypt(const S: WideString; Key: Word = cKeyDefault): String;
    class function Decrypt(const S: String; Key: Word = cKeyDefault): String;
  end;

implementation

class function TCript.Encrypt(const S: WideString; Key: Word): String;
var
  i: Integer;
  RStr: RawByteString;
  RStrB: TBytes Absolute RStr;
begin
  Result := '';
  RStr := UTF8Encode(S);
  for i := 0 to Length(RStr) - 1 do
  begin
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (RStrB[i] + Key) * CKEY1 + CKEY2;
  end;
  for i := 0 to Length(RStr) - 1 do
  begin
    Result := Result + IntToHex(RStrB[i], 2);
  end;
end;

class function TCript.Decrypt(const S: String; Key: Word): String;
var
  i, tmpKey: Integer;
  RStr: RawByteString;
  RStrB: TBytes Absolute RStr;
  tmpStr: string;
begin
  tmpStr := UpperCase(S);
  SetLength(RStr, Length(tmpStr) div 2);
  i := 1;
  try
    while (i < Length(tmpStr)) do
    begin
      RStrB[i div 2] := StrToInt('$' + tmpStr[i] + tmpStr[i + 1]);
      Inc(i, 2);
    end;
  except
    Result := '';
    Exit;
  end;
  for i := 0 to Length(RStr) - 1 do
  begin
    tmpKey := RStrB[i];
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (tmpKey + Key) * CKEY1 + CKEY2;
  end;
  Result := UTF8ToString(RStr);
end;

end.
