
{***************************************************}
{                                                   }
{        L e c a r                                  }
{   Turbo Pascal 6.X,7.X                            }
{   Попросту, без чинов и Copyright-ов  1991,92,93  }
{   Версия 2.0 от ...... (нужное дописать)          }
{***************************************************}

{$A+,B-,D+,E-,F-,I-,L+,N-,O-,R-,S+,V+,X+,G-}
{$M 16384,0,655360}

Unit DVir;

Interface

Uses
  Dos,
  Common;

Type
  PStoneVirus = ^TStoneVirus;
  TStoneVirus = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PGenericVirus = ^TGenericVirus;
  TGenericVirus = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PSexRevolution = ^TSexRevolution;
  TSexRevolution = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PDenZuk = ^TDenZuk;
  TDenZuk = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PRostov = ^TRostov;
  TRostov = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PMarch6Virus = ^TMarch6Virus;
  TMarch6Virus = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PPFlipVirus = ^TPFlipVirus;
  TPFlipVirus = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PBallVirus = ^TBallVirus;
  TBallVirus = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PMisspelVirus = ^TMisspelVirus;
  TMisspelVirus = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;
  PDHercenVirus = ^TDHercenVirus;
  TDHercenVirus = Object(TDiskVirus)
    procedure Kill; Virtual;
  End;


Implementation

procedure TStoneVirus.Kill;
begin
  StoneLikeKill(0,0,7,0,1,3);
end;

procedure TMarch6Virus.Kill;
begin
  StoneLikeKill(0,0,7,0,1,3);
end;


procedure TGenericVirus.Kill;
begin
  case Carier of
    Hard   : begin
               ErrorInfo := AbsRead(Drive, 0, 0, 13, 1, Buff);
               ErrorInfo := AbsWrite(Drive, 0, 0, 1, 1, Buff) or ErrorInfo;
             end;
    Floppy : begin
      ErrorInfo := AbsRead(Drive, 0, 0, 1, 1, Buff);
      ErrorInfo := AbsRead(Drive, Buff[05], Buff[06], Buff[04], 1, Buff);
      ErrorInfo := AbsWrite(Drive, 0, 0, 1, 1, Buff) or ErrorInfo;
    end;
    CDROM : ErrorInfo := $FF;
    else ErrorInfo := $FF;
  end;
end;

procedure TSexRevolution.Kill;
begin
  StoneLikeKill(0,0,8,0,1,3);
end;

procedure TDenZuk.Kill;
begin
  case Carier of
    Hard   : ErrorInfo := $FF; { Только на флоппах живет  }
    Floppy : begin
      ErrorInfo := AbsRead(Drive, 0, $28, $21, 1, Buff);
      ErrorInfo := AbsWrite(Drive, 0, 0, 1, 1, Buff) Or ErrorInfo;
      FillChar(Buff, SizeOf(Buff), #0);
      ErrorInfo := ErrorInfo Or AbsWrite(Drive, 0, 1, 3, 1, Buff);
    end;
    CDROM : ErrorInfo := $FF;
    else ErrorInfo := $FF;
  end;
end;

procedure TRostov.Kill;
begin
  StoneLikeKill(0,0,2,0,1,3);
end;

procedure TPFlipVirus.Kill;
var
  Regs : Registers;
begin
  case Carier of
    Hard   : begin
               ErrorInfo := AbsRead(Drive ,0,0,1,1,Buff);
               with Regs do begin
                 CH := Buff[$2B];
                 CL := Buff[$2A];
                 DH := Buff[$2D];
                 DL := Buff[$2C];
               end;
               ErrorInfo :=  AbsRead (Drive , Regs.DH, Regs.CH,Regs.CL,1, Buff) or ErrorInfo;
               If (Buff[510]=$55) AND (Buff[511]=$AA) then
                  ErrorInfo :=  AbsWrite (Drive , 0, 0, 1,1, Buff) or ErrorInfo;
{
               ErrorInfo := AbsRead(Drive, 0, 0, 13, 1, Buff);
               ErrorInfo := AbsWrite(Drive, 0, 0, 1, 1, Buff) or ErrorInfo;
}
             end;
    Floppy : ErrorInfo := $FF;
    CDROM  : ErrorInfo := $FF;
    else ErrorInfo := $FF;
  end;
end;

procedure TBallVirus.Kill;
begin
  ErrorInfo := DiskRead(LogDrive,0,1,Buff);
  ErrorInfo := DiskRead(LogDrive,((Buff[$1FA] Shl 4)+Buff[$1F9]+1),1,Buff) or ErrorInfo;
  ErrorInfo := DiskWrite(LogDrive,0,1,Buff) or ErrorInfo;
end;

procedure TMisspelVirus.Kill;
begin
  ErrorInfo := DiskRead(LogDrive,0,1,Buff);
  ErrorInfo := DiskRead(LogDrive,((Buff[$1F8] Shl 4)+Buff[$1F7]+1),1,Buff) or ErrorInfo;
  ErrorInfo := DiskWrite(LogDrive,0,1,Buff) or ErrorInfo;
end;

procedure TDHercenVirus.Kill;
var
  Regs : Registers;
begin
  ErrorInfo :=  DiskRead(LogDrive, 0, 1, Buff);
  With Regs do begin
    CH := $2;
    AX := (Word(Buff[$1FA]) Shl 8) + Buff[$1F9];
    DX := AX MOD (Word(Buff[$19]) Shl 8+Buff[$18]);
    AX := AX DIV (Word(Buff[$19]) Shl 8+Buff[$18]);
    Inc(DL);
    BX := DX;
    DX := AX MOD (Word(Buff[$1B]) Shl 8+Buff[$1A]);
    AX := AX DIV (Word(Buff[$1B]) Shl 8+Buff[$1A]);
    CH := AL;
    CL := $6;
    AH := AH Shl CL;
    CL := AH;
    DH := BL;
    CL := CL OR DH;
    DH := DL;
  end;
  ErrorInfo := AbsRead (Drive , Regs.DH, Regs.CH,Regs.CL,1, Buff) or ErrorInfo;
  ErrorInfo := DiskWrite(LogDrive, 0, 1, Buff) or ErrorInfo;
end;

End.
