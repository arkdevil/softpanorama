# include <stdio.h>
# include <mem.h>

# define  WORD  unsigned int
# define  BYTE  unsigned char

typedef struct {
        FILE  *fp;
	WORD  buf;
        BYTE  count;
    } bitstream;

void initbits(bitstream *,FILE *);
int getbit(bitstream *);

/*---------------------*/
/* decompressor routine */
int unsqu (FILE *ifile,FILE *ofile){
    int len;
    int span;
    bitstream bits;
    static BYTE data[0x4500], *p=data;

    initbits(&bits,ifile);
    for(;;){
        if(ferror(ifile)) return -1;
        if(ferror(ofile)) return -1;
        if(p-data>0x4000){
            fwrite(data,sizeof data[0],0x2000,ofile);
            p-=0x2000;
            memcpy(data,data+0x2000,p-data);
        }
        if(getbit(&bits)) {
            *p++=getc(ifile);
            continue;
        }
        if(!getbit(&bits)) {
            len=getbit(&bits)<<1;
            len |= getbit(&bits);
            len += 2;
            span=getc(ifile) | 0xff00;
        } else {
            span=(BYTE)getc(ifile);
            len=getc(ifile);
            span |= ((len & ~0x07)<<5) | 0xe000;
            len = (len & 0x07)+2;
            if (len==2) {
                len=getc(ifile);

                if(len==0)
                    break;    /* end mark of compreesed load module */
	    }
        }
        for( ;len>0;len--,p++){
            *p=*(p+span);
        }
    }
    if(p!=data)
        fwrite(data,sizeof data[0],p-data,ofile);
    return 0;
}

/*-------------------------------------------*/

/* get compress information bit by bit */
static void initbits(bitstream *p,FILE *filep){
    p->fp=filep;
    p->count=0x10;
    p->buf=getw(filep);
}

static int getbit(bitstream *p) {
    int b;
    b = p->buf & 1;
    if(--p->count == 0){
        (p->buf)=getw(p->fp);
        /* printf("%04x ",p->buf); */
        p->count= 0x10;
    }else
        p->buf >>= 1;
    return b;
}

