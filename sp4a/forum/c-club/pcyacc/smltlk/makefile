
YFLAG=
CFLAG=-AS
OBJ=main.obj lex.obj st.obj

.c.obj:
	cl -c $(CFLAG) $*.c


st.exe: $(OBJ)
	cl -Fest -Fbst -Lp $(OBJ)

st.c: st.y
	pcyacc $(YFLAG) st.y



