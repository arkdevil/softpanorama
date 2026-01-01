#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <dos.h>
#include <process.h>
#include <bios.h>
#include <ctype.h>
#include <time.h>

typedef  unsigned int uint;
typedef  unsigned int ushort;
typedef  unsigned long ulong;
typedef  unsigned char uchar;

// compile it in Compact model !

char time_str[20];
char *ClaTime( long abstime )
{
    uint i, hour, minute; // , seconds, hundreds;
    for( i=0; i<11; i++ ) *((uint *)&time_str[i])=0x0020;
    if ((abstime < 1) || (abstime > 8640000L)) return time_str;

       abstime-- ;
       hour = abstime / 360000L;
       abstime = abstime % 360000L;
       minute = abstime / 6000;
       // abstime = abstime % 6000;
       // seconds = abstime / 100;
       // hundreds = abstime % 100;

    sprintf( time_str, "  %2u:%2u  ", hour, minute );
    return time_str;
}

// преобразует строку в формат Decimal справа налево,
// последние нецифры пропускаются
// точка должна быть, но она игнорируется
char str2decimal( char *str, char *num, signed int len )
{
        char ciffer, nibble, minus, error;
	uint count;
        error=1;
	nibble=0;
	minus=0;
	count=strlen( str );
        if ( count==0 ) return error;
        while (( count ) && ( !isdigit( str[count-1] ))) count--;
        if ( count==0 ) return error;
        str += count-1; // крайняя справа цифра
        num += len-1;   // правый край буфера

        while (( count ) && ( len ))
        {
            if ( *str == 0x2E ) // если найдена точка
            goto decr;

            if ( *str == 0x2D ) // если найден минус
            {
              str--;
              count--;
              minus=1;
              break;
            };

            if ( *str == 0x20 ) // если найден пробел
            {
              str--;
              count--;
              break;
            };

            if ( !isdigit( *str )) return error;

            ciffer = (*str-48) & 0x0F; // превратим цифру в ниббл
            if ( nibble==0 )
            {
               *num &= 0xF0; *num |= ciffer; nibble=1;
            }
            else
            {
               *num &= 0x0F; *num |= (ciffer<<4); nibble=0; num--; len--;
            };

            decr:
            str--;
            count--;
        };
        // если исчерпаны не все цифры, а буфер кончился
        if (( isdigit( *str ) ) && ( len==0 )) return error;
        while ( count )
        {
            if ( *str != 0x20 ) // если найден не пробел слева от числа
              return error;
              str--;
              count--;
        }

        do {
            if ( nibble==0 ) { *num = 0; nibble=1; }
            else             { *num &= 0x0F; nibble=0; num--; len--; };
        } while ( len>0 );

        if ( minus ) *num ^= 0x80;
        return 0;
}


// Dates are more involved.  Given an absolute date (absday):
char number_of_days[]={ 31, 28, 31, 30, 31,
                        30, 31, 31, 30, 31,
                        30, 31 };
char date_str[20];
char *ClaDate( ulong absday )
{
    int year, day, month, i;
    if (( absday <= 3 ) || ( absday > 109211L ))
    {
	for( i=0; i<11; i++ ) *((uint *)&date_str[i])=0x0020;
        return date_str;
    }
    if ( absday > 36527L ) absday -= 3; else absday -= 4;
    year = (1801 + (4* (absday / 1461)));
    absday = absday % 1461;
    if ( absday != 1460 )
    {
        year = year + (absday / 365);
        day = absday % 365;
    }
    else
    {
        year = year + 3;
        day = 365;
    };
    if ( year < 100 ) year = year + 1900;
    if ((( year % 4) == 0 ) && ( year != 1900 ))
    {
        number_of_days[1] = 29;
    }
    else
    {
        number_of_days[1] = 28;
    };
    for ( i=1; i<13; i++ )
    {
        day -= (int)number_of_days[i-1];
        if ( day < 0 )
        {
            day += (int)number_of_days[i-1]+1;
            break;
        }
    }
    month = i;
    sprintf( date_str, "%2u.%2u.%u", day, month, year );
    return date_str;
}


char key_flag[60];
char *keyFlag2str( char flag )
{
	int offs; uchar mask=0x10;
	if ( flag & 0x0F )
	   sprintf( key_flag, "%s", "Index");
	else
	   sprintf( key_flag, "%s", "Key  ");
	offs=5;
	while ( mask )
	{
	if ( flag & mask )
	   sprintf( key_flag+offs, "%s", "    Yes ");
	else
	   sprintf( key_flag+offs, "%s", "    No  ");
	mask <<= 1;
	offs += 8;
        }
        return key_flag;
}
