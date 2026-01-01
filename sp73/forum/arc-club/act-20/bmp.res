Version Twenty, Archive Comparision Table                  [16 January 1995]
                                                          [ARC-TEST\BMP.RES]


Below is a table of each program with their corresponding switches, and the
time taken to archive and extract the files with the percentage of spaced
saved.

                                         Insert     %               Extract
Name & Switches     Storage Type          Time    Saved  File Size   Time
----------------------------------------------------------------------------
AIN a /m1 /u1       Maximal /Slow Update   3.91s  71.52    12,859     1.60s
AIN a /m1 /u2       Maximal /Norm Update   3.94s  71.52    12,859     1.61s
AIN a /m1 /u3       Maximal /Fast Update   3.92s  71.43    12,901     1.74s
AIN a /m2 /u1       Normal /Slow Update    1.37s  70.05    13,525     1.73s
AIN a /m2 /u2       Normal /Norm Update    1.37s  70.05    13,527     1.74s
AIN a /m2 /u3       Normal /Fast Update    1.45s  69.94    13,574     1.79s
AIN a /m3 /u3       Fast /Fast Update      1.13s  64.31    16,117     1.81s
AIN a /m3 /u2       Fast /Norm Update      1.00s  64.33    16,108     1.73s
AIN a /m3 /u1       Fast /Slow Update      1.03s  64.33    16,109     1.75s
AIN a /m4 /u1       Store /Slow Update     1.20s -00.53    45,398     1.81s
AIN a /m4 /u2       Store /Norm Update     1.18s -00.54    45,400     1.95s
AIN a /m4 /u3       Store /Fast Update     1.17s -00.54    45,400     2.04s

AR a                Compress               3.86s  70.83    13,174     1.77s

ARC a               Compress               0.99s  65.71    15,483     1.61s
ARC a5              Level 5 Compat.        1.03s  65.71    15,483     1.76s
ARC as              Store                  0.84s -00.71    45,479     1.64s

ARI a -i            Compress              48.53s  71.35    12,938     1.44s
ARI a -i -c         Compress, No Optimize 35.56s  71.05    13,073     1.26s
ARI a -i -z         Store                 00.91s -00.68    45,466     0.45s

ARJ a -e -jm        Maximum                9.43s  70.37    13,381     2.11s
ARJ a -e -jm1       Maximum                4.32s  70.27    13,426     2.19s
ARJ a -e -m1        Method 1 (Default)     3.24s  70.12    13,495     2.14s
ARJ a -e -m2        Method 2               2.17s  69.67    13,697     2.26s
ARJ a -e -m3        Method 3               1.71s  68.50    14,226     2.22s
ARJ a -e -m4        Method 4               1.71s  64.19    16,169     2.19s
ARJ a -e -m0        Store                  1.47s -01.38    45,783     2.23s

ARX a               Compress               2.67s  68.69    14,140     2.57s

AMGC a -mm          Max                   15.56s  69.95    13,571     3.83s
AMGC a -mn          Normal                 3.03s  68.43    14,255     4.01s
AMGC a -ml          Less Memory            2.73s  62.91    16,751     4.08s
AMGC a -mf          Fast                   2.70s  62.91    16,751     4.10s
AMGC a -ms          Super Fast             2.54s  43.21    25,646     4.11s

CODEC -c8           ?                      4.20s  68.73    14,121     2.68s
CODEC -c9           Maximum                4.37s  68.72    14,125     2.70s
CODEC -c7           ?                      3.39s  68.72    14,126     2.70s
CODEC -c6           ?                      2.90s  68.72    14,127     2.70s
CODEC -c5           Medium (Default)       2.48s  68.67    14,148     2.74s
CODEC -c4           ?                      2.22s  68.47    14,237     2.74s
CODEC -c3           ?                      2.05s  68.02    14,443     2.73s
CODEC -c2           ?                      1.95s  67.59    14,635     2.74s
CODEC -c1           Minimum                1.87s  67.43    14,710     2.76s
CODEC -a            Store                  1.82s -01.77    45,959     2.76s

CRUSH -h -n         (HA v0.99b)            9.27s  72.47    12,434     3.30s
CRUSH -l -n         (LHA v2.13)            2.98s  72.05    12,621     2.67s
CRUSH -o -n         (ZOO v2.1)             4.14s  71.75    12,759     3.14s
CRUSH -j -n         (ARJ v2.41a)           3.64s  71.51    12,865     2.87s
CRUSH -n            Default (ZIP v2.04g)   5.58s  71.10    13,051     2.81s

DWC az              Best                   1.10s  69.97    13,561     2.03s
DWC ay              Fast                   1.00s  69.97    13,561     2.08s
DWC as              Store                  1.13s -00.89    45,559     2.16s

HA ae21             Method 2 & 1          18.56s  76.15    10,772     5.66s
HA ae12             Method 1 & 2          22.43s  76.15    10,772     5.76s
HA ae2              Method 2 (HSC)         5.70s  75.95    10,860     6.03s
HA ae1              Method 1 (ASC)        14.26s  71.91    12,686     3.19s
HA ae0              Store (CPY)            2.50s -00.79    45,516     2.66s

HA(b) ae21          Method 2 & 1          22.53s  76.15    10,772    11.70s
HA(b) ae12          Method 1 & 2          22.77s  76.15    10,772    10.58s
HA(b) ae2           Method 2 (HSC)        14.41s  75.95    10,860    15.58s
HA(b) ae1           Method 1 (ASC)         8.99s  71.93    12,678     2.80s
HA(b) ae0           Store (CPY)            1.66s -00.79    45,516     2.47s

HAP a               Compress               5.33s  76.10    10,791     3.63s

HAP(r) a            Compress               1.53s  76.10    10,791     2.91s
HAP(r) a3           Compress 386           1.51s  76.10    10,791     2.87s

HPACK a -df -u      Unit Comp. Mode       17.60s  72.59    12,376     2.72s
HPACK a -df         Compress              16.89s  72.33    12,493     2.70s
HPACK a -df -0      Store                  0.92s -00.61    45,432     2.40s

HYPER -a            Compress               1.51s  71.09    13,054     2.39s

IZIP -9 -j          Method 9 (Slowest)     8.28s  69.49    13,777     2.36s
IZIP -8 -j          Method 8               5.73s  69.44    13,797     2.30s
IZIP -7 -j          Method 7               2.75s  69.37    13,833     2.35s
IZIP -6 -j          Method 6 (Default)     2.30s  69.24    13,889     2.27s
IZIP -5 -j          Method 5               1.96s  68.51    14,222     2.45s
IZIP -4 -j          Method 4               1.69s  67.52    14,669     2.33s
IZIP -3 -j          Method 3               1.78s  66.58    15,092     2.39s
IZIP -2 -j          Method 2               1.78s  65.39    15,630     2.36s
IZIP -1 -j          Method 1 (Faster)      1.72s  63.96    16,275     2.41s
IZIP -0 -j          Store                  1.55s -02.40    46,240     2.36s

IZIP386 -9 -j       Method 9 (Slowest)     8.39s  69.49    13,777     2.50s
IZIP386 -8 -j       Method 8               6.15s  69.44    13,797     2.60s
IZIP386 -7 -j       Method 7               3.40s  69.37    13,833     2.57s
IZIP386 -6 -j       Method 6 (Default)     2.95s  69.24    13,889     2.55s
IZIP386 -5 -j       Method 5               2.57s  68.51    14,222     2.63s
IZIP386 -4 -j       Method 4               2.36s  67.52    14,669     2.60s
IZIP386 -3 -j       Method 3               2.56s  66.58    15,092     2.63s
IZIP386 -2 -j       Method 2               2.45s  65.39    15,630     2.58s
IZIP386 -1 -j       Method 1 (Faster)      2.47s  63.96    16,275     2.67s
IZIP386 -0 -j       Store                  2.80s -02.40    46,240     2.75s

LARC a              Compress               2.71s  68.69    14,140     2.45s

LHA a               Compress               2.66s  70.96    13,116     1.64s
LHA a /o            Old Version            2.77s  69.81    13,631     1.70s
LHA a /z            Store                  1.64s -00.91    45,568     1.71s

LHA(b) a            Compress               2.54s  70.96    13,116     1.78s
LHA(b) a /o         Old Version            2.35s  69.81    13,631     1.95s
LHA(b) a /z         Store                  1.58s -00.91    45,568     2.05s

LHARC a             Compress               2.71s  68.69    14,140     2.19s

LIMIT c -mx         Maximum                7.30s  71.18    13,015     2.25s
LIMIT c -m1         Normal                 2.63s  70.83    13,172     2.31s
LIMIT c -ms         Fast                   1.30s  69.76    13,655     2.28s
LIMIT c -m0         Store                  0.77s -00.92    45,574     2.27s

MDCD c              Compress               2.34s  67.84    14,521     2.50s

NULIB ar            Compress               1.58s  61.61    17,337     2.19s

PAK a /s            Squashing              1.24s  70.86    13,610     2.27s
PAK a /cr           Crushing               1.20s  68.56    14,198     2.32s
PAK a /zs           ZIP 0.9                1.29s  68.28    14,325     2.22s
PAK a /c            Crunching              1.12s  67.17    14,826     2.25s
PAK a               Compress               2.83s  67.02    14,891     2.13s
PAK a /o            Distill or Implode     3.53s  66.84    14,973     2.19s

PKARC a             Compress               0.82s  68.61    14,175     1.89s

PKPAK -a            Compress               0.77s  68.63    14,167     1.91s

PKZIP1 -es          Shrink Only            0.73s  68.51    14,222     1.83s
PKZIP1 -ex          Maximal                2.69s  63.93    16,289     1.89s
PKZIP1 -ei          Implode Only           2.72s  63.93    16,289     1.82s

PKZIP2 -ex          Extra                  4.55s  69.18    13,918     1.91s
PKZIP2 -en          Normal (Default)       2.56s  68.66    14,153     1.94s
PKZIP2 -ef          Fast                   1.80s  65.90    15,397     1.88s
PKZIP2 -es          Superfast              0.95s  62.45    16,956     2.02s
PKZIP2 -e0          Store                  0.77s -00.18    46,240     2.01s

PUT quiet           Compress               3.13s  70.92    13,131     2.66s

QUANTUM -c5         Compress (Slowest) 5m  6.10s  74.12    11,689     4.02s
QUANTUM -c4         Compress           3m 32.76s  73.87    11,799     4.08s
QUANTUM -c3         Compress (Default)     9.88s  72.20    12,556     4.07s
QUANTUM -c2         Compress               5.15s  71.72    12,769     4.12s
QUANTUM -c1         Compress (Fastest)     3.32s  69.46    13,793     4.02s

RAR a -s -ep        Solid                  6.35s  70.83    13,172     2.07s
RAR a -s -ep -ds    Solid                  6.38s  70.83    13,172     2.13s
RAR a -m5 -ep       Best                   6.57s  69.97    13,561     2.19s
RAR a -m4 -ep       Good                   3.71s  69.61    13,725     2.15s
RAR a -m3 -ep       Normal (Default)       1.89s  68.14    14,388     2.17s
RAR a -m2 -ep       Fast                   1.54s  66.64    15,064     2.15s
RAR a -m1 -ep       Fastest                1.48s  64.40    16,076     2.16s
RAR a -m0 -ep       Store                  1.75s -01.07    45,642     2.22s

SAR a               Compress               3.68s  70.96    13,116     2.06s

SQWEZ               Compress               5.89s  23.95    34,343     2.98s

SQZ a /m4 /q∞ /p3   Method 4/<Alt 236>    11.65s  71.13    13,039     2.24s
SQZ a /m4 /q0 /p3   Method 4/0            10.23s  71.12    13,042     2.36s
SQZ a /m2 /q0 /p3   Method 2/0            10.44s  71.11    13,044     2.32s
SQZ a /m3 /q0 /p3   Method 3/0            10.24s  71.11    13,067     2.33s
SQZ a /m1 /q0 /p3   Method 1/0            10.45s  71.06    13,068     2.35s
SQZ a /p3           Compress (Default)     2.40s  70.55    13,301     2.30s
SQZ a /m0 /p3       Store                  1.43s -00.77    45,507     2.39s

UC a -tst           Super Tight           12.23s  71.04    13,078     3.60s
UC a -tt            Tight                  5.21s  70.93    13,128     3.48s
UC a -tn            Normal (Default)       3.04s  70.25    13,434     3.56s
UC a -tf            Fast                   2.86s  69.17    13,922     3.48s

ZOO ah:             High                   3.46s  69.87    13,607     2.71s
ZOO a:              Compress               1.58s  68.87    14,058     2.70s
ZOO af:             Store                  1.44s -01.95    46,037     2.58s


All the programs have been set to compress without including the filepaths,
that is, if they actually have an option to do this.

The STORE option of the archive programs looks like it takes up more space
than the 11 files, but normaly takes up less, due to the file slack mention
in BMP.SET.
