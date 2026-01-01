/***********************************************************************/
/* Program     : simple.rex                                            */
/* Version     : 1.00                                                  */
/* Author      : Mark Hessling                                         */
/* Date        : 13 Aug 1995                                           */
/* Purpose     : This program is an example of how simple it is to     */
/*             : display information from a SQL database.              */
/* Arguments   : None.                                                 */
/***********************************************************************/
Trace o
query1 = "select empno, ename, sal from emp order by empno"
connect.oracle = "scott/tiger"
connect.msql = "REXXSQL"

Call Initialise
If sqlconnect(,connect.database) < 0 Then Abort()
If sqlcommand("Q1",query1) < 0 Then Abort()
Do i = 1 To q1.empno.0
   Say Right(q1.empno.i,6) Left(q1.ename.i,15) Right(q1.sal.i,8)
End
Call Finalise
Return

/***********************************************************************/
Abort: Procedure Expose sqlca.
/***********************************************************************/
Parse Arg text
If text \= '' Then Say text
Else
   If sqlca.intcode = -1 Then Say sqlca.sqlerrm
   Else Say sqlca.interrm
Call Finalise
Exit 1

/***********************************************************************/
Initialise:
/***********************************************************************/
Parse Source os method .
If os = 'OS/2' & method = 'COMMAND' Then
   Do
     Call RXFuncAdd 'SqlLoadFuncs','REXXSQL','SqlLoadFuncs'
     Call SqlLoadFuncs
     dll = 'YES'
   End
version = sqlvariable("VERSION")
If version < 0 Then Abort()
database = Word(version,7)
Return

/***********************************************************************/
Finalise:
/***********************************************************************/
If dll = 'YES' Then Call SqlDropFuncs
Return
