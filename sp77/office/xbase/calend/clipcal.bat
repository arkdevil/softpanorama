CLIPPER TEST_CAL /b
if errorlevel 1 goto end
CLIPPER CALENDAR /N /b
if errorlevel 1 goto end
RTLINK FI TEST_CAL,calendar
test_cal
:end
