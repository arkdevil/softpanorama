/***********************************************************************/
/* oci.h - REXX/SQL for Oracle                                         */
/***********************************************************************/
/*
 * REXX/SQL. A REXX interface to SQL databases.
 * Copyright Impact Systems Pty Ltd, 1994, 1995.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to:
 *
 *    The Free Software Foundation, Inc.
 *    675 Mass Ave,
 *    Cambridge, MA 02139 USA.
 *
 *
 * If you make modifications to this software that you feel increases
 * it usefulness for the rest of the community, please email the
 * changes, enhancements, bug fixes as well as any and all ideas to 
 * address below.
 * This software is going to be maintained and enhanced as deemed
 * necessary by the community.
 *
 * Mark Hessling                     email: M.Hessling@qut.edu.au
 * 36 David Road                     Phone: +61 7 849 7731
 * Holland Park                      
 * QLD 4121
 * Australia
 *
 * Author:	Chris O'Sullivan  Ph (Australia) 015 123414
 *
 * Header file for ORACLE Call Interface
 * 
 * Defines structures CURSOR, SQLWA etc.
 *
 */

#define V2ERRORCODE(cursor)	((cursor)->csrrc)
#define V4ERRORCODE(cursor)	((cursor)->csrarc)
#define SQLROWCNT(cursor)	((cursor)->csrrpc)
#define SQLERRPOS(cursor)	((cursor)->csrpeo)

#define NO_DATA_FOUND		4		/* V2 return code */

#define MAX_COLS		254
#define MAX_NAMELEN		30
#define MAX_BINDVARS		256	

#define ORA_DATE_LEN		9		/* DD-MON-YY */
#define ORA_LONG_LEN		(32 * 1024 - 1)	/* Limited by odefin() */

#define SIZEOF_HDA		256	/* define Host Data Area (HDA) size */


/*
 * ORACLE external datatypes (used for input/output to Oracle)
 */
#define EXT_CHAR	 1	/* External CHAR datatype */


/*
 * ORACLE internal datatypes
 */
#define ORA_VARCHAR2	 1	/* Internal VARCHAR2 datatype */
#define ORA_NUMBER	 2	/* Internal NUMBER datatype */
#define ORA_LONG	 8	/* Internal LONG datatype */
#define ORA_UNKNOWN	10	/* Datatype unknown until after binding */
#define ORA_ROWID	11	/* Internal ROWID */
#define ORA_DATE	12	/* Internal DATE datatype */
#define ORA_RAW		23	/* Internal RAW datatype */
#define ORA_LONGRAW	24	/* Internal LONG RAW datatype */
#define ORA_CHAR	96	/* Internal ANSI compatible CHAR datatype */
#define ORA_MLSLABEL   106	/* Internal MLSLABEL datatype */


/*
 *
 * Define the C version of the CURSOR (for 32 bit machines)
 */
typedef struct {
	short		csrrc;		        	       /* return code */
	short	  	csrft;				     /* function type */
	unsigned long  	csrrpc;			      /* rows processed count */
	short	 	csrpeo;			        /* parse error offset */
	unsigned char  	csrfc;				     /* function code */
	unsigned char  	csrfil;				           /* filler  */
	unsigned short 	csrarc;			             /* V4 error code */
	unsigned char  	csrwrn;				     /* warning flags */
	unsigned char  	csrflg;				       /* error flags */
	/********************* Operating system dependent *********************/
	unsigned int   	csrcn;				     /* cursor number */
	struct {				           /* rowid structure */
		struct {
			unsigned long	tidtrba;  /* rba of 1st blockof table */
			unsigned short	tidpid;      /* partition id of table */
			unsigned char	tidtbl;          /* table id of table */
		} ridtid;
		unsigned long	ridbrba;	          /* rba of datablock */
		unsigned short  ridsqn;	   /* sequence number of row in block */
	} csrrid;
	unsigned int   	csrose;		           /* os dependent error code */
	unsigned char  	csrchk;				        /* check byte */
	unsigned char  	crsfill[30];	            /* private, reserved fill originally was 26 now 30*/
} CURSOR;


/* These are defined in the new Oracle7 header files! Should be converted */
#if __STDC__
typedef          int   eword;
typedef signed   int   sword;
typedef unsigned int   uword;
typedef          char  eb1;
typedef signed   char  sb1;
typedef unsigned char  ub1;
typedef          short eb2;
typedef signed   short sb2;
typedef unsigned short ub2;
typedef          long  eb4;
typedef signed   long  sb4;
typedef unsigned long  ub4;
typedef unsigned char  text;
#else
typedef          int   eword;
typedef          int   sword;
typedef unsigned int   uword;
typedef          char  eb1;
typedef          char  sb1;
typedef unsigned char  ub1;
typedef          short eb2;
typedef          short sb2;
typedef unsigned short ub2;
typedef          long  eb4;
typedef          long  sb4;
typedef unsigned long  ub4;
typedef unsigned char  text;
#endif

typedef struct {
	sb4	rbufl;         /* Size of buffer to hold fetched column value */
	sb4	cbufl;      /* Length of column name - reset to actual length */
	sb2	rcode;         /* Column return code - valid only after fetch */
	sb2	dbtype;                           /* Internal Oracle datatype */
	sb2	retl;                               /* Return length of field */
	sb2	indp;               /* Indicator for field - after each fetch */
                          /* <0 - NULL; 0 - OK; >0 - length BEFORE truncation */
	sb2	prec;                         /* Precision of number datatype */
	sb2	scale;                            /* Scale of number datatype */
	sb2	nullok;                 /* Are nulls permitted? 0=no, <>0=yes */
	ub1	*rbuf;      /* Pointer to buffer to hold fetched column value */
	ub1	cbuf[MAX_NAMELEN+1];            /* Buffer to hold column name */
} FLDDSCR;


/*
 * Definition of SQL Work Area (SQLWA).  This contains the ORACLE user
 * context area plus additional information required by this interface to
 * control the processing of SQL statements.
 * Note that the oracle CURSOR structure must be physically the first object
 * in this structure!!
 */

typedef struct {
    CURSOR ora;                                 /* ORACLE cursor area */
    char *sql_stmt;            /* ptr to buffer to hold SQL statement */
    int select;            /* 1 if statement is a SELECT, 0 otherwise */
    size_t      sql_stmt_sz;    /* size of allocated statement buffer */
    int bind_cnt;                      /* number of bind values bound */
    int expr_cnt;             /* number of expressions in select list */
    FLDDSCR *fa[MAX_COLS];      /* array of pointers to column dscr's */
} SQLWA;

#if __STDC__
sword obndrn(CURSOR*,sword,ub1*,sword,sword,sword,sb2*,text*,sword,sword);
sword obndrv(CURSOR*,text*,sword,ub1*,sword,sword,sword,sb2*,text*,sword,sword);
sword oclose(CURSOR*);
sword ocan(CURSOR*);
sword odescr(CURSOR*,sword,sb4*,sb2*,sb1*,sb4*,sb4*,sb2*,sb2*,sb2*);
sword oexec(CURSOR*);
sword ofetch(CURSOR*);
sword ologof(CURSOR*);
sword oopen(CURSOR*,CURSOR*,text*,sword,sword,text*,sword);
sword oparse(CURSOR*,text*,sb4,sword,ub4);
sword orlon(CURSOR*,ub1*,text*,sword,text*,sword,sword);
sword osql3(CURSOR*,text*,sword);
#else
sword obndrn(/*CURSOR*,sword,ub1*,sword,sword,sword,sb2*,text*,sword,sword*/);
sword obndrv(/*CURSOR*,text*,sword,ub1*,sword,sword,sword,sb2*,text*,sword,sword*/);
sword oclose(/*CURSOR**/);
sword ocan(/*CURSOR**/);
sword odescr(/*CURSOR*,sword,sb4*,sb2*,sb1*,sb4*,sb4*,sb2*,sb2*,sb2**/);
sword oexec(/*CURSOR**/);
sword ofetch(/*CURSOR**/);
sword ologof(/*CURSOR**/);
sword oopen(/*CURSOR*,CURSOR*,text*,sword,sword,text*,sword*/);
sword oparse(/*CURSOR*,text*,sb4,sword,ub4*/);
sword orlon(/*CURSOR*,ub1*,text*,sword,text*,sword,sword*/);
sword osql3(/*CURSOR*,text*,sword*/);
#endif
