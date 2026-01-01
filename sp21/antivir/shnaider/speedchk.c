/*   АТОЭНЕРГОПРОЕКТ  */
/*   Шнайдер Л.С.     */
/*   г.Киев           */
/*   тел. 274-91-87   */
/**********************/
#include<stdio.h>
#include<stdlib.h>
#include<dos.h>
#include<dir.h>
#include<string.h>
#define maxl 80
main(argc,argv)
int argc;
char *argv[];
{
  struct ffblk ffblk;
  int i,j,done,i1,ii,ppp,nn;
  char *ik;
  char ch,c1,c2;
  char p[2];
  unsigned char name[60];                       /* files name (with PATH)  */
  unsigned char razmer[12];                              /* size checksum  */
  unsigned  long sum,sum1,n1,n2;
  unsigned char text[80];
  char tex1[80],tex2[80];
  long  raz;
  unsigned long c;
  unsigned char fname[60];
  unsigned char fsprav[60];
  unsigned char buf[512];                                  /* file buffer  */
  FILE *fp,*fopen();
  FILE *fs;
  printf(" TEST VIRUS\n\n JUST A MOMENT, PLEASE!\n");
  for(i=0;i<60;i++)
  name[i]=' ' ;
  p[0]=*argv[2]; p[1]='\0';
  if(p[0]=='y')                                 /* create reference file */
    {
      fs=fopen(argv[1],"w");
      fclose(fs);
    }
  if((fs=fopen(argv[1],"a"))==NULL)
    {
      printf("\n can't  open  file %s \n",argv[1]);
      goto m1;
    }
  p[0]=*argv[3];   p[1]='\0';
  if(p[0]=='d')                                        /* selection mode */
    {
      printf("directory listing %s\n",argv[4]);
      nn=0;
      sprintf(tex1,"%s",argv[4]);
      for(j=0;j<80;j++)
       if(tex1[j]=='\0') break;
       else
       if(tex1[j]=='\\') nn=j+1;
      done=findfirst(argv[4],&ffblk,FA_HIDDEN|FA_SYSTEM) ;
       while(!done)
         {
           for(j=0;j<60;j++)
           text[j]=' ';
           sprintf(text,"%s",ffblk.ff_name);
           if(nn!=0)
            {
              strncpy(tex2,tex1,nn);tex2[nn]='\0'; strcat(tex2,text);
              strcpy(text,tex2);
            }
           printf("text=:%s \n",text);
           done=findnext(&ffblk);
           i=0;
            while((ch=text[i])!='\0')
            {
              fname[i]=text[i]; i=i+1;
            }
           fname[i]='\0'; text[i]=' ';
            if((fp=fopen(fname,"rb"))==NULL)
            {
              printf("can't open file %s",fname);
              fclose(fp);
              goto m4;
            }
           sum1=0;ppp=0;
   m20:;   sum=0; for(j=0;j<512;j++) buf[j]=' ';         /* checking sum  */
           fread(buf,sizeof(char),512,fp);
           for(j=0;j<512;j++)
            {
              c=buf[j];
              sum=sum+c;
            }
           sum1=sum1+sum;
             if(ppp!=1)
            {
              c1=buf[0];c2=buf[1];
               if(c1=='M'&&c2=='Z')                     /* mode .EXE file */
                {
                  n1=(buf[9]*256+buf[8])/32-1;         /*  size of hidder */
                  for(j=0;j<n1;j++)
                   {
                     fread(buf,sizeof(char),512,fp);
                   }
                  ppp=1; goto m20;
                }
             }
           i=i+1;
           sprintf(razmer,"%lu",sum1);
           ch=' '; j=0;
            while((ch=razmer[j])!='\0')
             {
               text[i]=razmer[j]; i++;j++;
             }
           text[i]='\n';
           i=i+1;  text[i]='\0';
           fprintf(fs,"%s",text);
   m4:;
           fclose(fp);
         }
        goto m1;
    }                                                  /* end mode create */
  fclose(fs); fs=fopen(argv[1],"r");                    /* mode checking  */
 m2: ik=fgets(text,maxl,fs);
  if(ik==NULL) goto m1;
  i=0;
   while((ch=text[i])!=' ')
    {
      name[i]=text[i];
      i=i+1;
    }
   name[i]='\0';
    if((fp=fopen(name,"rb"))==NULL)
     {
       printf("\n can't open file %s",name);
       goto m1;
     }
/***********************/
 m5:;
  i=i+1; j=0;ch=' ';
   while((ch=text[i])!='\n')
    {
      razmer[j]=text[i]; j=j+1; i=i+1;
    }
   razmer[j]='\0';
   raz=atol(razmer);  ppp=0; sum1=0;
 m10:;
   sum=0; for(i=0;i<512;i++) buf[i]=' ';                  /* checking sum  */
   fread(buf,sizeof(char),512,fp);
    for(i=0;i<512;i++)
      {
        c=buf[i];
        sum=sum+c;
      }
    sum1=sum1+sum;
     if(ppp!=1)
       {
         c1=buf[0];c2=buf[1];
          if(c1=='M'&&c2=='Z')
            {
              n1=(buf[9]*256+buf[8])/32-1;
               for(j=0;j<n1;j++) fread(buf,sizeof(char),512,fp);
                ppp=1; goto m10;
            }
       }
      if(raz!=sum1)
        {
          printf("\n FILE %s ERROR(VIRUS) \n for CONTINUE press ENTER",name);
          ch=getchar();
          fclose(fp);goto m2;
        }
      fclose(fp);goto m2;
 m1:;
      printf("\n END \n");
      fclose(fs);
}
