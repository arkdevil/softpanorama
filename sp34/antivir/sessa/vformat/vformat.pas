{$A+,B-,D+,E+,F-,I-,L+,N-,O-,R-,S-,V-}
{$M 8192,0,0}
Program VFORMAT;

uses dos;

{           PUBLIC DOMAIN           }

{Written by Christoph H. Hochstätter}
{Modified by Alexander V. Sessa}
{Turbo-Pascal 5.0}
{Last Updated: 8-Apr-1991}

const text01 = 'Error ';
const text02 = '(A)bort (R)etry (I)gnore ? ';
const t3     = 'R';
const text04 = 'No valid drive.';
const text05 = 'SUBST/ASSIGN/Network-Drive.';
const text06 = 'Not a floppy drive.';
const text07 = 'Unknown drive type.';
const text08 = 'Formatting drive ';
const text09 = ' Head(s), ';
const text10 = ' Tracks, ';
const text11 = ' Sectors/track, ';
const text12 = ' Root Directory Entries, ';
const text13 = ' Sector(s)/Cluster, Sector-Shift: ';
const text14 = 'Head: ';
const text15 = ', Cylinder: ';
const text16 = ', Sector: ';
const text17 = 'Format error in system area: Program aborted.';
const text18 = 'More than ';
const text19 = ' sectors unreadable. Program aborted.';
const text20 = ' marked as bad';
const text22 = 'Total sectors on disk:  ';
const text23 = 'Sectors per track:      ';
const text24 = 'Heads:                  ';
const text29 = 'Sectors per FAT:        ';
const text30 = 'Total clusters on disk: ';
const text31 = ' total bytes on disk';
const text32 = ' bytes in bad sectors';
const text33 = ' bytes available';
const text34 = 'This drive cannot be formatted.';
const text35 = 'Drive is physical ';
const text36 = 'BIOS double-step support: ';
const text37 = 'XT-like';
const text38 = 'EPSON QX-16 like';
const text39 = 'AT-like';
const text40 = 'Not available or unknown';
const text42 = 'Usage is: VFORMAT drive: [options]';
const text43 = ' Example: VFORMAT a: t41 h2 s10 C1 D112';
const text44 = 'Option   Meaning                                 Default';
const text45 = 'drive:   drive to be formatted                   none';
const text46 = 'Tnn      Number of tracks                        40/80 depends on drive';
const text47 = 'Hnn      Number of heads                         2';
const text48 = 'Snn      Number of sectors per track             9/15/18 depends on drive';
const text49 = 'Cn       Number of sectors per cluster           1 for HD, 2 for DD';
const text50 = 'Dnnn     Number of root directory entries        224 for HD, 112 for DD';
const text51 = 'Inn      Interleave                              1';
const text52 = 'P        for use on PS/2 Computers';
const text53 = 'V        Skip verifying';
const text69 = 'Bnnn     Force a specified Format-Descriptor     depends on format';
const text70 = 'Gnnn     Use specified GAP-Length                depends on format';
const text71 = 'Fnn      Use specified Sector-Shift              0';
const text54 = 'This program requires DOS 3.2 or higher.';
const text55 = 'VFORMAT - Diskette Formatter with VITAMIN-B Boot Vaccine - Ver 1.50';
const text56 = 'by Christoph H. Hochstätter (Germany) and Alexander V. Sessa (USSR)';
const text57 = 'Heads must be 1 or 2.';
const text58 = 'At least one track should be formatted.';
const text59 = 'Interleave must be from 1 to ';
const text60 = '.';
const text61 = 'WARNING! DOS supports only 1 or 2 sectors per cluster.';
const text62 = 'WARNING! So many tracks could cause damage to your drive.';
const text63 = 'WARNING! DOS supports a maximum of 240 root directory entries.';
const text64 = 'Insert Diskette in drive ';
const text65 = ':';
const text66 = 'Press ENTER when ready (ESC=QUIT)';
const text67 = 'Sector-Shift: ';
const text68 = ', GAP-Length: ';

type tabletyp = array[1..25] of record
                  t,h,s,f:byte;
		end;

     paratyp =  array[0..10] of byte;
     boottyp =  array[28..511] of byte;

     btttyp  =  array[1..20] of record
                  head:  byte;
                  track: byte;
                end;

     bpbtyp  =  record
		  jmp: array[1..3] of byte;  {3 bytes of JMP instruction}
		  oem: array[1..8] of char;  {OEM-Entry}
		  bps: word;                 {Bytes per Sector}
		  spc: byte;                 {Sectors per Cluster}
		  res: word;                 {Reserved Sectors}
		  fat: byte;                 {FAT's}
		  rde: word;                 {Root Entries}
		  sec: word;                 {Total Sectors on Diskette}
		  mds: byte;                 {Media-Deskriptor}
		  spf: word;                 {Sectors per FAT}
		  spt: word;                 {Sectors per Track}
		  hds: word;                 {Sides}
		  boot_code: boottyp;        {Other BOOT Code}
		end;

var regs:       registers;                {Processor-Registers}
    track:      byte;                     {Actual Track}
    head:       byte;                     {Actual Side}
    table:      tabletyp;                 {Formats-Table}
    table2:     array[1..25] of byte;     {Interleave-Table}
    x:          word;                     {Work Variable}
    buffer:     array[0..18432] of byte;  {Buffer for FAT}
    old1E:      pointer;                  {Olf Vector of Parameters List}
    new1E:      ^paratyp;                 {New Vector of Parameters List}
    old13:      pointer;                  {Old Vector of Interrupt 13}
    old58:      pointer;                  {Old Vector of Work Interrupt 58}
    bpb:	bpbtyp;                   {Boot-Sector with BPB}
    chx:        Char;                     {Work Variable}
    lw:         Byte;                     {Drive Phisical Address}
    hds,sec:    word;                     {Sides, Sectors}
    trk:        word;                     {Tracks}
    hd,lwhd:    Boolean;                  {High-Density Flags}
    lwtrk:      byte;                     {max Tracks}
    lwsec:      byte;                     {max Sectors}
    para:	String[5];                {Parameters of Command Line}
    rde:	byte;                     {Root Entries}
    spc:	byte;                     {Sectors per Cluster}
    i,n:	byte;                     {Work Variables}
    j:		integer;                  {Work Variable}
    again:      boolean;                  {INT 13 Flag}
    bttCount:   word;                     {Tracks Counter}
    btt:        btttyp;                   {Tracks Table}
    Offset:     word;                     {Relative Position in FAT}
    Mask:       word;                     {FAT Cluster Mask}
    bytes:	LongInt;                  {Disk Capacity in Bytes}
    bad:        Longint;                  {Bytes in Bad Clusters}
    pc80:	Byte;                     {Mask for 40/80 Track if XT-BIOS}
    at80:       Boolean;                  {TRUE when 80/40 Tracks if AT-BIOS}
    ps2:        Boolean;                  {TRUE when PS2}
    noverify:   Boolean;                  {TRUE when No Verify}
    DiskId:     Byte;                     {Media Descriptor}
    il:         Byte;                     {Interleave Factor}
    gpl:        Byte;                     {GAP Length}
    shift:      Byte;                     {Sector Shift}
    ModelByte:  Byte absolute $F000:$FFFE {XT/AT/386};
    ForceType:  Byte;                     {Forced Media Descriptor}

const para17:  paratyp =($df,$02,$25,$02,17,$1b,$ff,$23,$00,$0f,$08);
      para18a: paratyp =($df,$02,$25,$02,18,$1b,$ff,$02,$00,$0f,$08);
      para18:  paratyp =($df,$02,$25,$02,18,$1b,$ff,$6c,$00,$0f,$08);
      para10:  paratyp =($df,$02,$25,$02,10,$2a,$ff,$2e,$00,$0f,$08);  {GPL 26-36}
      para11:  paratyp =($df,$02,$25,$02,11,$2a,$ff,$02,$00,$0f,$08);
      para15:  paratyp =($df,$02,$25,$02,15,$1b,$ff,$54,$00,$0f,$08);
      para09:  paratyp =($df,$02,$25,$02,09,$2a,$ff,$50,$00,$0f,$08);
      para08:  paratyp =($df,$02,$25,$02,08,$2a,$ff,$58,$00,$0f,$08);
      para20:  paratyp =($df,$02,$25,$02,20,$1b,$ff,$25,$00,$0f,$08);  {GPL 17-33}
      para21:  paratyp =($df,$02,$25,$02,21,$1b,$ff,$0c,$00,$0f,$08);
      para22:  paratyp =($df,$02,$25,$02,22,$1b,$ff,$01,$00,$0f,$08);

      GetPhys: Array[0..14] of Byte =(

            $1E,               {  PUSH DS             }
	    $B8,$40,$00,       {  MOV  AX,40H         }
	    $8E,$D8,           {  MOV  DS,AX          }
            $88,$16,$41,$00,   {  MOV  [41H],DL       }
            $1F,               {  POP  DS             }
            $B8,$01,$01,       {  MOV  AX,101H        }
            $CF);              {  IRET                }

      Help58: Array[0..3] of Byte =(

            $CD,$25,           {  INT  25H            }
            $59,               {  POP  CX             }
            $CF);              {  IRET                }

      boot: boottyp=(
$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$56,$46,$4F,$52,$4D,
$41,$54,$20,$31,$2E,$35,$46,$41,$54,$31,$32,$20,$20,$20,$FA,$FC,
$33,$C0,$8E,$D0,$BC,$00,$7C,$16,$07,$BB,$78,$00,$36,$C5,$37,$1E,
$56,$BF,$2B,$7C,$B9,$0B,$00,$F3,$A4,$06,$1F,$C6,$45,$FE,$0F,$C6,
$45,$F9,$16,$89,$47,$02,$C7,$07,$2B,$7C,$FB,$CD,$13,$72,$6B,$BA,
$00,$F0,$33,$ED,$E8,$D5,$00,$22,$73,$04,$C7,$05,$A5,$FE,$E8,$CB,
$00,$26,$73,$04,$C7,$05,$87,$E9,$E8,$C1,$00,$5E,$73,$04,$C7,$05,
$D2,$EF,$E8,$B7,$00,$72,$73,$04,$C7,$05,$53,$FF,$B6,$C8,$E8,$AB,
$00,$4E,$73,$02,$A5,$A5,$4D,$73,$21,$BE,$DC,$7D,$E8,$97,$00,$98,
$CD,$16,$3C,$6E,$74,$14,$B9,$01,$00,$BA,$00,$00,$B7,$7C,$B8,$01,
$03,$0E,$07,$CD,$13,$EA,$F0,$FF,$00,$F0,$B9,$06,$00,$BA,$00,$00,
$BB,$00,$05,$B8,$01,$02,$CD,$13,$73,$13,$BE,$9F,$7D,$E8,$66,$00,
$98,$CD,$16,$8F,$06,$78,$00,$8F,$06,$7A,$00,$CD,$19,$8A,$47,$0B,
$8A,$67,$2B,$25,$04,$04,$3D,$04,$04,$75,$DF,$BE,$2C,$00,$B7,$07,
$B9,$04,$00,$B6,$01,$A1,$18,$7C,$2A,$C1,$40,$3B,$F0,$77,$02,$8B,
$C6,$50,$B4,$02,$CD,$13,$58,$72,$C1,$98,$2B,$F0,$76,$14,$02,$F8,
$02,$F8,$B1,$01,$FE,$C6,$3A,$36,$1A,$7C,$72,$D9,$FE,$C5,$B6,$00,
$EB,$D3,$8A,$2E,$15,$7C,$B2,$00,$BB,$0C,$00,$B8,$00,$00,$EA,$00,
$00,$70,$00,$E8,$4F,$00,$AC,$0A,$C0,$75,$F8,$C3,$5E,$AC,$56,$98,
$97,$26,$39,$15,$73,$47,$BE,$D1,$7D,$E8,$EA,$FF,$8B,$C7,$D0,$E8,
$D0,$E8,$E8,$1F,$00,$B0,$2D,$E8,$2B,$00,$8B,$05,$E8,$0C,$00,$B0,
$3A,$E8,$21,$00,$89,$15,$83,$EF,$02,$8B,$05,$8A,$E8,$8A,$C4,$E8,
$02,$00,$8A,$C5,$50,$B1,$04,$D2,$E8,$E8,$01,$00,$58,$24,$0F,$04,
$90,$27,$14,$40,$27,$33,$DB,$B4,$0E,$CD,$10,$45,$F9,$C3,$00,$0A,
$0D,$4E,$6F,$20,$73,$79,$73,$74,$65,$6D,$20,$6F,$72,$20,$64,$69,
$73,$6B,$20,$65,$72,$72,$6F,$72,$0A,$0D,$50,$72,$65,$73,$73,$20,
$61,$20,$6B,$65,$79,$20,$74,$6F,$20,$72,$65,$74,$72,$79,$0A,$0D,
$00,$07,$0A,$0D,$49,$6E,$74,$00,$59,$EC,$00,$F0,$0A,$0D,$56,$69,
$72,$75,$73,$20,$73,$74,$65,$72,$69,$6C,$69,$7A,$65,$64,$2E,$20,
$43,$75,$72,$65,$20,$42,$4F,$4F,$54,$3F,$0A,$0D,$07,$00,$55,$AA);

Function ReadKey:Char;
Var r:Registers;
begin
  with r do begin
    ah:=7;
    intr($21,r);
    if al in [3,27] then begin writeln; halt end;
    ReadKey:=chr(al);
  end;
end;

Procedure int13;
var axs: word;
    chs: byte;
    chx: char;
    er:  Boolean;
begin
  again:=false;
  with regs do begin
    axs:=ax;
    repeat
      ax:=axs;
      if trk>43 then dl:=dl or pc80;
      mem[$40:$90+dl]:=DiskId;
      intr($13,regs);
      er:=ah>1;
    until ah<>6;
    if er then begin
      writeln;
      writeln(text01,regs.ah,': T',ch,' H',dh,' S',cl,'-',
              cl+lo(axs)-1,' L',dl,' C',hi(axs));
      writeln(text02);
      repeat
	chx:=Upcase(ReadKey);
        case chx of
	  'A': begin SetIntVec($1E,Old1E); halt; end;
	  'I': er:=false;
          t3 : begin er:=false; again:=true; end;
        end;
      until chx in ['A','I',t3];
    end;
  ax:=axs;
  end;
end;

Procedure GetPhysical(Var lw:Byte);
begin
  with regs do begin
    GetIntVec($58,old58);
    GetIntVec($13,old13);
    SetIntVec($58,@help58);
    SetIntVec($13,@GetPhys);
    al:=lw; cx:=1; dx:=0;
    ds:=seg(buffer); bx:=ofs(buffer);
    intr($58,regs);
    SetIntVec($58,old58);
    SetIntVec($13,old13);
    lw:=mem[$40:$41];
  end;
end;

procedure DriveTyp(Var lw:Byte;Var hd:boolean;Var trk,sec:byte);
begin
  with regs do begin
    ax:=$4409; bl:=lw+1; bh:=0;
    intr($21,regs);
    if (FCarry and Flags) <> 0 then begin
      writeln(text04);
      trk:=0;
      exit;
    end;
    if (dx and $9200)<>0 then begin
      writeln(text05);
      trk:=0;
      exit;
    end;
    ax:=$440f; bl:=lw+1; bh:=0;
    intr($21,regs);
    if (FCarry and Flags)<>0 then begin
      writeln(text04);
      trk:=0;
      exit;
    end;
    ax:=$440d; cx:=$860; bl:=lw+1;
    bh:=0; dx:=ofs(buffer); ds:=seg(buffer);
    intr($21,regs);
    case buffer[1] of
      0: begin trk:=39; sec:= 9; hd:=false; end;
      1: begin trk:=79; sec:=15; hd:=true ; end;
      2: begin trk:=79; sec:= 9; hd:=false; end;
      7: begin trk:=79; sec:=18; hd:=true ; end;
    else
      begin
        writeln(text06);
        trk:=0;
        exit;
      end
    end;
    GetPhysical(lw);
    lw:=lw and $9f;
    if not(lw in [0..3]) then begin
      writeln(text07);
      trk:=0;
      exit;
    end;
    ModelByte:=mem[$f000:$fffe];
    at80:=(ModelByte=$f8) or (ModelByte=$fc); pc80:=0;
    if not(at80) then begin
      es:=seg(buffer); bx:=ofs(buffer);
      ax:=$201; cx:=0;
      dh:=0; dl:=lw+$20;
      intr($13,regs);
      if ah<>1 then
        pc80:=$20
      else begin
        dl:=$40+lw; ax:=$201;
        intr($13,regs);
        if ah<>1 then pc80:=$40;
      end;
    end;
  end;
end;

Procedure ATSetDrive(lw:Byte; trk,sec,Disk,SetUp:Byte);
begin
  with regs do begin
    dh:=lw; ah:=$18; ch:=trk; cl:=sec;
    intr($13,regs);
    if ah>1 then begin
      ah:=$17; al:=SetUp; dl:=lw;
      intr($13,regs);
    end;
    DiskId:=Disk;
    if ForceType=0 then
      mem[$40:$90+lw]:=Disk
    else
      mem[$40:$90+lw]:=ForceType;
  end;
end;

procedure SectorAbsolute(sector:Word;Var hds,trk,sec:Byte);
var h:word;
begin
  sec:=(sector mod bpb.spt)+1;
  h:=sector div bpb.spt;
  trk:=h div bpb.hds;
  hds:=h mod bpb.hds;
end;

Function SectorLogical(hds,trk,sec:Byte):Word;
begin
  SectorLogical:=trk*bpb.hds*bpb.spt+hds*bpb.spt+sec-1;
end;

Function Cluster(Sector: Word):Word;
Var h: byte;
begin
  Cluster:=((Sector-(bpb.rde shr 4)
            -(bpb.spf shl 1)-1)
           div Word(bpb.spc))+2;
end;

Procedure ClusterOffset(Cluster:Word; Var Offset,Mask:Word);
begin
  Offset:=Cluster*3 shr 1;
  if Cluster and 1 = 0 then
    Mask:=$ff7
  else
    Mask:=$ff70;
end;

Procedure format;
Var i:Byte;
begin
  case sec of
    0..8:   new1E:=@para08;
    9:      new1E:=@para09;
    10:     new1E:=@para10;
    11:     new1E:=@para11;
    12..15: new1E:=@para15;
    17:     new1E:=@para17;
    18:     if lwsec>17 then
              new1E:=@para18
            else
              new1E:=@para18a;
    19..20: new1E:=@para20;
    21:     new1E:=@para21;
    22..255:new1E:=@para22;
  end;
  if gpl<>0 then
    new1E^[7]:=gpl
  else
    gpl:=new1E^[7];
  writeln;
  write(text08,chr(lw+$41),': ');
  if hd then writeln('High-Density') else writeln('Double-Density');
  writeln(hds,text09,trk,text10,sec,text11,'Interleave: ',il,text68,gpl);
  writeln(bpb.rde,text12,spc,text13,shift);
  writeln;
  bttCount:=0;
  with regs do begin
    for i:=1 to 25 do begin
      table[i].f:=2;
      table2[i]:=0;
    end;
    i:=1;
    n:=1;
    repeat
      repeat
        while table2[n]<>0 do inc(n);
        if n>sec then n:=1;
      until table2[n]=0;
      table2[n]:=i;
      n:=n+il;
      inc(i);
    until i>sec;
    ax:=0;
    bx:=0;
    dl:=lw;
    if at80 then begin
      if (trk>43) and (sec>11) then ATSetDrive(lw,79,lwsec,$14,5);
      if not(ps2) and (trk>43) and (sec<12) then ATSetDrive(lw,79,9,$53,4);
      if ps2 and (trk>43) and (sec<12) then ATSetDrive(lw,79,9,$97,4);
      if (trk<44) and (sec>11) then ATSetDrive(lw,39,lwsec,$34,3);
      if ps2 and (trk<44) and (sec<12) then ATSetDrive(lw,39,9,$B7,2);
      if not(ps2) and (trk<44) and (sec<12) then ATSetDrive(lw,39,9,$73,2);
    end;
    writeln;
    bpb.jmp[1]:=$EB;
    bpb.jmp[2]:=$3C;
    bpb.jmp[3]:=$90;
    bpb.spt:=sec;
    bpb.hds:=hds;
    bpb.bps:=512;
    bpb.spc:=spc;
    bpb.res:=1;
    bpb.fat:=2;
    bpb.sec:=sec*bpb.hds*trk;
    bpb.boot_code:=boot;
    case bpb.spc of
      1:    if (trk>44) and (bpb.spt in [12..17]) then
               bpb.mds:=$f9
            else
               bpb.mds:=$f0;
      2:    if trk in [1..43] then bpb.mds:=$fd else bpb.mds:=$f9;
      else  bpb.mds:=$f8;
    end;
    bpb.spf:=trunc((bpb.sec-bpb.rde/16+1)*3/1024/bpb.spc);
    bpb.spf:=trunc((bpb.sec-bpb.rde/16+1-2*bpb.spf)*3/1024/bpb.spc)+1;
    SectorAbsolute((bpb.spf shl 1)+1,dh,ch,cl);
    bpb.boot_code[$CB]:=cl;
    bpb.boot_code[$CC]:=ch;
    bpb.boot_code[$CF]:=dh;
    SectorAbsolute((bpb.rde shr 4)+(bpb.spf shl 1)+1,dh,ch,cl);
    bpb.boot_code[$101]:=cl;
    bpb.boot_code[$102]:=ch;
    bpb.boot_code[$104]:=dh;
    bpb.boot_code[$139]:=(bpb.rde shr 4)+(bpb.spf shl 1)+1;
    dl:=lw;
    ax:=0;
    repeat int13 until not again;
    SetIntVec($1E,new1E);
    for track:=0 to trk-1 do begin
      n:=shift mod sec;
      for i:=1 to sec do begin
        table[i].s:=table2[(i+n-1) mod sec + 1];
        table[i].t:=track;
      end;
      for head:=0 to hds-1 do begin
        write(text14,head,text15,track);
        x:=SectorLogical(head,track,1);
        write(text16,x);
        x:=Cluster(x);
        if (x>1) and (x<10000) then write(', Cluster: ',x);
        for i:=1 to sec do
	  table[i].h:=head;
        repeat
          ah:=5;
          al:=sec;
          dl:=lw;
          dh:=head;
          ch:=track;
          cl:=1;
          es:=seg(table);
          bx:=ofs(table);
          write('  F');
          mem[$40:$41]:=0;
          int13;
          write(#8,'V        ');write(#13);
          if not(again or noverify) then begin
            ah:=2;
            dl:=lw;
	    es:=seg(buffer);
	    bx:=ofs(buffer);
            int13;
          end;
        until not again;
        if (FCarry and flags) <> 0 then begin
          if (x<2) or (x>10000) then begin
            writeln(text17);
            SetIntVec($1E,Old1E);
            halt;
          end;
          inc(bttCount);
          if bttCount>20 then begin
            writeln(text18,20*sec,text19);
            SetIntVec($1E,Old1E);
            halt;
          end;
          btt[bttCount].track:=track;
          btt[bttCount].head:=head;
          writeln(text14,head,text15,track,text20);
        end;
      end;
    end;
    SetIntVec($1E,Old1E);
  end;
end;

Procedure WriteBootSect;
begin
  with regs do begin
    bpb.oem:='Vaccined';
    writeln; writeln(text22,bpb.sec);
    writeln(text23,bpb.spt); writeln(text24,bpb.hds);
    writeln(text29,bpb.spf); writeln(text30,Cluster(bpb.sec)-2);
    dh:=0; dl:=lw; ch:=0; cl:=1;
    al:=1; ah:=3; es:=seg(bpb);
    bx:=ofs(bpb);
    repeat int13 until not again;
    fillchar(buffer[3],18430,#0);
    buffer[0]:=bpb.mds;
    buffer[1]:=$ff;
    buffer[2]:=$ff;
    bad:=0;
    for i:=1 to bttCount do
      for j:=1 to sec do begin
        x:=SectorLogical(btt[i].head,btt[i].track,j);
        x:=Cluster(x);
        ClusterOffset(x,Offset,Mask);
        if buffer[Offset] and Lo(Mask)=0 then inc(bad,bpb.spc*512);
        buffer[Offset]:=buffer[Offset] or Lo(Mask);
        buffer[Offset+1]:=buffer[Offset+1] or Hi(Mask);
      end;
    es:=seg(buffer);
    bx:=ofs(buffer);
    inc(cl);
    al:=bpb.spf;
    repeat int13 until not again;
    SectorAbsolute(bpb.spf+1,dh,ch,cl);
    ah:=3;
    dl:=lw;
    if bpb.spf+cl>sec+1 then al:=sec-cl+1;
    repeat int13 until not again;
    if bpb.spf+cl>sec+1 then begin
      bx:=bx+al*512;
      al:=bpb.spf-al;
      inc(dh);
      cl:=1;
      repeat int13 until not again;
    end;
    Bytes:=LongInt(Cluster(bpb.sec)-2)*512*LongInt(bpb.spc);
    writeln;
    writeln(Bytes:9,text31);
    if bad<>0 then writeln(bad:9,text32);
    writeln(Bytes-bad:9,text33);
    writeln;
  end;
end;

Procedure DrivePrt;
begin
  writeln;
  if lwtrk=0 then begin
    writeln(text34);
    exit;
  end;
  write(text35,chr(lw+$41));
  if lwhd then
    write(': High-Density, ')
  else
    write(': Double-Density, ');
  writeln(lwtrk+1,text10,lwsec,text11);
  write(text36);
  if pc80=$20 then writeln(text37);
  if pc80=$40 then writeln(text38);
  if at80 then writeln(text39);
  if not(at80) and (pc80=0) then writeln(text40);
  writeln;
end;

Procedure SyntaxError;
begin
  writeln; writeln(text42); writeln(text43); writeln;
  writeln(text44); writeln; writeln(text45);
  writeln(text46); writeln(text47); writeln(text48);
  writeln(text49); writeln(text50); writeln(text51);
  writeln(text52); writeln(text53);
  writeln(text69); writeln(text70);
  writeln(text71); writeln;
  halt;
end;

Procedure CheckDos;
var Version: Word;
begin
  Version:=swap(DosVersion);
  if Version<$314 then begin
    writeln(text54);
    halt;
  end;
end;

begin
  writeln;
  writeln(text55);
  writeln(text56);
  CheckDos;
  GetIntVec($1E,old1E);
  new1E:=old1E;
  para:=paramstr(1);
  ps2:=false;
  noverify:=false;
  if (length(para)<>2) or (para[2]<>':') then SyntaxError;
  lw:=ord(UpCase(para[1]))-$41;
  DriveTyp(lw,lwhd,lwtrk,lwsec);
  DrivePrt;
  if (lwtrk=0) and (para<>'') then halt;
  rde:=0;
  il:=0;
  spc:=0;
  gpl:=0;
  shift:=0;
  ForceType:=0;
  trk:=lwtrk+1;
  sec:=lwsec;
  hds:=2;
  for i:=2 to paramcount do
    if paramstr(i)<>'' then begin
      para:=paramstr(i);
      chx:=para[1];
      if length(para)=1 then
        case UpCase(chx) of
          'P': ps2:=true;
          'V': noverify:=true;
        end
      else begin
        val(copy(para,2,255),n,j);
        if j<>0 then SyntaxError;
        case UpCase(para[1]) of
          'T':trk:=n;
          'H':hds:=n;
          'S':sec:=n;
          'D':rde:=n;
          'C':spc:=n;
          'I':il:=n;
          'G':gpl:=n;
          'F':shift:=n;
          'B':ForceType:=n;
        end;
      end;
    end;
  if sec>11 then hd:=true else hd:=false;
  if rde=0 then
    case hd of
      true:  rde:=224;
      false: rde:=112;
    end;
  if spc=0 then
    case hd of
      true:  spc:=1;
      false: spc:=2;
    end;
  if il=0 then
    if sec-lwsec in [3..8] then il:=2 else il:=1;
  if not(hds in [1..2]) then begin
    writeln(text57);
    halt;
  end;
  if trk<1 then begin
    writeln(text58);
    halt;
  end;
  if il>=pred(sec) then begin
    writeln(text59,pred(sec),text60);
    halt;
  end;
  if not(spc in [1..2]) then
    writeln(text61);
  if ShortInt(trk-lwtrk)>4 then
    writeln(text62);
  if rde>240 then
    writeln(text63);
  if rde and 15 <> 0 then inc(rde,16);
  rde:=rde shr 4;
  if (spc=2) and (rde and 1 = 0) then inc(rde);
  bpb.rde:=rde shl 4;
  while TRUE=TRUE do begin
    writeln;
    writeln(text64,chr(lw+$41),text65);
    writeln(text66);
    chx:=ReadKey;
    format;
    WriteBootSect;
  end;
end.
