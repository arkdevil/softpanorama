/*------------------------------------------------------------------------
 * filename - tzset.c
 *
 * function(s)
 *        tzset     - UNIX time compatibility
 *        __isDST   - determines whether daylight savings is in effect
 *-----------------------------------------------------------------------*/

#pragma option -zC_TEXT

#include <io.h>
#include <time.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char *_tz;

#define YES 1
#define NO  0

#define Normal    0
#define Daylight  1
#define TZstrlen        3        /* Len of tz string(- null terminator) */
#define DefaultTimeZone -3L
#define DefaultDaylight YES
#define DefaultTZname   "MSK"    /* Default normal time zone name */
#define DefaultDSTname  "MSD"    /* Default daylight savings zone name */

static char _DfltZone[ TZstrlen+1 ], _DfltLight[ TZstrlen+1 ];
char  *const tzname[2] = {&_DfltZone[0], &_DfltLight[0]};

long  timezone = DefaultTimeZone * 60L * 60L; /* Set for MSK */

int   daylight = DefaultDaylight;             /* Apply daylight savings */

/*---------------------------------------------------------------------*

Name		tzset

Usage		void tzset(void);

Prototype in	time.h

Description	sets local timezone info base on the "TZ" environment string

Return value	None

*---------------------------------------------------------------------*/
void  tzset(void)
{
	register int  i;       /* A loop index */
	char *env;             /* Pointer to "TZ" environment string */

#define  issign(c)   (((c) == '-') || ((c) == '+'))

	if (
	   /************************************************************
		  1. Check for "TZ" string in the environment.
				env[0] - 1st char in time zone name
				env[1] - 2nd "    "   "    "
				env[2] - 3rd "    "   "    "
				env[3] - 1st char in time zone difference value
				env[4] - 2nd "    "   "    "       "        "
		  2. Rule out short strings.
		  3. Rule out non A-Z time zone characters.
		  4. Rule out bad time zone difference numbers.
			 a. Not a +/- or 0-9.
			 b. Sign with no following digit(s).
	   ************************************************************/
/* 1. */ ((env = getenv("TZ")) == NULL)                                   &&
/* 1. */ ((env = _tz) == NULL)                                            ||
/* 2. */ (strlen(env) < (TZstrlen+1))                                     ||
/* 3. */ ((!isalpha(env[0])) || (!isalpha(env[1])) || (!isalpha(env[2]))) ||
/* 4a.*/ (!(issign(env[ TZstrlen ]) || isdigit(env[ TZstrlen ])))         ||
/* 4b.*/ ((!isdigit(env[ TZstrlen ])) && (!isdigit(env[ TZstrlen+1 ]))) )
	{
		/*----- Missing or bogus "TZ" string, set default values -----*/

		daylight = DefaultDaylight;
		timezone = DefaultTimeZone * 60L * 60L;
		strcpy(tzname[Normal], DefaultTZname);
		strcpy(tzname[Daylight], DefaultDSTname);
	}
	else	/*----- Parse the "TZ" string and set values from string -----*/
	{
		memset(tzname[Daylight], 0, TZstrlen+1); /* Dlt daylight to NULL  */
		strncpy(tzname[Normal], env, TZstrlen);  /* Set zime zone string  */
		tzname[Normal][TZstrlen] = '\0';         /* Force NULL termination*/
		timezone = atol(&env[TZstrlen]) * 3600L; /* Base timezone on "TZ" */

		/*----- Scan for optional daylight savings field -----*/

		/* Scan for string start  */
		for (daylight=NO,i=TZstrlen; env[i]; i++)
		{
			if (isalpha(env[i]))        /* Found the string start */
				{
				if ((strlen(&env[i])<TZstrlen) ||
									(!isalpha(env[i+1]))       ||
									(!isalpha(env[i+2])) )
					break;
				/* Copy and null-terminate dlt sav string */
				strncpy(tzname[Daylight], &env[i], TZstrlen);
				tzname[Daylight][TZstrlen] = '\0';
				daylight = YES;
				break;
			}
		}
	}
}


#define M_START_DST 3 /* March */
#define M_END_DST   9 /* September */

/* Derived from astrolog sources */

static unsigned long mdytojulian(unsigned mon, unsigned day, unsigned yea)
{
  unsigned long im, j;

  im = 12*((unsigned long)yea+4800)+mon-3;
  j = (2*(im%12)+7+365*im)/12;
  j = j+day+im/48-32083;
  if (j > 2299171L)             /* Take care of dates in */
	j += im/4800-im/1200+38;    /* Gregorian calendar.   */
  return j;
}

static short mdays[12] = {
   31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

/*--------------------------------------------------------------------------*

Name            __isDST  -  determines whether daylight savings is in effect

Usage           int  pascal __isDST (unsigned hour,  unsigned yday,
					 unsigned month, unsigned year);

Description     Returns non-zero if daylight savings is in effect for
		the given date.

		If month is 0, yday is the day of the year, otherwise yday is
		the day of the month.

		It is assumed that the caller has called tzset() to fill in
		the timezone info.

Return value    Non-zero if DST is in effect for the given date.

*---------------------------------------------------------------------------*/
int pascal near __isDST(unsigned hour, unsigned mday, unsigned month, unsigned year)
{
	register unsigned i;

	year += 1970;
	mdays[1] = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))
		  ? 29 : 28;
	if (month == 0)		/* if only day of year given	*/
	{
		mday++;
		for (i = 0; i < 12 && mday > mdays[i]; i++)
			mday -= mdays[i];
		month = i + 1;
	}

	/* Test for March/September */
	if (month < M_START_DST || month > M_END_DST)
		return 0;
	if (month != M_START_DST && month != M_END_DST)
		return 1;

	i = mdays[month-1] - ((mdytojulian(month, mdays[month-1], year) + 1) % 7);

	/* Test for last Sunday */
	if (mday < i)
		return (month == M_END_DST);
	if (mday > i)
		return (month == M_START_DST);

	/* Test for 2am (March) and 3am (September) */
	return (   month == M_START_DST && hour >= 2
			|| month == M_END_DST && hour < 3
			);
}
