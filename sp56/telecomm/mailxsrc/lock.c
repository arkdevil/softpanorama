/*
 * A mailing program.
 *
 * Stuff to do version 7 style locking.
 *
 * $Log:	lock.c,v $
 * Revision 1.8  93/01/04  02:16:17  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.7  92/08/24  02:20:27  ache
 * Основательные правки и перенос в разные системы
 * 
 * Revision 1.10  1991/07/22  16:36:47  ache
 * Port to Borland C
 *
 * Revision 1.9  1991/03/10  18:26:37  ache
 * Убран ungetch (DOS)
 *
 * Revision 1.8  90/10/04  04:25:57  ache
 * sleep теперь не блокирует SIGINT.
 *
 * Revision 1.7  90/09/25  18:54:45  ache
 * MS-DOS locking use HIDDEN now.
 *
 * Revision 1.6  90/09/22  20:25:19  avg
 * ++ повторы.
 *
 * Revision 1.5  90/09/22  20:22:38  avg
 * В Unix сделана совместимая с localmail блокировка.
 *
 * Revision 1.4  90/09/13  13:19:48  ache
 * MS-DOS & Unix together...
 *
 * Revision 1.3  88/07/23  20:35:32  ache
 * Русские диагностики
 *
 * Revision 1.2  88/01/11  12:43:48  avg
 * Добавлен NOXSTR у rcsid.
 *
 * Revision 1.1  87/12/25  16:00:00  avg
 * Initial revision
 *
 */

#ifdef  MSDOS
#include 	<io.h>
#include 	<dos.h>
#include 	<time.h>
#ifndef __TURBOC__
void sleep();
#endif
#endif
#include <fcntl.h>
#include <errno.h>
#include "rcv.h"
#include <sys/stat.h>

#define OLD_LOCK_TIME (10*60)
#define SLEEP_INTERVAL 10

/*NOXSTR*/
static char rcsid[] = "$Header: lock.c,v 1.8 93/01/04 02:16:17 ache Exp $";
/*YESXSTR*/
static char             curlock[PATHSIZE];      /* Last used name of lock */
static int              locked = 0;             /* To note that we locked it */

#ifdef F_SETLK
int
setflock (fd, wr)
{
    static struct flock lock = {
	F_UNLCK,
	0,
	(long) 0,
	(long) 0,
    };

    lock.l_type = wr;

    return ((fcntl (fd, F_SETLK, &lock) != -1)
	   || errno == EINVAL
    );
}

int
getflock (fd)
{
    static struct flock lock = {
	F_UNLCK,
	0,
	(long) 0,
	(long) 0,
    };

    return (fcntl (fd, F_GETLK, &lock) != -1 && lock.l_type != F_UNLCK);
}
#endif  /* F_SETLK */

/*
 * Unix v7-style locking using user x-bit
 */
void
file_lock(file, fd)
char *file;
{
	struct stat stbuf;
	int trycnt, rst;

	if (locked)
		return;
#ifdef MSDOS
	if (fd < 0 || value("SHARE") == NOSTR)
		return;
#else
#ifdef F_SETLK
	if (fd < 0)
		return;
#else
	if (fd > 0)
		return;
#endif
#endif
	trycnt = 0;
checkagain:
	if((rst = stat(file, &stbuf)) < 0 && fd < 0)
		return;
#ifndef MSDOS
	if (
#ifdef  F_SETLK
		getflock(fd) ||
#endif
		rst == 0 && stbuf.st_mode & 1           /* user x bit is the lock */
	   )
	{
		if( stbuf.st_ctime+OLD_LOCK_TIME >= time((time_t *)NULL) ) {
#else
	goto fd_lock;
#endif
	already:
			if (trycnt++ < OLD_LOCK_TIME/SLEEP_INTERVAL) {
				fprintf(stderr, ediag("%s busy; waiting %d seconds\n","%s занят; ждем %d секунд\n"), file, SLEEP_INTERVAL);
				sleep(SLEEP_INTERVAL);
				goto checkagain;
			}
			fprintf(stderr, ediag("%s busy; can't lock file\n","%s занят; нельзя заблокировать файл\n"), file);
			exit(1);
#ifndef MSDOS
		}
	}
#ifdef  F_SETLK
	if (!setflock(fd, F_WRLCK))
		goto already;
#endif
	if (rst == 0) {
		chmod(file, stbuf.st_mode | 1);
		locked = stbuf.st_mode & ~1;
	}
	strcpy(curlock, file);
#else   /*MSDOS*/
fd_lock:
	if (lock(fd, 0L, -1L) < 0) {
		if (errno == EINVAL) {
			fprintf(stderr, ediag("share locking not installed\n","не установлена блокировка share\n"));
			exit(1);
		}
		goto already;
	}
	locked = 1;
#endif
}

void
file_unlock()
{
#ifdef MSDOS
	locked = 0;
	return;	/* Do nothing */
#else
	if(locked) {
		chmod(curlock, locked);
		locked = 0;
	}
#endif
}

