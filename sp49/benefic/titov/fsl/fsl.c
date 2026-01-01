/*                    FILMFILE INTERPRETER (LISP subset)          */
/*                    ----------------------------------          */
/*                    (C) A Titov,1992                            */

#include <nutil.h>
/*  Def in nutil.h - NortonTools used in contexts: /delay/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
*/

#include "FSL.H"

/*                    SCANNER VARIABLES                       */
/*                    -----------------                       */
char curchr;          /* Cur. char scnning */
int  curlex;          /* His typ          */
int  curpos;          /* His pos 0..instrlen */
int  instrlen;        /* Input string length */
int  errcount;        /* Err count in cur. string */
int  comperr;         /* Error presence in source text */
char errmark[maxinstrlen];  /* Error marking subscript string */
char errset[maxinstrlen];   /* Cur string error occuring codes */
char instring[maxinstrlen]; /* Input string for hardcopy listing */
FILE *instream;            /* Source text */
FILE *outstream;           /* Listing */
char *inFILE, *lstfile;    /* FILE names */
int inend;                 /* YES if input eof (-1 during get) occurs */
element *rootelement;      /* frame fsubr containing root element */

/*                    MODEL BUILDING VARS                     */
/*                    -------------------                     */
object *firstel;  /* 1st  object-table element */

/*                    RUN-TIME       VARS                     */
/*                    -------------------                     */
int frameerr;           /* YES if was errors during framecution */
int prepared [Sver][Shor];  /* Two compared before sending screens */
int displayed[Sver][Shor];
int absX,absY,absZ;
layer *world;        /* List of layers (Y.sprites.next) */

/*                    LINKER         VARS                     */
/*                    -------------------                     */
int linkerr;          /* YES if was errors during linking   */
int excount;


void *allocmem(siz)
int siz;
{
 void *addr;
 addr=malloc(siz);
 if (((int)addr)==0)
 {
    printf("\nNot enough memory to run FreeStyLISP\n");
    fprintf(outstream,"\nNot enough memory to run FreeStyLISP\n");
    exit(8);
 };
 return(addr);
};

/*                    MAIN PROGRAM                            */
/*                    ------------                            */
void main(argc,argv)
int argc;
char *argv[];
{
  void program();
  void link();
  void iniscan();
  void outerrs();
  object *val();
  object *result;
  void listvar();
  void frame();
  element *newelement();
  object *newobject();
  void listall();
  object *nd;

  if (argc<3)
  {
      printf("FreeStyLISP interpreter usage: L infile listfile\n");
      exit(0);
  };

  inFILE=strdup(argv[1]);
  lstfile=strdup(argv[2]);
  iniscan();
  fprintf(outstream,"FreeStyLISP Translator \n\n");
  program(rootelement);
  if (comperr)
  {
    if (errcount>0)
    {
      fprintf(outstream,"<Eof>\n");
      outerrs();
    };
    fprintf(outstream,"Unsuccessful translation \n");
    printf("LISP syntax error(s)\n");
  }
  else
  {
    fprintf(outstream,"\nSuccessful translation\n");
  };
  fclose(instream);
  if (!comperr)
  {
   linkerr=NO;
   if (excount>0) fprintf(outstream,"FreeStyLISP externals Linker\n");
   while (excount>0)
   {
          link(rootelement);
   }
   if ((!linkerr)&&(excount>0))
   {
       fprintf(outstream,"Successful linking\n");
   };
  };
  if ((!comperr)&&(!linkerr))
  {

   /*
       Next 2 operators puts the transl. result to the listing
   fprintf(outstream,"Internal representation: \n");
   listall();
   */

   fprintf(outstream,"FreeStyLISP RunTime  \n\n");

   result=val(rootelement);
   if (!frameerr)
   {
    listvar(result);
   };

  };
  fclose(outstream);
};

void listall()
{
 element* curel;
 void listvar();

 curel=rootelement;
 while(curel!=NULL)
 {
       listvar(curel->car);
       curel=curel->cdr;
 };
};

void listvar(var)
object  *var;
{
element *curel;
 if (var==NULL)
 {
            fprintf(outstream,"NullCAR\n");
 }
 else
 {
 switch (var->typ)
 {
 case listT:
            fprintf(outstream,"LIST:\n(\n");
            curel=(element*)((var->contents).first);
            while (curel!=NULL)
            {
             listvar(curel->car);
             curel=curel->cdr;
            };
            fprintf(outstream,")\n");
            break;
 case stringT:
            fprintf(outstream,"STRING:%s\n",(var->contents).string);
            break;
 case  intT:
            fprintf(outstream,"INTEGER:%d\n",*((var->contents).intv) );
            break;
 case floatT:
            fprintf(outstream,"FLOAT:%f\n",*((var->contents).floatv) );
            break;
 case functT:
            fprintf(outstream,"FSUBR:%s\n",var->string);
            break;
 case extrnT:
            fprintf(outstream,"EXTRN:%s\n",(var->contents).string);
            break;
 case varT:
            fprintf(outstream,"ATOM:%s\n",var->string);
            break;
 default:
            fprintf(outstream,"INTERNAL ERROR\n");
            break;
 };
 };
};
/*                    LINKER       PROGRAMS                    */
/*                    ---------------------                    */
void link(fromelement)
element *fromelement;
{
 element* curel;
 object * curobj;
 object * newobj;
 element*  readfsl();
 element *newel;

 curel=fromelement;
 while(curel!=NULL)
 {
       curobj=curel->car;
       if ((curobj->typ)==listT)
       {
            link( (element*)((curobj->contents).first) );
       }
       else
       {
            if ((curobj->typ)==extrnT)
            {
                 newel=readfsl((curobj->contents).string);
                 excount--;
                 if (newel!=NULL)
                 {
                     curel->car=newel->car;
                     free(newel);
                 }
                 else
                 {
                     curel->car=NULL;
                 };
            };
       };
       curel=curel->cdr;
 };
};

element* readfsl(incname)
char *incname;
{
 element *res;
 element *nel;
 element *newelement();
 void partinit();
 void program();

 res=NULL;
 fprintf(outstream,"Linking: %s\n",incname);
 comperr=NO;
 instream=fopen(incname,"r");
 if (instream!=NULL)
 {
     partinit();
     nel=newelement();
     program(nel);
     res=nel->cdr;
     free(nel);
 }
 else
 {
     linkerr=YES;
     fprintf(outstream,"***Error: %s not found\n\n",incname);
 };
 fclose(instream);
 linkerr=(linkerr || comperr);
 if (linkerr) res=NULL;
 return(res);
};


/*                    FILM DISPLAY PROGRAMS                    */
/*                    ---------------------                    */

void cls()
/* Clear the physical screen */
{

  _asm   push bp  ;
  _asm   push ax  ;
  _asm   push bx  ;
  _asm   push cx  ;
  _asm   push dx  ;
  _asm   push si  ;
  _asm   push di  ;
  _asm   push ds  ;
  _asm   push es  ;
  _asm   pushf    ;
/*
 _asm    mov ah,00h                ;
 _asm    mov al,07h                ;
 _asm    int 10h                   ;
*/
  _asm   popf     ;
  _asm   pop  es  ;
  _asm   pop  ds  ;
  _asm   pop  di  ;
  _asm   pop  si  ;
  _asm   pop  dx  ;
  _asm   pop  cx  ;
  _asm   pop  bx  ;
  _asm   pop  ax  ;
  _asm   pop  bp  ;

};

void send(i,j,spr)
/* Send int spr (integer) to TV : i,j [0..max] */
int i,j;
int spr;
{


  _asm   push bp  ;
  _asm   push ax  ;
  _asm   push bx  ;
  _asm   push cx  ;
  _asm   push dx  ;
  _asm   push si  ;
  _asm   push di  ;
  _asm   push ds  ;
  _asm   push es  ;
  _asm   pushf    ;

  _asm   mov ah,02h                ;
  _asm   mov bh,0                  ;
  _asm   mov cx,i                  ;
  _asm   mov dh,cl                 ;
  _asm   mov cx,j                  ;
  _asm   mov dl,cl                 ;
  _asm   int 10h                   ;
  _asm   mov ah,0ah                ;
  _asm   mov bh,0                  ;
  _asm   mov cx,spr                ;
  _asm   mov al,cl                 ;
  _asm   mov cx,1                  ;
  _asm   int 10h                   ;

  _asm   popf     ;
  _asm   pop  es  ;
  _asm   pop  ds  ;
  _asm   pop  di  ;
  _asm   pop  si  ;
  _asm   pop  dx  ;
  _asm   pop  cx  ;
  _asm   pop  bx  ;
  _asm   pop  ax  ;
  _asm   pop  bp  ;

};

/*                    INTERPRETER PROGRAMS                     */
/*                    --------------------                     */
object *val(listart)  /* Note that this is NOT (val ....) function due to different header */
element *listart;
{
 object *car;
 object *res;

 car=listart->car;
 switch (car->typ)
 {
 case functT:
             (*((car->contents).functv))(listart,&res);
             break;
 case listT:
             res=val((element*)((car->contents).first));
             break;
 default:
             res=car;
             break;
 };
 return(res);
}

/*                    BUILT-IN FUNCTIONS                       */
/*                    ------------------                       */

       /* NO PARAMETERS CHEKING AT ALL ! */

void set(listart,result)
/* (set var value) */
element *listart;
object* *result;
{
 object *varref;
 object *valueref;

 varref=val(listart->cdr);
 valueref=val(listart->cdr->cdr);

 if ( (varref==NULL)||(valueref==NULL) )
 {
    *result=NULL;
 }
 else
 {
    *result=valueref;
    (varref->contents).voidv=(valueref->contents).voidv;
 };
};

void repeat(listart,result)
/* (repeat index from to step program) */
element *listart;
object* *result;
{
 object *indexref;
 object *fromref;
 object *toref;
 object *stepref;
 object *val();
 void frame();
 object *res;
 int index,from,to,step;

 indexref=val(listart->cdr);
 fromref=val(listart->cdr->cdr);
 toref=val(listart->cdr->cdr->cdr);
 stepref=val(listart->cdr->cdr->cdr->cdr);

 from =*(( fromref->contents).intv);
 to   =*((   toref->contents).intv);
 step =*(( stepref->contents).intv);

 index=from;
 *result=NULL;
 while (index<=to)
 {
        *((indexref->contents).intv)=(int)index;
        frame(listart->cdr->cdr->cdr->cdr,&res);
        index+=step;
 };
 *result=res;
};

void clears(listart,result)
element *listart;
object* *result;
{
 int i,j;
 void cls(); /* Physical screen clearing */
 void KillWorld();

 for (i=0;i<Sver;i++)
 {
     for (j=0;j<Shor;j++)
     {
          displayed[i][j]=filler;
          prepared [i][j]=filler;
     };
 };
 KillWorld();

 /* Physical clearing */
 cls();
 *result=NULL;
};

void KillWorld()
{
 layer *curl, *nl;
 sprit *curs, *ns;
 curl=world;
 while(curl!=NULL)
 {
       nl=curl->next;
       curs=curl->sprites;
       while(curs!=NULL)
       {
             ns=curs->next;
             free(curs);
             curs=ns;
       };
       free(curl);
       curl=nl;
 };
 world=NULL;
};

void KillSprites(curl)
layer *curl;
{
 sprit *curs, *ns;

 if (curl!=NULL)
 {
     curs=curl->sprites;
     while(curs!=NULL)
     {
       ns=curs->next;
       free(curs);
       curs=ns;
     };
     curl->sprites=NULL;
 };
};

void namedef(listart,result)
/* (namedef "name" something) */
element *listart;
object* *result;
{
 object *res;
 object *oldobject();
 object *nameref;
 char   *name;
 void   finstall();
 object *val();

 res=NULL;
 nameref=val(listart->cdr);
 if (nameref!=NULL)
 {
    name=(nameref->contents).string;
    res=oldobject(name);
    if (res==NULL)
    {
        finstall(name,listT,listart->cdr->cdr);
    };
    res=oldobject(name);
 };
 *result=res;
};

void byname(listart,result)
/* (byname "name") */
element *listart;
object* *result;
{
 char *name;
 object *nameref;
 object *oldobject();
 object *objres;
 object *val();

 nameref=val(listart->cdr);
 *result=nameref;
 if (nameref!=NULL)
 {
    name=(nameref->contents).string;
    objres=oldobject(name);
    *result=objres;
    if (objres!=NULL)
    {
     *result=val((element*)((objres->contents).first));
    };
 };
};

void sprite(listart,result)
/* (sprite integer) */
element *listart;
object* *result;
{
 object *val();
 int  index;
 object *vref;
 object *val();
 layer *curl;
 sprit *curs;
 int found;
 void KillSprites();

 vref=val(listart->cdr);
 *result=vref;
 if (vref!=NULL)
 {
    index=*((vref->contents).intv);
    found=NO;
    curl=world;  /* Shook layer with this z */
    while ( (!found)&&(curl!=NULL) )
    {
       found=((curl->z)==absZ);
       if (!found) curl=curl->next;
    };
    if ( (found)&&(curl->FirstTry) )
    {
          KillSprites(curl);
    };
    if (!found) /* Then form new layer */
    {
        curl=(layer*)(allocmem(sizeof(layer)));
        curl->sprites=NULL;
        curl->next=world;
        world=curl;
    };

    curl->z=absZ;
    curl->FirstTry=NO;

    /* Is any sprite at (absX,absY) coordinate ? */
    curs=curl->sprites;
    found=NO;
    while ( (!found) && (curs!=NULL) )
    {
            found=(
                   (absX==(curs->x)) && (absY==(curs->y))
                  );
            if (!found) curs=curs->next;
    };
    if (!found)
    {
        curs=(sprit*)allocmem(sizeof(sprit));
        curs->next=curl->sprites;
        curl->sprites=curs;
        curs->x=absX;
        curs->y=absY;
    };
    curs->index=index;
 };
};

void loc(listart,result)
/* (loc x y z frame) */
element *listart;
object* *result;
{
  int savX,savY,savZ;
  object *Xref;
  object *Yref;
  object *Zref;
  object *val();
                     /* No parm checking ! */

  Xref=val(listart->cdr);
  Yref=val(listart->cdr->cdr);
  Zref=val(listart->cdr->cdr->cdr);

  savX=absX;savY=absY;savZ=absZ;

  absX=absX+( *((Xref->contents).intv) );
  absY=absY+( *((Yref->contents).intv) );
  absZ=absZ+( *((Zref->contents).intv) );

  *result=val(listart->cdr->cdr->cdr->cdr);

  absX=savX;absY=savY;absZ=savZ;
};

void view(listart,result)
element *listart;
object* *result;
/* (view)  No parameter absence checking */
/* Compare 2 int-screens & send to TV changed ints */
{
 int i,j;
 int x;   /* x is the sprite index */
 void send();
 void sortlayers();
 void prep();

 sortlayers();

 prep();

 for (i=0;i<Sver;i++)
 {
     for (j=0;j<Shor;j++)
     {
          x=prepared[i][j];
          if (displayed[i][j]!=x)
          {
              send(i,j,x);
              displayed[i][j]=x;
          };
          prepared[i][j]=filler;
     };
 };
 *result=NULL;
};

void sortlayers()
/* sort on z: 0 is nearest  (bubblesort) */
{
 layer *curl;
 int wasswap;
 int z1,z2;
 sprit *spritechain;

 wasswap=YES;
 while (wasswap)
 {
        wasswap=NO;
        curl=world;
        while((curl->next)!=NULL)  /* Note that MaxInts layer always present */
        {
               z1=curl->z;
               z2=curl->next->z;
               if (z2>=z1)
               {
                   curl->z=z2;
                   curl->next->z=z1;
                   spritechain=curl->sprites;
                   curl->sprites=curl->next->sprites;
                   curl->next->sprites=spritechain;
                   wasswap=YES;
               };
               curl=curl->next;
        };
 };
};

void prep()
{
 /* Layer-list is sorted on Z: 0 is nearest */
 layer *curl;
 sprit *curs;
 int i,j;

 curl=world;
 while (curl!=NULL)
 {
   curs=curl->sprites;
   while (curs!=NULL)
   {
      i=curs->x;j=curs->y;
      prepared[i][j]=curs->index;
      curs=curs->next;
   };
   curl->FirstTry=YES;
   curl=curl->next;
 };
};

void frame(listart,result)
element *listart;
object* *result;
{
 object *res;
 element *curel;
 object   *car;
 object *val();

 res=NULL;
 curel=listart->cdr;
 while (curel!=NULL)
 {
  res=val(curel);
  curel=curel->cdr;
 };
 *result=res;
};

void   sub()
{
};

void   add()
{
};

void delay(listart,result)
element *listart;
object* *result;
/* (delay ticks)    Delay execution upon ticks ticks */
{
 object *ticks;
 object *val();

 ticks=val(listart->cdr);
 *result=ticks;
 utsleept((word)(*((ticks->contents).intv)) );
};

/*                    LIST MODEL BUILDING PROGRAMS            */
/*                    ----------------------------            */
object *newobject()
{
 object *newobj;
 newobj=(object*)allocmem(sizeof(object));
 newobj->next=NULL;
 return(newobj);
};

element *newelement()
{
 element *newel;
 newel=(element*)allocmem(sizeof(element));
 newel->car=NULL;
 newel->cdr=NULL;
 return (newel);
};

void copyvch(i,catom,maxl)
/* Limited-length string passing & checkng */
char *catom;
int   maxl;
int *i;
{
  void error();

  if ((*i)<(maxl-2))
  {
     (*i)++;
     catom[*i]=curchr;
  }
  else error(8);
};

object* whatatom(catom)
/* Shook in tables , form typ & contents */
char  *catom;
{
 object* atomobject;
 object* oldobject();
 char *cp;

 cp=catom;
 atomobject=oldobject(cp);
 if (atomobject==NULL)
 {
     atomobject=newobject();
     atomobject->string=cp;
     switch (cp[0])
     {
     case '#':
              atomobject->typ=extrnT;
              excount++;
              (atomobject->contents).string=strdup(strcat(++cp,".fsl"));
              break;
     case '$':
              atomobject->typ=floatT;
              (atomobject->contents).floatv=(float*)(allocmem(sizeof(float)));
              break;
     default:
              atomobject->typ=intT;
              (atomobject->contents).intv=(int*)(allocmem(sizeof(int)));
              break;
     };
     atomobject->next=firstel;
     firstel=atomobject;
 };
 return(atomobject);
};

object* oldobject(catom)
/* Shook in tables , return NULL or object */
char  *catom;
{
 object* curel; /* internal object table element */
 int found;

 curel=firstel;
 found=NO;
 while ( (!found)&&(curel!=NULL) )
 {
  found=!(strcmp(catom,curel->string));
  if (!found) curel=curel->next;
 };
 return(curel);
};

void finstall(fname,ftyp,fref)
/* install new object */
char *fname;
objtype ftyp;
void *fref;
{
  object *new;
  new=newobject();
  new->next=firstel;
  new->typ=ftyp;
  (new->contents).voidv=fref;
  new->string=strdup(fname);
  firstel=new;
};

/*                    SCANNER PROGRAMS                        */
/*                    ----------------                        */
void program(prevelement)
element *prevelement;
/*                     program=  [ term ...] eof          */
{
 object *list();
 element *curel;
 element *newel;
 element *newelement();
 void nextchr();
 void error();

 curel=prevelement;

 while (!ineof())
 {
   if (curchr==space) nextchr();

   newel=newelement(); /*newelement puts nil to cdr,car*/
   newel->car=list();
   newel->cdr=curel->cdr;
   curel->cdr=newel;
   curel=curel->cdr;
   nextchr();
   if (!ineof())
   {
      if ((curchr!=space)&&(curchr!=leftpar)) error(1);
      if (curchr==space) nextchr();
   };
 };
};

object * list()
/*                     list= ( term [ term ...])            */
{
 object *term();
 void error();
 void nextchr();
 object *listobject;
 object *newobject();
 element *newelement();
 element *curel;

 listobject=newobject();
 listobject->typ=listT;
 (listobject->contents).first=(void*)newelement();
 curel=(element*)((listobject->contents).first);

 if (curchr==space) nextchr();
 if (curchr!=leftpar) error(2);
 nextchr();
 if (curchr==space) nextchr();
 curel->car=term();
 if (curchr==space) nextchr();
 while ( (curchr!=rightpar)&&(!ineof()) )
 {
  curel->cdr=newelement();
  curel=curel->cdr;
  curel->car=term();
  if (curchr==space) nextchr();
 };
 if (ineof()) error(3);
 return(listobject);
};

object * term()
/*                      term=  (' list                          */
/*                          alfa' atom                          */
/*                    +-   digit' value                         */
/*                         quote' string                        */
{
 object *atom();
 object *value();
 object *string();
 void nextchr();
 void error();
 object *termobject;

 if (curchr==space) nextchr();
 switch (curlex)
 {
 case leftpar:
              termobject=list();
              nextchr();
              break;
 case alfa:
              termobject=atom();
              break;
 case digit:
              termobject=value();
              break;
 case plus:
              termobject=value();
              break;
 case minus:
              termobject=value();
              break;
 case quote:
              termobject=string();
              nextchr(); /* Next after terminating quote */
              if ( (curchr!=space)&&(curchr!=rightpar)&&(curchr!=leftpar) )error(9);
              break;
 default:
              termobject=NULL;
              error(7);
              nextchr();
              break;
 };
 return(termobject);
};

object * atom()
/*                       atom= alfa [alfa|digit ...]              */
{
 void error();
 void nextchr();
 object *atomobject;
 object *newobject();
 char *catom; /* atom's char representation */
 int i;
 void copyvch();

 catom=(char*)allocmem(maxnamel*sizeof(char));
 i=0;
 catom[i]=curchr;

 if (curlex!=alfa)error(4);
 nextchr();
 while( (curlex==alfa) || (curlex==digit) )
 {
  copyvch(&i,catom,maxnamel);
  nextchr();
 };
 i++;
 catom[i]='\000';
 atomobject=whatatom(catom); /* Shook in tables , form typ & contents */
 return(atomobject);
};

object *value()
/*                        value=[+|-] digit [digit ...] [.[digit ...]]  */
{
 void nextchr();
 object *valueobject;
 object *newobject();
 char *cvalue;
 float *fvalue;
 int *ivalue;
 int i;
 int floatvalue;
 void copyvch();
 void error();

 float *Borland;
 float AlleyCat;
 Borland=&AlleyCat;    /* C++ 2.0 */

 valueobject=newobject();
 cvalue=(char*)allocmem(maxvaluel*sizeof(char));
 i=0;
 floatvalue=NO;
 cvalue[i]=curchr;

 switch (curlex)
 {
  case plus:
       nextchr();
       break;
  case minus:
       nextchr();
       break;
  case digit:
       nextchr();
       break;
 };
 while(curlex==digit)
 {
  copyvch(&i,cvalue,maxvaluel);
  nextchr();
 };
 if (curlex==dot)
 {
  floatvalue=YES;
  copyvch(&i,cvalue,maxvaluel);
  nextchr();
  while(curlex==digit)
  {
   copyvch(&i,cvalue,maxvaluel);
   nextchr();
  };
 };
 if ( (curchr!=space)&&(curchr!=rightpar)&&(curchr!=leftpar) )error(9);
 i++;
 cvalue[i]='\000';
 if (floatvalue)
 {
  fvalue=(float*)allocmem(sizeof(float));
  /*
  *fvalue=(float)utcton(&cvalue);
  */
  sscanf(cvalue,"%f",fvalue);
  valueobject->typ=floatT;
  (valueobject->contents).floatv=fvalue;
 }
 else
 {
  ivalue=(int*)allocmem(sizeof(int));
  /*
  *ivalue=(int)utctoi(&cvalue);
  */
  sscanf(cvalue,"%d",ivalue);
  valueobject->typ=intT;
  (valueobject->contents).intv=ivalue;
 };
 free(cvalue);
 return(valueobject);
};

object * string()
/*                string=quote [each without this quote ...] samequote   */
{
 void error();
 void nextchr();
 object *stringobject;
 object *newobject();
 void copyvch();
 char *cstring;
 int i;
 char q1;

 stringobject=newobject();
 stringobject->typ=stringT;
 cstring=(char*)allocmem(maxstringl*sizeof(char));
 (stringobject->contents).string=cstring;
 i=-1;

 if (curlex!=quote) error(5);
 q1=curchr;
 nextchr();
 while( (!ineof()) && (curchr!=q1) )
 {
  copyvch(&i,cstring,maxstringl);
  nextchr();
 };
 i++;
 cstring[i]='\000';
 if (ineof())error(6);
 return(stringobject);
};

/*                    SERVICE PROGRAMS                        */
/*                    ----------------                        */
int ineof()
{
 return(feof(instream)||inend);
};

void nextchr()
/* -> instring,instrlen,curpos,curchr,curlex */
{
 void flushstr();
 void outerrs();
 int wasblank;

 curchr=fgetc(instream);

 if (curchr==eofchr)
 {
    curlex=eoflex;
    instrlen=1;
    curpos=0;
    inend=YES;
 }
 else  /* this is not eof */
 {
  curlex=curchr;
  wasblank=NO;
  while ( (curchr==eolnchr)||(curchr==' ')||(curchr==tabchr) )
  {
     wasblank=YES; /* eolns,tabs & true blanks are all blanks */
     if (curchr==eolnchr)
     {
        instring[instrlen]='\000';
        flushstr();
        instrlen=0;
        curpos=-1;
     }
     else
     {
        instring[instrlen]=curchr;
        instrlen++;
        curpos++;
     };
     curchr=fgetc(instream);
     if (curchr==eofchr)
     {
        curlex=eoflex;
        instrlen=1;
        curpos=0;
        inend=YES;
     };
  };
  if (!ineof())
  {
      if (wasblank)
      {
          ungetc(curchr,instream);
          curchr=' ';
      }
      else
      {
         instring[instrlen]=curchr;
         instrlen++;
         curpos++;
      };
      if (
           instr(curchr,"$_#qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNMйцукенгшщзхфывапролджэячсмитьбюЙЦУКЕНГШЩЗХФЫВАПРОЛДЖЭЯЧСМИТЬБЮ")
         ) curlex=alfa;
      if (
           instr(curchr,"0123456789")
         ) curlex=digit;
      if (
           ( (curchr=='"') || (curchr=='\'') )
         ) curlex=quote;
  }; /* not ineof during skip blanks */
 }; /* not eof in next */
};

int instr(c,str)
char c;
char *str;
{
 char ts[2];
 ts[0]=c;ts[1]='\000';
 return(strspn(ts,str));
};

void error(errcode)
int errcode;
{
 comperr=YES;
 errset[errcount]=errcode;
 errmark[curpos]=errsign;
 if (errcount<maxinstrlen-1)
 {
     errcount++;
 };
};

void outerrs()
{
 int i;
 if (errcount>0)
 {
    for (i=0;i<instrlen;i++)
    {
      fprintf(outstream,"%c",errmark[i]);
    };
    fprintf(outstream,"\n");
    fprintf(outstream,"*** Error");
    if (errcount>1) fprintf(outstream,"s");
    fprintf(outstream,": ");
    for (i=0;i<errcount;i++)
    {
      fprintf (outstream," %d",errset[i]);
    };
    fprintf(outstream,"\n\n");
 };
 errcount=0;
 for (i=0;i<maxinstrlen;i++) errmark[i]=' ';
};

void flushstr()
{
 void outerrs();
 fprintf(outstream,"%s\n",instring);
 fflush(outstream);
 outerrs();
};

void partinit()
{
 int i;
 errcount=0;
 instrlen=0;
 inend=NO;
 curpos=-1;
 curlex=eoflex;
 for (i=0;i<maxinstrlen;i++) errmark[i]=' ';
 nextchr();
};

void iniscan()
{
 element *newelement();
 object   *newobject();
 object   *oldobject();
 sprit *ns;
 object *result;
 void partinit();
 int i,j;

 void sub();   /* Built-in functions */
 void add();
 void frame();
 void namedef();
 void loc();
 void set();
 void view();
 void delay();
 void sprite();
 void clears();
 void sprite();
 void byname();
 void repeat();

 comperr=NO;
 linkerr=NO;
 frameerr=NO;
 excount=0;
 instream=fopen(inFILE,"r");
 outstream=fopen(lstfile,"w");

 partinit();

 firstel=NULL;

 /*
  finstall("add",functT,add);
  finstall("sub",functT,sub);
 */
 finstall("frame",functT,frame);
 finstall("view",functT,view);
 finstall("namedef",functT,namedef);
 finstall("loc",functT,loc);
 finstall("delay",functT,delay);
 finstall("clears",functT,clears);
 finstall("sprite",functT,sprite);
 finstall("byname",functT,byname);
 finstall("set",functT,set);
 finstall("repeat",functT,repeat);

 rootelement=newelement();
 rootelement->car=oldobject("frame");
 world=NULL;
 absX=0;absY=0;absZ=0;
 for (i=0;i<Sver;i++)
 {
     for (j=0;j<Shor;j++)
     {
          displayed[i][j]=filler;
          prepared [i][j]=filler;
     };
 };
};
