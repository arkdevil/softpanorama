/* RCS compile-time configuration */

	/* $Id: conf.h%v 1.2 1991/08/23 14:39:44 SGP Exp $ */

/*
 * This file is generated automatically.
 * If you edit it by hand your changes may be lost.
 * Instead, please try to fix conf.sh,
 * and send your fixes to rcs-bugs@cs.purdue.edu.
 */

#define exitmain(n) return n /* how to exit from main() */
#if !MAKEDEPEND
#	include <stdio.h>
#	include <sys/types.h>
#	include <sys/stat.h>
#	include <fcntl.h>
#	include <limits.h>
# 	include <stdlib.h>
#	include <string.h>
#	include <io.h>
#	include <process.h>
#	include <dir.h>
/* #	include <unistd.h> */
/* #	include <vfork.h>  */
#endif /* !MAKEDEPEND */
#define has_sys_dir_h 0 /* Does #include <sys/dir.h> work?  */
#define has_sys_param_h 0 /* Does #include <sys/param.h> work?  */
#define has_sys_wait_h 0 /* Does #include <sys/wait.h> work?  */
/* #define const */ /* The 'const' keyword does not work.  */
/* #define volatile */ /* The 'volatile' keyword does not work.  */
/* typedef int gid_t; */ /* Standard headers define gid_t.  */
typedef int mode_t; /* Standard headers do not define mode_t.  */
typedef int pid_t; /* Standard headers do not define pid_t.  */
typedef int sig_atomic_t; /* Standard headers do not define sig_atomic_t.  */
/* typedef int size_t; */ /* Standard headers define size_t.  */
/* typedef long time_t; */ /* Standard headers define time_t.  */
/* typedef int uid_t; */ /* Standard headers define uid_t.  */
#define has_prototypes 1 /* Do function prototypes work?  */
#if has_prototypes
#	define P(params) params
#	if !MAKEDEPEND
#		include <stdarg.h>
#	endif
#	define vararg_start(ap,p) va_start(ap,p)
#else
#	define P(params) ()
#	if !MAKEDEPEND
#		include <varargs.h>
#	endif
#	define vararg_start(ap,p) va_start(ap)
#endif
#define has_getuid 0 /* Does getuid() work?  */
/* #define declare_getpwuid struct passwd *getpwuid P((uid_t)); */
#define has_rename 1 /* Does rename() work?  */
#define bad_rename 1 /* Does rename(A,B) fail if B exists?  */
#define VOID (void) /* 'VOID e;' discards the value of an expression 'e'.  */
#define signal_type void /* type returned by signal handlers */
#define sig_zaps_handler 0 /* Must a signal handler reinvoke signal()?  */
#define has_seteuid 0 /* Does seteuid() obey Posix 1003.1-1990?  */
#define has_sigaction 0 /* Does struct sigaction work?  */
#define has_sigblock 0 /* Does sigblock() work?  */
#define has_sys_siglist 0 /* Does sys_siglist[] work?  */
#define has_tmpnam 1 /* Does tmpnam() exist ? */
#define exit_type void /* type returned by exit() */
#define underscore_exit_type void /* type returned by _exit() */
typedef size_t fread_type; /* type returned by fread() and fwrite() */
typedef void *malloc_type; /* type returned by malloc() */
#define free_type void /* type returned by free() */
typedef size_t strlen_type; /* type returned by strlen() */
#define has_getcwd 1 /* Does getcwd() work?  */
/* #define has_getwd ? */ /* Does getwd() work?  */
#define has_vfork 0 /* Does vfork() work?  */
#define has_vfprintf 1 /* Does vfprintf() work?  */
#define CO "co.exe" /* name of 'co' program */
#define COMPAT2 0 /* Are version 2 files supported?  */
#define DATEFORM "%.2d.%.2d.%.2d.%.2d.%.2d.%.2d" /* e.g. 01.01.01.01.01.01 */
#define DIFF "diff.exe" /* name of 'diff' program */
#define DIFF_FLAGS , "-an" /* Make diff output suitable for RCS.  */
#define DIFF_L 0 /* Does diff -L work? */
#define EXECRCS execv /* variant of execv() to use on subprograms */
#define MERGE "merge.exe" /* name of 'merge' program */
#define RCSDIR "RCS/" /* subdirectory for RCS files */
#define SLASH '/' /* path name separator */
#define TMPDIR "/tmp/" /* default directory for temporary files */
#define DIFF_PATH_HARDWIRED 1 /* Is DIFF absolute, not relative?  */
#define ROOTPATH(p) ((p)[0]==SLASH)
#define RCSSEP '%' /* separator for RCSSUF */
#define SENDMAIL "/bin/mail" /* how to send mail */
#define WIFEXITED(x) (1) /* Always an EXIT on DOS */
#define WEXITSTATUS(x) (x) /* Return status from a child process */
#if 1 /* These agree with <stdio.h>.  */
	int fprintf P((FILE*,const char*,...));
	int printf P((const char*,...));
#	if has_vfprintf
		int vfprintf P((FILE*,const char*,...));
#	else
		void _doprnt P((const char*,...));
#	endif
#endif
/* char *sprintf P((char*,const char*,...)); */
int chmod P((const char*,mode_t));
int fcntl P((int,int,...));
int open P((const char*,int,...));
mode_t umask P((mode_t));
pid_t wait P((int*));
#ifndef O_CREAT
	int creat P((const char*,mode_t));
#endif
#if has_seteuid
	int setegid P((gid_t));
	int seteuid P((uid_t));
#endif
