/* modem_io.h */

int  ModemSendTo(int,int,char *);
char ModemWaitFor(int,int,int,char *);
int  ModemQuiet(int,int);
void ModemHangup(int);
void ModemCmdState(int);
void ModemEcho(int,int);
void ModemDebug(void);

