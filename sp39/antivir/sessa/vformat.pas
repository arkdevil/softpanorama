{$A+,B-,D+,E+,F-,L+,N-,O-,R-,S-,V-}
{$M 8192,0,0}
PROGRAM VFORMAT;

USES dos,auxdos,baseconv,desqview;

  {Written by Christoph H. Hochstätter}
  {Modified by Alexander V. Sessa}
  {Last Updated: 4-Nov-1991}
  {Donated to the Public-Domain for non-commercial usage}
  {Compiled in Turbo-Pascal 6.0}


const text02 = '(A)bort (R)etry (I)gnore ? ';
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
const text15 = #9#9'Track: ';
const text16 = 'Sector: ';
const text17 = 'Format error in system area: Program aborted.';
const text18 = 'More than ';
const text19 = ' sectors unreadable. Program aborted.';
const text20 = 'marked as bad.';
const text21 = 'proceed by Sectors:';
const text22 = 'Total sectors on disk:  ';
const text23 = 'Sectors per track:      ';
const text24 = 'Heads:                  ';
const text29 = 'Sectors per FAT:        ';
const text30 = 'Total clusters on disk: ';
const text79 = 'Volume serial number:   ';
const text34 = 'This drive cannot be formatted.';
const text35 = 'Drive is physical ';
const text36 = 'BIOS double-step support: ';
const text37 = 'XT-like';
const text38 = 'EPSON QX-16 like';
const text39 = 'AT-like';
const text40 = 'Not available or unknown';
const text41 = 'Syntax Error.';
const text42 = 'Usage is: VFORMAT drive: [mode] [options]';
const text43 = ' Example: VFORMAT A: U t41 h2 n10 C1 D112';
const text44 = 'Mode:        [default - MS/DOS-5.0-like "intellectual" format]';
const text45 = 'U     Uncoditional (old simple) format         R     skip veRifying';
const text46 = 'W     format Without erase (Cure format)       Q     Quick (track 0/1 only)';
const text47 = 'P[nn] Packet mode (format nn diskettes)        K     don'#39't wait Keyboard';
const text48 = 'Z     restore Zero track (unformat)'#10#10#13'Options:'#10#13;
const text49 = 'Tnn   number of Tracks       [default 40/80]   Inn   set Interleave factor';
const text50 = 'Hnn   number of Heads                    [2]   Gnnn  specify GAP-length';
const text51 = 'Nnn   Number of Sectors per track  [9/15/18]   Xnn   slide sectors (head)';
const text52 = 'Cn    sectors per Cluster    [HD - 1/DD - 2]   Ynn   slide sectors (track)';
const text53 = 'Dnnn  root Directory entries [HD-224/DD-112]   Bnnn  force disk type Byte';
const text69 = 'Fnnn  specify diskette Format {360,1.44 etc}   Mnnn  set Media descriptor';
const text70 = 'V[...] write Volume label                      A     use BIOS-calls only';
const text71 = 'O - Olivetti 720kB     1 - single side disk    4 - 360kB     8 - 8-sectors';
const text54 = 'This program requires DOS 3.2 or higher.';
const text55 = 'VFORMAT - Diskette Formatter with VITAMIN-B Boot Vaccine - Ver 1.90';
const text56 = 'by Christoph H. Hochstätter (Germany) and Alexander V. Sessa (USSR)';
const text57 = 'Heads must be 1 or 2.';
const text58 = 'At least one track should be formatted.';
const text59 = 'Interleave must be from 1 to ';
const text60 = '.';
const text61 = 'WARNING! DOS supports only 1 or 2 sectors per cluster.';
const text62 = 'WARNING! So many tracks could cause damage to your drive.';
const text63 = 'WARNING! DOS supports a maximum of 240 root directory entries.';
const text64 = 'Insert new Diskette in drive ';
const text65 = ':';
const text66 = 'Press ENTER when ready (ESC=QUIT)';
const text67 = 'Data Transfer Rate: ';
const text68 = ', GAP-Length: ';
const text72 = 'ON';
const text73 = 'OFF';
const text74 = 'Enter Volume Name (max. 11 characters): ';
const text75 = 'Error creating volume label.';
const text76 = 'Syntax Error in FDFORMAT.CFG.';
const text77 = 'Error reading FDFORMAT.CFG.';
const text80 = 'Error building new disk-parameter-block. DOS-Error: ';
const text81 = 'Cannot read old diskette parameters. Format without erase impossible.';
CONST text31 = ' Bytes total';
CONST text32 = ' Bytes in boot-sector';
CONST text33 = ' Bytes in Root-Directory';
CONST text82 = ' Bytes in the FAT';
CONST text83 = ' Bytes in bad sectors';
CONST text84 = ' Bytes available for files';
CONST text85 = ' Bytes actually free';
CONST text86 = 'Setting drive parameters via track/sector-combination...';
CONST text87 = 'Setting drive parameters via media typ...';
CONST text88 = 'successful';
CONST text89 = 'Error';
CONST text90 = 'WARNING! BIOS-Media-Byte could not set correctly.';
CONST text91 = 'BIOS-media-byte is: ';
CONST text92 = 'x, should be: ';
CONST text93 = 'Drive parameters set via direct write to BIOS-media-byte.';
CONST text94 = 'Program aborted by user.';
CONST error02 = 'Address mark not found';
CONST error03 = 'Disk is write protected';
CONST error04 = 'Sector not found';
CONST error08 = 'DMA overrun';
CONST error09 = 'DMA accross 64 kB boundary';
CONST error0c = 'Format not compatible with data transfer rate';
CONST error10 = 'CRC error';
CONST error20 = 'controller/adapter error';
CONST error40 = 'seek error';
CONST error80 = 'No disk in drive';
CONST errorxx = 'Unknown error';

CONST maxform = 15;

CONST TRead   = 2;
CONST TWrite  = 3;
CONST TVerify = 4;
CONST TFormat = 5;

TYPE tabletyp = ARRAY[1..25] OF RECORD
                                  t,h,s,f:Byte;
                                END;

  paratyp =  ARRAY[0..10] OF Byte;
  boottyp =  ARRAY[62..511] OF Byte;

  bsttyp  =  ARRAY[1..512] OF RECORD
                               head:  Byte;
                               track: Byte;
                               sector:Byte;
                             END;
  ftabtyp = ARRAY[1..maxform] OF RECORD
                                   fmt: Word;
                                   trk: Byte;
                                   sec: Byte;
                                   hds: Byte;
                                 END;

  bpbtyp  =  RECORD
               jmp: ARRAY[1..3] OF Byte;                               {3 bytes of JMP instruction}
               oem: ARRAY[1..8] OF Char;                                                {OEM-Entry}
               bps: Word;                                                        {Bytes per Sector}
               spc: Byte;                                                     {Sectors per Cluster}
               res: Word;                                                        {Reserved Sectors}
               fat: Byte;                                                                   {FAT's}
               rde: Word;                                                            {Root Entries}
               sec: Word;                                               {Total Sectors on Diskette}
               mds: Byte;                                                        {Media-Deskriptor}
               spf: Word;                                                         {Sectors per FAT}
               spt: Word;                                                       {Sectors per Track}
               hds: Word;                                                                   {Sides}
               shh: LongInt;                                                       {Hidden Sectors}
               lse: LongInt;                                       {Total Sectors for BIGDOS Disks}
               pdn: Word;                                                   {Physical Drive Number}
               ebs: Byte;                                                 {Extended Boot Signature}
               vsn: LongInt;                                                 {Volume Serial-Number}
               vlb: ARRAY[1..11] OF Char;                                            {Volume Label}
               fsi: ARRAY[1..8] OF Char;                                           {File System Id}
               boot_code: boottyp;                                           {Buffer for BOOT-Code}
             END;

  bdib = RECORD
           flag   : Byte;                                                         {Bitmapped flags}
           dtyp   : Byte;                             {Drive Type: 0,1,2 or 7 supported by VFORMAT}
           dflag  : Word;                                                         {Bitmapped flags}
           noc    : Word;                                                     {Number of cylinders}
           mt     : Byte;                                                              {Media Type}
           bpb    : ARRAY[0..30] OF Byte;                                                     {BPB}
           nos    : Word;                                             {Number of sectors per track}
           sly    : ARRAY[0..4598] OF RECORD                                        {sector layout}
                                        num: Word;                                  {Sector Number}
                                        siz: Word;                                 {Size of sector}
                                      END;
         END;

VAR regs:     registers;                                                      {Processor Registers}
  track:      Byte;                                                                  {Actual Track}
  head:       Byte;                                                                   {Actual Side}
  table:      tabletyp;                                                             {Formats Table}
  table2:     ARRAY[1..25] OF Byte;                                              {Interleave Table}
  x:          Word;                                                                 {Work variable}
  buffer:     ARRAY[0..18435] OF Byte;                                                {Work Buffer}
  old1E:      Pointer;                                               {Old vector of Parameter list}
  new1E:      ^paratyp;                                              {New vector of Parameter list}
  old13:      Pointer;                                                 {Old vector of Interrupt 13}
  chx:        Char;                                                                 {Work variable}
  lw:         Byte;                                                                {Phisical Drive}
  hds,sec:    Word;                                                                {Sides, Sectors}
  trk:        Word;                                                                        {Tracks}
  hd,lwhd:    Boolean;                                                         {High-Density Flags}
  lwtrk:      Byte;                                                           {max Tracks on Drive}
  lwsec:      Byte;                                                          {max Sectors on Drive}
  para:       ARRAY[1..50] OF String[20];                              {Parameters of Command line}
  rde:        Byte;                                                        {Root directory entries}
  srde:       Byte;                                                  {Saved root directory entries}
  spc:        Byte;                                                           {Sectors per Cluster}
  i:          Byte;                                                                {Work variables}
  j,n:        Integer;                                                              {Work variable}
  again:      Boolean;                                                     {Flag: try INT 13 again}
  bstCount:   Word;                                                           {Bad sectors counter}
  bst:        bsttyp;                                                        {Table of bad sectors}
  Offset:     Word;                                                      {Relative Position in FAT}
  Mask:       Word;                                                         {Mask for Cluster link}
  bytes:      LongInt;                                                        {Total bytes on disk}
  bytesub:    LongInt;                                                       {Bytes in system area}
  at80:       Boolean;                                       {TRUE, when 80/40 tracks with AT-BIOS}
  DiskId:     Byte;                                                    {Disk type byte for AT-BIOS}
  il:         Byte;                                                             {Interleave-Factor}
  gpl:        Byte;                                                                    {GAP-Length}
  shiftt:     Byte;                                                       {Sector Shift for Tracks}
  shifth:     Byte;                                                        {Sector Shift for Heads}
  ModelByte:  Byte ABSOLUTE $F000:$FFFE;                                                {XT/AT/386}
  ForceType:  Byte;                                                         {User specified Diskid}
  ForceMedia: Byte;                                               {User specified Media-Deckriptor}
  dosdrive:   Byte;                                                          {DOS Drive Identifier}
  PCount:     Byte;                                                            {Parameters counter}
  found:      Boolean;                                                         {Fixed Format found}
{ sys:        Boolean;}                                                               {System disk}
  lwtab:      ARRAY[0..3] OF Byte ABSOLUTE $40:$90;                               {Table of Drives}
  dlabel:     String[15];                                                          {Diskette Label}
  setlabel:   Boolean;                                                                  {Set Label}
  batch:      Boolean;                                                         {Don't wait any Key}
  cfgat80:    Boolean;                                         {TRUE, when Drive configured for AT}
  cfgpc80:    Boolean;                                         {TRUE, when Drive configured for XT}
  cfgdrive:   Byte;                                                              {Configured Drive}
  bios:       Boolean;                                                  {TRUE, when use BIOS-calls}
  pc80:       Byte;                                                  {Mask of 80 track for XT-BIOS}
  pc40:       Byte;                                                  {Mask of 80 track for XT-BIOS}
  v720:       Byte;                                                       {Media Typ for 720 kByte}
  v360:       Byte;                                                       {Media Typ for 360 kByte}
  v12:        Byte;                                                       {Media Typ for 1.2 MByte}
  v144:       Byte;                                                      {Media Typ for 1.44 MByte}
  lwphys:     Byte;                                                                {Physical Drive}
  NormExit:   Pointer;                                                      {Normal Exit-Procedure}
  packet:     Byte;                                                         {Packet format counter}

CONST para17: paratyp =($df,$02,$25,$02,17,$02,$ff,$23,$f6,$0f,$08);
  para18a:    paratyp =($df,$02,$25,$02,18,$02,$ff,$02,$f6,$0f,$08);
  para18:     paratyp =($df,$02,$25,$02,18,$02,$ff,$6c,$f6,$0f,$08);
  para10:     paratyp =($df,$02,$25,$02,10,$02,$ff,$2e,$f6,$0f,$08);                    {GPL 26-36}
  para11:     paratyp =($df,$02,$25,$02,11,$02,$ff,$02,$f6,$0f,$08);
  para15:     paratyp =($df,$02,$25,$02,15,$02,$ff,$54,$f6,$0f,$08);
  para09:     paratyp =($df,$02,$25,$02,09,$02,$ff,$50,$f6,$0f,$08);
  para08:     paratyp =($df,$02,$25,$02,08,$02,$ff,$58,$f6,$0f,$08);
  para20:     paratyp =($df,$02,$25,$02,20,$02,$ff,$2a,$f6,$0f,$08);                    {GPL 17-33}
  para21:     paratyp =($df,$02,$25,$02,21,$02,$ff,$0c,$f6,$0f,$08);
  para22:     paratyp =($df,$02,$25,$02,22,$02,$ff,$01,$f6,$0f,$08);

  ftab:    ftabtyp = ((fmt:360;trk:40;sec:9;hds:2),                      {Requires 360 kByte Drive}
                      (fmt:400;trk:40;sec:10;hds:2),                     {Requires 360 kByte Drive}
                      (fmt:410;trk:41;sec:10;hds:2),                     {Requires 360 kByte Drive}
                      (fmt:720;trk:80;sec:9;hds:2),                      {Requires 720 kByte Drive}
                      (fmt:800;trk:80;sec:10;hds:2),                     {Requires 720 kByte Drive}
                      (fmt:820;trk:82;sec:10;hds:2),                     {Requires 720 kByte Drive}
                      (fmt:120;trk:80;sec:15;hds:2),                     {Requires 1.2 MByte Drive}
                      (fmt:12;trk:80;sec:15;hds:2),                      {Requires 1.2 MByte Drive}
                      (fmt:144;trk:80;sec:18;hds:2),                     {Requires 1.2 MByte Drive}
                      (fmt:14;trk:80;sec:18;hds:2),                      {Requires 1.2 MByte Drive}
                      (fmt:148;trk:82;sec:18;hds:2),                     {Requires 1.2 MByte Drive}
                      (fmt:16;trk:80;sec:20;hds:2),                      {Requires 1.4 MByte Drive}
                      (fmt:164;trk:82;sec:20;hds:2),                     {Requires 1.4 MByte Drive}
                      (fmt:168;trk:80;sec:21;hds:2),                     {Requires 1.4 MByte Drive}
                      (fmt:172;trk:82;sec:21;hds:2));                    {Requires 1.4 MByte Drive}

  swchar:       Char      ='/';                                               {Default-Switch-Char}
  Quick:        Boolean   =False;                                                    {Quick-Format}
  noformat:     Boolean   =True;                                              {Don't really format}
  noverify:     Boolean   =False;                                                    {Don't verify}
  fwe:          Boolean   =False;                                            {Format without erase}
  safe:         Boolean   =True;                                                   {Noformat again}
  ssafe:        Boolean   =True;                                                       {Safe again}
  bad:          LongInt   =0;                                                {Bytes in bad Sectors}
  ExitRequest:  Boolean   =False;                                               {User interruption}
  slow:         Boolean   =False;                                        {Operate track by sectors}

  PROCEDURE GetPhys; Far; Assembler;
    ASM
      push  ds
      mov   ax,Seg @data
      mov   ds,ax
      mov   ds:lwphys,dl
      pop   ds
      mov   ax,101h
      iret
    END;

  CONST bpb: bpbtyp = (

    jmp      : ($EB,$42,$90);
    oem      : 'Vaccined';
    bps      : 512;
    spc      : 0;
    res      : 1;
    fat      : 2;
    rde      : 0;
    sec      : 0;
    mds      : 0;
    spf      : 0;
    spt      : 0;
    hds      : 2;
    shh      : 0;
    lse      : 0;
    pdn      : 0;
    ebs      : $29;
    vsn      : 0;
    vlb      : '           ';
    fsi      : 'FAT12   ';
    boot_code: (
$2E,$80,
$26,$90,$04,$DF,$FA,$FC,$33,$C0,$8E,$D0,$BC,$00,$7C,$16,$07,$BB,
$78,$00,$36,$C5,$37,$1E,$56,$BF,$2B,$7C,$B9,$0B,$00,$F3,$A4,$06,
$1F,$C6,$45,$FE,$0F,$C6,$45,$F9,$16,$89,$47,$02,$C7,$07,$2B,$7C,
$FB,$CD,$13,$72,$6B,$BA,$00,$F0,$33,$ED,$E8,$CD,$00,$22,$73,$04,
$C7,$05,$A5,$FE,$E8,$C3,$00,$26,$73,$04,$C7,$05,$87,$E9,$E8,$B9,
$00,$5E,$73,$04,$C7,$05,$D2,$EF,$E8,$AF,$00,$72,$73,$04,$C7,$05,
$53,$FF,$B6,$C8,$E8,$A3,$00,$4E,$73,$02,$A5,$A5,$4D,$73,$21,$BE,
$DC,$7D,$E8,$8F,$00,$98,$CD,$16,$3C,$6E,$74,$14,$B9,$01,$00,$BA,
$00,$00,$B7,$7C,$B8,$01,$03,$0E,$07,$CD,$13,$EA,$F0,$FF,$00,$F0,
$B9,$06,$00,$BA,$00,$00,$BB,$00,$05,$B8,$01,$02,$CD,$13,$73,$13,
$BE,$9F,$7D,$E8,$5E,$00,$98,$CD,$16,$8F,$06,$78,$00,$8F,$06,$7A,
$00,$CD,$19,$80,$7F,$0B,$04,$74,$E7,$BE,$2C,$00,$B7,$07,$B9,$04,
$00,$B6,$01,$A1,$18,$7C,$2A,$C1,$40,$3B,$F0,$77,$02,$8B,$C6,$50,
$B4,$02,$CD,$13,$58,$72,$C9,$98,$2B,$F0,$76,$14,$02,$F8,$02,$F8,
$B1,$01,$FE,$C6,$3A,$36,$1A,$7C,$72,$D9,$FE,$C5,$B6,$00,$EB,$D3,
$8A,$2E,$15,$7C,$B2,$00,$BB,$0C,$00,$B8,$00,$00,$EA,$00,$00,$70,
$00,$E8,$4F,$00,$AC,$0A,$C0,$75,$F8,$C3,$5E,$AC,$56,$98,$97,$26,
$39,$15,$73,$47,$BE,$D1,$7D,$E8,$EA,$FF,$8B,$C7,$D0,$E8,$D0,$E8,
$E8,$1F,$00,$B0,$2D,$E8,$2B,$00,$8B,$05,$E8,$0C,$00,$B0,$3A,$E8,
$21,$00,$89,$15,$83,$EF,$02,$8B,$05,$8A,$E8,$8A,$C4,$E8,$02,$00,
$8A,$C5,$50,$B1,$04,$D2,$E8,$E8,$01,$00,$58,$24,$0F,$04,$90,$27,
$14,$40,$27,$33,$DB,$B4,$0E,$CD,$10,$45,$F9,$C3,$00,$00,$00,$0A,
$0D,$4E,$6F,$20,$73,$79,$73,$74,$65,$6D,$20,$6F,$72,$20,$64,$69,
$73,$6B,$20,$65,$72,$72,$6F,$72,$0A,$0D,$50,$72,$65,$73,$73,$20,
$61,$20,$6B,$65,$79,$20,$74,$6F,$20,$72,$65,$74,$72,$79,$0A,$0D,
$00,$07,$0A,$0D,$49,$6E,$74,$00,$59,$EC,$00,$F0,$0A,$0D,$56,$69,
$72,$75,$73,$20,$73,$74,$65,$72,$69,$6C,$69,$7A,$65,$64,$2E,$20,
$43,$75,$72,$65,$20,$42,$4F,$4F,$54,$3F,$0A,$0D,$07,$00,$55,$AA
      ));

    FUNCTION ReadKey:Char;
    VAR r:registers;
    BEGIN
      GiveUpIdle;
      WITH r DO BEGIN
        ah:=7;
        intr($21,r);
        IF al IN [3,27] THEN BEGIN
          WriteLn;
          Halt(4);
        END;
        ReadKey:=Chr(al);
      END;
    END;

      PROCEDURE RequestAbort; Far;
      BEGIN
        SetIntVec($1E,old1E);
        SetIntVec($13,old13);
        DefExitProc;
      END;

      PROCEDURE ConfigError;
      BEGIN
        WriteLn(stderr,#10#13,text76);
        Halt(16);
      END;

      PROCEDURE GetValue(x,y:String;VAR Value:Byte);
      VAR i,k: Byte;
        j:   Integer;
      BEGIN
        y:=' '+y+'=';
        i:=pos(y,x);
        IF i<>0 THEN BEGIN
          i:=i+Length(y);
          WHILE x[i]=' ' DO Inc(i);
          IF i>Length(x) THEN ConfigError;
          k:=i;
          WHILE x[k]<>' ' DO Inc(k);
          IF x[i]<>'$' THEN BEGIN
            Val(Copy(x,i,k-i),Value,j);
            IF j<>0 THEN ConfigError;
          END ELSE BEGIN
            Value:=dezh(Copy(x,i+1,k-i-1));
            IF BaseError<>0 THEN ConfigError;
          END;
        END;
      END;

      PROCEDURE CfgRead;
      VAR f: Text;
        x: String;
        i: Byte;
      BEGIN
        cfgat80:=False;
        cfgpc80:=False;
        cfgdrive:=255;
        bios:=False;
        pc80:=0;
        pc40:=0;
        v720:=0;
        v360:=0;
        v12:=0;
        v144:=0;
        x:=FSearch('FDFORMAT.CFG',GetEnv('PATH'));
        IF x<>'' THEN BEGIN
          Assign(f,x);
          {$I-} Reset(f); {$I+}
          IF IoResult=0 THEN BEGIN
            WHILE NOT eof(f) DO BEGIN
              ReadLn(f,x);
              x:=x+' ';
              FOR i:=1 TO Length(x) DO x[i]:=Upcase(x[i]);
              IF Copy(x,1,2)=para[1] THEN BEGIN
                IF pos(' BIOS ',x)<>0 THEN bios:=True;
                IF pos(' AT ',x)<>0 THEN cfgat80:=True;
                GetValue(x,'F',cfgdrive);
                IF NOT(cfgdrive IN [0,1,2,7,255]) THEN ConfigError;
                IF pos(' XT ',x)<>0 THEN cfgpc80:=True;
                GetValue(x,'40',pc40);
                GetValue(x,'80',pc80);
                GetValue(x,'360',v360);
                GetValue(x,'720',v720);
                GetValue(x,'1.2',v12);
                GetValue(x,'1.44',v144);
                GetValue(x,'X',shifth);
                GetValue(x,'Y',shiftt);
              END;
              IF cfgat80 AND cfgpc80 THEN ConfigError;
            END;
            {$I-} Close(f); {$I+}
          END ELSE BEGIN
            WriteLn(stderr,#10#13,text77);
            Halt(8);
          END;
        END;
      END;

      PROCEDURE int13;
      VAR axs: Word;
        chx: Char;
      BEGIN
        again:=False;
        WITH regs DO BEGIN
          axs:=ax;
          REPEAT
            GiveUpCPU;
            ax:=axs;
            IF ah IN [2,3,4,5] THEN SetIntVec($1E,new1E);
            IF trk>43 THEN dl:=dl OR pc80 ELSE dl:=dl OR pc40;
            IF NOT(bios) THEN lwtab[dl]:=DiskId;
            intr($13,regs);
            SetIntVec($1E,old1E);
            GiveUpCPU;
          UNTIL ah<>6;
          IF ah>1 THEN BEGIN
            Write(stderr,#10#13,text14,dh,text15,ch);
            IF slow THEN Write(stderr,#9,text16,cl);
            CASE regs.ah OF
              $02: Write(stderr,#9,error02);
              $03: Write(stderr,#9,error03);
              $04: Write(stderr,#9,error04);
              $08: Write(stderr,#9,error08);
              $09: Write(stderr,#9,error09);
              $0c: Write(stderr,#9,error0c);
              $10: Write(stderr,#9,error10);
              $20: Write(stderr,#9,error20);
              $40: Write(stderr,#9,error40);
              $80: Write(stderr,#9,error80);
              ELSE Write(stderr,#9,errorxx);
            END;
            WriteLn(stderr,'.');
            Write(text14,head,text15,track,#9);
            IF (slow AND fwe) OR ((ah<>2) AND (ah<>4) AND (ah<>16)) THEN BEGIN
              WriteLn(stderr,text02);
              REPEAT
                chx:=Upcase(ReadKey);
                CASE chx OF
                  'A': Halt(4);
                  'R': again:=True;
                END;
              UNTIL chx IN ['A','I','R'];
            END;
          END;
          ax:=axs;
        END;
      END;


      PROCEDURE MakeTrack(Operation:Byte);
      VAR csec: Byte;
      BEGIN
        WITH regs DO BEGIN
          ah:=Operation;
          al:=sec;
          dl:=lw;
          dh:=head;
          ch:=track;
          cl:=1;
          es:=Seg(buffer);
          bx:=Ofs(buffer);
          int13;
          IF (FCarry AND Flags) <> 0 THEN BEGIN
            IF noformat AND (Operation=TVerify) THEN BEGIN
              noformat:=False;
              again:=True;
            END ELSE BEGIN
              slow:=True;
              Writeln(stderr,text21);
              FOR csec:=1 TO sec DO BEGIN
                ah:=Operation;
                al:=1;
                dl:=lw;
                dh:=head;
                ch:=track;
                cl:=csec;
                es:=Seg(buffer);
                bx:=Ofs(buffer)+(csec-1)*512;
                int13;
                IF ((FCarry AND Flags) <> 0) AND
                   (Operation=TVerify) AND (NOT again) THEN BEGIN
                  IF (track=0) THEN BEGIN
                    WriteLn(stderr,text17);
                    Halt(2);
                  END;
                  Inc(bstCount);
                  IF bstCount>512 THEN BEGIN
                    WriteLn(stderr,text18,512,text19);
                    Halt(2);
                  END;
                  bst[bstCount].track:=track;
                  bst[bstCount].head:=head;
                  bst[bstCount].sector:=csec;
                  WriteLn(stderr,text16,csec,#9,text20);
                END;
              END;
            END;
          END;
          slow:=False;
        END;
      END;


      PROCEDURE parse;
      VAR j:    Byte;
        argstr: String[80];
      BEGIN
        argstr:='';
        FOR j:=1 TO 50 DO para[j]:='';
        FOR j:=1 TO ParamCount DO argstr:=argstr+' '+ParamStr(j);
        FOR j:=1 TO Length(argstr) DO argstr[j]:=Upcase(argstr[j]);
        PCount:=0;
        FOR j:=1 TO Length(argstr) DO BEGIN
          IF argstr[j] IN [swchar,' ','-','/']
          THEN
            Inc(PCount)
          ELSE IF (NOT(argstr[j] IN [':','.'])) OR (PCount=1)
          THEN
            para[PCount]:=para[PCount]+argstr[j];
        END;
      END;

      FUNCTION GetPhysical(lw:Byte):Byte;
      BEGIN
        WITH regs DO BEGIN
          SetIntVec($13,@GetPhys);
          ASM
            cli
            mov  al,lw
            mov  cx,1
            xor  dx,dx
            mov  bx,offset buffer
            push bp                  {DOS 3 alters BP, DOS 4 & 5 don't}
            int  25h
            pop  cx
            pop  bp
          END;
          SetIntVec($13,old13);
          ASM
            sti
          END;
          GetPhysical:=lwphys;
        END;
      END;

      PROCEDURE DriveTyp(VAR lw:Byte;VAR hd:Boolean;VAR trk,sec:Byte);
      BEGIN
        WITH regs DO BEGIN
          ax:=$4409; bx:=lw+1;
          intr($21,regs);
          IF (FCarry AND Flags) <> 0 THEN BEGIN
            WriteLn(stderr,text04);
            trk:=0;
            Exit;
          END;
          IF (dx AND $9200)<>0 THEN BEGIN
            WriteLn(stderr,text05);
            trk:=0;
            Exit;
          END;
          ax:=$440f; bx:=lw+1;
          intr($21,regs);
          IF (FCarry AND Flags)<>0 THEN BEGIN
            WriteLn(stderr,text04);
            trk:=0;
            Exit;
          END;
          ax:=$440d; cx:=$860; bx:=lw+1;
          dx:=Ofs(buffer); ds:=Seg(buffer);
          buffer[0]:=0;
          intr($21,regs);
          dosdrive:=bdib(buffer).dtyp;
          IF cfgdrive<>255 THEN
            dosdrive:=cfgdrive;
          CASE dosdrive OF
            0: BEGIN trk:=39; sec:= 9; hd:=False; END;
            1: BEGIN trk:=79; sec:=15; hd:=True ; END;
            2: BEGIN trk:=79; sec:= 9; hd:=False; END;
            7: BEGIN trk:=79; sec:=18; hd:=True ; END;
            ELSE
              BEGIN
                WriteLn(stderr,text06);
                trk:=0;
                Exit;
              END
          END;
          IF Swap(DosVersion)<$1000 THEN lw:=GetPhysical(lw);
          lw:=lw AND $9f;
          IF NOT(lw IN [0..3]) THEN BEGIN
            WriteLn(stderr,text07);
            trk:=0;
            Exit;
          END;
          IF cfgat80 THEN
            at80:=cfgat80
          ELSE
            at80:=(ModelByte=$f8) OR (ModelByte=$fc);
        END;
      END;

      PROCEDURE ATSetDrive(lw:Byte; trk,sec,Disk2,Disk,SetUp:Byte);
      BEGIN
        WITH regs DO BEGIN
          IF lw>1 THEN bios:=True;
          dh:=lw; ah:=$18; ch:=trk; cl:=sec;
          IF bios THEN Write(text86);
          intr($13,regs);
          IF ah>1 THEN BEGIN
            IF bios THEN Write(text89,#10#13,text87);
            ah:=$17; al:=SetUp; dl:=lw;
            intr($13,regs);
            IF ah<>0 THEN BEGIN
              IF bios THEN WriteLn(text89);
            END ELSE BEGIN
              IF bios THEN WriteLn(text88);
            END;
          END ELSE
            IF bios THEN WriteLn(text88);
          IF ForceType<>0 THEN BEGIN
            lwtab[lw]:=ForceType;
            bios:=False;
          END ELSE IF Disk2<>0 THEN BEGIN
            bios:=False;
            lwtab[lw]:=Disk2;
          END ELSE IF NOT(bios) THEN BEGIN
            lwtab[lw]:=Disk;
          END;
          DiskId:=lwtab[lw];
          IF not(bios) THEN
            WriteLn(text93)
          ELSE BEGIN
            IF (lw<2) AND ((lwtab[lw] AND $F0) <> (Disk AND $F0)) THEN BEGIN
              Writeln(stderr,text90);
              Writeln(stderr,text91,hexf(lwtab[lw] shr 4,1),
              text92,hexf(Disk shr 4,1),'x.');
            END;
          END;
        END;
      END;

      PROCEDURE SectorAbsolute(sector:Word;VAR hds,trk,sec:Byte);
      VAR h:Word;
      BEGIN
        sec:=(sector MOD bpb.spt)+1;
        h:=sector DIV bpb.spt;
        trk:=h DIV bpb.hds;
        hds:=h MOD bpb.hds;
      END;

      FUNCTION SectorLogical(hds,trk,sec:Byte):Word;
      BEGIN
        SectorLogical:=trk*bpb.hds*bpb.spt+hds*bpb.spt+sec-1;
      END;

      FUNCTION Cluster(sector: Word):Word;
      BEGIN
        Cluster:=((sector-(bpb.rde SHR 4)-(bpb.spf SHL 1)-1) DIV Word(bpb.spc))+2;
      END;

      PROCEDURE ClusterOffset(Cluster:Word; VAR Offset,Mask:Word);
      BEGIN
        Offset:=Cluster*3 SHR 1;
        IF Cluster AND 1 = 0 THEN
          Mask:=$ff7
        ELSE
          Mask:=$ff70;
      END;

      PROCEDURE GetOldParms;
      VAR bpb2: bpbtyp;
      BEGIN
        WITH regs DO BEGIN
          ax:=$201;
          dx:=lw;
          cx:=$101;
          es:=Seg(bpb2);
          bx:=Ofs(bpb2);
          intr($13,regs);
          ax:=$201;
          dx:=lw;
          cx:=$1;
          es:=Seg(bpb2);
          bx:=Ofs(bpb2);
          intr($13,regs);
          IF ((FCarry AND Flags) = 0) AND (bpb2.hds<>0) AND (bpb2.spt<>0)
          AND (bpb2.sec MOD (bpb2.hds*bpb2.spt)=0) THEN BEGIN
            IF NOT(Quick) AND ((sec<>bpb2.spt) OR (hds<>bpb2.hds) OR
                               (trk<>bpb2.sec DIV bpb2.hds DIV bpb2.spt)) THEN BEGIN
              safe:=False;
            END ELSE BEGIN
              sec:=bpb2.spt;
              hds:=bpb2.hds;
              trk:=bpb2.sec DIV bpb2.hds DIV bpb2.spt;
              rde:=bpb2.rde;
              bpb.spf:=bpb2.spf;
              spc:=bpb2.spc;
            END;
          END ELSE BEGIN
            IF fwe THEN BEGIN
              WriteLn(stderr,text81);
              Halt(3);
            END ELSE BEGIN
              safe:=False;
            END;
          END;
        END;
      END;

      PROCEDURE format;
      VAR i:Byte;
         st:Byte;
      BEGIN
        IF NOT(fwe) THEN BEGIN
          IF rde AND 15 <> 0 THEN Inc(rde,16);
          rde:=rde SHR 4;
          IF (spc=2) AND (rde AND 1 = 0) THEN Inc(rde);
          bpb.rde:=rde SHL 4;
        END;
        CASE sec OF
          0..8:   new1E:=@para08;
          9:      new1E:=@para09;
          10:     new1E:=@para10;
          11:     new1E:=@para11;
          12..15: new1E:=@para15;
          17:     new1E:=@para17;
          18:     IF lwsec>17 THEN
                    new1E:=@para18
                  ELSE
                    new1E:=@para18a;
          19..20: new1E:=@para20;
          21:     new1E:=@para21;
          22..255:new1E:=@para22;
        END;
        IF gpl<>0 THEN
          new1E^[7]:=gpl
        ELSE
          gpl:=new1E^[7];
        WriteLn;
        Write(text08,Chr(lw+$41),', ');
        IF hd THEN WriteLn('High-Density') ELSE WriteLn('Double-Density');
        WriteLn(hds,text09,trk,text10,sec,text11,'Interleave: ',il,text68,gpl);
        WriteLn(bpb.rde,text12,spc,text13,shiftt,':',shifth);
        bstCount:=0;
        WITH regs DO BEGIN
          FOR i:=1 TO 25 DO BEGIN
            table[i].f:=2;
            table2[i]:=0;
          END;
          i:=1;
          n:=1;
          REPEAT
            REPEAT
              WHILE table2[n]<>0 DO Inc(n);
              IF n>sec THEN n:=1;
            UNTIL table2[n]=0;
            table2[n]:=i;
            n:=n+il;
            Inc(i);
          UNTIL i>sec;
          ax:=0;
          bx:=0;
          dl:=lw;
          IF at80 AND NOT(fwe) THEN BEGIN
            CASE dosdrive OF
              0: ATSetDrive(lw,39,9,v360,$53,1);
              1: IF (trk>43) AND (sec>11) THEN
                   ATSetDrive(lw,79,15,v12,$14,3)
                 ELSE IF (trk>43) AND (sec<12) THEN
                   ATSetDrive(lw,79,9,v720,$53,5)
                 ELSE IF sec<12 THEN
                   ATSetDrive(lw,39,9,v360,$73,2)
                 ELSE
                   ATSetDrive(lw,39,15,0,$34,2);
              2: IF (trk>43) THEN
                   ATSetDrive(lw,79,9,v720,$97,4)
                 ELSE
                   ATSetDrive(lw,39,9,v360,$B7,2);
              7: IF (trk>43) AND (sec>11) THEN
                   ATSetDrive(lw,79,18,v144,$14,3)
                 ELSE IF (trk>43) AND (sec<12) THEN
                   ATSetDrive(lw,79,9,v720,$97,5)
                 ELSE IF sec<12 THEN
                   ATSetDrive(lw,39,9,v360,$B7,2)
                 ELSE
                   ATSetDrive(lw,39,18,0,$34,3);
            END;
          END;
          IF at80 AND NOT(bios) THEN BEGIN
            Write(text67);
            CASE (DiskId AND $C0) OF
              $00: Write('500');
              $40: Write('300');
              $80: Write('250');
              $C0: Write('???');
            END;
            Write(' kBaud, Double-Stepping: ');
            IF (DiskId AND 32)=0 THEN
              Write(text73,', ')
            ELSE
              Write(text72,', ');
          END;
          bpb.spt:=sec;
          bpb.hds:=hds;
          bpb.spc:=spc;
          bpb.sec:=sec*bpb.hds*trk;
                if (sec<11) and (bpb.sec>850) then bpb.jmp[2]:=$3C;
          IF ForceMedia=0 THEN BEGIN
            CASE bpb.spc OF
              1:   IF (trk>44) AND (bpb.spt IN [12..17]) THEN
                     bpb.mds:=$f9
                   ELSE
                     bpb.mds:=$f0;
              2:   IF trk IN [1..43] THEN bpb.mds:=$fd ELSE bpb.mds:=$f9;
              ELSE bpb.mds:=$f8;
            END;
          END
          ELSE bpb.mds:=ForceMedia;
          IF NOT fwe THEN BEGIN
            bpb.spf:=Trunc(bpb.sec*1.5/512/bpb.spc)+1;
            WHILE Trunc((1.5*(((bpb.sec-bpb.res-(bpb.rde DIV 16)
                                -bpb.fat*(bpb.spf-1)) DIV bpb.spc)+2)-1)/bpb.bps)+1<bpb.spf DO
              Dec(bpb.spf);
          END;
          SectorAbsolute((bpb.spf shl 1)+1,dh,ch,cl);
          bpb.boot_code[$D1]:=cl;
          bpb.boot_code[$D2]:=ch;
          bpb.boot_code[$D5]:=dh;
          SectorAbsolute((bpb.rde shr 4)+(bpb.spf shl 1)+1,dh,ch,cl);
          bpb.boot_code[$FF]:=cl;
          bpb.boot_code[$100]:=ch;
          bpb.boot_code[$102]:=dh;
          bpb.boot_code[$137]:=(bpb.rde shr 4)+(bpb.spf shl 1)+1;
          WriteLn('Media-Byte: ',hexf(bpb.mds,2));
          WriteLn;
          dl:=lw;
          ax:=0;
          REPEAT int13 UNTIL NOT again;
          n:=0;
          FillChar(buffer,SizeOf(buffer),#0);
          IF safe THEN st:=0
                  ELSE st:=1;
          FOR track:=trk-st DOWNTO 0 DO BEGIN
            FOR head:=hds-1 DOWNTO 0 DO BEGIN
              Write(text14,head,text15,track,#9);
              EndProgram(4,text94);
              n:=n MOD sec;
              FOR i:=1 TO sec DO BEGIN
                table[i].s:=table2[(i+n-1) MOD sec+1];
                table[i].t:=track;
                table[i].h:=head;
              END;
              noformat:=safe;
              again:=False;
              Write('R'#8);
              IF (st=0) THEN REPEAT
                i:=track;
                track:=0;
                MakeTrack(TRead);
                track:=i;
              UNTIL NOT again;
              IF fwe AND (st<>0) THEN REPEAT MakeTrack(TRead) UNTIL NOT again;
              REPEAT
                Write('F'#8);
                IF (NOT noformat) OR (st=0) THEN BEGIN
                  ah:=5;
                  al:=sec;
                  dl:=lw;
                  dh:=head;
                  ch:=track;
                  cl:=1;
                  es:=Seg(table);
                  bx:=Ofs(table);
                  int13;
                END;
                Write('W'#8);
                IF fwe OR (track<(3-hds)) OR (st=0) THEN MakeTrack(TWrite);
                Write('V'#8);
                IF NOT noverify THEN MakeTrack(TVerify);
              UNTIL NOT again;
              IF (st<>0) THEN Write(#9,100-((track+track+head)*50 DIV trk),'%'#13)
              ELSE BEGIN
                Write(#9,'0%'#13);
                FillChar(buffer,SizeOf(buffer),#0);
              END;
              n:=n+shifth;
            END;
            st:=1;
            n:=n+shiftt;
          END;
        END;
      END;

      PROCEDURE WriteBootSect;
      BEGIN
        WITH regs DO BEGIN
          IF setlabel THEN
            Move(dlabel[1],bpb.vlb,Length(dlabel))
          ELSE
            bpb.vlb:='NO NAME    ';
          inc(bpb.vsn);
          dh:=0; dl:=lw; ch:=0; cl:=1;
          al:=1; ah:=3; es:=Seg(bpb);
          bx:=Ofs(bpb);
          REPEAT int13 UNTIL NOT again;
          FillChar(buffer[3],18430,#0);
          buffer[0]:=bpb.mds;
          buffer[1]:=$ff;
          buffer[2]:=$ff;
          bad:=0;
          FOR i:=1 TO bstCount DO BEGIN
            x:=SectorLogical(bst[i].head,bst[i].track,bst[i].sector);
            x:=Cluster(x);
            ClusterOffset(x,Offset,Mask);
            IF buffer[Offset] AND Lo(Mask)=0 THEN Inc(bad,bpb.spc*512);
            buffer[Offset]:=buffer[Offset] OR Lo(Mask);
            buffer[Offset+1]:=buffer[Offset+1] OR Hi(Mask);
          END;
          es:=Seg(buffer);
          bx:=Ofs(buffer);
          Inc(cl);
          al:=bpb.spf;
          REPEAT int13 UNTIL NOT again;
          SectorAbsolute(bpb.spf+1,dh,ch,cl);
          ah:=3;
          dl:=lw;
          IF bpb.spf+cl>sec+1 THEN al:=sec-cl+1;
          REPEAT int13 UNTIL NOT again;
          IF bpb.spf+cl>sec+1 THEN BEGIN
            bx:=bx+al*512;
            al:=bpb.spf-al;
            Inc(dh);
            cl:=1;
            REPEAT int13 UNTIL NOT again;
          END;
          ax:=$440f; bx:=lw+1;
          intr($21,regs);
        END;
      END;


      PROCEDURE WriteLabel(x:String);
      VAR i: Byte;
      BEGIN
        WITH regs DO BEGIN
          IF x='' THEN BEGIN
            REPEAT
              Write(text74);
              ReadLn(x);
            UNTIL Length(x)<12;
          END;
          IF x<>'' THEN BEGIN
            IF Length(x)>8 THEN Insert('.',x,9);
            x:=Chr(lw+$41)+':\'+x;
            x[Length(x)+1]:=#0;
            cx:=8;
            ds:=Seg(x);
            dx:=Ofs(x)+1;
            ah:=$3c;
            msdos(regs);
            IF (FCarry AND Flags) <> 0 THEN BEGIN
              WriteLn(stderr,text75);
              Exit;
            END;
            bx:=ax;
            ah:=$3e;
            msdos(regs);
            IF (FCarry AND Flags) <> 0 THEN BEGIN
              WriteLn(stderr,text75);
              Halt(32);
            END;
          END;
        END;
      END;

      PROCEDURE DrivePrt;
      BEGIN
        WriteLn;
        IF lwtrk=0 THEN BEGIN
          WriteLn(stderr,text34);
          Exit;
        END;
        Write(text35,lw);
        IF lwhd THEN
          Write(': High-Density, ')
        ELSE
          Write(': Double-Density, ');
        WriteLn(lwtrk+1,text10,lwsec,text11);
        Write(text36);
        IF pc80=$20 THEN WriteLn(text37);
        IF pc80=$40 THEN WriteLn(text38);
        IF at80 THEN WriteLn(text39);
        IF NOT(at80) AND (pc80=0) THEN WriteLn(text40);
        WriteLn;
      END;

      PROCEDURE SyntaxError;
      BEGIN
        WriteLn(stderr); WriteLn(stderr,text41); WriteLn(stderr);
        WriteLn(stderr,text42); WriteLn(stderr,text43); WriteLn(stderr);
        WriteLn(stderr,text44); WriteLn(stderr); WriteLn(stderr,text45);
        WriteLn(stderr,text46); WriteLn(stderr,text47); WriteLn(stderr,text48);
        WriteLn(stderr,text49); WriteLn(stderr,text50); WriteLn(stderr,text51);
        WriteLn(stderr,text52); WriteLn(stderr,text53);
        WriteLn(stderr,text69); WriteLn(stderr,text70); WriteLn(stderr);
        WriteLn(stderr,text71);
        Halt(1);
      END;

      PROCEDURE CheckDos;
      VAR Version: Word;
      BEGIN
        IF Swap(DosVersion)<$314 THEN BEGIN
          WriteLn(stderr,text54);
          Halt(128);
        END;
        ASM
          mov   ax,3700h
          int   21h
          cmp   al,255
          jz    @def
          mov   swchar,dl
          @def:
        END;
      END;

      PROCEDURE BuildDPBError;
      BEGIN
        WriteLn(stderr,#10,text80,regs.ax,#10);
        Halt(64);
      END;

    BEGIN
      GetIntVec($1E,old1E);
      GetIntVec($13,old13);
      NormExit:=ExitProc;                                                 {Save old Exit-Procedure}
      ExitProc:=@RequestAbort;                   {Use our own Exit-Procedure to restore Interrupts}
      SetIntVec($1B,@CtrlBreak);          {Our own Ctrl-Break-Handler, to exit only, if it is save}
      SetIntVec($23,@IgnoreInt);                                                    {Ignore Ctrl-C}
      WriteLn(#10,text55);
      WriteLn(text56);
      CheckDos;
      new1E:=old1E;
      parse;
      IF (Length(para[1])<>2) OR (para[1,2]<>':') THEN SyntaxError;
      lw:=Ord(Upcase(para[1,1]))-$41;
      shiftt:=0;
      shifth:=0;
      packet:=0;
      CfgRead;
      DriveTyp(lw,lwhd,lwtrk,lwsec);
      DrivePrt;
      IF (lwtrk=0) AND (para[1]<>'') THEN Halt(1);
      rde:=0;
      il:=0;
      spc:=0;
      gpl:=0;
      setlabel:=False;
{     sys:=False;}
      ForceType:=0;
      ForceMedia:=0;
      batch:=False;
      trk:=lwtrk+1;
      sec:=lwsec;
      hds:=2;
      FOR i:=2 TO PCount DO
        IF para[i]<>'' THEN BEGIN
          chx:=para[i,1];
          IF Upcase(chx)='V' THEN BEGIN
            dlabel:='           ';
            setlabel:=True;
            dlabel:=Copy(para[i],2,11);
          END ELSE
          IF Length(para[i])=1 THEN BEGIN
            CASE Upcase(chx) OF
              'A': bios:=True;
              'R': noverify:=True;
              'U': ssafe:=False;
              'Q': IF NOT(fwe) THEN BEGIN
                     ssafe:=True;
                     noverify:=True;
                     Quick:=True;
                   END;
              'W': BEGIN
                     ssafe:=False;
                     Quick:=True;
                     fwe:=True;
                     bios:=True;
                     ForceType:=0;
                   END;
              'O': BEGIN
                     trk:=80;
                     sec:=9;
                     rde:=144;
                   END;
              '4': BEGIN
                     trk:=40;
                     sec:=9;
                   END;
              '1': BEGIN
                     hds:=1;
                   END;
              '8': BEGIN
                     sec:=8;
                   END;
{             'S': BEGIN
                     sys:=True;
                   END;}
              'K': BEGIN
                     batch:=True;
                   END;
              'P': BEGIN
                     packet:=255;
                   END;
							'Z': BEGIN
                     CASE sec OF
                       0..8:   new1E:=@para08;
                       9:      new1E:=@para09;
                       10:     new1E:=@para10;
                       11:     new1E:=@para11;
                       12..15: new1E:=@para15;
                       17:     new1E:=@para17;
                       18:     IF lwsec>17 THEN
                                 new1E:=@para18
                               ELSE
                                 new1E:=@para18a;
                       19..20: new1E:=@para20;
                       21:     new1E:=@para21;
                       22..255:new1E:=@para22;
                     END;
							     WITH regs DO BEGIN
										 fwe:=True;
										 safe:=True;
										 Quick:=True;
										 again:=False;
										 GetOldParms;
										 IF safe THEN BEGIN
										 	 FOR head:=0 TO hds-1 DO BEGIN
											   track:=trk;
												 REPEAT MakeTrack(TRead) UNTIL NOT again;
                         IF (FCarry AND Flags) <> 0 THEN BEGIN
													 Writeln(stderr,'Can not read Unformat info - program aborted.');
													 Halt(1);
												 END;
												 IF (head=0) AND ((buffer[510]<>$55) OR (buffer[511]<>$AA)) THEN BEGIN
													 Writeln(stderr,'Bad Unformat info - program aborted.');
													 Halt(1);
												 END;
												 track:=0;
												 REPEAT MakeTrack(TWrite) UNTIL NOT again;
                         IF (FCarry AND Flags) <> 0 THEN BEGIN
													 Writeln(stderr,'Can not restore Zero track - program aborted.');
													 Halt(1);
												 END;
											 END;
											 Writeln('Diskette is successfully unformatted.');
										 END ELSE Writeln(stderr,'Diskette is not formatted or bad BPB');
										 Halt(0);
									 END;
								 END;
              ELSE SyntaxError;
            END;
          END ELSE BEGIN
            IF para[i,2]='$' THEN BEGIN
              n:=dezh(Copy(para[i],3,255));
              j:=BaseError
            END ELSE
              Val(Copy(para[i],2,255),n,j);
            IF j<>0 THEN SyntaxError;
            CASE Upcase(para[i,1]) OF
              'T':trk:=n;
              'H':hds:=n;
              'N':sec:=n;
              'S':sec:=n;
              'M':ForceMedia:=n;
              'D':rde:=n;
              'C':spc:=n;
              'I':il:=n;
              'G':gpl:=n;
              'X':shifth:=n;
              'Y':shiftt:=n;
              'B':IF NOT(fwe) THEN ForceType:=n;
              'P':packet:=n;
              'F':BEGIN
                    found:=False;
                    FOR j:=1 TO maxform DO
                      IF NOT(found) AND (n=ftab[j].fmt) THEN BEGIN
                        trk:=ftab[j].trk;
                        sec:=ftab[j].sec;
                        hds:=ftab[j].hds;
                        found:=True;
                      END;
                    IF NOT(found) THEN BEGIN
                      Writeln(stderr,'You can specify formats:  360,  400,  410            for => 360 KB Drives');
                      Writeln(stderr,'                          720,  800,  820            for => 720 KB Drives');
                      Writeln(stderr,'    12 | 1.2 | 120,  14 | 1.4 | 144,  148 | 1.48     for => 1.2 MB Drives');
                      Writeln(stderr,'    16 | 1.6,       164 | 1.64,       172 | 1.72     for = 1.44 MB Drives');
                      Halt(1);
                    END;
                  END;
              ELSE SyntaxError;
            END;
          END;
        END;
      Randomize;
      bpb.vsn:=LongInt(Ptr(Random(65535),Random(65535)));
      REPEAT
        safe:=ssafe;
        IF NOT(hds IN [1..2]) THEN BEGIN
          WriteLn(stderr,text57);
          Halt(1);
        END;
        IF trk<1 THEN BEGIN
          WriteLn(stderr,text58);
          Halt(1);
        END;
        IF spc>2 THEN
          WriteLn(stderr,text61);
        IF ShortInt(trk-lwtrk)>4 THEN
          WriteLn(stderr,text62);
        IF rde>240 THEN
        WriteLn(stderr,text63);
        IF NOT(batch) OR (packet>0) THEN BEGIN
          WriteLn;
          WriteLn(text64,Chr(lw+$41),text65);
          WriteLn(text66);
          chx:=ReadKey;
        END;
        IF ssafe OR Quick THEN GetOldParms;
        srde:=rde;
        IF sec>11 THEN hd:=True ELSE hd:=False;
        IF rde=0 THEN
          CASE hd OF
            True:  rde:=224;
            False: rde:=112;
          END;
        IF spc=0 THEN
          CASE hd OF
            True:  spc:=1;
            False: spc:=2;
          END;
        IF il=0 THEN
          IF sec-lwsec IN [3..8] THEN il:=2 ELSE il:=1;
        IF il>=Pred(sec) THEN BEGIN
          WriteLn(stderr,text59,Pred(sec),text60);
          Halt(1);
        END;
        format;
        IF NOT(fwe) THEN BEGIN
          WriteBootSect;
          regs.bx:=lw+1;
          regs.ax:=$440D;
          regs.cx:=$860;
          regs.ds:=Seg(buffer);
          regs.dx:=Ofs(buffer);
          bdib(buffer).flag:=5;
          msdos(regs);
          IF (regs.Flags AND FCarry) <> 0 THEN BuildDPBError;
          Move(bpb.bps,bdib(buffer).bpb,31);
          regs.bx:=lw+1;
          regs.ax:=$440D;
          regs.cx:=$840;
          regs.ds:=Seg(buffer);
          regs.dx:=Ofs(buffer);
          bdib(buffer).flag:=4;
          msdos(regs);
          IF (regs.Flags AND FCarry) <> 0 THEN BuildDPBError;
{         IF sys THEN WriteSys;}
          IF setlabel THEN WriteLabel(dlabel);
        END;
        rde:=srde;
        WriteLn(#10);
        WriteLn(text22,bpb.sec); WriteLn(text23,bpb.spt);
        WriteLn(text24,bpb.hds); WriteLn(text29,bpb.spf);
        WriteLn(text30,Cluster(bpb.sec)-2);
        WriteLn(text79,hexf(bpb.vsn SHR 16,4),'-',hexf(bpb.vsn AND $FFFF,4));
        bytes:=LongInt(bpb.sec) SHL 9;
        WriteLn(#10,bytes:9,text31);
        WriteLn(512:9,text32);
        bytes:=bytes-512;
        bytesub:=bpb.rde SHL 5;
        WriteLn(bytesub:9,text33);
        bytes:=bytes-bytesub;
        bytesub:=bpb.spf SHL 10;
        bytes:=bytes-bytesub;
        WriteLn(bytesub:9,text82);
        IF bad<>0 THEN WriteLn(bad:9,text83);
        WriteLn(bytes-bad:9,text84);
        WriteLn(Diskfree(Succ(lw)):9,text85,#10);
        IF packet>0 THEN dec(packet);
      UNTIL packet=0;
    END.
