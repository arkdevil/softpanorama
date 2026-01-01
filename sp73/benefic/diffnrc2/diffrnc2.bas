1000 REM **** Program written by Sam Mecham ****
1020 REM **** Thursday, November 20, 1986   ****
1040 REM **** PO Box 1324, Provo, UT  84603 ****
1060 REM
1080 REM This program, DIFFRNCE.BAS, together with DIFFRNCE.BAT,
1100 REM BASICA, and the MS-dos SORT.EXE will examine file listings
1120 REM from two bulletin boards or other sources and determine
1140 REM which files in the first (primary) do NOT occur in the second
1160 REM the second (secondary) file.
1180 REM
1200 REM The reason I wrote this program was to establish differences
1220 REM in BBS listings so I could meet my quota of uploads by searching
1240 REM other boards for files that were not to be found on one.  This
1260 REM way I could keep most sysops happy with uploads and increase my
1280 REM access time on my favorite boards.
1300 REM
1320 REM Modified Thursday, February 12, 1987 to use Qsort v2.1 to
1340 REM sort the primary and secondary files.
1360 REM
1380 KEY OFF:CLS
1400 OPEN "primary"      FOR INPUT  AS 1
1420 OPEN "secondry"     FOR INPUT  AS 2
1440 OPEN "diffrnce.lst" FOR OUTPUT AS 3
1460 GOSUB 1640:GOSUB 1660
1480 WHILE NOT EOF(1)
1500    PRINT PLINE$, SLINE$,
1520    IF PLINE$ = SLINE$ THEN GOSUB 1640:GOSUB 1660     :GOTO 1580
1540    IF PLINE$ > SLINE$ THEN GOSUB 1660                :GOTO 1580
1560    PRINT PLINE$;:PRINT#3,LNE$: GOSUB 1640
1580 PRINT:WEND
1600 CLOSE
1620 SYSTEM
1640 LINE INPUT #1, LNE$ : PLINE$ = LEFT$(LNE$,12) :RETURN
1660 IF EOF(2) THEN RETURN
1680 LINE INPUT #2, SLINE$ : SLINE$ = LEFT$(SLINE$,12) :RETURN
