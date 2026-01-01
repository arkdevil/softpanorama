======================================================================
  Microsoft(R) Product Support Services Application Note (Text File)
          WX1050: MICROSOFT ACCESS DATABASE STRUCTURE WIZARD
======================================================================
                                                   Revision Date: 1/95
                                                                1 Disk

The following information applies to Microsoft Access, version 2.0.

 ---------------------------------------------------------------------
| INFORMATION PROVIDED IN THIS DOCUMENT AND ANY SOFTWARE THAT MAY     |
| ACCOMPANY THIS DOCUMENT (collectively referred to as an Application |
| Note) IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER      |
| EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED      |
| WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR       |
| PURPOSE. The user assumes the entire risk as to the accuracy and    |
| the use of this Application Note. This Application Note may be      |
| copied and distributed subject to the following conditions:  1) All |
| text must be copied without modification and all pages must be      |
| included;  2) If software is included, all files on the disk(s)     |
| must be copied without modification (the MS-DOS(R)  utility         |
| diskcopy is appropriate for this purpose);  3) All components of    |
| this Application Note must be distributed together;  and  4) This   |
| Application Note may not be distributed for profit.                 |
|                                                                     |
| Copyright (C) 1995 Microsoft Corporation.  All Rights Reserved.     |
| Microsoft, MS-DOS, and Windows are registered trademarks of         |
| Microsoft Corporation.                                              |
| CompuServe is a registered trademark of CompuServe, Inc.            |
 ---------------------------------------------------------------------
                                   
What Is the Microsoft Access Database Structure Wizard?
-------------------------------------------------------

The Database Structure Wizard is a tool to assist you in documenting
and troubleshooting Microsoft Access database applications. It
generates tables that detail the organization, structure, and settings
of your Microsoft Access database files.

The Database Structure Wizard is an updated and improved version of
the Database Analyzer utility included in Microsoft Access version
1.x. It features improved customization and flexibility and takes
advantage of many new features found in Microsoft Access version 2.0.

It is important to note that the Database Structure Wizard is not a
full-featured reporting tool; sample reports are provided only as
examples of how you might organize and present the data collected by
the Database Structure Wizard. The wizard's main function is to
provide you with raw data about your database files that you can use
to create custom reports.

What Is the Database Structure Wizard Support Policy?
-----------------------------------------------------

The Database Structure Wizard was created by a team of Support
Engineers from Microsoft Product Support Services and is provided as
an unsupported tool. Microsoft Product Support Services does not
provide support for this tool beyond installing it. If you have
questions about or problems with the Database Structure Wizard, you
are encouraged to post a message in the Microsoft Access forum on
CompuServe(R). (Type GO MSACCESS to reach the forum.) The Database
Structure Wizard team will review all comments and findings posted in
the forum.

How Do I Install the Database Structure Wizard?
-----------------------------------------------

Follow these steps to install the Database Structure Wizard:

1. Insert the WX1050 disk in the appropriate disk drive.

2. Start Microsoft Access and open any database.

3. From the File menu, choose Add-ins, then from the menu that
   appears, choose Add-in Manager.

4. In the Add-in Manager dialog box, choose the Add New button.

5. In the Drives box in the Add New Library dialog box, select the
   drive containing the WX1050 disk.

6. In the File Name box, select WZSTRUC2.MDA (the Database Structure
   Wizard file) and then choose the OK button.

7. Choose the Close button.

8. Quit and then restart Microsoft Access.

For more detailed information about installing and removing the
Database Structure Wizard, see the WZSTRUC2.HLP Help file included
with the Database Structure Wizard.

What Files Are Included with the Database Structure Wizard?
-----------------------------------------------------------

The Database Structure Wizard includes the following files:

   Filename       Purpose
   -----------------------------------------------------------------
   WZSTRUC2.MDA   The Database Structure Wizard code library
   WZSTRUC2.HLP   Complete online documentation for the wizard
   WZREADME.HLP   Installation instructions
   ACCERROR.HLP   A complete listing of Microsoft Access error codes
   NLYRPTS.MDB    Sample reports using data generated from the
                  NWIND.MDB sample database

Installation of the Help files is optional. If you install them, make
sure to copy them to the Microsoft Access directory along with the
WZSTRUC2.MDA file. You can delete the Help files later to save room on
your hard disk. If you delete the Help files, you will receive an
error message if you request help while you are using the Database
Structure Wizard.

The NLYRPTS.MDB file is a database file that contains sample reports
designed to work with an analysis of the NWIND.MDB sample database.
Installation of this file is optional. To work with the sample
reports, follow these steps:

1. Start Microsoft Access and open the sample database NWIND.MDB.

2. Run the Database Structure Wizard. Make sure to use the default
   settings and specify that you want the output written to the
   NLYRPTS.MDB file.

3. Close the NWIND.MDB database.

4. Open the NLYRPTS.MDB database.

5. Preview or print the sample reports.

                                   

