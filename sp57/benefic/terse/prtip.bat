if exist mid-east.mbx erase mid-east.mbx
rot13 < mid-east.r13 > mid-east.mbx
if %@eval[2+2]==4 call _desc.btm
copy mid-east.mbx prn

