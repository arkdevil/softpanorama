@echo off
rem -------------------------------------------------------------
rem
rem A batch file that returns a memory scan
rem BATMEM.BAT
rem Copyright 1992 Douglas Boling
rem
rem -------------------------------------------------------------
rem
rem First, get the pointer to the list of lists
rem
strings /i /b16 iret = interrupt 21, 5200
strings /b16 lloff = parse %iret%, 2
strings /b16 llseg = parse %iret%, 9
set iret=

rem
rem First memory block kept at ListOfList - 2
rem
strings /b16 lloff = sub %lloff%, 2
strings /b16 memseg = peek %llseg%, %lloff%, 2, 2

echo.
echo  Block Owner Size Program
echo  --------------------------------

strings /b16 totalmem = add %memseg%, 1
set freemem=0
:loop
   rem
   rem Parse the memory arena header
   rem
   strings /b16 memtype = peek %memseg%, 0, 1
   strings /b16 memowner = peek %memseg%, 1, 2, 2
   strings /b16 memsize = peek %memseg%, 3, 2, 2

   strings /b16 memtemp = peek %memseg%, 8, 8
   strings /b16 /p  memtemp = char %memtemp%

   strings /b16 memseg = add %memseg%, 1
   rem
   rem If block not PSP, don't print block name
   rem
   set memname=
   set diff=-1

   strings /b16 /q diff = sub %memseg%, %memowner%
   if .%diff% == .0 goto skip1
   goto skip2
   :skip1
      set memname=%memtemp%
   :skip2

   if NOT %memowner% == 0000 goto skip3
      set memowner=FREE
      strings /b16 freemem = add %freemem%, %memsize%
   :skip3
   rem
   rem OK, print the results
   rem
   echo  %memseg% %memowner% %memsize% %memname%

   strings /b16 memseg = add %memseg%, %memsize%
   strings /b16 totalmem = add %memsize%, %totalmem%
   strings /b16 totalmem = add %totalmem%, 1

if %memtype% == 4D goto loop

echo.

strings /b16 memsize = mul %memsize%, 10
strings /b16 memsize = convert %memsize%, A
strings memsize = addcommas %memsize%

strings /b16 totalmem = mul %totalmem%, 10
strings /b16 totalmem = convert %totalmem%, A
strings /u totalmem = addcommas %totalmem%

echo  %totalmem% bytes total conventional memory
echo  %memsize% largest program executable size
echo.
rem
rem Done, clean up all vars
rem
set llseg=
set lloff=
set memseg=
set memowner=
set memsize=
set memtype=
set memname=
set memtemp=
set freemem=
set totalmem=
set diff=
