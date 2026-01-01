{$A+,B-,E+,F-,I-,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit Ng;

Interface

Const ShortEntry = 0;
      LongEntry  = 1;
      NoEntry    = $ffff;

Type Str79   = String[79];
     Str84   = String[84];
     Str100  = String[100];
     Str160  = String[160];
     Str255  = String[255];
     StrPtr  = ^Str84;


{**********De Objecten*******************************************************}
     GuideMenuOBJ     = Object
      Count           : Word; {Aantal Pulldownmenus in dit Menu,Contructor}
      Title           : Str84;
      {********Pointers***************************}
      Entrys          : Array [1..10] of Longint;
      Lines           : Array [1..10] of StrPtr;
      {*******************************************}

      Procedure Load(L : Longint); {Laad menuEntry}
      Procedure Done;{voor straks Desctructor}
      Function Entry(Nr : Word) : Longint; {Zie MMEntry}
      Function Line(Nr : Word) : Str84;
     End; {GuideMenuOBJ}
{****************************************************************************}
     GuideShortOBJ    = Object
      Count           : Word; {Aantal regels, 0 als fout is opgetreden}
      Parent          : Longint; {Geeft ouders van ouder in short}
      Current         : Word; {Current Entry,Eigenlijk +1, Als Parent -1}
                              {dan Current 65536                        }
      MenuParent      : Word; {als Parent -1 dan is dit het Menu Nummer}
                              {Eerste Menu is 0}
      MenuLine        : Word; {Als Parent -1 Dan dit Regelnummer van menu}
                              {Eerste Regel is 0}
      {********Pointers***************************}
      Entrys          : Array [1..512] of Longint;
      Lines           : Array [1..512] of StrPtr;
      {*******************************************}

      Procedure Load(L : Longint); {laad een short entry}
      Procedure Done; {Voor later met destructor}
      Function Line(Nr : Word) : Str84;
      Function RawLine(Nr : Word) : Str84;
      Function Entry(Nr : Word) : Longint;
     End; {GuideShortOBJ}
{****************************************************************************}
     SeeAlsoOBJ        = Object
      Count            : Word;

      {********Pointers***************************}
      Entrys          : Array [1..21] of Longint;
      Lines           : Array [1..21] of StrPtr;
      {*******************************************}

      Procedure Done;
      Function Line(Nr : Word) : Str84;
      Function Entry(Nr : Word) : Longint;
     End; {SeeAlso}
{----------------------------------------------------------------------------}
     GuideLongOBJ     = Object
      SeeAlso         : SeeAlsoObj;
      Count           : Word; {Aantal Regels}
      Parent          : Longint; {Als -1 dan geen parent}
      Current         : Word; {Als 65535 dan geen Current}
      MenuParent      : Word; {Let op menu 4 = Menu 0}
      MenuLine        : Word; {Begint bij 0 net als boven}
      PrevEntry       : Longint; {-1 geen previous}
      NxtEntry        : Longint; {-1 geen next}

      {********Pointers***************************}
      Lines           : Array [1..512] of StrPtr;
      {*******************************************}

      Procedure Load(L : Longint);
      Procedure Done;
      Function Line(Nr : Word) : Str84;
      Function RawLine(Nr : Word) : Str84;
      Function Previous : Longint;
      Function Next : Longint;
     End; {GuideLongOBJ}



{**********Einde van de Objecten*********************************************}


Var GuideName : Str84;
    Menus     : Byte; {De aantal topmenus}

{**Algemeen voor NG**********************************************************}
Function  LookGuide(F : String) : String;
Function  OpenGuide(GuideFileName : Str79) : Boolean;
Procedure CloseGuide;
Function  Credit(Regel : Byte) : Str160;
Function  MenuEntry(Nr : Byte) : Longint;
Function  EntryType(L : Longint) : Word;
Function  GuideStrip(S : String) : String;
Function  FirstEntry : Longint;
{****************************************************************************}

Implementation

{Algemeen gebruikte variabelen}
{Geen object omdat NG.TPU Maar een NG file Open per keer aankan}
Var DecrypTabel  : Array [0..255] of Byte;
    Guide        : File; {File variabele voor Norton Guide}
    MEntry       : Array [1..10] of Longint; {Geeft MenuEntrys voor Menuobj.Load}
    Credits      : Array [1..5] of StrPtr;{voor funtie Credit}
    Buffer       : Array [0..377] of Byte;
    UpDateBuffer : Boolean;
    FileBufStart : Longint;
    FilePtr      : Longint;
    FileBufEnd   : Longint;

{***Niet voor eind user maar voor intern, menuobj****************************}
{----------------------------------------------------------------------------}

{**Algemeen Voor Norton Guide*************************************************}
Procedure MoveFilePtr(L : Longint);
{deze procedure doet een normale seek, is gedaan om bij eventueele fout
 controle dit hier te inplanteren. FilePtr wordt ook geupdate omdat enkele
 funties hier vanaf hangen(bv:GuideShortOBJ.load de Entrys Lezen)}
Begin
 Seek(Guide,L);
 if (L>=FileBufStart) And (L<=FileBufEnd) then FilePtr := L
  Else UpDateBuffer := True;
End;


Procedure ReadBuffer;
Var Result : Word;
Begin
 if Not UpDateBuffer then Seek(Guide,FilePtr);
 UpDateBuffer := False;
 FileBufStart := FilePos(Guide);
 FilePtr := FileBufStart;
 BlockRead(Guide,Buffer,Sizeof(Buffer),Result);
 FileBufEnd := FilePtr + Pred(Result);
End;


Procedure MakeDecrypTabel;

  Function Decrypt(B  : Byte) : Byte;
  {Decrypt byte from NG format}
  Begin
   if ((B Mod 32)>=16) then B := B - 16 Else B := B + 16;
   if ((B Mod 16)>=8) then  B := B - 8  Else B := B + 8;
   if ((B Mod 4)>=2) then   B := B - 2  Else B := B + 2;
   Decrypt := B;
  End;

Var Loop : Byte;
Begin
 For Loop := 0 to 255 Do DecrypTabel[Loop] := Decrypt(Loop);
End;


Function Read_Byte : Byte;
{Read and decrypt byte}
Var Tb : Byte;
Begin
 if (FilePtr>FileBufEnd) Or (UpDateBuffer) then
  Begin
   ReadBuffer;
  End;
 Tb := DecrypTabel[Buffer[FilePtr-FileBufStart]];
 Inc(FilePtr);
 Read_Byte := Tb;
End;


Function Read_Word : Word;
{Read and decrypt word}
Var Tw : Word;
    Tb : Byte;
Begin
 Tb := Read_Byte;
 Tw := Tb;
 Tb := Read_Byte;
 Inc(tw,(Tb*256));
 Read_Word := Tw;
End;


Function Read_Long : Longint;
{Read and decrypt longint}
Var Tl : Longint;
    Tw : Word;
Begin
 Tw := Read_Word;
 Tl := Tw;
 Tw := Read_Word;
 Inc(Tl,(Tw*65536));
 Read_Long := Tl;
End;
{******************Eind Norton Algemeen**************************************}

{*****Normale Functies en Procedures*****************************************}
Procedure CloseGuide;
Var Loop : Byte;
Begin
{$I-} Close(Guide); {$I+}
 if IOResult <> 0 then ; {Alleen opvangen}

 For Loop := 1 to 5 Do
  if Credits[Loop]<>Nil then FreeMem(Credits[Loop],Length(Credits[Loop]^)+1);
End;


Function FirstEntry : Longint;
Begin
 FirstEntry := 378;
End;


Function LookGuide(F : String) : String;
Var S            : String;
    Loop         : Word;
    Result       : Word;
    Guide        : File;
Begin
 LookGuide := ''; UpDateBuffer := True;
 if F = '' then Exit;

 Assign(Guide,F);
{$I-} Reset(Guide,1); {$I+}
 if IOResult <> 0 then Exit; {File bestaat niet}
 BlockRead(Guide,Buffer,378,Result);
 if (Buffer[0]<>78) Or (Buffer[1]<>71)
 Or (Result<>Sizeof(Buffer)) then
 {Als de eerste 2 char niet 'NG' zijn of file is te klein dan geen NortonGuide}
  Begin
   Close(Guide);
   Exit;
  End;

 Menus := Buffer[6];

 Loop := 0;
 Repeat
  S[Loop+1] := Chr(Buffer[Loop+8]);
  Inc(Loop);
 Until (Buffer[Loop+8]=0);
 S[0] := Chr(Loop); {Lengte Van de GuideName}
 LookGuide := S;

 Close(Guide);
End;


Function OpenGuide(GuideFileName : Str79) : Boolean;
Var Loop         : Word;

  Procedure GetCredits;
  Var Loop2 : Byte;
      Len   : Byte;
      S     : String;
  Begin
   Loop := 48;
   For Loop2 := 1 to 5 Do
    Begin
     Len := 0;
     Repeat
      S[Len+1] := Chr(Buffer[Loop]);
      Inc(Loop); Inc(Len);
     Until (Buffer[Loop-1]=0);
     S[0] := Chr(Len);
     GetMem(Credits[Loop2],Length(S)+1);
     Credits[Loop2]^ := S;
     Loop := 48 + Loop2*66;
    End; {For}
  End;

  Procedure Read_MenuEntrys;
  Const MenuID = 2;
  Var MenuNr : Byte;
  Begin
   MenuNr := 0;
   Repeat
    if Read_Word = MenuId then
     Begin
      Inc(MenuNr);
      MEntry[MenuNr] := FilePtr - 2;{FilePos(Guide)}
      MoveFilePtr(MEntry[MenuNr]+Read_Word+26);
     End Else Begin
               {Writeln('Error in NG File!!');}
               Exit;
              End;
   Until (MenuNr>=Menus);
  End;

Begin
 OpenGuide := False;

 GuideName := LookGuide(GuideFileName);
 if GuideName = '' then Exit;
 Assign(Guide,GuideFileName);
 Reset(Guide,1); Seek(Guide,378);

 GetCredits;

{******Zet nu de file Pointer op de juiste Plaat voor verdere acties*********}
 MoveFilePtr(FirstEntry);
 Read_MenuEntrys;
 OpenGuide := True;
End;


Function Credit(Regel : Byte) : Str160;
Begin
 if (Regel>0) And (Regel<6) then
  Begin
   if Credits[Regel]<>Nil then Credit := Credits[Regel]^
    Else Credit := '';
  End Else Credit := '';
End;


Function MenuEntry(Nr : Byte) : Longint;
Begin
 if Nr <= Menus then MenuEntry := MEntry[Nr]
  Else MenuEntry := -1;
End;


Function EntryType(L : Longint) : Word;
Var Id : Word;
Begin
 EntryType := $ffff;
 if L < 0 then Exit;
 MoveFilePtr(L);
 Id := Read_Word;
 if (Id=0) Or (Id=1) then EntryType := Id;
End;


Function GuideStrip(S : String) : String;
Var TempS : String;
    Count : Word;
Begin
 if S = '' then Begin
                 GuideStrip := S;
                 Exit;
                End;
 TempS := '';
 Count := 0;
 Repeat
  Inc(Count);
  if S[Count] = '^' then
   Begin
    Inc(Count);
    Case Upcase(S[Count]) of
     '^' : Begin
            if (Upcase(S[Succ(Count)])='A') Or (Upcase(S[Succ(Count)])='B')
            Or (Upcase(S[Succ(Count)])='U') Or (Upcase(S[Succ(Count)])='N')
            then Dec(Count) Else Temps := Temps + '^';
           End;
     'A' : Count := Count + 2;
     'B' : ;
     'U' : ;
     'R' : ;
     'N' : Inc(Count);
     Else
      Dec(Count); {geen Kleur dus hoort bij tekst}
    End; {Case}
   End Else TempS := TempS + S[Count];
 Until (Count>=256) Or (Count>=Length(S));
 GuideStrip := TempS;
End;
{*********Einde Normale Functies en Procedures*******************************}

Procedure ReadNullString(Var S : String); {Voor intern gebruik}
Var Loop : Byte;
Begin
 Loop := 0;

 Repeat
  Inc(Loop);
  S[Loop] := Char(Read_Byte);
  if Loop=255 then
   Begin
    S[Loop] := #0;
    While (Read_Byte<>0) Do ;
   End;

 Until (S[Loop]=#0);

 Byte(S[0]) := Pred(Loop);
End;

{****************************************************************************}

{*********Start 'GuideMenuOBJ' Object****************************************}
Procedure GuideMenuOBJ.Done;
Var Loop : Word;
Begin
 For Loop := 1 to Count Do
  Begin
   FreeMem(Lines[Loop],Length(Lines[Loop]^)+1);
  End;
End;


Function GuideMenuOBJ.Entry(Nr : Word) : Longint;
Begin
 if (Nr<=Count) then Entry := Entrys[Nr]
  Else Entry := -1;
End;


Function GuideMenuOBJ.Line(Nr : Word) : Str84;
Begin
 if (Nr<=Count) then Line := Lines[Nr]^
  Else Line := '';
End;


Procedure GuideMenuOBJ.Load(L : Longint);
Var Loop,
    Loop2  : Word;
    S      : String;
Begin
 MoveFilePtr(L+4); {Eerste Word is Lengte?}
 Count := Read_Word;
 Dec(Count);

 MoveFilePtr(L+26);
 For Loop := 1 to Count Do
  Begin
   Entrys[Loop] := Read_Long;
  End;

 Loop := FilePtr;
 Loop2 := Succ(Count);
 Inc(Loop,(Loop2*8));
 MoveFilePtr(Loop);


 {Title}
   Loop2 := 0;
   Repeat
    Title[Loop2+1] := Chr(Read_Byte);
    Inc(Loop2);
   Until (Title[Loop2]=#0);
   Title[0] := Chr(Loop2-1);

 For Loop := 1 to Count Do
  Begin
   Loop2 := 0;
   Repeat
    S[Loop2+1] := Chr(Read_Byte);
    Inc(Loop2);
   Until (S[Loop2]=#0);
   S[0] := Chr(Loop2-1);
   GetMem(Lines[Loop],Loop2);
   Lines[Loop]^ := S;
  End; {For}
End;
{*********Einde 'GuideMenuIBJ' Object****************************************}

{********GuideShortOBJ Object************************************************}
Procedure GuideShortOBJ.Done;
Var Loop : Word;
Begin
 For Loop := 1 to Count Do
  Begin
   FreeMem(Lines[Loop],Length(Lines[Loop]^)+1);
  End;
End;


Function GuideShortOBJ.Line(Nr : Word) : Str84;
Begin
 if (Nr<=Count) then Line := Lines[Nr]^
  Else Line := '';
End;


Function GuideShortOBJ.RawLine(Nr : Word) : Str84;
Begin
 if (Nr<=Count) then RawLine := Lines[Nr]^
  Else RawLine := '';
End;


Function GuideShortOBJ.Entry(Nr : Word) : Longint;
Begin
 if (Nr<=Count) then Entry := Entrys[Nr]
  Else Entry := -1;
End;


Procedure GuideShortOBJ.Load(L : Longint);
Var Loop : Word;
    Dump : Word;
    S    : String;
Begin
{hier kan eventueel worden getest of het wel echt een Short Entry is,Nu dus+2}
 MoveFilePtr(L+4);
 Count      := Read_Word;
 MoveFilePtr(L+8);
 Current    := Read_Word;
 Parent     := Read_Long;
 MenuParent := Read_Word;
 MenuLine   := Read_Word;
 MoveFilePtr(L+26);

 For Loop := 1 to Count Do
  Begin
   MoveFilePtr(FilePtr+2);
   Entrys[Loop] := Read_Long;
  End;

 For Loop := 1 to Count Do
  Begin
   ReadNullString(S);
   GetMem(Lines[Loop],Length(S)+1);
   Lines[loop]^ := S;
  End;
End;
{********Einde GuideShortOBJ Object******************************************}

{**GuideLongOBJ**************************************************************}
Procedure SeeAlsoObj.Done;
Var Loop : Word;
Begin
 For Loop := 1 to Count Do
  Begin
   FreeMem(Lines[Loop],Length(Lines[Loop]^)+1);
  End;
End;


Function SeeAlsoObj.Line(Nr : Word) : Str84;
Begin
 if (Nr<=Count) then Line := Lines[Nr]^
  Else Line := '';
End;


Function SeeAlsoObj.Entry(Nr : Word) : Longint;
Begin
 if (Nr<=Count) then Entry := Entrys[Nr]
  Else Entry := -1;
End;


Procedure GuideLongOBJ.Done;
Var Loop : Word;
Begin
 For Loop := 1 to Count Do
  Begin
   FreeMem(Lines[Loop],Length(Lines[Loop]^)+1);
  End;

 SeeAlso.Done;
End;


Function GuideLongOBJ.Line(Nr : Word) : Str84;
Begin
 if (Nr<=Count) then Line := Lines[Nr]^
  Else Line := '';
End;


Function GuideLongOBJ.RawLine(Nr : Word) : Str84;
Begin
 if (Nr<=Count) then RawLine := Lines[Nr]^
  Else RawLine := '';
End;


Function GuideLongOBJ.Previous : Longint;
Begin
 Previous := PrevEntry;
End;


Function GuideLongOBJ.Next : Longint;
Begin
 Next := NxtEntry;
End;


Procedure GuideLongOBJ.Load(L : Longint);
Var Loop : Word;
    S    : String;
Begin
 MoveFilePtr(L+4);
 Count         := Read_Word;
 SeeAlso.Count := Read_Word;
 Current       := Read_Word;
 Parent        := Read_Long;
 MenuLine      := Read_Word;
 MenuParent    := Read_Word;
 PrevEntry     := Read_Long;
 NxtEntry      := Read_Long;

 For Loop := 1 to Count Do
  Begin
   ReadNullString(S);
   GetMem(Lines[Loop],Length(S)+1);
   Lines[Loop]^ := S;
  End;

 if SeeAlso.Count <> 0 then
  Begin
   With SeeAlso Do
    Begin
     Count := Read_Word;

     For Loop := 1 to Count Do
      if Loop <21 then
       Begin
        SeeAlso.Entrys[Loop] := Read_Long
       End Else MoveFilePtr(Filepos(Guide)+4);

     For Loop := 1 to Count Do
      Begin
       if Loop<21 then
        Begin
         ReadNullString(S);
         GetMem(SeeAlso.Lines[Loop],Length(S)+1);
         SeeAlso.Lines[Loop]^ := S;
        End;
      End; {For}
    End; {With}
  End;
End;
{****************************************************************************}


Begin {Init NG Unit}
 For Menus := 1 to 5 Do Credits[Menus] := Nil;
 GuideName := '';
 Menus := 0;
 MakeDecrypTabel;
End.  {Init NG Unit}