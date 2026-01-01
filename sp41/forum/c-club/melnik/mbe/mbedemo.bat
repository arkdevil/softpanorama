@Echo Off

Rem       Демонстрация работы программы  MBE ( Melnik Batch Enchanced )

MBE title
If Errorlevel 255 Goto Break

:Main
MBE Main
If Errorlevel 255 Goto Break
If Errorlevel 5 Goto Quit
If Errorlevel 4 Goto Manager
If Errorlevel 3 Goto Window
If Errorlevel 2 Goto Input
If Errorlevel 1 Goto Output
If Errorlevel 0 Goto Quit
Goto End

:Output
MBE Output
If Errorlevel 255 Goto Break
If Errorlevel 6 Goto Cls
If Errorlevel 5 Goto Sound
If Errorlevel 4 Goto Cursor
If Errorlevel 3 Goto Fill
If Errorlevel 2 Goto StrPrn
If Errorlevel 1 Goto Str
If Errorlevel 0 Goto Main
Goto End

:Cls
MBE Cls
Goto Output

:Sound
MBE Sound
Goto Output

:Cursor
MBE Cursor
Goto Output

:Fill
MBE Fill
Goto Output

:StrPrn
MBE StrPrn
MBE Printing
Goto Output

:Str
MBE  Str
Goto Output

:Input
MBE Input
If Errorlevel 255 Goto Break
If Errorlevel 5 Goto IfEsc
If Errorlevel 4 Goto GetKey
If Errorlevel 3 Goto KeyList
If Errorlevel 2 Goto YesNo
If Errorlevel 1 Goto AnyKey
If Errorlevel 0 Goto Main
Goto End

:IfEsc
MBE IfEsc
If Errorlevel 255 Goto Break
Goto Input

:GetKey
MBE GetKey
If Errorlevel 255 Goto Break
Goto Input

:KeyList
MBE KeyList
If Errorlevel 255 Goto Break
Goto Input

:YesNo
MBE YesNo
If Errorlevel 255 Goto Break
Goto Input

:AnyKey
MBE AnyKey
If Errorlevel 255 Goto Break
Goto Input

:Window
MBE Window
If Errorlevel 255 Goto Break
Goto Main

:Manager
MBE Manager
If Errorlevel 255 Goto Break
Goto Main

:Quit
MBE Quit
If Errorlevel 255 Goto Break
If Errorlevel 2 Goto Main
If Errorlevel 1 Goto End
If Errorlevel 0 Goto Main
Goto End

:End
MBE End
If Errorlevel 255 Goto Break
Goto Success

:Break
Echo Ошибка в работе программы!

:Success

Rem     Конец демонстрации работы программы MBE ( Melnik Batch Enchanced )
