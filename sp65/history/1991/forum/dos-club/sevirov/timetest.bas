'{***********************************************************************}
'{ Тест - перемножение матриц   Павел Северов 1989                       }
'{***********************************************************************}

'defsng A,B,C,S
defdbl A,B,C,S

defint i,j,k,L,M,N,T
defsng V

T=40
L=T:M=T:N=T
dim A(T,T),B(T,T),C(T,T)



print "POEHALI"
for i=1 to M:for j=1 to N:A(i,j)=2.0/(i*j):next j:next i
for i=1 to N:for j=1 to L:B(i,j)=2.0*i*j:next j:next i
V1=timer
for k=1 to M:for j=1 to L
  S=0.0
  for i=1 to N:S=S+A(k,i)*B(i,j):next i
  C(k,j)=S:next j:next k
V2=timer
for j=1 to 4:for k=1 to 2:print C(k,j):next k:next j
print "Время="V2-V1" сек."


