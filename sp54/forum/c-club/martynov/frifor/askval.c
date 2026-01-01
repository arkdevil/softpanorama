void fortran wrtext();
void fortran rdtext();
void fortran chattr();
void fortran scrlup();
void fortran scrldn();
void fortran getkey();
void fortran retoch();
void fortran chtore();
void fortran askval(int *x,int *y,int *dx,int *dy,char *sa1,char *sa2,
		int *linnum,float *val,long *lchar,char *lines,int *linlg)
{ int i,j,xx,yy,lg,sn,bp,corr;
  static int snc[1024];
  unsigned char buf[48],chval[12],scan,inkey,sym;
  yy=*y;
  sn=0;
  for(i=0;i<*linnum;i++)
    { snc[i]=sn++;
      if(lchar[i]>4)
	sn+=(lchar[i]-1)/4;
    }
  for(i=0;i<*dy && i<*linnum;i++)
    { wrtext(lines+i*(*linlg),linlg,x,&yy,dx,sa1);
      if(lchar[i])
	for(j=0;j<12;j++)
	  { if(j<lchar[i])
	      sym=((char*)(val+snc[i]))[j];
	    else
	      sym=' ';
	    if(sym<' ') sym=' ';
	    buf[j]=sym;
	  }
      else
	retoch(val+snc[i],buf);
      xx=*x+*linlg+1;
      lg=12;
      wrtext(buf,&lg,&xx,&yy,&lg,sa1);
      yy++;
    }
  corr=bp=sn=0;
  yy=*y;
  chattr(&lg,&xx,&yy,sa2);
  do
    { j=1;
      getkey(&scan,&inkey);
      if(inkey>=' ')
	{ if(bp==0)
	    { rdtext(buf,&lg,&xx,&yy);
	      xx+=13;
	      wrtext(buf,&lg,&xx,&yy,&lg,sa1);
	      xx-=13;
	      for(i=0;i<48;i++)
		buf[i]=' ';
	    }
	  if(lchar[sn]==0 && inkey!=' ' && inkey!='E' && inkey!='e'
	       && (inkey<'0' || inkey>'9') && inkey!='+'
	       && inkey!='-' && inkey!='.')
	    _asm /* beep */
	      { sub  bx,bx
		mov  ax,0E07h
		int  10h
	      }
	  else
	    { for(i=0;i<47;i++)
		buf[i]=buf[i+1];
	      buf[47]=inkey;
	      if(bp<48) bp++;
	      corr=1;
	    }
	}
      if(inkey==8 && bp) /*Backspace*/
	{ for(i=47;i>0;i--)
	    buf[i]=buf[i-1];
	  buf[0]=' ';
	  bp--;
	}
      if(inkey==0x0D) /*Enter*/
	{ scan=80;
	  inkey=0;
	}
      if(inkey==0x1B) /*Esc*/
	inkey=0;
      if(corr)
	wrtext(buf+36,&lg,&xx,&yy,&lg,sa2);
      if(inkey==0)
	{ if(corr)
	    { xx+=13;
	      rdtext(chval,&lg,&xx,&yy);
	      xx-=13;
	      wrtext(chval,&lg,&xx,&yy,&lg,sa2);
	      corr=0;
	    }
	  if(bp)
	    { if(lchar[sn])
		{ for(i=0;i<lchar[sn];i++)
		    { if(i<bp)
			sym=buf[48-bp+i];
		      else
			sym=' ';
		      ((char*)(val+snc[sn]))[i]=sym;
		    }
		  for(i=0;i<12;i++)
		    { if(i<lchar[sn])
			sym=((char*)(val+snc[sn]))[i];
		      else
			sym=' ';
		      if(sym<' ') sym=' ';
		      buf[i]=sym;
		    }
		}
	      else
		{ chtore(buf,val+snc[sn]);
		  retoch(val+snc[sn],buf);
		}
	      wrtext(buf,&lg,&xx,&yy,&lg,sa2);
	      bp=0;
	    }
	  else
	    { xx+=13;
	      if(corr)
		wrtext("            ",&lg,&xx,&yy,&lg,sa1);
	      xx-=13;
	    }
	  switch(scan)
	    { case 73: j=*dy+(yy-*y); /*PgUp*/
	      case 72: for(i=0;i<j;i++)
	      /*Up*/     if(yy>*y)
			   { chattr(&lg,&xx,&yy,sa1);
			       yy--;sn--;
			     chattr(&lg,&xx,&yy,sa2);
			   }
			 else
			   if(sn>0)
			     { sn--;
			       scrldn(lines+sn*(*linlg),linlg,x,y,dx,dy);
			       if(lchar[sn])
				 for(j=0;j<12;j++)
				   { if(j<lchar[i])
				       sym=((char*)(val+snc[sn]))[j];
				     else
				       sym=' ';
				     if(sym<' ') sym=' ';
				     buf[j]=sym;
				   }
			       else
				 retoch(val+snc[sn],buf);
			       wrtext(buf,&lg,&xx,&yy,&lg,sa2);
			     }
		       break;
	      case 81: j=*dy+(*dy-(yy-*y)-1); /*PgDn*/
	      case 80: for(i=0;i<j;i++)
	      /*Dn*/     if(yy<(*y+*dy-1))
			   { chattr(&lg,&xx,&yy,sa1);
			     yy++;sn++;
			     chattr(&lg,&xx,&yy,sa2);
			   }
			 else
			   if(sn<*linnum-1)
			     { sn++;
			       scrlup(lines+sn*(*linlg),linlg,x,y,dx,dy);
			       if(lchar[sn])
				 for(j=0;j<12;j++)
				   { if(j<lchar[i])
				       sym=((char*)(val+snc[sn]))[j];
				     else
				       sym=' ';
				     if(sym<' ') sym=' ';
				     buf[j]=sym;
				   }
			       else
				 retoch(val+snc[sn],buf);
			       wrtext(buf,&lg,&xx,&yy,&lg,sa2);
			     }
		       break;
	    }
	}
    }
  while(scan!=0x01);
}
