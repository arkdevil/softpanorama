PlayRight
The Paradox Script Editor                         Release 1.1a-XP

* The Burgiss Group
* One Newark Street  #5B
* Hoboken, New Jersey 07030
* (201) 795-5144


This version of PlayRight is being distributed as shareware.
*******************************************************************
It may only be freely copied and distributed in its original form.
*******************************************************************
Shareware was born of a need to encourage the development and
distribution of high quality software by relying on the value
it provides.  If you find PlayRight XP of value and use it, we
ask you to register this copy with us for $29.95.

With registration, you become eligible to receive technical
support. Software support is time-consuming and we regret that
we can only support registered users.  If you experience a problem
with PlayRight XP that you suspect may be related to the copy
you received, please call and let us know.  We will be happy
to provide you a new copy.


-------------------------------------------------------------------
Copyright Notice

PlayRight XP- The Paradox Script Editor. Copyright 1987-1990
by The Burgiss Group. All Rights reserved. Software libraries,
electronic bulletin boards may be used to distribute PlayRight XP.
In the event that a fee is charged for this product by third-party
distribution, that fee, or the value of the fee, shall not be, or
be described to be in excess of $5.00.
-------------------------------------------------------------------
Disclaimer

PlayRight is designed to help you create, edit and document Paradox
scripts.  However, neither the Burgiss Group nor HardCopy Press
assumes any responsibility whatsoever for the uses made of this
software or for decisions based on its use. This software is licensed
as is, without warranty of any kind, either expressed or implied,
respecting the contents of this manual or accompanying software;
including, but not limited to implied warranties for their quality,
performance, or fitness for any particular purpose. Neither the
Burgiss Group, HardCopy Press, nor its dealers or distributors
shall be liable to the purchaser or any other person or entity with
respect to any liability, loss, or damage caused or alleged to be
caused directly or indirectly by these materials or use.


-------------------------------------------------------------------
The Burgiss Group also publishes PlayRight Pro, which extends
the command and feature set of PlayRight XP and PlayRight:

· Same Consistent, Simple Yet Powerful Paradox-Like Interface
· Faster File Operations
· Stream and Column Block Operations
· Context-sensitive Paradox (PAL) Help
    MakeHelp.EXE - To Add to your help file
    Copy from Help
· Paradox Table Structure & Family Information
· Expanded and Integrated Configuration
· PlayRight Macro Language
    Playable by Key or by Example Element
· Template Editing
· Collapse Mode
· Split Screen
· Paradox Screen Attribute Table
· More...

-------------------------------------------------------------------
**JUMPSTART
-------------------------------------------------------------------

Welcome to the PlayRight User's Guide. For those of you who plan
or need to read little else, here are a few survival tips for use
with PlayRight.

-------------------------------------------------------------------
SOFTWARE COPY SIGNATURE

Before you can run PlayRight (PR.COM) you must first assign
registration information (Name and Company) to PR.COM with PRCCP.

-------------------------------------------------------------------
CONFIGURATION

Once within PlayRight, press [F1] (Help) to view the default
keyboard configuration. PlayRight is initially configured to mimic
the Paradox working environment. Depending on your hardware and the
manner in which you've installed Paradox using the Paradox  Custom
Configuration Program (the "Custom" script), PlayRight's setup may
or may not match your Paradox configuration. Suggestion: try
PlayRight the way it is provided first. If you decide you don't
like the way it looks or behaves, use the PlayRight Custom
Configuration Program (PRCCP.COM) provided on the PlayRight disk
to change the default attributes to suit your needs.
File Handling.

When you choose {Edit} from PlayRight and the prompt "Script: "
appears, press [Enter] and a window containing the names of files
with the default extension (.sc = script) in the current
subdirectory will appear. "Point & Shoot" or press any key to set
up a wildcard search. Press Enter on the highlighted file to
retrieve it. You can type in the names of other directories (end
with a backslash) at this prompt. Only the files with the default
extension in the directory you specify will appear in the file
selection window.

You can also type in the name of the file directly or set up a
wildcard search. Whatever you type at this prompt will be able to
be called up the next time you are at this prompt with [Ctrl D]
(Ditto).  The default extension for all file handling is ".SC" but
you can set it to anything you want using PRCCP. In addition, you
can use any legitimate file specification, including full and
partial paths and wildcards to specify files.

PlayRight may be called up directly from the DOS prompt with either
a file name or with DOS wildcards. For some examples: PRXP * will
bring up the file selection window with a listing of the first 25
filenames in the current directory with the default extension. PRXP
*.BAK will bring up a listing in the current directory of ".BAK"
files.

-------------------------------------------------------------------
MULTI-FILE EDITING.

As with Paradox, an open file is an image of a file drawn from
disk. The first file loaded is the topmost image.  The next file
that is loaded becomes the current image and an indicator will
appear in the upper right-hand corner of the screen indicating that
an image exists above the present one. Use the familiar [F3]
(UpImage) and [F4] (DownImage) keys to move from one active file
to another. You can load and use as many files as memory allows.
[F10] [Go]. The ability to play the script you have just finished
editing within PlayRight within Paradox is essential to quick
debugging. If loaded with the special "ParadoxInvoked" command (PI)
on the PlayRight command line, PlayRight will allow you to play the
script you've just finished editing.

-------------------------------------------------------------------
BLOCK OPERATIONS.

If you attempt to use block operations without defining a block,
PlayRight will let you know with the message "No block has been
selected." You select a block with the [F7] (BeginBlock) and [F8]
(EndBlock) keys. In order to clear a block, press [F7], [Enter],
[F8] or any combination that sets the EndBlock before the
BeginBlock.

-------------------------------------------------------------------
SURVIVAL KEYS.

[F10] and [Esc] activate the menu while editing a script.
[Esc] also deactivates the main menu when active or moves
to the previous level. [CtrlBackspace] clears the current entry
from any prompt or any of the settings menus. [F2] is [Do-It!], the
function of which will change from menu to menu. [Tab] will move
the cursor to the beginning of the next word in the nearest line
above.

[Ctrl o] creates a DOS shell over PlayRight. The same restrictions
apply that apply to the use of any DOS shell (see the explanation
for the Paradox {ToDOS} command in the Paradox User's Guide). When
you want to return to PlayRight, type "Exit" at the prompt and
press [Enter].

-------------------------------------------------------------------
HARDWARE & SOFTWARE CONSIDERATIONS

Operating System. DOS 2.x users must have the directory in which
PlayRight resides on their active PATH. The installation procedure
will yield the message "Bad command or file name" if the directory
in which PR.COM resides is not the current directory or the
directory in which it resides is not on the PATH. Simply add
PlayRight's directory to your PATH prior to loading Paradox.
Hardware-- Default Display. The {ScreenColors} option in the
configuration program (PRCCP.COM), allows you to adjust monochrome
as well as color display attributes. If you have a Compaq
monochrome or a Hercules compatible display, you might want to
adjust display attributes with the configuration program
(PRCCP.COM).

----------------------------------------------------------------
TABLE OF CONTENTS

JumpStart
Copyright Notice
Introduction
PlayRight Features
Getting Started
     PlayRight User's Guide Conventions
     What To Do First
     Installing PlayRight As Your Paradox Editor
     Default Configuration
Editing Preliminaries
     The PlayRight Screen
The Keyboard
     Cursor Movement
     Miscellaneous
     FieldView
     Manipulating Text
     Function Keys
Command Reference
     Edit
     HardCopy
     Directory
Configuring PlayRight
     Starting PRCCP
     Configuring The Editor
     HardCopy
     ScreenColors
     Finishing the Configuration Program
Appendix

-------------------------------------------------------------------
INTRODUCTION

PlayRight was designed by a team of Paradox users who were awed
with the power of Paradox and the Paradox Application Language
(PAL) but accustomed to a more powerful program development
environment. PlayRight was designed with the functionality of a
state-of-the-art text editor and many features of the Paradox user
interface, combining the best of both worlds.
While writing, editing, and documenting Paradox scripts, a wish
list grew:

     Faster operation: cursor, disk I/O.
     Block Operations: Copy, Move, Indent, ShiftCase.
     Editing of multiple files simultaneously.
     Block operations between active files.
     Bells & whistles.

While developing PlayRight, we listened to and got advice from many
other Paradox users. Paradox users also wanted to maintain a smooth
interface with Paradox:

     Active within the Paradox "debugger."
     Paradox style menus.
     Function keys that corresponded closely to the function keys
     of Paradox.
     The ability to record and play keystrokes within a script.
     [F10] Go. Save and play the script.

-------------------------------------------------------------------
PLAYRIGHT FEATURES

  +  Full-featured Editor with powerful search & replace and memory
     macros. Familiar Paradox style menus with explanations for
     each choice.

  +  Active debug with Paradox Release 2.0 and Paradox 386.
     PlayRight snaps into Paradox with the "Custom" script and then
     [Ctrl E] works as you would expect --  jumps to the offending
     line number in the code of the currently executing script (or
     procedure).

  +  [F10] [Go] allows you to play the current script when Paradox
     is loaded.

  +  HardCopy  --  Background printing.  Queue up to 10 files for
     printing and keep editing.  Output is quickly and easily
     formatted with margins, optional line numbers, full path
     script name.  Printing can be canceled for any script in the
     queue without affecting others.

  +  Fast --  Written in Turbo Pascal and Assembler.

  +  Multi-File Editing--  Edit as many files as you wish
     simultaneously, limited only by memory. Use the familiar [F3]
     and [F4] keys for UpImage and DownImage. Move or Copy blocks
     of text between files.

  +  Transparent Paradox interface when invoked from within
     Paradox.

  +  Reconfigurable --  With the PlayRight Custom Configuration
     Program (PRCCP.COM), you can modify PlayRight's editing keys,
     screen colors and attributes, and default HardCopy Settings.

-------------------------------------------------------------------
GETTING STARTED

PlayRight User's Guide Conventions. This guide uses several
conventions to help you better use and understand PlayRight with
ease:

Keystrokes are enclosed in square brackets: [Enter], [F2], [Esc].
When two keys are to be used together they are represented thus:
[Alt F3].

PlayRight and Paradox menu choices are represented in curly braces:
{Block} {Align} {LeftAlign}

-------------------------------------------------------------------
WHAT TO DO FIRST

(1) Make a copy of the original PlayRight disk using the DOS
Diskcopy command. Put away the original PlayRight disk.

(2) Run PRCCP from the A> with the backup disk. Choose the file
"PR.COM" as the PlayRight file. Supply your name and company
information and choose {DO-IT!} from the PRCCP menu. A working copy
of PR.COM will be created on the disk.

(3) Using the backup PlayRight disk, copy PR.COM into the hard disk
subdirectory of your choice (for Paradox users, usually the
\PARADOX2 subdirectory).

(4) Copy PR.HLP into the C:\PARADOX3 directory. If you are not
using PlayRight with Paradox or if you want to specify a different
subdirectory, instructions on creating a new help file location are
explained in the section on custom configuration.

Installing PlayRight As Your Paradox Editor

Following are two examples of installing PlayRight as your editor
of choice for use with Paradox. With Paradox release 2.x, 3.x or
PDOX386, you first load Paradox and then play the Paradox "Custom"
script to designate PlayRight as your editor. In the second
example, you take advantage of the Paradox "SETKEY" command to have
Paradox run PlayRight with the press of a function key.

Release 2.xx or 3.xx. Use the Paradox Custom Configuration Program
(Custom.sc) to install PlayRight as your editor:
Copy PlayRight (PR.COM) into your \PARADOX2 subdirectory (or one
of your choosing). Play the Paradox "Custom" script and select
{More} {Pal} {Editor}.

Important Note: The command that you type in to automatically load
PlayRight from Paradox depends on the version of DOS you are using.
If you are using DOS 2.xx, you will have to make sure that the
directory in which PlayRight resides is on your DOS PATH.
The prompt line for the editor should be typed in as follows.

     DOS 2.xx          ! PRXP * ** PI
     DOS 3.xx          ! C:\PARADOX3\PRXP * ** PI

The directory you select for DOS 3.xx should be the directory into
which you copied PR.COM. Press [Enter], select {Return} and press
[Do-It!] to save the configuration. Choose {HardDisk} and Paradox
will return you to the DOS prompt. The next time you run Paradox,
PlayRight will appear whenever you create or edit a script. When
called from debug within Paradox using [Ctrl E], PlayRight will
load and jump to the offending line number of the current script.

Notes:

  +  The ! designates the Paradox DOSBIG command, which stores the
     current Paradox environment temporarily to disk. This part of
     the command is optional. Configuring Paradox to load PlayRight
     under DOSBIG will free up more memory, allowing you to edit
     more and/or larger files. With DOSBIG, Paradox swaps almost
     its entire environment out of memory to disk and this takes
     time both going out to PlayRight and coming back into Paradox.
     If your PC has a very fast hard disk or is equipped with
     expanded memory, you will experience only a slight delay while
     PlayRight loads. If you find that the delay is too long, you
     may want to experiment and install PlayRight without the
     exclamation point for faster loading and unloading. The only
     penalty is that you will be able to edit smaller or fewer
     scripts due to less available memory.

  +  The * passes the filename to PlayRight from Paradox.

  +  The ** is used when debugging and passes the script line
     number from Paradox to PlayRight.

  +  The parameter "PI" signals PlayRight that it has been invoked
     from within Paradox, enables you to use [F10] {Go}, and
     maintains visual continuity.

-------------------------------------------------------------------
Release 1.xx   Use PlayRight on a function key:

Example: Under DOS 3.xx, using [Shift F1], with PR.COM loaded in
the Paradox directory. Create the following script, and play it
when you want to "enable" the key to call up PlayRight:

           SETKEY  "F11"    RUN  "C:\\PARADOX\\PRXP   PI"

After playing this script, press [Shift F1] to have Paradox call
on PlayRight. You can also add the line above to the script
"INIT.SC" so that Paradox will load this key assignment for you
when you call up Paradox (see page 32 of the Release 1.xx Pal
User's Guide or pages 101-102 of the Release 2.xx guide).

-------------------------------------------------------------------
Default Configuration

PlayRight comes configured to closely resemble the Paradox
environment and you may not need to change its default settings.
However, there are a few good reasons to explore the configurable
options:

  +  If you are using PlayRight as a general editor and you are not
     using Paradox, you will want to run PRCCP to configure the
     location of the PlayRight help file. The default is
     C:\PARADOX2\PR.HLP.

  +  If you have a color monitor, PlayRight displays white letters
     on a blue background. To change these defaults, use the
     {ScreenColors} configuration of PRCCP. If you have a
     monochrome monitor, you can use {ScreenColors} to change
     monochrome screen attributes (intensity or reverse video).
     If you are used to a different editor, or are uncomfortable
     with the Paradox-like defaults, you may want to change
     PlayRight's key assignments (use {Editor} {Keys} in PRCCP).

  +  If you program in a language which uses a default editing
     width greater than or less than the PlayRight default 132
     characters, you will want to change {Editor} {Width}.

-------------------------------------------------------------------
Default Settings

  +  PlayRight in its default configuration:

  +  Always starts out in the "Insert" mode.

  +  Finds words independent of case.

  +  Automatically creates backup files upon saving with the same
     filename and extension (default = .BAK).

  +  Uses a blinking cursor.

  +  Uses the Paradox default extension of ".SC" for all file
     handling operations.

  +  Has a default width of 132 characters.

  +  Scrolls the screen 10 lines with the [PgUp] and [PgDn] keys.

If you use the Paradox script editor, you will be at home in the
PlayRight editing environment.


-------------------------------------------------------------------
Editing Preliminaries

Although particularly geared for use with Paradox, PlayRight is
well suited for other programming languages as well (we used
PlayRight to help create PlayRight, which is programmed in Pascal
and Assembler), providing auto-indenting of code, line numbering
when printing, and many line-oriented features which make
programming easier.

When loaded by PlayRight, a file is assigned available conventional
RAM. The more RAM available, the greater the number and/or size of
the files that can be edited simultaneously. The amount of RAM
available is usually dependent on three conditions:

How much conventional memory your PC has.

Whether or not PlayRight is loaded within Paradox (and which
release of Paradox you are using).

The memory requirements of your operating system and any RAM
resident programs.

With Paradox Release 1.xx, the amount of memory available when
using the "Run" command will vary greatly with the number of
Paradox images on the workspace, whether or not a table is being
edited, the status of procedures, etc.   Memory management was
greatly improved with Paradox Release 2.0 (using Menu {Tools}
{More} {ToDOS} leaves a 640K PC with approximately 200K of memory
available). Invoking the Release 2.0 or 3.0 DOSBIG [Alt o] command
on a 640K machine frees 500K prior to loading PlayRight.

-------------------------------------------------------------------
PlayRight Files are Memory Images

When you edit an existing file with PlayRight, you are editing an
image of the file, not the file itself. When you are through
editing, you have the opportunity to save the file under its
present name (just hit [F2]), save it under a different name ([F10]
{Save} {New}), or cancel any changes you may have made. If you make
changes to a file and select {Cancel}, PlayRight will ask for
confirmation with {Yes} {No}.

Since all files are held in memory, a newly created file does not
"exist" on disk until you save it. If a file is currently being
printed, it cannot be edited or put into the print queue.

-------------------------------------------------------------------
File Handling

The default extension for all file operations is ".SC." If you do
not specify a file name extension, ".SC" is assumed. When working
with file extensions other than the default, reassign a DOS
wildcard pattern at the "Script: " prompt to set up a new default.
For example, to set the pattern for backup files, you might type
in "*.BAK" at this command line. If you routinely work with a
different filename extension, use PRCCP to configure a new default
(use {Editor} {Ext.}). If you wish to create or edit a file without
an extension, end the filename with a period.

When faced with the prompt "Script: " you can:

Press [Enter] to get a list of scripts in the current directory.
Bring back previously typed entres with [Ctrl D].
Edit your current entry with FieldView [Ctrl F].

In order to view the current files in the default directory with
the file specification *.SC when prompted "Script:   ", press
[Enter] and a window with the names of the scripts appears. If more
than 25 scripts are in the current directory, press [PgDn] to view
the next set of 25 files.

     [Home]     First file on screen.
     [End]     Last file on screen.
     [PgDn]     Next set of 25 or less files.
     [PgUp]     Previous set of 25 files.

Secondary Wildcard Matching.

While the file selection window is active, a secondary wildcard
search based on the first character of scripts is initiated. Unlike
Paradox, PlayRight's search is continuous, allowing you to browse
through a directory's scripts by tapping single characters. Files
that match the single character searches will be displayed
successively in the window. PlayRight will beep if no matches are
found. When you have thus narrowed your search for a file,
highlight your choice and press [Enter].

-------------------------------------------------------------------
The PlayRight Editing Screen

The main PlayRight editing screen displays the full path and
filename of the current script; the current line number, an Image
Indicator (if more than one image is on the workspace) and a ruler
line with column indicator. When scrolling, the upper two lines and
the lower two lines of the screen are always revealed, allowing the
display of what's to come and what's behind without having to
scroll the screen manually.

     The cursor is selectable: non-blinking or DOS.
     The current line is highlighted.
     132 columns (default width).
     A double line signifies end of text.

-------------------------------------------------------------------
The Keyboard

Cursor Movement (*Denotes reconfigurable with PRCCP.COM)
     [PgDn]*          Smoothly scroll down 10 lines.
     [PgUp]*          Smoothly scroll up 10 lines.
     [CtrlPgDn]*     Page jump down 20 lines.
     [CtrlPgUp]*     Page jump up 20 lines.
     [Right]          Right one character.
     [Left]          Left one character.
     [Ctrl Right*     Right one word.
     [Ctrl Left]*     Left one word.
     [Up]               Up one line.
     [Down]          Down one line.
     [End]*          End of file.
     [Home]*          Beginning of file.
     [CtrlEnd]*     End of line.
     [CtrlHome]*     Beginning of line.
     [Tab]          Cursor to character following space in any text
                    above. In insert mode, push text along with it.
     [Enter]          End current line.
                    In insert mode, break line.     In overtype mode,
                    same as [Down] [CtrlHome].
[Backspace]          Delete character left. Join lines in either
                    insert or overwrite.
[CtrlBackspace]*     Delete word left.
                    Join lines.
-------------------------------------------------------------------
Miscellaneous

     [Alt+Keypad]      ASCII character set.
     [Ctrl Z]          Initiate a find/replace.
     [Alt Z]*          Repeat last find/replace.
     [Ins]             Toggle Insert/Overwrite mode.
     [Ctrl o]          DOS shell.
     [Alt -]*          Move selected block one character left.
     [Alt =]*          Move selected block one character right.

FieldView      (Used in File Selection & Settings Windows)
     [Ctrl F]          Begin & end FieldView.
     [Home]            First character.
     [End]             Last character.
     [Ins]             Toggle Insert mode.
     [Right]           Right one character.
     [Left]            Left one character.
     [Ctrl Right]*     Right one word.
     [Ctrl Left]*      Left one word.
     [Del]             Delete character at cursor.
     [Backspace]       Delete character to left of cursor.
[Ctrl Backspace]       Delete entire entry.
     [Ctrl D]          Repeat previous entry.
     [Enter]           End FieldView     .

-------------------------------------------------------------------
Manipulating Text

     [Del]             Delete character at cursor.
     [Ctrl G]          Delete character at cursor.
     [Backspace]       Delete character left.
     [CtrlBackspace]*  Delete word left.
     [Ctrl T]*         Delete word right.
     [Ctrl Y]*         Hack line at cursor.
                       At left margin, delete line.
     [Alt Y]*          Delete line.
     [Ctrl W]*         Scroll screen down.
     [Ctrl E]*         Scroll screen up.
     [Ctrl C]*         Center current text line within 80 columns.
     [Ctrl D]*         Ditto: Repeat line above character by
                       character.
     [Alt D]*          DittoLine: repeat entire line above cursor.
     [Ctrl K]*         Change case (upper, lower, InitCaps).
     [Ctrl U]*         Undo line change (before moving cursor
                       off line).
[Ctrl J/[Enter]*       Add line below current line.


-------------------------------------------------------------------
Function Keys

     [F1]              Help
     [F2]              Do-It!
     [F3]              UpImage
     [F4]              DownImage
     [F6]              Checkmark (Field Toggle)
     [F7]*             BeginBlock
     [F8]*             EndBlock
     [F10]             Menu
     [Alt F3]          Begin/End Record (Record Macro)
     [Alt F4]          InstantPlay (Play Macro)

The Function Keys

     [F1] is Help. Pressing [F1] brings up a screen which shows the
     current editing key configurations.

     [F2] is the Do-It! key and it can be used to immediately save
     the current image (even with no menu present). If multiple
     images are loaded, pressing [F2] repeatedly will save one
     image after another. [F2] also serves as a secondary key
     choice for {Save}. In addition, [F2] controls whether the
     actions you take in the {Find} and {HardCopy} menus are
     carried out.

     [F3] is UpImage. [F4] is DownImage. When two or more files are
     loaded into PlayRight, an Image Indicator will appear in the
     upper right hand corner of the screen. This indicator will
     "point" up to an image above the current image, down to an
     image below the current image, or to files both above and
     below the current image. The first file loaded is the topmost
     image. If you press UpImage at the topmost image, or attempt
     to move below the last image with DownImage, the PC will beep.

     [F6] is called Checkmark, [√] and is used as a field toggle.
     Whenever a settings window contains a checkmark it can be
     toggled on or off with [F6].

     In their default key assignments, [F7]  is BeginBlock and [F8]
     is EndBlock. Blocks are line-oriented. If you wish to select
     a block of text, move the cursor to the first line, press [F7]
     and move the cursor to the last line and press [F8]. If you
     wish to select only a single line, move the cursor to the line
     and press [F7] and then [F8].  To extend the block to include
     more above or below, move the cursor and press [F7] above the
     block or [F8] below the block. To clear the block, press [F7],
     [Up], [F8]. These are the only two default function key
     assignments that are reconfigurable.

     [F10] is Menu. [Esc] clears the menu. When the main menu is
     not active, the next press of [Esc] reactivates the menu. This
     improves the accessibility of the Menu function in keyboards
     that position the [F10] key remotely. The key combination
     "Ctrl [" also is interpreted as [Esc] and so brings up the
     menu as well.

-------------------------------------------------------------------
Macros

The macro function within PlayRight XP is simple and powerful. [Alt
F3] (Begin/EndRecord) is used to both begin and end the macro. [Alt
F4] (InstantPlay) is used to play the current macro. A macro is
memory resident while in PlayRight and only one can exist at a
time.  When [Alt F3] is pressed, the message "Beginning
recording..." appears at the lower right of the screen. PlayRight
will record your keystrokes (to a maximum of 500) until you press
[Alt F3] again (the message "Ending recording..." will appear).
When you wish to play the macro, press [Alt F4].

Macros can come in handy when using repetitive keystrokes in an
editing session. For example, you can use a simple macro to help
with the drawing of ASCII graphics characters:

     Press:      [Alt F3]     (BeginRecord)
     Hold:       [Alt]
     and Type:   196          (On the numeric keypad)
     Release:    [Alt]
     Press:      [Alt F3]     (EndRecord)

Now simply use [Alt F4] to repeatedly draw that character wherever
you need it.

Survival Tips: Use the {Save} {Update} feature on your text prior
to playing your macro in case things go amiss. A macro will
duplicate your keystrokes, not record your menu choices. If you use
menus in your macros, be sure to use the first letter of the
command choice in order to ensure proper execution. If you exceed
the limit of 500 keystrokes, PlayRight will force you to press
[Esc] to acknowledge that macro recording has been halted. The
macro will be playable up to that point.

-------------------------------------------------------------------
Command Reference
-------------------------------------------------------------------

Below is the PlayRight menu tree, a quick listing of the available
menu choices and their organization. While editing a script,
pressing the Menu key [F10] brings up the PlayRight main edit menu.
[Esc] toggles in and out of the main menu and, with few exceptions,
backs you out of the current menu choice.

Edit {Read} {Block} {Find} {Line} {Save} {Image} {Go} {Cancel}

-------------------------------------------------------------------
Edit

{Edit} brings the selected file onto the workspace and into memory.
If the file does not already exist, {Edit} will create it (this
substitutes for Paradox's {Scripts}{Editor}{Write}).

-------------------------------------------------------------------
Read

{Read} copies the contents of an entire file into the present image
below the cursor. The new text is highlighted as a block and
immediately can be manipulated with any block function.

-------------------------------------------------------------------
Block

{Copy} {Move} {Erase} {Write} {Print} {Shift} {Align} {Quit}

Block operations work on selected blocks of text. You select blocks
with [F7] (BeginBlock) and [F8] (EndBlock). The minimum amount of
selected text is one line, and the maximum is an entire file.

One block can exist at any time. No matter how many images are on
the workspace, only one image can contain a selected block. The
block operations {Move} and {Copy} will work between images. The
remaining block operations --  {Erase}, {Write}, {Print}, {Shift},
and {Align}--  work on a block in the current image only.

-------------------------------------------------------------------
Block Selection

Position the cursor on the first line you want included in the
block.
     Press: [F7]      BeginBlock
                      Move the cursor to the last line you want
                      included in the block.
     Press: [F8]      EndBlock
                       The block will be selected in inverse video (or
                       in a different color).
Note: if you want to select only one line, press [F7] followed by
[F8].

-------------------------------------------------------------------
Changing and Clearing Block Selection

The selected block size can be changed by moving the cursor to a
different line and pressing [F7] or [F8].

Clearing. If you position the cursor above the selected block and
press [F8], the block will be cleared. Likewise, if you move below
the selected block and press [F7], the block will also clear. To
clear the block in the current image, press in succession: [F7],
[Up], [F8].

Changing. To decrease the size of the current block, locate the
cursor within the block and press [F7] or [F8]. To increase the
size of the current block, position the cursor above the block and
press [F7] or below the block and press [F8].

-------------------------------------------------------------------
Copy

{Copy} copies the selected block to a new block beginning one line
below the current cursor line. Blocks may be copied between active
images. The new copy of the block becomes the selected block. With
the default keyboard configuration, [Alt c] will copy a selected
block below the cursor. This short-cut key assignment is
reconfigurable with PRCCP.

-------------------------------------------------------------------
Move

{Move} repositions the selected block beginning on the line below
the current cursor line. Blocks may be moved between active images.
The block remains selected. With the default keyboard
configuration, [Alt m] will move the selected block. This short-cut
key assignment is reconfigurable with PRCCP.

-------------------------------------------------------------------
Erase

{Erase} deletes the current block from the workspace. {Erase} also
cancels all block designations.

-------------------------------------------------------------------
Write

{Write} prompts you for a file name and creates a new file with the
selected block. If the file already exists, PlayRight prompts you
with a {Cancel}/{Replace} option. Choose {Cancel} if you do not
want to overwrite the existing file. Full file specifications are
supported. The file may be written to another drive or directory.
If a filename extension is not supplied, the default extension
".SC" is assigned. If you wish to assign a filename without an
extension, use up to the eight character filename and follow it
with a period (i.e. the filename "JUNK" will result in the script
"JUNK.SC" whereas the filename "JUNK." will result in "JUNK"). The
block remains selected.

-------------------------------------------------------------------
Print

The {Print} command prints the current block using the current
print settings. The block remains selected and the file can
continue to be edited. {Print} creates a temporary file called
PRBLOCK.TXT which is queued for background printing. If you want
to print the current file and continue to work on it, identify the
entire file as a block, and use the {Block} {Print} function.

-------------------------------------------------------------------
Shift

{UpperCase} {LowerCase} {InitCaps}
     {Shift}    converts all letters in the block to:
     {UpperCase}      UPPER CASE
     {LowerCase}      lower case
     {InitCaps}       Initial Capital Letters ("Proper" case)

-------------------------------------------------------------------
Align

{Indent} {LeftAlign} {Center80}
     {Align} is a powerful command which repositions selected text
     by indenting, left-aligning to a column, or centering. While
     aligning text, if text encounters either margin, the text will
     be pushed up against that margin. A block may be moved one
     character to the left with [Alt -] and one character to the
     right with [Alt =]. These shortcut key assignments are
     reconfigurable with PRCCP.

To center text around a column, first center it using {Block}
{Align} {Center80}. Once centered, the block can be repositioned
left or right of the 80 column center position using {Block}
{Align} {Indent}.

Although instantaneous in most moderate-sized blocks, the larger
the block, the longer block alignment will take.

-------------------------------------------------------------------
Find

PlayRight's {Find} function allows you to enter a character string
of up to 36 characters and perform a search or search/replace for
the string's occurrence. When you choose {Find}, a window will open
which allows you great flexibility in dictating the specifics of
the find. {Find} works from the current cursor position forward.
With the default key configuration, [Ctrl z] (Zoom) also brings up
the {Find} window. [Alt z] (ZoomNext) repeats the last find. These
two shortcut keys are reconfigurable.

Options. By using the [F6] key you can toggle on or off options
which determine whether PlayRight will ignore case sensitivity in
the search or search for whole words only: Ignore Case; Global;
Confirm; Whole words only.

-------------------------------------------------------------------
Find & Replace.
If you enter a replacement string, you can toggle on a Global
forward replacement option and replace all occurrences.
The Confirm option only works when the Global option is enabled.
With Global and Confirm enabled, PlayRight will stop at each
occurrence of the find string, and a window will open which prompts
you with "Replace? (Y/N/Q)."

Counting Occurrences. If you enter a find string, leave the replace
string blank and check off the "Global" option, you'll get a count
of the number of times the string is found.

-------------------------------------------------------------------
Line

{Line} jumps to a line number in the current script.  If the
requested line number is outside the range of actual script lines,
a message will appear asking you to choose a value between the
starting and ending line number.  PlayRight will position the
screen so that the requested line number is the third line from the
ruler line.

-------------------------------------------------------------------
Save
{Save}  {Update}  {New}

PlayRight's {Save} function offers you the flexibility of saving
the current image:

     {Save} Under the current name and exit. (The same effect is
     achieved by pressing [F2].)

     {Update} Under the current name without exiting.

     {New} Under a new name while remaining in the current file.
      The current file name remains the old file name.

-------------------------------------------------------------------
Image

{Image} enables you to load an additional file into memory for
editing.  When two or more files are loaded, an image indicator
will appear in the upper right corner of the screen "pointing"
above, below, or above and below. You can load as many images as
memory allows. You move between images with the [F3] (UpImage) and
[F4] (DownImage) keys.

-------------------------------------------------------------------
Go

{Go} allows you to leave PlayRight, return to Paradox, and play the
script you are editing. PlayRight first saves the script, exits,
and then instructs Paradox to play the script. Several conditions
apply:

{Go} will not work if Paradox isn't loaded.

Only one image (file) can be on the workspace. All others must be
cancelled or saved.

-------------------------------------------------------------------
Cancel
{No} {Yes}

{Cancel} enables you to cancel all changes made to the script.
Confirmation is required by selecting {Yes} only if the current
file (image) has been changed. If the current image is the only
image, PlayRight will return you to the main PlayRight menu.
Otherwise, PlayRight will make the next image the current image.

-------------------------------------------------------------------
HardCopy
-------------------------------------------------------------------
{Filename} {Align} {LineFeed} {PageEject} {Settings} {Cancel} {Quit}

The PlayRight Editor helps you create readable code. Printing
scripts is always revealing. HardCopy provides you with the ability
to print scripts according to specifications that you set and keep
on editing. This background printing mode allows up to 10 files to
be queued at a time. With {Cancel}, you have the freedom to release
the printing of any file from the queue.

Filename Any text file can be printed with HardCopy. Files are
printed according to the settings on the HardCopy {Settings} menu.
The current settings govern all files being printed. If you change
settings in the middle of printing, you will affect the current
output. Files in the print queue cannot be edited or added into the
queue.

-------------------------------------------------------------------
Align

{Align} sends a signal which identifies the current page position
as being at the top of form.

-------------------------------------------------------------------
LineFeed

{LineFeed} sends a linefeed to the printer.

-------------------------------------------------------------------
PageEject
{PageEject} ejects the current page from the printer.

-------------------------------------------------------------------
Settings -- {Margins} {PageLength} {Options} {PortType}
{PortNumber}

{Settings} allows you to change the current printer settings to
suit your needs.

Setup strings follow the conventions of preceding a three-digit
ASCII number with a backslash; all other characters are interpreted
as literal. For example, compressed printing on a LaserJet Series
II is: \027&k2S.

Survival Tip: The number of lines at the bottom of the printed page
is the page length minus the bottom setting. The default is four
lines (66-62=4).

The following HardCopy options can be toggled on or off with [F6],
the Checkmark:

Default Header: is on and consists of the date (left-justified),
the script name including full path (centered) and the page number
(right-justified).

Line Numbers: consecutively line numbers printed scripts. Default
is On.

Eighth Bit: If your printer can print the full ASCII character set,
leave this field checkmarked. If your printer has fits with some
of the control characters in your scripts, press [F6] to clear the
Checkmark, turn your printer off and on and print the script again.
PlayRight will then strip out the eighth bit of a character when
printing and so will print high-order ASCII characters according
to the standard 128 character ASCII set.

All of these defaults can be reconfigured with PRCCP.

-------------------------------------------------------------------
Cancel

The {Cancel} menu choice temporarily suspends printing and enables
you to alter the status of the files currently in the print queue.
{Cancel} is accessible only when files are being printed (a message
will let you know if there are no files in the queue). When you
invoke {Cancel}, printing will be suspended immediately (your
printer may continue printing until it's buffer is empty).

The Cancel Print window shows the files currently in the queue. If
you want to delete any files from the queue, point to the file's
Checkmark and press [F6] to toggle it off. When you press [F2] to
resume printing, any filenames without Checkmarks are canceled. If
you decide to continue printing despite changes you may have made
to the queue, simply press [Esc].

If you attempt to leave PlayRight with files in the print queue,
you will be prompted to confirm with a {No}{Yes} menu.

-------------------------------------------------------------------
Directory

The directory command on the main menu allows you to specify the
default directory. A trailing backslash is permitted (but ignored
by PlayRight) when specifying directories. When you leave
PlayRight, you will be returned to the directory from which
PlayRight was invoked.

*******************************************************************
Configuring PlayRight
*******************************************************************

PlayRight can be configured to suit your editing style,
configuration, and whims.

The PlayRight Custom Configuration Program (PRCCP.COM) enables you
to configure PlayRight to suit your programming habits, and
perhaps, adjust to new ones. PRCCP rewrites your PlayRight command
file "PR.COM" to your specifications. PRCCP allows you to configure
three major areas, the Editor, HardCopy, and Screen Colors.

-------------------------------------------------------------------
Starting PRCCP

Copy PRCCP.COM from the PlayRight distribution disk to the
subdirectory containing PlayRight (PR.COM).

Make the directory containing PR.COM and PRCCP.COM the current
directory. At the prompt,

Type:           PRCCP
and Press:     [Enter]

PRCCP will prompt you for a PlayRight file name (usually PR.COM,
but possibly one of your renaming). To view the *.COM files in the
current directory, press [Enter]. Only valid PlayRight files will
be accepted by PRCCP.

If this is the first time you have configured this copy of the file
PR.COM, you will prompted for your name and your company's name.
This information is recorded and entered into the {Info} selection
of the main PlayRight menu.

Once you have entered a PlayRight file and PRCCP has accepted it,
you will be faced with the PRCCP main menu:

-------------------------------------------------------------------
{Editor} {HardCopy} {Color} {Quit}

Configuring the Editor

The choices under {Editor} are described below:
  {Keys}
  {Cursor}
  {TypingMode}
  {Find}
  {Indent}
  {Backup}
  {Paging}
  {Ext.}
  {Width}

-------------------------------------------------------------------
Keys

When you choose {Keys} the Key Assignment Window opens and the
current key assignments are displayed. This window is the basis for
the help file (PR.HLP). If you change any of the key assignments
and press [F2] from this window, you will be asked to designate the
name and destination of the help file when you complete the
configuration program (the default is C:\PARADOX2\HELP.PR; you may
want to add a drive specifier).

In order to reassign these keys when viewing this window, a new set
of rules takes effect. When you press [F1], the next key or key
combination you press will substitute for the current choice. If
the key or key combination is not allowed, you will get the message
"Unassignable key."

You can move throughout the table and adjust any of the key
assignments shown in like manner. When you are finished, either
press [F2] to have PRCCP record your changes, or [Esc] to cancel
them. Several other rules apply. Two functions cannot be assigned
the same key. Most of the normal alphanumeric keys cannot be
assigned without an [Alt] or [Ctrl] key combination.

Cursor The cursor choices are either the standard DOS cursor
(blinking underline) or an inverse video, non-blinking block. The
PlayRight default is {DOS}.

-------------------------------------------------------------------
TypingMode

PlayRight is configured to start off every editing session in the
"Insert" mode.  By contrast, the Paradox editor starts out in the
"Overwrite" mode.

-------------------------------------------------------------------
Find

The {Find} configuration resembles the window used for the
{Find} function.  Here you can toggle the current options to suit
your needs. Ignore Case finds and replaces words independent of
case. The Global toggle will find and count occurrences of the Find
string, or when replacing, will find and replace the string from
the current cursor position forward. The Confirm option only works
when you are replacing the string and the Global toggle is enabled.
Whole Words Only looks for the string between valid delimiters.

-------------------------------------------------------------------
Indent

When on, {Indent} will send the cursor to a position one line under
the leftmost character of the current line when [Enter] is pressed.
This aids in constructing properly indented code "on the fly." The
default is {IndentOn}.

-------------------------------------------------------------------
Backup

PlayRight helps you prevent catastrophic changes to code by
automatically backing up a previously created script when saving.
The backup files will have the same filename with an extension of
.BAK. The default is {BackupOn}.

-------------------------------------------------------------------
Paging

"Paging" is the number of lines the screen will scroll when the
default keys [PgDn] or [PgUp] are pressed. The default is 10 lines.

-------------------------------------------------------------------
Ext.

The default extension (required by Paradox) is ".SC". You can set
it to any legitimate DOS extension. Wildcards are not permitted.

-------------------------------------------------------------------
Width

The maximum editing width permitted by Paradox for Paradox scripts
is 132 characters. The editing width within PlayRight has a range
of 1 to 255 characters.

-------------------------------------------------------------------
HardCopy
-------------------------------------------------------------------

The settings menu of HardCopy contains default configurations for
margins, page length, a setup string, line numbers, default
headers, eighth bit control, port type and port number. If you
normally print your scripts in compressed mode, set the defaults
to correspond to your printer's characteristics in this
configuration file so that you won't have to change the settings
each time you print. See the section on HardCopy for more detailed
information on these topics.

-------------------------------------------------------------------
ScreenColors
-------------------------------------------------------------------

With {ScreenColors}, you can set the colors of
PlayRight to suit your monitor's attributes or perhaps, your fancy.
You select six colors from a chart of numbers that depict both a
foreground color (or attribute) and a background color (or
attribute):

     Background (the borders and menu background)

     Menus (the highlighted choice and the letter colors)

     Text (all text but the current line)

     Cursor (which includes the column indicator)

     LineAtCursor (where the cursor resides)

     SelectedText (any block).

As you select the colors, the model of the PlayRight editing screen
will show the effect of your choices. When you are satisfied with
the display attributes, press [Do-It!].

-------------------------------------------------------------------
Finishing the Configuration Program
-------------------------------------------------------------------

When you have completed the changes to PlayRight using PRCCP,
choose {DO-IT!} and you will be prompted for one or two file names.

If you have changed the configuration of the key assignments using
{Editor} {Keys}, you will be prompted for a full file specification
for the help file. The default is C:\PARADOX2\PR.HLP. Be sure to
include a drive specifier if you intend to use PlayRight across
different drives.

You will always be prompted for a PlayRight filename. Name it (or
accept the default) and press [Enter]. If you leave the filename
extension off, PRCCP will attach ".COM" to complete its designation
as a command file.

If you decide to cancel the configuration program, you will be
prompted for confirmation.

-------------------------------------------------------------------
Appendix
-------------------------------------------------------------------

Distribution Diskette Contents

PR.COM     PlayRight Editor
PRCCP.COM     The PlayRight Custom Configuration Program.
README.SC     Last minute changes to PlayRight.

Access to PlayRight's Main Menu

With release 2.0 of Paradox, we have found it convenient to install
PlayRight as the main editor (using Paradox's "Custom" script) and
with the Setkey command. In this manner, you have direct access to
the main menu of PlayRight and its {Directory} and {HardCopy}
choices (via Setkey) and the advantages of active debugging.

-------------------------------------------------------------------
Notes on [F10] {Go}

PlayRight will only recognize that it has been loaded from within
Paradox if the "PI" parameter is on the command line. If PlayRight
is installed as your Paradox release 2.0 editor, the manner in
which PlayRight tells Paradox to play the script will vary:

     If the script you play from within PlayRight was passed to
     PlayRight from Paradox (e.g. from [Ctrl E] while debugging a
     script or from {Scripts} {Editor} {Edit}), the script plays
     exactly as it would from the Paradox script editor.

     If the script you play from within PlayRight was not passed
     to PlayRight from Paradox (e.g. you loaded a second script
     from within PlayRight using the PlayRight {Image} command, or
     you invoked PlayRight using a Paradox "Setkey" command),
     PlayRight will play the current script with assistance from
     a script called "PRGO.SC." If you are using PlayRight with
     Paradox release 1.xx, the script "PRGO.SC" is created and
     played whenever you use [F10] Go.

-------------------------------------------------------------------
PlayRight Error Messages

"Not enough memory to load entire file, tap [Esc]."
PlayRight will attempt to load any size file. If the file size
exceeds the amount of memory available, PlayRight will load as much
of the file as possible.

"Not enough memory to copy all of text, tap [Esc]"
The block copy you are attempting would result in an incomplete
copy. Possible solution: use the {Block} {Write} command to write
the block out to a file, cancel any images not currently actively
used, and {Read} the newly created file back in.

"Line would be longer than 132* characters, tap [Esc]."
You have attempted to join two lines whose total length exceeds the
editing width. Break up the second line prior to attempting to join
the lines again.

"Macro buffer full, recording halted."
The maximum number of keystrokes for a PlayRight Macro is 500. Once
you've reached that limit, PlayRight will automatically stop
recording your keystrokes. The macro will be playable up to that
point.

"Not enough memory for DOS shell"
The total RAM available is insufficient for the {ToDOS} function.
If there are several images on the workspace, save or cancel those
not presently in use. This should gain more memory.

"Files in print queue, tap [Esc]."
You have attempted to exit PlayRight with files in the print queue.
When you press [Esc], you will be faced with a {No} {Yes} menu
which allows you to complete or cancel your exit.

"Disk full or disk error"
You have attempted to save or write to a disk which is not ready
or which is full. Replace the disk or use [Ctrl o] to shell out to
DOS to delete any unused or backup files.

"Only .SC files can be played."
You have attempted to use [F1] {Go} with a file with an extension
other than ".SC". Rename the file and play it again.

Miscellaneous Error Messages

"Not a Valid PlayRight 1.1a File"
The file that you are attempting to configure with PRCCP does not
match the normal file attributes of the supplied file PR.COM. Use
the backup copy you created when you installed PlayRight to
configure a new copy of PR.COM.

"Not enough memory to load program"
This DOS message will occur if you attempt to load PlayRight in a
DOS environment that has less than about 100K. Unload other memory
resident programs prior to invoking PlayRight.

-------------------------------------------------------------------
PlayRight XP

Program designed by James Kocis and Adam Hiler, HardCopy Press,
Summit, New Jersey. Program written by Adam Hiler. Documentation
written by James Kocis & Stephen Kocis.

Paradox is a registered trademark of Ansa Software, a Borland
Company. Turbo Pascal is a registered trademark of Borland
International, Inc. LaserJet is a registered trademark of
Hewlett-Packard. Ventura Publisher is a registered trademark of
Xerox Corp. HotShot, Hercules and Compaq are registered trademarks
of their respective companies.

-------------------------------------------------------------------
Acknowledgments

Many thanks to all who made this endeavor possible: Manny Perez and
Michael Chesloff of Sinper Corporation; Sharon Lipscomb of Data
Quest Systems; Claire Chase, Sam Moeller, Mathew Syracuse of the
NYPC Paradox SIG; Mitch Musicant of NYNEX; Pam Insull of Ansa for
superior technical support and inspiring good humor; and Pete the
Piccolo Player. To Yorke Rhodes, Harry Strauss and Victor Pei:
thanks for helping improve PlayRight with your careful attention
to detail.

Special thanks to Cassandra Wilday and Marcia Hiler for their
understanding and support.

To Alan Zenreich of Zenreich Systems, thank you. Without your
continuing constructive criticism, PlayRight would not be
PlayRight.

-------------------------------------------------------------------
