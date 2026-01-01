#include <dos.h>
#define INTR 0x1C
#define ATTR 0x7000
static unsigned int count=0,second=0,minutes=0,hour=0,mhour=0;

void interrupt ( *oldhandler)(void);

void interrupt handler(void){
unsigned int (far *screen)[80];
screen = MK_FP(0xB800,0);
   if(count == 0){
	count=(((second % 5)==0) ? 19 : 18);
	     second++;
	     MySound(5,50);
	     if(second==60){
		   second=0;
		   minutes++;
		 if(minutes==60){
		       minutes=0;
		       hour++;
		       if(hour==24)
			    hour=0;
		 }
	     }
     screen[0][76] = second % 10 + '0' + ATTR;
     screen[0][75] = (second /10) % 10 + '0' + ATTR;
     screen[0][74] =  ':' + ATTR;
     screen[0][73] = minutes % 10 + '0' + ATTR;
     screen[0][72] = (minutes /10) % 10 + '0' + ATTR;
     screen[0][71] =  ':' + ATTR;
     screen[0][78] =  'm' + ATTR;
      if(hour >= 12){
	   screen[0][77] =  'p' + ATTR;
	      mhour=hour-12;
	      mhour=mhour?mhour:12;
       }else{
	screen[0][77] =  'a' + ATTR;
	mhour=hour;
	mhour=mhour?mhour:12;
       }
     screen[0][70] = mhour % 10 + '0' + ATTR;
    if(mhour > 9)
     screen[0][69] = (mhour /10) % 10 + '0' + ATTR;
   }
count--;
oldhandler();
}
void SetMyTime(void){
oldhandler = getvect(INTR);
GetMyTime(&second,&minutes,&hour);
setvect(INTR, handler);
}

