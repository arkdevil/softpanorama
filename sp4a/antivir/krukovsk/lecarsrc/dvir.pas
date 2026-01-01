{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 6.X                             }
{   Попросту, без чинов и Copyright-ов  1992     }
{   Версия 2.0 от                                }
{************************************************}

{$A+,B-,D+,E-,F-,I-,L+,N-,O-,R+,S+,V+,X+,G-}
{$M 16384,0,655360}

Unit DVir;

Interface

Uses
  Disk,
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

Implementation

procedure TStoneVirus.Kill;
begin
  case Carier of
    Hard   : begin
               ErrorInfo := AbsRead(Drive, 0, 0, 7, 1, Buff);
               ErrorInfo := AbsWrite(Drive, 0, 0, 1, 1, Buff) Or ErrorInfo;
             end;
    Floppy : begin
      ErrorInfo := AbsRead(Drive, 0, 1, 3, 1, Buff);
      ErrorInfo := AbsWrite(Drive, 0, 0, 1, 1, Buff) Or ErrorInfo;
      FillChar(Buff, SizeOf(Buff), #0);
      ErrorInfo := ErrorInfo Or AbsWrite(Drive, 0, 1, 3, 1, Buff);
    end;
    CDROM : ErrorInfo := $FF;
    else ErrorInfo := $FF;
  end;
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

End.