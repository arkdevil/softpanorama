*--------------------------------------------------------------------------
* RBarDemo.PRG - Program to demonstrate the use of the functions
*                in the Clipper Library RBarLib
*
* Used functions :
*
*	R_OpnBar ()	- Open   a progress bar
*	R_UpdBar ()	- Update a progress bar
*	R_ClsBar ()	- Close  a progress bar
*	R_Ntx ()	- Index a file with progress indication
*	R_Pack ()	- Pack  a file with progress indication
*
* This demo has been written for Clipper version 5.xx
*
* Compile    :	CLIPPER RBARDEMO /N
*
* Link       :	RTLINK   file RBarDEMO lib RBar_C50   - or -
*		BLINKER  file RBarDEMO lib RBar_C50   - or -
*		EXOSPACE file RBarDEMO lib RBar_C50
*		(Replace C50 with C52 for Clipper v5.2x)
*
* Syntax     :  RBarDEMO
*--------------------------------------------------------------------------
* Date       :  19/09/94
*--------------------------------------------------------------------------
* Author     :  Rolf van Gelder
*               Binnenwiertzstraat 27
*               5615 HG  EINDHOVEN
*	        THE NETHERLANDS
*
* E-Mail     :  Internet : RCROLF@urc.tue.nl
*               BitNet   : RCROLF@heitue5
*--------------------------------------------------------------------------
* (c) 1993-94  Rolf van Gelder, All rights reserved
*--------------------------------------------------------------------------

*--------------------------------------------------------------------------
* CONSTANTS
*--------------------------------------------------------------------------
#define	K_ESC	27

*--------------------------------------------------------------------------
* STATIC CODEBLOCKS
*--------------------------------------------------------------------------

*-- Headerline (with clear screen)
STATIC	bHeader := { || Scroll(), DevPos (0,0), ;
                        DevOut ('RBarDemo: Demo program for RBarLib v1.2 - '+;
                                '19/09/94    (C) 1993-94  Rolf v Gelder' ), ;
                        DevPos (1,0), ;
                        DevOut ( Replicate ('─',80) ) }


*--------------------------------------------------------------------------
*
*                          Main function : RBarDemo
*
*--------------------------------------------------------------------------
FUNCTION RBarDemo

*-- Main menu
LOCAL	aMenu := { 'Index demo file (with progress bar)', ;
                   'Pack demo file (with progress bar)', ;
                   'Calculate average salary', ;
                   'Print a report to disk (with progress bar)', ;
                   'End of Demo' }

LOCAL	nChoice := 1		&& Menu choice

LOCAL	nPersons		&& Counter : number of persons
LOCAL	nSalTot			&& Counter : total of salaries

LOCAL	aBar := {}		&& Progress bar
LOCAL	nRecs			&& Number of records in DBF
LOCAL	nRecCount		&& Record counter

IF IsColor ()
   *-- Set screen color

   SetColor ( 'W+/RB' )

ENDIF


*--------------------------------------------------------------------------
* M A I N   P R O G R A M   L O O P
*--------------------------------------------------------------------------
DO WHILE .t.

   *-- Display header lines
   Eval ( bHeader )

   DevPos ( 3, 31 )
   DevOut ( '-+- MAIN  MENU -+-' )

   *-- Draw box
   @5,17 TO 11,62 DOUBLE

   *-- Display main menu
   nChoice := AChoice ( 6, 19, 10, 60, aMenu, , , nChoice )

   IF LastKey () = K_ESC .or. nChoice = 5
      *-- <Esc> or 'End of Demo'
      EXIT
   ENDIF

   *-- Display header lines
   Eval ( bHeader )

   DO CASE
   CASE nChoice = 1
      *-- Index demo file

      DevPos ( 3, 24 )
      DevOut ( '>>> INDEX  THE DEMO DBF FILE <<<' )
      DevPos ( 5, 0 )

      USE DemoDBF NEW

      R_Ntx ( 'Upper(Name)', 'DEMONAME', 'Indexing demo file' )

      dbCloseAll ()


   CASE nChoice = 2
      *-- Pack demo file

      DevPos ( 3, 25 )
      DevOut ( '>>> PACK THE DEMO DBF FILE <<<' )
      DevPos ( 5, 0 )

      USE DemoDBF NEW

      R_Pack ( 'Packing demo file' )

      dbCloseAll ()


   CASE nChoice = 3

      DevPos ( 3, 22 )
      DevOut ( '>>> CALCULATE THE AVERAGE SALARY <<<' )
      DevPos ( 5, 0 )

      nSalTot  := 0			&& Total field
      nPersons := 0			&& Number of persons

      USE DemoDBF NEW

      nRecs := LastRec ()
      IF nRecs < 1
         *-- Prevent zero-division
         nRecs := 1
      ENDIF

      nRecCount := 0

      aBar := R_OpnBar ( ' CALCULATING AVERAGE SALARY ', ;
         nil, nil, nil, 'GR+/B', 'R+/B' )

      dbEval ( { || nPersons++, nSalTot += _FIELD->Salary }, ;
               nil, ;
               { || R_UpdBar ( aBar, 100 * ++nRecCount / nRecs ) } )

      R_ClsBar ( aBar )

      Alert ( 'The average salary = ' + Str ( nSalTot / nPersons, 9, 2 ) )

      dbCloseAll ()


   CASE nChoice = 4
      *-- Print a report to disk (with progress bar)

      DevPos ( 3, 15 )
      DevOut ( '>>> PRINT A REPORT TO DISK (WITH PROGRESS BAR) <<<' )
      DevPos ( 5, 0 )

      USE DemoDBF NEW

      nRecs := LastRec ()
      IF nRecs < 1
         *-- Prevent zero-division
         nRecs := 1
      ENDIF

      nRecCount := 0

      aBar := R_OpnBar ( ' PRINTING A REPORT ', ' <Esc> = Abort ' )

      REPORT FORM DemoFRM ;
         WHILE ( I_Cont() .and. R_UpdBar ( aBar, 100 * ++nRecCount/nRecs ) ) ;
         TO FILE DemoLst.Txt NOCONSOLE

      R_ClsBar ( aBar )

      Alert ( 'Report printed to file DEMOLST.TXT.' )

      dbCloseAll ()

   ENDCASE

ENDDO

DevPos ( 23, 0 )

RETURN nil


*--------------------------------------------------------------------------
*
* I_Cont : Tests if the <Esc>-key has been pressed while printing
*
*--------------------------------------------------------------------------
FUNCTION I_Cont

IF InKey () = K_ESC

   IF Alert ( 'Do you want to abort ?', { "NO", "YES" } ) = 2

      RETURN .f.

   ENDIF

ENDIF

RETURN .T.	&& Continue
*
* EOF RBarDemo.PRG ========================================================