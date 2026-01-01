#define Buffstr 14
#define Buffstr1 78
int xa1=24, xa2=57, ya1=7, ya2=17;
int ch=0,i;
static int point=0,sty=0;
unsigned char DialBar[39-29-1];
unsigned char DialBarBuffer[39-29-1];
unsigned char DialBar1[57-28-1];
unsigned char DialBarBuffer1[57-28-1];
char *string[]={" Set Alarm Clock ",
		" Text Message    "};
unsigned char *buf;
static char StrClocka[Buffstr]="12:00:00 am";
static char StrClock[Buffstr]="12:00:00 am";
static char StrClocka1[Buffstr1]="String Message";
static char StrClock1[Buffstr1]="String Message";
int BarAttr=0x50;
void AlmClock(){
int CurPos;
static int TimePoint=0;
NegTabX(xa1+5+TimePoint*3,ya1+4,2,0x50);
   while(ch!=27){
     ch=getch();
      if(ch==0){
	ch=getch();
	    if(ch==77){
		NegTabX(xa1+5+TimePoint*3,ya1+4,2,0x7);
		TimePoint==3 ? TimePoint=0 : TimePoint++;
		NegTabX(xa1+5+TimePoint*3,ya1+4,2,0x50);
	    }
	     if(ch==75){
		NegTabX(xa1+5+TimePoint*3,ya1+4,2,0x7);
		TimePoint==0 ? TimePoint=3 : TimePoint--;
		NegTabX(xa1+5+TimePoint*3,ya1+4,2,0x50);
	     }
	       if(ch==72){
		      if(TimePoint<3){
			    CurPos=StrClocka[TimePoint*3+1]-'0';
			    CurPos+=(StrClocka[TimePoint*3]-'0')*10;
		      }
		if(TimePoint==0) CurPos = CurPos < 12 ? ++CurPos : 1;
		   else{
		     if( TimePoint!=3 ) CurPos = CurPos < 59 ? ++CurPos : 0;
			else{
			  if(StrClocka[9]=='a')StrClocka[9]='p';
				 else  StrClocka[9]='a';
			}
		   }
		      if(TimePoint<3){
			   StrClocka[TimePoint*3]=CurPos/10+'0';
			   StrClocka[TimePoint*3+1]=CurPos%10+'0';
		      }
		   }
	       if(ch==80){
		      if(TimePoint<3){
			 CurPos=StrClocka[TimePoint*3+1]-'0';
			 CurPos+=(StrClocka[TimePoint*3]-'0')*10;
		      }
		if(TimePoint==0) CurPos = CurPos > 1 ? --CurPos : 12;
		   else{
		     if( TimePoint!=3 ) CurPos = CurPos > 0 ? --CurPos : 59;
			else{
			  if(StrClocka[9]=='a')StrClocka[9]='p';
				 else  StrClocka[9]='a';
			}
		      }
		      if(TimePoint<3){
			   StrClocka[TimePoint*3]=CurPos/10+'0';
			   StrClocka[TimePoint*3+1]=CurPos%10+'0';
		      }
		   }
		  PrintString(xa1+5,ya1+4,StrClocka,0x7);
		  NegTabX(xa1+5+TimePoint*3,ya1+4,2,0x50);
	      }
		  if(ch==13){
		    if(StrClocka[9]=='p'){
		      if((StrClocka[0]=='1')&&(StrClocka[1]=='2')){
			 strcpy(StrClock,StrClocka);
		       }else{
		       CurPos=StrClocka[1]-'0';
		       CurPos+=(StrClocka[0]-'0')*10;
		       CurPos+=12;
		       strcpy(StrClock,StrClocka);
		       StrClock[0]=CurPos/10+'0';
		       StrClock[1]=CurPos%10+'0';
		       }
		    }else{
			 strcpy(StrClock,StrClocka);
		      if((StrClocka[0]=='1')&&(StrClocka[1]=='2')){
			  StrClock[0]='0';
			  StrClock[1]='0';
		      }
		    }
		     break;
		  }
	       }
}
void AlmMessage(){
strcpy(StrClock1,(char *)edit_string(ya1+8,xa1+4,xa1+29,1543,
	    Buffstr1,StrClocka1,DialBar1,DialBarBuffer1));
}
void AlarmClock(){
register int i;
memset(DialBar,BarAttr,39-29-1);
memset(DialBar1,BarAttr,57-28-1);
buf = (unsigned char *)malloc(4096);
SaveText(xa1,ya1,xa2+2,ya2+1,buf);
ClearBox(xa1,ya1,xa2,ya2);
ShadowRigth(xa1,ya1,xa2,ya2,7);
BoxDraw(xa1+2,ya1+1,xa2-2,ya2-1,"┌┐└┘──││",0x7f);
  stshadow(xa1+4,ya1+2,string,0x20,0x2e,0x70,0,0);
NegTabX(xa1+4,ya1+4,26,0x07);
  stshadow(xa1+4,ya1+6,string,0x20,0x2e,0x70,0,1);
NegTabX(xa1+4,ya1+8,26,0x07);
stshadow(xa1+4,ya1+2+sty,string,0x2f,0x2e,0x70,0,point);
ClearStringX(xa1+4,ya1+4,26);
PrintString(xa1+5,ya1+4,StrClocka,0x07);
ClearStringX(xa1+4,ya1+8,26);
for(i=0;i < 25;i++)
  PrintUsingCharX(xa1+5+i,ya1+8,1,StrClocka1[i],0x07);
begin:
ch=getch();
  if(ch==0){
       ch=getch();
	 if (ch==80){
	       if (point < 1){
		stshadow(xa1+4,ya1+2+sty,string,0x20,0x2e,0x70,0,point);
		point++;
		sty+=4;
		stshadow(xa1+4,ya1+2+sty,string,0x2f,0x2e,0x70,0,point);
	       } else {
		stshadow(xa1+4,ya1+2+sty,string,0x20,0x2e,0x70,0,point);
		point=0;
		sty=0;
		stshadow(xa1+4,ya1+2+sty,string,0x2f,0x2e,0x70,0,point);
	       }
	 }
	 if (ch==72){
	       if (point > 0){
		stshadow(xa1+4,ya1+2+sty,string,0x20,0x2e,0x70,0,point);
		point--;
		sty-=4;
		stshadow(xa1+4,ya1+2+sty,string,0x2f,0x2e,0x70,0,point);
	       } else {
		stshadow(xa1+4,ya1+2+sty,string,0x20,0x2e,0x70,0,point);
		point=1;
		sty=4;
		stshadow(xa1+4,ya1+2+sty,string,0x2f,0x2e,0x70,0,point);
	       }
	 }
  }
if(ch==27)goto e_xit;
if (ch==13){
   PrintBox(xa1+4,ya1+2+sty,xa1+17,ya1+2+1+sty,0x00,0x70);
   stshadow(xa1+4+1,ya1+2+sty,string,0x2f,
	    0x2e,0x77,0,point);
   keyclick();
   PrintBox(xa1+4,ya1+2+sty,xa1+17,ya1+2+1+sty,0x00,0x70);
   stshadow(xa1+4,ya1+2+sty,string,0x2f,
	    0x2e,0x70,0,point);
  if(point==0){
     AlmClock();
     NegTabX(xa1+4,ya1+4,26,0x07);
     SetAlarm(StrClock,StrClock1);
  }
    if(point==1){
       AlmMessage();
       NegTabX(xa1+4,ya1+8,26,0x07);
    }
}
goto begin;
e_xit:;
RestTextNorm(xa1,ya1,xa2+2,ya2+1,buf);
free(buf);
}