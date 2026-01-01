#pragma inline;
void Autor(int colo_sh,int colo_no,int ColorBox,int colo_ch){
char *txt_aut[]={ " Copyright (C) 1991 by",
		  "  Noskov & Matveyonok",
		  "",
		  "   phone :  77-14-19",
		  "            54-34-56" };
unsigned char *buf;
char *string[]={"  Ok  "};
int numb_ch[]={1};
int point=0;
int colo_shoff=0;
int x1=24, y1=6, x2=54, y2=18;
int num_col=0, kol_col=0;
int ColTest=0;
register int i, j;
  ColTest = colo_sh;
  ColTest &= 0xf0;
  colo_shoff = colo_sh;
  colo_shoff >>= 4;
  colo_shoff |= ColTest;
buf = (unsigned char *)malloc(x2+2-x1+1*y2+1-y1+1);
  for(i=0;i < 5;i++){
    for(j=0;j <= strlen(txt_aut[i]);j++){
	kol_col=txt_aut[i][j];
	num_col=num_col+kol_col;
    }
  }
     if(num_col!=5519)
	  ResetMachine();

     SaveText(x1,y1,x2+2,y2+1,buf);
     PrintBox(x1,y1,x2,y2,0x00,colo_sh);
     ShadowRigth(x1,y1,x2,y2,7);
     BoxDraw(x1+2,y1+1,x2-2,y2-1,"┌┐└┘──││",ColorBox);

     for(i=0;i < 5;i++)
	PrintString(x1+4,y1+i+3,txt_aut[i],colo_sh);
	stshadow(x1+12,y2-3,string,colo_no,
		 colo_ch,colo_sh,numb_ch,point);
   while(!kbhit());
      PrintBox(x1+10,y2-3,x1+11+
	       strlen(string[0]),y2-2,0x00,colo_sh);
      stshadow(x1+13,y2-3,string,colo_no,
	       colo_ch,colo_shoff,numb_ch,point);
      keyclick();
      PrintBox(x1+10,y2-3,x1+11+
	       strlen(string[0]),y2-2,0x00,colo_sh);
      stshadow(x1+12,y2-3,string,colo_no,
	       colo_ch,colo_sh,numb_ch,point);
      RestTextNorm(x1,y1,x2+2,y2+1,buf);
      free(buf);
      getch();
}