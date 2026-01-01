if exist mid-east.mbx erase mid-east.mbx
if not exist rot13.com pkunzip filters.zip unrot13.com
rot13 < mid-east.r13 > mid-east.mbx
if %@eval[2+2]==4 call _desc.btm
l mid-east.mbx
