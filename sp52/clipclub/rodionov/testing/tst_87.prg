private i,j,k,l,x
j=33
? 'Numeric conversions time test'

? 'val(str())'
x=time()
l=val(substr(x,4,2))*60+val(substr(x,7,2))
for i=1 to 50000
  k=val(str(j))
next
x=time()
?? ' Timing',val(substr(x,4,2))*60+val(substr(x,7,2))-l

? 'asc(chr())'
x=time()
l=val(substr(x,4,2))*60+val(substr(x,7,2))
for i=1 to 50000
  k=asc(chr(j))
next
x=time()
?? ' Timing',val(substr(x,4,2))*60+val(substr(x,7,2))-l

? 'bin2i(i2bin())'
x=time()
l=val(substr(x,4,2))*60+val(substr(x,7,2))
for i=1 to 50000
  k=bin2i(i2bin(j))
next
x=time()
?? ' Timing',val(substr(x,4,2))*60+val(substr(x,7,2))-l

? 'bin2w(i2bin())'
x=time()
l=val(substr(x,4,2))*60+val(substr(x,7,2))
for i=1 to 50000
  k=bin2w(i2bin(j))
next
x=time()
?? ' Timing',val(substr(x,4,2))*60+val(substr(x,7,2))-l

? 'bin2l(l2bin())'
x=time()
l=val(substr(x,4,2))*60+val(substr(x,7,2))
for i=1 to 50000
  k=bin2l(l2bin(j))
next
x=time()
?? ' Timing',val(substr(x,4,2))*60+val(substr(x,7,2))-l

? 'bin2f(f2bin())'
x=time()
l=val(substr(x,4,2))*60+val(substr(x,7,2))
for i=1 to 50000
  k=bin2f(f2bin(j))
next
x=time()
?? ' Timing',val(substr(x,4,2))*60+val(substr(x,7,2))-l

