/*[]--------------------------------------------------------------[]*/
/*| имя файла - relink.h                                           |*/
/*|                                                                |*/
/*| файл описания функций библиотеки утилит Design Plus            |*/
/*|                                                                |*/
/*[]--------------------------------------------------------------[]*/


/*[]--------------------------------------------------------------[]*/
/*|                                                                |*/
/*|      Design Plus Utilities Library   -   Version 1.0           |*/
/*|      Interface file                                            |*/
/*|                                                                |*/
/*|      Copyright (c) 1992 by Acta, Ltd.                          |*/
/*|      All rights reserved.                                      |*/
/*|                                                                |*/
/*[]--------------------------------------------------------------[]*/


#ifndef RELINKH
#define RELINKH

#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

// Режимы замены функции Relink

#define REPLACEALL 0        // полная замена
#define PATHONLY   1        // замена только пути доступа
#define NAMEONLY   2        // замена только имени таблицы
#define LOOKUPLIST 3        // список Lookup Table

// Коды заверешения для функции Relink

#define ALL_RIGHT_MAMA     0
#define LOOKUP_EMPTY       1
#define INVALID_PARM       2
#define WHERE_IS_FILE      3
#define MEMORY_LIMIT       4
#define ERROR_READ         5
#define ERROR_WRITE        6
#define LOOKUP_ABSENT      7


int Relink( char *ReportName,        // имя файла отчета PARADOX
	    char *OldTable,          // старое имя Lookup Table
	    char *NewTable,          // новое имя Lookup Table
	    int   Mode               // режим замены
	  );


#endif
