unit ThreadCommonUnit;

interface

uses
  Classes {$IFDEF MSWINDOWS} , Windows {$ENDIF}
    , Messages, SysUtils, Variants, Graphics, Controls, Forms, Dialogs,
    CommonUnit;

type
  ThreadCommon = class(TThread)
  private
    procedure SetName;
  protected
    procedure Execute; override;
  public
    destructor Destroy; override;
  end;

implementation

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure ThreadCommon.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{$IFDEF MSWINDOWS}
type
  TThreadNameInfo = record
    FType: LongWord;     // must be 0x1000
    FName: PChar;        // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord;    // reserved for future use, must be zero
  end;
{$ENDIF}

{ ThreadCommon }

procedure ThreadCommon.SetName;
{$IFDEF MSWINDOWS}
var
  ThreadNameInfo: TThreadNameInfo;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  ThreadNameInfo.FType := $1000;
  ThreadNameInfo.FName := 'Common_Thread';
  ThreadNameInfo.FThreadID := $FFFFFFFF;
  ThreadNameInfo.FFlags := 0;

  try
    RaiseException($406D1388, 0, sizeof(ThreadNameInfo) div sizeof(LongWord), @ThreadNameInfo);
  except
  end;
{$ENDIF}
end;

procedure ThreadCommon.Execute;
var
  Msg: TMsg;
  PD: PItemData;
  str, tmpstr: string;
  ps: PString;
begin
  SetName;
  { Place thread code here }
  while (not Terminated) do
  begin
    if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
    begin
      case Msg.message of
        WM_POSTITEMDATE:
          begin
            PD := PITEMDATA(Msg.wParam);
            str := StrPas(Pd^.ItemCode);
            tmpstr := StrPas(pd^.ItemName);
            str := Format('ID: %d Code: %s Name: %s', [PD^.ItemID, str, tmpstr]);
            OutputDebugString(PChar(Format('ID: %d Code: %s Name: %s', [PD^.ItemID, PD^.ItemCode, PD^.ItemName])));
            New(ps);
            ps^ := str;
            PostMessage(Application.MainForm.Handle, WM_POSTSTRING, Integer(ps), PD^.ItemID);
            Dispose(PD);
          end;
      end;
    end;
    Sleep(1);
  end;
end;

destructor ThreadCommon.Destroy;
begin
  inherited;
end;

end.

