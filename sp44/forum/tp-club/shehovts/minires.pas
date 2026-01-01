(*                                 Специально для СофтПанорамы.

  Демонстрационная программа, показывающая способы сокращения  размера
резидентных программ, написанных на языке Turbo-Pascal 6.0.
   Подробности использованных трюков приведены в статье, помещенной  в
этой же СофтПанораме.
   Программа играет простую мелодию в  фоновом  режиме,  затем  делает
пятисекундную паузу и снова играет ту же мелодию.
   Автор за качество мелодии ответственности не несет.
   Для простоты вектор прерывания 1C перехватывается безвозвратно,  то
есть после запуска этой программы  остальные  резиденты,  использующие
вектор 1C, могут перестать срабатывать.
   Чтобы  проверить,  сколько  памяти  экономится  при   использовании
методов  сокращения  размера   резидентной   программы,   восстановите
описание макроопределения Standard.
   У меня получился резидент в 5824 байта  при  {$DEFINE  Standard}  и
всего лишь 1904 байта, если  использовать  методы  сокращения  размера
резидентной программы, то есть {.$DEFINE Standard}.

                                        Автор      Шеховцов А.Л.
                                                   25 февраля 1992 года

*)

{.$DEFINE Standard}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
{$M 1024,0,0}

program MiniResident;

uses DOS,CRT;

CONST
     Counter  : word = 0; (* Счетчик вызовов прерывания 1C - таймера *)
     MusicItem: word = 1; (* Номер текущей частоты и длительности звука *)
     MaxItem         = 58;(* Всего элементов массивов длительности
                             и частоты звука *)

CONST Fr : ARRAY[1..MaxItem] of word =  (* Частота звука *)
                                ( $106,$106,$125,$149,$106,$149,$125,$0C4,
                                  $106,$106,$125,$149,$106,$106,$106,$106,
                                  $125,$149,$15D,$149,$125,$106,$0F6,$0C4,
                                  $0DC,$0F6,$106,$106,$0DC,$0F6,$0DC,$0AE,
                                  $0DC,$0F6,$106,$0DC,$0C4,$0DC,$0C4,$0AE,
                                  $0A4,$0AE,$0C4,$0DC,$0F6,$0DC,$0AE,$0DC,
                                  $0F6,$106,$0DC,$0C4,$106,$0F6,$125,$106,
                                  $106,0);
      Tm : ARRAY[1..MaxItem] of byte =  (* Пауза между изменениями звуков *)
                                ( 5 ,5 ,5 ,5 ,5 ,5 ,5 ,5 ,
                                  5 ,5 ,5 ,5 ,11,11,5 ,5 ,
                                  5 ,5 ,5 ,5 ,5 ,5 ,5 ,5 ,
                                  5 ,5 ,11,11,6 ,5 ,6 ,5 ,
                                  5 ,5 ,5 ,5 ,6 ,5 ,6 ,5 ,
                                  5 ,5 ,7 ,6 ,5 ,6 ,5 ,5 ,
                                  5 ,5 ,7 ,5 ,5 ,5 ,5 ,11 ,
                                  11,90);

(*
     Процедуры Move, Sound и NoSound, написанные вместо стандартных
   из модулей SYSTEM и CRT.
*)

procedure Move( VAR Source, Dest; Count : word );
(* Для того, чтобы не использовать move из модуля SYSTEM *)

TYPE
   Bytes = array[1..MaxInt] of byte;
VAR
   I : word;
begin

   FOR I := 1 TO Count DO Bytes(Dest)[I] := Bytes(Source)[I];

end;{Move}

(* Процедуры Sound и NoSound взяты из библиотеки Object Professional
for Turbo-Pascal. Исходные тексты других процедур, необходимых для
работы Ваших резидентных программ, можно найти там же.
*)


procedure Sound(Hz: Word);
(*Turn on the sound at the designated frequency*)
begin
 asm

        MOV     BX,Hz                  (*BX = Hz       *)
        MOV     AX,34DCh
        MOV     DX,0012h               (*DX:AX = $1234DC = 1,193,180 *)
        CMP     DX,BX                  (*Make sure the division won't *)
        JAE     @SoundExit             (* produce a divide by zero error *)
        DIV     BX                     (*Count (AX) = $1234DC div Hz     *)
        MOV     BX,AX                  (*Save Count in BX                *)

        IN      AL,61h                 (*Check the value in port $61     *)
        TEST    AL,00000011b           (*Bits 0 and 1 set if speaker is on *)
        JNZ     @SetCount              (*If they're already on, continue   *)

        OR      AL,00000011b           (*Set bits 0 and 1   *)
        OUT     61h,AL                 (*Change the value   *)
        MOV     AL,182                 (*Tell the timer that the count is coming *)
        OUT     43h,AL                 (*by sending 182 to port $43  *)

@SetCount:
        MOV     AL,BL                  (*Low byte into AL       *)
        OUT     42h,AL                 (*Load low order byte into port $42 *)
        MOV     AL,BH                  (*High byte into AL                 *)
        OUT     42h,AL                 (*Load high order byte into port $42*)

@SoundExit:
end;
end;{Sound}


procedure NoSound; assembler;
(* Turn off the sound *)
asm

        IN      AL,61h                  (* Get current value of port $61 *)
        AND     AL,11111100b            (* Turn off bits 0 and 1         *)
        OUT     61h,AL                  (* Reset the port                *)

end; {NoSound}


procedure BufferDS; (* Место для хранения нового адреса сегмента данного *)
begin
end;{BufferDS}

procedure MyRes; interrupt;
 (* Резидентная процедура - обработчик перехваченного прерывания 1С *)

begin
{$IFNDEF Standard}
    ASM
       mov ax, cs : word ptr [BufferDS]
       mov ds,ax
    END;
{$ENDIF}

    INC( Counter );
    if MusicItem = MaxItem        (* Вся музыка отыграла? *)
       then NoSound
       else Sound( (Fr[MusicItem]*9) DIV 10 );
     if Counter = Tm[MusicItem]   (* Длительность текущего звука
                                     исчерпана? *)
        then begin
                 Inc( MusicItem );   (* Да, переходим к следующему звуку *)
                 Counter := 0;
                 if MusicItem > MaxItem
                    then MusicItem := 1;
             end;
end;{MyRes}

{$IFNDEF Standard}

procedure DummyProc; external;

procedure Keep( ExitCode : byte );
(* Сдвиг сегмента данных вплотную к кодовому сегменту.
   В результате ужимается EXE - файл насколько возможно. *)

VAR
   ResidSize: word; (* размер резидентной части программы в параграфах *)
   NewDS    : word; (* значение сегмента нового DS - сегмента данных  *)
   DataSize : word; (* размер сегмента данных в параграфах            *)


begin



  NewDS := (CSeg + Ofs(DummyProc) DIV 16) +1; (* Новый сегмент данных
                                              начинается сразу после
                                              процедуры Keep *)

  DataSize := SSeg-DSeg;
  ResidSize:= NewDS-PrefixSeg+DataSize;

  asm      (* Запомним значение адреса нового сегмента данных *)
     mov ax,NewDS
     mov cs : word ptr [BufferDS], ax
  end;

  move( MEM[ DSeg:0 ], MEM[ NewDS:0 ], (SSeg-DSeg)*16);
        (* move сдвигает сегмент данных впритык
           к кодам резидентной части программы *)

  ASM                             (* Становимся резидентом *)
    mov ax,[SYSTEM.PREFIXSEG]
    mov es,ax
    mov es,es:[02CH]              (* Сначала освобожу Environment block *)
    mov ah,49H
    int 21H

    mov dx,ResidSize              (* Установим размер резидентной части *)
    mov ah,31H
    mov al,ExitCode               (* Теперь - TSR с кодом возврата ExitCode *)
    int 21H
  END;

end;{Keep}

procedure DummyProc;
begin
end;{DummyProc}

{$ENDIF}

(* Отсюда начинается та часть программы, которая не попадет в резидент.
   Не думайте, что это слишком мало, ведь она включает в себя процедуры
   из модулей DOS, SYSTEM, CRT и инициализационный код этих модулей.
*)

begin
  SetIntVec( $1C, Addr(MyRes) );
  SwapVectors;
  Keep( 0 );
end.
