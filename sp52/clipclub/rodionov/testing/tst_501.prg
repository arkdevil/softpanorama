#define MAXCOUNT 50000
local i,j:=33,k,l

? 'Numeric conversions time test'

? 'val(str())'
l:=seconds()
for i:=1 to MAXCOUNT
  k:=val(str(j))
next
?? ' Timing',seconds()-l

? 'asc(chr())'
l:=seconds()
for i:=1 to MAXCOUNT
  k:=asc(chr(j))
next
?? ' Timing',seconds()-l

? 'bin2i(i2bin())'
l:=seconds()
for i:=1 to MAXCOUNT
  k:=bin2i(i2bin(j))
next
?? ' Timing',seconds()-l

? 'bin2w(i2bin())'
l:=seconds()
for i:=1 to MAXCOUNT
  k:=bin2w(i2bin(j))
next
?? ' Timing',seconds()-l

? 'bin2l(l2bin())'
l:=seconds()
for i:=1 to MAXCOUNT
  k:=bin2l(l2bin(j))
next
?? ' Timing',seconds()-l

? 'bin2f(f2bin())'
l:=seconds()
for i:=1 to MAXCOUNT
  k:=bin2f(f2bin(j))
next
?? ' Timing',seconds()-l


