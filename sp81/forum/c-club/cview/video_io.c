typedef  unsigned int uint;
typedef  unsigned int ushort;
typedef  unsigned long ulong;
typedef  unsigned char uchar;

extern uchar colorNormal;
extern uchar colorWindow;
extern uchar colorError;
extern uchar colorSelect1;
extern uchar colorSelect2;

void Selector( char x, char y, char color, char len )
{
    asm push ds
    asm mov al,y
    asm mov bl,160
    asm mul bl
    asm mov bl,x
    asm xor bh,bh
    asm add bx,bx
    asm add bx,ax
    asm mov al,color
    asm mov di,0B800h
    asm mov es,di
    asm mov di,bx
    asm mov cl,len
    asm mov ch,0
    asm jcxz end
    q:
    asm inc di
    asm stosb
    asm loop q
    end:
    asm pop ds
    ;
}


void Say( char x, char y, char color, char *zstring )
{
    asm push ds
    asm mov al,y
    asm mov bl,160
    asm mul bl
    asm mov bl,x
    asm xor bh,bh
    asm add bx,bx
    asm add bx,ax
    asm mov ah,color
    asm mov di,0B800h
    asm mov es,di
    asm mov di,bx
    asm lds si,dword ptr zstring
    q:
    asm lodsb
    asm or al,al
    asm je end
    asm stosw
    asm jmp short q
    end:
    asm pop ds
    ;
}


void SayCR( char x, char y, char color, char *zstringCR )
{
    asm push ds
    asm mov al,y
    asm mov bl,160
    asm mul bl
    asm mov bl,x
    asm xor bh,bh
    asm add bx,bx
    asm add bx,ax
    asm mov ah,color
    asm mov di,0B800h
    asm mov es,di
    asm mov di,bx
    asm lds si,dword ptr zstringCR
    asm push di
    q:
    asm lodsb
    asm or al,al
    asm je end
    asm cmp al,0Ah // аналог "\n"
    asm jne r
    asm pop di
    asm add di,160
    asm push di
    asm jmp short q
    r:
    asm stosw
    asm jmp short q
    end:
    asm pop di ds
    ;
}


void SayN( char x, char y, char color, uint len, char *string )
{
    asm push ds
    asm mov al,y
    asm mov bl,160
    asm mul bl
    asm mov bl,x
    asm xor bh,bh
    asm add bx,bx
    asm add bx,ax
    asm mov ah,color
    asm mov di,0B800h
    asm mov es,di
    asm mov di,bx
    asm mov cx,len
    asm jcxz end
    asm lds si,dword ptr string
    q:
    asm lodsb
    asm stosw
    asm loop q
    end:
    asm pop ds
    ;
}


void SayNchar( char x, char y, char color, uint len, char c )
{
    asm push ds
    asm mov al,y
    asm mov bl,160
    asm mul bl
    asm mov bl,x
    asm xor bh,bh
    asm add bx,bx
    asm add bx,ax
    asm mov ah,color
    asm mov di,0B800h
    asm mov es,di
    asm mov di,bx
    asm mov cx,len
    asm jcxz end
    asm mov al,c
    asm rep stosw
    end:
    asm pop ds
    ;
}

void fLine( uchar x, uchar y, uchar direction, uchar size,
            char color, uchar *shape )
{
    asm push ds
    _DI=x*2+y*160;
    if ( direction ) _DX=160-2; else _DX=2-2;
    asm mov cx,0B800h
    asm mov es,cx
    _CX=(uint)size;
    _AH=color;
    asm lds si, dword ptr [shape]
    asm lodsb
    asm stosw
    asm add di,dx
    asm lodsb
    asm sub cx,2
    asm jc done
    r:
    asm jcxz done
    asm stosw
    asm add di,dx
    asm dec cx
    asm jmp short r
    done:
    asm lodsb
    asm stosw
    asm pop ds
    ;
}

char save_screen[4000];
void SaveScreen( char x, char y, uchar width, uchar height )
{
     uint offs=x*2+y*160;
     asm push ds es
     asm mov dx,[height]
     asm mov cx,[width]
     asm mov si,[offs]
     asm mov di,offset save_screen
     asm push ds
     asm pop es
     asm mov ax,0B800h
     asm mov ds,ax
     g:
     asm push cx si
     asm rep movsw
     asm pop si cx
     asm add si,160
     asm dec dx
     asm jne g
     asm pop es ds
     ;
}

void RestScreen( char x, char y, uchar width, uchar height )
{
     uint offs=x*2+y*160;
     asm push ds es
     asm mov di,[offs]
     asm mov si,offset save_screen
     asm mov ax,0B800h
     asm mov es,ax
     asm mov dx,[height]
     asm mov cx,[width]
     g:
     asm push cx di
     asm rep movsw
     asm pop di cx
     asm add di,160
     asm dec dx
     asm jne g
     asm pop es ds
     ;
}

void scroll( char x, char y, char hsize, char vsize, char mode, char color )
{
    asm mov al,1
    asm cmp byte ptr [mode],0
    asm mov ah,07h
    asm jne down
    asm mov ah,06h
    down:
    asm mov cl, byte ptr [x]
    asm mov ch, byte ptr [y]
    asm mov dx,cx
    asm add dl, byte ptr [hsize]
    asm add dh, byte ptr [vsize]
    asm mov bh, byte ptr [color]
    asm int 10h
}

// расположение лифтов (используется при обработке нажатий мыши)
typedef struct {        // описание скролл-бара, заполняется (обновляется)
                        // при каждом вызове Percent()
       uchar mode;      // признак: 0-горизонтальный 1=вертикальный
       uint barMin, barMax; // концы скролл-бара
       uint barX, barY;  // позиция указателя (лифта)
} SCROLLBAR;

char *lift="◄►▲▼";
// рисует полоску и лифт; direction=2 для вертикали
// возвращает текущую абсолютную позицию лифта (от верха или слева экрана)
void Percent( char x, char y, uchar direction, char size,
              char color, ulong current, ulong max, SCROLLBAR *scroll)
{
    uint p;
    p=(uint)( current*(size-2)/max );
    if ( direction )
    {
       scroll->mode=1;
       scroll->barX=x;
       scroll->barY=y+p;
       scroll->barMin=y;
       scroll->barMax=y+size;
    }
    else
    {
       scroll->mode=0;
       scroll->barX=x+p;
       scroll->barY=y;
       scroll->barMin=x;
       scroll->barMax=x+size;
    };
    _DI=x*2+y*160;
    if ( direction ) _DX=160-2; else _DX=2-2;
    asm mov cx,0B800h
    asm mov es,cx
    _CX=(uint)size;
    _AH=color;
    asm push ds
    asm lds si, dword ptr [lift]
    asm or dx,dx  // для вертикальной полоски надо выбрать "▲▼"
    asm je t
    asm add si,2
    t:
    asm lodsb
    asm stosw
    asm add di,dx
    asm sub cx,2
    asm jc done
    asm mov bx,0
    asm jmp short comp
    r:
    asm mov al,0B0h
    asm cmp bx,[p]
    asm jne n
    asm mov al,0FEh
    n:
    asm stosw
    asm add di,dx
    asm inc bx
    comp:
    asm cmp cx,bx
    asm ja r
    done:
    asm lodsb
    asm stosw
    asm pop ds
}

// выдает коды клавиш со стрелками, если курсор мыши попал на участки
// скроллбара до или после лифта
uint scroll2key( uint mX, uint mY, SCROLLBAR *scroll )
{
       if ( scroll->mode )
       {
         // если вертикальный скролл-бар
	 if ( mX==scroll->barX )
	 {
            if ( mY<scroll->barY && mY>=scroll->barMin) return 0x4800;
	    else if ( mY>scroll->barY && mY<scroll->barMax ) return 0x5000;
         }
       }
       else
       {
         // если горизонтальный скролл-бар
	 if ( mY==scroll->barY )
	 {
            if ( mX<scroll->barX && mX>=scroll->barMin) return 0x4B00;
	    else if ( mX>scroll->barX && mX<scroll->barMax ) return 0x4D00;
         }
       };
       return 0;
}

void box( char x, char y, char width, char height, char color )
{
             fLine( x,y,0,width,color, "┌─┐");
             fLine( x,y+height-1,0,width,color, "└─┘");
             height -= 2;
             while ( height>0 )
             {
               fLine( x,y+height,0,width,color, "│ │");
               height--;
             }
}

void Bar( void )
{
    asm mov ax,0B800h
    asm mov es,ax
    asm mov cx,10
    asm mov di,24*160
    asm mov al,colorNormal
    asm mov ah,colorWindow
    l:
    asm inc di
    asm stosb
    asm inc di
    asm stosb
    asm xchg ah,al
    asm inc di
    asm stosb
    asm inc di
    asm stosb
    asm inc di
    asm stosb
    asm inc di
    asm stosb
    asm inc di
    asm stosb
    asm inc di
    asm stosb
    asm xchg ah,al
    asm loop l;
}

void dialog_box( char x, char y, char color,
                 char *header, char *prompt, char *footer )
{
             box( x,y,31,3,color);
             Say( x+2,y ,color, header );
             Say( x+2,y+1 ,color, prompt );
             Say( x+2,y+2 ,color, footer );
}
