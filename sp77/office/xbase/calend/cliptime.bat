CLIPPER TestTime /b
CLIPPER CALENDAR /N /b
if errorlevel 1 goto end
RTLINK FI TestTime,calendar
testtime
:end
