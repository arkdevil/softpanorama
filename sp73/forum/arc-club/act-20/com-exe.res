Version Twenty, Archive Comparision Table                  [16 January 1995]
                                                      [ARC-TEST\COM-EXE.RES]


Below is a table of each program with their corresponding switches, and the
time taken to archive and extract the files with the percentage of spaced
saved.

                                         Insert     %               Extract
Name & Switches     Storage Type          Time    Saved  File Size   Time
---------------------------------------------------------------------------
AIN a /m1 /u1       Maximal /Slow Update  31.99s  46.60 1,003,578   13.23s
AIN a /m2 /u1       Normal /Slow Update   27.98s  46.53 1,004,958   13.36s
AIN a /m1 /u2       Maximal /Norm Update  30.85s  46.46 1,006,317   13.01s
AIN a /m2 /u2       Normal /Norm Update   26.76s  46.38 1,007,692   12.95s
AIN a /m1 /u3       Maximal /Fast Update  29.58s  45.38 1,026,506   12.78s
AIN a /m2 /u3       Normal /Fast Update   25.98s  45.31 1,027,791   12.84s
AIN a /m3 /u3       Fast /Fast Update     15.69s  41.72 1,095,283   12.99s
AIN a /m3 /u1       Fast /Slow Update     15.20s  42.68 1,077,285   13.80s
AIN a /m3 /u2       Fast /Norm Update     15.04s  42.66 1,077,563   13.20s
AIN a /m4 /u1       Store /Slow Update     8.90s -00.04 1,880,214   11.41s
AIN a /m4 /u2       Store /Norm Update     8.92s -00.04 1,880,214   11.57s
AIN a /m4 /u3       Store /Fast Update     9.02s -00.04 1,880,214   11.58s

AR a                Compress           1m 39.06s  44.58 1,041,579   22.77s

ARC a5              Level 5 Compat.       25.74s  28.53 1,343,218   17.97s
ARC a               Compress              26.00s  28.53 1,343,218   18.04s
ARC as              Store                 11.05s -00.09 1,880,517   12.99s

ARI a -i            Compress           7m 36.20s  46.57 1,004,232   18.70s
ARI a -i -c         Compress, No opt.  5m 00.95s  46.49 1,005,699   18.85s
ARI a -i -z         Store                 07.33s -00.06 1,880,477   06.10s

ARJ a -e -jm        Maximum               54.19s  45.24 1,029,153   15.69s
ARJ a -e -jm1       Maximum               43.04s  45.23 1,029,271   15.49s
ARJ a -e -m1        Method 1 (Default)    40.21s  45.22 1,029,456   15.72s
ARJ a -e -m2        Method 2              33.45s  45.15 1,030,804   15.57s
ARJ a -e -m3        Method 3              27.03s  44.05 1,051,479   15.97s
ARJ a -e -m4        Method 4              20.87s  39.63 1,134,612   16.38s
ARJ a -e -m0        Store                 11.89s -00.01 1,881,431   16.17s

ARX a               Compress           1m 00.03   42.55 1,079,758   29.49s

AMGC a -mm          Max                1m 33.04s  45.59 1,022,639   23.05s
AMGC a -mn          Normal                48.54s  44.58 1,041,567   23.22s
AMGC a -ml          Less Memory           23.59s  42.07 1,088,771   23.47s
AMGC a -mf          Fast                  22.50s  42.07 1,088,771   23.37s
AMGC a -ms          Super Fast            19.51s  35.33 1,215,487   22.89s

CODEC -c9           Maximum               47.64s  45.40 1,026,134   29.59s
CODEC -c8           ?                     47.00s  45.40 1,026,138   29.55s
CODEC -c7           ?                     45.65s  45.40 1,026,155   29.71s
CODEC -c6           ?                     44.82s  45.40 1,026,194   29.76s
CODEC -c5           Medium (Default)      44.08s  45.39 1,026,280   29.65s
CODEC -c4           ?                     42.61s  45.37 1,026,670   29.70s
CODEC -c3           ?                     41.12s  45.31 1,027,768   30.31s
CODEC -c2           ?                     39.09s  45.17 1,030,472   29.49s
CODEC -c1           Minimum               38.42s  44.97 1,034,175   29.55s
CODEC -a            Store                 21.22s -00.15 1,882,191   19.86s

CRUSH -h -n         (HA v0.99b)        1m 41.81s  47.15   993,237 1m 0.67s
CRUSH -n            Def. (ZIP v2.04g)  1m  1.26s  46.48 1,005,812   17.96s
CRUSH -j -n         (ARJ v2.41a)          47.86s  46.08 1,013,344   20.29s
CRUSH -l -n         (LHA v2.13)           53.86s  44.77 1,037,920   21.62s
CRUSH -o -n         (ZOO v2.1)         1m 34.69s  44.77 1,038,058   29.91s

DWC az              Best                  20.50s  30.27 1,310,468   13.69s
DWC ay              Fast                  16.11s  29.65 1,322,130   13.70s
DWC as              Store                  9.50s -00.07 1,880,732   12.61s

HA ae21             Method 2 & 1      22m 50.33s  47.89   979,322 11m 35.42s
HA ae12             Method 1 & 2      35m 01.34s  47.89   979,322 11m 35.33s
HA ae2              Method 2 (HSC)    20m 29.91s  47.44   987,830 18m 29.02s
HA ae1              Method 1 (ASC)     2m 28.47s  46.24 1,010,435  1m 19.79s
HA ae0              Store (CPY)           43.49s -00.06 1,880,624     33.91s

HA(b) ae21          Method 2 & 1      14m 49.94s  47.91   979,014  9m 35.68s
HA(b) ae12          Method 1 & 2      14m 53.03s  47.91   979,014  9m 35.32s
HA(b) ae2           Method 2 (HSC)    13m 10.20s  47.44   987,830 14m 02.82s
HA(b) ae1           Method 1 (ASC)     1m 40.02s  46.15 1,012,045     58.07s
HA(b) ae0           Store (CPY)           26.08s -00.06 1,880,624     20.07s

HAP a               Compress           4m 07.96s  44.99 1,033,804  3m 47.20s

HAP(r) a3           Compress 386       1m 41.59s  44.99 1,033,804  2m 08.45s
HAP(r) a            Compress           1m 48.32s  44.99 1,033,804  2m 08.37s

HPACK a -df         Compress           7m 13.68s  44.24 1,047,891  1m 10.46s
HPACK a -df -u      Unit Comp. Mode    8m 31.67s  40.83 1,111,974  1m 29.16s
HPACK a -df -0      Store                 13.63s -00.05 1,880,329     19.13s

HYPER -a            Compress              39.18s  41.74 1,094,919     29.40s

IZIP -9 -j          Method 9 (Slowest)    56.96s  45.25 1,029,044     26.36s
IZIP -8 -j          Method 8              47.84s  45.25 1,029,059     26.32s
IZIP -7 -j          Method 7              41.64s  45.21 1,029,674     26.32s
IZIP -6 -j          Method 6 (Default)    40.56s  45.19 1,030,096     26.35s
IZIP -5 -j          Method 5              38.09s  45.08 1,032,197     26.63s
IZIP -4 -j          Method 4              36.12s  44.67 1,039,842     26.60s
IZIP -3 -j          Method 3              33.55s  43.68 1,058,540     27.37s
IZIP -2 -j          Method 2              32.21s  43.24 1,066,779     27.79s
IZIP -1 -j          Method 1 (Faster)     31.42s  42.68 1,077,230     26.86s
IZIP -0 -j          Store                 13.91s -00.19 1,883,065     19.92s

IZIP386 -9 -j       Method 9 (Slowest) 1m 08.11s  45.25 1,029,044     15.56s
IZIP386 -8 -j       Method 8              58.18s  45.25 1,029,059     15.62s
IZIP386 -7 -j       Method 7              52.57s  45.21 1,029,674     15.75s
IZIP386 -6 -j       Method 6 (Default)    50.67s  45.19 1,030,096     15.71s
IZIP386 -5 -j       Method 5              47.86s  45.08 1,032,197     15.78s
IZIP386 -4 -j       Method 4              46.24s  44.67 1,039,842     15.83s
IZIP386 -3 -j       Method 3              46.23s  43.68 1,058,540     15.89s
IZIP386 -2 -j       Method 2              43.59s  43.24 1,066,779     16.20s
IZIP386 -1 -j       Method 1 (Faster)     43.07s  42.68 1,077,230     16.23s
IZIP386 -0 -j       Store                 48.53s -00.19 1,883,065     16.58s

LARC a              Compress              56.92s  34.97 1,222,253     18.75s

LHA a               Compress              48.75s  44.56 1,041,883     15.88s
LHA a /o            Old Version        1m 00.47s  43.31 1,065,369     30.20s
LHA a /z            Store                 15.23s -00.07 1,880,811     12.87s

LHA(b) a            Compress              48.85s  44.56 1,041,883     15.71s
LHA(b) a /o         Old Version        1m 00.06s  43.31 1,065,369     30.74s
LHA(b) a /z         Store                 12.09s -00.07 1,880,811     13.50s

LHARC a             Compress           1m 00.67s  42.55 1,079,758     28.80s

LIMIT c -mx         Maximum               42.03s  45.66 1,021,213     15.73s
LIMIT c -m1         Normal                32.57s  45.65 1,021,374     15.71s
LIMIT c -ms         Fast                  27.69s  45.53 1,023,688     15.79s
LIMIT c -m0         Store                  6.77s -00.07 1,880,790     12.76s

MDCD c              Compress              40.50s  29.26 1,329,403     20.73s

NULIB ar            Compress              38.45s  28.90 1,336,212     21.58s

PAK a /o            Distill or Implode    43.21s  41.79 1,094,044     16.82s
PAK a               Compress              43.13s  41.79 1,094,044     16.86s
PAK a /cr           Crushing              32.90s  35.16 1,218,633     25.26s
PAK a /zs           ZIP 0.9               27.74s  29.89 1,317,677     20.76s
PAK a /c            Crunching             22.73s  29.66 1,322,039     21.92s
PAK a /s            Squashing             23.01s  29.43 1,326,339     21.26s

PKARC a             Compress              17.31s  29.79 1,319,447     13.44s

PKPAK -a            Compress              15.39s  29.83 1,318,722     13.49s

PKZIP1 -ex          Maximal               33.37s  42.08 1,088,486     11.80s
PKZIP1 -ei          Implode Only          33.41s  42.08 1,088,486     11.95s
PKZIP1 -es          Shrink Only           14.33s  30.37 1,308,724     15.05s

PKZIP2 -ex          Extra                 43.09s  45.33 1,027,471     12.28s
PKZIP2 -en          Normal (Default)      29.35s  45.22 1,029,636     12.76s
PKZIP2 -ef          Fast                  21.09s  44.29 1,046,968     12.51s
PKZIP2 -es          Superfast             15.39s  41.31 1,102,990     12.52s
PKZIP2 -e0          Store                 11.63s -00.19 1,883,065     11.56s

PUT quiet           Compress           1m 03.70s  44.53 1,042,507     20.60s

QUANTUM -c5         Comp. (Slowest)   19m 54.42s  49.61   947,044  1m 18.90s
QUANTUM -c4         Comp.             14m 07.18s  49.56   947,892  1m 19.17s
QUANTUM -c3         Comp. (Default)    3m 32.50s  48.55   966,949  1m 19.04s
QUANTUM -c2         Comp.              2m 35.39s  48.41   969,619  1m 19.29s
QUANTUM -c1         Comp. (Fastest)    1m 40.95s  46.79 1,000,119  1m 22.22s

RAR a -s -ep        Solid              1m 13.04s  47.61   984,541     15.69s
RAR a -s -ep -ds    Solid              1m 13.23s  47.38   988,915     15.60s
RAR a -m5 -ep       Best                  56.28s  46.43 1,006,779     15.13s
RAR a -m4 -ep       Good                  46.79s  46.42 1,006,910     15.47s
RAR a -m3 -ep       Normal (Default)      37.85s  46.35 1,008,235     15.25s
RAR a -m2 -ep       Fast                  30.27s  45.31 1,027,792     15.40s
RAR a -m1 -ep       Fastest               26.58s  44.88 1,036,011     15.44s
RAR a -m0 -ep       Store                 10.23s -00.09 1,881,020     11.71s

SAR a               Compress           1m 43.27s  44.56 1,041,883     22.85s

SQWEZ               Compress           1m 48.45s  42.14 1,087,500     37.77s

SQZ a /m4 /q0 /p3   Method 4/0         1m 12.40s  45.43 1,025,564     17.64s
SQZ a /m4 /q∞ /p3   Method 4/<Alt 236> 1m 23.61s  45.43 1,025,570     17.76s
SQZ a /m2 /q0 /p3   Method 2/0         1m 15.50s  45.40 1,026,194     17.40s
SQZ a /m3 /q0 /p3   Method 3/0         1m 12.52s  45.38 1,026,533     17.69s
SQZ a /p3           Compress (Default) 1m 47.04s  45.37 1,026,634     17.82s
SQZ a /m1 /q0 /p3   Method 1/0         1m 15.89s  45.35 1,027,162     17.83s
SQZ a /m0 /p3       Store                 12.47s -00.06 1,880,561     16.70s

UC a -tst           Super Tight        1m 47.48s  47.63   984,270     17.16s
UC a -tt            Tight              1m 15.90s  47.57   985,332     17.21s
UC a -tn            Normal (Default)   1m 02.37s  47.36   989,364     17.32s
UC a -tf            Fast                  51.65s  46.55 1,004,550     17.31s

ZOO ah:             High               1m 24.73s  44.48 1,043,357     26.83s
ZOO a:              Compress              44.90s  29.36 1,327,563     18.92s
ZOO af:             Store                 15.85s -00.15 1,882,209     15.04s


All the programs have been set to compress without including the filepaths,
that is, if they actually have an option to do this.

The STORE option of the archive programs looks like it takes up more space
than the 38 files, but normaly takes up less, due to the file slack mention
in COM-EXE.SET.
