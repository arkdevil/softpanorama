#include 	<io.h>
#include 	<dos.h>
#include 	<time.h>
#include	<stdio.h>
#include 	<dir.h>
#include	<stdlib.h>
#include	<string.h>
#include <sys/stat.h>
#include <errno.h>
#include "lib.h"
#include "ssleep.h"

currentfile();
extern char *share;
extern boolean visual_output;

#define OLD_LOCK_TIME (10*60)
#define SLEEP_INTERVAL 10

void
fd_lock(char *file, int fd)
{
	int trycnt;

	if (share == NULL)
		return;
	if (fd < 0 || file == NULL) {
		printmsg(0, "fd_lock: arg error, file %s, fd %d", file, fd);
		panic();
	}
	trycnt = 0;
	for (;;) {
		if (lock(fd, 0L, -1L) < 0) {
			if (errno == EINVAL) {
				printmsg(0, "fd_lock: share locking not installed");
				panic();
			}
		}
		else
			return;
		if (trycnt++ < OLD_LOCK_TIME/SLEEP_INTERVAL) {
			if (!visual_output) {
				printmsg(0, "fd_lock: attempt %d, %s busy, wait %ds, Esc to abort",
							trycnt, file, SLEEP_INTERVAL);
				if (!ssleep(SLEEP_INTERVAL))
					continue;
			}
			else {
				extern char *viscont;
				extern int vissleep;
				extern boolean visret;
				char *vc = viscont;
				int vs = vissleep;

				viscont = "abort";
				vissleep = SLEEP_INTERVAL;
				printmsg(0, "fd_lock: attempt %d, %s busy",
							trycnt, file);
				viscont = vc;
				vissleep = vs;
				if (!visret)
					continue;
			}
		}
		printmsg(0, "fd_lock: %s busy; can't release lock", file);
		panic();
	}
}
