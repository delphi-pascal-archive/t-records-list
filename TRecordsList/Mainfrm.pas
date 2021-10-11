unit Mainfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RecList, Grids, StdCtrls;

type
  TMainForm = class(TForm)
    StringGrid1: TStringGrid;
    EditTitre: TEdit;
    EditCode: TEdit;
    EditDate: TEdit;
    Checkbox1: TCheckBox;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    AddBtn: TButton;
    EditBtn: TButton;
    DeleteBtn: TButton;
    GroupBox1: TGroupBox;
    EditFilterTitre: TEdit;
    EditFilterCode: TEdit;
    EditFilterDate: TEdit;
    CBFilter1: TCheckBox;
    CBFilter2: TCheckBox;
    CBFilter3: TCheckBox;
    FilterBtn: TButton;
    FilterOutBtn: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    KeySortBtn: TButton;
    LabelFilter: TLabel;
    CBFilterTitre: TCheckBox;
    CBFilterCode: TCheckBox;
    CBFilterDate: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddBtnClick(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure EditBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure FilterBtnClick(Sender: TObject);
    procedure FilterOutBtnClick(Sender: TObject);
    procedure KeySortBtnClick(Sender: TObject);
  private
    { Déclarations privées }
    function ListCompareValues(AValue1, AValue2: string; AField: integer; AOptions: TRLLocateOptions; var ADefault: boolean): integer;
    function ReturnRecord(ARow: integer): integer;
    procedure VerifyEdits;
  public
    { Déclarations publiques }
    procedure UpdateGrid(ARecord: integer);
  end;

const
  F_TITRE = 0;
  F_CODE = 1;
  F_DATE = 2;
  F_BOOL = 3;
  F_COMMENT = 4;

var
  MainForm: TMainForm;
  List: TRecordsList;
  ListFileName: string;
  ListFiltered: boolean;
  FS: TFormatSettings;

implementation

uses SortFrm;

{$R *.dfm}

var
  LocateOptions: TRLLocateOptions;
  FilterTitre: string;
  FilterCode: string;
  FilterDate: string;


function GetBoolean(const S: string): boolean;
begin
  Result:= (S = '1');
end;

function SetBoolean(Value: boolean): string;
begin
  if Value then Result:= '1' else Result:= '0';
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
   {Titre des colonnes du Stringgrid1}
   with StringGrid1 do
   begin
     Cells[0,0]:= 'Record';
     Cells[1,0]:= 'Title';
     Cells[2,0]:= 'Code';
     Cells[3,0]:= 'Date';
   end;
   {création de la liste}
   List:= TRecordsList.Create;
   with List do
   begin
     SetSortKey([F_TITRE, F_CODE]);
     OnCompareValues:= ListCompareValues;
     if FileExists(ListFileName) then
       LoadFromFile(ListFileName);
     if Count > 1 then Sort;
   end;
   {mise à jour du stringgrid}
   UpdateGrid(-1);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   with List do
   begin
      SaveToFile(ListFileName);
      Free;
   end;
end;

function TMainForm.ListCompareValues(AValue1, AValue2: string; AField: integer; AOptions: TRLLocateOptions; var ADefault: boolean): integer;
var
  D: extended;
begin
   Result:= 0;
   case AField of
     F_CODE: begin
               Result:= StrToInt(AValue1) - StrToInt(AValue2);
               ADefault:= false;
             end;
     F_DATE: begin
               D:= StrToDate(AValue1) - StrToDate(AValue2);
               if D > 0.0 then Result:= 1
               else if D < 0.0 then Result:= -1
               else Result:= 0;
               ADefault:= false;
             end;
   end;
end;

function TMainForm.ReturnRecord(ARow: integer): integer;
begin
  try
     with StringGrid1 do Result:= StrToInt(Cells[0, ARow]);
  except
     Result:= -1;
  end;
end;

procedure TMainForm.VerifyEdits;
begin
   try
     EditCode.Text:= IntToStr(StrToInt(EditCode.Text));
     EditDate.Text:= DateTimeToStr(StrToDate(EditDate.Text), FS);
   except
     raise;
   end;
end;

procedure TMainForm.UpdateGrid(ARecord: integer);
var
  I, ARow: integer;
  First: boolean;
begin
  ARow:= -1;
  with StringGrid1 do
  begin
     RowCount:= 2;
     for I:= 0 to ColCount - 1 do Cells[I,1]:= '';
     First:= true;
     I:= 0;
     while I < List.Count do
     begin
        if ListFiltered then
        begin
           List.Locate([FilterTitre, FilterCode, FilterDate], I, LocateOptions, I);
           if I < 0 then Break;
        end;
        if First then First:= false
           else RowCount:= RowCount + 1;
        Cells[0, RowCount - 1]:= IntToStr(I);
        Cells[1, RowCount - 1]:= List.FieldValue[F_TITRE, I];
        Cells[2, RowCount - 1]:= List.FieldValue[F_CODE, I];
        Cells[3, RowCount - 1]:= List.FieldValue[F_DATE, I];
        if I = ARecord then ARow:= RowCount - 1;
        Inc(I);
     end;
     if (ARow > 0) and (ARow < RowCount) then Row:= ARow;
  end;
end;

procedure TMainForm.AddBtnClick(Sender: TObject);
var
  Rec: integer;
begin
   VerifyEdits;
   Rec:= List.Add([EditTitre.Text, EditCode.Text, EditDate.Text, SetBoolean(CheckBox1.Checked), Memo1.Text]);
   UpdateGrid(Rec);
end;

procedure TMainForm.StringGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  Rec: integer;
begin
   if List.Count = 0 then Exit;
   Rec:= ReturnRecord(ARow);
   with List do
   begin
     EditTitre.Text:= FieldValue[F_TITRE, Rec];
     EditCode.Text:=  FieldValue[F_CODE, Rec];
     EditDate.Text:= FieldValue[F_DATE, Rec];
     CheckBox1.Checked:= GetBoolean(FieldValue[F_BOOL, Rec]);
     Memo1.Text:= FieldValue[F_COMMENT, Rec];
   end;
end;

procedure TMainForm.EditBtnClick(Sender: TObject);
var
  Rec: integer;
begin
  VerifyEdits;
  Rec:= ReturnRecord(StringGrid1.Row);
  if Rec >= 0 then
  begin
     Rec:= List.Edit([EditTitre.Text, EditCode.Text, EditDate.Text, SetBoolean(CheckBox1.Checked), Memo1.Text], Rec);
     UpdateGrid(Rec);
  end
  else Beep;
end;

procedure TMainForm.DeleteBtnClick(Sender: TObject);
var
  Rec: integer;
begin
   Rec:= ReturnRecord(StringGrid1.Row);
   if Rec >= 0 then
   begin
     List.Delete(Rec);
     UpdateGrid(Rec-1);
   end
   else Beep;
end;

procedure TMainForm.FilterBtnClick(Sender: TObject);
begin
   if not(CBFilterTitre.Checked) then FilterTitre:= '|' else FilterTitre:= EditFilterTitre.Text;
   if not (CBFilterCode.Checked) then FilterCode:= '|' else FilterCode:= EditFilterCode.Text;
   if not(CBFilterDate.Checked) then FilterDate:= '|' else FilterDate:= EditFilterDate.Text;
   LocateOptions:= [];
   if CBFilter1.Checked then LocateOptions:= [loPartialKey];
   if CBFilter2.Checked then LocateOptions:= LocateOptions + [loNoCaseSensitive];
   if CBFilter3.Checked then LocateOptions:= LocateOptions + [loNoAccentSensitive];
   ListFiltered:= true;
   LabelFilter.Caption:='Filter active';
   UpdateGrid(-1);
end;

procedure TMainForm.FilterOutBtnClick(Sender: TObject);
begin
   ListFiltered:= false;
   UpdateGrid(-1);
   LabelFilter.Caption:='Filter inactive';
end;

procedure TMainForm.KeySortBtnClick(Sender: TObject);
begin
   SortForm.ShowModal;
end;

initialization
   FS.ShortDateFormat:= 'dd/mm/yyyy';
   FS.DateSeparator:= '/';
   ListFileName:= ExtractFilePath(Application.ExeName) + 'Test.txt';
   ListFiltered:= false;

end.
