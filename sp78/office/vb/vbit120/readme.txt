_____________________________________________________________________________

VBIT: Visual Basic Invisible Tools 1.20
_____________________________________________________________________________

> WHAT IS VBIT?

  VBIT is a library of useful and timesaving routines which
  makes life easier for any Visual Basic programmer.

  Basic contents are as follows:

  + Simple, but very powerful routines for string-manipulation

  + Extensively simplified reading/writing of INI-files compared
    to API-calls

  + Routines for reading system-information, i.e. available
    disk space, memory, screen resolution etc.

  + Dynamic one/two-dimensional tables (arrays) consisting of dynamic text-
    strings enables you to manipulate significantly bigger amounts of data
    than Visual Basic alone can handle. Smart sorting, seek, read files,
    write to file, linking to spreadsheets etc. is also included.

  + Encryption algorithms (with no "back-door") enable you to easily
    protect your data against unwanted intruders.

  + Elegant copy protection of software and applications. This software
    (VBIT) uses the same copy protection itself, so try it out and evaluate.

  VBIT is an InfoTech AS product. This package is intended for
  Visual Basic, but the same software will soon be available for C++.

  Please see the enclosed files VBIT.WRI, VBITABLE.WRI, VBITFILE.WRI and
  VBITVTSS.WRI (standard Windows 3.1 Write format - can also be read
  from MS Word) for a detailed  description of routines and functionality.

  This software is distributed as "shareware" (see below for details), and
  we intend to ship regular updates. If this file is more than a couple of
  months old (see file-date), it is likely that there is a newer release in
  circulation, so call your favorite BBS's to get the most recent version.

  You can visit our WWW-pages to check:      http://www.vestnett.no/~idb/

  The latest release of VBIT will also always be avaliable at Trader's
  Mascot BBS, running Excalibur BBS (+47/7012-9014 or +47/7012-5102).

  Any comments and/or suggestions are welcome, and can be sent/mailed to:

  InfoTech AS                                           idb@vestnett.no
  Strandgt. 207                                         """""""""""""""
  N-5004 BERGEN, Norway

or

  Trader's Mascot AS                                  nornes@oslonett.no
  Postboks 3098 Sentrum                               ^^^^^^^^^^^^^^^^^^
  N-6001 AALESUND, Norway

_____________________________________________________________________________

NB: This file contains special characters based on MS DOS character set.
    If you use a  Windows  program like  Notepad  to read this,  special
    characters will not display correctly, and the examples in this document
    will not be readable.

_____________________________________________________________________________

> TABLES

  A table is a matrix of text-strings, which can be compared to an invisible
  spreadsheet in RAM. The tables can be dimensioned according to your needs,
  and dynamic changes can be made at any time. You can read tables directly
  from a number of file formats, and the tables are automatically
  dimensioned according to the file-contents. The same applies for writing
  tables to different file formats.

  Reading and writing data from/to tables, seek and sort are very fast
  operations.

  The sorting routine for tables has some unique features. It is the only
  sorting routine known that gives a logical sorting of text containing
  numbers.

  Example:      Ordinary sorting                VBIT SmartSort

                Number 1 of 100                 Number 1 of 100
                Number 10 of 100                Number 2 of 100
                Number 100 of 100               Number 10 of 100
                Number 2 of 100                 Number 20 of 50
                Number 20 of 100                Number 20 of 100
                Number 20 of 50                 Number 100 of 100

  Sorting of special characters is greatly improved compared to most
  competing sort-routines. Characters like /E/É/e/é/è/ë/ê/ are treated as
  variations on the same letter, i.e. the difference is only significant
  for the sort-order when the remaining characters are identical.

  Example:
                Sequence 1
                Sequènce 2
                Sequence 3
                Sequènce 3
                Sequènce 4
                Sequencè 5
                Sequencé 6

  Between record 1 and 2 the difference between "e" and "è" has no
  significance since the remaining characters are different. The same
  applies for record 2 and 3. The only difference between record 3 and 4
  is "e"/"è", and consequently the record containing "e" will be sorted in
  front of the other, since "e" is defined before "è".

  You may say that this is plain trivia, but may change your mind when you
  see how most other programs handles sorting of the same records:

                Sequence 1
                Sequence 3
                Sequencé 6
                Sequencè 5
                Sequènce 2
                Sequènce 3
                Sequènce 4

  VBIT contains several different seek-routines for finding data in a
  table, i.e. exact match, wildcards and binary-search (data in a sorted
  table)
_____________________________________________________________________________

> STRING-HANDLING / INI-FILES

  Most Visual Basic programmers sooner or later face the "problem" that
  most program-utilities for returning strings, anticipate that the calling
  program has allocated space for the returned string. To illustrate this
  we will show you the difference between reading INI-files traditionally
  (via API) and using VBIT:

  ' Read name of starting program for Windows from SYSTEM.INI:

    Declare Function GetPrivateProfileString% Lib "Kernel" (ByVal pAppName$,
                     ByVal pKeyName$, ByVal pDefault$,
                     ByVal pReturnedString$, ByVal nSize%, ByVal pFileName$)

    txt$ = String$(80, " ") ' Reserve space for 80 chars
    len% = GetPrivateProfileString("boot","shell","",txt$,80,"SYSTEM.INI")
    StartProg$ = Left$(txt$, len%) ' Possible result: "progman.exe"

  ' Same as above using VBIT (VBIT.BAS is included in the project):

    StartProg$ = IniFileGetString("SYSTEM.INI", "boot", "shell")

  I think we have made our point, and showed beyond reasonable doubt which
  method is the easiest to PROGRAM, MAINTAIN and last but not least to
  UNDERSTAND!

  VBIT provides a number of powerful routines for string-manipulation
  that Visual Basic "lacks": pick words from strings, swap parts of strings,
  formatting, translation between DOS and Windows character sets and much
  more. See VBIT.WRI for a complete and detailed documentation.

_____________________________________________________________________________

> SYSTEM INFORMATION

  Routines that gives easy access to system-information: screen resolution,
  number of colors, free disk-space, available RAM, disk(ette)-unit status
  etc. Details on environment variables and directory information can be
  read directly into tables.

_____________________________________________________________________________

> ENCRYPTION

  If you want to protect data against unwanted intruders, you can achieve
  this by using the VBIT encryption routines. These routines are not
  based on any standard algorithm specified by "Big Brother", and has
  therefore no "back door". There is no possibility whatsoever to recover
  an encrypted string without the correct key - not even for those who
  made the program.

  The routines are very simple in use; you specify the text-string to be
  coded together with the "secret key" and the result is a completely
  unreadable string. When decoding the same string, you specify the
  unreadable string and its key, and the original string is returned.
  Using wrong keys will not unlock any doors.

  Example:

          TextIn$  = "Private information..."
          Secret$  = "Sesam$ΣzaM"
          Crypt$   = Encrypt (TextIn$, Secret$)
          TextOut$ = Decrypt (Crypt$,  Secret$)

  ' TextOut$ and TekstIn$ will be identical, and
  ' Crypt$ will contain an unreadable string.
_____________________________________________________________________________

> COPY PROTECTION

  The program library VBIT.DLL is copy protected. If you have no valid
  license, you will be made aware of this by an annoying pop-up window
  reminding you to contact InfoTech AS and purchase a copy. Most of the
  VBIT routines will for the time being function without the annoying reminder,
  but when you use table-functions or the encryption routines, the testing
  for a valid license is activated.

  The only way to get rid of the "license-alarm" is to purchase a license
  code from InfoTech AS. The license-code consists of a 6-letter alphanumeric
  string which is derived from the name of the licensee. The license-name and
  corresponding code must be inserted into all programs using VBIT:

     status% = LisenseVBIT("User Name, Address", "CODE01")

  This code is inserted in Form Load in the applications startup form.

  All applications using VBIT must have a license for the name holding
  Copyright for the application. INFOTECH.INI will contain a list of all
  programs using VBIT. If the application is using a licensed version
  of VBIT, the licensee name will appear as the copyright holder of the
  application. This means that an application using a "borrowed" license
  code will appear as copyrighted by the name connected to the violated
  license. Somebody actively programming a call to LicenseVBIT using
  somebody else's name and code, can not claim to have acted in good faith.

  A similar copy protection scheme is available for all applications
  using VBIT, provided a valid license:

  The call      code$ = LicenseGetCode("User Name","SECRET_KEY")
  will return a code for the given user name. This call is supposed
  to be used in a program only available for the distributor of
  the application.

  The following statement is put into the application:
                status% = LicenseProgram(UserName$, Code$, "SECRET_KEY")

  Depending on the result, status%, your application can determine whether
  the username/code is valid for this program, and take appropriate actions.
  Different applications can have different keys ("SECRET_KEY_PROG2").

  When LicenseProgram has been called with a valid code, the user name will
  be inserted in INFOTECH.INI connected to the name of your application in
  the group [License].
_____________________________________________________________________________

> SHAREWARE: RULES FOR USE AND DISTRIBUTION

  VBIT is distributed as "shareware". This term must not be mixed up
  with "Freeware" or "Public domain". "SHAREWARE" is a method for
  distribution of software which is protected by COPYRIGHT like all other
  commercial software.

  The "shareware" concept gives potential users the opportunity to evaluate
  the software before they decide whether they want to pay for the right
  to use it.

  It is perfectly legal to use this software for testing in a trial period.
  A reasonable test period is estimated to be 30 days. Using the software
  beyond a reasonable trial period, or including it in a commercial
  program without a legal license, will be regarded as a violation of
  our copyright.

  An important part of the "shareware" concept is that the user must have
  a chance to test all parts of the software. If the software is only
  partly working, or deliberately causes erroneous results, it should not
  be called "shareware", but "crippleware". Some "shareware" software
  is also called "nagware" because of the annoying pop-ups constantly
  reminding the user about the lack of license. VBIT is using this
  approach, but you can still test all parts of it.


  VBIT can be distributed freely on the following conditions:

  - All files in this package must be included (see PACKING.LST).

  - The files must be unchanged.
    Archive file name must include version number (VBIT120.ZIP -> ver 1.20).
    The date and time of the files should not be changed.
    Time must correspond to the version number.

  - No files can be added to the package, with one exception: The BBS
    distributing this software may include a short text file with a
    short presentation of the BBS.

  - It is not allowed to charge any cost for the distribution of this
    software, except for normal downloading fees (if any), without the
    express permission from InfoTech AS.

  We encourage you to give copies of this software to your friends and
  colleagues, and to upload it to any BBS's that you use. For sample
  descriptions suitable for BBS file listings, please see FILE_ID.DIZ
  and DESC.SDI.

_____________________________________________________________________________

> COPYRIGHT / LIABILITY / CONDITIONS FOR USE


  !    VBIT  Copyright (C) 1995  InfoTech AS,  BERGEN, NORWAY               !
  !    Distributed by: Trader's Mascot AS, Aalesund, Norway                 !
  !    ________________________________________________________________     !
  !    Use this software  only  if you accept the following conditions:     !
  !    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""     !
  !    THE SOFTWARE  VBIT  AND  ACCOMPANYING  DOCUMENTATION IS PROVIDED     !
  !    AS IS WITHOUT WARRANTY OF ANY KIND. ALL USE IS AT YOUR OWN RISK.     !
  !    INFOTECH AS CAN NOT BE MADE LIABLE FOR ANY DAMAGES CAUSED BY USE		!
  !    OF THIS SOFTWARE AND DOCUMENTATION. OWNER OF A LEGAL LICENSE FOR		!
  !    VBIT  IS  COMMITTED  TO KEEP  THIS CODE  UNAVAILABLE FOR OTHERS.     !
  !    DELIBERATE DISTRIBUTION OF  A LICENSE CODE  WILL  BE REGARDED AS		!
  !    A SEVERE  VIOLATION OF THE LICENSE CONDITIONS AND A VIOLATION OF		!
  !    INFOTECH'S COPYRIGHT, AND WILL BE PROSECUTED.                        !                               !

_____________________________________________________________________________

> LICENSE-CODES / PRICE

  Contact InfoTech AS or Trader's Mascot AS to get a license code.
  Current prices are:

  In Norway:           NOK 495 incl. M.V.A.
  All other countries: US $ 65

  A valid license code gives you the right to distribute VBIT.DLL
  with your programs.


  ------------------------------
  * TIME LIMITED SPECIAL OFFER *
  ------------------------------
  If you pay for a VBIT license before april 30. 1995, you will
  also get the right to use and distribute VBITVTSS.DLL. This module
  contains the necessary routines for connecting VBIT to the
  spreadsheet product Formula One from Visual Tools. This product is
  exceptionally suitable for presentation of VBIT Tables, and also
  gives the possibility to import/export Excel (4.0) spreadsheets to
  the Tables via Formula One.

  In future versions, VBITVTSS will be sold as a separate add-on tool.

_____________________________________________________________________________

> ORDERING INFORMATION / PAYMENT:
  Price in Norway : NOK 495,- incl. mva.  all other countries : $65

  Send to:   Trader's Mascot AS
             Postboks 3098 Sentrum
             N-6001 AALESUBD, Norway

  ___________________________________________________________________________
  |                                                                         |
  |         The following information must accompany the payment:           |
  |         =====================================================           |
  |                                                                         |
  |     Name       _________________________________________________________|
  |                                                                         |
  |     Address    _________________________________________________________|
  |                                                                         |
  |     Postcode   _________________________________________________________|
  |                                                                         |
  |     City       _________________________________________________________|
  |                                                                         |
  |     Country    _________________________________________________________|
  |                                                                         |
  |     Date       ___________________________   Phone: ____________________|
  |                                                                         |
  |     Has paid   ___________ for VBIT license (see PRICE above):          |
  |          _                                                              |
  |         [_] Check / money order enclosed                                |
  |         [_] BankGiro: 5353.05.22667 (Den Norske Bank)                   |
  |         [_] PostGiro: 0826.06.97588 (Post cheque)                       |
  |                                                                         |
  |         [_] Visa        [_] American Express     [_] EuroCard           |
  |         [_] MasterCard  [_] Diners International                        |
  |                                                                         |
  |         Creditcard number  :_________________________________________   |
  |                                                                         |
  |         Expiration date    :_________________________________________   |
  |                                                                         |
  |         Signature          :_________________________________________   |
  |                                                                         |
  |     Want to receive the license code [_] via post.                      |
  |                                      [_] via Fax:    ___________________|
  |     VBIT version:      ________                                         |
  |                                                                         |
  |     Where did you find VBIT? _______________________________________    |
  |_________________________________________________________________________|

  Send above information to Trader's Mascot AS or by fax to
  Fax number +47 7012 4090

  If you pay directly to the bank account or international Post services,
  you may prefer to send the above information as E-mail via internet to:

  idb@vestnett.no  or nornes@oslonett.no

  We will send the code to you as soon as we have confirmed the payment.

  You may also call the Trader's Mascot BBS, running Excalibur BBS:
  +47/7012-9014 or +47/7012-5102.

____________________________________________________________________________

> FEEDBACK

  If you have comments, error reports, suggestions for improvements and
  extensions, please write to:

  InfoTech AS                                           idb@vestnett.no
  Strandgaten 207                                       ^^^^^^^^^^^^^^^
  N-5004 Bergen, Norway

or

  Trader's Mascot AS                                 nornes@oslonett.no
  Postboks 3098 Sentrum                              ^^^^^^^^^^^^^^^^^^
  N-6001 AALESUND, Norway
_____________________________________________________________________________
_______________________________END_OF_README_________________________________
