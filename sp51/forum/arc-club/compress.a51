The most recent copy of this text may be anonymous ftp'd from
ftp.cso.uiuc.edu (128.174.5.59) in the directory /doc/pcnet as
the file compression.
This file is maintained by David Lemson (lemson@uiuc.edu).
Please do not strip this note from this list when passing it on.
-------------------------------------------------------------------------------
DECODING THIS CHART: This chart has been compacted to fit into 80 columns
so it can be viewed on-line. The first column is the name of the compression/
archiving technique. The next field is the file extension given to the 
resulting file. After that are 5 columns each for a different operating system.
Each one of these consists of the name of the file/program to undo the given
compression/archiving style and a letter that tells where the file/program may
be obtained. All symbols and letters are decoded at the bottom portion of this
file. 
-------------------------------------------------------------------------------

FILE COMPRESSION, ARCHIVING, AND TEXT<->BINARY FORMATS

Last Update: 10/8/92           Operating System/Unpackaging Program

NAME    File     DOS      *   Mac         *   Unix   *   VM/CMS  *  Amiga    *
      Extension
abe       ?  abe.exe      N      -          abe      Q      -          -
afio      -      -               -          afio     ?      -          -
ar      (any)    -               -          ar       L      -          -
ARC     .ARC arc602.exe   B ArcMac1.3c    A arc521   B arcutil2.0K Arc 0.23  Aa
ARCHDOS .IBM Internal IBM only - creates .EXE self-extractors also
ARJ     .ARJ arj230ng.exe B      -          unarj230 B   unarj   K     -
BinHex  .Hqx xbin23.zip   B BinHex4.0 +   A mcvert   D  binhex   K     -
binscii   *      -               -              -           -          -
BLU       ?      -               -              -           -          -
BOO     .BOO msbpct.exe   B      ?        ?     -           -          -
             msbmkb.exe
btoa    (any)btoa         N      +          btoa     L      -      compress  Ab
Bundle  .bndl    -          Bundle        ? Unbundle M      -          -
CardDump(any)    -               -              -       card     K     -
compact .C       -               -         uncompact L      -          -
Compac-
tor      .cpt    -          Compactor1.21 D     -           -          - 
Compac- 
tor Pro  .cpt    -        CompactorPro1.33D     -           -          -
compress.Z   u16.zip      A MacCompress3.2A compress L  compress K compress  Ac
             comp430d.zip B
cpio      ?  pax2exe.zip  H      -            cpio   L      -          -
COMT	.COM comt010d.zip B	 -		-	    -	       -
Crunch    ?      -               -              -       arcutil  K     -
Diamond (spc+hibit) -       Diamond 3.0   Z     -           -          -
Diet	(any)diet110a.zip B      -              -           -          -
Disk-
Doubler  .dd     -         DiskDoubler3.7 Z     -           -          -
Disk-   .DMS     -               -              -           -       dms-102  T
Masher  .EXE
DWC     .DWC dwc-a501.exe B      -              -           -          -
FPack   (any)    ?        ? FPack2.2      A     ?    ?      -          -
HPACK   .HPK hpack75.zip  B 
HYPER   .HYP hyper25.zip  B      -              -           -          -
Imploder(any)    -               -              -           -    imploder1.3 T
Ish	.ish ish200.lzh	  B  ishmac-06         ?	    ? 	       ?
JPEG	(any)	(See note at bottom - C source available) ***
Larc    .LZS larc333.zip  B      -              -           -          -
LHA     .LZH lha213.exe   B      -           lha1.00 U      -          -
LHarc   .LZH lh113c.exe   H MacLHarc 0.41 D lharc102 U      -      LHarc     Ad
LHWarp  .LZW     -               -              -           -      Lhwarp    Ae
LU (LAR).LBR lue220.arc   B      -          lar      ?  arcutil  K     -
LZari     ?      -          MacLZAri 7-11 ?     -           -          -
LZEXE   .EXE lzexe91.zip  A      -              -           -          -
LZSS    .lzss    ?        ? LZSS 2.0b5    ?     -           -          -
MDCD    .MD  mdcd10.arc   B      -              -           -          -
nupack    ?      -               -              -           -          -
pack     .Z      -               -           unpack  L      -          -   
PackIt  .pit UnPackIt     ? PackIt3.1.3   A unpit    ?      -          -
PAK     .PAK pak251.exe   H      ?        ?     -           -          -
PKLITE  .EXE pklte115.exe B      -              -           -          -
PKPAK   .ARC pk361.exe    A ArcMac1.3c    A arc521   I arcutil2.0K PKAX      ?
PKZIP   .ZIP pkz110eu.exe B UnZip1.1 0    D unzip42 B  arcutil2.0K PKAZip    Af
Power-  (any)
Packer  .pp      -               -              -           -    PowerPacker Ai
Scrunch .COM scrnch.arc   B      -              -           -          -
Shark            -               -              sh   E 
shell - .shar
archive      toadshr1.arc B UnShar2.0     D   unshar L      -      UnShar    Ag
Ship	(any) (See note at bottom about Ship and Portable Zip) *
shrinkit.shk     -               -              -           -          -
Shrink-
ToFit   .stf     -          STF1.2        ?     -           -          -
SPL       ?      -               ?        ?     -           -          -
Squash  .ARC squash.arc   B      -              -           -          -
Squeeze .xQx sqpc131.arc  B      ?        ?     ?    ?  arcutil  K Sq.Usq    Ah
StuffIt .Sit unsit30.zip  B StuffItLite 3 D unsit    D      -          -
tar     .tar tar.zip      A UnTar2.0      D tar      L      -      TarSplit  Ai
             tarread.arc  I
             extar10.zip  B 
	     ltarv1.zip   B
terse   (any)Copyright IBM       -              -       vmarc    +     -
uuencode.UUE toaduu20.zip B uutool2.0.3  D  uudecode L  arcutil  K uudecode  Aj
Warp    .WRP     -               -              -           -      WarpUtil  Ak
whap    .AP      ?               ?         yabbawhap M      ?      yabbawhap M 
xxencode.XXE ncdc150.zip  B      -          xxdecode A  xxdecode K     -
yabba   .Y       ?               ?         yabbawhap M      ?      yabbawhap M 
ZOO     .ZOO zoo210.exe   A MacBooz2.1    D zoo210   B  zoo      K amigazoo  A

------------------------------------------------------------------------------
Extended Chart:
                VMS       *    Apple 2    *   Atari     *    OS/2   *  Windows3 

abe       ?      -               -              -              -          -
afio      -      -               -              -              -          -
ar      (any)    -               -              -              -          -
ARC     .arc arcvms.uue   B dearc.bsq.Z   B arc521b.arc R  arc2.arc A     -
ARJ     .ARJ  unarj220    B      -              -              -          -
BinHex  .Hqx     -               -              -              -          -
binscii   *      -          binscii.exe   O     -              -          -
BLU       ?      -               ?              -              -          -
BOO     .BOO     -               -              -              -          -
btoa    (any)    -               -              -              -          -
Bundle  .bndl    -               -              -              -          -
CardDump(any)    -               -              -              -          -
compact .C       -               -              -              -          -
Compac-
tor      .cpt    -               -              -              -          - 
compress.Z   lzdcomp.exe  P compress.shk  J compress.arc R     -          -
cpio      ?      -               -              -              -          -
Crunch    ?      -               -              -              -          -
Disk-
Doubler   ?      -               -              -              -          -
DWC     .DWC     -               -              -              -          -
FPack   (any)    -               -              -              -          -
HPACK   .HPK     ?        *      ?        *     ?    *         ?    *     ?    *
HYPER   .HYP     -               -              -              -          -
Larc    .LZS     -               -              -              -          -
LHA     .LHA     -               -              -           lha214_2      -
LHarc   .LZH     -               -          lharc113.arc R  clhar103  S   -
LHWarp  .LZW     -               -              -              -          -
LU(LAR) .LBR vmssweep     B      -              -              -          -
LZari     ?      -               -              -              -          -
LZEXE   .EXE     -               -              -              -          -
LZSS    .lzss    -               -              -              -          -
MDCD    .MD      -               -              -              -          -
nupack    ?      -          nupack        B     -              -          -
PackIt  .pit     -               -              -              -          -
PAK     .PAK     -               -              -              -          -
PKPAK   .ARC     -               -          pkunarc.arc R      -          -
PKZIP   .ZIP  unzip41 B          -          STZIP1.1 	R pkz101-2.exe A  -
Power-
Packer  (any)    -               -              -              -          -
Scrunch .COM     -               -              -              -          -
shell-
archive .shar    -          unshar.shk    J shar.arc    R      -          -
shrinkit.shk     -               ?        O     -              -          -
Shrink-
ToFit   .stf     -               -              -              -          -
SPL       ?      -               -              -              -          -
Squash  .ARC     -               -              -              -          -
Squeeze   ?  vmsusq.pas   B      -          ezsqueeze.arc R    -          -
StuffIt .Sit     -               -              -              -          -
tar     .tar vmstar       Q      -          sttar.arc   R      -          -
terse   (any)    -               -              -              -          -
uuencode.uue uudecode2.vmsB uu.en.decode  J     -              -          -
Warp    .WRP     -               -              -              -          -
whap      ?      ?               -              ?              ?          -
xxencode.XXE     -               -              -              -          -
yabba     ?      ?               -              ?              ?          -
ZOO     .ZOO ZOO210.TAR-Z B      -          booz.arc    R  booz.exe  A    -

------------------------------------------------------------------------------
WHERE TO GET THEM:
   A. ftp.cso.uiuc.edu [128.174.5.59]
	          /pc/exec-pc/ {Zip, arc, lots of good stuff}
		  /pc/local
                  /mac/
                  /amiga/fish/(see individual references)

      a ff070  b ff051  c ff051  d ff312  e ff305  f ff311  g ff345
      h ff051  i ff053  j ff092  k ff243  i ff253

   B. wuarchive.wustl.edu [128.152.135.4] (UIUC: NFS mounted on uxa and mrcnext)
         /mirrors/msdos/arc-lbr/ {arc, LHARC, hpack}
                       /filutl/ {msbpct - BOO, toadshr, DIET}
		       /sq-usq/ {NUSQ}
                       /zip/ {unzip}
                       /mac/ {unsit30}
                 /info-mac/util/
                 /unix-c/arc-progs/ {ARC}
                 /misc/vaxvms/ {UNZIP for VMS}
		 /misc/unix/ {UNZIP, ZOO for UNIX/VMS, UNARJ}

   C. omnigate.clarkson.edu [128.153.4.2]
         /pub/ncsa2.2tn/

   D. sumex-aim.stanford.edu [36.44.0.6]
         /info-mac/util/ {Stuffit Lite, Compactor Pro, etc.}
		  /unix/ {unsit, mcvert}

   E. ftp.uu.net [137.39.1.9]
         /pub/
	     /ioccc/shar.1990.* {shark}

   F. grape.ecs.clarkson.edu [128.153.28.129.]
        -  collection varies - see the file 'allfiles'

   G. watsun.cc.columbia.edu [128.59.39.2]
	Definitive source for KERMIT releases for all machines
         /kermit/a/

   H. wsmr-simtel20.army.mil [192.88.110.20]
   Wuarchive's mirror is updated within 48 hours - recommended to
   use wuarchive instead of simtel20.
         cd pd1:<msdos.arc-lbr>

   I. pc.usl.edu [130.70.40.3]
         /pub/unix/

   J. plains.nodak.edu [134.129.111.64]
         /pub/appleII/GS/utils/
                     /nonGS/packers/

   K. vmd.cso.uiuc.edu [128.174.5.98]
      binhex - cd public.474
      card   - cd public.460
      others - cd public.477
	- NOTE: UUDECODE, UNARJ, ZOO and COMPRESS are originally from
	  LISTSERV@BLEKUL11

   L. (should be available on all major unix systems including
	wuarchive.wustl.edu in /unix-c/arc-progs)

   M. comp.sources.unix archives
         (varies, including wuarchive in /usenet/comp.sources.unix)

   N. comp.binaries.ibm.pc archives
         (varies, including wuarchive in /usenet/comp.binaries.ibm.pc)

   O. tybalt.caltech.edu [131.215.139.100]
         /pub/apple2/
                    /shrinkits/

   P. kuhub.cc.ukans.edu [129.237.1.10]
         /LZW/ 

   Q. vmsa.oac.uci.edu [128.200.9.5]
         /

   R. atari.archive.umich.edu [141.211.164.8]
         /atari/archivers/

   S. mtsg.ubc.ca [137.82.27.1]
        /os2

   T. ab20.larc.nasa.gov [128.155.23.64]
	/amiga/utils/archivers/ 

   U. alt.sources archives (available on wuarchive.wustl.edu in
			    /usenet/alt.sources/)
	{LHarc is articles number 2217 and 2218}

   V. rascal.ics.utexas.edu [128.83.138.20]
	/misc/mac/utilies

   W. akiu.gw.tohoku.ac.jp [130.34.8.9]
	/pub/mac/tools/archiver

   Z. Commercial software product - check discount mail order
   software houses, computer stores.

NOTES:
Symbols: +   means see the notes below for special information
         -   means that nothing exists to the best of my knowledge
         ?   means that something exists but I do not know the name
             of the program or where to get it
         *   means that e-mail should be sent to lemson@uiuc.edu
             for details/explanation

JPEG - source (Free code) is available in
ftp.uu.net:/graphics/jpeg/jpegsrc.v?.tar.Z.  Supports conversion
between JPEG "JFIF" format and image files in PBMPLUS PPM, Utah RLE,
Truevision Targa, and GIF file formats.  Contact for more info:
Dr. Thomas G. Lane,  organizer, Independent JPEG Group
Internet: jpeg-info@uunet.uu.net

Some uuencode/uudecode programs are able to read xxencode files.

Stuffit Lite 3.0 is the replacement version of Stuffit
Classic 1.6 for Macintosh.  Stuffit Lite is shareware, $25.  Stuffit
Deluxe is the commercial version from Aladdin Software.

VMARC, available with the command "TELL LISTSERV AT RPIECS GET VMARC
PACKAGE" from a CMS machine, will decode any CMS terse program.  The
PC version of terse is a commercial program available from IBM
directly.

There is a portable 'ZIP' that goes along with unzip41 that is
available from valeria.cs.ucla.edu:/pub/zip10ex.zip.  'ship' is also
available in that same package.  It is a program like uuencode, but
is more robust.  WizUnzip, WZUNZ1.ZIP in the WINDOWS3 dir on
wuarchive (B), is a MS Windows 3 version of Unzip41.

There is a set of translators that will allow Stuffit Deluxe to read
btoa, UUencoded files, zip, pack, tar, MacBinary, and others.  They are in
sumex-aim.stanford.edu:/info-mac/utils/stuffit-deluxe-translators.hqx.

When using tar.exe for PC's, the order of option flags is important.
For extraction, use tar -tvf <filename>.

ARC : From SEA, ARC 6.02 is the latest widespread shareware release.
      It is available at A (ux1.cso.uiuc.edu).
      Also, SEA has ARC 7.00, but it is commercial, not shareware.
      
When using binscii.exe for an Apple II, there are different file extensions
depending on the type of file being changed.

BinHexed files (with the extension .hqx) can be UnBinHexed with BinHex 4.0 or
Stuffit.  BinHex5.0 format is a MacBinary format, while BinHex 4.0 files
are ASCII format.

The files listed are only guaranteed to uncompress/unarchive.
To make a compression/archive, further software may be needed.

USAGE NOTES:

There are certain "standard" combinations of compression used:
  unix - .tar.Z
         (often this will be .taz for PC's)
  unix - tar.Z.btoa (abbrev. to .TZB sometimes) (aka "tarmail")

  mac  - .sit.hqx
       - these must be undone in order starting at the end of the name

Sometimes an archive may be self-extracting. These will look like normal
executable programs. Simply run them to undo the archive.

LZEXE (PC), PKLITE(PC), Imploder(Amiga), and PowerPacker(Amiga)
are executable compressors.
They compress an executable file and attach an uncompressing header so that
the file can still be executed while in compressed form.
The listed programs for these utilities compress files, in order to uncompress
a file with these types of compression, just execute them.

DIET (PC) is a TSR program that compresses and decompresses both
executables and data files as needed.


DEFINITIVE SOURCES:

   PKWARE Support BBS - avaliable 24 hours
     (414) 352-7176

   ZOO - author: Rahul Dhesi
         source code in C on Usenet and GEnie's IBM PC Roundtable

   ARC - SEA (System Enhancement Associates, Inc.)
         21 New Street
         Wayne, NJ 07470
