procedure main(fname,param)
   local talk,echo,skip
   default param to "",;
           fname to ""
   param:=upper(param)
   talk:=(at("T",param)>0)
   echo:=(at("E",param)>0)
   skip:=(at("S",param)>0)  
   if fname==NIL
     ? "Usage: cli <.cli file> [/options]"
     ? "options are:  T - talk ON"
     ? "              E - echo ON"
     ? "              S - skip errors"
     quit
   endif
   if !file(fname)
      ? "Can't locate ",fname
   endif
   prolog(fname,talk,echo,skip)
   
// эвалуятор текста
procedure prolog(_fname,_talk,_echo,_skip)
  local _buffer,_nline,_cstring:="",_bblock,_temp,_result,oldERR,_oe,_i
  memvar i,j,k,l,m,n,nechto

  default _talk to .f.,;
          _echo to .f.,;
          _skip to .f.
  _buffer:=memoread(_fname)
  for _nline:=1 to mlcount(_buffer,80)
        _cstring+=alltrim(memoline(_buffer,80,_nline))
        if !empty(_cstring).and.!left(_cstring,2)=="//"  //строка не пуста
           _temp:=rat("//",_cstring)   // внутристрочные комментарии
           if _temp>0
              _cstring:=trim(substr(_cstring,1,_temp-1))
           endif
           if right(_cstring,1)==";"  // склеенная строка
              _cstring:=trim(substr(_cstring,1,len(_cstring)-1))
           else
             if _echo
               ? _nline,_cstring
             endif
             if upper(left(_cstring,8))=="PRIVATE "
                nechto:=trim(substr(_cstring,9))
                private &nechto
             elseif upper(left(_cstring,7))=="PUBLIC "
                nechto:=trim(substr(_cstring,8))
                public &nechto
             else
                oldERR:=errorblock({|x|myerror(x)})

                BEGIN SEQUENCE

                if upper(left(_cstring,6))=="BLOCK "
                  _cstring:=trim(substr(_cstring,7))
                  _i:=at(":=",_cstring)
                  nechto:=upper(alltrim(substr(_cstring,1,_i-1)))
                  _cstring:=alltrim(substr(_cstring,_i+2))
                  &nechto := &(_cstring)
                else
                   _bblock:=&("{||"+_cstring+"}")
                   _result:=eval(_bblock)
                   if _talk
                      ? "=",_result
                   endif
                 endif
                recover using _oe
                  ?? chr(7)
                  ? '**',_nline,'** Error **'
                    ? "e:description is: " + _oe:description
                    ? "e:filename is:    " + _oe:filename
                    ? "e:genCode is:     " + LTRIM(STR(_oe:genCode))
                    ? "e:operation is:   " + _oe:operation
                    ? "e:osCode is:      " + LTRIM(STR(_oe:osCode))
                    ? "e:subCode is:     " + LTRIM(STR(_oe:subCode))
                    ? "e:subSystem is:   " + _oe:subSystem
                    ? "e:args is:        "
                    IF VALTYPE(_oe:args) == "A"
                       ?? "An ARRAY: " + LTRIM(STR(LEN(_oe:args))) + " Element(s)"
                       FOR i := 1 TO LEN(_oe:args)
                          ? "e:args[" + STR(i, 2) + "] is:    ", _oe:args[i]
                       NEXT
                    ELSE
                       ?? _oe:args
                    ENDIF
                      ? 'Press any key ...'
                    INKEY(0)

                  if !_skip
                     quit
                  endif
                END

                errorblock(oldERR)
             endif
             _cstring:=""
           endif
        else
           _cstring:=""
        endif
  next

function myerror(oe)
  break(oe)
  return (.t.)

static procedure DUMMY
  local i,j,k
* Clipper 5.01 commands
//?? __ACCEPT()
//?? __ACCEPTSTR()
//?? __classnew()
//?? __classadd()
//?? __classins()
//?? __classsel()
//?? __setcentury()
//?? _DFSET()
//?? __EJECT()
?? __WAIT()
//?? __MCLEAR()
//?? __mxrelease()
//?? __mrelease()
//?? __mrestore()
//?? __msave()
?? __copyfile()
?? __dir()
?? __typefile()
//?? __quit()
?? __run()
?? __dbpack()
?? __dbzap()
?? __dblocate()
?? __dbcontinue()
?? __dbcreate()
?? __dbcopyxstruct()
?? __dbcopystruct()
?? __dbcopydelim()
?? __dbcopysdf()
?? __dbcopy()
?? __dbappdelim()
?? __dbapp()
?? __dbappsdf()
?? __dbsort()
?? __dbtotal()
?? __dbupdate()
?? __dbjoin()
?? __dblist()
?? __keyboard()
* Clipper 5.00 functions
?? AADD(i,j)
?? ABS(i)
?? ACHOICE()
?? ACLONE()
?? ACOPY()
?? ADEL()
?? ADIR()
?? AEVAL()
?? AFIELDS()
?? AFILL()
?? AINS()
?? ALERT()
?? ALIAS()
?? ALLTRIM()
?? ALTD()
?? ARRAY()
?? ASC(i)
?? ASCAN()
?? ASIZE()
?? ASORT()
?? AT(i,j)
?? ATAIL()
?? BIN2I()
?? BIN2L()
?? BIN2W()
?? BOF()
?? BREAK(i)
?? BROWSE()
?? CDOW(i)
?? CHR(i)
?? CMONTH(i)
?? COL()
?? CTOD(i)
?? CURDIR()
?? DATE()
?? DAY(i)
?? DBAPPEND()
?? DBCLEARFIL()
?? DBCLEARIND()
?? DBCLEARREL()
?? DBCLOSEALL()
?? DBCLOSEAREA()
?? DBCOMMIT()
?? DBCOMMITALL()
?? DBCREATE()
?? DBCREATEIND()
?? DBDELETE()
?? DBEDIT()
?? DBEVAL()
?? DBF()
?? DBFILTER()
?? DBGOBOTTOM()
?? DBGOTO()
?? DBGOTOP()
?? DBRECALL()
?? DBREINDEX()
?? DBRELATION()
?? DBRSELECT()
?? DBSEEK()
?? DBSELECTAR()
?? DBSETDRIVER()
?? DBSETFILTER()
?? DBSETINDEX()
?? DBSETORDER()
?? DBSETRELAT()
?? DBskip()
?? DBSTRUCT()
?? DBUNLOCK()
?? DBUNLOCKALL()
?? DBUSEAREA()
?? DELETED()
?? DESCEND()
?? DEVOUT()
?? DEVPOS(i,j)
?? DIRECTORY()
?? DISKSPACE()
?? DISPBEGIN()
?? DISPBOX()
?? DISPEND()
?? DISPOUT()
?? DOSERROR()
?? DOW(i)
?? DTOC(i)
?? DTOS(i)
?? EMPTY(i)
?? EOF()
?? ERRORBLOCK()
?? ERRORLEVEL()
?? EVAL(i)
?? EXP(i)
?? FCLOSE()
?? FCOUNT()
?? FCREATE()
?? FERASE()
?? FERROR()
?? FIELDBLOCK()
?? FIELDGET()
?? FIELDNAME(i)
?? FIELDPOS()
?? FIELDPUT()
?? FIELDWBLOCK()
?? FILE()
?? FKLABEL()
?? FKMAX()
?? FLOCK()
?? FOPEN()
?? FOUND()
?? FREAD()
?? FREADSTR()
?? FRENAME()
?? FSEEK()
?? FWRITE()
?? GETACTIVE()
?? GETENV()
?? HARDCR()
?? HEADER()
?? INDEXEXT()
?? INDEXKEY()
?? INDEXORD()
?? INKEY()
?? INT(i)
?? ISALPHA()
?? ISCOLOR()
?? ISDIGIT()
?? ISLOWER()
?? ISPRINTER()
?? ISUPPER()
?? I2BIN()
?? LASTKEY()
?? LASTREC()
?? LEFT(i,j)
?? LEN(i)
?? LOG(i)
?? LOWER(i)
?? LTRIM(i)
?? LUPDATE()
?? L2BIN()
?? MAX(i,j)
?? MAXCOL()
?? MAXROW()
?? MEMOEDIT()
?? MEMOLINE()
?? MEMOREAD()
?? MEMORY()
?? MEMOTRAN()
?? MEMOWRIT()
?? MEMVARBLOCK()
?? MIN(i,j)
?? MLCOUNT()
?? MLCTOPOS()
?? MLPOS()
?? MOD()
?? MONTH(i)
?? MPOSTOLC()
?? NETERR()
?? NETNAME()
?? NEXTKEY()
?? NOSNOW()
?? OS()
?? OUTERR()
?? OUTSTD()
?? PAD()
?? PCOL()
?? PCOUNT()
?? PROCLINE()
?? PROCNAME()
?? PROW()
?? QOUT()
?? RAT()
?? READEXIT()
?? READINSERT()
?? READKEY()
?? READMODAL()
?? READVAR()
?? RECCOUNT()
?? RECNO()
?? RECSIZE()
?? REPLICATE(i,j)
?? RESTSCREEN()
?? RIGHT()
?? RLOCK()
?? ROUND(i,j)
?? ROW()
?? RTRIM(i)
?? SAVESCREEN()
?? SCROLL()
?? SECONDS()
?? SELECT()
?? SET()
?? SETBLINK()
?? SETCANCEL()
?? SETCOLOR()
?? SETCURSOR()
?? SETKEY()
?? SETMODE()
?? SETPOS(i,j)
?? SETPRC()
?? SOUNDEX()
?? SPACE(i)
?? SQRT(i)
?? STR(i)
?? STRTRAN()
?? STUFF()
?? SUBSTR(i,j)
?? TIME()
?? TONE()
?? TRANSFORM(i,j)
?? TYPE(i)
?? UPDATED()
?? UPPER(i)
?? USED()
?? VAL(i)
?? VALTYPE(i)
?? VERSION()
?? WORD(i)
?? YEAR(i)

