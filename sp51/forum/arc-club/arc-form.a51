From cs.kiev.ua!cs.kiev.ua!L-usenet Sat Dec 05 09:07:48 1992
Received: by softp.kiev.ua (UUPC/@ v5.00gamma, 07Nov92);
          Sat,  5 Dec 1992 09:07:47 +0200
X-Class: Slow
To: netters
Sender: L-usenet@cs.kiev.ua
From: jwright@cfht.hawaii.edu (Jim Wright)
Newsgroups: comp.virus
Subject: [NEWS] Brief guide to files formats last changed 05 September 1992
Message-ID: <0003.9212012053.AA06542@barnabas.cert.org>
Date: 1 Dec 92 18:09:54 GMT
Approved: news@netnews.cc.lehigh.edu
Lines: 212

Brief guide to files formats            last changed 05 September 1992

 -- The most recent copy of the complete text may be anonymous ftp'd --
 -- from ux1.cso.uiuc.edu (128.174.5.59) in the directory doc/pcnet. --
 -- That file is maintained by David Lemson (lemson@uiuc.edu).       --
 -- Please do not strip this note from this list when passing it on. --

ARC (.arc)
    This format is most popular on PCs.  Compresses and stores multiple
    files in a single archive.
    PC     - arc 6.02, pk361
    Mac    - ArcMac 1.3c
    Unix   - arc 5.21
    VM/CMS - arcutil
    Amiga  - Arc 0.23, PKAX
    VMS    - arcvms
    Apple2 - dearc
    Atari  - arc 5.21b, pkunarc
    OS/2   - arc2

ARJ (.arj)
    ARJ is a new archive format for DOS.  Compresses and stores multiple
    files in a single archive.  The author is Robert K Jung,
    robjung@world.std.com.
    PC     - arj 2.30 (arj230.exe)
    Unix   - unarj 2.30
    Amiga  - unarj 0.6

BinHex (.hqx)
    A Macintosh format.  Converts a binary Mac file, including data and
    resource forks, into an archive of only printing ASCII characters.
    Note that BinHex4.0 will create and decode the ASCII hqx encoding used
    on Usenet, while BinHex5.0 will decode the ASCII hqx encoding but will
    create a non-ASCII binary file.
    PC     - xbin 2.3
    Mac    - BinHex4.0, BinHex5.0
    Unix   - mcvert
    VM/CMS - binhex

binscii ( )
    A favorite Apple2 file transmission format.  Similar to uu{en,de}code
    except it can handle multiple files in a single package.
    Apple2 - binscii

Compact Pro (.cpt)
    A new Macintosh format.  Compresses and stores multiple files in
    a single archive.
    Mac    - Compact Pro 1.32, Extractor 1.21
    PC     - EXTRACT

compress (.Z)
    A Unix format.  Compresses a single file in an archive.
    PC     - u16, comprs16, comp430d
    Mac    - MacCompress3.2A
    Unix   - compress
    VM/CMS - compress
    Amiga  - compress
    VMS    - lzcomp
    Apple2 - compress
    Atari  - compress

Disk Masher (.dms)
    This is an Amiga format.  Compresses and stores an entire floppy in a
    single archive.
    Amiga  - DMS

LHarc (.lzh)
    This format originated on PCs, and is now popular on Amigas.  Compresses
    and stores multiple files in a single archive.
    PC     - lha 2.13 (lha213.exe)
    Mac    - MacLHarc 0.41
    Unix   - lha 1.00
    Amiga  - LHarc 1.30 [Only .lh0 and .lh1], LhA 1.32, LZ 1.92
    Atari  - lharc113

LHWarp (.lzw)
    This is an Amiga format.  Compresses and stores an entire floppy in a
    single archive.  Better compression than plain Warp.
    Amiga  - Lhwarp

LU (.lbr)
    This is an old format that originated with CP/M.  It is virtually
    non-existent now.  Collects multiple files into a single archive
    with no compression.
    PC     - lue220
    Mac    - ArcMac 1.3c
    Unix   - lar
    VM/CMS - arcutil
    VMS    - vmssweep

LZ (.lha .lzh)
    This format is popular on Amigas.  Compresses and stores multiple
    files in a single archive.  Will extract .lzh or .lza, and will
    produce .lza.  Is fast when extracting files.
    Amiga  - LZ 1.92

MSX (.msx)
    A new format for CP/M machines.  Is also able to extract lharc archives.
    CP/M   - PMARC and PMEXT

nupack ( )
    A favorite Apple2 archive format.
    Apple2 - nupack

PackIt (.pit)
    An old Macintosh format.  Compresses and stores multiple files in a
    single archive.
    PC     - UnPackIt 1.0
    Mac    - PackIt3.1.3
    Unix   - unpit

PAK (.pak)
    An old PC format.  Compresses and stores multiple files in a
    single archive.  Also the name of an Amiga format which produces
    self-extracting archives.  Also the name of a new PC format.
    PC     - PAK 2.51
    Unix   - arc 5.21
    Amiga  - PAK 1.0

shell archive (.shar, .sh)
    A Unix format.  Stores multiple files in a single archive without
    compression.
    PC     - unshar
    Mac    - UnShar2.0
    Unix   - sh, unshar
    Amiga  - UnShar
    Apple2 - unshar
    Atari  - shar

ShrinkIt ( )
    A favorite Apple2 archive format.
    Apple2 - ShrinkIt

Squeeze (._Q_)
    An old PC (CP/M?) format.  Compresses and stores multiple files in a
    single archive.
    PC     - sqpc131
    VM/CMS - arcutil
    Amiga  - Sq.Usq
    VMS    - vmsusq
    Atari  - ezsqueeze

StuffIt (.sit)
    A Macintosh format.  Compresses and stores multiple files in a
    single archive.
    PC     - mactopc, UnStuffit 1.0
    Mac    - StuffIt 1.6
    Unix   - unsit
    Amiga  - unsit

tape archive (.tar)
    A Unix format.  Stores multiple files in a single archive without
    compression.
    PC     - tar, tarread, pax, pdtar
    Mac    - UnTar2.0
    Unix   - tar, GNU tar
    Amiga  - TarSplit, pax, GNUtar 1.09
    VMS    - vmstar
    Atari  - sttar

uuencode (.uu, .uue)
    A Unix format.  Converts a binary file into an archive of only
    printing ASCII characters suitable for mailing.
    PC     - uuexe 5.15
    Mac    - UMCP Tools 1.5.1
    Unix   - uuencode, uudecode
    VM/CMS - arcutil
    Amiga  - uuencode, uudecode
    VMS    - uudecode2.
    Apple2 - uu.en.decode

Warp (.wrp)
    This is an Amiga format.  Compresses and stores an entire floppy in a
    single archive.
    Amiga  - WarpUtil

xxencode (.xx, .xxe)
    A Unix format.  Converts a binary file into an archive of only
    printing ASCII characters suitable for mailing.  Solves many of
    the problems of uuencode.
    PC     - uuexe 5.15
    Unix   - xxencode, xxdecode
    VM/CMS - xxencode

ZIP (.zip)
    This format is popular on many systems.  Compresses and stores
    multiple files in a single archive.
    PC     - PKZIP/PKUNZIP 1.10, Portable unzip 5.0, Portable zip 1.9
    Mac    - UnZip1.02c
    Unix   - Portable unzip 5.0, Portable zip 1.9
    VM/CMS - arcutil 2.0 (uncompress only)
    Amiga  - PKAZip 1.01, Portable unzip 5.0, Portable zip 1.9
    Atari  - STZip 0.9 beta
    VMS    - Portable unzip 5.0, Portable zip 1.9
    OS/2   - PKZIP/PKUNZIP 1.02, Portable unzip 5.0, Portable zip 1.9

ZOO (.zoo)
    This format is popular on USENET.  Compresses and stores multiple
    files in a single archive.
    PC     - zoo 2.10
    Mac    - MacBooz2.1
    Unix   - zoo 2.10
    VM/CMS - zoo
    Amiga  - zoo 2.10
    VMS    - zoo 2.10
    Atari  - zoo 2.10
    OS/2   - zoo 2.10

ZOOM (.zom)
    This is an Amiga format.  Compresses and stores an entire floppy in a
    single archive.  Not in common use due to program speed.
    Amiga  - zoom

