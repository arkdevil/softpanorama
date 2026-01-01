#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <dos.h>

// компилиpовать в модели Compact !

typedef  unsigned int uint;
typedef  unsigned char uchar;
typedef  unsigned long ulong;


   unsigned long in_len, totalCompRead=0;
   FILE *in, *out;              // потоки

// на сколько сдвигаем вправо компоненты цвета, чтобы получить ID цвета
#define ClrID_bit 4
// 2^((8-ClrID_bit)*3)
#define BIGpaletteSize 4096

   uchar palette[256*3];
   uchar BIGpalette[BIGpaletteSize*3];
   uint palette_index[BIGpaletteSize]; // 12-битные номера цветов
   uint i,j, color, c, d;

   uint isVESA=0;
   uchar VesaInfo[512];
   uint Xscr=320;
   uint Yscr=200;
   uint granul=0;
   uint page_mask=0xFFFF;
   uint page_shift=0; // тип int чтобы легче грузить в cx

   char bit_per_color=0; // число бит на каждую компоненту цвета
   char alfa_ch=0;

   ulong pal_size=0; // размер палитры в файле

struct
{
   uchar skip, colormap_type, image_type;
   uint colormap_begin, colormap_len; uchar colormap_flags;
   uint zero1, zero2; // offset's from left top of screen
   uint xsize, ysize;
   uchar bpp, flags; // bits per pixel & flags
} TGA;

struct
{
   uchar r,g,b;
} RGB;

// для RLE-копирования значение цвета может повторяться
union
{
   struct
   {
     uchar r,g,b;
   } RGBvalue;

   struct
   {
     uchar r,g,b,alfa;
   } RGBAvalue;
} p;



uint rgb;   // для 15-битного кодирования

char RLE=0; // признак сжатого изображения
uchar count=0; // счетчик пикселов
uint value;    // значение цвета

unsigned long flen( FILE *f )
{
    long len; fseek( f, 0, 2); len=ftell(f); fseek( f, 0, 0); return len;
}

// сдвиг в файле на начало картинки
void go2image( void )
{
   fseek( in, sizeof( TGA )+ TGA.skip + pal_size, 0);
}

// находит наиболее яркую компоненту в цвете
uint Hcolor( uchar r, uchar g, uchar b )
{
	if ( r>g )
        {
           if ( r>=b ) return 1; else return 3;
        }
        else
           if ( g>=b ) return 2; else return 3;
}

uchar color8;
void GetRGB(void)
{
    switch ( bit_per_color )
    {
        case 5:
        fread( &value, 1, sizeof( value ), in ); return;
        case 8:
        if ( alfa_ch )
         // RGB 24-bit & alfa channel
        fread( &p.RGBAvalue, 1, sizeof( p.RGBAvalue ), in );
        else fread( &p.RGBvalue, 1, sizeof( p.RGBvalue ), in );
        return;
        case 2:
        color8=fgetc( in ); return;
    }
}

uchar repeat=0; // что хранится-повторения или различия
// дает очередной пиксел (либо чтение из файла, либо RLE распаковка)
void get_pixel(void)
{
    if ( RLE )
    {
            if ( count==0 )
            {
               fread( &count, 1, sizeof( count ), in );
               repeat = (count & 0x80);
               count &= 0x7F; count += 1;
               GetRGB();
            };
            rgb=value;
	    RGB.r=p.RGBvalue.r;
	    RGB.g=p.RGBvalue.g;
	    RGB.b=p.RGBvalue.b;
	    if ( repeat ) { count--; return; }
	    else { if (--count) GetRGB(); return; };
    }
    else // not compressed
    {
       GetRGB();
       rgb=value;
       RGB.r=p.RGBvalue.r;
       RGB.g=p.RGBvalue.g;
       RGB.b=p.RGBvalue.b;
    }
}

   uint last_page=0xFF;
void ShowLine(void)
{
	i=0;
        while ( i<TGA.xsize )
        {
            get_pixel();
            if ( i<Xscr && j<Yscr )
            {
              // вычислим номер цвета как взвешенное значение
              if ( bit_per_color==8 )
              {
                color= RGB.r >> ClrID_bit;
                c=RGB.g >> ClrID_bit;
                color += ( c << ClrID_bit);
                c=RGB.b >> ClrID_bit;
                color += ( c << (ClrID_bit*2));
              };
              if ( bit_per_color==5 )
              {
                    color= (rgb >> 1)&0x0F;
                    c= (rgb >> 6)&0x0F;
                    color += ( c << 4);
                    c= (rgb >> 11)&0x0F;
                    color += ( c << 8);
              };
              if ( bit_per_color==2 )
              {
                    color=color8;
              }
              else
              // получим истинный цвет
              color=palette_index[color];

         //   честный вариант для VESA
         //     asm push bp
         //     asm mov ax,color
         //     asm mov ah,0Ch
         //     asm mov cx,i
         //     asm mov dx,j
         //     asm mov bx,0
         //     asm int 10h
         //     asm pop bp
           if ( isVESA )
           {
               asm push bp
               asm mov ax,640
               asm mov cx,j
               asm mul cx
               asm add ax,i
               asm adc dx,0
               asm mov bx,ax
               asm and bx,word ptr [page_mask]
               asm mov cx,word ptr [page_shift]
               asm jcxz no_shift
               sh:
               asm shl ax,1
               asm rcl dx,1
               asm loop sh
               no_shift:
               asm push bx
               asm cmp dx,last_page
	       asm je  mk_point
	       asm mov last_page,dx
	       asm mov ax,4F05h
	       asm xor bx,bx
	       asm int 10h
	   mk_point:
	       asm pop bx
	       asm pop bp
           }
           else
           {
               asm mov ax,320
               asm mov cx,j
               asm mul cx
               asm add ax,i
               asm mov bx,ax
           };

               asm mov ax,0A000h
               asm mov es,ax
	       asm mov al,byte ptr [color]
               asm mov es:[bx],al

            };
            i++;
        };
}

// определяет цвет одной точки в RGB формате
void calc_24bit( void )
{
    get_pixel();
    // вычислим номер цвета как взвешенное 12-бит значение
    color= RGB.r >> ClrID_bit;
    c=RGB.g >> ClrID_bit;
    color += ( c << ClrID_bit);
    c=RGB.b >> ClrID_bit;
    color += ( c << (ClrID_bit*2));
    // VGA понимает 6 бит на компоненту, сохраним цвет
    c=color*3;
    BIGpalette[c+0]=RGB.b >> 2;
    BIGpalette[c+1]=RGB.g >> 2;
    BIGpalette[c+2]=RGB.r >> 2;
}

// определяет цвет одной точки в 15-битовом формате
void calc_15bit( void )
{
    get_pixel();
    // вычислим номер цвета как взвешенное 12-бит значение
    color= (rgb >> 1)&0x0F;
    c= (rgb >> 6)&0x0F;
    color += ( c << 4);
    c= (rgb >> 11)&0x0F;
    color += ( c << 8);
    // VGA понимает 6 бит на компоненту, сохраним цвет
    c=color*3;
    BIGpalette[c+0]= (rgb >> 9)&0x03E;
    BIGpalette[c+1]= (rgb >> 4)&0x03E;
    BIGpalette[c+2]= (rgb << 1)&0x03E;
}

int main(int argc, char *argv[])
{
   uint total_color, non_fit, every, last_used;

   if (argc<2)
   {
   printf("\nTGA viewer 1.0, (c) Milukov, 1995,96\n"\
	  "\n\tusage: vtga filename.tga [/v]\n"\
	  "\twhere filename.tga is 24 or 15 bit-per-pixel TARGA picture\n"\
	  "\t/v to disable VESA and use 320x200x256\n");
   exit(1);
   };

   if ( argc>2 && (strcmp(argv[2], "/v")==NULL) ) goto no_vesa;

   asm push ds
   asm pop es
   asm lea di,VesaInfo
   asm mov ax,4F00h
   asm push bp
   asm int 10h
   asm pop bp
   asm cmp al,4Fh
   asm jne no_v

   asm push ds
   asm pop es
   asm lea di,VesaInfo
   asm mov ax,4F01h
   asm mov cx,101h
   asm push bp
   asm int 10h
   asm pop bp
   asm cmp ax,4Fh
   asm je vesaOk
   no_v:
   asm jmp no_vesa
   vesaOk:
   asm mov ax,word ptr es:[di+4]
   asm mov granul,ax
   asm or ax,ax
   asm je no_v
   asm cmp ax,64
   asm ja no_v
   // sizeof bank must be no more than 64Kb & no zero

   printf( "VESA detected, use 640x480, 256c, granul %u\n", granul );
   while (( granul & 0x40 ) == 0 )
   {
      granul <<= 1; // ищем первый ненулевой бит
      page_mask >>= 1;
      page_shift++;
   }
   isVESA=1;
   Xscr=640;
   Yscr=480;

   no_vesa:
   if ((in = fopen(argv[1], "rb"))  == NULL)
   {
      fprintf(stderr, "file %s not open\n", argv[1] ); return 1;
   };
   if (setvbuf( in, malloc( 10240 ), _IOFBF, 10240))
   printf( "I/O buffering not active\n" );

   in_len = flen(in);

   fread( &TGA, 1, sizeof( TGA ), in ); // прочитаем заголовок

   // флаг способа хранения строк сверху вниз или снизу вверх
   if (( TGA.flags != 0x20) &&
       ( TGA.flags != 0x08) &&
       ( TGA.flags != 0x00)
       )
   goto unknown;

   // число цветов
   if ( TGA.bpp == 0x18 ) bit_per_color=8;
   if ( *((uint *)&TGA.bpp) == 0x0020 ) { bit_per_color=8; alfa_ch=1; };
   if ( *((uint *)&TGA.bpp) == 0x0820 ) { bit_per_color=8; alfa_ch=1; };
   if ( *((uint *)&TGA.bpp) == 0x2010 ) bit_per_color=5;
   if ( *((uint *)&TGA.bpp) == 0x0010 ) bit_per_color=5;
   if ( *((uint *)&TGA.bpp) == 0x000F ) bit_per_color=5;
   if ( bit_per_color==0 ) goto unknown;

   if ( TGA.image_type == 0x0A ) { RLE=1; goto good; }
   else
   if ( TGA.image_type == 0x02 ) goto good;

   unknown:
   // last chance for paletted TARGA
   if (( TGA.colormap_type == 1 )&&
       (TGA.image_type == 1)&&
       ( *((uint *)&TGA.bpp) == 0x0008 ))
   {
      if ( TGA. colormap_flags ==0x18 ) pal_size=256*3;
      if ( TGA. colormap_flags ==0x20 ) pal_size=256*4;
      bit_per_color=2; goto good;
   }
   printf( "Sorry, Unknown .TGA or .RLE file format\n");
   fclose(in);
   exit(1);

   good:
   // на начало пикселов
   if ( bit_per_color!=2 ) go2image();
   else
   {
       // прочитаем палитру
       for ( i=0; i<256; i++ )
       {
       fread( &p.RGBvalue, 1, sizeof( p.RGBvalue ), in );
       if (pal_size==256*4) fgetc(in);
	  // поменяем порядок BGR
	     palette[i*3+0]=p.RGBvalue.b >>2;
	     palette[i*3+1]=p.RGBvalue.g >>2;
	     palette[i*3+2]=p.RGBvalue.r >>2;

       };
       total_color=256;
       goto set_palette;
   }
   // очистим палитру
   for ( i=0; i<BIGpaletteSize*3; i++ ) BIGpalette[i]=0;
   // очистим индексы цвета
   for ( i=0; i<BIGpaletteSize; i++ ) palette_index[i]=0xFFFF;

   j=0;
   // создадим палитру
   printf( "Creating palette...\n");
   while ( j<TGA.ysize )
   {
        i=0;
        while ( i<TGA.xsize )
        {
            if ( bit_per_color==5 ) calc_15bit();
            if ( bit_per_color==8 ) calc_24bit();
            // зарегистрируем цвет
            palette_index[color]=color;
            i++;
        };
        j++;
   };
   // подсчитаем количество непустых цветов в палитре
   total_color=0;
   for ( i=0; i<BIGpaletteSize; i++ )
   {
        if (palette_index[i]!=0xFFFF) total_color++;
   };
   // сколько не влезло в 256 VGA
   if ( total_color>256 ) non_fit=total_color-256; else non_fit=0;
   // пропускать каждый every (2-й, 7-й и т.п.) цвет, чтобы равномерно
   // поместились (почти) все
   every=4096;
   if ( non_fit )
   {
     every= (256-1)/non_fit+1;
     if ( every<2 ) every=2;
   }

   // скопируем палитру с коррекцией номеров цвета
   color=0;
   last_used=0;  // предыдущий цвет для затыкания дыр в palette_index[]
   j=0;          // порядковый номер цвета, взятого из palette_index[]
   i=0;
   while ( i<BIGpaletteSize )
   {
        if (palette_index[i]!=0xFFFF)
        {
            if ( j % every ) // если данный цвет не исключаем
            {
		c=color*3;
		d=i*3;
		palette[c+0]=BIGpalette[d+0];
		palette[c+1]=BIGpalette[d+1];
		palette[c+2]=BIGpalette[d+2];
                palette_index[i++]=color;
                last_used=color;
                if ( ++color == 256 ) break;
            }
            else
	    {
		c=last_used*3;
		d=i*3;
		if (
		     Hcolor( palette[c+0],
			     palette[c+1],
			     palette[c+2] ) ==
		     Hcolor( BIGpalette[d+0],
			     BIGpalette[d+1],
			     BIGpalette[d+2] )
                   )
                palette_index[i++]=last_used;
                else palette_index[i++]=color+1;
            };
            j++;
	}
        else i++;
   };

   set_palette:

   asm push dx cx bx ax bp
   asm mov ax,13h
   asm cmp isVESA,0
   asm je set_mode
   asm mov ax,4F02h          ///5Ch  // 640x480 256
   asm mov bx,101h
   set_mode:
   asm int 10h
   asm mov dx,offset [palette]
   asm push ds
   asm pop es
   asm mov ax,1012h
   asm mov cx,256
   asm mov bx,0
   asm int 10h
   asm pop bp ax bx cx dx

   // на начало пикселов
   go2image();
   if ( TGA.flags == 0x20 )
   {
           j=0;
           while ( j<TGA.ysize )
           {
                ShowLine();
                j++;
           };
   }
   else if ((  TGA.flags == 0x00 ) ||
            (  TGA.flags == 0x08 ) ||
            (  *((uint *)&TGA.bpp) == 0x0010 ) ||
            (  *((uint *)&TGA.bpp) == 0x0008 ))
   {
           j=TGA.ysize;
           while ( j )
           {
                ShowLine();
                j--;
           };
   };

   fclose(in); fclose(out);
   asm mov ax,0
   asm int 16h
   asm cmp al,'p'
   asm je e:
   asm jmp no_pal
   e:
   // покажем палитру
   for ( i=0; i<16; i++ )
   {
        for ( j=0; j<16; j++ )
        {
	    color=j+i*16+j*256+i*16*256;
            poke( 0xA000, j*4+Xscr*i*4, color );
            poke( 0xA000, j*4+2+Xscr*i*4, color );
            poke( 0xA000, j*4+Xscr*i*4+Xscr, color );
            poke( 0xA000, j*4+2+Xscr*i*4+Xscr, color );
            poke( 0xA000, j*4+Xscr*i*4+Xscr*2, color );
            poke( 0xA000, j*4+2+Xscr*i*4+Xscr*2, color );
            poke( 0xA000, j*4+Xscr*i*4+Xscr*3, color );
	    poke( 0xA000, j*4+2+Xscr*i*4+Xscr*3, color );

        }
   }
   asm mov ax,0
   asm int 16h
   no_pal:
   asm mov ax,3
   asm int 10h
   printf( "%u colors used\n", total_color );
   return 0;
}
