object MainFrm: TMainFrm
  Left = 192
  Top = 130
  Width = 928
  Height = 480
  Caption = #23454#29616#39033#30446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mm1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object mm1: TMainMenu
    Left = 344
    Top = 128
    object MenuFile: TMenuItem
      Caption = #25991#20214'(&F)'
      object MenuQuit: TMenuItem
        Caption = #36864#20986'(&Q)'
      end
    end
    object MenuItem: TMenuItem
      Caption = #39033#30446
      object MenuDiskSN: TMenuItem
        Caption = #30828#30424'SN'
        OnClick = MenuDiskSNClick
      end
    end
  end
end
