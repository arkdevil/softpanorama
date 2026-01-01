@echo off
rem
rem    Перед Вами - простая программа на командном языке DOS.
rem  Посмотрите внимательно на предпоследнюю строку. Если Вы полагаете,
rem  что она будет выведена на экран один раз - значит COMMAND.COM
rem  написали не Вы!
rem    Правильный ответ: строка выведется дважды. Проверьте сами.
rem
rem        Это свойство COMMAND.COM заметил  Лизенко Сергей, Киев, Технософт.
rem

echo Very simple batch file
goto first
:first
echo This string repeats 2 times
:last