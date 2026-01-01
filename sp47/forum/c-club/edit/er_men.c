int ermenu(x1,y1,kol,men,act,det,xm,ym,mmes,
	     color_norm,color_inver,color_chnorm,
		    color_chinver,color_shad,color_shadoff)
char *men[],*mmes[];
int x1,y1,kol,act[],det,xm,ym;
int color_norm,color_inver,
      color_chnorm,color_chinver,
	 color_shad,color_shadoff;
{
int  naclen, konx=0;
int  stax=0, point=0;
char ch;
register int i, j, ij;
   for(i=0,j=0;j <= kol;i+=det+strlen(men[j]),j++){
       stshadow(x1+i,y1,men,color_norm,
	     color_chnorm,color_shad,act,j);
   }
     for(i=0;i<kol;i++)konx+=strlen(men[i])+det;
     konx+=x1;
     naclen = strlen(men[point]);
     NEGTAB(y1,x1+stax,naclen,color_inver);
     if(act[point]!=-1){
	NEGTAB(y1,x1+stax+1+act[point],1,color_chinver);
     }
     PrintString(xm,ym,mmes[point],color_norm);
  begin:
	ch=getch();
	  if (ch==0){
	   ch=getch();
	   if (ch==0x47){
	    goto h_ome;
	   }
	   if (ch==0x4F){
	    goto e_nd;
	   }
	     if (ch==77){
	       if (point < kol){
		    naclen = strlen(men[point]);
		    NEGTAB(y1,x1+stax  ,naclen,color_norm);
		    if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chnorm);
		    }
		    stax+=det+naclen;
		    point++;
                    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    NEGTAB(y1,x1+stax  ,naclen,color_inver);
		    if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chinver);
		    }
	       }else{
		 h_ome:
		    naclen = strlen(men[point]);
		    NEGTAB(y1,x1+stax  ,naclen,color_norm);
		    if(act[i]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chnorm);
		    }
		    point = 0;
		    stax=0;
                    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    NEGTAB(y1,x1+stax  ,naclen,color_inver);
		    if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chinver);
		    }
	    }
	  }
	   if (ch==80) goto e_nter;
	   if (ch==75){
	       if (point > 0){
		    naclen = strlen(men[point]);
		    NEGTAB(y1,x1+stax  ,naclen,color_norm);
		    if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chnorm);
		    }
		    point--;
                    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    stax-=det+naclen;
		    NEGTAB(y1,x1+stax  ,naclen,color_inver);
		    if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chinver);
		    }
	       }else{
		 e_nd:
		    naclen = strlen(men[point]);
		    NEGTAB(y1,x1+stax  ,naclen,color_norm);
		    if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chnorm);
		    }
		    point = kol;
		    stax = konx-x1 ;/* Конечная коорд. Х1 */
                    PrintString(xm,ym,mmes[point],color_norm);
		    naclen = strlen(men[point]);
		    NEGTAB(y1,x1+stax  ,naclen,color_inver);
		    if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chinver);
		    }
	    }
	  }
	 }else{
	   if ((ch >= 65) && (ch <= 122)){
	     for(i=0;i<=kol;i++){
	      if(act[i]!=-1){
		if((tolower(ch)==men[i][act[i]+1])
		    ||(toupper(ch)==men[i][act[i]+1])){
		  naclen = strlen(men[point]);
		 NEGTAB(y1,x1+stax  ,naclen,color_norm);
		  if(act[point]!=-1)
		    NEGTAB(y1,x1+stax+1+act[point],1,color_chnorm);

		 point = i;
		 stax=0;
                 PrintString(xm,ym,mmes[point],color_norm);
		 for(ij=0;ij<i;ij++)stax+=strlen(men[ij])+det;
		 naclen = strlen(men[point]);
		 NEGTAB(y1,x1+stax  ,naclen,color_inver);
		   if(act[point]!=-1){
		     NEGTAB(y1,x1+stax+1+act[point],1,color_chinver);
		   }
		 goto e_nter;
		}
	       }
	     }

	   }
	   if (ch==27){
	     return 1;
	   }
	   if (ch==13){
	    e_nter:
             ClearBox((x1-1)+stax,y1-1,x1+stax+naclen,y1+1,
                      0x00,color_shadoff);
	     stshadow(x1+stax+1,y1,men,color_inver,
		   color_chinver,color_shadoff,act,point);
	       delay(200);
	       return  point;
	   }
	 }
   goto begin;
}
