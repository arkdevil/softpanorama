#include <dos.h>
#define ALARM 0x1a
union REGS regs;
static char *TimeMess;
unsigned char Buff[960];
void interrupt AlarmHandle(void){
 register int i;
 SaveText(1,25,80,25,Buff);
 MySound(200,600);
 NegTabX(1,25,80,0x77);
 PrintString(2,25,TimeMess,0xf0);
 enable();
 keydown(1);
 disable();
 RestTextNorm(1,25,80,25,Buff);
}
void ResetAlarm(){
regs.h.ah = 7;
int86(ALARM, &regs, &regs);
}
void SetAlarm(char *StringTime,char *StringTime1){
register int i;
char StrTime[9];
char *StrPoint;
if(0!=strcmp(StringTime1,"")) TimeMess = StringTime1;
 if(0!=strcmp(StringTime,"")){
    strcpy(StrTime,StringTime);
     StrPoint=StrTime;
       ResetAlarm();
	setvect(0x4a,AlarmHandle);
	for(i=0;i<8;i++) *(StrPoint+i) -='0';
	regs.h.ch = (*StrTime << 4);
	regs.h.ch |= *(StrTime+1);
	regs.h.cl = (*(StrTime+3) << 4);
	regs.h.cl |= *(StrTime+4);
	regs.h.dh = (*(StrTime+6) << 4);
	regs.h.dh |=*(StrTime+7);
	regs.h.ah = 6;
    int86(ALARM, &regs, &regs);
 }
}


