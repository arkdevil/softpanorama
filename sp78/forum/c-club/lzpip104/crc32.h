#ifndef __ARGS__
#   include "modern.h"
#endif

void crcbegin __ARGS__((void));
void updcrc   __ARGS__((unsigned char *, unsigned));
void addcrc   __ARGS__((unsigned char));
unsigned long getcrc __ARGS__((void));
