/* (c) Copyright 1992, Raymond P. Tackett */

/* The date separator characters */

  #define G_sep '-'  /* Gregorian separator */
  #define J_sep '.'  /* Julian separator    */

/* Date ordering definitions as ordinal within string */

  /* Gregorian ordinal positions within numeric date */

  #define M_ord 0
  #define D_ord 1
  #define Y_ord 2
  #define G_count 3

  /* Julian ordinal positions */

  #define JD_ord 0
  #define JY_ord 1
  #define J_count 2

/* Month name strings */

  #define M_1  'January'
  #define M_2  'February'
  #define M_3  'March'
  #define M_4  'April'
  #define M_5  'May'
  #define M_6  'June'
  #define M_7  'July'
  #define M_8  'August'
  #define M_9  'September'
  #define M_A  'October'
  #define M_B  'November'
  #define M_C  'December'

/* Day name strings */

  #define D_1  'Sunday'
  #define D_2  'Monday'
  #define D_3  'Tuesday'
  #define D_4  'Wednesday'
  #define D_5  'Thursday'
  #define D_6  'Friday'
  #define D_7  'Saturday'

/* Default template for date string returned by TEXTDATE
     %M = substitute month name, e.g. January
     %m = substitute month number, e.g., 01
     %D = substitute day name, e.g. first
     %d = substitute day number, e.g., 1
     %Y = substitute year name, e.g., one thousand nine hundred ninety two
     %y = substitute year number, e.g., 1992
     %W = substitute name of day of week, e.g., Sunday
     %w = substitute number of day of week 1-7 (Sunday - Saturday)
     %J = substitute julian day name
     %j = substitute julian day number
*/

  #define T_F  '%M %d, %y'
  #define CTL_SEP '%'
  #define M_NAME 'M'
  #define M_NUM  'm'
  #define D_NAME 'D'
  #define D_NUM  'd'
  #define Y_NAME 'Y'
  #define Y_NUM  'y'
  #define W_NAME 'W'
  #define W_NUM  'w'
  #define J_NAME 'J'
  #define J_NUM  'j'

/* Number words */

  #define G_W  'billion '
  #define M_W  'million '
  #define K_W  'thousand '
  #define C_W  'hundred '
  #define T_9  'ninety '
  #define T_8  'eighty '
  #define T_7  'seventy '
  #define T_6  'sixty '
  #define T_5  'fifty '
  #define T_4  'forty '
  #define T_3  'thirty '
  #define T_2  'twenty '
  #define T_19 'nineteen '
  #define T_18 'eighteen '
  #define T_17 'seventeen '
  #define T_16 'sixteen '
  #define T_15 'fifteen '
  #define T_14 'fourteen '
  #define T_13 'thirteen '
  #define T_12 'twelve '
  #define T_11 'eleven '
  #define T_10 'ten '
  #define U_9  'nine '
  #define U_8  'eight '
  #define U_7  'seven '
  #define U_6  'six '
  #define U_5  'five '
  #define U_4  'four '
  #define U_3  'three '
  #define U_2  'two '
  #define U_1  'one '

/* Ordinal words */

  #define G_WF  'billionth'
  #define M_WF  'millionth'
  #define K_WF  'thousandth'
  #define C_WF  'hundredth'
  #define T_9F  'ninetieth'
  #define T_8F  'eightieth'
  #define T_7F  'seventieth'
  #define T_6F  'sixtieth'
  #define T_5F  'fiftieth'
  #define T_4F  'fortieth'
  #define T_3F  'thirtieth'
  #define T_2F  'twentieth'
  #define T_19F 'nineteenth'
  #define T_18F 'eighteenth'
  #define T_17F 'seventeenth'
  #define T_16F 'sixteenth'
  #define T_15F 'fifteenth'
  #define T_14F 'fourteenth'
  #define T_13F 'thirteenth'
  #define T_12F 'twelfth'
  #define T_11F 'eleventh'
  #define T_10F 'tenth'
  #define U_9F  'ninth'
  #define U_8F  'eighth'
  #define U_7F  'seventh'
  #define U_6F  'sixth'
  #define U_5F  'fifth'
  #define U_4F  'fourth'
  #define U_3F  'third'
  #define U_2F  'second'
  #define U_1F  'first'

/* Negative number word */

  #define M_WORD 'minus '

/* Zero word */

  #define Z_WORD 'zero '

/* Number of days in a month */

  #define N_1  31   /* January */
  #define N_2  28
  #define N_3  31
  #define N_4  30
  #define N_5  31
  #define N_6  30   /* June    */
  #define N_7  31
  #define N_8  31
  #define N_9  30
  #define N_A  31
  #define N_B  30
  #define N_C  31   /* December */

/* Number of days in a month, leap year */

  #define NL_1  31   /* January */
  #define NL_2  29
  #define NL_3  31
  #define NL_4  30
  #define NL_5  31
  #define NL_6  30   /* June    */
  #define NL_7  31
  #define NL_8  31
  #define NL_9  30
  #define NL_A  31
  #define NL_B  30
  #define NL_C  31   /* December */

/* Cumulative days in a regular year, month by month */

  #define J_1    0
  #define J_2   31
  #define J_3   59
  #define J_4   90
  #define J_5  120
  #define J_6  151
  #define J_7  181
  #define J_8  212
  #define J_9  243
  #define J_A  273
  #define J_B  304
  #define J_C  334
  #define J_D  365  /* for Julian day validation */

/* Cumulative days in a leap year, month by month */

  #define JL_1    0
  #define JL_2   31
  #define JL_3   60
  #define JL_4   91
  #define JL_5  121
  #define JL_6  152
  #define JL_7  182
  #define JL_8  213
  #define JL_9  244
  #define JL_A  274
  #define JL_B  305
  #define JL_C  335
  #define JL_D  366  /* for Julian day validation */