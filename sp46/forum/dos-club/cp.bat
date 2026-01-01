@echo off
if "%1" == "?" goto help
if "%1" == "" set disk=D:
if not "%1" == "" set disk=%1
echo ┌───────────────────────────────────────────────┐
echo │    Копирование ДИСКЕТА-ВИНЧЕСТЕР-ДИСКЕТА      │
echo │               "ТехИнформ"                     │
echo └───────────────────────────────────────────────┘
echo ┌───────────────────────────────────────────────┐
echo │ Схема копирования Диск A: - Диск %disk% - Диск A: │
echo │ --------------------------------------------- │
echo │ Можно изменить при запуске, например:  CP C:  │
echo └───────────────────────────────────────────────┘
echo  
be ask "Дискеты стандартной разметки (360 Kb, 1.2 Mb) ? (Y/N) [Y] " yn DEFAULT=y
if not errorlevel 2 set form=st
if "%form%" == "st" goto bak:
800 > nul
:bak
md %disk%\cpwd#### > nul
echo  
be ask "Вставьте ИСХОДНУЮ дискету в устройство A: и нажмите любую клавишу..."
echo  
echo Выполняется копирование с дискеты на винчестер...
xcopy a:\*.* %disk%\cpwd#### /s > nul
echo  
be ask "Вставьте ЧИСТУЮ дискету в устройство A: и нажмите любую клавишу..."
echo  
be ask "ФОРМАТИРОВАТЬ эту дискету ? (Y/N) [N] " yn DEFAULT=n
if errorlevel 2 goto cont01
echo  
echo Выберите необходимый формат:
echo ┌──────────────────────────────────┐
echo │ S - стандартный для дисковода A: │
echo │ 3 - на 360  Кбайт                │
if not "%form%" == "st" echo │ 7 - на 720  Кбайт                │
if not "%form%" == "st" echo │ 8 - на 800  Кбайт                │
echo └──────────────────────────────────┘
if not "%form%" == "st" goto nonst:
be ask "Введите S, или 3: [S] " s3 DEFAULT=s
if errorlevel 2 goto frm360
goto stnd:
:nonst
be ask "Введите S, 3, 7, или 8: [S] " s378 DEFAULT=s
if errorlevel 4 goto frm800
if errorlevel 3 goto frm720
if errorlevel 2 goto frm360
:stnd
echo  
echo Стандартное форматирование дискеты A: ...
echo  
format a:
goto cont02
:frm800
echo  
echo Форматирование дискеты A: (на 800 Кб)...
echo  
format a: /t:80/n:10
goto cont02
:frm720
echo  
echo Форматирование дискеты A: (на 720 Кб)...
echo  
format a: /t:80/n:9
goto cont02
:frm360
echo  
echo Форматирование дискеты A: (на 360 Кб)...
echo  
format a: /4
goto cont02
:cont01
echo  
be ask "ОЧИСТИТЬ эту дискету ? (Y/N) [N] " yn DEFAULT=n
if errorlevel 2 goto cont02
zap2 a:\ /s /a > nul
:cont02
echo  
echo Выполняется копирование с винчестера на дискету...
xcopy %disk%\cpwd####\*.* a:\ /s > nul
zap2 %disk%\cpwd##### /a /s > nul
echo  
be ask "Есть еще дискеты для копирования ? (Y/N) [N] " yn DEFAULT=n
if not errorlevel 2 goto bak
echo  
echo ┌───────────────────────────────────────────────────────────────┐
echo │...Копирование закончено... (с) ТехИнформ, 1992, тел.216-25-02 │
echo └───────────────────────────────────────────────────────────────┘
goto end
:help
echo  
echo Программе CP должны быть доступны следующие утилиты:
echo  
echo 1) BE.EXE     (из пакета Norton Utilites 6.0)
echo 2) FORMAT.COM (из MS-DOS)
echo 3) XCOPY.COM  (тоже из MS-DOS)
echo 4) 800.COM    
echo 5) ZAP2.COM   
echo  
echo При запуске программы CP можно изменить диск для промежуточного
echo копирования информации (по умолчанию - D:), например: CP C: 
echo  
echo Программа CP создает временный каталог CPWD#### на винчестере,
echo который удаляется в случае успешного завершения работы CP 
echo  
echo На винчестере должно быть достаточно места для размещения всей
echo информации одной дискеты !
:end
echo on
