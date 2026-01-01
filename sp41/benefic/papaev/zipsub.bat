@echo off
echo.
echo Архивирование с подкаталогами. Архиватор LHA.
if %1.==. goto error
echo.
ask "Удалять информацию после архивирования? [Y/N]",YN
if errorlevel=2 goto notdel
if errorlevel=1 goto del

:del
@pkzip -rpm %1 
goto ends

:notdel
@pkzip -rpa %1 

:ends
echo.
echo Архивирование завершено.
goto konec

:error
echo.
echo Ошибка при задании параметров.
echo.
echo Формат вызова: zipsub [имя_архива]

:konec