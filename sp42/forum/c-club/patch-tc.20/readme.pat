(BCPAT1) Patches to Borland C++ v2.0
====================================
To patch the Borland C++ integrated environment, run the batch files
    PATBC BC.EXE
    PATBCX BCX.OVY

* If you are in the Borland C++ bin directory, you may omit the path.
* If you supply a path, you must also state the name of the file to patch,
* for example:
      PATBC C:\BORLANDC\BIN\BC.EXE
      PATBCX C:\BORLANDC\BIN\BCX.OVY

These two patches correct the following problem:

[1]  Insert disk in drive A:
Intermittently, the a message was erroneously displayed prompting the
user to insert a disk in Drive A:.

Run Time Libraries
==================
To patch the Borland C++ Libraries:

    - Place the following files in the same directory as your run-time
    libraries (normally \BORLANDC\LIB).

            scroll.bat
            scroll.obc
            scroll.obh
            scroll.obl
            scroll.obm
            scroll.obs

    - Ensure that TLIB.EXE is in your path or place TLIB.EXE in the same
    directory as the above files.

    - Run scroll.bat

    - The above files will not automatically be deleted; however, once
    the patch has been successfully installed, they are no longer
    required and may be deleted.

This patch fixes a problem wherein printing to the CRT on the last line
of the display, causing the screen to scroll, would cause the last line
to be redisplayed.
