call !makelib t
call !makelib n
call !makelib f

pkzip a console.zip console?.lib console.h console.txt
zip2exe -j console.zip
del console.zip
