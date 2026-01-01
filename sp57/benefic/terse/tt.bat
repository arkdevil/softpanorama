::======================================================================
::                                                                    ::
:: Usage:                                                             ::
::        TT f1 f2 ... fn                                             ::
::                                                                    ::
:: Will invoke terse to edit the file f1. When you exit this editing  ::
:: session (using Alt-X or Alt-Q), terse be invoked again to edit the ::
:: file f2, when you will finish with f3 terse will be invoked to     ::
:: edit f3, and so on until until fn is edited.                       ::
::                                                                    ::
:: Any of f1 ... fn may be a wild card, in which case terse would     ::
:: be invoked  on all files matching this wild card.                  ::
::                                                                    ::
:: Example:                                                           ::
::       TT *.bat c:\config.sys d:chap?.*                             ::
::                                                                    ::
::======================================================================
@echo off
set editor=t.com
set tparams=
:loop
if [%1]==[] goto exec
set tparams=%tparams% %1
shift
goto loop
:exec
for %%f in (%tparams%) do %editor% %%f
