 ; Раздельно компилируемый модуль - обработчик прерываний, генерируемых
 ; макросами Multi-Edit. 
 ; Гурин С. В. Томск, ТПИ, кафедра электрических станций.

DGROUP group _DATA
  assume  ds:DGROUP

_DATA segment word public 'DATA'
_DATA ends

_TEXT segment byte public 'CODE'
  assume  cs:_TEXT

@multi_edit_handler$qv proc far    ; Диспетчер связи с Multi-Edit
  push  es                         ; Сохранение регистров, не используемых для
  push  ds                         ; обмена параметрами между функциями C и
  push  bp                         ; макросами Multi-Edit
  sti                              ; Разрешение аппаратных прерываний
  mov   bp, DGROUP                 ; Установка сегментного регистра данных
  mov   ds, bp
  cmp   ax, word ptr DGROUP:_max_function  ; Контроль правильности задания
  ja    short error_function               ; номера функции
  mov   word ptr DGROUP:_r_bx, bx  ; Заполнение обменных переменных значениями
  mov   word ptr DGROUP:_r_cx, cx  ; соответствующих регистров
  mov   word ptr DGROUP:_r_dx, dx
  mov   word ptr DGROUP:_r_si, si
  mov   word ptr DGROUP:_r_di, di
  mov   bx, ax                     ; Получение индекса в таблице C-функций
  shl   bx, 1                      ; по значению регистра ax
  mov   cx, word ptr DGROUP:_function_array[bx]
  xor   ax, ax                     ; Обнуление кода ошибки
  mov   word ptr DGROUP:_r_ax, ax
  cmp   cx, ax                     ; Контроль отсутствия функции
  je    short error_function       
  call  cx                         ; Вызов C-функции с заданным номером
  mov   di, word ptr DGROUP:_r_di  ; Заполнение регистров соответствующими
  mov   si, word ptr DGROUP:_r_si  ; значениями обменных переменных
  mov   dx, word ptr DGROUP:_r_dx
  mov   cx, word ptr DGROUP:_r_cx
  mov   bx, word ptr DGROUP:_r_bx
  mov   ax, word ptr DGROUP:_r_ax  ; Заполнение значения кода ошибки
  jmp   short exit_handler
error_function:
  mov   ax, 1                      ; Возврат 1 при ошибке номера функции
exit_handler:
  pop   bp                         ; Восстановление регистров, не используемых
  pop   ds                         ; для обмена параметрами между функциями C
  pop   es                         ; и макросами Multi-Edit
  iret                             ; Возврат в Мulti-Edit
@multi_edit_handler$qv  endp

_TEXT ends

  public @multi_edit_handler$qv
  extrn  _r_ax:word
  extrn  _r_bx:word
  extrn  _r_cx:word
  extrn  _r_dx:word
  extrn  _r_si:word
  extrn  _r_di:word
  extrn  _function_array:word
  extrn  _max_function:word
  end
