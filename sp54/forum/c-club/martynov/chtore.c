void fortran retoch(float *val,char *str)
{ float aval;
  int i,order,pset,count;
  long mant;
  for(i=0;i<12;i++) str[i]=' ';
  aval=*val;
  if(aval<0.)
    aval=-aval;
  order=0;
  if(aval>0.)
    { while(aval>=1.)
	{ aval/=10.;
	  order++;
	}
      while(aval<0.1)
	{ aval*=10.;
	  order--;
	}
    }
  if(order<8 && order>(-3))
    { count=12;
      pset=1;
      mant=aval*1.e7+0.51;
      while(count>1 && (mant || pset))
	{ i=mant%10;
	  mant/=10;
	  if((++order==8) && count>1)
	    { str[--count]='.';
	      pset=0;
	    }
	  str[--count]=i|'0';
	}
      if(*val<0.)
	str[--count]='-';
      while(str[11]=='0')
	{ for(i=11;i>0;i--)
	    str[i]=str[i-1];
	  str[0]=' ';
	}
    }
  else
    { if(*val<0.)
	str[0]='-';
      mant=aval*1e6+0.51;
      if(mant>=1000000L)
	{ mant/=10;
	  order++;
	}
      for(count=7;count>0;count--)
	{ i=mant%10;
	  mant/=10;
	  if(count==2)
	    str[count--]='.';
	  str[count]=i|'0';
	}
      str[8]='E';
      str[9]='+';
      if(--order<0)
	{ str[9]='-';
	  order=-order;
	}
      str[10]=(order/10)|'0';
      str[11]=(order%10)|'0';
   }
}

void fortran chtore(char *str,float *val)
{ int i,order,iford,sigval;
  float p;
  *val=0.;
  p=-1.;
  order=iford=0;
  sigval=1;
  for(i=0;i<48 && str[i];i++)
    switch(str[i])
      { case 'E':
	case 'e': iford=1;
		  break;
	case '-': if(iford)
		    iford=-iford;
		  else
		    sigval=-sigval;
		  break;
	case '.': p=0.1;
		  break;
	default:  if(str[i]<'0' || str[i]>'9')
		    break;
		  if(iford)
		    order=order*10+(str[i]&0x0F);
		  else
		    { if(p<0.)
			*val=*val*10.+(str[i]&0x0F);
		      else
		        { *val+=p*(str[i]&0x0F);
			  p*=0.1;
			}  
		    }
      }
  *val*=sigval;
  if(iford)
    { order%=100;
      for(i=0;i<order;i++)
	if(iford>0)
	  *val*=10.;
	else
	  *val/=10;
    }
}
