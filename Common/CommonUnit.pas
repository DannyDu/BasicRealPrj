unit CommonUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, EncdDecd;

const
  WM_POSTITEMDATE = WM_USER + 100;
  WM_POSTSTRING = WM_POSTITEMDATE + 1;

type
  PItemData = ^ItemData;

  ItemData = record
    ItemID: Cardinal;
    ItemCode: array[0..255] of Char;
    ItemName: array[0..255] of Char;
  end;

function GetIdeNum: string;
function Base64ToFile(const str, fn: string): string;
function FileToBase64(fn: string): string;

implementation

function GetIdeNum: string;
type
  TSrbIoControl = packed record
    HeaderLength: ULONG;
    Signature: array[0..7] of Char;
    Timeout: ULONG;
    ControlCode: ULONG;
    ReturnCode: ULONG;
    Length: ULONG;
  end;

  SRB_IO_CONTROL = TSrbIoControl;

  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    bFeaturesReg: Byte;
    bSectorCountReg: Byte;
    bSectorNumberReg: Byte;
    bCylLowReg: Byte;
    bCylHighReg: Byte;
    bDriveHeadReg: Byte;
    bCommandReg: Byte;
    bReserved: Byte;
  end;

  IDEREGS = TIDERegs;

  PIDERegs = ^TIDERegs;

  TSendCmdInParams = packed record
    cBufferSize: DWORD;
    irDriveRegs: TIDERegs;
    bDriveNumber: Byte;
    bReserved: array[0..2] of Byte;
    dwReserved: array[0..3] of DWORD;
    bBuffer: array[0..0] of Byte;
  end;

  SENDCMDINPARAMS = TSendCmdInParams;

  PSendCmdInParams = ^TSendCmdInParams;

  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of Char;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: array[0..7] of Char;
    sModelNumber: array[0..39] of Char;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: ULONG;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: ULONG;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: array[0..127] of Byte;
  end;

  PIdSector = ^TIdSector;
const
  IDE_ID_FUNCTION = $EC;
  IDENTIFY_BUFFER_SIZE = 512;
  DFP_RECEIVE_DRIVE_DATA = $0007c088;
  IOCTL_SCSI_MINIPORT = $0004d008;
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001b0501;
  DataSize = sizeof(TSendCmdInParams) - 1 + IDENTIFY_BUFFER_SIZE;
  BufferSize = SizeOf(SRB_IO_CONTROL) + DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE + 16;
var
  hDevice: THandle;
  cbBytesReturned: DWORD;
  pInData: PSendCmdInParams;
  pOutData: Pointer;
  Buffer: array[0..BufferSize - 1] of Byte;
  srbControl: TSrbIoControl absolute Buffer;

  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    ptr: PChar;
    i: Integer;
    c: Char;
  begin
    ptr := @Data;
    for i := 0 to (Size shr 1) - 1 do
    begin
      c := ptr^;
      ptr^ := (ptr + 1)^;
      (ptr + 1)^ := c;
      Inc(ptr, 2);
    end;
  end;

begin
  Result := '';
  FillChar(Buffer, BufferSize, #0);
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    hDevice := CreateFile('//./Scsi0:', GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    if hDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      srbControl.HeaderLength := SizeOf(SRB_IO_CONTROL);
      System.Move('SCSIDISK', srbControl.Signature, 8);
      srbControl.Timeout := 2;
      srbControl.Length := DataSize;
      srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
      pInData := PSendCmdInParams(PChar(@Buffer) + SizeOf(SRB_IO_CONTROL));
      pOutData := pInData;
      with pInData^ do
      begin
        cBufferSize := IDENTIFY_BUFFER_SIZE;
        bDriveNumber := 0;
        with irDriveRegs do
        begin
          bFeaturesReg := 0;
          bSectorCountReg := 1;
          bSectorNumberReg := 1;
          bCylLowReg := 0;
          bCylHighReg := 0;
          bDriveHeadReg := $A0;
          bCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(hDevice, IOCTL_SCSI_MINIPORT, @Buffer, BufferSize, @Buffer, BufferSize, cbBytesReturned, nil) then
        Exit;
    finally
      CloseHandle(hDevice);
    end;
  end
  else
  begin
    hDevice := CreateFile('//./SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
    if hDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      pInData := PSendCmdInParams(@Buffer);
      pOutData := @pInData^.bBuffer;
      with pInData^ do
      begin
        cBufferSize := IDENTIFY_BUFFER_SIZE;
        bDriveNumber := 0;
        with irDriveRegs do
        begin
          bFeaturesReg := 0;
          bSectorCountReg := 1;
          bSectorNumberReg := 1;
          bCylLowReg := 0;
          bCylHighReg := 0;
          bDriveHeadReg := $A0;
          bCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(hDevice, DFP_RECEIVE_DRIVE_DATA, pInData, SizeOf(TSendCmdInParams) - 1, pOutData, W9xBufferSize, cbBytesReturned, nil) then
        Exit;
    finally
      CloseHandle(hDevice);
    end;
  end;
  with PIdSector(PChar(pOutData) + 16)^ do
  begin
    ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber));
    SetString(Result, sSerialNumber, SizeOf(sSerialNumber));
  end;
  Result := Trim(Result);
end;

function FileToBase64(fn: string): string;
var
  mm: TMemoryStream;
  sf: TStringStream;
begin
  try
    try
      mm := TMemoryStream.Create;
      try
        sf := TStringStream.Create('');
        mm.LoadFromFile(fn);
        EncdDecd.EncodeStream(mm, sf);                       // 将m1的内容Base64到m2中
        Result := sf.DataString;

      finally
        sf.Free;
      end;
    finally
      mm.Free;
    end;
  except
    on e: Exception do
    begin
      OutputDebugString(PChar('FileToBase64->Error: ' + e.Message));
    end;
  end;
end;

function Base64ToFile(const str, fn: string): string;
var
  mm: TMemoryStream;
  sf: TStringStream;
begin
  try
    try
      mm := TMemoryStream.Create;
      try
        sf := TStringStream.Create(str);

        EncdDecd.DecodeStream(sf, mm);                       // 将m1的内容Base64到m2中
        mm.SaveToFile(fn);
      finally
        sf.Free;
      end;
    finally
      mm.Free;
    end;
  except
    on e: Exception do
    begin
      OutputDebugString(PChar('FileToBase64->Error: ' + e.Message));
    end;
  end;
end;

end.

