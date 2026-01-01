
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "const.h"
#include "db4.h"

extern FILE *fin;

char spool[PLSZ];
char *sp=spool;

int debug = 0;

yylex()
{
  int tok;

  tok = yylex1();
  if (debug) printf("returning token: %d\n", tok);
  return (tok);
}

yylex1()
{   int i;
    int c;

    c = getc(fin);
    while (c==' ' || c=='\t' || c=='\n')
        c = getc(fin);
    if (c==EOF) 
        return(0);
    if (c=='"') {
        yylval.sv = sp;
        c = getc(fin);
        while (c!='"') {
            *sp = c;
            sp++;
            c = getc(fin);
        }
        *sp = '\0';
        sp++;
        return(STRING);
    }
    if (c == '<') {
        if ((c=getc(fin)) == '>') {
            return(NE);
        } else if (c == '=') {
            return(LE);
        } else {
            ungetc(c, fin);
            return('<');
        }
    }
    if (c == '>') {
        if ((c=getc(fin)) == '=') {
            return(GE);
        } else {
            ungetc(c, fin);
            return('>');
        }
    }
    if (isdigit(c)) {
        yylval.iv  = 0;
        while (isdigit(c)) {
            yylval.iv = yylval.iv * 10 + (c - '0');
            c = getc(fin);
        }
        ungetc(c, fin);
        return(NUMBER);
    }
    if (isalpha(c)) {
        i = 0;
        while (isalnum(c)) {
            yylval.nv[i++] = c;
            c = getc(fin);
        }
        ungetc(c, fin);
        yylval.nv[i] = '\0';
        return (iskeywd(yylval.nv));
    }
    i = c;
    return (i);
}

        

struct {
  char keywd[NMSZ];	int  type;
} keytable[] = {

  "ACCEPT",		ACCEPT,
  "accept",		ACCEPT,
  "ADDITIVE",		ADDITIVE,
  "additive",		ADDITIVE,
  "ALIAS",		ALIAS,
  "alias",		ALIAS,
  "ALL",		ALL,
  "all",		ALL,
  "ALTERNATE",		ALTERNATE,
  "alternate",		ALTERNATE,
  "AMERICAN",		AMERICAN,
  "american",		AMERICAN,
  "ANSI",		ANSI,
  "ansi",		ANSI,
  "APPEND",		APPEND,
  "append",		APPEND,
  "ASCENDING",		ASCENDING,
  "ascending",		ASCENDING,
  "ASSIST",		ASSIST,
  "assist",		ASSIST,
  "AVERAGE",		AVERAGE,
  "average",		AVERAGE,
  "BACKGROUND",	BACKGROUND,
  "background",	BACKGROUND,
  "BEFORE",		BEFORE,
  "before",		BEFORE,
  "BELL",		BELL,
  "bell",		BELL,
  "BLANK",		BLANK,
  "blank",		BLANK,
  "BORDER",		BORDER,
  "border",		BORDER,
  "BOTTOM",		BOTTOM,
  "bottom",		BOTTOM,
  "BRITISH",		BRITISH,
  "british",		BRITISH,
  "BROWSE",		BROWSE,
  "browse",		BROWSE,
  "CANCEL",		CANCEL,
  "cancel",		CANCEL,
  "CARRY",		CARRY,
  "carry",		CARRY,
  "CASE",		CASE,
  "case",		CASE,
  "CATALOG",		CATALOG,
  "catalog",		CATALOG,
  "CENTURY",		CENTURY,
  "century",		CENTURY,
  "CHANGE",		CHANGE,
  "change",		CHANGE,
  "CLEAR",		CLEAR,
  "clear",		CLEAR,
  "CLOSE",		CLOSE,
  "close",		CLOSE,
  "COLOR",		COLOR,
  "color",		COLOR,
  "COM1",		COM1,
  "com1",		COM1,
  "COM2",		COM2,
  "com2",		COM2,
  "COMMAND",		COMMAND,
  "command",		COMMAND,
  "CONFIRM",		CONFIRM,
  "confirm",		CONFIRM,
  "CONSOLE",		CONSOLE,
  "console",		CONSOLE,
  "CONTINUE",		CONTINUE,
  "continue",		CONTINUE,
  "COPY",		COPY,
  "copy",		COPY,
  "COUNT",		COUNT,
  "count",		COUNT,
  "CREATE",		CREATE,
  "create",		CREATE,
  "DATABASES",		DATABASES,
  "databases",		DATABASES,
  "DATE",		DATE,
  "date",		DATE,
  "DEBUG",		DEBUG,
  "debug",		DEBUG,
  "DESCENDING",	DESCENDING,
  "descending",	DESCENDING,
  "DECIMALS",		DECIMALS,
  "decimals",		DECIMALS,
  "DEFAULT",		DEFAULT,
  "default",		DEFAULT,
  "DELETE",		DELETE,
  "delete",		DELETE,
  "DELETED",		DELETED,
  "deleted",		DELETED,
  "DELIMITED",		DELIMITED,
  "delimited",		DELIMITED,
  "DELIMITER",		DELIMITER,
  "delimiter",		DELIMITER,
  "DEVICE",		DEVICE,
  "device",		DEVICE,
  "DIF",		DIF,
  "dif",		DIF,
  "DIR",		DIR,
  "dir",		DIR,
  "DISPLAY",		DISPLAY,
  "display",		DISPLAY,
  "DO",		DO,
  "do",		DO,
  "DOHISTORY",		DOHISTORY,
  "dohistory",		DOHISTORY,
  "DOUBLE",		DOUBLE,
  "double",		DOUBLE,
  "ECHO",		ECHO,
  "echo",		ECHO,
  "EDIT",		EDIT,
  "edit",		EDIT,
  "EJECT",		EJECT,
  "eject",		EJECT,
  "ELSE",		ELSE,
  "else",		ELSE,
  "ENDCASE",		ENDCASE,
  "endcase",		ENDCASE,
  "ENDDO",		ENDDO,
  "enddo",		ENDDO,
  "ENDIF",		ENDIF,
  "endif",		ENDIF,
  "ENDTEXT",		ENDTEXT,
  "endtext",		ENDTEXT,
  "ENHANCED",		ENHANCED,
  "enhanced",		ENHANCED,
  "ENVIRONMENT",	ENVIRONMENT,
  "environment",	ENVIRONMENT,
  "ERASE",		ERASE,
  "erase",		ERASE,
  "ERROR",		ERROR,
  "error",		ERROR,
  "ESCAPE",		ESCAPE,
  "escape",		ESCAPE,
  "EXACT",		EXACT,
  "exact",		EXACT,
  "EXCEPT",		EXCEPT,
  "except",		EXCEPT,
  "EXIT",		EXIT,
  "exit",		EXIT,
  "EXPORT",		EXPORT,
  "export",		EXPORT,
  "EXTENDED",		EXTENDED,
  "extended",		EXTENDED,
  "FILLER",		FILLER,
  "filler",		FILLER,
  "FILTER",		FILTER,
  "filter",		FILTER,
  "FIND",		FIND,
  "find",		FIND,
  "FIXED",		FIXED,
  "fixed",		FIXED,
  "FIELDS",		FIELDS,
  "fields",		FIELDS,
  "FILE",		_FILE,
  "file",		_FILE,
  "FOR",		FOR,
  "for",		FOR,
  "FORM",		FORM,
  "form",		FORM,
  "FORMAT",		FORMAT,
  "format",		FORMAT,
  "FREEZE",		FREEZE,
  "freeze",		FREEZE,
  "FRENCH",		FRENCH,
  "french",		FRENCH,
  "FROM",		FROM,
  "from",		FROM,
  "FUNCTION",		FUNCTION,
  "function",		FUNCTION,
  "GERMAN",		GERMAN,
  "german",		GERMAN,
  "GETS",		GETS,
  "gets",		GETS,
  "GO",		GO,
  "go",		GO,
  "GOTO",		GOTO,
  "goto",		GOTO,
  "HEADING",		HEADING,
  "heading",		HEADING,
  "HELP",		HELP,
  "help",		HELP,
  "HISTORY",		HISTORY,
  "history",		HISTORY,
  "IF",		IF,
  "if",		IF,
  "IMPORT",		IMPORT,
  "import",		IMPORT,
  "INDEX",		INDEX,
  "index",		INDEX,
  "INPUT",		INPUT,
  "input",		INPUT,
  "INSERT",		INSERT,
  "insert",		INSERT,
  "INTENSITY",		INTENSITY,
  "intensity",		INTENSITY,
  "INTO",		INTO,
  "into",		INTO,
  "ITALIAN",		ITALIAN,
  "italian",		ITALIAN,
  "JOIN",		JOIN,
  "join",		JOIN,
  "KEY",		KEY,
  "key",		KEY,
  "LABEL",		LABEL,
  "label",		LABEL,
  "LAST",		LAST,
  "last",		LAST,
  "LIKE",		LIKE,
  "like",		LIKE,
  "LIST",		LIST,
  "list",		LIST,
  "LOCATE",		LOCATE,
  "locate",		LOCATE,
  "LOCK",		LOCK,
  "lock",		LOCK,
  "LOOP",		LOOP,
  "loop",		LOOP,
  "LPT1",		LPT1,
  "lpt1",		LPT1,
  "LPT2",		LPT2,
  "lpt2",		LPT2,
  "MARGIN",		MARGIN,
  "margin",		MARGIN,
  "MASTER",		MASTER,
  "master",		MASTER,
  "MEMORY",		MEMORY,
  "memory",		MEMORY,
  "MEMOWIDTH",		MEMOWIDTH,
  "memowidth",		MEMOWIDTH,
  "MENUS",		MENUS,
  "menus",		MENUS,
  "MESSAGE",		MESSAGE,
  "message",		MESSAGE,
  "MODIFY",		MODIFY,
  "modify",		MODIFY,
  "MODULE",		MODULE,
  "module",		MODULE,
  "NEXT",		NEXT,
  "next",		NEXT,
  "NOAPPEND",		NOAPPEND,
  "noappend",		NOAPPEND,
  "NOEJECT",		NOEJECT,
  "noeject",		NOEJECT,
  "NOFOLLOW",		NOFOLLOW,
  "nofollow",		NOFOLLOW,
  "NOMENU",		NOMENU,
  "nomenu",		NOMENU,
  "OFF",		OFF,
  "off",		OFF,
  "ON",		ON,
  "on",		ON,
  "OTHERWISE",		OTHERWISE,
  "otherwise",		OTHERWISE,
  "PACK",		PACK,
  "pack",		PACK,
  "PARAMETERS",	PARAMETERS,
  "parameters",	PARAMETERS,
  "PATH",		PATH,
  "path",		PATH,
  "PFS",		PFS,
  "pfs",		PFS,
  "PLAIN",		PLAIN,
  "plain",		PLAIN,
  "PRINT",		PRINT,
  "print",		PRINT,
  "PRINTER",		PRINTER,
  "printer",		PRINTER,
  "PROCEDURE",		PROCEDURE,
  "procedure",		PROCEDURE,
  "PUBLIC",		PUBLIC,
  "public",		PUBLIC,
  "QUERY",		QUERY,
  "query",		QUERY,
  "QUIT",		QUIT,
  "quit",		QUIT,
  "RANDOM",		RANDOM,
  "random",		RANDOM,
  "READ",		READ,
  "read",		READ,
  "RECALL",		RECALL,
  "recall",		RECALL,
  "RECORD",		RECORD,
  "record",		RECORD,
  "REINDEX",		REINDEX,
  "reindex",		REINDEX,
  "RELATION",		RELATION,
  "relation",		RELATION,
  "RELEASE",		RELEASE,
  "release",		RELEASE,
  "RENAME",		RENAME,
  "rename",		RENAME,
  "REPLACE",		REPLACE,
  "replace",		REPLACE,
  "REPORT",		REPORT,
  "report",		REPORT,
  "REST",		REST,
  "rest",		REST,
  "RESTORE",		RESTORE,
  "restore",		RESTORE,
  "RESUME",		RESUME,
  "resume",		RESUME,
  "RETRY",		RETRY,
  "retry",		RETRY,
  "RETURN",		RETURN,
  "return",		RETURN,
  "RUN",		RUN,
  "run",		RUN,
  "SAMPLE",		SAMPLE,
  "sample",		SAMPLE,
  "SAFETY",		SAFETY,
  "safety",		SAFETY,
  "SAVE",		SAVE,
  "save",		SAVE,
  "SCREEN",		SCREEN,
  "screen",		SCREEN,
  "SDF",		SDF,
  "sdf",		SDF,
  "SEEK",		SEEK,
  "seek",		SEEK,
  "SELECT",		SELECT,
  "select",		SELECT,
  "SET",		SET,
  "set",		SET,
  "SKIP",		SKIP,
  "skip",		SKIP,
  "SORT",		SORT,
  "sort",		SORT,
  "STANDARD",		STANDARD,
  "standard",		STANDARD,
  "STATUS",		STATUS,
  "status",		STATUS,
  "STEP",		STEP,
  "step",		STEP,
  "STORE",		STORE,
  "store",		STORE,
  "STRUCTURE",		STRUCTURE,
  "structure",		STRUCTURE,
  "SUM",		SUM,
  "sum",		SUM,
  "SUMMARY",		SUMMARY,
  "summary",		SUMMARY,
  "SUSPEND",		SUSPEND,
  "suspend",		SUSPEND,
  "SYLK",		SYLK,
  "sylk",		SYLK,
  "TALK",		TALK,
  "talk",		TALK,
  "TEXT",		TEXT,
  "text",		TEXT,
  "TITLE",		TITLE,
  "title",		TITLE,
  "TO",		TO,
  "to",		TO,
  "TOP",		TOP,
  "top",		TOP,
  "TOTAL",		TOTAL,
  "total",		TOTAL,
  "TYPE",		TYPE,
  "type",		TYPE,
  "TYPEAHEAD",		TYPEAHEAD,
  "typeahead",		TYPEAHEAD,
  "UNIQUE",		UNIQUE,
  "unique",		UNIQUE,
  "UPDATE",		UPDATE,
  "update",		UPDATE,
  "USE",		USE,
  "use",		USE,
  "VIEW",		VIEW,
  "view",		VIEW,
  "WAIT",		WAIT,
  "wait",		WAIT,
  "WHILE",		WHILE,
  "while",		WHILE,
  "WIDTH",		WIDTH,
  "width",		WIDTH,
  "WITH",		WITH,
  "with",		WITH,
  "WKS",		WKS,
  "wks",		WKS,
  "ZAP",		ZAP,
  "zap",		ZAP,
  "FALSE",		FALSE,
  "false",		FALSE,
  "TRUE",		TRUE,
  "true",		TRUE,
  "IDENTIFIER",	IDENTIFIER,
  "identifier",	IDENTIFIER,
  "FUNCALL",		FUNCALL,
  "funcall",		FUNCALL,
  "CHARACTER",		CHARACTER,
  "character",		CHARACTER,
  "NUMBER",		NUMBER,
  "number",		NUMBER,
  "STRING",		STRING,
  "string",		STRING,
  "NE",		NE,
  "ne",		NE,
  "LE",		LE,
  "le",		LE,
  "GE",		GE,
  "ge",		GE,
  "UNARYMINUS",	UNARYMINUS,
  "unaryminus",	UNARYMINUS,
  "$EOF$",		IDENTIFIER,
};

/* a sequential search routine */

iskeywd(name)
char *name;
{   int i;

    for (i=0; strcmp(keytable[i].keywd, "$EOF$"); i++) {
        if (!strcmp(keytable[i].keywd, name))
            return(keytable[i].type);
    }
    return (keytable[i].type);
}


