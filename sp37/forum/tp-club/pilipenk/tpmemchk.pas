{$S-,R-,V-,I-,B-}

{$IFDEF Ver40}
{$F-}
{$DEFINE FMinus}
{$ELSE}
  {$F+}
  {$I OPLUS.INC}
{$ENDIF}

{*********************************************************}
{*                   TPMEMCHK.PAS 5.05                   *}
{*        Copyright (c) TurboPower Software 1987.        *}
{* Portions copyright (c) Sunny Hill Software 1985, 1986 *}
{*     and used under license to TurboPower Software     *}
{*                 All rights reserved.                  *}
{*********************************************************}
{*  Модуль доработан О.П.Пилипенко для совместимости со  *}
{*     всеми версиями Turbo Pascal - от 4.0 до 6.0       *}
{*********************************************************}

unit TpMemChk;
  {-Allocate heap space. This unit is for internal use only.}

interface

function GetMemCheck(var P; Bytes : Word) : Boolean;
  {-Allocate heap space, returning true if successful}

procedure FreeMemCheck(var P; Bytes : Word);
  {-Deallocate heap space}

  {==============================================================}

implementation

  {$F+}
  function HeapFunc(Size : Word) : Integer;
    {-Return nil pointer if insufficient memory}
  begin
  {$IFDEF Ver60}
  if Size > 0 then
     begin
          HeapFunc:=1
     end
  {$ELSE}
    HeapFunc := 1
  {$ENDIF}
  end;
  {$IFDEF FMinus}
  {$F-}
  {$ENDIF}

  function GetMemCheck(var P; Bytes : Word) : Boolean;
    {-Allocate heap space, returning true if successful}
  var
    Pt : Pointer absolute P;
    SaveHeapError : Pointer;
  begin
    {Take over heap error control}
    SaveHeapError := HeapError;
    HeapError := @HeapFunc;
    GetMem(Pt, Bytes);
    GetMemCheck := (Pt <> nil);
    {Restore heap error control}
    HeapError := SaveHeapError;
  end;

  procedure FreeMemCheck(var P; Bytes : Word);
    {-Deallocate heap space}
  var
    Pt : Pointer absolute P;
  begin
    if Pt <> nil then begin
      FreeMem(Pt, Bytes);
      Pt := nil;
    end;
  end;

end.
