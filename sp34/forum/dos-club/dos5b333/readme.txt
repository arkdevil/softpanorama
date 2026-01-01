
MS-DOS 5.0 INFORMATION:
============================================================


UPPER MEMORY BLOCK (UMB) SUPPORT:

User's Notes:

DOS 5.0 can make use of Upper Memory Blocks in the region 
between 640Kb and 1Mb for loading device drivers, TSRs, and 
ordinary programs.  
 
UMB support begins with a UMB provider.  We have not 
supplied a UMB provider with this DOS beta, although we will 
in the final DOS 5.0 product.  You can use products such as 
386Max or QEMM as UMB providers, as long as the product 
supplies the XMS interface to allocate UMBs.
 
UMB support is activated via the DOS= line in CONFIG.SYS.  
This line has the syntax:
 
         DOS = [high|low],[umb|noumb]
 
If DOS=,UMB is not specified, UMB support is off by default.
 
When UMB support is active, DOS allocates all UMBs via XMS 
during system initialization.  It adds this memory to the 
standard DOS arena, making it available for device and 
program load.
 
To load a device driver high, use the command DEVICEHIGH in 
your CONFIG.SYS.  This has the syntax:
 
         DEVICEHIGH [size=xxxx] pathname
 
If there is not enough UMB space to fit the device driver, 
it will be loaded into low memory.  
 
Some device drivers grow themselves during initialization.  
In some cases this may exceed the available UMB space, and 
can cause an error or even a system crash.  For these cases, 
the SIZE= parameter is helpful.  You can obtain the size of 
the device when loaded low with the MEM /PROGRAM command.  
Use the size displayed there with SIZE=, and this will tell 
DOS how much space this device driver really needs.
 
To load a TSR or ordinary program high, use the LOADHIGH 
command from the DOS command line or from your AUTOEXEC.BAT.  
This has the syntax:
 
         LOADHIGH program
 
The LOADHIGH command has two effects: it loads the specified 
program into UMBs, if there is enough space; and it makes 
any unallocated program in the UMBs available to the program 
via DOS Alloc calls, while it is running.
 
Batch files cannot be specified for LOADHIGH, although the 
LOADHIGH command can be used within batch files.

Some devices and programs will simply be incompatible with 
loading high. Be prepared to do some experimentation.  Let 
us know what you find.
 
 
Programmers' Notes:
 
Programs can control whether they have access to the memory 
in UMBs via INT 21h Function 58h.  Ordinarily the UMB memory 
is not part of the standard DOS memory arena because many 
applications existing today don't function properly if they 
encounter available memory above 640Kb. If your program can 
handle this memory, and wishes to access it via DOS Alloc, 
you can add this to the available memory pool.
 
The subfunctions of function 58h are as follows:
 
 
 ENTRY   (al) = 0
           Get allocation Strategy in (ax)
 
         Used to obtain the current allocation strategy.  
         First Fit is the normal default.  High First is
         used to load programs into UMBs.
 
         (al) = 1, (bx) = method = z00000xy
           Set allocation strategy.
            z  = 1  => HIGH_FIRST
            xy = 00 => FIRST_FIT
               = 01 => BEST_FIT
               = 10 => LAST_FIT
 
         Sets the allocation strategy for subsequent allocs.
         
         (al) = 2
           Get UMB link state in (al)
 
         Indicates if UMB arenas are currently part of the 
         DOS arena.
 
         (al) = 3
           Set UMB link state
            (bx) = 0 => Unlink UMBs
            (bx) = 1 => Link UMBs
 
         Adds or removes UMBs from the DOS arena.  This 
         function returns an error if no UMB arenas exist.
 
 EXIT    'C' clear if OK
 
          if (al) = 0
            (ax) = existing method
          if (al) = 1
            Sets allocation strategy
          if (al) = 2
            (al) = 0 => UMBs not linked
            (al) = 1 => UMBs linked in
          if (al) = 3
            Links/Unlinks the UMBs into DOS chain
 
         'C' set if error
           AX = error_invalid_function
 
A program that changes the allocation strategy or the UMB 
link state should ALWAYS restore it to its original 
condition before exiting, or subsequent programs may fail.


MS-DOS 5.0 SETUP ON OS/2 DUAL BOOT SYSTEMS:

Installing MS-DOS 5.0 on an OS/2 dual boot system requires 
some special care.  If you are using OS/2 1.0 and 1.1 dual 
boot, you can install MS-DOS 5.0, and then re-install OS/2 
1.0 or 1.1 dual boot.  If you are using OS/2 1.2 dual boot, 
boot the system under DOS and run the MS-DOS 5.0 SETUP.


MANUALLY UNPACKING MS-DOS 5.0 FILES:

The files on the installation diskettes with file extensions 
which end with a _ are in a compressed format.  To retrieve 
a single file from the installation diskettes, use the 
EXPAND utility, located on the INSTALL 5 diskette.

    Usage:  EXPAND inFile outFile

    Where,
        InFile - is the pathname of the file on the 
                 installation diskette,
                 such as, a:\redir.ex_.

        OutFile- The name of the file to received the 
                 unpacked copy of InFile.
                 For example, c:\dos\redir.exe


PIPES USE OF TEMP ENVIRONMENT VARIABLE:

Dos 5.0 checks for the existence of the "TEMP" environment 
variable when creating temporary files for piping 
operations.  If such a variable exists, temporary files are 
created in the directory described in the variable.  
Otherwise, temporary files are created in the current 
working directory.  For example, the following command will 
cause all temporary files to be created in the directory 
c:\tempdir: SET TEMP=C:\TEMPDIR


DOSSHELL.EXE TASK SWITCHING:

The DOSSHELL task switcher does not support switching of 
programs performing asynchronous communications.  The 
DOSSHELL switcher should not be enabled if you are using any 
software that provides multitasking support for DOS.



SOFTWARE COMPATIBILITY NOTES:
============================================================


SOFTWARE THAT ACCESSES EXTENDED MEMORY:

Some software that uses extended memory, such as Paradox, 
Oracle, QEMM, or Turbo EMS, does so using interrupt 15.  In 
order to use this type of software with MS-DOS 5.0 loaded 
high, you can use the /INT15=xxxx switch on HIMEM.SYS.  The 
/INT15 option allows you to specify how much extended memory 
HIMEM.SYS should set aside for INT15 extended memory 
allocation interface.  It may also be necessary to use 
options on the particular software to tell it the amount of 
extended memory accessible through INT15.  This can be done 
using the /M switch with Turbo EMS, and the MEMORY option 
with QEMM.


DOS MULTITASKING SOFTWARE:

If using software that provides multitasking support for DOS 
do not enable the switcher in the DOSSHELL, as the 
multitasking system and the DOSSHELL task swapping are 
likely to conflict.


QUARTERDECK MANIFEST:

This application is closely tied to DOS internals specific 
to previous versions of DOS and does not work with MS-DOS 
5.0.


NETWORKS:

MS-DOS 5.0 supports DOS 4.xx compatible network redirectors.  
If you have trouble starting your particular network under 
MS-DOS 5.0, try using the SETVER command (described in the 
"MS-DOS Command Reference") to have MS-DOS 5.0 report DOS 
version 4.0 to your network software.  Network software that 
is explicitly designed to make use of extended / expanded 
memory (like Novell XMSNET4) may not work with MS-DOS 5.0.

NOTE: the MS-DOS 5.0 REDIR.EXE is supplied only for upgrade 
of MS-NET, MS LAN Manager basic services, and PCLP networks.

The following is a list of network software and special 
changes required for use under MS-DOS 5.0:

3Com 3+Share
    versions: 1.6 only
      - use 3Com DOS 4.x compatible redirector.
      - cannot be run as a server under MS-DOS 5.0.

3Com 3+Open
    versions: 1.0, 1.1
      - Follow the procedure for Microsoft LAN Manager
          listed below.

Artisoft LANtastic
    versions: 3.0
      - operates normally

Banyan VINES
    versions: below 4.0
      - May not work with MS-DOS 5.0
    versions: 4.0 and above
      - the current version.  Works with MS-DOS 5.0
          unaltered.
      - use REDIRALL.EXE without SETVER or REDIR4.EXE and 
          BAN.XXX, and SETVER for both to DOS 4.00.

DCA 10net
    versions: below 4.1
      - May not work with MS-DOS 5.0
    versions: 4.1 and above
      - SETVER 10NET.EXE to DOS 4.0
      - When used with MS-DOS 5.0 loaded high, the 10net
          software must be forced to load above the first
          64k in memory.  This can be accomplished by 
          loading large enough device drivers in CONFIG.SYS, 
          SMARTDRV or RAMDRIVE for example.


IBM PC LAN Program
    versions: 1.32
      - need to replace REDIRIFS.EXE with the MS-DOS 5.0
          REDIR.EXE.
      - replace DOS files (PRINT, MODE, etc) in PCLP 
          directory with MS-DOS 5.0 counterparts.
      - with server use SETVER on PSPRINT.EXE

Microsoft LAN Manager and 100% compatible networks
    versions: 1.0 and above
      - Changes necessary only if previously under DOS 3.xx
      - If the file NETWKSTA.EXE exists in your network
          directory rename NETWKSTA.400 to NETWKSTA.EXE and
          replace your old NETWKSTA.EXE.
      - If the file REDIR.EXE exists in your network
          directory replace it with the MS-DOS 5.0 REDIR.EXE


Novell NetWare
    versions: 2.0A or below
      - will not work with MS-DOS 5.0.
    version: 2.10 through 3.01
      - use NET4.EXE and SETVER NET4.EXE to DOS 4.0
      - EMS driver and XMS driver untested with MS-DOS 5.0

Ungermann-Bass Net/One
    versions:
      - Replace the file REDIR.EXE in your network directory
          with the MS-DOS 5.0 REDIR.EXE.

Ungermann-Bass Net/One LAN Manager
    versions:
      - follow the procedure for Microsoft LAN Manager 1.0

