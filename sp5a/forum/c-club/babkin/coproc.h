/**/
/*
/*      coproc.h
/*
/*      (C) Copyright by Serge Babkin, 1993
/*
/*      Any part of this code may be freely distributed for
/*      the non-commertial use when it contains this copyright
/*      notice only.
/*
/*      My FIDO address is: 2:5010/4
/*
/**/

#ifndef _COPROC_H

#define _COPROC_H

extern int lbolt;

int cosleep();
int cofork();
int run1coproc();
int cowakeup();
int coexit();
int cogetpid();

/* switch to the next coprocess, insert the current coprocess */
/* into the ready-to-run queue with priority pri              */

#define coswtch(pri)      cosleep(&lbolt,pri)

#endif /* _COPROC_H */
