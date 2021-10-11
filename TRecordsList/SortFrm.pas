unit SortFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, RecList;

type
  TSortForm = class(TForm)
    ListBox1: TListBox;
    ListBox2: TListBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    OkBtn: TButton;
    CancelBtn: TButton;
    Label3: TLabel;
    CBSortOrder: TCheckBox;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  SortForm: TSortForm;

implementation

{$R *.dfm}

uses Mainfrm;

procedure TSortForm.SpeedButton1Click(Sender: TObject);
begin
  with ListBox1 do
    if (ItemIndex >= 0) and (ListBox2.Items.IndexOf(Items[ItemIndex]) < 0) then
     ListBox2.Items.Add(Items[ItemIndex]);
end;

procedure TSortForm.SpeedButton2Click(Sender: TObject);
begin
   with ListBox2 do
     if ItemIndex >= 0 then Items.Delete(ItemIndex);
end;

procedure TSortForm.OkBtnClick(Sender: TObject);
var
  A: array of integer;
  I: integer;
begin
  if ListBox2.Count = 0 then List.SetSortKey([])
  else
  begin
    SetLength(A, ListBox2.Count);
    for I:= 0 to High(A) do
      A[I]:= StrToInt(Copy(ListBox2.Items[I],1,1));
    List.SetSortKey(A);
    if CBSortOrder.Checked then List.SortOrder:= soDescending
       else List.SortOrder:= soAscending;
    SetLength(A,0);
    List.Sort;
    MainForm.UpdateGrid(-1);
  end;
  Close;
end;

end.
