/*                                                                         */
/* Creates a simple last caller list from the LASTUSxx.BBS files written   */
/* by Maximus when a caller is online. Should be called after the caller   */
/* logs off the system. ERRORLEVEL 4 or higher.                            */
/*                                                                         */
/* Don't forget to MECCA(P) it to something Maximus can display. Then all  */
/* you have to do is [link] or [display] it in your WELCOME.MEC or where   */
/* ever you think appropriate.                                             */
/*                                                                         */
'@echo off'

Parse Upper Arg UserFile MecFile .
if UserFile = '' Then
    Signal BadArgs

If MecFile = '' Then
    Signal BadArgs

if Stream(UserFile, 'c', 'query exists')='' Then
    Signal NoUserFile

if Stream(MecFile, 'c', 'query exists')<>'' Then Do
    Doscmd = 'DEL 'MecFile
    Doscmd
End

Say 'MaxUserREXX Last Caller Utility - Using 'UserFile

/* Setup the catch all loader for the user functions                       */
Call RxFuncAdd 'UserLoadFuncs', 'MaxUser', 'UserLoadFuncs'

/* Load all the user functions at once                                     */
Call UserLoadFuncs

/* Define some constants                                                   */
UserError = 'ERROR'
OutFile = 'LASTCALL.SAV'
HdrFile = 'LASTCALL.HDR'
Downloads = 0
Uploads = 0
index = 0
MAXENTRIES = 10
MAXNAME = 15
MAXCITY = 20
MAXDATE = 10
MAXCALLS = 7
LINEPAD = 9
col.1 = '[yellow on black]'
col.2 = '[white on black]'
col.3 = '[lightgreen on black]'
col.4 = '[lightcyan on black]'
col.5 = '[lightmagenta on black]'
rColor = Random(1,5)
NC = col.rColor
CC = '[lightred on black]'
DC = '[yellow on black]'
LC = '[white on black]'
EC = '[lightcyan on black]'
LP = Copies(' ', LINEPAD)
HLINE = '[CLS]'x2c('0d')||x2c('0a')
TLINE = EC||LP'┌'Copies('─', MAXNAME+1+MAXCITY+1+MAXDATE+1+MAXCALLS+2)'┐'
MLINE = LP'├'Copies('─', MAXNAME+1+MAXCITY+1+MAXDATE+1+MAXCALLS+2)'┤'
BLINE = LP'└'Copies('─', MAXNAME+1+MAXCITY+1+MAXDATE+1+MAXCALLS+2)'┘'LC

/* Open the user file for use */
UserCount = OpenUserFile(UserFile)

if UserCount <> UserError then do

    /* Gather user information */
    UserName = Left(QueryUserAlias(index), MAXNAME)
    UserCity = Left(QueryUserLocation(index), MAXCITY)
    LastCall = Left(QueryUserLastCallDate(index), MAXDATE)
    NoCalls = Right(QueryUserSystemCalls(index), MAXCALLS)

    /* Combine it to form last caller list info line */
    OutStr = LP'│'NC' 'UserName' 'CC||UserCity' 'DC||LastCall' 'LC||NoCalls' 'EC'│'

    /* Append info to caller list, and close it */
    Call LineOut OutFile, OutStr
    Call Stream OutFile, 'c', 'close'

    /* Trim down the last caller list to MAXENTRIES if necessary */
    idx = 1
    Do While Lines(OutFile)=1
        CallerList.idx = LineIn(OutFile)
        idx = idx + 1
    End
    idx = idx - 1
    Call Stream OutFile, 'c', 'close'
    if idx > MAXENTRIES Then Do
        Doscmd = 'DEL 'OutFile
        Doscmd
        Do i = idx-MAXENTRIES+1 to idx
            Call LineOut OutFile, CallerList.i
        End
        Call Stream OutFile, 'c', 'close'
    End
    Call LineOut MecFile, HLINE
    Do Until Lines(HdrFile)=0
        Call LineOut MecFile, LineIn(HdrFile)
    End
    Call LineOut MecFile, TLINE
    Call LineOut MecFile, LP'│'NC' 'Left('Caller', MAXNAME)' 'CC||Left('Location', MAXCITY)' 'DC||Left('Date', MAXDATE)' 'LC||Right('Calls', MAXCALLS)' 'EC'│'
    Call LineOut MecFile, MLINE
    Do While Lines(OutFile)=1
        text = LineIn(OutFile)
        Call LineOut MecFile, text
    End
    Call LineOut MecFile, BLINE
    Call LineOut MecFile, ' '
    Call Stream OutFile, 'c', 'close'

    NodeOneStats = QueryBBS_Stats('D:\Max\BBStat01.BBS')
    NodeTwoStats = QueryBBS_Stats('D:\Max\BBStat02.BBS')

    Parse Value NodeOneStats With NOC NOM NODL NOUL NOTC
    Parse Value NodeTwoStats With NTC NTM NTDL NTUL NTTC

    NOC = NOC + NTC
    NOM = NOM + NTM
    NODL = NODL + NTDL
    NOUL = NOUL + NTUL

    Call LineOut MecFile, LP||EC'        Total System Calls: 'NC||NOC||EC'    Calls Today: 'CC||NOTC||EC
    Call CharOut MecFile, '      Total Messages Out: 'DC||NOM||EC
    Call LineOut MecFile, '    KBytes DL: 'LC||NODL||EC'    KBytes UL: 'NC||NOUL||EC

    Call Stream MecFile, 'c', 'close'

    /* Close up shop and free the system resources */
    Call CloseUserFile
end

/* We are done, so we can drop all the functions                           */
Call UserDropFuncs
Exit

BadArgs:
    Say
    Say 'Usage: LCALLER <LASTUSxx.BBS> <LASTCALL.MEC>'
    Exit 1

NoUserFile:
    Say
    Say 'ERROR: UserFile does not exist'
    Exit 2
