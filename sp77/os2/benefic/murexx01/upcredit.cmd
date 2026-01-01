/* MaxUserREXX Examples                                                    */
'@echo off'

/* Setup the catch all loader for the user functions                       */
Call RxFuncAdd 'UserLoadFuncs', 'MaxUser', 'UserLoadFuncs'

/* Load all the user functions at once                                     */
Call UserLoadFuncs

/* Define some constants                                                   */
UserError = 'ERROR'
UserFile = 'D:\MAX\USER.BBS'

/* Open the user file for use */
UserCount = OpenUserFile(UserFile)

if UserCount <> UserError then do
    Signal On Syntax Name BadCommand
    Signal On Halt Name BadCommand
    index = 0
    Say '  U#   Name                 Credit balance'
    Say ' ---- -------------------- ------------------------------'
    do until index = UserCount
        Call SetUserCredit index, '65535'
        Call CommitUser index
        Say Right(index, 5)' 'Left(QueryUserName(index), 20)' 'QueryUserCredit(index)
        index = index + 1
    end

    /* Close up shop and free the system resources */
    Call CloseUserFile
end

/* We are done, so we can drop all the functions                           */
Call UserDropFuncs
Exit

BadCommand:
    Say
    Say 'REXX Error ('rc')'
    Call CloseUserFile
    Call UserDropFuncs
    Exit
