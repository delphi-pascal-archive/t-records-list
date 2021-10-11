object SortForm: TSortForm
  Left = 305
  Top = 297
  BorderStyle = bsDialog
  Caption = 'Tri'
  ClientHeight = 279
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 120
  TextHeight = 16
  object SpeedButton1: TSpeedButton
    Left = 176
    Top = 80
    Width = 33
    Height = 33
    Hint = 'Ajouter le champ selectionne'
    Caption = '--->'
    ParentShowHint = False
    ShowHint = True
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 176
    Top = 144
    Width = 33
    Height = 33
    Hint = 'Enlever le champ selectionne'
    Caption = '<---'
    ParentShowHint = False
    ShowHint = True
    OnClick = SpeedButton2Click
  end
  object Label1: TLabel
    Left = 8
    Top = 32
    Width = 53
    Height = 16
    Caption = 'Champs:'
  end
  object Label2: TLabel
    Left = 216
    Top = 32
    Width = 30
    Height = 16
    Caption = 'Cles:'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 277
    Height = 16
    Caption = 'Choisissez le ou les champs dans l'#39'ordre du tri.'
  end
  object ListBox1: TListBox
    Left = 8
    Top = 56
    Width = 161
    Height = 145
    Style = lbOwnerDrawFixed
    ItemHeight = 16
    Items.Strings = (
      '0 TITRE'
      '1 CODE'
      '2 DATE'
      '3 BOOLEAN'
      '4 COMMENTAIRE')
    TabOrder = 0
  end
  object ListBox2: TListBox
    Left = 216
    Top = 56
    Width = 161
    Height = 145
    Style = lbOwnerDrawFixed
    ItemHeight = 16
    Items.Strings = (
      '0 TITRE'
      '1 CODE')
    TabOrder = 1
  end
  object OkBtn: TButton
    Left = 192
    Top = 240
    Width = 105
    Height = 27
    Caption = 'Ok'
    TabOrder = 2
    OnClick = OkBtnClick
  end
  object CancelBtn: TButton
    Left = 80
    Top = 240
    Width = 105
    Height = 27
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object CBSortOrder: TCheckBox
    Left = 80
    Top = 208
    Width = 201
    Height = 17
    Caption = 'Trier dans l'#39'ordre decroissant'
    TabOrder = 4
  end
end
