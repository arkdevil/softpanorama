//   my_get.ch
//
// Файл заголовка для поддержки синтаксиса 
// модернизированной GET системы
//  Copyright (c) 1992 МП " КАСТ "  Васильев Игорь Викторович 
//                      г. Самара
//
//
***
*  @..GET_SHOW
*

#command @ <row>, <col> [GET_SHOW   <g_proc1>]                                  ;
                        [GET_PROC   <g_proc2>]                                  ;
                        [VALID <valid>]                                         ;
                        [WHEN <when>]                                           ;
                                                                                ;
        =>    Grow_getlist( @GetList,                                           ;
        _V_GET_( <{g_proc1}>, <{g_proc2}> ,<{valid}>,<{when}>,<row>,<col> )       ;
                          )


***
*  @..GET
*

#command @ <row>, <col> GET <var>                                       ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                                                                        ;
      => SetPos( <row>, <col> )                                         ;
               ; Grow_getlist( @GetList,                                         ;
               _GET_( <var>, <(var)>, <pic>, <{valid}>, <{when}> )      ;
                             )



***
*  PUT GETS TO <array>
*

#command    PUT GETS TO <array>                                         ;
            => <array> := GetList					;
	    ; Getlist := {}



***********
*  READ
*

#command READ  FROM <array>                                             ;
        =>                                                              ;
        ReadModal(@<array>)



#command READ  FROM <array>                                             ;
        FIRST  <ccol>,<rrow>                                            ;
        =>                                                              ;
        <array>\[1,1]:cargo\[3] := <ccol>                               ;
        ; <array>\[1,1]:cargo\[4] := <rrow>                             ;
        ; ReadModal(@<array>)



#command READ 				                                ;
        =>                                                              ;
        ReadModal(GetList)



#command READ FIRST  <ccol>,<rrow>                                      ;
        =>                                                              ;
        GetList\[1,1]:cargo\[3] :=   <ccol>                             ;
        ; GetList\[1,1]:cargo\[4] := <rrow>                             ;
        ; ReadModal(@GetList)



***
*  CLEAR GETS
*

#command CLEAR GETS IN <array>                                          ;
      => __KillRead()                                                   ;
       ; <array> := {}                                                  ;
       ; GetList := {}


#command CLEAR GETS                                                     ;
      => __KillRead()                                                   ;
       ; GetList := {}