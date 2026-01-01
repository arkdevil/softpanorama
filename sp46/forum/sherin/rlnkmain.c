/*[]--------------------------------------------------------------[]*/
/*| имя файла - rlnkmain.c                                         |*/
/*|                                                                |*/
/*| функция  main  для утилиты  RELINK                             |*/
/*|                                                                |*/
/*[]--------------------------------------------------------------[]*/


/*[]--------------------------------------------------------------[]*/
/*|                                                                |*/
/*|      Design Plus Utilities   -   Version 1.0                   |*/
/*|                                                                |*/
/*|                                                                |*/
/*|      Copyright (c) 1992 by Acta, Ltd.                          |*/
/*|      All rights reserved.                                      |*/
/*|                                                                |*/
/*[]--------------------------------------------------------------[]*/


// Interface Dependencies --------------------------------------------

#ifndef   RELINKH
#include "relink.h"
#endif

// End Interface Dependencies ----------------------------------------

// Implementation Dependencies ---------------------------------------

#ifndef  _STDIO_H
#include <stdio.h>
#endif

#ifndef  _STRING_H
#include <string.h>
#endif

// End Implementation Dependencies -----------------------------------

// Implementation Constants ------------------------------------------

#ifndef NULL
#define NULL 0L
#endif

#define NOMODE     -1
#define INCOMP     -2
#define HELPSCREEN -3
#define TOOFEWPARM -4
#define NOMSG      -5

char *Copyright = "Relink, Design Plus Utilities 1.0, Copyright (c) 1992 by ACTA, Ltd.\n\r";
char *ListInfo  = "\n\rСписок Lookup Tables для отчета %s\
		   \n\r-------------------------------------------";
char *ErrMsg[]  = { /*00*/"\n\rВыполнена замена в отчете %s : %s -> %s\n\r",
		    /*01*/"\n\rЗамена имени Lookup Table в отчете PARADOX\n\r\
\n\rRELINK [/|-<ключ>] <отчет> [<имя1> <имя2>]\n\r\
\n\r   отчет - полное имя файла отчета PARADOX\
\n\r   имя1  - имя Lookup Table в отчете PARADOX\
\n\r   имя2  - имя таблицы или путь доступа для замены <имя1>\n\r\
\n\rКлючи :\
\n\r   /A      -  полная замена имени Lookup Table (по умолчанию)\
\n\r   /P      -  заменить только путь доступа к таблице\
\n\r   /N      -  заменить только имя таблицы\
\n\r   /L      -  вывести список всех Lookup Tables в отчете\
\n\r   /S      -  не выдавать сообщений на экран\
\n\r   /H, /?  -  этот экран\n\r\
\n\rПримеры :\
\n\r   RELINK mytable.r3 this d:\\dir\\that\
\n\r   RELINK /s /p mytable.r7 temptab e:\\temp\n\r",
		    /*02*/"\n\rНесовместимые ключи\n\r",
		    /*03*/"\n\rМало параметров\n\r",
		    /*04*/"\n\rФайл отчета %s не найден\n\r",
		    /*05*/"\n\rВ отчете %s Lookup Table %s отсутствует\n\r",
		    /*06*/"\n\rВ отчете %s нет Lookup Table\n\r",
		    /*07*/"\n\rОшибка чтения файла отчета %s\n\r",
		    /*08*/"\n\rОшибка записи файла отчета %s\n\r",
		    /*09*/"\n\rНе хватает памяти для работы программы\n\r",
		    /*10*/"\n\rВнутренняя ошибка. Обратитесь к разработчику\n\r",
		    /*11*/"\n\rОшибка в параметрах\n\r"
		  };

// End Implementation Constants --------------------------------------


// Function Main //

int main( int argc, char **argv )
{
 int   Mode = NOMODE, Count = 1, Silence = 0;
 char *RetMsg;

 if( argc > 1 ) 
     while( ( *argv[Count] == '/' || *argv[Count] == '-' ) && Count <= argc )
	   {
	    strupr( argv[Count] );
	    switch( *( argv[Count] + 1 ) )
		   {
		    case 'A' : if( Mode == NOMODE )
				   Mode = REPLACEALL;
			       else
				   Mode = INCOMP;
			       break;
		    case 'P' : if( Mode == NOMODE )
				   Mode = PATHONLY;
			       else
				   Mode = INCOMP;
			       break;
		    case 'N' : if( Mode == NOMODE )
				   Mode = NAMEONLY;
			       else
				   Mode = INCOMP;
			       break;
		    case 'L' : if( Mode == NOMODE && !Silence )
				   Mode = LOOKUPLIST;
			       else
				   Mode = INCOMP;
			       break;
		    case 'S' : if( Mode == LOOKUPLIST )
				   Mode = INCOMP;
			       else
				   Silence = 1;
			       break;
		    default  : if( Mode == NOMODE )
				   Mode = HELPSCREEN;
		   }
	    Count++;
	   }
 else
     Mode = HELPSCREEN;
 if( Mode == NOMODE )
     Mode = REPLACEALL;

 if( !Silence )
     printf( "%s", Copyright );

 if( Mode == LOOKUPLIST && argc >= Count + 1 )
    {
     printf( ListInfo, strupr( argv[Count] ) );
     Mode = Relink( argv[Count], NULL, NULL, Mode );
     if( !Mode )
	 Mode = NOMSG;
    }
 else
 if( Mode >= 0 && argc >= Count + 3 )
     Mode = Relink( argv[Count], argv[Count+1], argv[Count+2], Mode );
 else
 if( Mode >= 0 )
     Mode = TOOFEWPARM;

 if( !Silence )
    {
     switch( Mode )
	    {
	     case ALL_RIGHT_MAMA : RetMsg = ErrMsg[0];
				   break;
	     case HELPSCREEN     : RetMsg = ErrMsg[1];
				   break;
	     case INCOMP         : RetMsg = ErrMsg[2];
				   break;
	     case TOOFEWPARM     : RetMsg = ErrMsg[3];
				   break;
	     case WHERE_IS_FILE  : RetMsg = ErrMsg[4];
				   break;
	     case LOOKUP_ABSENT  : RetMsg = ErrMsg[5];
				   break;
	     case LOOKUP_EMPTY   : RetMsg = ErrMsg[6];
				   break;
	     case NOMSG          : RetMsg = NULL;
				   break;
	     case ERROR_READ     : RetMsg = ErrMsg[7];
				   break;
	     case ERROR_WRITE    : RetMsg = ErrMsg[8];
				   break;
	     case MEMORY_LIMIT   : RetMsg = ErrMsg[9];
				   break;
	     case INVALID_PARM   : RetMsg = ErrMsg[11];
				   break;
	     default             : RetMsg = ErrMsg[10];
				   break;
	    }
     if( RetMsg )
	 printf( RetMsg, strupr( argv[Count] ), strupr( argv[Count+1] ), strupr( argv[Count+2] ) );
    }

 if( Mode )
     return 1;
 else
     return 0;
}
// End Function Main //
