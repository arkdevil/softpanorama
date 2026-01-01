void fortran wrtext();
void fortran chattr();
void fortran scrlup();
void fortran scrldn();
void fortran getkey();
void fortran vmenu(int *x,int *y,int *dx,int *dy,char *lines,int *linlg,
			int *linnum,char *sa1,char *sa2,long *selnum)
{ int i,j,yy,sn;
  unsigned char scan,inkey;
  yy=*y;
  for(i=0;i<*dy && i<*linnum;i++)
    { wrtext(lines+i*(*linlg),linlg,x,&yy,dx,sa1);
      yy++;
    }
  sn=0;
  yy=*y;
  chattr(dx,x,&yy,sa2);
  do
    { j=1;
      getkey(&scan,&inkey);
      switch(scan)
	{ case 28: goto ret; /*Enter*/
	  case 73: j=*dy+(yy-*y); /*PgUp*/
	  case 72: for(i=0;i<j;i++)
	  /*Up*/     if(yy>*y)
		       { chattr(dx,x,&yy,sa1);
			   yy--;sn--;
			 chattr(dx,x,&yy,sa2);
		       }
		     else
		       if(sn>0)
			 { sn--;
			   scrldn(lines+sn*(*linlg),linlg,x,y,dx,dy);
			 }
		   break;
	  case 81: j=*dy+(*dy-(yy-*y)-1); /*PgDn*/
	  case 80: for(i=0;i<j;i++)
	  /*Dn*/     if(yy<(*y+*dy-1))
		       { chattr(dx,x,&yy,sa1);
			 yy++;sn++;
			 chattr(dx,x,&yy,sa2);
		       }
		     else
		       if(sn<*linnum-1)
			 { sn++;
			   scrlup(lines+sn*(*linlg),linlg,x,y,dx,dy);
			 }
		   break;
	}
    }
  while(inkey!=0x1B);
  sn=-1;
  ret:*selnum=++sn;
}
void fortran svmenu(int *x,int *y,int *dx,int *dy,char *lines,int *linlg,
		    int *linnum,char *sa1,char *sa2,long *selnum)
{ int i,j,k,yy,xsel,sn;
  unsigned char scan,inkey,sel,uns;
  sel='√';uns=' ';
  yy=*y;xsel=*x+*dx-1;
  j=1;
  for(i=0;i<*dy && i<*linnum;i++)
    { wrtext(lines+i*(*linlg),linlg,x,&yy,dx,sa1);
      if(*(selnum+i))
	wrtext(&sel,&j,&xsel,&yy,&j,sa1);
      else
	wrtext(&uns,&j,&xsel,&yy,&j,sa1);
      yy++;
    }
  sn=0;
  yy=*y;
  chattr(dx,x,&yy,sa2);
  do
    { j=1;
      getkey(&scan,&inkey);
      switch(scan)
	{ case 28: /*Enter*/
	  case 57: /*SPACE*/
	  case 82: if(*(selnum+sn))
	  /*Ins*/    { *(selnum+sn)=0;
		       wrtext(&uns,&j,&xsel,&yy,&j,sa2);
		     }
		   else
		     { *(selnum+sn)=1;
		       wrtext(&sel,&j,&xsel,&yy,&j,sa2);
		     }
		   goto down;
	  case 73: j=*dy+(yy-*y); /*PgUp*/
	  case 72: for(i=0;i<j;i++)
	  /*Up*/     if(yy>*y)
		       { chattr(dx,x,&yy,sa1);
			   yy--;sn--;
			 chattr(dx,x,&yy,sa2);
		       }
		     else
		       if(sn>0)
			 { sn--;
			   scrldn(lines+sn*(*linlg),linlg,x,y,dx,dy);
			   k=1;
			   if(*(selnum+sn))
			     wrtext(&sel,&k,&xsel,&yy,&k,sa2);
			 }
		   break;
	  case 81: j=*dy+(*y+*dy-yy-1); /*PgDn*/
	  case 80: down: for(i=0;i<j;i++)
	  /*Dn*/     if(yy<(*y+*dy-1))
		       { chattr(dx,x,&yy,sa1);
			 yy++;sn++;
			 chattr(dx,x,&yy,sa2);
		       }
		     else
		       if(sn<*linnum-1)
			 { sn++;
			   scrlup(lines+sn*(*linlg),linlg,x,y,dx,dy);
			   k=1;
			   if(*(selnum+sn))
			     wrtext(&sel,&k,&xsel,&yy,&k,sa2);
			 }
		   break;
	}
    }
  while(inkey!=0x1B);
  ret:;
}
