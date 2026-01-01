/***********************************************************************/
/* orasql.c - REXX/SQL for Oracle                                      */
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
 *    Purpose:	This module provides an Oracle SQL interface for REXX. It
 *		allows REXX programs to connect to Oracle servers, issue SQL
 *		queries, DDL, DCL & DML statements. Multiple concurrent
 *		connections are supported. Additionally, multiple statements
 *		may be active concurrently against any or all of these
 *		connections. This interface is called "REXX/SQL".
 *
 *      Notes:	1) The REXX/SQL interface is built using the Oracle Call
 *		Interface (OCI libraries). As such it does require that the
 *		object code be linked with the OCI libraries. Consequently,
 *		it does not require the Oracle Pre-compilers (i.e. Pro*C) to
 *		compile it. Also, it does not require the Pro* libraries
 *		(e.g. SQLLIB) at link time.
 *
 *		2) I have attempted to write this module so that the Oracle
 *              interface could be replaced by another (say GUPTA) without
 *              affecting REXX programs which have been written for this inter-
 *              face (providing these programs use ANSI SQL). Any programs
 *		using DDL or DCL will not be portable without some clever
 *		programming!
 *
 *		3) REXX/SQL currently contains the interface functions for
 *		ORACLE V6.  True Oracle7 support will be added at a later time.
 *
 *		4) Very little has been added to support the performance
 *		features of Oracle. The interface does allow a statement to be
 *		parsed once and executed multiple times. Binding is another
 *		matter. Since arguments are passed by value, it was a tradeoff
 *		as to whether to dynamically allocate a buffer for each bind
 *		value and allow the statement to be reexecuted without rebinding
 *		(or rebinding of selected variables). The alternative was to
 *		assume that the extra overhead of the malloc() and strcpy()
 *		would be less efficient in many cases. At this point in time,
 *		the values passed to the function are bound directly. A rebind
 *		is thus necessary each time SQLEXECUTE() or SQLOPEN() is
 *		called.
 *
 *              5) As far as performance features there is currently no support
 *		for the following:
 *		 + Array fetches
 *		 + Array binding
 *		 + Bundled calls.
 *
 *		6) PL/SQL blocks are supported, however since all arguments
 *		to REXX functions are passed by value I have not thought of
 *		a suitable method of supporting bind values in PL/SQL blocks
 *		where the bind value is used for output. Input bind values
 *		are supported.
 *
 */


#if defined(USE_AIXREXX)
#   define PFN PRXFUNC
#endif

#define INCL_RXSHV	/* Shared variable support */
#define INCL_RXFUNC	/* External functions support */

#include "rexxsaa.h"
#include "rexxsql.h"

#include "hash.h"
#include "oci.h"

#if !defined(OS2)
#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned int	size_t;
#endif
#endif

#define TYPE_INT	0
#define TYPE_STRING	1

#define MAX_EXPRLEN		255       /* Max length of column expressions */
#define MAX_IDENTIFIER		30               /* Max length of identifiers */
#define TBL_STATEMENTS		253       /* Statement hash table vector size */
#define TBL_CONNECTIONS		17       /* Connection hash table vector size */
#define MAX_ERROR_TEXT		1024              /* Size of SQL error buffer */
#define DEFAULT_STATEMENT	"*DEFAULT*" /* Name of the implicit statement */


#if defined(ORA_PREFIX)
#   define SQLCA_STEM		"ORACA"     /* Name of stem of SQLCA variable */
#   define SQLCA_SQLCODE		"ORACA.SQLCODE"
#   define SQLCA_SQLERRM		"ORACA.SQLERRM"
#   define SQLCA_SQLTEXT		"ORACA.SQLTEXT"
#   define SQLCA_ROWCOUNT		"ORACA.ROWCOUNT"
#   define SQLCA_FUNCTION		"ORACA.FUNCTION"
#   define SQLCA_INTCODE		"ORACA.INTCODE"
#   define SQLCA_INTERRM		"ORACA.INTERRM"
#else
#   define SQLCA_STEM		"SQLCA"     /* Name of stem of SQLCA variable */
#   define SQLCA_SQLCODE		"SQLCA.SQLCODE"
#   define SQLCA_SQLERRM		"SQLCA.SQLERRM"
#   define SQLCA_SQLTEXT		"SQLCA.SQLTEXT"
#   define SQLCA_ROWCOUNT		"SQLCA.ROWCOUNT"
#   define SQLCA_FUNCTION		"SQLCA.FUNCTION"
#   define SQLCA_INTCODE		"SQLCA.INTCODE"
#   define SQLCA_INTERRM		"SQLCA.INTERRM"
#endif


#if defined(ORA_PREFIX)
#  if defined(USE_AIXREXX)
      ULONG OraVariable(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraConnect(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraDisconnet(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraDefault(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraCommit(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraRollback(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraCommand(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraPrepare(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraDispose(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraExecute(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraOpen(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraClose(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraFetch(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG OraDescribe(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
#  else
      RexxFunctionHandler OraVariable;
      RexxFunctionHandler OraConnect;
      RexxFunctionHandler OraDisconnect;
      RexxFunctionHandler OraDefault;
      RexxFunctionHandler OraCommit;
      RexxFunctionHandler OraRollback;
      RexxFunctionHandler OraCommand;
      RexxFunctionHandler OraPrepare;
      RexxFunctionHandler OraDispose;
      RexxFunctionHandler OraExecute;
      RexxFunctionHandler OraOpen;
      RexxFunctionHandler OraClose;
      RexxFunctionHandler OraFetch;
      RexxFunctionHandler OraDescribe;
#  endif
#else
#  if defined(USE_AIXREXX)
      ULONG SqlVariable(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlConnect(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlDisconnet(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlDefault(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlCommit(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlRollback(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlCommand(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlPrepare(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlDispose(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlExecute(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlOpen(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlClose(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlFetch(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
      ULONG SqlDescribe(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
#  else
      RexxFunctionHandler SqlVariable;
      RexxFunctionHandler SqlConnect;
      RexxFunctionHandler SqlDisconnect;
      RexxFunctionHandler SqlDefault;
      RexxFunctionHandler SqlCommit;
      RexxFunctionHandler SqlRollback;
      RexxFunctionHandler SqlCommand;
      RexxFunctionHandler SqlPrepare;
      RexxFunctionHandler SqlDispose;
      RexxFunctionHandler SqlExecute;
      RexxFunctionHandler SqlOpen;
      RexxFunctionHandler SqlClose;
      RexxFunctionHandler SqlFetch;
      RexxFunctionHandler SqlDescribe;
#  endif
#endif

#if defined(DYNAMIC_LIBRARY)
#  if defined(ORA_PREFIX)
#     if defined(USE_AIXREXX)
         ULONG OraLoadFuncs(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
         ULONG OraDropFuncs(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
#     else
         RexxFunctionHandler OraLoadFuncs;
         RexxFunctionHandler OraDropFuncs;
#     endif
#  else
#     if defined(USE_AIXREXX)
         ULONG SqlLoadFuncs(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
         ULONG SqlDropFuncs(PSZ,ULONG,PRXSTRING,PSZ,PRXSTRING);
#     else
         RexxFunctionHandler SqlLoadFuncs;
         RexxFunctionHandler SqlDropFuncs;
#     endif
#  endif
#endif


static char *column_attribute[] = {
    "NAME", "TYPE", "SIZE", "SCALE", "PRECISION", "NULLABLE", (char*)NULL
};

/*
 * Error value returned for errors returned by Oracle as opposed to
 * those generated by the interface.
 */
#define ORACLE_ERROR	(-1L)

/* Debugging flags */
int run_flags = 0;          /* can also be set via SQLVariable() */

/* Global Function Name - set on entry to every REXX/SQL function */
char FName[40];

/*
 * Settable variables
 * ------------------
 *
 * Limits number of rows returned by SQLCOMMAND(). If set to zero (0) then
 * all rows in query are returned (unless memory is exhausted in which case
 * an error is returned)!
 */
static ULONG RowLimit =  0;	/* Default is unlimited! */
/*
 * If TRUE, the SQL statement is saved on each parse (SqlCommand()
 * & SqlPrepare()).  If TRUE then on errors, the last SQL statement can be
 * retrieved in a REXX program by calling SQLVARIABLE().
 * eg.      error_stmt = SqlVariable('sqltext');
 */
static ULONG SaveSQL = TRUE;	/* Default is to save each SQL statement! */

/*
 * ReadOnly variables
 * ------------------
 *
 * Current version/platform
 * 
 * 
 */
static RXSTRING RexxSqlVersion;
static char RexxSqlVersionString[100];


#define LDA(stmt)	(&((stmt)->db->lda))	/* Ptr to STMT's LDA */
#define HDA(db)		((db)->hda)		/* Ptr to DBCON's HDA */
#define SWA(stmt)	(&((stmt)->sqlwa))	/* Ptr to STMT's SQL WorkArea */
#define CTX(swa)	(&((swa)->ora))		/* Ptr to Oracle cursor */
#define SEL(swa)	((swa)->select)		/* Ptr to SELECT flag */


/* Connection structure. Each connection requires one of these! */
typedef struct {
    char      name[MAX_IDENTIFIER+1];	/* Connection name */
    CURSOR    lda;			/* Logon Data Area for connection */
    char      hda[SIZEOF_HDA];		/* Host Data Area for connection */
    void      *dflt_stmt;		/* Pointer to implicit statement */
    int       num_statements;		/* Number of explicit statements */
} DBCON;


/* Statement structure. Each statement requires one of these! */
typedef struct {
    char      name[MAX_IDENTIFIER+1];	/* Statement name */
    DBCON     *db;			/* Pointer to connection structure */
    SQLWA     sqlwa;			/* SQL Work Area */
} STMT;


/* Basic REXXSQL environment structure - allocated when 1st connection made! */
typedef struct {
    int       num_connections;		/* Number of active connections */
    DBCON     *current_connection;	/* Pointer to current connection */
    BUCKET    *db_tbl[TBL_CONNECTIONS];	/* Connection hash table */
    BUCKET    *stmt_tbl[TBL_STATEMENTS];/* Statement hash table */
} DBENV;


/*
 * Pointer to REXXSQL environment - initially unallocated!
 * Only one object of this type is required and this object is created
 * the first time a connection is made. This object is released whenever
 * the last connection is released or upon exit.
 */
static DBENV *DbEnv = (DBENV*)NULL;



/*
 * Structure to define a REXX/SQL variable descriptor entry. Note that this
 * describes the variable but does not define storage for it!
 */
typedef struct _SQLVAL {
    char  name[MAX_IDENTIFIER+1];
    char  user_update;
    char  dtype;
    int   maxlen;
    void  *value;
} SQLVAL;

#define TBL_OPTIONS	17

static BUCKET *opt_tbl[TBL_OPTIONS] = {0};



/*
 * These global variables hold the result of the last function call.
 */
static long     SQLCA_SqlCode      = -1L;	/* Force a clear on startup */
static ULONG    SQLCA_RowCount     = 1L;	/* Force a clear on startup */
static long     SQLCA_IntCode      = -1L;	/* Force a clear on startup */


/*-----------------------------------------------------------------------------
 * Copy a non terminated character array to the nominated buffer (truncate
 * if necessary) and null terminate.
 *----------------------------------------------------------------------------*/
static char *MkAsciz

#if __STDC__
    (char *buf, size_t bufsize, char *str, size_t len)
#else
    (buf, bufsize, str, len)
    char    *buf;
    size_t  bufsize;
    char    *str;
    size_t  len;
#endif

{
 bufsize--;	/* Make room for terminating byte */
 if (len > bufsize)
    len = bufsize;
 (void)memcpy(buf, str, len);
 buf[len] = '\0';
 return buf;
}
/*-----------------------------------------------------------------------------
 * Parse the supplied statement and return 1 if the first word of the
 * statement is "select" (any case) or 0 otherwise.
 *----------------------------------------------------------------------------*/
static int SelectStatement

#if __STDC__
    (char *stmt,long len)
#else
    (stmt,len)
    char    *stmt;
    long    len;
#endif

{
 char buf[7];
 char *p=stmt;
 int i=0,j=0;


 /* Remove leading whitespace */
 while (len && isspace(*p)) 
   {
    p++;
    len--;
   }
 if (len<6L)
    return(0);
 buf[6] = '\0';

 for(i=0;i<6;i++)
   {
    buf[i] = (islower(*p)) ? toupper(*p) : *p;
    p++;
   }
 if (strcmp(buf,"SELECT") == 0)
    return(1);
 return(0);
}


/*-----------------------------------------------------------------------------
 * Create a REXX variable of the specified name and bind the value to it.
 *----------------------------------------------------------------------------*/
static int SetRexxVariable

#if __STDC__
    (char *name, size_t namelen, char *value, size_t valuelen)
#else
    (name, namelen, value, valuelen)
    char    *name;
    size_t  namelen;
    char    *value;
    size_t  valuelen;
#endif

{
 ULONG	rc=0L;
 SHVBLOCK	shv;

 if (run_flags & MODE_DEBUG) 
   {
    char buf1[50], buf2[50];

    (void)fprintf(stderr, "*DEBUG* Setting variable \"%s\" to \"%s\".\n",
                      MkAsciz(buf1, sizeof(buf1), name, namelen),
                      MkAsciz(buf2, sizeof(buf2), value, valuelen));
   }
 shv.shvnext = (SHVBLOCK*)NULL;
#if defined(USE_REGINA)
 shv.shvcode = RXSHV_SYSET;
#else
 shv.shvcode = RXSHV_SET;
#endif
 MAKERXSTRING(shv.shvname, name, (ULONG)namelen);
 MAKERXSTRING(shv.shvvalue, value, (ULONG)valuelen);
 shv.shvnamelen = shv.shvname.strlength;
 shv.shvvaluelen = shv.shvvalue.strlength;
 rc = RexxVariablePool(&shv);
 if (rc == RXSHV_OK
 ||  rc == RXSHV_NEWV)
    return(0);
 else
    return(-16);
}


/*-----------------------------------------------------------------------------
 * Store the error message for INTERNAL errors in SQLCA.SQLTEXT variable.
 *----------------------------------------------------------------------------*/
static int SetIntError

#ifdef __STDC__
    (int errcode, char *errmsg)
#else
    (errcode,errmsg)
    int   errcode;
    char *errmsg;
#endif

{
 char  msg[MAX_ERROR_TEXT];

 SQLCA_IntCode = -errcode;

 /* Set SQLCA.INTERRM variable */
 (void)sprintf(msg, "REXX/SQL-%-02d: %s", errcode, errmsg);
 (void)SetRexxVariable(SQLCA_INTERRM, strlen(SQLCA_INTERRM),
                          msg, strlen(msg));

 /* Set SQLCA.INTCODE variable */
 (void)sprintf(msg, "%d", SQLCA_IntCode);
 (void)SetRexxVariable(SQLCA_INTCODE, strlen(SQLCA_INTCODE),
                          msg, strlen(msg));

 return(SQLCA_IntCode);
}



/*-----------------------------------------------------------------------------
 * Set elements of the compound variable "SQLCA.".  SQLCA. holds the results of
 * any call to REXXSQL. It should never be set by the REXX program!
 *----------------------------------------------------------------------------*/
static void SetSQLCA

#if __STDC__
    (long sqlcode, char *errm, char *txt)
#else
    (sqlcode, errm, txt)
    long    sqlcode;
    char    *errm;
    char    *txt;
#endif

{
 char    buf[50];

 SQLCA_SqlCode = sqlcode;

 (void)sprintf(buf, "%ld", sqlcode);
 (void)SetRexxVariable(SQLCA_SQLCODE, strlen(SQLCA_SQLCODE),
                          buf, strlen(buf));
 (void)SetRexxVariable(SQLCA_SQLERRM, strlen(SQLCA_SQLERRM),
                          errm, strlen(errm));
 (void)SetRexxVariable(SQLCA_SQLTEXT, strlen(SQLCA_SQLTEXT),
                          txt, strlen(txt));

 if (sqlcode != 0)
   {
    (void)SetRexxVariable(SQLCA_INTCODE, strlen(SQLCA_INTCODE),"-1", 2);
    (void)sprintf(buf, "REXX/SQL-1: Database Error");
    (void)SetRexxVariable(SQLCA_INTERRM, strlen(SQLCA_INTERRM),
                          buf, strlen(buf));
   }
 return;
}


/*-----------------------------------------------------------------------------
 * Set RowCount and put into REXX "SQLCA.ROWCOUNT" compound variable.
 *----------------------------------------------------------------------------*/
static void SetRowCount

#if __STDC__
    (ULONG rowcount)
#else
    (rowcount)
    ULONG rowcount;
#endif

{
 char    buf[50];

 if (SQLCA_RowCount != rowcount) 
   {
    SQLCA_RowCount = rowcount;
    (void)sprintf(buf, "%lu", rowcount);
    (void)SetRexxVariable(SQLCA_ROWCOUNT,  strlen(SQLCA_ROWCOUNT),
                              buf, strlen(buf));
   }
 return;
}


/*-----------------------------------------------------------------------------
 * Clear the error code, error message etc.
 *----------------------------------------------------------------------------*/
static void ClearOraError
#ifdef __STDC__
    (void)
#else
    ()
#endif

{
 SetRowCount(0L);
 SetSQLCA(0L, "", "");
 return;
}


/*-----------------------------------------------------------------------------
 * Clear the internal error code, error message etc.
 *----------------------------------------------------------------------------*/
static void ClearIntError
#ifdef __STDC__
    (void)
#else
    ()
#endif

{
 SQLCA_IntCode = 0L;

 /* Set SQLCA.INTERRM variable */
 (void)SetRexxVariable(SQLCA_INTERRM, strlen(SQLCA_INTERRM),"", 0);

 /* Set SQLCA.INTCODE variable */
 (void)SetRexxVariable(SQLCA_INTCODE, strlen(SQLCA_INTCODE),"0", 1);

 return;
}


/*-----------------------------------------------------------------------------
 * Fetch the Oracle error and put into REXX "SQLCA." compound variable.
 *----------------------------------------------------------------------------*/
static void SetOraError

#if __STDC__
    (CURSOR *lda, SQLWA *swa)
#else
    (lda, swa)
    CURSOR    *lda;
    SQLWA     *swa;
#endif

{
 CURSOR  *cursor=NULL;
 long    sqlcode=0L;
 char    *txt=NULL;
 char    msg[MAX_ERROR_TEXT];

 cursor = swa ? CTX(swa) : lda;

 /* Get the Oracle error code */
 sqlcode = V4ERRORCODE(cursor);

 /* Get the Oracle error message */
 (void)oerhms(lda, V2ERRORCODE(cursor), msg, sizeof(msg));
    
 /* Remove trailing newline character */
 msg[strlen(msg)-1] = '\0';

 /* Get the statement text */
 txt = (swa == (SQLWA*)NULL) ? "" : (swa->sql_stmt) ? swa->sql_stmt : "";

 /* Set SQLCA. variable */
 SetSQLCA(sqlcode, msg, txt);

 return;
}


/*-----------------------------------------------------------------------------
 * Allocate a DBENV object. Only one database environment is allocated.
 * This structure is allocated when the first connection is made and deallocated
 * when the last connection is released.
 * Note that statement names are global and hence are defined in this structure
 * and not in the connection structure as would be the case if they were unique
 * to a connection!
 *----------------------------------------------------------------------------*/
static DBENV *AllocDbEnvironment

#if __STDC__
    (void)
#else
    ()
#endif

{
    DBENV  *dbenv=NULL;
    int    i=0;

    if ((dbenv = (DBENV*)malloc(sizeof(DBENV))) == (DBENV*)NULL)
        return (DBENV*)NULL;
    dbenv->num_connections = 0;
    dbenv->current_connection = (DBCON*)NULL;
    for (i = 0; i < TBL_CONNECTIONS; i++)
        dbenv->db_tbl[i] = (BUCKET*)NULL;
    for (i = 0; i < TBL_STATEMENTS; i++)
        dbenv->stmt_tbl[i] = (BUCKET*)NULL;
    return dbenv;
}



/*-----------------------------------------------------------------------------
 * Allocate a DBCON object. One of these is required for each database
 * connection. This structure is allocated when the connection is made and
 * deallocated when the connection is released.
 *----------------------------------------------------------------------------*/
static DBCON *AllocConnection

#if __STDC__
    (char *name)
#else
    (name)
    char *name;
#endif

{
    DBCON  *db=NULL;

    if ((db = (DBCON*)NewObject(sizeof(DBCON))) == (DBCON*)NULL)
        return (DBCON*)NULL;
    (void)strncpy(db->name, name, MAX_IDENTIFIER);
    db->dflt_stmt = (void*)NULL;
    db->num_statements = 0;
    return db;
}



/*-----------------------------------------------------------------------------
 * Open a database connection. This requires allocating a connection object
 * and making the connection to Oracle.
 *----------------------------------------------------------------------------*/
static int OpenConnection

#if __STDC__
    (PSZ name, PSZ uid, size_t uidlen, DBCON **new_db)
#else
    (name, uid, uidlen, new_db)
    PSZ     name;
    PSZ     uid;
    size_t  uidlen;
    DBCON   **new_db;
#endif

{
    DBCON   *db=NULL;
    CURSOR  *lda=NULL;
    int     rc=0;

    if ((db = AllocConnection(name)) == (DBCON*)NULL)
        return(SetIntError(10, "out of memory"));

    lda = &(db->lda);

/*    rc = orlon(lda, HDA(db), uid, uidlen, (char*)-1, -1, 0);*/
    rc = orlon(lda, HDA(db), uid, uidlen, (char*)0, -1, 0);
    if (rc) {
        SetOraError(lda, (SQLWA*)NULL);
        FreeObject(db);
        return ORACLE_ERROR;
    }

    *new_db = db;
    return 0;
}


/*-----------------------------------------------------------------------------
 * Allocate a STMT object. One of these is required for each statement
 * including the default statement for a connection. An instance of this object
 * is allocated when (i) a statement is prepared & (ii) the first time
 * SQLCOMMAND() is called for a connection (ie. the default statement is used).
 *----------------------------------------------------------------------------*/
static STMT *AllocStatement

#if __STDC__
    (char *name, DBCON *db)
#else
    (name, db)
    char  *name;
    DBCON *db;
#endif

{
    STMT    *stmt=NULL;
    SQLWA   *swa=NULL;
    int	    i=0;


    if ((stmt = (STMT*)NewObject(sizeof(STMT))) == (STMT*)NULL)
        return (STMT*)NULL;
    stmt->db = db;
    (void)strncpy(stmt->name, name, MAX_IDENTIFIER);

    /* Initialise SQL Work Area */
    swa = SWA(stmt);
    swa->bind_cnt = 0;
    swa->expr_cnt = 0;
    swa->sql_stmt = (char*)NULL;
    swa->sql_stmt_sz = 0;

    /* Set pointer for each column descriptor to NULL (unused) */
    for (i = 0; i < MAX_COLS; i++)
    	swa->fa[i] = (FLDDSCR*)NULL;

    return stmt;
}




/*-----------------------------------------------------------------------------
 * Open a statement. This allocates a statement & then opens an Oracle cursor
 * (also called a context area).
 *----------------------------------------------------------------------------*/
static int OpenStatement

#if __STDC__
    (char *name, DBCON *db, STMT **new_stmt)
#else
    (name, db, new_stmt)
    char  *name;
    DBCON *db;
    STMT  **new_stmt;
#endif

{
    int	    rc=0;
    STMT    *stmt=NULL;
    SQLWA   *swa=NULL;

    
    if ((stmt = AllocStatement(name, db)) == (STMT*)NULL)
        return(SetIntError(10, "out of memory"));

    /* Open the Oracle cursor */
    swa = SWA(stmt);
    if (rc = oopen(CTX(swa), LDA(stmt), (char*)-1, -1, -1, (char*)-1, -1)) {
        SetOraError(LDA(stmt), (SQLWA*)NULL);
        FreeObject(stmt);
    }

    *new_stmt = stmt;
    return (rc==0) ? 0 : ORACLE_ERROR;
}




/*-----------------------------------------------------------------------------
 * Disposes a SQL statement. This closes the Oracle cursor and frees the
 * statement structure and all resources associated with it.
 *----------------------------------------------------------------------------*/
static int ReleaseStatement

#if __STDC__
    (STMT *stmt)
#else
    (stmt)
    STMT *stmt;
#endif

{
    SQLWA    *swa = SWA(stmt);
    FLDDSCR  *fd=NULL;
    int	     rc=0, i=0;


    /* Close Oracle cursor */
    if (rc = oclose(CTX(swa)))
        SetOraError(LDA(stmt), swa);

    /* Free up select column descriptors */
    for (i = 0; i < MAX_COLS; i++) {
    	if (fd = swa->fa[i]) {
	    if (fd->rbuf)
		free(fd->rbuf);
	    free(fd);
    	}
    }
    
    /* Free sql statement buffer (if any) */
    if (swa->sql_stmt)
        free(swa->sql_stmt);

    FreeObject(stmt);

    return (rc==0) ? 0 : ORACLE_ERROR;
}


/*-----------------------------------------------------------------------------
 * Release an Oracle connection. This closes any open statements associated
 * with the connection, closes the connection and frees all resources
 * associated with it.
 *----------------------------------------------------------------------------*/
static int ReleaseConnection

#if __STDC__
    (DBCON *db)
#else
    (db)
    DBCON *db;
#endif

{
    int    i=0, rc=0, last_error=0;
    STMT   *stmt=NULL, *t=NULL;
    CURSOR *lda = &(db->lda);

    /* Remove the Connection structure from the hash structures etc. */
    (void)RemoveObject(db);

    /* Decrement the count of active connections. */
    DbEnv->num_connections--;

    /* Dispose all active statements for this connection. */
    for (i = 0; db->num_statements && i < TBL_STATEMENTS; i++) {
        stmt = (STMT*)FirstObject(i, DbEnv->stmt_tbl);
        while (stmt && db->num_statements) {
            t = (STMT*)NextObject(stmt);
            if (stmt->db == db) {
                RemoveObject(stmt);
                last_error = (rc = ReleaseStatement(stmt)) ? rc : last_error;
                db->num_statements--;
            }
            stmt = t;
        }
    }

    /* Dispose the default statement (if any). */
    if (db->dflt_stmt)
        last_error = (rc = ReleaseStatement((STMT*)(db->dflt_stmt)))
                         ? rc : last_error;

    /* Disconnect from Oracle */
    if (rc = ologof(lda)) {
        SetOraError(lda, (SQLWA*)NULL);
        last_error = rc;
    }

    /* Free the connection structure */
    FreeObject(db);

    return (last_error);
}



/*-----------------------------------------------------------------------------
 * Release the Oracle environment. This releases all active connections
 * (if any).
 *----------------------------------------------------------------------------*/
int ReleaseDbEnvironment

#ifdef __STDC__
    (void)
#else
    ()
#endif

{
    int    i=0, rc=0, last_error=0;
    DBCON  *db=NULL, *t=NULL;

    /* Ensure there is an environment to release! */
    if (DbEnv == (DBENV*)NULL)
        return 0;

    /* Release all connections. */
    for (i = 0; DbEnv->num_connections && i < TBL_CONNECTIONS; i++) {
        db = (DBCON*)FirstObject(i, DbEnv->db_tbl);
        while (db && DbEnv->num_connections) {
            t = (DBCON*)NextObject(db);
            last_error = (rc = ReleaseConnection(db)) ? rc : last_error;
            db = t;
        }
    }

    /* Free the DB environment */
    free(DbEnv);
    DbEnv = (DBENV*)NULL;

    return (last_error);
}



/*-----------------------------------------------------------------------------
 * Save SQL statement in cursor statement buffer.  Dynamically extends the
 * statement buffer when required.
 *----------------------------------------------------------------------------*/
static int SaveSqlStatement

#if __STDC__
    (SQLWA *swa, char *statement, int length)
#else
    (swa, statement, length)
    SQLWA   *swa;
    char    *statement;
    int     length;
#endif

{
 int len=length+1;


 if (len > swa->sql_stmt_sz) 
   {
    /* New statement size is > than previous */
    if (swa->sql_stmt != (char*)NULL) 
      {
       /* Free old statement */
       free(swa->sql_stmt);
       swa->sql_stmt = (char*)NULL;
       swa->sql_stmt_sz = 0;
      }

    /* Allocate a buffer for the new statement */
    if ((swa->sql_stmt = (char*)malloc(len)) == (char*)NULL)
       return(SetIntError(10, "out of memory"));
    swa->sql_stmt_sz = len;
   }

 /* Save the statement */
 (void)memcpy(swa->sql_stmt, statement, length);
 swa->sql_stmt[length] = '\0';
 return 0;
}




/*-----------------------------------------------------------------------------
 * Converts a RXSTRING to integer. Return 0 if OK and -1 if error.
 * Assumes a string of decimal digits and does not check for overflow!
 *----------------------------------------------------------------------------*/
static int StrToInt

#if __STDC__
    (RXSTRING *ptr, ULONG *result) 
#else
    (ptr, result) 
    RXSTRING *ptr;
    ULONG    *result; 
#endif

{
    int    i=0;
    char   *p=NULL;
    ULONG  sum=0L;

    p = ptr->strptr;
    for (i = ptr->strlength; i; i--)
        if (isdigit(*p))
            sum = sum * 10 + (*p++ - '0');
        else
            return -1;

    *result = sum;
    return 0;
}



/*-----------------------------------------------------------------------------
 * This is called when in VERBOSE mode. It prints function name & arg values.
 *----------------------------------------------------------------------------*/
static void FunctionPrologue

#ifdef __STDC__
    (PSZ name, ULONG argc, RXSTRING argv[])
#else
    (name, argc, argv)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
#endif

{
 ULONG	i=0L;
 char	buf[61];


 if (run_flags & MODE_VERBOSE) 
   {
    (void)fprintf(stderr, "++ Call %s%s\n", name, argc ? "" : "()");
    for (i = 0; i < argc; i++) 
      {
       (void)fprintf(stderr, "++ %3ld: \"%s\"\n", i+1,
                          MkAsciz(buf, sizeof(buf), RXSTRPTR(argv[i]),
                                  (size_t)RXSTRLEN(argv[i])));
      }
    if (argc) (void)fprintf(stderr, "++\n");
   }

 /* Set SQLCA.FUNCTION variable */
 if (strcmp(name,FName) != 0)
   {
    (void)SetRexxVariable(SQLCA_FUNCTION, strlen(SQLCA_FUNCTION),
                          name, strlen(name));
    strcpy(FName,name);
   }
}



/*-----------------------------------------------------------------------------
 * Copy a string "s" to the RXSTRING structure pointed to by "target".
 * The string is not null terminated (unless the null is included as the
 * last byte of the string and is counted in "len".
 * Note: Currently the string is always malloc()'d even when less then 255!
 *----------------------------------------------------------------------------*/
static ULONG PutString

#ifdef __STDC__
    (RXSTRING *target, char *s, size_t len)
#else
    (target, s, len)
    RXSTRING	*target;
    char	*s;
    size_t      len;
#endif

{
    char        *t=NULL;

    if ((t = (char*)malloc(len+1)) == (char*)NULL)
        return 1;
    target->strptr = (char*)memcpy(t, s, len);
    target->strlength = len;
    return 0;
}



/*-----------------------------------------------------------------------------
 * Return an integer number as the return value of the function. Also
 * handles verbose mode!
 *----------------------------------------------------------------------------*/
static ULONG ReturnInt

#ifdef __STDC__
    (RXSTRING *retptr, long retval)
#else
    (retptr, retval)
    RXSTRING	*retptr;
    long	retval;
#endif

{
    char        buf[32];

    (void)sprintf(buf, "%ld", retval);

    if (run_flags & MODE_VERBOSE)
        (void)fprintf(stderr, "++ Exit %s with value \"%ld\"\n", FName, retval);
    
    return PutString(retptr, buf, strlen(buf));
}



/*-----------------------------------------------------------------------------
 * Return a string as the return value of the function. Also
 * handles verbose mode!
 *----------------------------------------------------------------------------*/
static ULONG ReturnString

#ifdef __STDC__
    (RXSTRING *retptr, char *val, size_t len)
#else
    (retptr, val, len)
    RXSTRING	*retptr;
    char	*val;
    size_t      len;
#endif

{
    if (run_flags & MODE_VERBOSE) {

        char  buf[50];

        (void)fprintf(stderr, "++ Exit %s with value \"%s\"\n",
                      FName, MkAsciz(buf, sizeof(buf), val, len));
    }

    return PutString(retptr, val, len);
}



/*-----------------------------------------------------------------------------
 * Return an error to REXX interpreter.
 *----------------------------------------------------------------------------*/
static ULONG ReturnError

#ifdef __STDC__
    (RXSTRING *retptr, int errcode, char *errmsg)
#else
    (retptr, errcode, errmsg)
    RXSTRING	*retptr;
    int         errcode;
    char	*errmsg;
#endif

{
    SetIntError(errcode, errmsg);
    return ReturnInt(retptr, -errcode);
}




/*-----------------------------------------------------------------------------
 * Makes an identifier (for a Connection, Stem or Statement) from a given
 * string. Leading and trailing whitespace is removed and the string is
 * capitalised. The variable must be the following regular expression:
 *   [A-Za-z!?][A-Za-z0-9!?_]*
 * That is the variable :-
 *   (i) The variable name must start with an alpha character or '!' or '?'.
 *  (ii) The rest of the variable name must be one of the above characters or
 *       a decimal digit or underscore.
 *----------------------------------------------------------------------------*/
static int MkIdentifier

#ifdef __STDC__
    (RXSTRING var, PSZ buf, size_t buflen)
#else
    (var, buf, buflen)
    RXSTRING  var;
    PSZ       buf;
    size_t    buflen;
#endif

{
    char      *p = RXSTRPTR(var);
    size_t    len = RXSTRLEN(var);
    size_t    cnt = 0;

    if (len == 0)
        return(SetIntError(51, "zero length identifier"));

    /* Make room for the terminating byte. */
    buflen--;

    /* Remove leading whitespace */
    while (len && isspace(*p)) {
        p++;
        len--;
    }

    /* Special check for 1st character */
    if (len && (isalpha(*p) || *p == '!' || *p == '?')) {
        *buf++ = (islower(*p)) ? toupper(*p) : *p;
        p++;
        len--;
    }

    /* Copy identifier to destination */
    while (len && (isalnum(*p) || *p == '_' || *p == '!' || *p == '?')) {
        *buf = (islower(*p)) ? toupper(*p) : *p;
        p++;
        len--;
        if (++cnt <= buflen) buf++;
    }

    /* Remove trailing whitespace */
    while (len && isspace(*p)) {
        p++;
        len--;
    }

    /* Check for garbage */
    if (len)
        return(SetIntError(52, "garbage in identifier name"));

    *buf = '\0';
    return 0;
}



/*-----------------------------------------------------------------------------
 * Install a REXX/SQL variable structure.
 *----------------------------------------------------------------------------*/
static int InstallSQLVariable

#ifdef __STDC__
    (char *name, int upd, int dtype, int max, void *val)
#else
    (name, upd, dtype, max, val)
    char  *name;
    int   upd;
    int   dtype;
    int   max;
    void  *val;
#endif

{
    SQLVAL  *opt=NULL;

    if ((opt = NewObject(sizeof(SQLVAL))) == (SQLVAL*)NULL)
        return(SetIntError(10, "out of memory"));
    (void)strcpy(opt->name, name);
    opt->user_update = (char)upd;
    opt->dtype = (char)dtype;
    opt->maxlen = max;
    opt->value = val;
    (void)InsertObject(opt, opt_tbl, TBL_OPTIONS);
    return 0;
}



/*-----------------------------------------------------------------------------
 * Install all REXX/SQL variable structures.
 *----------------------------------------------------------------------------*/
int InstallSQLVariables

#ifdef __STDC__
    (void)
#else
    ()
#endif

{
 int rc=0;

    sprintf(RexxSqlVersionString,"%s %s %s %s ORACLE",
                                 DLLNAME,
                                 REXXSQL_VERSION,
                                 REXXSQL_DATE,
                                 CURRENT_OS);
    MAKERXSTRING(RexxSqlVersion, RexxSqlVersionString,(ULONG)strlen(RexxSqlVersionString));
    if (rc = InstallSQLVariable("ROWLIMIT", TRUE, TYPE_INT, 0, &RowLimit))
       return(rc);
    if (rc = InstallSQLVariable("SAVESQL", TRUE, TYPE_INT, 0, &SaveSQL))
       return(rc);
    if (rc = InstallSQLVariable("DEBUG", TRUE, TYPE_INT, 0, &run_flags))
       return(rc);
    if (rc = InstallSQLVariable("VERSION", FALSE, TYPE_STRING, 0, &RexxSqlVersion))
       return(rc);
    return(0);
}



/*-----------------------------------------------------------------------------
 * Fetch or set a REXX/SQL variable.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraVariable
#else
ULONG SqlVariable
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    char        opt_name[MAX_IDENTIFIER+1];
    SQLVAL      *opt=NULL;
    char        tmp[128];
    int         rc=0;

    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc == 0 || argc > 2) return 1;

    if (RXSTRLEN(argv[0]) == 0)
        return ReturnError(retstr, 19, "null (\"\") variable name.");

    /* Get the name of the variable */
    if (rc = MkIdentifier(argv[0], opt_name, sizeof(opt_name)))
        return ReturnInt(retstr, rc);

    /* Make sure the option is a valid one! */
    if ((opt = FindObject(opt_name, opt_tbl, TBL_OPTIONS)) == (SQLVAL*)NULL) {
        (void)sprintf(tmp,"unknown variable \"%s\".", opt_name);
        return ReturnError(retstr, 11, tmp);
    }

    if (argc == 1) {
        if (opt->dtype == TYPE_INT)
            return ReturnInt(retstr, *(ULONG*)(opt->value));
        else
            return ReturnString(retstr,
                                ((RXSTRING*)(opt->value))->strptr,
                                (size_t)(((RXSTRING*)(opt->value))->strlength));
    }

    /* Must be updateable by user */
    if (!opt->user_update) {
        (void)sprintf(tmp, "variable \"%s\" is not settable.", opt_name);
        return ReturnError(retstr, 12, tmp);
    }

    /* Set the value of the option */
    if (opt->dtype == TYPE_INT) {
        if (StrToInt(&argv[1], (ULONG*)opt->value))
            return ReturnError(retstr, 7,
                               "value is not a valid integer.");
    }
    /* We don't have any use for user settable strings as yet!! */

    return ReturnInt(retstr, 0L);
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLCONNECT( [connection-name, ] connection-string)
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraConnect
#else
ULONG SqlConnect
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    char	*uid=NULL;
    int		uidlen=0;
    char	dbname[MAX_IDENTIFIER+1];
    int		i=0, rc=0;
    char        tmp[128];
    DBCON       *db=NULL;

    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc > 3) return 1;

    /* Allocate a DB environment if none exists! */
    if (DbEnv == (DBENV*)NULL) {
        if ((DbEnv = AllocDbEnvironment()) == (DBENV*)NULL)
            return ReturnError(retstr, 10, "out of memory.");
    }

    /*
     * If a name is given then it is arg#1 and the connect string
     * is arg#2. If no name is given then connect-string is arg#1 unless
     * both name & connect-string are omitted.
     */
    if (argc == 0)
      {
       uid = "/";
       uidlen = 1;
      }
    else
      {
       if (argc == 1)
         {
          uid = RXSTRPTR(argv[0]);
          uidlen = RXSTRLEN(argv[0]);
         }
       else
         {
          uid = RXSTRPTR(argv[1]);
          uidlen = RXSTRLEN(argv[1]);
         }
      }

    /*
     * If a name is given it is the first argument!/
     * Get the name of the connection (default if not specified).
     */
    if (argc > 1 && RXSTRLEN(argv[0])) {
        if (rc = MkIdentifier(argv[0], dbname, sizeof(dbname)))
            return ReturnInt(retstr, rc);
    }
    else {
        (void)strcpy(dbname, DEFAULT_CONNECTION);
    }

    /* Make sure there is no existing connection with the same name */
    if (FindObject(dbname, DbEnv->db_tbl, TBL_CONNECTIONS)) {
        (void)sprintf(tmp, "connection already open with name \"%s\".", dbname);
        return ReturnError(retstr, 20, tmp);
    }

    /* Open a new connection for the given connect string. */
    if (rc = OpenConnection(dbname, uid, uidlen, &db))
        return ReturnInt(retstr, (long)rc);

    DbEnv->num_connections++;
    DbEnv->current_connection = db;
    (void)InsertObject(db, DbEnv->db_tbl, TBL_CONNECTIONS);

    return ReturnInt(retstr, 0L);
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLDISCONNECT( [connection-name ] )
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraDisconnect
#else
ULONG SqlDisconnect
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    int		rc = 0;
    char        dbname[MAX_IDENTIFIER+1];
    DBCON       *db=NULL;
    char        tmp[128];


    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc > 1) return 1;

    if (DbEnv == (DBENV*)NULL)
        return ReturnInt(retstr, 0L);

    if (argc && RXSTRLEN(argv[0])) {

        /* A connection has been named */
        if (rc = MkIdentifier(argv[0], dbname, sizeof(dbname)))
            return ReturnInt(retstr, rc);

        /* Make sure the named connection exists. */
        if ((db = FindObject(dbname, DbEnv->db_tbl, TBL_CONNECTIONS))
                                              == (DBCON*)NULL) {
            (void)sprintf(tmp,"connection \"%s\" is not open.",
                          dbname);
            return ReturnError(retstr, 21, tmp);
        }
    }
    else {
        if (DbEnv->current_connection)
            db = DbEnv->current_connection;
        else
            return ReturnError(retstr, 25, "no connection is current");
    }

    /*
     * If terminating the current connection then make it so there is
     * no current connection!
     */
    if (db == DbEnv->current_connection)
        DbEnv->current_connection = (DBCON*)NULL;

    /* Do the disconnection */
    rc = ReleaseConnection(db);

    /* Free the environment if zero connections remaining */
    if (DbEnv->num_connections == 0) {
        free(DbEnv);
        DbEnv = (DBENV*)NULL;
    }

    return ReturnInt(retstr, (long)rc);
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLDEFAULT( [connection-name ] )
 *
 * RETURNS :  When called with 0 args : 0-success, <0-error.
 *         :  When called with 1 arg  : Name of current connection else "".
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraDefault
#else
ULONG SqlDefault
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    char        dbname[MAX_IDENTIFIER+1];
    DBCON       *db=NULL;
    char        tmp[128];
    int rc=0;

    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc > 1) return 1;

    if (argc && RXSTRLEN(argv[0])) {

        /* Get the normalised name of the connection. */
        if (rc = MkIdentifier(argv[0], dbname, sizeof(dbname)))
            return ReturnInt(retstr, rc);

        /* Make sure we have an environment! */
        if (DbEnv == (DBENV*)NULL)
            return ReturnError(retstr, 22, "no connections open.");

        /* Make sure the Connection Name is a valid one! */
        if ((db = FindObject(dbname, DbEnv->db_tbl, TBL_CONNECTIONS))
                                              == (DBCON*)NULL) {
            (void)sprintf(tmp,"connection \"%s\" is not open.", dbname);
            return ReturnError(retstr, 21, tmp);
        }

        /* Make connection the default one! */
        DbEnv->current_connection = db;

        return ReturnInt(retstr, 0L);
    }
    else if (DbEnv && DbEnv->current_connection) {
        return ReturnString(retstr,
                            DbEnv->current_connection->name,
                            strlen(DbEnv->current_connection->name));
    }
    else {
        return ReturnString(retstr, "", 0);
    }
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS:  Called by SQLCOMMIT( ) &  SQLROLLBACK( )
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraTransact
#else
ULONG SqlTransact 
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr,int commit)
#else
    (name, argc, argv, stck, retstr, commit)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
    int commit;
#endif
{ 
    int		rc = 0;
    char        dbname[MAX_IDENTIFIER+1];
    char        tmp[128];
    DBCON       *db=NULL;
    CURSOR      *lda=NULL;


    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc > 1) return 1;

    if (DbEnv == (DBENV*)NULL)
        return ReturnError(retstr, 22, "no connections open.");

    if (DbEnv->current_connection)
       db = DbEnv->current_connection;
    else
       return ReturnError(retstr, 25, "no connection is current");

    lda = &(db->lda);

/*    if (rc = (strcmp(name, NAME_SQLROLLBACK)) ? ocom(lda) : orol(lda))*/
    if (rc = (commit) ? ocom(lda) : orol(lda))
        SetOraError(lda, (SQLWA*)NULL);

    return ReturnInt(retstr, (rc==0)?0:ORACLE_ERROR);
}


/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLCOMMIT( )
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraCommit
#else
ULONG SqlCommit
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{ 
#if defined(ORA_PREFIX)
 return(OraTransact(name, argc, argv, stck, retstr,1));
#else
 return(SqlTransact(name, argc, argv, stck, retstr,1));
#endif
}

/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLROLLBACK( )
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraRollback
#else
ULONG SqlRollback
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{ 
#if defined(ORA_PREFIX)
 return(OraTransact(name, argc, argv, stck, retstr,0));
#else
 return(SqlTransact(name, argc, argv, stck, retstr,0));
#endif
}


/*-----------------------------------------------------------------------------
 * Binds all arguments (by number) to the parsed (prepared) SQL statement.
 *----------------------------------------------------------------------------*/
static int BindByNumber

#ifdef __STDC__
    (STMT *stmt,ULONG argc,RXSTRING argv[])
#else
    (stmt, argc, argv)
    STMT          *stmt;
    ULONG         argc;
    RXSTRING      argv[];
#endif
{
    int           i=0;
    int	          rc=0, bindlen=0;
    void	  *bindaddr=NULL;
    short	  *indp=NULL;
    char          tmp[128];
    SQLWA	  *swa= SWA(stmt);

    static short  not_null = 0;
    static short  is_null = (-1);

    /*
     * Bind all variables (if any) to placeholders in SQL statement. It is
     * assumed that the variables are static for the life of the SQL statement
     * i.e. their addresses remain fixed.
     */
    for (i = 0; i != argc && i < MAX_BINDVARS; i++) {

        if (RXSTRLEN(argv[i]) == 0) {

	    /* indicate a NULL value */
	    bindaddr = (void*)NULL;
	    bindlen = 0;
	    indp = (short*)&is_null;
	}
	else {
	    bindaddr = (void*)RXSTRPTR(argv[i]);
	    bindlen = (int)RXSTRLEN(argv[i]);
	    indp = (short*)&not_null;
	}

	if (rc = obndrn(CTX(swa), (int)i+1, bindaddr, bindlen, EXT_CHAR,
                                            -1, indp, (char*)-1, -1, -1)) {
            SetOraError(LDA(stmt), swa);
            return ORACLE_ERROR;
        }
    }

    /*
     * If previous bind count is non-zero (i.e. a previous bind for 
     * this statement then check all values are re-bound. 
     */
    if (swa->bind_cnt && i < swa->bind_cnt) {
        (void)sprintf(tmp, "%d bind values passed. %d expected",
                      i, swa->bind_cnt);
        return(SetIntError(61, tmp));
    }

    /* save the new bind count */
    swa->bind_cnt = i;

    return (0);
}




/*-----------------------------------------------------------------------------
 * Binds all arguments (by name) to the parsed (prepared) SQL statement.
 *----------------------------------------------------------------------------*/
static int BindByName
#ifdef __STDC__
    (STMT *stmt,ULONG argc,RXSTRING argv[])
#else
    (stmt, argc, argv)
    STMT          *stmt;
    ULONG         argc;
    RXSTRING	  argv[];
#endif
{
    SQLWA	  *swa= SWA(stmt);
    RXSTRING	  *Varg=NULL, *Narg=NULL;
    int           i=0, cnt=0;
    int	          rc=0, bindlen=0;
    void	  *bindaddr=NULL;
    short	  *indp=NULL;
    static short  not_null = 0;
    static short  is_null = (-1);
    char          tmp[128];

    /*
     * Bind all variables (if any) to placeholders in SQL statement. It is
     * assumed that the variables are static for the life of the SQL statement
     * i.e. their addresses remain fixed.
     */
    if (argc % 2)
        return(SetIntError(62, "bind values must be paired for bind by name"));

    for (i= 0, cnt = 0; i < argc && cnt <= MAX_BINDVARS;) {
        cnt++;
        Narg = &argv[i++];
        Varg = &argv[i++];

        /*
         * Check that each substitution variable name begins with a ':' and
         * is at least 2 charsacters in length.
         */
	if (RXSTRLEN(*Narg) < 2 || *(RXSTRPTR(*Narg)) != ':') {
            (void)sprintf(tmp,
                          "invalid substitution variable name at bind pair %d.",
                          cnt);
            return(SetIntError(63, tmp));
        }

	if (RXSTRLEN(*Varg) == 0) {
	    /* indicate a NULL value */
	    bindaddr = (void*)NULL;
	    bindlen = 0;
	    indp = (short*)&is_null;
	}
	else {
	    bindaddr = (void*)RXSTRPTR(*Varg);
	    bindlen = (int)RXSTRLEN(*Varg);
	    indp = (short*)&not_null;
	}

	if (rc = obndrv(CTX(swa), RXSTRPTR(*Narg), (int)RXSTRLEN(*Narg),
                        bindaddr, bindlen, EXT_CHAR, -1, indp,
                        (char*)-1, -1, -1)) {
            SetOraError(LDA(stmt), swa);
            return ORACLE_ERROR;
        }
    }

    /*
     * If previous bind count is non-zero (i.e. a previous bind for 
     * this statement then check all values are re-bound. 
     */
    if (swa->bind_cnt && cnt < swa->bind_cnt) {
        (void)sprintf(tmp, "%d bind values passed. %d expected",
                      cnt, swa->bind_cnt);
        return(SetIntError(61, tmp));
    }

    /* save the new bind count */
    swa->bind_cnt = cnt;

    return (0);
}




/*-----------------------------------------------------------------------------
 * This function binds all values (supplied as a list of arguments) to
 * the specified cursor. Two types of binding are supported:
 * (i)  By Name - This is the DEFAULT. Each bind value is a pair of consecutive
 *      arguments the first being the name of the substitution variable
 *      (placeholder) complete with a leading colon (":") and the second is
 *	the value to be bound.
 * (ii) By Number - First arg must be the token '#' anything else defaults
 *      By Name. Args are bound to placeholders in the order supplied, one
 *      argument per placeholder.
 *----------------------------------------------------------------------------*/
static int BindValues

#ifdef __STDC__
    (STMT *stmt,ULONG argc,RXSTRING argv[])
#else
    (stmt, argc, argv)
    STMT	  *stmt;
    ULONG         argc;
    RXSTRING	  argv[];
#endif
{
    /* Bind by number if first arg is '#' else bind by name. */
    return (RXSTRLEN(argv[0]) == 1 && *(RXSTRPTR(argv[0])) == '#')
        ? BindByNumber(stmt, --argc, &argv[1])
        : BindByName(stmt, argc, argv);
}



/*-----------------------------------------------------------------------------
 * Get a column expression descriptor.  Assumes the index is valid!
 *----------------------------------------------------------------------------*/
static FLDDSCR *GetFldDscr

#ifdef __STDC__
    (SQLWA *swa,int i)
#else
    (swa, i)
    SQLWA   *swa;
    int	    i;
#endif
{
    FLDDSCR *fd=NULL;
	

    if ((fd = swa->fa[i]) == (FLDDSCR*)NULL) {
    	if ((fd = (swa->fa[i] = (FLDDSCR*)malloc(sizeof(FLDDSCR))))
                       == (FLDDSCR*)NULL) {
            return (FLDDSCR*)NULL;
        }
        fd->rbuf = (char*)NULL;
        fd->rbufl = 0;
    }
    return fd;
}


/*-----------------------------------------------------------------------------
 * Describes columns (expressions) and defines the output buffers for each
 * column for the select statement in nominated cursor.
 * Returns the number of expressions in the select statement.
 *----------------------------------------------------------------------------*/
static int DefineExpressions

#ifdef __STDC__
    (STMT *stmt)
#else
    (stmt)
    STMT     *stmt;
#endif
{
 SQLWA    *swa= SWA(stmt);
 FLDDSCR  *fd=NULL;
 int      i=0;
 sb4      dsize=0, dbsize=0;
 size_t   varlen=0;

 /* Describe & define buffer for each expression in the SELECT statement */
 for (i = 0; i < MAX_COLS ; i++)
   {
    /* Get a new field descriptor */
    if ((fd = GetFldDscr(swa, i)) == (FLDDSCR*)NULL)
       return(SetIntError(10, "out of memory"));

    fd->cbufl = sizeof(fd->cbuf) - 1;

    if (odescr(CTX(swa), i+1, &dbsize, &fd->dbtype, (sb1*)fd->cbuf,
               &fd->cbufl, &dsize, &fd->prec, &fd->scale, &fd->nullok))
       break;

    fd->cbuf[fd->cbufl] = '\0';     /* Terminate the Column Name */

    switch (fd->dbtype) 
      {
       case ORA_DATE:          varlen = ORA_DATE_LEN;  break;
       case ORA_LONGRAW:
       case ORA_LONG:          varlen = ORA_LONG_LEN;  break;
       default:                varlen = dsize;         break;
      }

    /*
     * In an attempt to save malloc() & free() calls we keep the old
     * buffer providing it is not grossly oversized. 
     */
    if ((size_t)fd->rbufl < varlen || (size_t)fd->rbufl > varlen + 256)
      {
       /* Free the old buffer (if any) */
       if (fd->rbufl) 
         {
          free(fd->rbuf);
          fd->rbufl = 0;
         }
       /* Allocate a new buffer */
       if ((fd->rbuf = (char*)malloc(varlen)) == (char*)NULL)
          return(SetIntError(10, "out of memory"));
       fd->rbufl = varlen;
      }

    if (odefin(CTX(swa), i+1, fd->rbuf, fd->rbufl, EXT_CHAR, 0,
               &fd->indp, (char*)NULL, 0, 0, &fd->retl,&fd->rcode)) 
      {
       SetOraError(LDA(stmt), swa);
       return (ORACLE_ERROR);
      }
   }

 /*
  ** Check if too many SELECT expressions.
  ** ORACLE should trap it if MAX_COLS is set correctly!
  */
 if (i >= MAX_COLS) 
     return(SetIntError(71, "Too many columns specified in SELECT"));

 return (swa->expr_cnt = i);
}


/*-----------------------------------------------------------------------------
 * Fetches the next row from the nominated cursor and returns the values
 * of the expressions for the fetched row into the compound variable with
 * name constructed as follows:
 *
 * For single fetches. eg. SQLFETCH('s1')
 *                     or  SQLFETCH('s1','') :
 *  <statement-name>.<column-name>
 *
 * For bulk fetches. eg. SQLCOMMAND(stmt1)
 *                   or  SQLFETCH('s1',0)
 *                   or  SQLFETCH('s1',1)
 *                   or  SQLFETCH('s1',20) :
 *  <statement-name>.<column-name>.<row-number>
 *
 * Note that the row-number always starts at 1!
 *
 * Returns:
 *	success:  0
 *	failure: ORACLE return code (V2 codes).
 *----------------------------------------------------------------------------*/
static int FetchRow

#ifdef __STDC__
    (STMT *stmt,char *stem,ULONG rowcount)
#else
    (stmt, stem, rowcount)
    STMT    *stmt;
    char    *stem;
    ULONG   rowcount;
#endif
{
 FLDDSCR *fd=NULL;
 SQLWA   *swa=NULL;
 int	    rc=0, i=0;
 size_t  varlen=0;
 char    varname[MAX_IDENTIFIER+1+10];

 swa = SWA(stmt);

 rc = ofetch(CTX(swa));
 if (rc == NO_DATA_FOUND)
    return (rc);
 if (rc)
   {
    SetOraError(LDA(stmt), swa);
    return ORACLE_ERROR;
   }

 /* Get each expr value in turn */
 for (i = 0; rc == 0 && i < swa->expr_cnt; i++)
   {
    fd = swa->fa[i];
        
    /* Add each column value to the stem's values */
    (void)sprintf(varname, rowcount ? "%s.%s.%lu" : "%s.%s",
                      stem, fd->cbuf, rowcount);
    varlen = strlen(varname);

    if (fd->indp < 0)      /* returned value is NULL */
      {
       rc = SetRexxVariable(varname, varlen, "", 0);
      }
    else 
      {
       if (fd->rcode)    /* truncation or conversion error */
         {
          return(SetIntError(15, "Conversion/truncation occurred."));
         }
       else 
         {
          rc = SetRexxVariable(varname, varlen, fd->rbuf, (size_t)fd->retl);
         }
      }
   }
 if (rc)
    return(SetIntError(16, "unable to set REXX variable"));
 return rc;
}


static int SetRowCountVar

#ifdef __STDC__
    (SQLWA *swa,char *stem_name,long rowcount)
#else
    (swa, stem_name, rowcount)
    SQLWA *swa;
    char *stem_name;
    long rowcount;
#endif
{
    int     i=0,rc=0;
    char    varname[MAX_IDENTIFIER*2+4], buf[11];

    for (i = 0; i < swa->expr_cnt; i++) {
        if (rc = SetRexxVariable(varname,
                            sprintf(varname, "%s.%s.0", stem_name,
                                    swa->fa[i]->cbuf),
                            buf,
                            sprintf(buf, "%lu", rowcount)))
            return(rc);
    }
    return 0;
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS: SQLCOMMAND(stem-name, sql-statement-text [, <bind-args>])
 *
 * RETURNS :  0-success < 0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraCommand
#else
ULONG SqlCommand
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
 int         rc = 0, i=0;
 ULONG       rowcount=0L;
 int		expr_cnt=0;
 DBCON       *db=NULL;
 STMT        *stmt=NULL;
 SQLWA	*swa=NULL;
 char        stem_name[MAX_IDENTIFIER+1];

 FunctionPrologue(name, argc, argv);

 if (SQLCA_SqlCode) ClearOraError();
 if (SQLCA_IntCode) ClearIntError();

 if (argc == 0) return 1;

 /* Get pointer to current connection */
 if (DbEnv && DbEnv->current_connection)
    db = DbEnv->current_connection;
 else
    return ReturnError(retstr, 25, "no connection is current");

 if (argc == 1 || RXSTRLEN(argv[0]) == 0) /* No stem name specified! */
    (void)strcpy(stem_name, DEFAULT_STEM);
 else 
   {
    if (rc = MkIdentifier(argv[0], stem_name, sizeof(stem_name)))
       return ReturnInt(retstr, rc);
   }

 /* If no default statement then create it! */
 if ((stmt = (STMT*)(db->dflt_stmt)) == (STMT*)NULL) 
   {
    /* Open a statement for the default statement. */
    if (rc = OpenStatement(DEFAULT_STATEMENT, db, &stmt))
       return ReturnInt(retstr, (long)rc);

    db->dflt_stmt = (void*)stmt;
   }

 swa = SWA(stmt);

 /*
  * If only 1 arg then it is the SQL-statement-text. If more than 1 args
  * then arg#1 is stem-name, arg#2 is text and rest are bind values.
  * 'i' is index (base zero) to sql-statement-text arg.
  */
 i = (argc == 1) ? 0 : 1;

 /* set flag indicating if SELECT statement supplied */
 swa->select = SelectStatement(RXSTRPTR(argv[i]),RXSTRLEN(argv[i]));

 /* Save the SQL statement if required */
 if (SaveSQL && SaveSqlStatement(swa, RXSTRPTR(argv[i]),
                                       (int)RXSTRLEN(argv[i])))
    return ReturnError(retstr, 10, "out of memory");

 /* Parse the statement */
#if defined(NO_OPARSE)
 if (rc = osql3(CTX(swa), RXSTRPTR(argv[i]), (int)RXSTRLEN(argv[i]))) 
   {
    SetOraError(LDA(stmt), swa);
    return ReturnInt(retstr, ORACLE_ERROR);
   }
#else
 if (rc = oparse(CTX(swa), RXSTRPTR(argv[i]), (int)RXSTRLEN(argv[i]), 0, 1L)) 
   {
    SetOraError(LDA(stmt), swa);
    return ReturnInt(retstr, ORACLE_ERROR);
   }
#endif

 /* Bind variables in WHERE/INSERT/UPDATE clause (if any). */
 if (argc > 2) 
   {
    if (rc = BindValues(stmt, argc-2, &argv[2])) 
      {
       return ReturnInt(retstr, (long)rc);
      }
   }

 /* Describe the expression list & define output buffers (if any). */
 if ((expr_cnt = DefineExpressions(stmt)) < 0)
    return ReturnInt(retstr, (long)expr_cnt);

 /* Execute the SQL statement */
 if (rc = oexec(CTX(swa))) 
   {
    SetOraError(LDA(stmt), swa);
    return ReturnInt(retstr, ORACLE_ERROR);
   }

 /* Test if select statement. If not then done else fetch rows. */
 if (expr_cnt == 0) 
   { 
    /* Inform ORACLE that operation is complete */
    if (rc = ocan(CTX(swa)))   /* this should never fail */
      {
       SetOraError(LDA(stmt), swa);
       return ReturnInt(retstr, ORACLE_ERROR);
      }
    rowcount = SQLROWCNT(CTX(swa));
   }
 else /* Then must be a SELECT statement */
   {
    /* Fetch each row in turn */
    for (rowcount = 1; RowLimit == 0 || rowcount <= RowLimit; rowcount++)
      {
       if (rc = FetchRow(stmt, stem_name, rowcount))
          break;
      }
    rowcount--;

    if (rc && rc != NO_DATA_FOUND) 
      {
       return ReturnInt(retstr, (long)rc);
      }

    if (rc = SetRowCountVar(swa, stem_name, rowcount))
       return ReturnInt(retstr, (long)rc);

    /* Inform ORACLE that operation is complete */
    if (rc = ocan(CTX(swa))) /* this should never fail */
      {
       SetOraError(LDA(stmt), swa);
       return ReturnInt(retstr, ORACLE_ERROR);
      }
   }
 SetRowCount(rowcount);
 return ReturnInt(retstr, 0L);
}


/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLPREPARE(statement-name, sql-statement-text)
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraPrepare
#else
ULONG SqlPrepare
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    int         rc=0;
    DBCON       *db=NULL;
    STMT        *stmt=NULL;
    SQLWA	*swa=NULL;
    char        stmt_name[MAX_IDENTIFIER+1];

    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc != 2) return 1;

    /* Get pointer to current connection */
    if (DbEnv && DbEnv->current_connection)
        db = DbEnv->current_connection;
    else
        return ReturnError(retstr, 25, "no connection is current");

    if (RXSTRLEN(argv[0]) == 0)		/* No statement name specified! */
        return ReturnError(retstr, 18, "statement name omitted or null");
    else if (rc = MkIdentifier(argv[0], stmt_name, sizeof(stmt_name)))
        return ReturnInt(retstr, rc);

    /*
     * Find the named statement or create if necessary. We have to be a
     * bit careful here because the statement may exist but point to a
     * different database connection!
     */
    stmt = FindObject(stmt_name, DbEnv->stmt_tbl, TBL_STATEMENTS);

    if (stmt == (STMT*)NULL || stmt->db != db) {

        if (stmt) {

            /*
             * Statement is not for the same db, therefore we must dispose
             * & re-alloc it!
             */
            RemoveObject(stmt);
            ((DBCON*)stmt->db)->num_statements--;
            if (rc = ReleaseStatement(stmt))
                return ReturnInt(retstr, (long)rc);
        }

        /* Open a statement for this statement. */
        if (rc = OpenStatement(stmt_name, db, &stmt))
            return ReturnInt(retstr, (long)rc);

        /* Insert this statement into the connection hash table. */
        (void)InsertObject(stmt, DbEnv->stmt_tbl, TBL_STATEMENTS);

        db->num_statements++;
    }

    swa = SWA(stmt);
    /* set flag indicating if SELECT statement supplied */
    swa->select = SelectStatement(RXSTRPTR(argv[1]),RXSTRLEN(argv[1]));

    /* Save the SQL statement if required */
    if (SaveSQL && SaveSqlStatement(swa, RXSTRPTR(argv[1]),
                                       (int)RXSTRLEN(argv[1])))
        return ReturnError(retstr, 10, "out of memory");

    swa->bind_cnt = 0;
    swa->expr_cnt = 0;

    /* Parse the statement */
#if defined(NO_OPARSE)
    if (rc = osql3(CTX(swa), RXSTRPTR(argv[1]), (int)RXSTRLEN(argv[1]))) {
        SetOraError(LDA(stmt), swa);
    }
#else
    if (rc = oparse(CTX(swa), RXSTRPTR(argv[1]), (int)RXSTRLEN(argv[1]),0,1L)) {
        SetOraError(LDA(stmt), swa);
    }
#endif

    return ReturnInt(retstr, rc ? ORACLE_ERROR : 0);
}




/*-----------------------------------------------------------------------------
 * Get a pointer to the nominated statement. Returns NULL on error.
 *----------------------------------------------------------------------------*/
static STMT *GetStatement

#ifdef __STDC__
    (RXSTRING	var,PSZ		buf)
#else
    (var, buf)
    RXSTRING	var; 
    PSZ		buf;
#endif
{
    STMT        *stmt=NULL;
    char        tmp[128];

    if (DbEnv == (DBENV*)NULL) {
        SetIntError(22, "no connections open.");
        return (STMT*)NULL;
    }

    if (RXSTRLEN(var) == 0)	{	/* No statement name specified! */
        SetIntError(23, "statement name omitted or null");
        return (STMT*)NULL;
    }

    /* Get the normalised form of the name */
    if (MkIdentifier(var, buf, MAX_IDENTIFIER+1))
        return (STMT*)NULL;

    /* Find the named statement or create if necessary */
    if ((stmt = FindObject(buf, DbEnv->stmt_tbl, TBL_STATEMENTS))
                                          == (STMT*)NULL) {

        /* Statement not an existing one! */
        (void)sprintf(tmp,"statement \"%s\" does not exist", buf);
        SetIntError(24, tmp);
        return (STMT*)NULL;
    }
    return stmt;
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLDISPOSE(statement-name)
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraDispose
#else
ULONG SqlDispose
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    int         rc=0;
    STMT        *stmt=NULL;
    DBCON       *db=NULL;
    char        stmt_name[MAX_IDENTIFIER+1];

    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc != 1) return 1;

    if ((stmt = GetStatement(argv[0], stmt_name)) == (STMT*)NULL)
        return ReturnInt(retstr, SQLCA_IntCode);
    
    /* Get pointer to statement's connection structure */
    db = stmt->db;

    /* Dispose the statement */
    RemoveObject(stmt);
    rc = ReleaseStatement(stmt);

    db->num_statements--;

    return ReturnInt(retstr, (long)rc);
}

/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLEXEC (called by SQLEXECUTE() and SQLOPEN()
 *
 * RETURNS :  0-success,
 *           >0-number of rows affected for SQLEXECUTE(),
 *           <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraExec
#else
ULONG SqlExec
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr,int open)
#else
    (name, argc, argv, stck, retstr, open)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
    int open;
#endif
{
 int         rc=0;
 int		expr_cnt=0;
 ULONG	rowcount=0L;
 STMT        *stmt=NULL;
 SQLWA	*swa=NULL;
 char        stmt_name[MAX_IDENTIFIER+1];
 char        tmp[128];

 FunctionPrologue(name, argc, argv);

 if (SQLCA_SqlCode) ClearOraError();
 if (SQLCA_IntCode) ClearIntError();

 if (argc == 0) return 1;

 if ((stmt = GetStatement(argv[0], stmt_name)) == (STMT*)NULL)
    return ReturnInt(retstr, SQLCA_IntCode);
    
 swa = SWA(stmt);

 /*
  * Rest of args (if any) are bind values. Therefore bind the substitution
  * variables in WHERE/INSERT/UPDATE clause (if any).
  */
 argc--;
 if (argc) 
   {
    if (rc = BindValues(stmt, argc, &argv[1])) 
      {
       return ReturnInt(retstr, (long)rc);
      }
   }

 /*
  * This function can be called as SQLOPEN() or SQLEXECUTE(). These
  * operations are similar except for the describe. Use the function
  * name to determine what operation we are performing.
  */
 if (open) 
   {
    /* Describe the expression list & define output buffers (if any). */
    if ((expr_cnt = DefineExpressions(stmt)) < 0) 
      {
       return ReturnInt(retstr, (long)expr_cnt);
      }

    /* Since this is a call to SQLOPEN() the statement must be a query! */
    if (expr_cnt == 0) 
      { 
       if (!SEL(swa))
         {
          (void)sprintf(tmp,"statement \"%s\" is not a query.", stmt_name);
          return ReturnError(retstr, 13, tmp);
         }
       else
         {
          SetOraError(LDA(stmt), swa);
          return ReturnInt(retstr, ORACLE_ERROR);
         }
      }
   }

 /* Execute the SQL statement. This is required for Queries & DML! */
 if (rc = oexec(CTX(swa))) 
   {
    SetOraError(LDA(stmt), swa);
    return ReturnInt(retstr, ORACLE_ERROR);
   }

 /*
  * Return the ROWCOUNT.  For a query it will be zero at this stage.  For
  * a DML statement it will be the number of rows affected by the INSERT/
  * UPDATE/DELETE statement.
  */
 rowcount = SQLROWCNT(CTX(swa));
 SetRowCount(rowcount);
 return ReturnInt(retstr, (long)0L);
}

/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLOPEN(statement-name [, <bind-args>])
 *
 * RETURNS :  0-success,
 *           >0-number of rows affected for SQLEXECUTE(),
 *           <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraOpen
#else
ULONG SqlOpen
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
#if defined(ORA_PREFIX)
 return(OraExec(name, argc, argv, stck, retstr,1));
#else
 return(SqlExec(name, argc, argv, stck, retstr,1));
#endif
}

/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLEXECUTE(statement-name [, <bind-args>])
 *
 * RETURNS :  0-success,
 *           >0-number of rows affected for SQLEXECUTE(),
 *           <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraExecute
#else
ULONG SqlExecute
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
#if defined(ORA_PREFIX)
 return(OraExec(name, argc, argv, stck, retstr,0));
#else
 return(SqlExec(name, argc, argv, stck, retstr,0));
#endif
}


/*-----------------------------------------------------------------------------
 * SYNOPSIS: SQLCLOSE(statement-name)
 *
 * RETURNS :  0-success, <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraClose
#else
ULONG SqlClose
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    int         rc=0;
    STMT        *stmt=NULL;
    SQLWA	*swa=NULL;
    char        stmt_name[MAX_IDENTIFIER+1];

    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc != 1) return 1;

    if ((stmt = GetStatement(argv[0], stmt_name)) == (STMT*)NULL)
        return ReturnInt(retstr, SQLCA_IntCode);
    
    swa = SWA(stmt);

    /* Inform ORACLE that operation is complete. This should never fail! */
    if (rc = ocan(CTX(swa)))
        SetOraError(LDA(stmt), swa);

    return ReturnInt(retstr, rc ? ORACLE_ERROR : 0);
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLFETCH(statement-name [, number-of-rows])
 *
 * RETURNS :  0-end-of-data,
 *           >0- single fetch: row number of last row fetched
 *           >0- group fetch : number of rows fetched if < number-of-rows then
 *                             end--of-data is indicated.
 *           <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraFetch
#else
ULONG SqlFetch
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    long        rc=0;
    int         single_fetch=0;
    ULONG       num_rows=0L;
    ULONG       rowcount=0L;
    STMT        *stmt=NULL;
    SQLWA	*swa=NULL;
    char        stmt_name[MAX_IDENTIFIER+1];

    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc == 0 || argc > 2) return 1;

    if ((stmt = GetStatement(argv[0], stmt_name)) == (STMT*)NULL)
        return ReturnInt(retstr, SQLCA_IntCode);
    
    swa = SWA(stmt);

    /* Determine # of rows to fetch */
    if (argc > 1 && RXSTRLEN(argv[1])) {
        if (StrToInt(&argv[1], &num_rows)) {
            return ReturnError(retstr, 14,
                               "<num-rows> is not a valid integer.");
        }
        single_fetch = FALSE;
    }
    else
        single_fetch = TRUE;

    if (single_fetch) {
        /* Fetch a single row */
        if (rc = FetchRow(stmt, stmt_name, 0L))
           rc = (rc == NO_DATA_FOUND) ? 0 : rc;
        else
           rc = SQLROWCNT(CTX(swa));	/* Nasty! */
    }
    else {
    	/* Fetch each row in turn */
	for (rowcount = 1; num_rows == 0 || rowcount <= num_rows; rowcount++)
	    if (rc = FetchRow(stmt, stmt_name, rowcount))
		break;

        rowcount--;

        if (rc && rc != NO_DATA_FOUND) {
            return ReturnInt(retstr, (long)rc);
        }

        if (rc = SetRowCountVar(swa, stmt_name, rowcount))
            return ReturnInt(retstr, (long)rc);

        rc = rowcount;
    }

    SetRowCount(SQLROWCNT(CTX(swa)));
    return ReturnInt(retstr, rc);
}


/*-----------------------------------------------------------------------------
 * Fetch the description for the column expression. Used by SQLDESCRIBE().
 *----------------------------------------------------------------------------*/
static int GetColumn

#ifdef __STDC__
    (SQLWA *swa,int i,char *stem_name)
#else
    (swa, i, stem_name)
    SQLWA   *swa;
    int	    i;
    char    *stem_name;
#endif
{
    FLDDSCR *fd=NULL;
    int     idx=0, rc=0;
    char    column_size[7], column_prec[7], column_scale[7], column_nullok[7];
    char    *column_type=NULL;
    char    name[MAX_IDENTIFIER+32];
    char    *value[6];
    int     value_len[6];

    if (i >= swa->expr_cnt)
        return 1;

    fd = swa->fa[i];

    switch (fd->dbtype) {
    case ORA_CHAR:     column_type = "CHAR";     break;
    case ORA_VARCHAR2: column_type = "VARCHAR2"; break;
    case ORA_RAW:      column_type = "RAW";      break;
    case ORA_NUMBER:   column_type = "NUMBER";   break;
    case ORA_DATE:     column_type = "DATE";     break;
    case ORA_LONG:     column_type = "LONG";     break;
    case ORA_LONGRAW:  column_type = "LONG RAW"; break;
    case ORA_ROWID:    column_type = "ROWID";    break;
    case ORA_MLSLABEL: column_type = "MLSLABEL"; break;
    default:           column_type = "UNKNOWN";  break;
    }

    /* Set up the array */
    value[0] = fd->cbuf;
    value_len[0] = fd->cbufl;
    value[1] = column_type;
    value_len[1] = strlen(column_type);
    value[2] = column_size;
    value_len[2] = sprintf(column_size, "%ld", fd->rbufl);
    value[3] = column_scale;
    value_len[3] = sprintf(column_scale, "%d", fd->scale);
    value[4] = column_prec;
    value_len[4] = sprintf(column_prec, "%d", fd->prec);
    value[5] = column_nullok;
    value_len[5] = sprintf(column_nullok, "%d", fd->nullok);

    /* Output into Rexx variable */
    i++;
    for (idx = 0; idx < 6; idx++) {
        if (rc = SetRexxVariable(name,
                                 sprintf(name, "%s.COLUMN.%s.%d", stem_name,
                                         column_attribute[idx], i),
                                 value[idx],
                                 value_len[idx]))
            break;
    }

    return rc;
}



/*-----------------------------------------------------------------------------
 * SYNOPSIS:  SQLDESCRIBE(statement-name [, stem-name])
 *
 * RETURNS : >0-number of columns in the prepared SELECT statement.
 *            0-prepared statement is not a SELECT statement.
 *           <0-error.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
ULONG OraDescribe
#else
ULONG SqlDescribe
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    int         i=0, len1=0, len2=0, rc=0;
    STMT        *stmt=NULL;
    SQLWA	*swa=NULL;
    char        **p=NULL, buf1[MAX_IDENTIFIER+32], buf2[16];
    char        stmt_name[MAX_IDENTIFIER+1];
    char        stem_name[MAX_IDENTIFIER+1];


    FunctionPrologue(name, argc, argv);

    if (SQLCA_SqlCode) ClearOraError();
    if (SQLCA_IntCode) ClearIntError();

    if (argc < 1 || argc > 2) return 1;

    if ((stmt = GetStatement(argv[0], stmt_name)) == (STMT*)NULL)
        return ReturnInt(retstr, SQLCA_IntCode);
    
    swa = SWA(stmt);

    /* Get the name of the stem into which to put output */
    if (argc < 2 || RXSTRLEN(argv[1]) == 0) /* No stem name specified! */
        (void)strcpy(stem_name, stmt_name);
    else if (rc = MkIdentifier(argv[1], stem_name, sizeof(stem_name)))
        return ReturnInt(retstr, (long)rc);

    /* Describe the expression list & define output buffers (if any). */
    if ((rc = DefineExpressions(stmt)) < 0)
        return ReturnInt(retstr, (long)rc);

    /* Describe the parsed statement into REXX variables */
    for (rc = 0, i = 0; rc == 0; i++) {
        rc = GetColumn(swa, i, stem_name);
    };

    if (rc >= 0) {
        len2 = sprintf(buf2,"%d", --i);
        for (p = column_attribute; *p && rc >= 0; p++) {
            len1 = sprintf(buf1, "%s.COLUMN.%s.0", stem_name, *p);
            rc = SetRexxVariable(buf1, len1, buf2, len2);
        }
        rc = rc < 0 ? rc : i;
    }

    return ReturnInt(retstr, (long)rc);
}

/*-----------------------------------------------------------------------------
 * Table entry for a REXX/SQL function.
 *----------------------------------------------------------------------------*/
typedef	struct {
	PSZ	function_name;
	PFN	EntryPoint;
} RexxFunction;


/*-----------------------------------------------------------------------------
 * Table of REXX/SQL Functions. Used to install/de-install functions.
 *----------------------------------------------------------------------------*/
#if defined(ORA_PREFIX)
static RexxFunction RexxSqlFunctions[] = {
        { NAME_SQLCONNECT,    (PFN)OraConnect         },
        { NAME_SQLDISCONNECT, (PFN)OraDisconnect      },
        { NAME_SQLDEFAULT,    (PFN)OraDefault         },
        { NAME_SQLCOMMIT,     (PFN)OraCommit          },
        { NAME_SQLROLLBACK,   (PFN)OraRollback        },
        { NAME_SQLCOMMAND,    (PFN)OraCommand         },
        { NAME_SQLPREPARE,    (PFN)OraPrepare         },
        { NAME_SQLDISPOSE,    (PFN)OraDispose         },
        { NAME_SQLEXECUTE,    (PFN)OraExecute         },
        { NAME_SQLOPEN,       (PFN)OraOpen            },
        { NAME_SQLCLOSE,      (PFN)OraClose           },
        { NAME_SQLFETCH,      (PFN)OraFetch           },
        { NAME_SQLVARIABLE,   (PFN)OraVariable        },
        { NAME_SQLDESCRIBE,   (PFN)OraDescribe        },
#if defined(DYNAMIC_LIBRARY)
        { NAME_SQLDROPFUNCS,  (PFN)OraDropFuncs       },
#endif
	{ NULL,				NULL		}
};
#else
static RexxFunction RexxSqlFunctions[] = {
        { NAME_SQLCONNECT,    (PFN)SqlConnect         },
        { NAME_SQLDISCONNECT, (PFN)SqlDisconnect      },
        { NAME_SQLDEFAULT,    (PFN)SqlDefault         },
        { NAME_SQLCOMMIT,     (PFN)SqlCommit          },
        { NAME_SQLROLLBACK,   (PFN)SqlRollback        },
        { NAME_SQLCOMMAND,    (PFN)SqlCommand         },
        { NAME_SQLPREPARE,    (PFN)SqlPrepare         },
        { NAME_SQLDISPOSE,    (PFN)SqlDispose         },
        { NAME_SQLEXECUTE,    (PFN)SqlExecute         },
        { NAME_SQLOPEN,       (PFN)SqlOpen            },
        { NAME_SQLCLOSE,      (PFN)SqlClose           },
        { NAME_SQLFETCH,      (PFN)SqlFetch           },
        { NAME_SQLVARIABLE,   (PFN)SqlVariable        },
        { NAME_SQLDESCRIBE,   (PFN)SqlDescribe        },
#if defined(DYNAMIC_LIBRARY)
        { NAME_SQLDROPFUNCS,  (PFN)SqlDropFuncs       },
#endif
	{ NULL,				NULL		}
};
#endif

/*-----------------------------------------------------------------------------
 * This function is called to initiate REXX/SQL interface.
 *----------------------------------------------------------------------------*/
int InitRexxSQL

#ifdef __STDC__
    (PSZ progname)
#else
    (progname)
    PSZ progname;
#endif

{
    RexxFunction  *func=NULL;
    ULONG rc=0L;

    FunctionPrologue(progname, 0L, NULL);

    /* Install REXX/SQL variable descriptors */
    if (rc = InstallSQLVariables())
        return(rc);
    
    /* Register all REXX/SQL functions */
    for (func = RexxSqlFunctions; func->function_name; func++)
      {
#if defined(DYNAMIC_LIBRARY)
        rc = RexxRegisterFunctionDll(func->function_name,DLLNAME,func->function_name);
/*        printf("Registering External %s Internal %s %d\n",func->external_name,func->internal_name,rc);*/
#else
#   if defined(USE_AIXREXX)
        rc = RexxRegisterFunction(func->function_name,	func->EntryPoint);
#   else
        rc = RexxRegisterFunctionExe(func->function_name,	func->EntryPoint);
#   endif
/*        printf("Registering %s %d\n",func->external_name,rc);*/
#endif
      }
    return 0;
}


/*-----------------------------------------------------------------------------
 * This function is called to terminate all activity with REXX/SQL.
 *----------------------------------------------------------------------------*/
int TerminateRexxSQL

#ifdef __STDC__
    (PSZ progname)
#else
    (progname)
    PSZ progname;
#endif

{
 int rc=0;
    RexxFunction  *func=NULL;

    /* Release the REXX/SQL environment. */
    FunctionPrologue(progname, 0L, NULL);
    if (rc = ReleaseDbEnvironment())
        return rc;

    /* De-register all REXX/SQL functions only */
    /* if DEBUG value = 99                     */
    /* DO NOT DO THIS FOR DYNAMIC LIBRARY      */
    /* AS IT WILL DEREGISTER FOR ALL PROCESSES */
    /* NOT JUST THE CURRENT ONE.               */

 if (run_flags == 99)
   {
    for (func = RexxSqlFunctions; func->function_name; func++)
        (void)RexxDeregisterFunction(func->function_name);
   }

    return 0;
}

/*-----------------------------------------------------------------------------
 * Declare the initiating and terminating functions when used as a dynamic lib
 *----------------------------------------------------------------------------*/
#if defined(DYNAMIC_LIBRARY)

/*
 * SYNOPSIS: SQLLOADFUNCS();
 */
#if defined(ORA_PREFIX)
ULONG OraLoadFuncs
#else
ULONG SqlLoadFuncs
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    int rc=0;

    rc = InitRexxSQL(DLLNAME);
    return ReturnInt(retstr,rc);
}

/*
 * SYNOPSIS: SQLDROPFUNCS();
 */
#if defined(ORA_PREFIX)
ULONG OraDropFuncs
#else
ULONG SqlDropFuncs
#endif

#ifdef __STDC__
    (PSZ		name,ULONG	argc,RXSTRING	argv[],PSZ		stck,RXSTRING	*retstr)
#else
    (name, argc, argv, stck, retstr)
    PSZ		name;
    ULONG	argc;
    RXSTRING	argv[];
    PSZ		stck;
    RXSTRING	*retstr;
#endif
{
    int rc=0;

    rc = TerminateRexxSQL(DLLNAME);
    return ReturnInt(retstr,rc);
}

#endif
