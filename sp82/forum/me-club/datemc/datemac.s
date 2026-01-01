// #include datedef.s  /* Just for local compilation test purposes. */

/* (c) Copyright 1992, Raymond P. Tackett */

macro DATEMATH dump
{
  /* dummy to make the correct object file name */
}

macro DATESTART
{
  set_global_int('started',1);     /* initialization tag                */
  set_global_int('gmonth',0);      /* parsed, converted Gregorian month */
  set_global_int('gday',0);        /*   "        "          "     day   */
  set_global_int('gyear',0);       /*   "        "          "     year  */
  set_global_int('jday',0);        /*   "        "      Julian    day   */
  set_global_int('jyear',0);       /*   "        "      Juilian   year  */
  set_global_int('lyear',0);       /* boolean leap year flag            */
  set_global_int('century',1900);  /* century                           */
  set_global_int('isjulian',0);    /* boolean input date is julian      */
  set_global_int('isgregorian',0); /* boolean input date is gregorian   */
  set_global_int('twodigit',0);    /* year is two digit format          */
  set_global_int('dow',0);         /* ordinal day of week from 1        */
  set_global_int('workd',0);
  set_global_int('workm',0);
  set_global_int('worky',0);
  set_global_str('workstr',' ');
}

macro PARSEDATE
{
  /*
     break input date down to Gregorian month, day, year
     break input date down to Julian day, year
     set isjulian and twodigit as appropriate
     set all output values to zero for invalid input
  */

  int posit   = 1;
  int workval = 0;
  str workparm = mparm_str;
  int limit = svl(workparm);
  int digitcnt = 1;
  int complete = FALSE;
  int ordinal = 0;
  int goodsep = FALSE;
  char thischar;
  int foo,bar,g,j,month,day,leap;

  if (not(global_int('started'))) rm('datestart');
  set_global_int('isjulian',FALSE);
  set_global_int('isgregorian',FALSE);
  set_global_int('twodigit',FALSE);

  /* chew on the input string */
  while ((digitcnt) && (posit < limit) && (not(complete)))
  {
    call getnum;
    if (digitcnt)
    {
      call testsep;
      if (global_int('isjulian')) call putjulian;
      if (global_int('isgregorian')) call putgregorian;
    }
    posit ++ ;
  }

  /* validate the parse result for numerics in bounds */
  call valyear;
  call valmonth;
  call valday;

  /* move the resulting values to the correct places */

  if (global_int('isjulian'))
  {
    set_global_int('jday',global_int('workd'));
    set_global_int('jyear',global_int('worky'));
    call jtog;
  }
  if (global_int('isgregorian'))
  {
    set_global_int('gday',global_int('workd'));
    set_global_int('gyear',global_int('worky'));
    set_global_int('gmonth',global_int('workm'));
    call gtoj;
  }
  goto parsedateexit;

jtog:
  {
    month=0;
    day=global_int('jday');
    set_global_int ('gyear',global_int('jyear'));
    if (global_int('lyear')) call leapjtog;
                    else     call normjtog;
    set_global_int('gday',day);
    set_global_int('gmonth',month);
    ret;

leapjtog:
    {
      if (day > JL_C) {month = 12; day = day-JL_C;}
        else if (day > JL_B) {month = 11; day = day-JL_B;}
        else if (day > JL_A) {month = 10; day = day-JL_A;}
        else if (day > JL_9) {month =  9; day = day-JL_9;}
        else if (day > JL_8) {month =  8; day = day-JL_8;}
        else if (day > JL_7) {month =  7; day = day-JL_7;}
        else if (day > JL_6) {month =  6; day = day-JL_6;}
        else if (day > JL_5) {month =  5; day = day-JL_5;}
        else if (day > JL_4) {month =  4; day = day-JL_4;}
        else if (day > JL_3) {month =  3; day = day-JL_3;}
        else if (day > JL_2) {month =  2; day = day-JL_2;}
        else if (day > JL_1) {month =  1; day = day-JL_1;}
      ret;
    }

normjtog:
    {
      if (day > J_C) {month = 12; day = day-J_C;}
        else if (day > J_B) {month = 11; day = day-J_B;}
        else if (day > J_A) {month = 10; day = day-J_A;}
        else if (day > J_9) {month =  9; day = day-J_9;}
        else if (day > J_8) {month =  8; day = day-J_8;}
        else if (day > J_7) {month =  7; day = day-J_7;}
        else if (day > J_6) {month =  6; day = day-J_6;}
        else if (day > J_5) {month =  5; day = day-J_5;}
        else if (day > J_4) {month =  4; day = day-J_4;}
        else if (day > J_3) {month =  3; day = day-J_3;}
        else if (day > J_2) {month =  2; day = day-J_2;}
        else if (day > J_1) {month =  1; day = day-J_1;}
      ret;
    }

  }

gtoj:
  {
    month=global_int('gmonth');
    day=global_int('gday');
    leap=global_int('lyear');
    set_global_int ('jyear',global_int('gyear'));
    switch (month)
    {
      case  1 : day = day + J_1 +    0; break;
      case  2 : day = day + J_2 +    0; break;
      case  3 : day = day + J_3 + leap; break;
      case  4 : day = day + J_4 + leap; break;
      case  5 : day = day + J_5 + leap; break;
      case  6 : day = day + J_6 + leap; break;
      case  7 : day = day + J_7 + leap; break;
      case  8 : day = day + J_8 + leap; break;
      case  9 : day = day + J_9 + leap; break;
      case 10 : day = day + J_A + leap; break;
      case 11 : day = day + J_B + leap; break;
      case 12 : day = day + J_C + leap; break;
      default : break;
    }
    set_global_int('jday',day);
    ret;
  }

valday:
  {
    foo = global_int('workd');
    bar = global_int('lyear');
    month = global_int('workm');
    if (foo < 1)
    {
      rm('datestart');
      ret;
    }
    if (global_int('isjulian'))
    {
      if (foo > (J_D + bar))
      {
        rm('datestart');
        ret;
      }
    }
    if (global_int('isgregorian'))
    {
      switch (month)
      {
        case 1  : if (foo > N_1)  rm('datestart'); break;
        case 2  : if (foo > (N_2 + bar)) rm('datestart'); break;
        case 3  : if (foo > N_3)  rm('datestart'); break;
        case 4  : if (foo > N_4)  rm('datestart'); break;
        case 5  : if (foo > N_5)  rm('datestart'); break;
        case 6  : if (foo > N_6)  rm('datestart'); break;
        case 7  : if (foo > N_7)  rm('datestart'); break;
        case 8  : if (foo > N_8)  rm('datestart'); break;
        case 9  : if (foo > N_9)  rm('datestart'); break;
        case 10 : if (foo > N_A)  rm('datestart'); break;
        case 11 : if (foo > N_B)  rm('datestart'); break;
        case 12 : if (foo > N_C)  rm('datestart'); break;
        default : break;
      }
    }
  ret;
  }

valmonth:
  {
    foo = global_int('workm');
    if (global_int('isjulian')) ret;
    if ((foo > 12) || (foo < 1))
    {
      rm('datestart'); /* trash the universe */
      ret;
    }
  ret;
  }
valyear:
  {
    foo = global_int('century');
    bar = global_int('worky');
    if (global_int('twodigit')) set_global_int('worky',foo+bar);
    rm('isleapyear '+str(global_int('worky')));
    set_global_int('lyear',return_int);
    ret;
  }

putgregorian:
  {
    switch (ordinal)
    {
      case  D_ord : set_global_int('workd',workval);
                    break;

      case  Y_ord : set_global_int('worky',workval);
                    if (digitcnt < 4) set_global_int('twodigit',TRUE);
                    break;

      case  M_ord : set_global_int('workm',workval);
                    break;


      default :     complete = TRUE;
                    break;
    }
    ordinal ++;
  if (ordinal >= G_count) complete = TRUE;
    else if (not(goodsep))
    {
      rm('datestart');
      complete = TRUE;
    }

  ret;
  }

putjulian:
  {
    switch (ordinal)
    {
      case JD_ord : set_global_int('workd',workval);
                    break;

      case JY_ord : set_global_int('worky',workval);
                    if (digitcnt < 4) set_global_int('twodigit',TRUE);
                    break;

      default :     complete = TRUE;
                    break;
    }
    ordinal ++;
  if (ordinal >= J_count) complete = TRUE;
    else if (not(goodsep))
    {
      rm('datestart');
      complete = TRUE;
    }
  ret;
  }
testsep: /* determine julian, gregorian, or bogus separator */
  {
  g = global_int('isgregorian');
  j = global_int('isjulian');
  goodsep = FALSE;
  if ((thischar == J_sep) && (not(g)))
  {
    set_global_int('isjulian',TRUE);
    goodsep = TRUE;
  }
  if ((thischar == G_sep) && (not(j)))
  {
    set_global_int('isgregorian',TRUE);
    goodsep = TRUE;
  }
  ret;
  }
getnum: /* find the next number in workparm, return value and length of
           number, position of next character
        */
  {
    workval=0;
    digitcnt=0;
    thischar = str_char(workparm,posit);
    while (((thischar < '0') || (thischar > '9')) && (posit <= limit))
    {
      posit ++ ;
      thischar = str_char(workparm,posit);
    }

    /* now pointing at a numeric character or end of string */
    bar = 0;

    while ((posit <= limit) && (thischar >= '0') && (thischar <= '9'))
    {
      bar = val(foo,thischar);
      workval = (workval * 10) + foo;
      digitcnt ++ ;
      posit ++ ;
      thischar = str_char(workparm,posit);
    }
    ret;

  }
parsedateexit:
}

macro FMTDATE 
{
  /*
     Follow the rules for returning date strings.
  */
  str workstr = '';
  int ordinal = 0;
  int limit, foo;
  if(global_int('isjulian'))
  {
    limit = J_count;
    while(ordinal < limit)
    {
      if(ordinal) workstr = workstr + J_sep;
      switch(ordinal)
      {
        case JD_ord : workstr = workstr + str(global_int('workd')); break;
        case JY_ord : call fmtyear; break;
        default     : break;
      }
    ordinal ++ ;
    }
  }
  if(global_int('isgregorian'))
  {
    limit = G_count;
    while (ordinal < limit)
    {
      if(ordinal) workstr = workstr + G_sep;
      switch(ordinal)
      {
        case M_ord : workstr = workstr + str(global_int('workm')); break;
        case D_ord : workstr = workstr + str(global_int('workd'))  ; break;
        case Y_ord : call fmtyear; break;
        default    : break;
      }
    ordinal ++;
    }
  }
  goto fmtdateexit;

fmtyear:
  foo = global_int('worky');
  if(global_int('twodigit')) foo = foo - global_int('century');
  workstr = workstr + str(foo);
  ret;

fmtdateexit:
  return_str = workstr;
}

macro ISLEAPYEAR 
{
  /*
     Set lyear based upon integer parameter
     Rules (as normally stated):
       Century years are leap years only if exact multiples of 400.
       Non-century years are leap years if exact multiples of 4.
     Rules (as implemented):
       Any year which is an exact multiple of 400 is a leap year.
       Any year which is NOT an exact multiple of 100 and IS an
         exact multiple of 4 is a leap year.
  */
  int year;
  if (not(val(year,mparm_str)))
  {
    if ((not(year%400)) || ((year%100)&&(not(year%4))))
         return_int = 1;
       else
         return_int = 0;
  }
}

macro YEARDIFF 
{
  /*
    return number of days difference across whole year boundaries
    from gyear to worky. Return value in workd.
  */

  int from = global_int('gyear');
  int to   = global_int('worky');
  int retval = 0;
  while (from > to)
  {
    rm('isleapyear '+str(from));
    retval = retval - (365 + return_int);
    from--;
  }
  while (from < to)
  {
    rm('isleapyear '+str(from));
    retval = retval + 365 + return_int;
    from ++;
  }
  set_global_int('workd',retval);
}

macro ARGONE 
{
  /*
     return the first space-delimited argument from the input string.
     will return empty string if argument starts with a blank to indicate
     first argument omitted.
  */

  char delimiter = ' ';
  str mystr = mparm_str;
  int limit = svl(mystr);
  int posit = 1;
  int len = 0;

  while (not(str_char(mystr,posit) == ' ') && (posit <= limit))
  {
    posit ++;
    len ++;
  }
  return_str = copy(mystr,1,len);
}

macro ARGTWO 
{
  /* return the second space-delimited argument from the input string */
  char delimiter = ' ';
  str mystr = mparm_str;
  int limit = svl(mystr);
  int posit = 1;
  int len = limit;

  /* find first blank delimiter */
  while (not(str_char(mystr,posit) == ' ') && (posit <= limit))
  {
    posit ++;
    len --;
  }

  /* skip all consecutive blank delimiters */
  while (str_char(mystr,posit) == ' ' && (posit <= limit))
  {
    posit ++;
    len --;
  }

  /* return everything thereafter */

  return_str = copy(mystr,posit,len);
}