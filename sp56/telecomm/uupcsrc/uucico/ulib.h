/*
   ulib.h
*/

extern boolean port_active;         /* Port active flag for error handler   */

extern int openline(char *name, unsigned short baud);

extern int sread(char *buffer, int wanted, int timeout);
#define S_TIMEOUT (-1)
#define S_LOST (-2)
#define S_OK 1

extern int swrite(char *data, int len);

extern void ssendbrk(int duration);

extern void closeline(void);

extern void SIOSpeed(unsigned short baud);

extern void hangup( void );
