@echo off

echo ARJSORT 1.00 Batch file to sort ARJ archive
echo ""

if "%1"=="" goto param_error

if "%2"=="" goto sort_start
if %2==/A goto sort_start
if %2==/a goto sort_start
if %2==/C goto sort_start
if %2==/c goto sort_start
if %2==/D goto sort_start
if %2==/d goto sort_start
if %2==/E goto sort_start
if %2==/e goto sort_start
if %2==/F goto sort_start
if %2==/f goto sort_start
if %2==/O goto sort_start
if %2==/o goto sort_start
if %2==/P goto sort_start
if %2==/p goto sort_start
if %2==/R goto sort_start
if %2==/r goto sort_start
if %2==/S goto sort_start
if %2==/s goto sort_start
if %2==/T goto sort_start
if %2==/t goto sort_start
goto param_error

:sort_start
arj v %1 -jv1 > arjsort.$$1
if errorlevel 1 goto arj_error

echo 1,2d>  arjsort.$$2
echo 1sProcessing archive>> arjsort.$$2
echo 1,.d>> arjsort.$$2
echo 1,3d>> arjsort.$$2
echo e>>    arjsort.$$2
edlin arjsort.$$1 < arjsort.$$2

if "%2"=="" goto sort_path
if %2==/A goto sort_attr
if %2==/a goto sort_attr
if %2==/C goto sort_crc
if %2==/c goto sort_crc
if %2==/D goto sort_date
if %2==/d goto sort_date
if %2==/E goto sort_ext
if %2==/e goto sort_ext
if %2==/F goto sort_file
if %2==/f goto sort_file
if %2==/O goto sort_ratio
if %2==/o goto sort_ratio
if %2==/P goto sort_path
if %2==/p goto sort_path
if %2==/R goto r_sort_path
if %2==/r goto r_sort_path
if %2==/S goto sort_size
if %2==/s goto sort_size
if %2==/T goto sort_time
if %2==/t goto sort_time
goto param_error

:sort_path
echo Sorting by pathname
sort /+122 %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:r_sort_path
echo Sorting by pathname
sort /+122 %2 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_attr
echo Sorting by attribute
sort /+69  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_crc
echo Sorting by CRC
sort /+60  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_date
echo Sorting by Date/Time modified
sort /+42  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_ext
echo Sorting by file extension
sort /+81  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_file
echo Sorting by filename
sort /+89  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_ratio
echo Sorting by compression ratio
sort /+36  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_size
echo Sorting by original file size
sort /+14  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_time
echo Sorting by time modified
sort /+51  %3 < arjsort.$$1 > arjsort.$$$
goto sort_finish

:sort_finish
arj o %1 !arjsort.$$$
if errorlevel 1 goto arj_error

del arjsort.$$1
del arjsort.$$2
del arjsort.$$$
del arjsort.bak
goto stop

:arj_error
echo ARJ error processing %1
goto stop

:param_error
echo "Usage:  ARJSORT archive [/a | /c | /d | /e | /f | /o | /p | /s | /t] [/r]"
echo "        /a=attribute, /c=crc, /d=date-time, /e=extension, /f=filename"
echo "        /o=ratio, /p=pathname, /s=size"
echo "        /r=reverse order, must be the last argument on the command line"
echo ""
:stop
