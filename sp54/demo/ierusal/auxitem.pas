Unit AUXItem;
{$X+}
{$F+}
{$O+}
interface
uses Crt, Objects, Drivers  , Views,Dialogs,App;

const
msNoMask = 0; {не порождать событие }
{следующие коды можно складывать}
msRight  = 1; {порождать событие если нажали на правую клавишу}
msLeft   = 2; {порождать событие если нажали на левую клавишу }
msDouble = 4; {порождать событие если нажали на клавишу дважды}

type

  {----------TInputLineMod-----------}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{ данный объект несколько расширяет возможности стандартного}
{ TInputLine                                                }
{ Если CodeComm  <> 0 , то если на данном объекте нажали    }
{ клавишу мыши в соответствии с маской или нажата клавиша   }
{ клавиатуры с кодом  = KeyCode, то данный объект порождает }
{ событие :                                                 }
{  var                                                      }
{    Ev : TEvent;                                           }
{     if CodeComm <> 0 then                                 }
{      BEGIN                                                }
{       Ev.What   := evCommand;                             }
{       Ev.Command:= CodeComm;                              }
{       PutEvent(Ev);                                       }
{      END;                                                 }
{ Это свойство объекта можно использовать для               }
{ вызова справочников и т. п.                               }
{ KeyPalInt = 0 - разные цвета при активном и пассивном поле}
{             1 - 4 - другие палитры                        }
{ KeyDraw <> 0 то если  состояние объекта sfDisabled        }
{ заполнить  поле  символом chr(KeyDraw)                    }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{При     использовании      стандартного                    }
{TInputLine,  если   с  помощью   метода                    }
{SetData,  загрузить   строку   длиннее                     }
{максимальной  ,   то  происходит   крах                    }
{системы.   В   данном   объекте  просто                    }
{загружается начало строки                                  }
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ }

PInputLineMod =^TInputLineMod;
TInputLineMod = object(TInputLine)
    MouseMask : word    ; {маска действий по нажатию мыши  }
    KeyCode   : word    ; {по этой клавише выдавать команду}
    CodeComm  : word    ; {код команды                     }
    KeyPalInt : byte    ; { 0 - 4  разные палитры          }
                          { если 0 - то цвет зависит  от   }
                          { состояния объекта              }
    KeyDraw   : byte    ; { если <> 0 , то символ, которым }
                          { заполнять поле если объект в   }
                          { состоянии sfDisabled           }
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event : TEvent); virtual;
    procedure Store(var S: TStream);
    procedure SetData(var Rec); virtual;
    procedure Draw ; virtual;
    function  GetPalette : PPalette; virtual;
end;
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                                                          }
{ Целое число LongInt                                      }
{ Valid = True если:                                       }
{ содержимое - целое число в интервале от                  }
{ MinI  до MaxI                                            }
{ Пустая строка ->  0                                      }
{ Если MinI > MaxI , проверка границ не выполняется        }
{ DataSize = SizeOf(LongInt)                               }
{ В методах SetData и GetData аргумент считается типа      }
{ LongInt                                                  }
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
    {--------TTIntNumb------}
  PTIntNumb = ^TTIntNumb;
  TTIntNumb = object( TInputLineMod)
    MaxI,MinI : LongInt;
    constructor Init(var Bounds : TRect;
                              L : integer;
                      AMax,Amin : LongInt);
    constructor Load(var S: TStream);
    function  DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure Store(var S: TStream);
    procedure SetData(var Rec); virtual;
    function Valid(Command: Word): Boolean; virtual;
  end;
{----------------TTRealNumb--------------------------------}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{ Действительное число должно быть <= AMax  и              }
{  Valid = True если введенные данные имеют формат         }
{          действительного числа и число <= AMax  и        }
{          >= AMin                                         }
{ Если AMin > AMax , проверка границ не выполняется        }
{ Пустая строка ->  0                                      }
{ALField     Длина поля в символах                         }
{ADecimals   количество десятичных символов                }
{ DataSize = SizeOf(Real)                                  }
{ В методах SetData и GetData аргумент считается типа      }
{ Real                                                     }
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
  PTRealNumb = ^TTRealNumb;
  TTRealNumb = object(TInputLineMod)
    MaxI,MinI : Real;
    LField   : byte;
    Decimals : ShortInt;
    constructor Init(var Bounds : TRect;
                 AMax,Amin      : real;
              ALField           : byte;
              ADecimals         : ShortInt);
    function  DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    function Valid(Command: Word): Boolean; virtual;
  end;
 {Обычный диалог, но пpи пеpеходе c одного поля }
 {выполняется пpовеpка Valid                    }
 { в случае если Valid = Fals вызывается        }
 { ShowError, который должен ссобщить об ошибке }
{TValidDialog}
   PValidDialog = ^TValidDialog;
   TValidDialog = object(TDialog)
     procedure   HandleEvent(var Event : TEvent) ; virtual;
     procedure   ShowError(code : integer); virtual;
     function Valid(Command: Word): Boolean; virtual;
   end;

   procedure RegistInputLineMod;
   procedure RegistIntNumb;
   procedure RegistRealNumb;
   procedure RegistValidDialog;

  const
  RInputLinemod: TStreamRec = (
    ObjType: 300;
    VmtLink: Ofs(TypeOf(TInputLinemod)^);
    Load:    @TInputLinemod.Load;
    Store:   @TInputLinemod.Store);
  RIntNUmb: TStreamRec = (
    ObjType: 301;
    VmtLink: Ofs(TypeOf(TTIntNumb)^);
    Load:    @TTIntNumb.Load;
    Store:   @TTIntNumb.Store);

  RValidDialog: TStreamRec = (
    ObjType: 303;
    VmtLink: Ofs(TypeOf(TValidDialog)^);
    Load:    @TValidDialog.Load;
    Store:   @TValidDialog.Store);

  RRealNUmb: TStreamRec = (
    ObjType: 304;
    VmtLink: Ofs(TypeOf(TTRealNumb)^);
    Load:    @TTRealNumb.Load;
    Store:   @TTRealNumb.Store);

 implementation
  {++++++++++++++++++++++++++++++++}
  { Убрать "пробелы и т.п."        }
  {++++++++++++++++++++++++++++++++}

  function RemWhiteStr(S : string): string;
    var
     T     : string;
     i,j   : word;
     Ch    : char;

    begin
      T := '';
      J := 0 ;
      for I := 1 to Length(S) do
        BEGIN
          Ch := S[I];
          if Ch > ' ' then
            BEGIN
             inc(j);
             T[j] := Ch;
            END;
        END;
      T[0] := Chr(j);
      RemWhiteStr := T;
    end;{RemWhiteStr}

   function RemTrailNils(S : string) : string;
  var
{   S1 : string;}
   i  : byte;
  begin
   {S1 := S;}
   {нули убираем только из дробной части}
   if (S          <> '') and
      (Pos('.',S) <>  0) then
   begin
   I := Length(S);
    while (S[I] = '0') and (i > 0) do
     begin
      Delete(S,I,1);
      I := Length(S)
     end;
     {если последний символ '.', то убрать его}
     if S[Length(S)] = '.' then Dec(S[0]);
     if S = '' then S := '0';
    end;
    RemTrailNils := S;
  end;

    function TestAndConvR( S : string; var R : real) : word;
      var
        Code : word;
      begin
         S :=RemWhiteStr(S);
         if  S  = '' then 
          BEGIN
            R    := 0;
            Code := 0;
          END else   Val(S, R , Code);
        TestAndConvR := Code;
      end;

    function TestAndConvL( S : string; var L : LongInt) : word;
      var
        Code : word;
      begin
         S :=RemWhiteStr(S);
         if  S  = '' then 
          BEGIN
            L    := 0;
            Code := 0;
          END else   Val(S, L , Code);
        TestAndConvL := Code;
      end;

    procedure RegistIntNumb;
    begin
     RegisterType(RIntNumb);
    end;

    procedure RegistRealNumb;
    begin
     RegisterType(RRealNumb);
    end;

   procedure RegistInputLineMod;
    begin
     RegisterType(RInputLineMOd);
    end;

   procedure RegistValidDialog;
    begin
     RegisterType(RValidDialog);
    end;

{---------TValidDialog----------}

     procedure TValidDialog.ShowError(code : integer);
      begin
        Sound(440);
        Delay(200);
        NoSound;
      end;

    procedure TValidDialog.HandleEvent(var Event : TEvent) ;
      var
       KeyTrans : boolean;

      begin
         {есть переход?}
         KeyTrans := False; { пока нет}
         if  (( Event.What    = evMouseDown )   and
            Not Current^.MouseInView(Event.Where)) then KeyTrans := True;

         if  (Event.What = evKeyDown) and
             ((Event.KeyCode = kbTab) or
              (Event.KeyCode = kbShiftTab)) then KeyTrans := True;

         if KeyTrans and Not Current^.Valid(1) then
          begin
            ShowError(1);
            ClearEvent(Event);
          end;

       TDialog.HandleEvent(Event);
 end;

 function TValidDialog.Valid(Command: Word): Boolean;
  var
   Key : boolean;
  begin
    Key := TDialog.Valid(Command);
    Valid := Key;
    if Not Key then ShowError(0);
  end;


  {------TTRealNumb-------}
    constructor TTRealNumb.Init(var Bounds : TRect; AMax,Amin : Real;
                                 ALField           : byte;
                                 ADecimals         : ShortInt);

      begin
       TInputLineMod.Init(Bounds,ALField);

       MaxI      := AMax;
       MinI      := AMin;
       LField    := ALField;
       Decimals  := ADecimals;
      end;

    function  TTRealNumb.DataSize: Word;
     begin
       DataSize := SizeOf(Real);
     end;


    procedure TTRealNumb.GetData(var Rec);
     var
      R    : Real;
      Code : integer;
     begin
       if TestAndConvR(Data^,R) <> 0 then Real(Rec) := MinI
                                     else Real(Rec) := R;
     end;

    procedure TTRealNumb.SetData(var Rec);
     var
      S : string;
     begin
       if Decimals > 0 then Str(Real(Rec): LField : Decimals,S)
                       else Str(Real(Rec): LField,S);

       {убрать пробелы и т.п. а так же нули после дробной части}
       S     :=RemTrailNils(  RemWhiteStr(S));
       if Length(S) > LField then
        begin
         FillChar(S[1],255,Ord('*'));
         S[0] := #255;
        end;
       Data^ := Copy(S,1,LField);
     end;

    function TTRealNumb.Valid(Command: Word): Boolean;
     var
      Code : integer;
      R    : Real;
      S    : string;
     begin
       Valid := True;
       if (Command <> cmValid) then
        begin
         if (TestAndConvR(Data^,R) <> 0   )  then Valid := False
                            else
         if (MaxI    >  MinI   ) and
            ((R    <  MinI)  or
            (R     >  MaxI))  then Valid := False;
        end;
     end;

  {----------TInputLineMod-----------}
    procedure TInputLineMod.SetData(var Rec);
     var
     S : string;
     begin
       S := Copy(String(Rec),1,MaxLen);
       TInputLine.SetData(S);
     end;

    function  TInputLinemod.GetPalette: PPalette;
     var
     S  : string[4];
     SD : string[4];
     D  : char;
(* стаpая палитpа
 1 2 3 4
╔═╤═╤═╤═╗
╚╤╧╤╧╤╧╤╝
 │ │ │ └─ 21: Selected
 │ │ └─── 20: Arrow
 │ └───── 19: Passive
 └─────── 19: Active
*)
     begin
      case KeyPalInt  of
0:    begin
        S :=#19#20#20#21;
        D :=#13;
        SD:=D+D+D+D;
        if GetState(sfDisabled) then S := Sd;
       end;
1:     S := CInputLIne;
2:     S :=#19#19#19#20;
4:     S :=#6#6#6#21;  {все как у StaticText кроме Selected}
        else   S  := CInputLIne;
      end;
       GetPalette := @S;
     end;

    procedure TInputLinemod.Draw ;
     var
      B : TDrawBuffer;
      c,c1 : word;
     begin
       if GetState(sfDisabled) and ( KeyDraw <> 0 ) then
        begin
          C   := GetColor(2);
          if Size.X < MaxViewWidth then c1 := Size.X
                                   else c1 := MaxViewWidth;
          MoveChar(B, char(KeyDraw) , C, c1 );
          WriteLine(0, 0 , Size.X, 1, B);
        end
                               else
       TInputLine.Draw ;

     end;

    procedure TInputLineMod.HandleEvent(var Event : TEvent);
     var
      EV :  TEvent;
      procedure PtEvent;
       begin
        if  (CodeComm <> 0 )  then
         begin
          EV         := Event;
          Ev.What    := evBroadCast;
          Ev.Command := CodeComm;
          Ev.InfoPtr := @Self;
          PutEvent(Ev);
         end;
       end;

     begin
        if (
            (Event.What    = evBroadcast    )  and
            (Event.Command = cmReceivedFocus)  and
            (Event.InfoPtr = @Self          )  and
            (KeyCode       = kbNokey        )  and
            (MouseMask     = msNoMask       )
           ) then PtEvent;

       if (
           (Event.What  = evKeyDown          ) and
           (Event.KeyCode = KeyCode         )
          )  then PtEvent;

       if (Event.What    = evMouseDown     ) then
        if (
            Event.Double = ((Mousemask and msDouble) <> 0)
           ) then
        begin
        if  ((MouseMask    and msRight) <> 0 ) and
            (Event.Buttons = mbRightButton   ) then  PtEvent;
        if  ((MouseMask   and msLeft)  <> 0 ) and
            (Event.Buttons = mbLeftButton    ) then  PtEvent;
        end;

       TInputLine.HandleEvent(Event);
     end;

    constructor TInputLinemod.Load(var S: TStream);
     begin
      TInputLine.Load(S);
      S.Read(MouseMask,SizeOf(MouseMask));
      S.Read(KeyCode  ,SizeOf(KeyCode));
      S.Read(CodeComm,SizeOf(CodeComm));
      S.Read(KeyPalInt,SizeOf(KeyPalInt));
      S.Read(KeyDraw,SizeOf(KeyDraw));
     end;

    procedure TInputLinemod.Store(var S: TStream);
     begin
      TInputLine.Store(S);
      S.Write(MouseMask,SizeOf(MouseMask));
      S.Write(KeyCode  ,SizeOf(KeyCode));
      S.Write(CodeComm,SizeOf(CodeComm));
      S.Write(KeyPalInt,SizeOf(KeyPalInt));
      S.Write(KeyDraw,SizeOf(KeyDraw));
     end;


{-------TTIntNumb--------}
    constructor TTIntNumb.Init(var Bounds    : TRect;
                                   L         : integer;
                                   AMax,Amin : LongInt);
      begin
       TInputLineMod.Init(Bounds,L);
       MaxI := AMax;
       MinI := AMin;
      end;

   constructor  TTIntNumb.Load(var S: TStream);
    begin
     TInputLineMod.Load(S);
     S.Read(MaxI,SizeOf(LongInt));
     S.Read(MinI,SizeOf(LongInt));
    end;

   procedure TTIntNumb.Store(var S: TStream);
    begin
     TInputLineMod.Store(S);
     S.Write(MaxI,SizeOf(LongInt));
     S.Write(MinI,SizeOf(LongInt));
    end;


    function  TTIntNumb.DataSize: Word;
     begin
       DataSize := SizeOf(LongInt);
     end;

    procedure TTIntNumb.GetData(var Rec);
     var
      L    : LongInt;
     begin
       if TestAndConvL( Data^, L) <> 0 then LongInt(Rec) := MinI
                                       else LongInt(Rec) := L;
     end;

    procedure TTIntNumb.SetData(var Rec);
     var
      S : string;
      V : LongInt;
     begin
       V := LongInt(Rec);

       if (MaxI > MinI) and
          ((V  <  MinI) or (V > MaxI )) then   V := MinI;
       Str(V : MaxLen,S);
       Data^ :=RemWhiteStr(Copy(S,1,MaxLen));
     end;

    function TTIntNumb.Valid(Command: Word): Boolean;
     var
      Code : integer;
      L    : LongInt;
      S    : string;
     begin
       Valid := True;
       if Command <> cmValid then
        begin
         if (TestAndConvL( Data^, L) <> 0) then Valid := False
                                           else
         if (MaxI > MinI) and
            ((L  <  MinI) or (L > MaxI )) then  Valid := False ;
        end;
     end;
    end.