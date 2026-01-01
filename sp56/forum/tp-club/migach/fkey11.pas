
		{--------------------------------}
                {         FKEY   V 1.1           }
                {     Модуль определения         }
                {   процедур по функциональным   }
                {      и другим клавишам         }
                { Реализован на Turbo Pascal 5.5 }
                {			         }
                {    (c), 1990 Мигач Ярослав     }
                {--------------------------------}

UNIT fkey11;

{$F+,O+,D-,R-,S-,I-}

INTERFACE       { интерфейсная секция }

USES Crt, Def;

{----------------------------------------------------------}

CONST          { Коды клавиш функциональной клавиатуры }
     f1 = #59;  {           ( после ESC )               }
     f2 = #60;
     f3 = #61;
     f4 = #62;
     f5 = #63;
     f6 = #64;
     f7 = #65;
     f8 = #66;
     f9 = #67;
     f10 = #68;

     Shift_f1 = #84;
     Shift_f2 = #85;
     Shift_f3 = #86;
     Shift_f4 = #87;
     Shift_f5 = #88;
     Shift_f6 = #89;
     Shift_f7 = #90;
     Shift_f8 = #91;
     Shift_f9 = #92;
     Shift_f10 =#93;

     Ctl_f1 = #94;
     Ctl_f2 = #95;
     Ctl_f3 = #96;
     Ctl_f4 = #97;
     Ctl_f5 = #98;
     Ctl_f6 = #99;
     Ctl_f7 = #100;
     Ctl_f8 = #101;
     Ctl_f9 = #102;
     Ctl_f10 =#103;

     Alt_f1 = #104;
     Alt_f2 = #105;
     Alt_f3 = #106;
     Alt_f4 = #107;
     Alt_f5 = #108;
     Alt_f6 = #109;
     Alt_f7 = #110;
     Alt_f8 = #111;
     Alt_f9 = #112;
     Alt_f10 =#113;

     Arrow_down = #80;
     Arrow_up = #72;
     Arrow_left = #75;
     Arrow_right = #77;
     Page_down = #81;
     Page_up = #73;
     Key_home = #71;
     Key_end = #79;
     Key_ins = #82;
     Key_del = #83;

     Shift_tab = #15;

     Ctl_Arrow_left = #115;
     Ctl_Arrow_right = #116;
     Ctl_Page_up = #132;
     Ctl_Page_down = #118;
     Ctl_Key_end = #117;
     Ctl_Key_home = #119;

     Alt_Q = #16;
     Alt_W = #17;
     Alt_E = #18;
     Alt_R = #19;
     Alt_T = #20;
     Alt_Y = #21;
     Alt_U = #22;
     Alt_I = #23;
     Alt_O = #24;
     Alt_P = #25;
     Alt_A = #30;
     Alt_S = #31;
     Alt_D = #32;
     Alt_F = #33;
     Alt_G = #34;
     Alt_H = #35;
     Alt_J = #36;
     Alt_K = #37;
     Alt_L = #38;
     Alt_Z = #44;
     Alt_X = #45;
     Alt_C = #46;
     Alt_V = #47;
     Alt_B = #48;
     Alt_N = #49;
     Alt_M = #50;

{----------------------------------------------------------}

TYPE
    pointer_fkey = ^control_func_key;
                   { указатель на обьект управления }
                   { функциональной клавиатурой     }

    func_key = ARRAY [ 0..255 ] OF RunProcedure;
    logical = ARRAY [ 0..255 ] OF BOOLEAN;
                   { набор указателей на процедуры  }
                   {     выполняемые по нажатию     }
                   {     функциональных клавиш      }

    parameters = RECORD   { параметры }

                       point_param : ARRAY [ 0..255 ] OF POINTER;
                       size_param : ARRAY [ 0..255 ] OF WORD
                 END;

    control_func_key = OBJECT
    		   { обьект по управлению функциональной }
                   {          клавиатурой                }

                   up : pointer_fkey;
                               { указатель на следующий по }
                               {      цепочке обьект       }

                   point_proc : ^func_key;
                               { указатель на набор указателей }
                               {           процедур            }

                   label_proc : ^logical;
                               { метки наличия установленных процедур }

                   param : ^parameters;
                               { парамеры обьекта }

                   CONSTRUCTOR init;
                               { инициализация обьекта }

                   PROCEDURE set_key ( key : CHAR;  proc : RunProcedure );
                             VIRTUAL;
                                { установить процедуру по заданной }
                                {    функциональной клавиши для    }
                                { последнего по вложенности обьекта}

                   PROCEDURE get_key ( key : CHAR; VAR proc : RunProcedure );
                             VIRTUAL;
                                { получить указатель на процедуру    }
                                { по заданной функциональной клавише }
                                { для последненго по вложенности     }
                                {              обьекта               }

                   PROCEDURE set_param ( num : BYTE; VAR parametr;
                             size : WORD ); VIRTUAL;
                                { установить параметр с заданным }
                                {          номером               }

                   PROCEDURE get_param ( num : BYTE; VAR parametr );
                             VIRTUAL;
                                { получить параметр с заданным }
                                {          номером             }

                   PROCEDURE push_clear; VIRTUAL;
                                { сохраняет назначения текущего обьекта }
                                { в "стеке" и создает новый текущий     }
                                {    обьект с очисткой всех старых      }
                                {              назначений               }

                   PROCEDURE push_save; VIRTUAL;
                                { сохраняет назначения текущего обьекта }
                                { в "стеке" и создает новый текущий     }
                                {    обьект с сохранением всех старых   }
                                {              назначений               }

                   PROCEDURE pop; VIRTUAL;
                                { удаляет все текущие назначения и    }
                                { восстанавливает из стека предыдущие }

                   PROCEDURE run_for_key ( VAR key : CHAR ); VIRTUAL;
    	                        { исполнить по заданной клавише }
                                { для последнего по вложенности }
                                {            обьекта            }

                   FUNCTION run_char : CHAR; VIRTUAL;
                                { ввести значение клавиши и исполнить }
                                {     если требуется необходимую      }
                                {     процедуру по фунц. клавише      }

                   DESTRUCTOR done;
                                { уничтожение тукущего обьекта }

                       END; { object control_func_key }

PROCEDURE null;
          { процедура не осуществляет }
          {     никаких действий      }

{----------------------------------------------------------}

IMPLEMENTATION    { секция реализации }

PROCEDURE null;
          { процедура не осуществляет }
          {     никаких действий      }

BEGIN

END; { procedure null }

{----------------------------------------------------------}

CONSTRUCTOR control_func_key.init;

            { инициализация обьекта }
VAR
   indx : BYTE;
              { индексная переменная }
BEGIN
     up := NIL;
     NEW ( point_proc );
     NEW ( label_proc );
     NEW ( param );
     FOR indx := 0 TO 255 DO
         BEGIN
              point_proc^[ indx ] := NulRunProcedure;
              label_proc^[ indx ] := FALSE;
              param^.point_param [ indx ] := NIL;
              param^.size_param [ indx ] := 0
         END

END; { constroctor  control_func_key.init }

{----------------------------------------------------------}

PROCEDURE control_func_key.push_clear;

          { инициализация следующего по цепочке обьекта }
          { с уничтожением предыдущих назначений по     }
          {        функциональной клавиатуре            }
BEGIN
     IF ( up <> NIL ) THEN
        up^.push_clear
     ELSE
         BEGIN
              NEW ( up );
              up^.init
         END

END; { procedure  control_func_key.push_clear }

{----------------------------------------------------------}

PROCEDURE control_func_key.push_save;

          { инициализация следующего по цепочке обьекта }
          {  с сохранением предыдущих назначений по     }
          {        функциональной клавиатуре            }
VAR
   indx : BYTE;
             { индексная переменная }
BEGIN
     IF ( up <> NIL ) THEN
        up^.push_save
     ELSE
         BEGIN
              NEW ( up );
              up^.init;
              FOR indx := 1 TO 255 DO
                  BEGIN
                       up^.point_proc^[ indx ] := point_proc^[ indx ];
                       up^.label_proc^[ indx ] := label_proc^[ indx ]
                  END
         END

END; { procedure control_func_key.push_save }

{----------------------------------------------------------}

PROCEDURE control_func_key.pop;

          { удаление текущих назначений и восстановление }
          {          из "стека" предыдущих               }
BEGIN
     IF ( up = NIL ) THEN
        EXIT;
     IF ( up^.up <> NIL ) THEN
        up^.pop
     ELSE
         BEGIN
              up^.done;
              DISPOSE ( up );
              up := NIL
         END

END; { procedure control_func_key.pop }

{----------------------------------------------------------}

PROCEDURE control_func_key.set_key ( key : CHAR; proc : RunProcedure );

         { установить процедуру по }
         {   назначенной клавише   }
BEGIN
     IF ( up <> NIL ) THEN
        up^.set_key ( key, proc )
     ELSE
         BEGIN
              point_proc^[ ORD ( key ) ] := proc;
              label_proc^[ ORD ( key ) ] := TRUE
         END

END; { procedure control_func_key.set_key }

{----------------------------------------------------------}

PROCEDURE control_func_key.get_key ( key : CHAR; VAR proc : RunProcedure );

         { получить процедуру по заданной }
         {           клавише              }
BEGIN
     IF ( up <> NIL ) THEN
        up^.get_key ( key, proc )
     ELSE
         proc := point_proc^[ ORD ( key ) ]

END; { procedure control_func_key.get_key }

{----------------------------------------------------------}

PROCEDURE control_func_key.set_param ( num : BYTE; VAR parametr;
				       size : WORD );

        { установить заданный параметр }
VAR
    Help : WORD;

BEGIN
     IF ( size = 0 ) THEN
        EXIT;
     IF ( up <> NIL ) THEN
        up^.set_param ( num, parametr, size )
     ELSE
         WITH param^ DO
              BEGIN
                   Help := size_param [ num ];
                   IF ( ( point_param [ num ] <> NIL ) AND ( size <> 0 )
                      AND ( Size <> size_param [ num ] )  ) THEN
                      BEGIN
                           FREEMEM ( point_param [ num ], size_param [ num ] );
                           point_param [ num ] := NIL
                      END;
                   IF ( ( size <> 0 ) AND ( size <> size_param [ num ] ) )
                      THEN
                          GETMEM ( point_param [ num ], size );
                   size_param [ num ] := size;
                   MOVE ( parametr, point_param [ num ]^, size )
              END

END; { procedure control_func_key.set_param }

{----------------------------------------------------------}

PROCEDURE control_func_key.get_param ( num : BYTE; VAR parametr );

         { получить заданный параметр }
BEGIN
     IF ( up <> NIL ) THEN
        up^.get_param ( num, parametr )
     ELSE
         WITH param^ DO
              IF ( point_param [ num ] <> NIL ) THEN
                 MOVE ( point_param [ num ]^, parametr, size_param [ num ] )

END; { procedure control_func_key.get_param }

{----------------------------------------------------------}

PROCEDURE control_func_key.run_for_key ( VAR key : CHAR );

         { выполнить процедуру по заданой клавише }
         { и если процедура была выполнена, то    }
         {     в качестве key возвратить #0       }
BEGIN
     IF ( up <> NIL ) THEN
        up^.run_for_key ( key )
     ELSE
         IF ( label_proc^[ ORD ( key ) ] ) THEN
            BEGIN
                 point_proc^[ ORD ( key ) ];
                 key := #0
            END

END; { procedure control_func_key.run_for_key }

{----------------------------------------------------------}

FUNCTION control_func_key.run_char : CHAR;

         { ввод кода нажатой клавиши, интерпритация }
         { ESC последовательности и выполнение по   }
         {    необходимости заданной процедуры      }
VAR
   ch : CHAR;
            { переменная опроса }
BEGIN
     IF ( up <> NIL ) THEN
        ch := up^.run_char
     ELSE
         BEGIN
              ch := READKEY;
              IF ( KEYPRESSED ) THEN
                 BEGIN
                      ch := READKEY;
                      IF ( label_proc^[ ORD ( ch ) ] ) THEN
                         BEGIN
                              point_proc^[ ORD ( ch ) ];
                              ch := #0
                         END
                 END;
              run_char := ch
         END

END; { function control_func_key.run_char }

{----------------------------------------------------------}

DESTRUCTOR control_func_key.done;

         { уничтожение обьекта }
VAR
   indx : BYTE;
               { индексная переменная }
BEGIN
     DISPOSE ( point_proc );
     DISPOSE ( label_proc );
     WITH param^ DO
          FOR indx := 0 TO 255 DO
              IF ( point_param [ indx ] <> NIL ) THEN
                 FREEMEM ( point_param [ indx ], size_param [ indx ] );
     DISPOSE ( param )

END; { destructor control_func_key.done }

{----------------------------------------------------------}

END.
