Sub DosToUnix (ByVal FromFile$, ByVal ToFile$)
    BytesToRead& = FileLen(FromFile$)
    If FileLength(ToFile$) > 0 Then Kill (ToFile$)
    Open FromFile$ For Input As #1
    Open ToFile$ For Binary Access Write As #2
    Const maxBuff& = 30000 ' Read up to 30000 bytes each time
    Do While BytesToRead& > 0
       BuffSize& = BytesToRead&
       If BuffSize& > maxBuff& Then BuffSize& = maxBuff&
       buffer$ = CRLF(Input$(BuffSize&, #1), 10) ' Read and convert LF to CR/LF
       ' NB: Problem if CR/LF is found exactly at a maxBuff& boundary:
       If Asc(Pick(buffer$, BuffSize&, 1)) = 13 Then ' Fix it:
          buffer$ = Pick(buffer$, 1, BuffSize& - 1)  ' remove CR (last chr)
       End If
       Put #2, , buffer$
       BytesToRead& = BytesToRead& - BuffSize&
    Loop
    Close #1
    Close #2
End Sub

Function FileExist% (ByVal FileName$)
    tempTab& = ITabDir(FileName$, 1)
    If ITabGetNumLines(tempTab&) Then
       FileExist% = True
    Else
       FileExist% = False
    End If
    ITabDelete tempTab&
End Function

Function FileLength& (ByVal FileName$)
    tempTab& = ITabDir(FileName$, 3)
    ' Will return 0 if file does not exist:
    FileLength& = ITabGetLong(tempTab&, 1, 3)
    ITabDelete tempTab&
End Function

Sub FileSubstStr (ByVal FileName$, ByVal FromStr$, ByVal ToStr$)
    table& = ITabRead(FileName$, IT_TEXTFILE)
    row% = 0
    Do
       row% = ITabFind(table&, FromStr$, row% + 1, 1, IT_WILD)
       If row% = 0 Then Exit Do
       ITabPutLine table&, row%, SubstAll(FromStr$, ToStr$, ITabGetLine(table&, row%))
    Loop
    ok% = ITabWrite(table&, FileName$, IT_TEXTFILE)
    ITabDelete table&
End Sub

' Return the "filename.ext" part of a filepattern
'
Function GetFile$ (ByVal FilePattern$)
    pos% = Find(":", FilePattern$, 1)
    If (Find("\", FilePattern$, 1)) Or (pos%) Then
        While Find("\", FilePattern$, pos% + 1) ' find last "\"
              pos% = Find("\", FilePattern$, pos% + 1)
        Wend
        GetFile$ = Pick(FilePattern$, pos% + 1, 0)
    Else ' take it all
        GetFile$ = FilePattern$
    End If
End Function

' Return number of words in a string given a delimiter
' Leading, trailing and repeated embedded delimiters are ignored
'
Function GetNumWords% (ByVal FileMask$, ByVal Delim$)
    bs% = -Asc(Delim$)
    n% = 0
    While Len(PickWord(FileMask$, n% + 1, bs%))
        n% = n% + 1
    Wend
    GetNumWords% = n%
End Function

' Return "D:\SUB1\SUB2\" for a given file pattern
'                        *.*
'                        FILE*.EXT
'                        \FILE*.*
'                        DIR\FILE*.*
'                        \DIR\FILE*.*
'                        C:\FILE*.E?T
'                        D:DIR\FILE*.*
'                        D:\DIR\FILE*.*
'                        D:..\DIR\FILE*.*
'                        ..\DIR\FILE*.*
'                        .\FILE*.*
'                        etc...
'
Function GetPath$ (ByVal FilePattern$)
    If (Find("\", FilePattern$, 1)) Or (Pick(FilePattern$, 2, 1) = ":") Then
        path$ = FullPath(UCase$(FilePattern$))
        pos% = 0
        While Find("\", path$, pos% + 1) ' find last "\"
              pos% = Find("\", path$, pos% + 1)
        Wend
        GetPath$ = Pick(path$, 1, pos%)
    Else ' use current path
        GetPath$ = SysInfo(DISK_PATH) & "\"
    End If
End Function

Sub ShowPath ()
' Display search path in List1:
 eTab& = ITabEnvList()
 row% = ITabFind(eTab&, "PATH", 1, 1, IT_EXACT)
 path$ = ITabGet(eTab&, row%, 2) ' e.g. "C:\DOS;C:\WINDOWS;D:\UTILS;E:\PROG"
 i% = 1
 Do
    p$ = PickWord(path$, i%, Asc(";"))
    If Len(p$) = 0 Then Exit Do
 '>>  List1.AddItem p$
    i% = i% + 1
 Loop
 ITabDelete eTab&
End Sub

Sub UnixToDos (ByVal FromFile$, ByVal ToFile$)
    BytesToRead& = FileLen(FromFile$)
  ' If FileLength(ToFile$) > 0 Then Kill (ToFile$)
    If FileExist(ToFile$) Then Kill (ToFile$)
    Open FromFile$ For Input As #1
    Open ToFile$ For Binary Access Write As #2
    Const maxBuff& = 30000 ' Read up to 30000 bytes each time
    Do While BytesToRead& > 0
       BuffSize& = BytesToRead&
       If BuffSize& > maxBuff& Then BuffSize& = maxBuff&
       buffer$ = CRLF(Input$(BuffSize&, #1), -10) ' Read and convert CR/LF to LF
       Put #2, , buffer$
       BytesToRead& = BytesToRead& - BuffSize&
    Loop
    Close #1
    Close #2
End Sub

