void HorMen(int x1,int y1,int kol,char *men[],
	   int act[],int det,int xm,int ym,char *mmes[],
	   int color_norm,int color_inver,int color_chnorm,
	   int color_chinver,int *Drop,int DownKey[],int *DownDrop){
int naclen,konx = 0, i, j;
int stax, point;
int MaxLenMes, Elm1;
char ch;
 point=*Drop; stax=*(Drop+1);
   for(i=0,j=0;j <= kol;i+=det+strlen(men[j]),j++){
     PrintString(x1+i,y1,men[j],color_norm);
     if(act[j]!=-1){
      NegTabX(x1+i+1+act[j],y1,1,color_chnorm);
     }
   }
     for(i=0;i < kol;i++)konx+=strlen(men[i])+det;
     konx+=x1;
     naclen = strlen(men[point]);
     NegTabX(x1+stax,y1,naclen,color_inver);
     if(act[point]!=-1){
	NegTabX(x1+stax+1+act[point],y1,1,color_chinver);
     }
     ClearStringX(xm,ym,80-xm);
     PrintString(xm,ym,mmes[point],color_norm);
  begin:
	ch=getch();
	 if (ch==0){
	   ch=getch();
	   if (ch==0x47) goto h_ome;
	    if (ch==0x4F) goto e_nd;
	     if (ch==77){
	       if (point < kol){
		    naclen = strlen(men[point]);
		    NegTabX(x1+stax,y1,naclen,color_norm);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chnorm);
		    }

		    stax+=det+naclen;
		    point++;
		    ClearStringX(xm,ym,80-xm);
		    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    NegTabX(x1+stax,y1,naclen,color_inver);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chinver);
		    }
		    if((*(DownDrop+2)>=2)
		    &&(DownKey[point]!=-1)){
		     goto e_nter;
		    }
	       }else{
		 h_ome:
		    naclen = strlen(men[point]);
		    NegTabX(x1+stax,y1,naclen,color_norm);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chnorm);
		    }
		    point = 0;
		    stax=0;
		    ClearStringX(xm,ym,80-xm);
		    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    NegTabX(x1+stax,y1,naclen,color_inver);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chinver);
		    }
		    if((*(DownDrop+2)>=2)
		    &&(DownKey[point]!=-1)){
		     goto e_nter;
		    }
	    }
	  }
	   if (ch==80) goto e_nter;
	   if (ch==75){
	       if (point > 0){
		    naclen = strlen(men[point]);
		    NegTabX(x1+stax,y1,naclen,color_norm);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chnorm);
		    }
		    point--;
		    ClearStringX(xm,ym,80-xm);
		    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    stax-=det+naclen;
		    NegTabX(x1+stax,y1,naclen,color_inver);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chinver);
		    }
		    if((*(DownDrop+2)>=2)
		    &&(DownKey[point]!=-1)){
		     goto e_nter;
		    }
	       }else{
		 e_nd:
		    naclen = strlen(men[point]);
		    NegTabX(x1+stax,y1,naclen,color_norm);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chnorm);
		    }
		    point = kol;
		    stax = konx-x1 ;/* Конечная коорд. Х1 */
		    ClearStringX(xm,ym,80-xm);
		    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    NegTabX(x1+stax,y1,naclen,color_inver);
		    if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chinver);
		    }
		    if((*(DownDrop+2)>=2)
		    &&(DownKey[point]!=-1)){
		     goto e_nter;
		    }
	    }
	  }
	 }else{
	 if(((ch >= 'A') && (ch <= 'z')) ||
	    ((ch >= 'А') && (ch <= 'ё'))){
	     for(i=0;i<=kol;i++){
	      if(act[i]!=-1){
		if((CharUp(ch)==men[i][act[i]+1])
		  ||(CharDown(ch)==men[i][act[i]+1])){
		  naclen = strlen(men[point]);
		 NegTabX(x1+stax,y1,naclen,color_norm);
		  if(act[point]!=-1)
		    NegTabX(x1+stax+1+act[point],y1,1,color_chnorm);
		 point = i;
		 stax=0;
		 ClearStringX(xm,ym,80-xm);
		 PrintString(xm,ym,mmes[point],color_norm);
		 for(j=0;j<i;j++)stax+=strlen(men[j])+det;
		 naclen = strlen(men[point]);
		 NegTabX(x1+stax,y1,naclen,color_inver);
		   if(act[point]!=-1){
		     NegTabX(x1+stax+1+act[point],y1,1,color_chinver);
		   }
		 goto e_nter;
		}
	       }
	     }
	   }
      if (ch==27){
	 *Drop = point;
	 *(Drop + 1) = stax;
	 *(Drop + 2) = 1;
	 goto ExitProg;
      }
	   if (ch==13){
	    e_nter:
	       *Drop = point;
	       *(Drop + 1) = stax;
	       *(Drop + 2) = 0;
	       goto ExitProg;
	   }
	 }
   goto begin;
ExitProg:;
 NegTabX(x1,y1,konx,color_norm);
 NegTabX(x1+stax,y1,naclen,color_inver);
}