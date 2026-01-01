/////////////////////////////////////////////////////////////
// Определение индексов массива
#define B_SIZE          7

#define B_ROW           1
#define B_LEFT          2
#define B_LEN           3
#define B_COUNT         4
#define B_NUM           5
#define B_COLOR         6
#define B_STR           7

// Создать новый массив для индикации
#command CREAT BAR <top>,<left> LINELEN <len> ;
         COUNT <count> TO <aArray> => ;
                            <aArray> := Array(B_SIZE)     ;;
                            <aArray>\[B_ROW   ] := <top>  ;;
                            <aArray>\[B_LEFT  ] := <left> ;;
                            <aArray>\[B_LEN   ] := <len>  ;;
                            <aArray>\[B_COUNT ] := <count>;;
                            <aArray>\[B_COLOR ] := 'W+/B*';;
                            <aArray>\[B_NUM   ] := 0      ;;// к-во вызовов
                            <aArray>\[B_STR   ] := Replicate('▒', <aArray>\[B_LEN])

#command CREAT BAR <top>,<left> LINELEN <len> ;
         COUNT <count> COLOR <color> TO <aArray> => ;
                            <aArray> := Array(B_SIZE)     ;;
                            <aArray>\[B_ROW   ] := <top>  ;;
                            <aArray>\[B_LEFT  ] := <left> ;;
                            <aArray>\[B_LEN   ] := <len>  ;;
                            <aArray>\[B_COUNT ] := <count>;;
                            <aArray>\[B_COLOR ] := <color>;;
                            <aArray>\[B_NUM   ] := 0      ;; // к-во вызовов
                            <aArray>\[B_STR   ] := Replicate('▒', <aArray>\[B_LEN])

#command DISPLAY BAR <aBar> =>;
  DevPos(<aBar>\[ B_ROW ], <aBar>\[ B_LEFT ]);
  DevOut(StrTran(<aBar>\[B_STR],"▒",'█',1,;
         (<aBar>\[B_LEN]*(++<aBar>\[B_NUM])/<aBar>\[B_COUNT])+0.5),;
              <aBar>\[B_COLOR]   )

#command SET BAR <aBar> TO <nPos> => <aBar>\[B_NUM] := <nPos>

/////////////////////////////////////////////////////////////
// Определение индексов массива
#define S_SIZE          6

#define S_ROW           1
#define S_LEFT          2
#define S_LEN           3
#define S_NUM           4
#define S_COLOR         5
#define S_STR           6

// Создать новый массив для индикации
#command CREAT SKI <top>,<left> LINELEN <len> TO <aArray> => ;
                            <aArray> := Array(S_SIZE)     ;;
                            <aArray>\[S_ROW   ] := <top>  ;;
                            <aArray>\[S_LEFT  ] := <left> ;;
                            <aArray>\[S_LEN   ] := <len>  ;;
                            <aArray>\[S_COLOR ] := 'W+/B*';;
                            <aArray>\[S_NUM   ] := 0      ;;// к-во вызовов
                            <aArray>\[S_STR   ] := Replicate('▒', <aArray>\[S_LEN])

#command CREAT SKI <top>,<left> LINELEN <len> COLOR <color> TO <aArray> => ;
                            <aArray> := Array(S_SIZE)     ;;
                            <aArray>\[S_ROW   ] := <top>  ;;
                            <aArray>\[S_LEFT  ] := <left> ;;
                            <aArray>\[S_LEN   ] := <len>  ;;
                            <aArray>\[S_COLOR ] := <color>;;
                            <aArray>\[S_NUM   ] := 0      ;; // к-во вызовов
                            <aArray>\[S_STR   ] := Replicate('▒', <aArray>\[S_LEN])

#command DISPLAY SKI <aSki> =>;
  DevPos(<aSki>\[ S_ROW ], <aSki>\[ S_LEFT ]);
  DevOut(Stuff(<aSki>\[S_STR],;
            If(++<aSki>\[S_NUM] > <aSki>\[S_LEN],(<aSki>\[S_NUM] :=0 ),;
                                                 <aSki>\[S_NUM]),;
              1,'█'),;
              <aSki>\[S_COLOR])

