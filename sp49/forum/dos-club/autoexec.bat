rem   Вы пытались когда нибудь запускать свою дискету с операционкой
rem   на чужом компьютере ?
rem   А у Вас есть на ней виртуальный диск ?
rem   Возникают проблемы при копировании COMMAND.COM и установки
rem   COMSPEC, а работать без виртуального диска не очень хочеться.
rem   Данный пример показывает как преодолеть эти проблемы используя
rem   утилиту WHATNEW.
@echo off
prompt $p$g
SET WHAT=..
SET TMP=..
whatnew L
copy a:\command.com %what%:\
set comspec=%what%:\command.com


