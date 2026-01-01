void fortran intoch(long *val,char *str)
{ long aval;
  int i;
  for(i=0;i<12;i++) str[i]=' ';
  aval=*val;
  if(aval<0)
    aval=-aval;
  i=11;
  do
    { str[i--]=(aval%10)|'0';
      aval/=10;
    }
  while(i>0 && aval);
  if(*val<0)
    str[i]='-';
}
void fortran chtoin(char *str,long *val)
{ int i,sign;
  char j;
  sign=1;
  *val=0;
  for(i=0;i<12 && (j=str[i])>0;i++)
    { if(j=='-')
	sign*=(-1);
      if(j>='0' && j<='9')
	*val=*val*10+(j-'0');
    }
  *val*=sign;
}
