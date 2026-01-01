
                        {----------------------------------}
                        {               MUSIC  V 1.0       }
                        {                                  }
                        { Пакет подпрограмм для работы с   }
                        {           фоновой музыкой        }
                        {     (c) 1990, Мигач Ярослав      }
                        {----------------------------------}

UNIT music;

INTERFACE

USES Dos, Crt;

CONST
        max_ms = 20;    { максимальное количество }
                        { инициируемых мелодий   }


PROCEDURE Play_on ( ms : INTEGER );
                { запуск фоновой мелодии с заданным }
                {               номером             }

PROCEDURE Play_off;
                { Выключить мелодию                }
                { Эта процедура обязательно должна }
                { быть вызвана при завершении      }
                { программы пользователя           }

PROCEDURE n_music ( ms : INTEGER; sz : INTEGER );
                { Создать новую мелодию с заданным      }
                { номером, и отвести под нее            }
                { определенное число тактов             }

PROCEDURE d_music ( ms : INTEGER );
                { Освободить память из под ранее   }
                { использованной мелодии с заданным}
                {               номером            }

PROCEDURE note ( th_sound, tt_sound : INTEGER );
                { Добавление нового такта в     }
                {       текущую мелодию         }

PROCEDURE TestPlay;
                { отладочная процедура }

{        В одной мелодии не может содержатся более чем 999 тактов.
 Каждый такт представляет собой частоту в герцах и длительность
 звучания динамика на этой частоте. Длительность задается в
 миллисекундах, однако всегда будет приводится к числу,
 кратному 55 мс. Частота звучания < 55, указывает на то, что динамик
 необходимо отключить. При этом осуществляется переход к началу
 проигрывания текущей мелодии. Таким образом возможно осуществление
 циклического проигрывания мелодии. Если будет произведено обращение
 к мелодии которая небыла инициализирована, то исполнение музыки
 автоматически прекращается. Невозможно выполнить процедуры обработки
 мелодии исполняемой в текущий момент времени. }

IMPLEMENTATION

CONST
        vec = $1C;

VAR
        svint  : POINTER;       { переменная для сохранения   }
                                { базового вектора прерывания }
                                {       по Int 1c             }

        ton, del : POINTER; { указатели на массив тона и }
                            { и длительности звучания    }

        ptic, ptact : POINTER;

        number : INTEGER;       { содержит номер текущей }
                                { исполняемой мелодии    }

        temp_ms : INTEGER;      { содержит номер обрабатываемой }
                                {       мелодии                 }


TYPE
        melodi = ARRAY [ 1..1000 ] OF
                                RECORD
                                        h_sound : INTEGER; { частота }
                                        t_sound : INTEGER  { длительность }
                                END;

VAR
   rec_melodi : ARRAY [ 1..max_ms ] OF
                    RECORD
                          pm : ^melodi; { ссылка на мелодию }
                          szm : INTEGER; { максимальное число }
                                        {       тактов           }
                          tmp : INTEGER  { номер заполняемого }
                                        {       такта            }
                     END;

        now_melodi : RECORD
                        tn : ARRAY [ 1..1000 ] OF INTEGER;
                        dl : ARRAY [ 1..1000 ] OF INTEGER;
                        szm : INTEGER
                     END;
        HZ : INTEGER;


        tic : INTEGER;          { содержит количество тиков     }
                                { по 55 мс, которые осталось    }
                                { отсчитать до переключения     }
                                { следующего такта мелодии      }

        tact : INTEGER; { содержит текущий такт         }
                        { исполняемой в данный момент   }
                        { времени мелодии               }



{$L INT1C } { Подключение обьектного модуля с }
            { низкоуровневым обработчиком     }
            {   прерывания Int 1c             }

{$F+}
PROCEDURE newint; EXTERNAL;
                { Низкоуровневая процедура обработки }
                { прерывания из обьектного модуля    }
                {       INT1c   ( тип FAR )          }
{$F-}
PROCEDURE sd_off; EXTERNAL;
                { Отключение динамика }

PROCEDURE sd_on; EXTERNAL;
                { включение динамика }

PROCEDURE ANALIZ; EXTERNAL;
                { процедура анализа переключения }
                { режимов работы динамика        }

PROCEDURE inintr; EXTERNAL;

PROCEDURE Play_on ( ms : INTEGER );
                { Процедура производит включение мелодии }
                { с номером ms. Если указанный номер     }
                { несуществует, то производится          }
                {       выключение мелодии               }

VAR
        indx : INTEGER;

BEGIN
        SetIntVec ( vec, svint );
        IF ( ( ms < 1 ) OR ( ms > max_ms ) ) THEN
                BEGIN
                        SetIntVec ( vec, svint );
                        EXIT
                END;
        tact := 1;
        number := ms;
        FOR indx := 1 TO rec_melodi [ ms ].szm DO
                BEGIN
                        IF ( rec_melodi [ ms ].pm^[ indx ].h_sound > 0 ) Then
                            now_melodi.tn[indx] := ( 11900 DIV
                              rec_melodi [ ms ].pm^[ indx ].h_sound  ) * 100
                        ELSE
                            now_melodi.tn [ indx ] := 0;
                        now_melodi.dl [ indx ] :=
                                rec_melodi [ ms ].pm^[ indx ].t_sound DIV 55
                END;
        now_melodi.szm := rec_melodi [ ms ].szm;
        tic := 10;
        SetIntVec ( vec, @newint )

END; { procedure Play_on }

PROCEDURE Play_off;
                { Отключение мелодии }

BEGIN
        SetIntVec ( vec, svint );
        sd_off

END; { procedure Play_off }

PROCEDURE TestPlay;
                { отладочная процедура }
VAR
   ch : CHAR;

BEGIN
     Play_on ( 1 );
     Play_off;
     Tact := 1;
     WHILE (( now_melodi.tn [ tact ] <> 0 ) OR ( now_melodi.dl [ tact ]
            <> 0 ) ) DO
            BEGIN
                WRITE (' tn = ',now_melodi.tn [ tact ] );
                WRITELN ( ' dl = ',now_melodi.dl [ tact ]  );
                WRITELN (' tic = ',tic,'  HZ = ', HZ );
                ANALIZ;
                DELAY ( tic * 55 );
                Play_off;
                IF KEYPRESSED THEN
                   BEGIN
                        ch := READKEY;
                        IF ( ch = #$0D ) THEN
                           EXIT
                   END;
                INC ( Tact )
            END
END; { procedure TestPlay }


PROCEDURE       n_music ( ms : INTEGER; sz : INTEGER );
                { Процедура иницирования новой мелодии }
                { с номером ms и отведения под нее     }
                { заданного числа тактов sz                 }

BEGIN
        IF ( ( ms < 1 ) OR ( ms > max_ms ) OR ( ms = number )
                OR ( sz < 1 ) OR ( sz > 999 ) ) THEN
                BEGIN
                        temp_ms := 0;
                        EXIT
                END;
        temp_ms := ms;
        WITH rec_melodi [ ms ] DO
                BEGIN
                        FREEMEM ( pm, szm * 4 );
                        GETMEM ( pm, sz * 4 );
                        IF ( pm = NIL ) THEN
                                BEGIN
                                        temp_ms := 0;
                                        EXIT
                                END;
                        szm := sz;
                        tmp := 1;
                        WITH pm^[1] DO
                                BEGIN
                                        h_sound := 0;
                                        t_sound := 0
                                END
                END

END; { procedure n_music }

PROCEDURE d_music ( ms : INTEGER );
                { процедура освобождения памяти из под }
                { ранее используемой мелодии                }

BEGIN
        IF ( ( ms < 1 ) OR ( ms > max_ms ) OR ( ms = number ) ) THEN
                EXIT;
        WITH rec_melodi [ ms ] DO
                BEGIN
                        FREEMEM ( pm, szm * 4 );
                        szm := 1;
                        GETMEM ( pm, szm * 4 );
                        temp_ms := 0;
                        WITH pm^[1] DO
                                BEGIN
                                        h_sound := 0;
                                        t_sound := 0
                                END
                END

END; { procedure d_music }

PROCEDURE note ( th_sound, tt_sound : INTEGER );
                { добавление нового такта в текущую }
                {               мелодию                          }

BEGIN
        IF ( ( temp_ms = 0 ) OR ( temp_ms = number ) ) THEN
                EXIT;
        WITH rec_melodi [ temp_ms ] DO
                BEGIN
                        IF ( tmp = szm ) THEN
                                BEGIN
                                        temp_ms := 0;
                                        EXIT
                                END;
                        pm^[ tmp ].h_sound := th_sound;
                        pm^[ tmp ].t_sound := tt_sound;
                        INC ( tmp );
                        pm^[ tmp ].h_sound := 0;
                        pm^[ tmp ].t_sound := 0
                END;

END; { procedure note }

PROCEDURE init_music;
                { Процедура инициализации пакета }

VAR
        indx : INTEGER;

BEGIN
        GetIntVec ( vec, svint );
        FOR  indx := 1 TO max_ms DO
                WITH rec_melodi [ indx ] DO
                        BEGIN
                                szm := 1;
                                GETMEM ( pm, szm * 4 );
                                WITH pm^[1] DO
                                        BEGIN
                                                h_sound := 0;
                                                t_sound := 0
                                        END
                        END;
        temp_ms := 0;
        number := 0;
        tic := 0;
        tact := 0;
        ton := @now_melodi.tn;
        del := @now_melodi.dl;
        ptic := @tic;
        ptact := @tact;
        inintr

END; { procedure init_music }

BEGIN
        init_music

END.
