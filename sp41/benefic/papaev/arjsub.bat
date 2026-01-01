@echo off
echo.
echo Архивирование с подкаталогами. Архиватор ARJ.
if %1.==. goto error
ask "Удалять информацию после архивирования? [Y/N]",YN
if errorlevel=2 goto notdel
if errorlevel=1 goto del

:del
ask "Создать самооткрывающийся архив? [Y/N]",YN
if errorlevel=2 goto noselfm
if errorlevel=1 goto selfm
:selfm
@arj m -r -je %1
goto ends
:noselfm
@arj m -r %1
goto ends

:notdel
ask "Создать самооткрывающийся архив? [Y/N]",YN
if errorlevel=2 goto noselfa
if errorlevel=1 goto selfa
:selfa
@arj a -r -je %1
goto ends
:noselfa
@arj a -r %1
goto ends


:ends
echo.
echo Архивирование завершено.
goto konec

:error
echo.
echo Ошибка при задании параметров.
echo.
echo Формат вызова: arjsub [имя_архива]

:konec