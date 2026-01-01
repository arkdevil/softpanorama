{******************************* JScr-Info *********************************}
{ резидентная программа для определения положения курсора и атрибутов       }
{***************************************************************************}
program ScrInfo;
Uses
  TpCrt,
  TpTsr,
  TpString,
  Dos;

const
  ModuleName : string = 'JScr-Info';
  HotKey : Word = $0839;  {Alt + Space}
  HotKey2: Word = $080f;  {Alt + Tab}

const
   MaxCol = 80;    { размеры экрана }
   maxRow = 25;


type
   Sym = record  { символ экранной памяти }
      S : char;  { код ASCII символа }
      A : byte;  { атрибут цвета }
   end;

   Scr = array[1..MaxRow,1..MaxCol] of Sym;

var
   XY, ScanLines : word;          { положение и состояние курсора       }
                                  {                  до вызова Resident }
   VideoRAM     : Scr absolute $b800:$0000;
   SaveVideoRAM : Scr;
   CurX,CurY    : byte;           { положение курсора на экране при     }
                                  { резидентном опросе                  }
{░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}


procedure Abort(Message : string);
    {-Display message and Halt}
  begin
    WriteLn(Message);
    Halt(1);
  end;

{*****************************************************************************}
{$F+}
procedure Resident(Var R : Registers);

var
   chw : word;
   KeyOut : boolean;
   Str1,Str2 : string;
   CurX0,CurY0 : byte;
   Sout : string;
   SW : string;
   ColOut : byte;

begin

   PopupsOff;
   SaveVideoRAM:=VideoRAM;
   GetCursorState(XY,ScanLines);
   BlockCursor;
   FastRead(80,25,1,Str1);
   ReadAttribute(80,25,1,Str2);

   FastCenter('Use Left,Right,Up,Down,Home,End,PgUp,PgDn,Esc',25,$5E);
   GoToXY(CurX,CurY);
   repeat until (KeyPressed);
   FastText(Str1,25,1);
   WriteAttribute(Str2,25,1);

   KeyOut:=false;
   repeat
      chw:=ReadKeyWord;

      CurX0:=CurX;
      CurY0:=CurY;

      case (chw) of
         $4b00 :  Dec(CurX0); {Left}
         $4d00 :  Inc(CurX0); {Right}
         $4800 :  Dec(CurY0); {Up}
         $5000 :  Inc(CurY0); {Down}

         $4700 :  begin Dec(CurX0); Dec(CurY0); end; {Home}
         $4F00 :  begin Dec(CurX0); Inc(CurY0); end; {End}
         $4900 :  begin Inc(CurX0); Dec(CurY0); end; {PgUp}
         $5100 :  begin Inc(CurX0); Inc(CurY0); end; {PgDn}
         $011B,
         $1C0D : KeyOut:=true;   {Enter,Esc}
      end;

      if (CurX0<=MaxCol) and (CurX0>0) then CurX:=CurX0;
      if (CurY0<=MaxRow) and (CurY0>0) then CurY:=CurY0;
      GoToXYAbs(CurX,CurY);

      Sout:='Sym "'+SaveVideoRAM[CurY,CurX].S+'" $'+
           HexB(byte(SaveVideoRAM[CurY,CurX].S));
      str(ord(SaveVideoRAM[CurY,CurX].S):3,SW);
      Sout:=Sout+'('+SW+
           '),Attr:$'+
           HexB(SaveVideoRAM[CurY,CurX].A);
      str(SaveVideoRAM[CurY,CurX].A:3,SW);
      Sout:=Sout+'('+SW+')';

      Sout:=Sout+' X=';
      str(CurX:2,SW);
      Sout:=Sout+SW;
      Sout:=Sout+',Y=';
      str(CurY:2,SW);
      Sout:=Sout+SW;

      if (CurY=1) and (CurX>40) then ColOut:=1 else ColOut:=41;
      move(SaveVideoRAM,VideoRAM,160);
      FastWrite(Sout,1,ColOut,$4E);

   until (KeyOut);

   VideoRAM:=SaveVideoRAM;
   RestoreCursorState(XY,ScanLines);
   PopupsOn;

end;
{$F-}
{*****************************************************************************}
{$F+}
{ Выгрузить резидентную рпограмму }
procedure FreeMemory(Var R : Registers);

var
   i:byte;

begin
   SaveVideoRAM:=VideoRAM;

   if DisableTSR then
      write(ModuleName,' больше не работает !')
   else
      write('Невозможно выгрузить '+ModuleName+'!');

   for i:=1 to 10 do
      begin
         sound(750);  delay(1);
         sound(1000); delay(1);
         sound(1500); delay(2);
         sound(2250); delay(4);
         nosound;
      end;
   delay(1000);

   VideoRAM:=SaveVideoRAM;
end;
{$F-}
{*****************************************************************************}

begin {JSaver}

   HighVideo;
   WriteLn('Информатор экранной памяти');
   WriteLn(ModuleName+', v1.5  1990,1991 Е.Чалюк г.Харьков');
   LowVideo;

   if SideKickLoaded then
     Abort('Нельзя загрузиться после SideKick!');


   if ModuleInstalled(ModuleName) then
     Abort('Программа не готова к загрузке, т.к. уже загружена.');

   InstallModule(ModuleName, nil);

   if DefinePop(HotKey, @Resident, Ptr(SSeg, SPtr), True) then
     WriteLn(ModuleName+' загружена, нажмите Alt + Space для активации,');
   if DefinePop(HotKey2, @FreeMemory, Ptr(SSeg, SPtr), True) then
     WriteLn('  и Alt-Tab для выгргузкии из памяти.');

   CurX:=1;    { Для первого вызова }
   CurY:=1;

   PopupsOn;

   if not TerminateAndStayResident(ParagraphsToKeep, 0) then {} ;

   Abort('Невозможно инсталлировать '+ModuleName);

end.  {JSaver}