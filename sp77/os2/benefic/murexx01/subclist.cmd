/* MaxUserREXX Examples                                                    */
/* Subscriber List                                                         */
'@echo off'

Parse Upper Arg NodeNumber

if NodeNumber = '' Then
    Exit 1

/* Setup the catch all loader for the user functions                       */
Call RxFuncAdd 'UserLoadFuncs', 'MaxUser', 'UserLoadFuncs'

/* Load all the user functions at once                                     */
Call UserLoadFuncs

/* Define some constants                                                   */
UserError = 'ERROR'
UserFile = 'D:\MAX\USER.BBS'
LastUserFile = 'D:\MAX\LASTUS'NodeNumber'.BBS'
UserPad = '       '

/* Open the user file for use */
UserCount = OpenUserFile(LastUserFile)
index = 0
Color = QueryUserVideoMode(index)
Call CloseUserFile

/* Open the user file for use */
UserCount = OpenUserFile(UserFile)

if UserCount <> UserError then do
    Signal On Syntax Name BadCommand
    Signal On Halt Name BadCommand
    ii = 0
    index = 0
    if Color = 'ANSI' Then
        Call CharOut , x2c('1b')'[2J'x2c('0d')||x2c('0a')||x2c('1b')'[1;33m'
    Say Copies(' ', 16)'Current Subscribers to the Workplace Connection'
    Call CharOut , x2c('0d')||x2c('0a')
    Say Copies(' ', 19)'Helping to Keep the Workplace Going Strong'
    if Color = 'ANSI' Then
        Call CharOut , x2c('1b')'[1;37m'
    Call CharOut , x2c('0d')||x2c('0a')||x2c('0d')||x2c('0a')||UserPad
    do until index = UserCount
        UserLevel = QueryUserPriviledge(index)
        UserExpInfo = QueryUserExpiryInfo(index)
        if UserLevel='EXTRA' Then Do
            Call CharOut , Left(QueryUserAlias(index), 20)'  '
            ii = ii + 1
            if ii // 3 = 0 Then
                Call CharOut , x2c('0d')||x2c('0a')||UserPad
        end
        index = index + 1
    end
    Call CharOut , x2c('0d')||x2c('0a')
    Call CharOut , x2c('0d')||x2c('0a')
    if Color = 'ANSI' Then
        Call CharOut , x2c('1b')'[0m'

    /* Close up shop and free the system resources */
    Call CloseUserFile
    Call CharOut , 'Press ENTER to continue. . .'
    Pull .
end

/* We are done, so we can drop all the functions                           */
Call UserDropFuncs
Exit 0

BadCommand:
    Say
    Say 'REXX Error ('rc')'
    Call CloseUserFile
    Call UserDropFuncs
    Exit 2
