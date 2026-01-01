CLIPPER TEST_DAT /b
if errorlevel 1 goto end
CLIPPER CALENDAR /N /b
if errorlevel 1 goto end
RTLINK FI TEST_DAT, calendar
test_dat
:end
