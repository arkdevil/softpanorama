/* ------------------------------------------------------------------ */
/* REXXCC.CMD - a tiny REXX "compiler" (c) Bernd Schemmer 1994        */
/*                                                                    */
/* Usage: REXXCC source TO target {WITH copyright} {/IExt} {/IDate}   */
/*               {/IVer} {/Overwrite} {/UseSource} {/LineCount=n}     */
/*                                                                    */
/* Author                                                             */
/*   Bernd Schemmer                                                   */
/*   Baeckerweg 48                                                    */
/*   60316 Frankfurt                                                  */
/*   Germany                                                          */
/*   Compuserve: 100104,613                                           */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Description:                                                       */
/*                                                                    */
/* REXXCC "compiles" a OS/2 REXX program by substituting the source   */
/* code with any text. This is possible because the OS/2 REXX         */
/* interpreter stores a tokenized copy of each executed REXX program  */
/* in the EAs of the program. If you execute an OS/2 REXX program,    */
/* the OS/2 REXX interpreter first checks, if the tokenized copy in   */
/* the EAs is still valid and, if so, executes the tokenized copy     */
/* and ignores the source code.                                       */
/*                                                                    */
/* Usage:                                                             */
/*                                                                    */
/* 1. execute your REXX file to get the tokenized version of the      */
/* program                                                            */
/*                                                                    */
/* Note: You may use the switch '//t' (yes, there are two slashes!)   */
/*       to force the creation of the tokenized version of your       */
/*       program without executing it.                                */
/*                                                                    */
/* 2. call REXXCC to "compile" your REXX file.                        */
/* The syntax for REXXCC is:                                          */
/*                                                                    */
/*   REXXCC source TO target {WITH copyrightFile} {option} {voption}  */
/*                                                                    */
/* with:                                                              */
/*   source                                                           */
/*     is the name of the source file                                 */
/*     The extension of the source file must be '.CMD'.               */
/*     If you ommit the extension, REXXCC appends '.CMD' to the       */
/*     name of the source file.                                       */
/*                                                                    */
/*   TO                                                               */
/*     this is a neccessary keyword!                                  */
/*                                                                    */
/*   target                                                           */
/*     is the name of the target file or directory                    */
/*     The extension for the target file must be '.CMD'. If you ommit */
/*     the extension, REXXCC appends '.CMD' to the name of the target */
/*     file. If you enter a directory name for this parameter, REXXCC */
/*     uses the name of the source file as name for the target file.  */
/*                                                                    */
/*   WITH                                                             */
/*     this is a neccessary keyword!                                  */
/*                                                                    */
/*   copyrightfile                                                    */
/*     is the file with the copyright message which replaces the      */
/*     original source code in the "compiled" version of the program. */
/*     If you ommit the parameter copyrightFile, REXXCC uses only its */
/*     copyright message as copyright file. If the copyright file is  */
/*     equal with the source file REXXCC uses only the leading        */
/*     comment lines of the source file as copyright file.            */
/*                                                                    */
/*     Hint: You may use the equal sign (=) as name of the            */
/*           copyrightfile if you want to use the sourcefile as       */
/*           copyrightfile.                                           */
/*                                                                    */
/*   options                                                          */
/*     are misc. options for REXXCC. All options are in the format    */
/*                                                                    */
/*       /optionName{=optionValue}                                    */
/*                                                                    */
/*     with optionValue = 1 to turn the option on and optionValue = 0 */
/*     to turn the option off. Any other value for optionValue turns  */
/*     the option on. The default for optionValue is 1 (= turn the    */
/*     option on).                                                    */
/*     You may enter an option at any position in the parameters.     */
/*                                                                    */
/*     Possible options for REXXCC are:                               */
/*       IExt                                                         */
/*         if ON : do not check the extension of the source and       */
/*                 target files ( def.: OFF )                         */
/*       IVer                                                         */
/*         if ON : do not check the version of the REXX interpreter   */
/*                 and the source file ( def.: OFF )                  */
/*       IDate                                                        */
/*         if ON : do not check the date of the source file           */
/*                 ( def.: OFF )                                      */
/*                                                                    */
/*       Overwrite                                                    */
/*         if ON : overwrite an existing target file ( def.: OFF )    */
/*                                                                    */
/*       UseSource                                                    */
/*         if ON : use the source file as copyright file if the       */
/*                 parameter copyrightfile is missing ( def.: OFF )   */
/*                                                                    */
/*   voptions                                                         */
/*     are misc. options for REXXCC. All voptions are in the format   */
/*                                                                    */
/*       /voptionName=voptionValue                                    */
/*                                                                    */
/*     vopitonValue is any integer value greater or equal 0.          */
/*     You may enter a voption at any position in the parameters.     */
/*                                                                    */
/*     Possible voptions for REXXCC are:                              */
/*       LineCount=n                                                  */
/*         n is the number of leading comment lines of the source     */
/*         file which REXXCC should use as copyright file for the     */
/*         target file. REXXCC ignores this parameter, if you don't   */
/*         use the source file as copyright file.                     */
/*         ( def.: use all leading comment lines of the sourcefile )  */
/*         If n is not a whole number or if n is equal 0, REXXCC      */
/*         ignores n. If there are less than n leading comment lines  */
/*         in the source file, REXXCC ignores the value of n.         */
/*         example:                                                   */
/*                                                                    */
/*           REXXCC TEST.CMD TO PROGS\ WITH TEST.CMD /LineCount=50    */
/*           -> compile the file "TEST.CMD" to "PROGS\TEST.CMD" and   */
/*              use the first 50 comment lines of the source file as  */
/*              copyright file.                                       */
/*                                                                    */
/*     You may also set the defaults for the options and voptions in  */
/*     the environment variable "REXXCC", for example:                */
/*                                                                    */
/*       SET REXXCC=/IExt=1 /Overwrite /LineCount=20 /UseSource       */
/*                                                                    */
/*     Options and VOptions in the parameters overwrite the values of */
/*     the environment variable "REXXCC".                             */
/*                                                                    */
/* See also the Notes below.                                          */
/*                                                                    */
/* initial release: 01.07.1994 /bs                                    */
/* last Update:     18.11.1994 /bs                                    */
/*                                                                    */
/*                                                                    */
/* History                                                            */
/*                                                                    */
/*   V1.00  - 05.07.1994 /bs - initial release                        */
/*   V1.01  - 12.07.1994 /bs - added code to check if the temporary   */
/*                             path exists                            */
/*                           - change meaning of the 2nd parameter -- */
/*                             now it can be a directory name or a    */
/*                             file name                              */
/*                           - added code to check if the source file */
/*                             was changed after the last execution   */
/*                           - added code to check if the current     */
/*                             ADDRESS() environment is the CMD       */
/*   V2.00  - 20.08.1994 /bs - fixed a bug, where REXXCC did not      */
/*                             delete the temporary files and the     */
/*                             target file if an error occured        */
/*                           - added the parameters -IExt, -IVer and  */
/*                             -IDate                                 */
/*                           - added the support for the envrionment  */
/*                             variable "REXXCC"                      */
/*                           - added the parameter -LineCount         */
/*                           - added the color support                */
/*   V2.01  - 01.10.1994 /bs - INTERNAL VERSION                       */
/*   V2.05  - 18.11.1994 /bs - advanced the error handling            */
/*                           - added the abbreviation '=' for the     */
/*                             parameter copyrightfile                */
/*                           - added the parameter -Overwrite         */
/*                           - added the parameter -UseSource         */
/*                                                                    */
/* Notes:                                                             */
/*                                                                    */
/* REXXCC can only "compile" files on a read/write medium. So if you  */
/* want to "compile" a REXX file from a read-only medium (a CD ROM    */
/* for example) you MUST copy it to a read/write medium (e.g. a hard  */
/* disk) and execute it there (!) before "compiling" it!              */
/*                                                                    */
/* REXXCC only overwrites existing target files if the option         */
/* '-Overwrite' is set.                                               */
/*                                                                    */
/* The copyright file must begin with a valid REXX comment in line 1  */
/* column 1. You may suppress this check with the parameter '-IExt'.  */
/*                                                                    */
/* You should not use 'TO' or 'WITH' as name for any of the           */
/* parameters for REXXCC.                                             */
/*                                                                    */
/* REXXCC needs the programs EAUTIL and ATTRIB to be in a directory   */
/* in the environment variable "PATH".                                */
/*                                                                    */
/* Note that you must reExecute a source file after you changed it    */
/* before you can "compile" it. You may suppress this check with the  */
/* parameter '-IDate'.                                                */
/*                                                                    */
/* Set the environment variable 'ANSI' to "0", "NO" or "OFF" if you   */
/* don't want colors.                                                 */
/*                                                                    */
/* To get a smaller version of REXXCC use the following commands:     */
/*                                                                    */
/*   MD PROGRAM                                                       */
/*   REXXCC REXXCC.CMD to PROGRAM WITH REXCC.CMD /LINECOUNT=15        */
/*                                                                    */
/* Note that you can't change the name of REXXCC. Note also that you  */
/* only get a very short usage description if you use the parameter   */
/* '/?' with the smaller version.                                     */
/* IMPORTANT: YOU MUSTN'T SHARE A CHANGED VERSION OF REXXCC!          */
/*                                                                    */
/* Known limitations:                                                 */
/*                                                                    */
/* You can only "compile" REXX file which are less than 64 K in       */
/* tokenized form. 64 K is the maximum length of the EAs in which the */
/* REXX interpreter stores the tokenized form of REXX programs.       */
/* (Note that the second length shown by the dir command on an HPFS   */
/* drive is the length of the EAs.)                                   */
/*                                                                    */
/* You should not use the function "SOURCELINE" in a program          */
/* "compiled" by REXXCC because there is no source code anymore :-).  */
/* If you want to use the function "SOURCELINE" (e.g. in an error     */
/* handler) use the following command sequence (this avoids an error  */
/* if you call the function "SOURCELINE" with a not existing line     */
/* number):                                                           */
/*                                                                    */
/*  if sourceLine( errorLineNo ) <> '' then                           */
/*  do                                                                */
/*    call charOut, left( " The line reads: ", 80 )                   */
/*    call charOut, left( " *-* " || sourceline( errorLineNo ), 80 )  */
/*  end                                                               */
/*                                                                    */
/* You may use difficult lines in the source file and the copyright   */
/* file to distinguish between the original and the "compiled"        */
/* version using "SOURCELINE" while running your program.             */
/*                                                                    */
/* You can not load a "compiled" program in the REXX macro space.     */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Terms for using this version of REXXCC                             */
/*                                                                    */
/* This version of REXXCC is Freeware. You can use and share it as    */
/* long as you neither delete nor change any file or program in the   */
/* archiv!                                                            */
/* IT IS VERY IMPORTANT THAT YOU SHARE THIS PROGRAM ONLY WITH IT'S    */
/* EXTENDED ATTRIBUTES (EAs) - because without them it will not run!  */
/*                                                                    */
/* If you find REXXCC useful, your gift in any amount would be        */
/* appreciated.                                                       */
/*                                                                    */
/* Please direct your inquiries, complaints, suggestions, bug lists   */
/* etc. to the adress noted above.                                    */
/*                                                                    */
/* If you like and use REXXCC it would be nice if you send me a       */
/* postcard.                                                          */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Terms for distributing REXXCC                                      */
/* for vendors, sysops and others 'for-profit' distributors           */
/*                                                                    */
/* I encourage all shareware vendors, BBS sysops and other            */
/* 'for-profit' distributors to copy and distribute this version      */
/* of REXXCC subject to the following restrictions:                   */
/*                                                                    */
/*  The REXXCC freeware package - including all related program files */
/*  and documentation files - cannot be modified in any way (other    */
/*  than that mentioned below) and must be distributed as a complete  */
/*  package, without exception.                                       */
/*                                                                    */
/*  Small additions to the package, such as the introductory or       */
/*  installation batch files used by many shareware disk vendors, are */
/*  acceptable.                                                       */
/*                                                                    */
/*  You may charge a distribution fee for the package, but you must   */
/*  not represent in any way that you are selling the software itself.*/
/*                                                                    */
/*  The disk-based documentation may not be distributed in printed    */
/*  form without the prior written permission of the author.          */
/*                                                                    */
/*  You shall not use, copy, rent, lease, sell, modify, decompile,    */
/*  disassemble, otherwise reverse engineer, or transfer this         */
/*  program except as provided in this agreement. Any such unautho-   */
/*  rized use shall result in immediate and automatic termination of  */
/*  the permission to distribute this program.                        */
/*                                                                    */
/*  I reserve the right to withdraw permission from any vendor to     */
/*  distribute my products at any time and for any reason.            */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Warranty Disclaimer                                                */
/*                                                                    */
/* Bernd Schemmer makes no warranty of any kind, expressed or         */
/* implied, including without limitation any warranties of            */
/* merchantability and/or fitness for a particular purpose.           */
/*                                                                    */
/* In no event will Bernd Schemmer be liable to you for any           */
/* additional damages, including any lost profits, lost savings, or   */
/* other incidental or consequential damages arising from the use of, */
/* or inability to use, this software and its accompanying documen-   */
/* tation, even if Bernd Schemmer has been advised of the possibility */
/* of such damages.                                                   */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Copyright                                                          */
/*                                                                    */
/* REXXCC, the documentation for REXXCC and all other related files   */
/* are Copyright 1994 by Bernd Schemmer                               */
/*                                                                    */
/* All rights reserved.                                               */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Technical information                                              */
/*                                                                    */
/*                                                                    */
/* Returncodes and error messages                                     */
/*                                                                    */
/* Note: If you get one of the errors marked with a plus (+) in the   */
/*       table below - please contact the author!                     */
/*                                                                    */
/*    RC  Error message                                               */
/*   ---------------------------------------------------------------- */
/*     0  ok, target file successfully created (NO ERROR)             */
/*     1  parameter for help detected, usage shown (NO ERROR)         */
/*     2  Can not find a name for a temporary file (Check the         */
/*        variable "TEMP" or "TMP")                                   */
/*     3  Can not find the program EAUTIL.EXE                         */
/*        (Check the variable "PATH")                                 */
/*     4  Can not find the program ATTRIB.EXE                         */
/*        (Check the variable "PATH")                                 */
/*    11  Parameter missing                                           */
/*    12  The source file "%1" does not exist                         */
/*    13  The extension of the source file must be ".CMD"             */
/*    14  The extension for the target file must be ".CMD"            */
/*    15  The target file "%1" already exist                          */
/*    16  CopyrightFile "%1" does not exist                           */
/*    17  The copyrightFile can not be a device                       */
/*    18  The target file can not be equal with the source file       */
/*    31  The CopyrightFile must begin with a REXX comment in         */
/*        line 1 column 1'                                            */
/* +  32  OS Error %1 deleting the temporary file "%2"                */
/* +  33  OS Error %1 deleting the existing target file "%2"          */
/* +  34  OS Error %1 compiling the inputfile "%2"                    */
/*    35  You must first execute the inputfile "%1" before            */
/*        compiling it                                                */
/*    36  Can not find a name for a temporary file (Check the         */
/*        variable "TEMP" or "TMP")                                   */
/* +  37  OS Error %1 creating the outputfile "%2"                    */
/* +  38  OS Error %1 creating the outputfile "%2"                    */
/* +  39  OS Error %1 creating the outputfile "%2"                    */
/* +  40  OS Error %1 creating the outputfile "%2"                    */
/* +  41  OS Error %1 creating the outputfile "%2"                    */
/* +  42  OS Error %1 creating the outputfile "%2"                    */
/*    51  You must first execute the inputfile "%1" before            */
/*        compiling it                                                */
/*    52  You must first execute the inputfile "%1" before            */
/*        compiling it                                                */
/*    53  You must reExecute the source file after every              */
/*        change before you can compile it                            */
/* +  54  Internal error E1                                           */
/*    60  Invalid switches "%1" in the environment variable "REXXCC"! */
/*    61  The string "%1" in the environment variable "REXXCC" is     */
/*        not a valid option                                          */
/*    62  The string "%1" in the parameters is not a valid option     */
/*                                                                    */
/*   250  Program aborted by the user                                 */
/* + 252  This is a patched version of the program. It won't work     */
/* + 253  Invalid REXX interpreter version                            */
/* + 254  Internal error OTFT                                         */
/* + 254  Internal error FTOT                                         */
/* + 254  Internal error ODFD                                         */
/* + 254  Internal error FDOD                                         */
/*   255  You can only execute this program in a CMD session!         */
/*                                                                    */
/**********************************************************************/
/* compiled on 11/18/94 at 19:16:25 with REXXCC V2.05 (c) Bernd Schemmer 1994 */  
