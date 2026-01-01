@echo off
echo.
echo Архивирование с подкаталогами. Архиватор LHA.
if %1.==. goto error
echo.
ask "Удалять информацию после архивирования? [Y/N]",YN
if errorlevel=2 goto notdel
if errorlevel=1 goto del

:del
@lha m /r1x1 %1 
goto exec

:notdel
@lha a /r1x1 %1 

:exec
ask "Создать самооткрывающийся архив? [Y/N]",YN
if errorlevel=2 goto ends
if errorlevel=1 goto self

:self
@lha s /x1 %1

:ends
echo.
echo Архивирование завершено.
goto konec

:error
echo.
echo Ошибка при задании параметров.
echo.
echo Формат вызова: lhasub [имя_архива]

:konec