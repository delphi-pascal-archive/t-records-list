object MainForm: TMainForm
  Left = 212
  Top = 130
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'TRecordsList'
  ClientHeight = 593
  ClientWidth = 793
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 408
    Top = 8
    Width = 29
    Height = 16
    Caption = 'Title:'
  end
  object Label2: TLabel
    Left = 408
    Top = 64
    Width = 92
    Height = 16
    Caption = 'Code (number):'
  end
  object Label3: TLabel
    Left = 408
    Top = 120
    Width = 32
    Height = 16
    Caption = 'Date:'
  end
  object Label4: TLabel
    Left = 568
    Top = 64
    Width = 67
    Height = 16
    Caption = 'Comments:'
  end
  object LabelFilter: TLabel
    Left = 8
    Top = 8
    Width = 94
    Height = 16
    Caption = 'Filter inactive'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object StringGrid1: TStringGrid
    Left = 8
    Top = 32
    Width = 393
    Height = 555
    ColCount = 4
    Ctl3D = False
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
    ParentCtl3D = False
    TabOrder = 0
    OnSelectCell = StringGrid1SelectCell
    ColWidths = (
      57
      161
      66
      76)
  end
  object EditTitre: TEdit
    Left = 408
    Top = 32
    Width = 377
    Height = 25
    TabOrder = 1
  end
  object EditCode: TEdit
    Left = 408
    Top = 88
    Width = 153
    Height = 25
    TabOrder = 2
    Text = '0'
  end
  object EditDate: TEdit
    Left = 408
    Top = 144
    Width = 153
    Height = 25
    TabOrder = 3
  end
  object Checkbox1: TCheckBox
    Left = 408
    Top = 184
    Width = 81
    Height = 17
    Caption = 'Boolean'
    TabOrder = 4
  end
  object Memo1: TMemo
    Left = 568
    Top = 88
    Width = 217
    Height = 249
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 5
  end
  object AddBtn: TButton
    Left = 408
    Top = 216
    Width = 153
    Height = 25
    Caption = 'Add'
    TabOrder = 6
    OnClick = AddBtnClick
  end
  object EditBtn: TButton
    Left = 408
    Top = 248
    Width = 153
    Height = 25
    Caption = 'Edit'
    TabOrder = 7
    OnClick = EditBtnClick
  end
  object DeleteBtn: TButton
    Left = 408
    Top = 280
    Width = 153
    Height = 25
    Caption = 'Delete'
    TabOrder = 8
    OnClick = DeleteBtnClick
  end
  object GroupBox1: TGroupBox
    Left = 408
    Top = 344
    Width = 377
    Height = 243
    Caption = ' Filter '
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 9
    object Label5: TLabel
      Left = 40
      Top = 24
      Width = 26
      Height = 16
      Caption = 'Title'
    end
    object Label6: TLabel
      Left = 40
      Top = 80
      Width = 33
      Height = 16
      Caption = 'Code'
    end
    object Label7: TLabel
      Left = 40
      Top = 136
      Width = 29
      Height = 16
      Caption = 'Date'
    end
    object EditFilterTitre: TEdit
      Left = 39
      Top = 48
      Width = 154
      Height = 25
      TabOrder = 0
    end
    object EditFilterCode: TEdit
      Left = 40
      Top = 104
      Width = 153
      Height = 25
      TabOrder = 1
    end
    object EditFilterDate: TEdit
      Left = 40
      Top = 160
      Width = 153
      Height = 25
      TabOrder = 2
    end
    object CBFilter1: TCheckBox
      Left = 208
      Top = 72
      Width = 89
      Height = 17
      Caption = 'PartialKey'
      TabOrder = 3
    end
    object CBFilter2: TCheckBox
      Left = 208
      Top = 104
      Width = 128
      Height = 17
      Caption = 'NoCaseSensitive'
      TabOrder = 4
    end
    object CBFilter3: TCheckBox
      Left = 208
      Top = 136
      Width = 138
      Height = 17
      Caption = 'NoAccentSensitive'
      TabOrder = 5
    end
    object FilterBtn: TButton
      Left = 208
      Top = 200
      Width = 153
      Height = 25
      Caption = 'OK'
      TabOrder = 6
      OnClick = FilterBtnClick
    end
    object FilterOutBtn: TButton
      Left = 16
      Top = 200
      Width = 185
      Height = 26
      Caption = 'Cancel filter'
      TabOrder = 7
      OnClick = FilterOutBtnClick
    end
    object CBFilterTitre: TCheckBox
      Left = 16
      Top = 48
      Width = 17
      Height = 17
      TabOrder = 8
    end
    object CBFilterCode: TCheckBox
      Left = 16
      Top = 104
      Width = 17
      Height = 17
      TabOrder = 9
    end
    object CBFilterDate: TCheckBox
      Left = 16
      Top = 160
      Width = 17
      Height = 17
      TabOrder = 10
    end
  end
  object KeySortBtn: TButton
    Left = 408
    Top = 312
    Width = 153
    Height = 25
    Caption = 'Sort by ...'
    TabOrder = 10
    OnClick = KeySortBtnClick
  end
end
