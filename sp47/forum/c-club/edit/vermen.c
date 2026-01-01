void VerMen(int StartX,int StartY,int KolElm,char *MenStr[],
	    int MenAct[],int StepDet,int StartMesX,int StartMesY,
	    char *MenStrMes[],int ColorNorm,int ColorInver,
	    int ColorChNorm,int ColorChInver,int *DropPoint){

char ch;
unsigned char *BufTextOne;
int MaxLenMen,KonLen,Elm1;
int PointRet, StatY;
int OldPoint, OldStatY;
int LastElm,LastLen;
int NachLen,NachElm;
int C1 = 0, C2 = 0;
int ColorNotAct = 0;
register int i, j;
 C1 = ColorNorm >> 4;
 C2 = 0x08;
 ColorNotAct = C1;
 ColorNotAct <<= 4;
 ColorNotAct |= C2;
 PointRet=*DropPoint; StatY=*(DropPoint+1);
 MaxLenMen=0;
   for(i=0;i <= KolElm;i++){
       Elm1=strlen(MenStr[i]);
       MaxLenMen=(MaxLenMen > Elm1) ? MaxLenMen:Elm1;
   }
 for(i=0;i <= KolElm;i++){
   if(MenAct[i] >= 0){
     KonLen=StepDet*i;
     LastElm=i;
   }
 }
 for(i=0;i <= KolElm;i++){
   if(MenAct[i] >= 0){
     NachLen=StepDet*i;
     NachElm=i;
     break;
   }
 }
 LastLen=KolElm*StepDet;
 BufTextOne = (unsigned char *)malloc((MaxLenMen+1*KolElm+1)<<1);
 SaveText(StartX-2,StartY-1,StartX+MaxLenMen+3,LastLen+StartY+2,BufTextOne);
 ClearBox(StartX-2,StartY-1,StartX+MaxLenMen+1,LastLen+StartY+1);
 ShadowRigth(StartX-2,StartY-1,StartX+MaxLenMen+1,LastLen+StartY+1,0x07);
 BoxDraw(StartX-1,StartY-1,StartX+MaxLenMen,LastLen+StartY+1,
	 "┌┐└┘──││",ColorNorm);
   for(i=0,j=0;j <= KolElm;i+=StepDet,j++){
   if(MenAct[j] >= 0){
    PrintString(StartX,StartY+i,MenStr[j],ColorNorm);
   } else PrintString(StartX,StartY+i,MenStr[j],ColorNotAct);
      if(MenAct[j] > -1)
	  NegTabX(StartX+1+MenAct[j],StartY+i,1,ColorChNorm);
	if(MenAct[j] == -1){
	    PrintUsingCharX(StartX-1,StartY+i,1,'├',ColorNorm);
	    PrintUsingCharX(StartX,StartY+i,MaxLenMen,'─',ColorNorm);
	    PrintUsingCharX(StartX+MaxLenMen,StartY+i,1,'┤',ColorNorm);
	}
   }
   OldStatY=StatY;
   OldPoint=PointRet;
   while((MenAct[PointRet] < 0)&&(PointRet < KolElm)){
      StatY+=StepDet;
      PointRet++;
   }
   if(MenAct[PointRet] < 0){
      StatY=OldStatY;
      PointRet=OldPoint;
   }else   NegTabX(StartX,StartY+StatY,MaxLenMen,ColorInver);

    if(MenAct[PointRet] > -1)
      NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChInver);
    ClearStringX(StartMesX,StartMesY,80-StartMesX);
    PrintString(StartMesX,StartMesY,MenStrMes[PointRet],ColorNorm);
begin:
ch=getch();
 if (ch==0){
   ch=getch();
    if (ch==75){PUSH_KEY(75,00); goto left;}
      if (ch==77){PUSH_KEY(77,00); goto left;}
	if((ch==0x47)&&(MenAct[PointRet] >= 0)) goto h_ome;
	  if((ch==0x4F)&&(MenAct[PointRet] >= 0)) goto e_nd;
    if((ch==80)&&(MenAct[PointRet] >= 0)){
	  if(PointRet < LastElm){
	      NegTabX(StartX,StartY+StatY,MaxLenMen,ColorNorm);
	      if(MenAct[PointRet] > -1)
	       NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChNorm);
	      OldStatY=StatY;
	      OldPoint=PointRet;
	      StatY+=StepDet;
	      PointRet++;
	      while((MenAct[PointRet] < 0)&&(PointRet < LastElm)){
		StatY+=StepDet;
		PointRet++;
	      }
	     if(MenAct[PointRet] < 0){
	      StatY=OldStatY;
	      PointRet=OldPoint;
	     }
	     ClearStringX(StartMesX,StartMesY,80-StartMesX);
	     PrintString(StartMesX,StartMesY,MenStrMes[PointRet],ColorNorm);
	     NegTabX(StartX,StartY+StatY,MaxLenMen,ColorInver);
	     if(MenAct[PointRet] > -1)
	      NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChInver);
	  }else{
	     h_ome:
	     NegTabX(StartX,StartY+StatY,MaxLenMen,ColorNorm);
	     if(MenAct[PointRet] > -1)
	      NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChNorm);
	     if(MenAct[PointRet] >= 0){
	      PointRet = NachElm;
	      StatY = NachLen; /* Начальная коорд. Y1 */
	     }
	     ClearStringX(StartMesX,StartMesY,80-StartMesX);
	     PrintString(StartMesX,StartMesY,MenStrMes[PointRet],ColorNorm);
	     NegTabX(StartX,StartY+StatY,MaxLenMen,ColorInver);
	     if(MenAct[PointRet] > -1)
	      NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChInver);
	  }
    }

   if((ch==72)&&(MenAct[PointRet] >= 0)){
       if(PointRet > NachElm){
	  NegTabX(StartX,StartY+StatY,MaxLenMen,ColorNorm);
	  if(MenAct[PointRet] > -1)
	    NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChNorm);
	  OldStatY=StatY;
	  OldPoint=PointRet;
	  StatY-=StepDet;
	  PointRet--;
	      while((MenAct[PointRet] < 0)&&(PointRet > NachElm)){
		StatY-=StepDet;
		PointRet--;
	      }
	    if(MenAct[PointRet] < 0){
	      StatY=OldStatY;
	      PointRet=OldPoint;
	     }
	    ClearStringX(StartMesX,StartMesY,80-StartMesX);
	    PrintString(StartMesX,StartMesY,MenStrMes[PointRet],ColorNorm);
	    NegTabX(StartX,StartY+StatY,MaxLenMen,ColorInver);
	    if(MenAct[PointRet] > -1)
	      NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChInver);
	  }else{
	    e_nd:
	    NegTabX(StartX,StartY+StatY,MaxLenMen,ColorNorm);
	    if(MenAct[PointRet] > -1)
	     NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChNorm);
	    if(MenAct[PointRet] >= 0){
	      PointRet = LastElm;
	      StatY = KonLen; /* Конечная коорд. Y1 */
	    }
	    ClearStringX(StartMesX,StartMesY,80-StartMesX);
	    PrintString(StartMesX,StartMesY,MenStrMes[PointRet],ColorNorm);
	    NegTabX(StartX,StartY+StatY,MaxLenMen,ColorInver);
	    if(MenAct[PointRet] > -1)
	    NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChInver);
       }
   }
 }else{
     if(((ch >= 'A') && (ch <= 'z')) ||
       ((ch >= 'А') && (ch <= 'ё'))){
	  for(i=0;i <= KolElm;i++){
	    if(MenAct[i] > -1){
	      if((CharUp(ch)==MenStr[i][MenAct[i]+1])
		||(CharDown(ch)==MenStr[i][MenAct[i]+1])){
	      NegTabX(StartX,StartY+StatY,MaxLenMen,ColorNorm);
	      if(MenAct[PointRet] > -1)
	      NegTabX(StartX+1+MenAct[PointRet],StartY+StatY,1,ColorChNorm);
	      PointRet = i;
	      StatY = i*StepDet;
	      NegTabX(StartX,StartY+StatY,MaxLenMen,ColorInver);
	      ClearStringX(StartMesX,StartMesY,80-StartMesX);
	      PrintString(StartMesX,StartMesY,MenStrMes[PointRet],ColorNorm);
	      goto e_nter;
	      }
	    }
	  }
	}
  if(ch==27){
   e_sc:
   *DropPoint=PointRet;
   *(DropPoint+1)=StatY;
   *(DropPoint+2)=1;
   goto ExitProg;
  }
   if((ch==13)&&(MenAct[PointRet] >= 0)){
   e_nter:
   *DropPoint=PointRet;
   *(DropPoint+1)=StatY;
   *(DropPoint+2)=0;
   goto ExitProg;
  }
 }
goto begin;
 left:
   *DropPoint=PointRet;
   *(DropPoint+1)=StatY;
   *(DropPoint+2)=2;
   goto ExitProg;
ExitProg:;
RestTextNorm(StartX-2,StartY-1,StartX+MaxLenMen+3,LastLen+StartY+2,BufTextOne);
free(BufTextOne);
}