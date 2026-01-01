/*
   A package of Multi-Edit macros for date manipulation by:

  (c) Copyright 1992  Raymond P. Tackett
                      434 East Woodlawn Avenue
                      Philadelphia, PA  19144

                      Compuserve 76416,276
*/

#include datedef.s   /* global definitions */
#include datemac.s   /* internal subroutines */

macro DOW       /* Day Of Week name by Zeller's Congruence Formula
                   Returned as both string and ordinal integer */
{
  str foo = mparm_str;
  int month,day,year,junk,x,y,z,dow;
  if (foo == '') foo = date;
  rm('parsedate '+foo);
  month = global_int('gmonth');
  day = global_int('gday');
  year = global_int('gyear');
  if (not(month)) /* if bad date parameter */
  {
    return_str = '';
    return_int = 0;
    goto dowexit;
  }
  if (month < 3) /* first two months are 13 and 14 of previous year */
  {
    month = month + 12;
    year --;
  }
  junk = (month + 3) * 13;
  x = junk/5;
  if (not(junk%5)) x -- ;
  y = (year * 5) / 4;
  z = year / 100;
  junk = year / 400;
  dow = day + 1 + x + y - z + junk;
  dow = (dow%7) + 1;
  switch (dow)
  {
    case  1 : return_str = D_1; break;
    case  2 : return_str = D_2; break;
    case  3 : return_str = D_3; break;
    case  4 : return_str = D_4; break;
    case  5 : return_str = D_5; break;
    case  6 : return_str = D_6; break;
    case  7 : return_str = D_7; break;
    default : return_str = '' ; break;
  }
  return_int = dow;
  goto dowexit;

dowexit:
}

macro JULIAN      /* Output date in Julian */
{
  str foo = mparm_str;
  if (foo == '') foo = date;
  rm('parsedate '+foo);
  set_global_int('isjulian',TRUE);
  set_global_int('isgregorian',FALSE);
  set_global_int('workd',global_int('jday'));
  set_global_int('worky',global_int('jyear'));
  rm('fmtdate');
}

macro GREGORIAN      /* Output date in Gregorian */
{
  str foo = mparm_str;
  if (foo == '') foo = date;
  rm('parsedate '+foo);
  set_global_int('isgregorian',TRUE);
  set_global_int('isjulian',FALSE);
  set_global_int('workm',global_int('gmonth'));
  set_global_int('workd',global_int('gday'));
  set_global_int('worky',global_int('gyear'));
  rm('fmtdate');
}

macro NDAYS       /* Number of days between dates */
{
  int delta = 0;
  int fromyr, toyr, fromday, today;
  str fromstr, tostr;
  rm('argone '+mparm_str);
  fromstr = return_str;
  if (fromstr == '') fromstr = date; /* default from today */
  rm('argtwo '+mparm_str);
  tostr = return_str;
  if (tostr == '') tostr = date;     /* default to today */
  rm('parsedate '+fromstr);
  fromyr = global_int('jyear');
  fromday = global_int('jday');
  rm('parsedate '+tostr);
  toyr = global_int('jyear');
  today = global_int('jday');

  if (fromyr == toyr) delta = (today-fromday);
  else if (fromyr > toyr) /* time moves backward -- negative delta */
  {
    delta = delta - fromday;
    rm('isleapyear '+str(toyr));
    delta = delta - (J_D + return_int - today);
    fromyr -- ;
  }
  else if (fromyr < toyr)
  {
    delta = today;
    rm('isleapyear '+str(fromyr));
    delta = delta + (J_D + return_int - fromday);
    fromyr ++ ;
  }
  set_global_int('gyear',fromyr);
  set_global_int('worky',toyr);
  rm('yeardiff');
  return_int = delta + global_int('workd');
}

macro PLUSDAYS      /* Date plus N days */
{
  int delta,foo,year,leap,j,g,t;
  str fromstr;
  rm('argone '+mparm_str);
  fromstr = return_str;
  if (fromstr == '') fromstr = date;
  rm('argtwo '+mparm_str);
  foo = val(delta,return_str);
  rm('parsedate '+fromstr);

  /* save the real input format because we're going to parse our own */
  j = global_int('isjulian');
  g = global_int('isgregorian');
  t = global_int('twodigit');

  delta = delta + global_int('jday'); /* raw result */
  year = global_int('jyear');
  rm('isleapyear '+str(year));
  leap = return_int;
  while (delta > (J_D + leap))
  {
    delta = delta - (J_D + leap);
    year ++ ;
    rm('isleapyear '+str(year));
    leap = return_int ;
  }
  while (delta < 0)
  {
    delta = delta + J_D + leap;
    year -- ;
    rm('isleapyear '+str(year));
    leap = return_int;
  }
  set_global_int('workd',delta);
  set_global_int('worky',year);
  set_global_int('isjulian',TRUE);
  set_global_int('isgregorian',FALSE);
  set_global_int('twodigit',FALSE);
  rm('fmtdate');

  /* use parsedate and fmtdate on the return string to get the
     required output format */
  rm('parsedate '+return_str);
  set_global_int('isjulian',j); /* restore the original input format */
  set_global_int('isgregorian',g);
  set_global_int('twodigit',t);

  if (g)
  {
    set_global_int('workm',global_int('gmonth'));
    set_global_int('workd',global_int('gday'));
    set_global_int('worky',global_int('gyear'));
    rm('fmtdate');
  }

  if (j)
  {
    set_global_int('workd',global_int('jday'));
    set_global_int('worky',global_int('jyear'));
    rm('fmtdate');
  }
}

macro TEXTDATE       /* Date in controlled text format */
{
  str indate, ctlstr, parmstr, dowstr;
  int posit, limit, workpos, downum;
  rm('argone '+mparm_str);
  indate = return_str;
  rm('argtwo '+mparm_str);
  ctlstr = return_str;
  if (ctlstr == '') ctlstr = T_F;  /* get default format if none given */
  if (indate == '') indate = date; /* default is today */
  rm('parsedate '+indate);

  limit = svl(ctlstr);
  posit = 1;
  while (posit < limit)
  {
    while (str_char(ctlstr,posit) == CTL_SEP) /* allow recursive expansion */
    {
      workpos = posit + 1;
      if     (str_char(ctlstr,workpos) == M_NAME) call mname;
      else if(str_char(ctlstr,workpos) == M_NUM)  call mnum;
      else if(str_char(ctlstr,workpos) == D_NAME) call dname;
      else if(str_char(ctlstr,workpos) == D_NUM)  call dnum;
      else if(str_char(ctlstr,workpos) == Y_NAME) call yname;
      else if(str_char(ctlstr,workpos) == Y_NUM)  call ynum;
      else if(str_char(ctlstr,workpos) == W_NAME) call wname;
      else if(str_char(ctlstr,workpos) == W_NUM)  call wnum;
      else if(str_char(ctlstr,workpos) == J_NAME) call jname;
      else if(str_char(ctlstr,workpos) == J_NUM)  call jnum;

      limit = svl(ctlstr); /* length changed if a case hit above */
    }
    posit ++ ;
  }
  goto textdateexit;

mname:
  ctlstr = str_del(ctlstr,posit,2);
  switch (global_int('gmonth'))
  {
    case  1 : ctlstr = str_ins(M_1,ctlstr,posit); break;
    case  2 : ctlstr = str_ins(M_2,ctlstr,posit); break;
    case  3 : ctlstr = str_ins(M_3,ctlstr,posit); break;
    case  4 : ctlstr = str_ins(M_4,ctlstr,posit); break;
    case  5 : ctlstr = str_ins(M_5,ctlstr,posit); break;
    case  6 : ctlstr = str_ins(M_6,ctlstr,posit); break;
    case  7 : ctlstr = str_ins(M_7,ctlstr,posit); break;
    case  8 : ctlstr = str_ins(M_8,ctlstr,posit); break;
    case  9 : ctlstr = str_ins(M_9,ctlstr,posit); break;
    case 10 : ctlstr = str_ins(M_A,ctlstr,posit); break;
    case 11 : ctlstr = str_ins(M_B,ctlstr,posit); break;
    case 12 : ctlstr = str_ins(M_C,ctlstr,posit); break;
    default : break;
  }
  ret;

mnum:
  ctlstr = str_del(ctlstr,posit,2);
  ctlstr = str_ins(str(global_int('gmonth')),ctlstr,posit);
  ret;

dname:
  ctlstr = str_del(ctlstr,posit,2);
  parmstr = str(global_int('gday'));
  rm('numord '+parmstr);
  parmstr = return_str;
  ctlstr = str_ins(parmstr,ctlstr,posit);
  ret;

dnum:
  ctlstr = str_del(ctlstr,posit,2);
  ctlstr = str_ins(str(global_int('gday')),ctlstr,posit);
  ret;

yname:
  ctlstr = str_del(ctlstr,posit,2);
  parmstr = str(global_int('gyear'));
  rm('numword '+parmstr);
  parmstr = return_str;
  ctlstr = str_ins(parmstr,ctlstr,posit);
  ret;

ynum:
  ctlstr = str_del(ctlstr,posit,2);
  ctlstr = str_ins(str(global_int('gyear')),ctlstr,posit);
  ret;

wname:
  ctlstr = str_del(ctlstr,posit,2);
  rm('dow '+indate);
  dowstr = return_str;
  ctlstr = str_ins(dowstr,ctlstr,posit);
  ret;

wnum:
  ctlstr = str_del(ctlstr,posit,2);
  rm('dow '+indate);
  downum = return_int;
  ctlstr = str_ins(str(downum),ctlstr,posit);
  ret;

jname:
  ctlstr = str_del(ctlstr,posit,2);
  parmstr = str(global_int('jday'));
  rm('numord '+parmstr);
  parmstr = return_str;
  ctlstr = str_ins(parmstr,ctlstr,posit);
  ret;

jnum:
  ctlstr = str_del(ctlstr,posit,2);
  ctlstr = str_ins(str(global_int('jday')),ctlstr,posit);
  ret;

textdateexit:
  return_str = ctlstr;
}

macro NUMWORD      /* Number expressed in words */
{
  int foo;
  str workstr='';
  str numend,nummiddle,workmid,workend;
  int work,work1,workhund,workten,workunit;
  return_str='';
  if (val(foo,mparm_str)) goto numwordexit; /* no garbage allowed */

  if (foo < 0)
  {
    workstr = workstr + M_WORD;
    foo = foo * (-1);
  }

  if (foo == 0)
  {
    workstr = workstr + Z_WORD;
    goto numwordexit;
  }

  work = foo/1000000000;    /* 10^9 */
  foo = foo-(work*1000000000);
  nummiddle = G_W;
  numend = G_WF;
  if(work) call num2word;

  work = foo/1000000;       /* 10^6 */
  foo = foo-(work*1000000);
  nummiddle = M_W;
  numend = M_WF;
  if(work) call num2word;

  work = foo/1000;          /* 10^3 */
  foo = foo-(work*1000);
  nummiddle = K_W;
  numend = K_WF;
  if(work) call num2word;

  work = foo;               /* 10^0 */
  foo = 0;            /* nothing left to work on */
  nummiddle = '';
  numend = '';
  if(work) call num2word;
  goto numwordexit;

num2word:
  call word2sub;
  if((global_int('ordinal')) && (not(foo))) /* end of ordinal number */
    workstr = workstr + numend;
   else
    workstr = workstr + nummiddle;
  ret;

word2sub:
  workhund = work/100;
  work = work-(workhund*100);
  workmid = C_W;
  if(numend == '') workend = C_WF; else workend = workmid;
  if(workhund) call hundcase;
  workten = work/10;
  if(workten == 1) workten = 0; /* "teenth" hack */
  work = work-(workten*10);
  if(workten) call tencase;
  workunit = work;   /* may be up to 19 for teenth hack */
  work = 0;          /* done with this piece */
  if(workunit) call unitcase;
  ret;

hundcase:
  switch (workhund)
  {
    case 1 : workstr = workstr + U_1; break;
    case 2 : workstr = workstr + U_2; break;
    case 3 : workstr = workstr + U_3; break;
    case 4 : workstr = workstr + U_4; break;
    case 5 : workstr = workstr + U_5; break;
    case 6 : workstr = workstr + U_6; break;
    case 7 : workstr = workstr + U_7; break;
    case 8 : workstr = workstr + U_8; break;
    case 9 : workstr = workstr + U_9; break;
    default : break;
  }
  if((global_int('ordinal')) && (not(foo)) && (not(work)))
    workstr = workstr + workend;
   else
    workstr = workstr + workmid;
  ret;

tencase:
  if((global_int('ordinal')) && (not(foo)) && (not(work)))
    switch (workten)
    {
    case  2 : workstr = workstr + T_2F ; break;
    case  3 : workstr = workstr + T_3F ; break;
    case  4 : workstr = workstr + T_4F ; break;
    case  5 : workstr = workstr + T_5F ; break;
    case  6 : workstr = workstr + T_6F ; break;
    case  7 : workstr = workstr + T_7F ; break;
    case  8 : workstr = workstr + T_8F ; break;
    case  9 : workstr = workstr + T_9F ; break;
    default : break;
    }
   else
    switch (workten)
    {
    case  2 : workstr = workstr + T_2 ; break;
    case  3 : workstr = workstr + T_3 ; break;
    case  4 : workstr = workstr + T_4 ; break;
    case  5 : workstr = workstr + T_5 ; break;
    case  6 : workstr = workstr + T_6 ; break;
    case  7 : workstr = workstr + T_7 ; break;
    case  8 : workstr = workstr + T_8 ; break;
    case  9 : workstr = workstr + T_9 ; break;
    default : break;
    }

  ret;

unitcase:
  if((global_int('ordinal')) && (not(foo)) && (numend == ''))
    switch (workunit)
    {
    case  1 : workstr = workstr + U_1F ; break;
    case  2 : workstr = workstr + U_2F ; break;
    case  3 : workstr = workstr + U_3F ; break;
    case  4 : workstr = workstr + U_4F ; break;
    case  5 : workstr = workstr + U_5F ; break;
    case  6 : workstr = workstr + U_6F ; break;
    case  7 : workstr = workstr + U_7F ; break;
    case  8 : workstr = workstr + U_8F ; break;
    case  9 : workstr = workstr + U_9F ; break;
    case 10 : workstr = workstr + T_10F; break;
    case 11 : workstr = workstr + T_11F; break;
    case 12 : workstr = workstr + T_12F; break;
    case 13 : workstr = workstr + T_13F; break;
    case 14 : workstr = workstr + T_14F; break;
    case 15 : workstr = workstr + T_15F; break;
    case 16 : workstr = workstr + T_16F; break;
    case 17 : workstr = workstr + T_17F; break;
    case 18 : workstr = workstr + T_18F; break;
    case 19 : workstr = workstr + T_19F; break;
    default : break;
    }
   else
    switch (workunit)
    {
    case  1 : workstr = workstr + U_1 ; break;
    case  2 : workstr = workstr + U_2 ; break;
    case  3 : workstr = workstr + U_3 ; break;
    case  4 : workstr = workstr + U_4 ; break;
    case  5 : workstr = workstr + U_5 ; break;
    case  6 : workstr = workstr + U_6 ; break;
    case  7 : workstr = workstr + U_7 ; break;
    case  8 : workstr = workstr + U_8 ; break;
    case  9 : workstr = workstr + U_9 ; break;
    case 10 : workstr = workstr + T_10; break;
    case 11 : workstr = workstr + T_11; break;
    case 12 : workstr = workstr + T_12; break;
    case 13 : workstr = workstr + T_13; break;
    case 14 : workstr = workstr + T_14; break;
    case 15 : workstr = workstr + T_15; break;
    case 16 : workstr = workstr + T_16; break;
    case 17 : workstr = workstr + T_17; break;
    case 18 : workstr = workstr + T_18; break;
    case 19 : workstr = workstr + T_19; break;
    default : break;
    }

  ret;

numwordexit:
  return_str=remove_space(workstr);
}

macro NUMORD      /* Ordinal number expressed in words */
{
  int foo;
  return_str='';
  if(val(foo,mparm_str) || (foo < 1)) /* don't take any garbage */
  {
    goto numordexit;
  }
  set_global_int('ordinal',1);
  rm('numword '+mparm_str);
  set_global_int('ordinal',0);
numordexit:
}

macro EATZEROS
{
  /*
    Strip leading zeros from the global string.
    Do not strip out last (or only) zero.
    Respect non-numeric string (if any) following numeric portion.
  */
  str eater = mparm_str;
  int foo;
  int posit = 1;
  int strlen = svl(eater);
  int limit = val(foo,eater); /* find 1st non-numeric, if any */
  if (not(limit)) limit = strlen; /* whole string is numeric */
    else limit--; /* exclude the first non-numeric from consideration */
  while ((posit < limit) && (str_char(eater,posit) == '0'))
    {
      posit++;
    }
  return_str = copy(eater,posit,strlen - posit + 1);
}