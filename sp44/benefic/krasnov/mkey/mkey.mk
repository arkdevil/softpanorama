1:
2:
3:      "#include \".h\"" rep 3 Left end
4:      "#define "
5:
6:
7:
8:      "/*  */" rep 3 Left end
9:      " ();" rep 2 Left end
0:
[:      " []" Left
A:      M_Left "} else if (){" rep 2 Left end
B:      "break;"
C:      M_Left "case :" Enter M_Space "break;" Up End Left
D:      M_Left "default:" Enter M_Space
E:      M_Left "} else {" Enter M_Space
F:      "for (){" Enter "}" Up End rep 2 Left end
G:      "goto ;" Left
H:      "#include <.h>" rep 3 Left end
I:      "if (){" Enter "}" Up End rep 2 Left end
J:      "i = 0; i < ; i++" rep 5 Left end
K:      "Дата: " Date day rus " Время: " Time sec Home
L:      Time hund Home
M:      Home "main (int argc, char *argv []){" Enter Enter "}" Up Home M_Space
N:      End Enter M_Space
O:      CDir " " CDir C: Home
P:      Home Enter Up
Q:
R:      "return ;" Left
S:      "switch (){" Enter "}" Up End rep 2 Left end
T:      Home Enter Up "/*" rep 42 " " end rep 19 "*" end Enter \
        " *" rep 42 " " end "*  P R O G R A M  *" Enter \
        "*" rep 42 " " end "* " Date day rus " *" Enter \
        "*" rep 42 " " end rep 19 "*" end Enter "*/" rep 3 Up end C_Right
U:      "do {" Enter Enter "} while ();" rep 2 Left end Up
V:      "Версия от " Date rus " г."
W:      "while (){" Enter "}" Up End rep 2 Left end
X:      "extern "
Y:
Z:      "sizeof ()" Left
':      "\"\\n\"" rep 3 Left end

Bksp:   rep 4 Left Del end
Enter:  End Enter
Space:  "    "
Esc:    "exit" Enter

Up:     Up Home
Down:   Down Home
Left:   rep 4 Left end
Right:  rep 4 Right end
Home:   Enter Up C_Y                    { Удаление с начала строки }
End:    Enter C_Y Up End                { Удаление до конца строки }

CapsLock: "tc "  C_J Enter
SysReq:   "td "  C_J Enter
R_Shift:  "eds " C_J Enter
PrtSc:    "pp "  C_J Enter

                Определения клавиш для Turbo C:

F1:     C_Q "f"                         { Поиск контекста }
F2:     C_Q "a"                         { Замена контекста }
F3:     Home C_K "b" Down C_K "k"       { Выделение строки }
F4:     C_K "h"                         { Снятие выделения фрагмента }
F5:     Home C_K "c"                    { Копирование фрагмента }
F6:     Home C_K "v"                    { Перемещение фрагмента }
F7:     C_K "b"                         { Начало фрагмента }
F8:     C_K "k"                         { Конец фрагмента }

F10:    A_F "O"                         { Временный выход в DOS }

Plus:   Home Down C_K "k"               { Включение текущей строки в фрагмент }
Minus:  Home Up C_K "k"                 { Исключение предыдущей строки из фрагмент }

