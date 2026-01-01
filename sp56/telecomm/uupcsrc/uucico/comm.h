/*
** declarations from FOSSIL & internal drivers
*/

void far _select_port(int); /* select active port (1 or 2) */
void far save_com(void);   /* save the interupt vectors */
void far restore_com(void);   /* restore those vectors */
int far _install_com(void); /* install our vectors */

void far _open_com(         /* open com port */
   unsigned,  /* baud */
   int,  /* 'M'odem or 'D'irect */
   int,  /* Parity 'N'one, 'O'dd, 'E'ven, 'S'pace, 'M'ark */
   int,  /* stop bits (1 or 2) */
   int); /* Xon/Xoff 'E'nable, 'D'isable */

void far _close_com(void);  /* close com port */
void far _dtr_off(void);    /* clear DTR */
void far _dtr_on(void);     /* set DTR */
void far _set_connected(int);

unsigned long far r_count(void);    /* receive counts */
   /* high word = total size of receive buffer */
   /* low word = number of pending chars */
#define r_count_size() ((int)(r_count() >> 16))
#define _r_count_pending() ((int)r_count())

int far receive_com(void); /* get one character */
   /* return -1 if none available */

unsigned long far s_count(void);    /* send counts */
   /* high word = total size of transmit buffer */
   /* low word = number of bytes free in transmit buffer */
#define s_count_size() ((int)(s_count() >> 16))
#define _s_count_free() ((int)s_count())

void far _r_flush(void);
int far send_com(int);    /* send a character */
void far send_local(int);  /* simulate receive of char */
void far sendi_com(int);   /* send immediately */
void far _break_com(void);  /* send a BREAK */
int far _carrier(void);

void  select_port(int  port);
boolean set_connected(boolean need);
boolean	install_com(void);
void  open_com(unsigned short  baud,char  modem,char  parity,int  stopbits,char  xon);
void  close_com(void);
void  dtr_on(void);
void  dtr_off(void);
void  break_com(int  length);
void  r_flush(void);
void  r_purge(void);
void  w_purge(void);
int   w_flush(void);
int  s_count_free(void);
int  s_1_free(void);
int  r_count_pending(void);
int  r_1_pending(void);
int  s_count_pending(void);
unsigned read_block(unsigned wanted, char *buf);
int receive_char(void);
int transmit_char(char c);
int status(void);
boolean carrier(boolean);
void timer_parms(void);
int timer_function(void (interrupt far *ff)(void), int ins);
unsigned write_block(unsigned wanted, char *buf);
int peek_ahead(void);
void fossil_delay(unsigned tics);
void fossil_exit(void);
void flowcontrol(boolean);

extern unsigned char fs_tim_int, fs_tics_per_sec;
extern unsigned fs_ms_per_tic;
extern boolean need_carrier;

/* Status bits */

#define FS_TSRE 0x4000
#define FS_THRE 0x2000
#define FS_OVRN 0x0200
#define FS_RDA	0x0100
#define FS_DCD	0x0080

