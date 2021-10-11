{ RecList :
     TRecordsList : 19/04/2008
     auteur : ThWilliam}

unit RecList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StrUtils;

type

  TRLLocateOption = (loPartialKey, loNoCaseSensitive, loNoAccentSensitive);
         {loPartialKey: true = recherche une chaine commençant par la clé
          loNoCaseSensitive: true = recherche sans distinguer Min-Maj
          loNoAccentSensitive: true = recherche sans distinguer les caractères accentués}
  TRLLocateOptions = set of TRLLocateOption;

  TRLSortOrder = (soAscending, soDescending); // tri par ordre croissant ou décroissant

  TRLSortCompare = function(Index1, Index2: Integer): Integer of object;

  TRLCompareValuesEvent = function(AValue1, AValue2: string; AField: integer; AOptions: TRLLocateOptions; var ADefault: boolean): integer of object;

  TCustomRecList = class(TList)
  private
    FArraySortKey: array of integer;
    FSortOrder: TRLSortOrder;
    FSortOptions: TRLLocateOptions;
    FOnCompareValues: TRLCompareValuesEvent;
    function GetRecord(ARecord: integer): string;
    function SetRecord(const A: array of string): string;
    function GetFieldsCount(ARecord: integer): integer;
    function GetTextStr: string;
    procedure SetTextStr(const Value: string);
    procedure QuickSort(L, R: Integer; SCompare: TRLSortCompare);
    function InternalSCompare(Index1, Index2: Integer): Integer;
    function InternalCompareValues(const AValue1, AValue2: string; AField: integer; AOptions: TRLLocateOptions): integer;
    function InternalAdd(const S: string): integer;
    function InternalInsert(const S: string; ARecord: integer): integer;
    procedure InternalEdit(const S: string; ARecord: integer);
    function SearchFieldValue(AField: integer; S: string): string;
  protected
    function GetFieldValue(AField: integer; ARecord: integer): string;
    function Add(const A: array of string): integer;
    function Insert(const A: array of string; ARecord: integer): integer;
    function Edit(const A: array of string; ARecord: integer): integer;
    procedure Delete(ARecord: Integer);
    procedure DoClear;
    property SortOptions: TRLLocateOptions read FSortOptions write FSortOptions default [loNoCaseSensitive];
    property SortOrder: TRLSortOrder read FSortOrder write FSortOrder default soAscending;
    property OnCompareValues: TRLCompareValuesEvent read FOnCompareValues write FOnCompareValues;
    property FieldValue[AField: integer; ARecord: integer]: string read GetFieldValue;
    property FieldsCount[ARecord: integer]: integer read GetFieldsCount;
    property RecordValue[ARecord: integer]: string read GetRecord;
    procedure SetSortKey(AFields: array of integer);
    function DoFindKey(const A: array of string; var ARecord: Integer; Options: TRLLocateOptions): Boolean;
    function CompareValues(AValue1, AValue2: string; AOptions: TRLLocateOptions): integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    function Locate(const A: array of string; var ARecord: integer; Options: TRLLocateOptions; Start: integer = 0): boolean; overload;
    function Locate(const AValues: array of string; const AFields: array of integer; var ARecord: integer; Options: TRLLocateOptions; Start: integer = 0): boolean; overload;
    procedure Sort;
    procedure CustomSort(Compare: TRLSortCompare);
    function IsSorted: boolean;
  end;

  TRecordsList = class(TCustomRecList)
  public
    property FieldValue;
    property FieldsCount;
    property RecordValue;
    property SortOptions;
    property SortOrder;
    property OnCompareValues;
    function Add(const A: array of string): integer;
    function Insert(const A: array of string; ARecord: integer): integer;
    function Edit(const A: array of string; ARecord: integer): integer;
    procedure Delete(ARecord: Integer);
    procedure Clear; override;
    procedure SetSortKey(AFields: array of integer);
    function FindKey(const A: array of string; var ARecord: Integer; Options: TRLLocateOptions): Boolean;
  end;

const
   RL_DEFAULTDATE = -693593.0; // "01/01/0001"

function RLCompareTextAccentInsensitive(const S1, S2: string): Integer;
function RLCompareStrAccentInsensitive(const S1, S2: string): Integer;

implementation

const
  RL_FIELDSEPARATOR = #1;
  RL_ENDOFRECORD = #2;


resourcestring
  ERR_INVALIDRECORD =  'Index de record (%d) : non valide';
  ERR_NOSORTKEY = 'Aucune clé de tri n''a été définie';

procedure DBError(Message: string; Args: array of const);
begin
  raise exception.Create(Format(Message, Args));
end;

function RLCompareTextAccentInsensitive(const S1, S2: string): Integer;
// compare 2 strings sans tenir compte de la casse ni des accents
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE or NORM_IGNORENONSPACE,
            PChar(S1), Length(S1), PChar(S2), Length(S2)) - 2;
end;

function RLCompareStrAccentInsensitive(const S1, S2: string): Integer;
// compare 2 strings sans tenir compte des accents mais avec distinction Min-Maj
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORENONSPACE, PChar(S1), Length(S1),
    PChar(S2), Length(S2)) - 2;
end;



{ ------------------------------------------------------------------
                            TCustomRecList
  ------------------------------------------------------------------}

constructor TCustomRecList.Create;
begin
  inherited Create;
  FSortOrder:= soAscending;
  FSortOptions:= [loNoCaseSensitive];
end;

destructor TCustomRecList.Destroy;
begin
  DoClear;
  SetLength(FArraySortKey,0);
  inherited Destroy;
end;

function TCustomRecList.InternalAdd(const S: string): integer;
var
  PToRec: pString;
begin
  New(PToRec);
  PToRec^:= S;
  Result:= inherited Add(PToRec);
end;

function TCustomRecList.Add(const A: array of string): integer;
var
  ARecord: integer;
begin
  if IsSorted then
  begin
     DoFindKey(A, ARecord, FSortOptions);
     Result:= InternalInsert(SetRecord(A), ARecord);
  end
  else
     Result:= InternalAdd(SetRecord(A));
end;

function TCustomRecList.InternalInsert(const S: string; ARecord: integer): integer;
var
  PToRec: pString;
begin
  if ARecord < 0 then ARecord:= 0
     else if ARecord > Count then ARecord:= Count;
  New(PToRec);
  PToRec^:= S;
  inherited Insert(ARecord, PToRec);
  Result:= ARecord;
end;

function TCustomRecList.Insert(const A: array of string; ARecord: integer): integer;
begin
  if IsSorted then DoFindKey(A, ARecord, FSortOptions);
  Result:= InternalInsert(SetRecord(A), ARecord);
end;

procedure TCustomRecList.InternalEdit(const S: string; ARecord: integer);
var
  PToRec: pString;
begin
  PToRec:= Items[ARecord];
  PToRec^:= S;
end;

function TCustomRecList.Edit(const A: array of string; ARecord: integer): integer;
var
  I: integer;
  MustDelete: boolean;
begin
  if (ARecord < 0) or (ARecord >= Count) then DBError(ERR_INVALIDRECORD, [ARecord]);
  Result:= ARecord;
  MustDelete:= false;
  for I:= 0 to High(FArraySortKey) do
     if A[FArraySortKey[I]] <> GetFieldValue(FArraySortKey[I], ARecord) then
     begin
        MustDelete:= true;
        Break;
     end;
  if MustDelete then
  begin
     Delete(ARecord);
     Result:= Insert(A, 0);
  end
  else
     InternalEdit(SetRecord(A), ARecord);
end;

procedure TCustomRecList.Delete(ARecord: Integer);
var
  PToRec: pString;
begin
  if (ARecord < 0) or (ARecord >= Count) then DBError(ERR_INVALIDRECORD, [ARecord]);
  PToRec := Items[ARecord];
  Dispose(PToRec);
  inherited Delete(ARecord);
end;

procedure TCustomRecList.DoClear;
var
  I: integer;
begin
  for I:= Count - 1 downto 0 do Delete(I);
  inherited Clear;
end;

function TCustomRecList.GetRecord(ARecord: integer): string;
var
  PToRec: pString;
begin
  if (ARecord < 0) or (ARecord >= Count) then DBError(ERR_INVALIDRECORD, [ARecord]);
  PToRec:= Items[ARecord];
  Result:= PToRec^;
end;

function TCustomRecList.SetRecord(const A: array of string): string;
var
  I: integer;
begin
  Result:= '';
  for I:= 0 to High(A) do
     Result:= Result + A[I] + RL_FIELDSEPARATOR;
end;

function TCustomRecList.SearchFieldValue(AField: integer; S: string): string;
var
  P1, P2, C: integer;
begin
  Result:= '';
  P1:= Pos(RL_FIELDSEPARATOR, S);
  if P1 = 0 then Exit;
  if AField = 0 then Result:= Copy(S, 1, P1 - 1)
  else
  begin
     C:= 1;
     while C < AField do
     begin
        P1:= PosEx(RL_FIELDSEPARATOR, S, P1 + 1);
        if P1 > 0 then Inc(C) else Exit;
     end;
     P2:= PosEx(RL_FIELDSEPARATOR, S, P1 + 1);
     if P2 > 0 then Result:= Copy(S, P1 + 1, P2 - P1 - 1);
  end;
end;

function TCustomRecList.GetFieldValue(AField: integer; ARecord: integer): string;
begin
  Result:= SearchFieldValue(AField, GetRecord(ARecord));
end;

function TCustomRecList.GetFieldsCount(ARecord: integer): integer;
{renvoie le nombre de champs d'un record}
var
  P: integer;
  S: string;
begin
  Result:= 0;
  S:= GetRecord(ARecord);
  P:= 1;
  while P > 0 do
  begin
     P:= PosEx(RL_FIELDSEPARATOR, S, P);
     if P > 0 then
     begin
       Inc(Result);
       Inc(P);
     end;
  end;
end;

function TCustomRecList.CompareValues(AValue1, AValue2: string; AOptions: TRLLocateOptions): integer;
begin
  if loPartialKey in AOptions then
     AValue2:= LeftStr(AValue2, Length(AValue1));
  if loNoCaseSensitive in AOptions then
  begin
     if loNoAccentSensitive in AOptions then Result:= RLCompareTextAccentInsensitive(AValue1, AValue2)
       else Result:= AnsiCompareText(AValue1, AValue2);
  end
  else
     if loNoAccentSensitive in AOptions then Result:= RLCompareStrAccentInsensitive(AValue1, AValue2)
       else Result:= AnsiCompareStr(AValue1, AValue2);
end;

function TCustomRecList.InternalCompareValues( const AValue1, AValue2: string; AField: integer; AOptions: TRLLocateOptions): integer;
var
  ADefault: boolean;
begin
  Result:= 0;
  ADefault:= true;
  if Assigned(FOnCompareValues) then
     Result:= FOnCompareValues(AValue1, AValue2, AField, AOptions, ADefault);
  if ADefault then Result:= CompareValues(AValue1, AValue2, AOptions);
  if FSortOrder = soDescending then Result:= - Result;
end;

function TCustomRecList.Locate(const A: array of string; var ARecord: integer; Options: TRLLocateOptions; Start: integer = 0): boolean;
{ Les valeurs de A doivent être dans l'ordre des champs.
  Pour ne pas tenir compte de la valeur d'un champ, assigner Alt+124 à A[n].
  Si Options = [], la recherche se fait sur la correspondance exacte (casse et accents).
  Si valeur trouvée, Locate renvoie true et ARecord contient l'index de l'enregistrement}
var
  R, F: integer;
begin
  Result:= false;
  ARecord:= -1;
  if (Start < 0) or (Start >= Count) then Exit;
  for R:= Start to Count - 1 do
  begin
     for F:= 0 to High(A) do
     begin
        if A[F] <> '|' then
        begin
          Result:= (CompareValues(A[F], GetFieldValue(F, R), Options) = 0);
          if not Result then Break;
        end;
     end;
     if Result then
     begin
        ARecord:= R;
        Exit;
     end;
  end;
end;

function TCustomRecList.Locate(const AValues: array of string; const AFields: array of integer; var ARecord: integer; Options: TRLLocateOptions; Start: integer = 0): boolean;
{ AFields = index des champs
  AValues = valeur à rechercher pour les champs
  exemple: Locate(['Dupond', 'Jean'], [0,1], ...) : recherche de "Dupond" dans champ 0
     et de "Jean" dans champ 1.
  AValues et AFields doivent avoir le même nombre d'éléments.
  Si Options = [], la recherche se fait sur la correspondance exacte (casse et accents).
  Si trouvé, la fonction renvoie true et l'index du record dans ARecord}
var
  R, F: integer;
begin
  Result:= false;
  ARecord:= -1;
  if (Start < 0) or (Start >= Count) then Exit;
  if Length(AValues) <> Length(AFields) then Exit;
  for R:= Start to Count - 1 do
  begin
     for F:= 0 to High(AFields) do
     begin
        Result:= (CompareValues(AValues[F], GetFieldValue(AFields[F], R), Options) = 0);
        if not Result then Break;
     end;
     if Result then
     begin
        ARecord:= R;
        Exit;
     end;
  end;
end;

procedure TCustomRecList.SetSortKey(AFields: array of integer);
var
  I: integer;
begin
  SetLength(FArraySortKey, Length(AFields));
  for I:= 0 to High(AFields) do
     FArraySortKey[I]:= AFields[I];
end;

function TCustomRecList.IsSorted: boolean;
begin
  Result:= (Length(FArraySortKey) > 0);
end;

function TCustomRecList.DoFindKey(const A: array of string; var ARecord: Integer; Options: TRLLocateOptions): Boolean;
var
  L, H, I, C: integer;
  CF, N: integer;
begin
  Result := False;
  ARecord:= -1;
  if not IsSorted then DBError(ERR_NOSORTKEY, []); // DoFindKey ne peut être utilisée que sur une table triée
  if Length(A) < Length(FArraySortKey) then
     CF:= Length(A)
    else CF:= Length(FArraySortKey);
  L := 0;
  H := Count - 1;
  C:= 0;
  while L <= H do
  begin
     I := (L + H) shr 1;
     for N:= 0 to CF - 1 do
     begin
        C:= InternalCompareValues(A[FArraySortKey[N]], FieldValue[FArraySortKey[N], I],
                                  FArraySortKey[N], Options);
        if C <> 0 then Break;
     end;
     if C > 0 then L := I + 1 else
     begin
        H := I - 1;
        if C = 0 then Result:= true;
     end;
  end;
  ARecord:= L;
end;

function TCustomRecList.InternalSCompare(Index1, Index2: Integer): Integer;
var
  N: integer;
begin
  Result:= 0;
  for N:= 0 to High(FArraySortKey) do
  begin
     Result:= InternalCompareValues(GetFieldValue(FArraySortKey[N], Index1),
                                    GetFieldValue(FArraySortKey[N], Index2),
                                    FArraySortKey[N], FSortOptions);
     if Result <> 0 then Break;
  end;
end;

procedure TCustomRecList.QuickSort(L, R: Integer; SCompare: TRLSortCompare);
var
  I, J, P: integer;
begin
  repeat
     I := L;
     J := R;
     P := (L + R) shr 1;
     repeat
        while SCompare(I, P) < 0 do Inc(I);
        while SCompare(J, P) > 0 do Dec(J);
        if I <= J then
        begin
           Exchange(I, J);
           if P = I then P := J
             else if P = J then P := I;
           Inc(I);
           Dec(J);
        end;
     until I > J;
     if L < J then QuickSort(L, J, SCompare);
     L := I;
  until I >= R;
end;

procedure TCustomRecList.Sort;
begin
  if Count > 0 then
     QuickSort(0, Count - 1, InternalSCompare);
end;

procedure TCustomRecList.CustomSort(Compare: TRLSortCompare);
begin
   if Count > 0 then
     QuickSort(0, Count - 1, Compare);
end;

procedure TCustomRecList.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCustomRecList.SaveToStream(Stream: TStream);
var
  S: string;
begin
  S := GetTextStr;
  Stream.WriteBuffer(Pointer(S)^, Length(S));
end;

procedure TCustomRecList.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCustomRecList.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  S: string;
begin
   Size := Stream.Size - Stream.Position;
   SetString(S, nil, Size);
   Stream.Read(Pointer(S)^, Size);
   SetTextStr(S);
end;

function TCustomRecList.GetTextStr: string;
{fonction de TStrings adaptée}
var
  I, L, Size: Integer;
  P: PChar;
  S: string;
begin
  Size := 0;
  for I := 0 to Count - 1 do Inc(Size, Length(GetRecord(I)) + 1);
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to Count - 1 do
  begin
    S := GetRecord(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L);
      Inc(P, L);
    end;
    P^ := RL_ENDOFRECORD;
    Inc(P);
  end;
end;

procedure TCustomRecList.SetTextStr(const Value: string);
{fonction de TStrings adaptée}
var
  P, Start: PChar;
  S: string;
begin
   DoClear;
   P := Pointer(Value);
   if P <> nil then
      while P^ <> #0 do
      begin
        Start := P;
        while not (P^ in [#0, RL_ENDOFRECORD]) do Inc(P);
        SetString(S, Start, P - Start);
        InternalAdd(S);
        if P^ = RL_ENDOFRECORD then Inc(P);
      end;
end;

function TRecordsList.Add(const A: array of string): integer;
begin
   Result:= inherited Add(A);
end;

function TRecordsList.Insert(const A: array of string; ARecord: integer): integer;
begin
   Result:= inherited Insert(A, ARecord);
end;

function TRecordsList.Edit(const A: array of string; ARecord: integer): integer;
begin
   Result:= inherited Edit(A, ARecord);
end;

procedure TRecordsList.Delete(ARecord: Integer);
begin
  inherited Delete(ARecord);
end;

procedure TRecordsList.Clear;
begin
  inherited DoClear;
end;

procedure TRecordsList.SetSortKey(AFields: array of integer);
begin
  inherited SetSortKey(AFields);
end;

function TRecordsList.FindKey(const A: array of string; var ARecord: Integer; Options: TRLLocateOptions): Boolean;
begin
  Result:= inherited DoFindKey(A, ARecord, Options);
end;


end.
