{$I-}{$F-}
uses dos,crt;
type
 exehptr=^exehtype;
 exehtype=record
   w4D5A,   { "подпись" файла .EXE ('MZ')                                }
   PartPag, { длина неполной последней страницы (обычно игнорируется)    }
   PageCnt, { длина образа в 512-байтовых страницах, включая заголовок   }
   ReloCnt, { число элементов в таблице перемещения                      }
   HdrSize, { длина заголовка в 16-байтовых параграфах                   }
   MinMem,  { минимум требуемой памяти за концом программы (параграфы)   }
   MaxMem,  { максимум требуемой памяти за концом программы (параграфы)  }
   ReloSS,  { сегментное смещение сегмента стека (для установки SS)      }
   ExeSP,   { значение регистра SP (указателя стека) при запуске         }
   ChkSum,  { контрольная сумма (отрицательная сумма всех слов в файле)  }
   ExeIP,   { значение регистра IP (указателя команд) при запуске        }
   ReloCS,  { сегментное смещение кодового сегмента (для установки CS)   }
   TablOff, { смещение в файле 1-го элемента перемещения (часто 001cH)   }
   Overlay:word;  { номер оверлея (0 для главного модуля)                }
	    { пропуск до границы параграфа                               }
 end;
 rptyp=record o,s:word; end;
  var cop,vacresult:integer;
  { Процедура вакцинирования EXE файлов версия 1.2 }
  { Параметры:
       f - файловая переменная;
       cop-код операции   1 - проверка
                          2 - установка
                          3 - снятие
     Глобальная переменная vacresult сохраняет код результата:
       0 - успешное завершение / вакцина не установлена;
       1 - вакцина уже установлена;
       2 - вакцина установлена;
       3 - вакцина удалена;
      -1 - ошибка диска;
      -2 - при попытке установки вакцина уже была установлена ;
      -3 - при попытке удаления вакцина не была установлена ;
  }
  procedure vac_14E(var f:file;cop:integer);
    label exv;
    var
       vp:pointer;ps,pv:longint;vcp:^byte;vrp,vpp,vzp,rcp,rtp,fplp,fphp:^word;hc,hs:exehptr;
       rc,vz,vo,i,j,oexv:word;sb:array[1..400] of byte;rb:array[0..7000] of rptyp;
       fz:boolean;dsp:^integer;csm:byte;
    procedure e;
     begin
       if IOresult=0 then exit;
       close(f);
       vacresult:=-1;
       asm pop bp
           pop ax
           jmp oexv.word end;
     end;
    procedure ex;
     begin
      close(f);
      asm  pop bp
           pop ax
           jmp oexv.word end;
     end;
   begin
     asm mov oexv.word,offset exv end;
     asm
             mov    vp.word,offset @exeh
             mov    vp[2].word,seg @exeh
             mov    hc.word,offset @exeh
             mov    hc[2].word,seg @exeh
             mov    hs.word,offset @partpag-2
             mov    hs[2].word,seg @partpag
             mov    rcp.word,offset @relovcnt+1
             mov    rcp[2].word,seg @relovcnt
             mov    vzp.word,offset @relovcnt+1
             mov    vzp[2].word,seg @relovcnt
             mov    vrp.word,offset @vernum
             mov    vrp[2].word,seg @vernum
             mov    vpp.word,offset @vpos
             mov    vpp[2].word,seg @vpos
             mov    vcp.word,offset @vchsum
             mov    vcp[2].word,seg @vchsum
             mov    fplp.word,offset @fpsl
             mov    fplp[2].word,seg @fpsl
             mov    fphp.word,offset @fpsh
             mov    fphp[2].word,seg @fpsh
             mov    rtp.word,offset @tpos
             mov    rtp[2].word,seg @tpos
             mov    vz.word,offset @end
             sub    vz.word,offset @exeh
             mov    ax,vz.word
             mov    cs:[offset @ret1+1],ax
             mov    si,offset @sv
             mov    di,offset @exeh
             mov    cx,ax
             mov    ax,cs:[offset @fz]
             or     ax,ax
             jnz    @@0
             mov    ax,0
             sub    ax,offset @exeh
             add    cs:[offset @a8+3],ax
             mov    ax,100h
             sub    ax,offset @exeh
             add    cs:[offset @a0+2],ax
             add    cs:[offset @a1+1],ax
             add    cs:[offset @a2+2],ax
             add    cs:[offset @a3+2],ax
             add    cs:[offset @a4+2],ax
             add    cs:[offset @a5+2],ax
             add    cs:[offset @a6],ax
             add    cs:[offset @a7+1],ax
             add    cs:[offset @a9],ax
             add    cs:[offset @ort1],ax
             add    cs:[offset @ort2],ax
             add    cs:[offset @ort3],ax
             inc    word ptr cs:[offset @fz]
             mov    si,offset @exeh
             mov    di,offset @sv
         @@0:push   ds
             push   es
             push   cs
             push   cs
             pop    ds
             pop    es
             cld
             rep    movsb
             pop    es
             pop    ds
             jmp    @@1
      @fz:   dw     0
            {*********************** BEGINVAC ****************************}
  @exeh:     dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0      { - заголовок            }
  @start:    push   ds                           {                        }
      @a8:   push   word ptr cs:[offset @a9]     {                        }
             retf                                {                        }
  @stv:      push   ax                           { - сохранить регистры   }
             push   bx                           {                        }
             push   cx                           {                        }
             push   dx                           {                        }
             push   si                           {                        }
             push   di                           {                        }
             push   bp                           {                        }
             mov    bp,ds                        {     bp <- PSP          }
             cld                                 {                        }
             mov    ds,[2Ch]                     {     ds <- Среда        }
             xor    bx,bx                        {                        }
             xor    si,si                        {                        }
    @pst:    dec    bx                           {                        }
             jz     @nst                         {                        }
    @next:   lodsb                               {                        }
             or     al,al                        {                        }
             jnz    @next                        { - пропуск строки       }
             or     al,[si]                      {   среды / ком.строк    }
             jnz    @pst                         { - обнаружение          }
             lodsb                               {   начала ком.строк     }
             lodsw                               {                        }
             mov    bx,ax                        { - кол-во строк         }
             jmp    @pst                         {                        }
    @nst:    mov    dx,si                        {                        }
             mov    ax,03d02h                    {                        }
             int    21h                          {                        }
             mov    bx,ax                        {                        }
             mov    dx,0BEh                      {    dx <- avtomask      }
             mov    ds,bp                        {                        }
      @a1:   mov    si,offset @ort3              {                        }
    @lo:     lodsw                               {                        }
    @pu:     push   ax                           {                        }
             xor    ax,ax                        {                        }
             shr    dx,1                         {                        }
             jc     @lo                          {                        }
             jnz    @pu                          { - смена сегмента-      }
             push   ss                           {                        }
             pop    ds                           {                        }
             mov    cx,1Ch                       {                        }
    @cmp:    call   @rdf                         { - чтение фрагмента     }
             mov    di,dx                        { - установ проверки     }
             mov    si,di                        {                        }
             repz   cmpsb                        { - проверка             }
             jnz    @exv                         {                        }
             pop    dx                           { - чтение позиции       }
             pop    cx                           {   файла из стека       }
             mov    ax,4200h                     {                        }
             int    21h                          { - установка позиции    }
             ret                                 { - переход на обраб.    }
    @ret2:   push   ds                           { ---- обработка оп.---  }
             push   cs                           {     ds <- PSP          }
             pop    ds                           { - переход на копию     }
      @a0:   push   word ptr [offset @ort1]      {                        }
             retf                                {                        }
    @ret1:   mov    cx,4444                      { - длинна вакцины в cx  }
             jmp    @cmp                         { - переход на начало    }
    @ret3:   push   cs                           { -                      }
             pop    ds                           {                        }
             push   es                           {                        }
             add    bp,10h                       {                        }
  @relovcnt: mov    si,4444                      {                        }
    @rel:    dec    si                           {                        }
             js     @exit                        {                        }
             mov    cx,4                         {                        }
             call   @rdf                         {                        }
             mov    di,dx                        {                        }
             add    ds:[di+2],bp                 {                        }
             les    di,ds:[di]                   {                        }
             add    es:[di],bp                   {                        }
             jmp    @rel                         {                        }
    @exit:   mov    ah,3eh                       {                        }
             int    21h                          {                        }
      @a2:   add    [offset @relocs],bp          {                        }
      @a3:   add    [offset @reloss],bp          {                        }
             pop    es                           {                        }
             pop    bp                           {                        }
             pop    di                           {                        }
             pop    si                           {                        }
             pop    dx                           {                        }
             pop    cx                           {                        }
             pop    bx                           {                        }
             pop    ax                           {                        }
      @a4:   mov    ss,[offset @reloss]          {                        }
      @a5:   mov    sp,[offset @exesp]           {                        }
             push   es                           {                        }
             pop    ds                           {                        }
             db     2Eh,0FFh,2Eh                 {                        }
      @a6:   dw     offset @exeip                {                        }
    @exv:                                        {                        }
             mov    ds,bp                        {                        }
      @a7:   mov    dx,offset @vrs               {                        }
             mov    ah,09h                       {                        }
             int    21h                          {                        }
             mov    ah,3eh                       {                        }
             int    21h                          {                        }
             mov    ax,04c00h                    {                        }
             int    21h                          {                        }
    @vrs:    db     'Vac 1.4E: Virus!!!$'        {                        }
    @rdf:    mov    dx,100h                      {                        }
             mov    ah,3Fh                       {                        }
             int    21h                          {                        }
             ret                                 {                        }
  @ort3:     dw     offset @ret3                 {                        }
  @tpos:     dw     0                            {                        }
  @ort2:     dw     offset @ret2                 {                        }
  @fpsh:     dw     0                            {                        }
  @fpsl:     dw     0                            {                        }
  @ort1:     dw     offset @ret1                 {                        }
  @vpos:     dw     0                            {                        }
  @partpag:  dw     0 { длина неполной последней страницы (обычно игнорируется)     }
  @pagecnt:  dw     0 { длина образа в 512-байтовых страницах, включая заголовок    }
  @relocnt:  dw     0 { число элементов в таблице перемещения                       }
  @hdrsize:  dw     0 { длина заголовка в 16-байтовых параграфах                    }
  @minmem:   dw     0 { минимум требуемой памяти за концом программы (параграфы)    }
  @maxmem:   dw     0 { максимум требуемой памяти за концом программы (параграфы)   }
  @reloss:   dw     0 { сегментное смещение сегмента стека (для установки SS)       }
  @exesp:    dw     0 { значение регистра SP (указателя стека) при запуске          }
  @chksum:   dw     0 { контрольная сумма (отрицательная сумма всех слов в файле)   }
  @exeip:    dw     0 { значение регистра IP (указателя команд) при запуске         }
  @relocs:   dw     0 { сегментное смещение кодового сегмента (для установки CS)    }
  @tabloff:  dw     0 { смещение в файле 1-го элемента перемещения (часто 001cH)   }
  @vernum:   dw     02114
      @a9:   dw     offset @stv
  @vchsum:   db     0
  @end:                                          {                        }
           {******************** ENDVAC **********************************}
  @sv:       dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
             dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
             dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
             dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
             dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         @@1:
     end;
     reset(f,1);e;ps:=filesize(f);e;blockread(f,hc^,28);e;
     with hc^ do begin
      { if (w4D5A<>$4D5A)or((relocnt*4+28)>(hdrsize*16))or
          (((relocs*16+exeip)div 512)>pagecnt) then begin vacresult:=-4;ex; end;}
       seek(f,hdrsize shl 4);e;blockread(f,sb,vz);e;
       csm:=0;for i:=1 to vz-1 do inc(csm,sb[i]);
       if csm=sb[vz] then
         case cop of
         1:begin vacresult:=1;ex; end;
         2:begin vacresult:=-2;ex; end;
         3:begin
             i:=hdrsize shl 4;
             move(sb,vp^,vz);
             move(hs^.partpag,hc^.partpag,24);
             seek(f,ps-vz);e;blockread(f,sb,vz);e;
             seek(f,ps-vz);e;truncate(f);e;
             seek(f,i);e;blockwrite(f,sb,vz);e;
             seek(f,0);e;blockwrite(f,hc^,28);e;
             vacresult:=3;ex;
           end;
         end
       else begin
         case cop of
         1:begin vacresult:=0;ex; end;
         2:begin
             move(hc^.partpag,hs^.partpag,24);
             rtp^:=tabloff;if relocnt>7000 then ex;
             seek(f,tabloff);e;blockread(f,rb[1],relocnt*4);e;
             fz:=false;i:=1;j:=relocnt;rc:=0;
             while i<=j do begin
               pv:=rb[i].s shl 4 + rb[i].o;
               if pv>vz then begin
                 while (j>i)and((rb[j].s shl 4 + rb[j].o)>vz) do dec(j);
                 if j>i then begin  inc(rc);fz:=true;
                   rb[0]:=rb[i];rb[i]:=rb[j];rb[j]:=rb[0];
                 end;
               end
               else inc(rc);
               inc(i);
             end;
             if fz then begin seek(f,tabloff);e;blockwrite(f,rb[1],relocnt*4);e;end;
             inc(tabloff,rc shl 2);dec(relocnt,rc);rcp^:=rc;
             relocs:=0;exeip:=$01C;reloss:=pagecnt shl 5;exesp:=vz+500;
             pv:=exesp div 16+1;if minmem<pv then minmem:=pv;
             if maxmem<minmem then maxmem:=minmem;
             fphp^:=ps shr 16;fplp^:=ps and $FFFF;vpp^:=hdrsize shl 4;
             move(vp^,sb,vz);csm:=0;for i:=1 to vz-1 do inc(csm,sb[i]);vcp^:=csm;
             seek(f,hdrsize shl 4);e;blockread(f,sb,vz);e;
             seek(f,ps);e;blockwrite(f,sb,vz);e;
             seek(f,hdrsize shl 4);e;blockwrite(f,vp^,vz);e;
             seek(f,0);e;blockwrite(f,hc^,28);e;vacresult:=2;
             ex;
           end;
         3:begin vacresult:=-3;ex; end;
         end;
       end;
     end;
     exv:;
   end;
  { Процедура вакцинирования COM файлов версия 1.2 }
  { Параметры:
       f - файловая переменная;
       cop-код операции   1 - проверка
                          2 - установка
                          3 - снятие
     Глобальная переменная vacresult сохраняет код результата:
       0 - успешное завершение / вакцина не установлена;
       1 - вакцина уже установлена;
       2 - вакцина установлена;
       3 - вакцина удалена;
      -1 - ошибка диска;
      -2 - при попытке установки вакцина уже была установлена ;
      -3 - при попытке удаления вакцина не была установлена ;
  }
  procedure vac_12C(var f:file;cop:integer);
    label vacinit,startvaccod,endvaccod,jmpcod,jmptest,posvac,origin,exitvac;
    var
       vacptr,jmpptr,originptr:pointer;jmptptr:^word;
       vacsize,ofvac,retwv,pv,ps,ofexitvac:word;
       s,s1:array[1..200] of byte;
    function cmp(var a,b;c:integer):boolean;
    var ap,bp:^byte;i:integer;
    begin
      cmp:=false;ap:=@a;bp:=@b;
      for i:=1 to c do begin if ap^<>bp^ then exit;inc(ap);inc(bp); end;
      cmp:=true;
    end;
    procedure e;
    begin
      if IOresult=0 then exit;
      vacresult:=-1;
      asm pop bp
          pop ax
          jmp ofexitvac.word end;
    end;
    procedure ex;
    begin
      asm pop bp
          pop ax
          jmp ofexitvac.word end;
    end;
   begin
     reset(f,1);e;ps:=filesize(f);e;ofvac:=$100+ps;vacresult:=0;
     asm
             mov    ofexitvac.word,offset exitvac;
             mov    vacptr.word,offset startvaccod
             mov    vacptr[2].word,seg startvaccod
             mov    jmpptr.word,offset jmpcod
             mov    jmpptr[2].word,seg jmpcod
             mov    originptr.word,offset origin
             mov    originptr[2].word,seg origin
             mov    jmptptr.word,offset jmptest
             mov    jmptptr[2].word,seg jmptest
             mov    vacsize.word,offset endvaccod
             sub    vacsize.word,offset startvaccod
      end;
      move(vacptr^,s1,vacsize);
      asm
             mov    ax,ofvac.word
             sub    ax,offset @start
             add    cs:[offset @a1+2],ax
             add    cs:[offset @a2+1],ax
             add    cs:[offset @a3+1],ax
             add    cs:[offset @a4+1],ax
             mov    ax,ps.word
             add    ax,100h
             mov    cs:[offset posvac+1],ax
             jmp    @@1
            {*********************** BEGINVAC ****************************}
 startvaccod:                                    {                        }
  @start:                                        {                        }
             push   ax                           {                        }
             mov    ds,[2Ch]                     {                        }
             xor    si,si                        {                        }
             xor    bx,bx                        {                        }
    @pst:    dec    bx                           {                        }
             jz     @nst                         {                        }
    @next:   lodsb                               {                        }
             or     al,al                        {                        }
             jnz    @next                        {                        }
             or     al,[si]                      {                        }
             jnz    @pst                         {                        }
             lodsb                               {                        }
             lodsw                               {                        }
             mov    bx,ax                        {                        }
             jmp    @pst                         {                        }
    @nst:    mov    dx,si                        {                        }
             mov    ax,03d02h                    {                        }
             int    21h                          {                        }
             mov    bx,ax                        {                        }
             push   es                           {                        }
             pop    ds                           {                        }
             mov    dx,cx                        {                        }
             sub    dx,100h                      {                        }
        @a4: mov    si,offset @start             {                        }
    @cmp:    xor    cx,cx                        {                        }
             mov    ax,4200h                     {                        }
             int    21h                          {                        }
             mov    dx,100h                      {                        }
             mov    cl,6                         {                        }
             mov    ah,3Fh                       {                        }
             int    21h                          {                        }
             mov    di,dx                        {                        }
             repz   cmpsb                        {                        }
             jne    @exv                         {                        }
        @a1: cmp    si,offset @next              {                        }
             jns    @ok                          {                        }
             xor    dx,dx                        {                        }
        @a2: mov    si,offset jmpcod             {                        }
             jmp    @cmp                         {                        }
    @ok:     mov    cl,6                         {                        }
             mov    di,dx                        {                        }
             rep    movsb                        {                        }
             mov    ah,3eh                       {                        }
             int    21h                          {                        }
             pop    ax                           {                        }
             push   dx                           {                        }
             ret                                 {                        }
    @exv:                                        {                        }
        @a3: mov    dx,offset @vrs               {                        }
             mov    ah,09h                       {                        }
             int    21h                          {                        }
             mov    ah,3eh                       {                        }
             int    21h                          {                        }
             mov    ax,04c00h                    {                        }
             int    21h                          {                        }
    @vrs:    db     'Vac 1.2C: Virus!!!$';       {                        }
 jmpcod:                                         {                        }
 posvac:     mov    cx,4444                      {                        }
             push   cx                           {                        }
             ret                                 {                        }
             db     12d                          {                        }
 origin:     db     0                            {                        }
 jmptest:    dw     0                            {                        }
             db     0,0,0                        {                        }
 endvaccod:                                      {                        }
           {******************** ENDVAC **********************************}
         @@1:
     end;
     blockread(f,originptr^,6);e;pv:=jmptptr^-$100;
     if pv=(ps-vacsize) then begin
       seek(f,pv);e;blockread(f,s,vacsize);e;
       if cmp(s,vacptr^,40) then
         case cop of
           1:begin vacresult:=1;ex;end;
           2:begin vacresult:=-2;ex; end;
           3:begin move(s,vacptr^,vacsize);seek(f,0);e;
                   blockwrite(f,originptr^,6);e;seek(f,pv);e;
                   truncate(f);e;vacresult:=3;ex; end;
         end;
     end;
     case cop of
     1:ex;
     2:begin
         seek(f,ps);e;blockwrite(f,vacptr^,vacsize);e;
         seek(f,0);e;blockwrite(f,jmpptr^,6);e;vacresult:=2;ex; end;
     3:begin vacresult:=-3;ex; end;
     end;
     exitvac:move(s1,vacptr^,vacsize);
   end;


Procedure help;
begin
Writeln('Вакцина VAC_СE предназначена для имунизации COM и EXE файлов');
Writeln('Формат командной строки:');
Writeln('VAC_CE command file1 file2 file3 ... fileN  [/switch]');
Writeln('command:');
Writeln('        T - проверка');
Writeln('        S - установка');
Writeln('        R - удаление');
Writeln('file1 ... fileN : Имена вакцинируемых файлов');
Writeln('switch:');
Writeln('       ! - останавливаться после каждого файла и спрашивать разрешения');
halt;
end;
Procedure Comment(sol:Integer);
begin
 sol := sol * (Vacresult + 10);
  case sol of
    10,20:Writeln(' - Вакцина не установлена');
    11,24:Writeln(' - Вакцина установлена');
    18,9:Writeln(' - Ошибка диска');
    16:Writeln(' - Вакцина была установлена раньше');
    39:Writeln(' - Вакцина удалена');
    21:Writeln(' - Вакцина не была установлена');
    else
    Writeln(' - Внутреняя ошибка');
   end;
end;
function EXEOk(var f:file):Boolean;
var s:word;
begin
 blockread(f,s,2);
 EXEok := s=$5A4D;
end;
Function YorN(Ok :Boolean):Boolean;
var S:Char;
begin
 S:='Y';
 if Ok Then begin
              write(' Y/N/Esc');
              Repeat S:=UpCase(ReadKey) Until S in ['Y','N',#27];
            end;
 If S = #27 then Halt;
 YorN:=S = 'Y';
end;
var  f:file;CurentName:string;
     DirInfo: SearchRec;
     NumName : Byte;
     StepOn : Boolean;
     P: PathStr;
     D: DirStr;
     N: NameStr;
     E: ExtStr;

begin
 Writeln(#13,#10,'Вакцина для обнаружения файловых вирусов версия 1.5 от 1.06.91 г.Свердловск');
 Writeln('(C) Березин А. Шароварин Е. тел (3432) 44-84-53, 51-31-77');
 Writeln('Лабоpатоpия инфоpмационной технологии "КОНУС"',#13,#10);

  if paramcount  < 2 then Help;
  CurentName := paramStr(1);
  case UpCase(CurentName[1]) of
    'T':cop := 1;
    'S':cop := 2;
    'R':cop := 3;
   else begin
         Writeln('Неверная команда',#7);Help;
        end;
   end;
  NumName := 2;
  StepOn := paramstr(paramcount) = '/!';
  repeat
  CurentName := paramstr(NumName);
  FindFirst(CurentName, Archive, DirInfo);
  while DosError = 0 do
  begin
    FSplit(DirInfo.Name, D, N, E);
    if (E = '.COM') or (E = '.EXE') then
    begin
     Write(DirInfo.Name);
     if YorN(StepOn) then
     begin
      assign(f,dirinfo.name);
      reset(f,1);
      if EXEOk(f)
       then
        begin
         if E ='.COM' then
         begin
          write(' - Это EXE файл, продолжим?',#7);
          if YorN(True) then vac_14E(f,cop) else vacresult :=0;
         end else vac_14E(f,cop);
        end
        else if E ='.EXE' then
        begin
         write(' - Это не EXE файл, продолжим?',#7);
         if YorN(True) then vac_12C(f,cop) else vacresult :=0;
        end else vac_12C(f,cop);
      Comment(cop);
     end;
    end;
    FindNext(DirInfo);
  end;
  inc(NumName);
  until ((NumName = ParamCount) and StepOn) or (NumName = ParamCount + 1);
end.

