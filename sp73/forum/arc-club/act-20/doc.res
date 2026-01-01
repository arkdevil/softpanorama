Version Twenty, Archive Comparision Table                  [16 January 1995]
                                                          [ARC-TEST\DOC.RES]


Below is a table of each program with their corresponding switches, and the
time taken to archive and extract the files with the percentage of spaced
saved.

                                         Insert     %               Extract
Name & Switches     Storage Type          Time    Saved  File Size   Time
---------------------------------------------------------------------------
AIN a /m1 /u1       Maximal /Slow Update  20.41s  71.62   366,766    07.14s
AIN a /m2 /u1       Normal /Slow Update   15.90s  71.36   370,102    07.06s
AIN a /m1 /u2       Maximal /Norm Update  18.97s  71.12   372,032    06.80s
AIN a /m2 /u2       Normal /Norm Update   15.37s  70.98   374,986    06.93s
AIN a /m1 /u3       Maximal /Fast Update  17.85s  70.75   378,053    06.69s
AIN a /m2 /u3       Normal /Fast Update   14.36s  70.55   380,607    06.61s
AIN a /m3 /u1       Fast /Slow Update     07.91s  64.90   452,383    07.69s
AIN a /m3 /u2       Fast /Norm Update     07.90s  64.90   453,634    07.31s
AIN a /m3 /u3       Fast /Fast Update     07.89s  64.77   455,248    07.03s
AIN a /m4 /u1       Store /Slow Update    06.19s -00.04 1,292,795    07.26s
AIN a /m4 /u2       Store /Norm Update    05.84s -00.04 1,292,795    07.10s
AIN a /m4 /u3       Store /Fast Update    05.97s -00.04 1,292,795    07.08s

AR a                Compress           1m 18.40s  68.59   405,861    11.10s

ARC a               Compress              13.23s  55.75   571,789    10.33s
ARC a5              Level 5 Compat.       13.29s  55.75   571,789    10.41s
ARC as              Store                 07.93s -00.06 1,292,871    08.18s

ARI a -i            Compress           6m 01.62s  71.98   362,139    10.05s
ARI a -i -c         Compress, No Opt.  4m 45.55s  71.91   362,958    09.94s
ARI a -i -z         Store                 04.93s -00.04 1,292,849    04.20s

ARJ a -e -jm        Maximum               42.98s  70.43   382,158    07.97s
ARJ a -e -jm1       Maximum               35.44s  70.41   382,440    08.15s
ARJ a -e -m1        Method 1 (Default)    31.24s  70.38   382,805    07.94s
ARJ a -e -m2        Method 2              22.51s  70.08   386,702    08.12s
ARJ a -e -m3        Method 3              15.34s  68.50   407,085    08.34s
ARJ a -e -m4        Method 4              13.46s  65.86   454,116    08.67s
ARJ a -e -m0        Store                 08.06s -00.08 1,293,347    09.93s

ARX a               Store                 44.90s  65.46   446,309    12.79s

AMGC a -mm          Max                1m 28.69s  71.25   371,531    12.67s
AMGC a -mn          Normal                27.11s  69.98   387,963    12.91s
AMGC a -ml          Less Memory           14.36s  62.68   482,313    13.19s
AMGC a -mf          Fast                  13.28s  62.68   482,313    13.22s
AMGC a -ms          Super Fast            12.12s  53.75   597,720    13.61s

CRUSH -h -n         (HA v0.99b)        1m 21.45s  71.85   363,829    27.52s
CRUSH -n            Default (ZIP v2.04g)  38.95s  71.65   366,414    10.68s
CRUSH -j -n         (ARJ v2.41a)          38.16s  71.10   373,457    11.12s
CRUSH -l -n         (LHA v2.13)           42.16s  68.88   402,152    12.24s
CRUSH -o -n         (ZOO v2.1)         1m 14.48s  68.87   402,290    16.25s

CODEC -c8           ?                     37.74s  71.09   373,598    15.25s
CODEC -c9           Maximum               37.88s  71.09   373,599    15.14s
CODEC -c7           ?                     35.15s  71.08   373,689    15.21s
CODEC -c6           ?                     32.14s  71.05   374,139    15.21s
CODEC -c5           Medium (Default)      28.79s  70.98   375,070    15.20s
CODEC -c4           ?                     25.51s  70.82   377,100    15.37s
CODEC -c3           ?                     22.66s  70.53   380,827    15.31s
CODEC -c2           ?                     20.26s  69.97   388,139    15.48s
CODEC -c1           Minimum               19.45s  69.59   392,962    15.61s
CODEC -a            Store                 13.59s -00.11 1,293,667    12.79s

DWC az              Best                  10.41s  61.32   499,818    07.30s
DWC ay              Fast                  08.15s  59.86   518,725    07.46s
DWC as              Store                 06.57s -00.05 1,292,996    07.79s

HA ae21             Method 2 & 1       4m 57.74s  75.88   311,634 2m 57.98s
HA ae12             Method 1 & 2       8m 08.92s  75.88   311,634 2m 57.80s
HA ae2              Method 2 (HSC)     3m 16.92s  75.88   311,634 2m 57.86s
HA ae1              Method 1 (ASC)     1m 45.97s  71.25   371,555    33.01s
HA ae0              Store (CPY)           26.33s -00.05 1,292,900    21.82s

HA(b) ae21          Method 2 & 1       3m 41.60s  75.88   311,634 2m 36.82s
HA(b) ae12          Method 1 & 2       3m 44.24s  75.88   311,634 2m 36.85s
HA(b) ae2           Method 2 (HSC)     2m 31.13s  75.88   311,634 2m 36.85s
HA(b) ae1           Method 1 (ASC)     1m 11.76s  71.29   371,069    24.24s
HA(b) ae0           Store (CPY)           14.67s -00.03 1,292,900    12.90s

HAP a               Compress           1m 10.49s  74.77   326,012 1m 10.46s

HAP(r) a            Compress              39.70s  74.77   326,012    52.13s
HAP(r) a3           Compress 386          38.47s  74.77   326,012    52.18s

HPACK a -df -u      Unit Comp. Mode    2m 55.13s  72.51   355,263    21.66s
HPACK a -df         Compress           2m 26.66s  71.45   368,911    21.67s
HPACK a -df -0      Store                 10.00s -00.04 1,292,763    12.47s

HYPER -a            Compress              20.10s  67.56   419,184    14.99s

IZIP -9 -j          Method 9 (Slowest)    45.75s  70.83   376,971    12.78s
IZIP -8 -j          Method 8              37.97s  70.81   377,167    12.60s
IZIP -7 -j          Method 7              29.59s  70.74   378,181    12.58s
IZIP -6 -j          Method 6 (Default)    26.20s  70.62   379,713    12.67s
IZIP -5 -j          Method 5              21.33s  70.10   386,400    12.64s
IZIP -4 -j          Method 4              18.45s  69.04   400,045    13.02s
IZIP -3 -j          Method 3              16.91s  67.44   420,799    13.36s
IZIP -2 -j          Method 2              15.75s  66.22   436,563    13.68s
IZIP -1 -j          Method 1 (Faster)     15.23s  64.74   455,637    14.06s
IZIP -0 -j          Store                 08.93s -00.15 1,294,165    12.70s

IZIP386 -9 -j       Method 9 (Slowest)    47.02s  70.83   376,971    08.50s
IZIP386 -8 -j       Method 8              40.15s  70.81   377,167    08.55s
IZIP386 -7 -j       Method 7              32.01s  70.74   378,181    08.57s
IZIP386 -6 -j       Method 6 (Default)    29.02s  70.62   379,713    08.51s
IZIP386 -5 -j       Method 5              24.42s  70.10   386,400    08.69s
IZIP386 -4 -j       Method 4              21.98s  69.04   400,045    09.03s
IZIP386 -3 -j       Method 3              21.21s  67.44   420,799    08.88s
IZIP386 -2 -j       Method 2              20.20s  66.22   436,563    09.08s
IZIP386 -1 -j       Method 1 (Faster)     19.95s  64.74   455,637    09.24s
IZIP386 -0 -j       Store                 29.76s -00.15 1,294,165    10.27s

LARC a              Compress              39.93s  60.63   508,803    10.04s

LHA a               Compress              37.17s  68.57   406,208    08.15s
LHA a /o            Old Version           37.71s  66.88   427,997    11.62s
LHA a /z            Store                 09.99s -00.07 1,293,197    08.91s

LHA(b) a            Compress              37.35s  68.57   406,208    08.08s
LHA(b) a /o         Old Version           37.38s  66.88   427,997    11.75s
LHA(b) a /z         Store                 08.06s -00.07 1,293,197    08.14s

LHARC a             Compress              44.90s  65.46   446,309    12.40s

LIMIT c -mx         Maximum               41.97s  71.15   372,808    08.45s
LIMIT c -m1         Normal                31.64s  71.09   373,550    08.49s
LIMIT c -ms         Fast                  18.78s  70.35   383,178    08.48s
LIMIT c -m0         Store                 05.14s -00.05 1,292,994    07.77s

MDCD c              Compress              19.44s  58.54   535,740    12.11s

NULIB ar            Compress              24.21s  51.18   630,934    13.43s

PAK a /o            Distill or Implode    29.00s  67.04   425,908    08.69s
PAK a               Compress              28.46s  67.04   425,908    09.02s
PAK a /cr           Crushing              17.44s  62.37   486,269    14.55s
PAK a /zs           ZIP 0.9               15.46s  61.38   499,071    12.33s
PAK a /s            Squashing             13.36s  58.67   534,042    12.47s
PAK a /c            Crunching             13.41s  56.13   566,989    13.09s

PKARC a             Compress              08.70s  59.27   526,399    07.29s

PKPAK -a            Compress              07.78s  59.18   527,507    07.21s

PKZIP1 -ex          Maximal               23.68s  68.10   412,190    06.61s
PKZIP1 -ei          Implode Only          23.85s  68.10   412,190    06.76s
PKZIP1 -es          Shrink Only           07.30s  61.39   498,911    08.11s

PKZIP2 -ex          Extra                 25.76s  70.76   377,855    06.49s
PKZIP2 -en          Normal (Default)      16.36s  70.48   381,466    06.54s
PKZIP2 -ef          Fast                  11.00s  68.76   403,719    06.47s
PKZIP2 -es          Superfast             07.65s  64.40   460,116    06.72s
PKZIP2 -e0          Store                 07.39s -00.15 1,294,165    06.37s

PUT quiet           Compress              48.74s  68.55   406,435    10.55s

QUANTUM -c5         Comp. (Slowest)   31m 02.17s  75.81   312,588    29.20s
QUANTUM -c4         Comp.             19m 25.61s  75.51   316,532    29.33s
QUANTUM -c3         Comp. (Default)    3m 39.65s  74.25   332,716    29.56s
QUANTUM -c2         Comp.              1m 40.85s  73.50   342,453    30.27s
QUANTUM -c1         Comp. (Fastest)       47.44s  69.37   395,882    32.78s

RAR a -s -ep        Solid              1m 16.33s  72.50   355,341    07.89s
RAR a -s -ep -ds    Solid              1m 16.41s  72.50   355,341    07.92s
RAR a -m5 -ep       Best                  50.40s  71.40   369,582    07.81s
RAR a -m4 -ep       Good                  41.86s  71.37   369,966    07.79s
RAR a -m3 -ep       Normal (Default)      24.27s  71.03   374,400    07.81s
RAR a -m2 -ep       Fast                  16.31s  69.88   389,294    07.98s
RAR a -m1 -ep       Fastest               13.38s  68.32   409,425    08.12s
RAR a -m0 -ep       Store                 06.93s -00.07 1,293,196    07.57s

SAR a               Compress           1m 21.62s  68.58   406,008    12.00s

SQWEZ               Compress           1m 10.42s  64.04   464,677    15.03s

SQZ a /m4 /q∞ /p3   Method 4/<Alt 236> 1m 21.28s  70.90   376,088    08.90s
SQZ a /m4 /q0 /p3   Method 4/0         1m 10.16s  70.89   376,132    08.95s
SQZ a /m3 /q0 /p3   Method 3/0         1m 10.04s  70.87   376,381    09.52s
SQZ a /m2 /q0 /p3   Method 2/0         1m 12.06s  70.86   376,604    09.07s
SQZ a /m1 /q0 /p3   Method 1/0         1m 12.04s  70.84   376,850    08.66s
SQZ a /p3           Compress (Default)    33.86s  70.59   380,108    08.99s
SQZ a /m0 /p3       Store                 08.04s -00.05 1,292,873    10.92s

UC a -tst           Super Tight        1m 53.35s  72.92   349,996    09.14s
UC a -tt            Tight                 58.63s  72.77   351,954    09.17s
UC a -tn            Normal (Default)      33.19s  72.03   361,456    09.38s
UC a -tf            Fast                  23.43s  70.40   382,526    09.33s

ZOO ah:             High               1m 06.78s  68.52   406,858    13.10s
ZOO a:              Compress              20.61s  58.61   534,818    11.09s
ZOO af:             Store                 10.42s -00.12 1,293,807    09.37s


All the programs have been set to compress without including the filepaths,
that is, if they actually have an option to do this.

The STORE option of the archive programs looks like it takes up more space
than the 20 files, but normaly takes up less, due to the file slack mention
in DOC.SET.
