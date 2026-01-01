/*
 * Declarations and constants specific to an installation.
 *
 * DEMOS 2.
 *
 * $Log:	local.h,v $
 * Revision 1.11  93/01/04  02:16:11  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.10  92/08/24  02:20:22  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.9  1991/04/19  22:49:02  asa
 * Изменения для Демос 32
 *
 * Revision 1.8  1990/09/21  21:59:09  ache
 * MS-DOS extends + some new stuff
 * 
 * Revision 1.7  90/09/13  13:21:26  ache
 * MS-DOS & Unix together...
 * 
 * Revision 1.6  90/08/08  17:14:46  avg
 * SENDMAIL->NETMAIL
 * 
 * Revision 1.5  90/08/07  22:12:10  avg
 * Опмсание имени SENDMAILа вынесено в отдельный файл.
 * 
 * Revision 1.4  90/04/20  19:17:29  avg
 * Прикручено под System V
 * 
 * Revision 1.3  88/08/23  17:43:15  avg
 * Сделаны русские help-файлы.
 *
 * Revision 1.2  88/01/11  12:27:17  avg
 * Добавлены куски для работы с PMCS.
 * У rcsid поставлены комментарии NOXSTR.
 *
 * Revision 1.1  87/12/25  16:01:08  avg
 * Initial revision
 *
 */

/*
 * $Header: local.h,v 1.11 93/01/04 02:16:11 ache Exp $
 */
#ifndef MSDOS
#define NETMAIL                 /* network mailing allowed */

#define GETHOST                         /* System has gethostname syscall */
#define MYGETHOST                       /* XENIX hack by avg */

#ifdef  GETHOST
#define LOCAL           EMPTYID         /* Dynamically determined local host */
#else
#define LOCAL           'V'             /* Local host id */
#endif

#define MAIL            "localmail"  /* Name of mail sender */
#if !defined(SVR4) && !defined(__386BSD__)
#define MAILDIR         "/usr/spool/mail"
#else
#define MAILDIR         "/var/mail"
#endif
#define EDITOR          "/bin/ed"               /* Name of text editor */
#define VISUAL          "/usr/local/bin/re"       /* Name of display editor */
#define SHELL           "/bin/sh"       /* Standard shell */
#define MORE            "/usr/bin/more" /* Standard output pager */
#define HELPFILE        "Mail.help"    /* Name of casual help file */
#define THELPFILE       "Mail.help.~"  /* Name of casual tilde help */
#define RHELPFILE       "Mail.rhelp"   /* Name of casual help file */
#define RTHELPFILE      "Mail.rhelp.~" /* Name of casual tilde help */
#define POSTAGE         "/usr/adm/maillog"      /* Where to audit mail sending */
#define UIDMASK         0177777         /* Significant uid bits */
#define MASTER          "Mail.rc"
#define ALIASES         "/usr/lib/aliases"      /* Sendmail's aliases */

/* #define PMCS            "/usr/ucb/bin/pmcs"     /* project mailing control system */
/* #define PROJSPOOL       "/usr/spool/projects"   /* каталог файлов проектов */
/* #define PROJMAILER      "/etc/projmail"         /* sender для проектов */

#define UTIME                           /* System implements utime(2) */
#define GETPWENT                        /* System has <pwd.h> file */

#ifdef  VMUNIX
#define sigsys  signal
#define sigset  signal
#endif
#else   /*------------------------------MSDOS----------------------*/
/*
 * Declarations and constants specific to an installation.
 *
 * MSDOS.
 *
 */
#define NETMAIL                 /* network mailing allowed */

#define GETHOST                         /* System has gethostname syscall */

#ifdef  GETHOST
#define LOCAL           EMPTYID         /* Dynamically determined local host */
#else
#define LOCAL           'V'             /* Local host id */
#endif

#define MAIL            "sendmail.exe"     /* Name of mail sender */
#define MAILDIR         "."
#define EDITOR		"edlin.com"   /* Name of text editor */
#define VISUAL		"me.exe"      /* Name of display editor */
#define SHELL           "command.com"   /* Standard shell */
#define MORE            "list.com"    /* Standard file pager */
#define HELPFILE        "help.txt"    /* Name of casual help file */
#define THELPFILE       "helpt.txt"  /* Name of casual tilde help */
#define RHELPFILE       "rhelp.txt"   /* Name of casual help file */
#define RTHELPFILE      "rhelpt.txt" /* Name of casual tilde help */
#define POSTAGE         "maillog"      /* Where to audit mail sending */
#define MASTER          "mail.rc"
#define ALIASES         "aliases.txt"   /* Sendmail's aliases */

#endif  /*------------------------------MSDOS----------------------*/

#define CANLOCK                         /* Locking protocol actually works */
#define APPEND                          /* New mail goes to end of mailbox */
#define UNPACK_MAILBOX                  /* Unpack encoded batches */
