@echo off
:
:    Start Norton Commander, if NC already active then NOP.
:    Variable %NC% used as flag for NC activaty.
:    When %NC% is not empty then assumed that NC is active.
:
:    Use: %NC% environ variable
:
if   not "%nc%"==""  goto end
set  nc=%B%\nort\nc
%nc%\nc
set  nc=
:end
