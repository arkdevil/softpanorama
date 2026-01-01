Mini Java Editor - By Lim Thye Chean
====================================
This is a FREE Java development editor. You are welcome to distribute it 
to anybody. If you have any problem installing the software or have some
suggestions, please email to me.

It has been developed and tested on the following platforms:

  - Windows 95
  - Windows NT Workstation 4.0
  - Solaris 2.4

It supports the following features:

  * Project management.
  * Multiple window editing, compiling and building the project.
  * Use javac for compilation - and double click on error to edit the line!
  * Run Java application and see the results in console.
  * Run Java applets via AppletViewer or web browser.
  * Global search with case matching.
  * Search and replace with case matching within the window.
  * Indentation of source codes.
  * Go to line number.
  * Different font, style and size selection.
  * Ability to read and convert between MS-DOS or UNIX style text file.
  * Full editing functions.
  
This editor is totally written in Java JDK 1.1b3. It is also an AWT example 
for Java programmer. Source codes are included.


TIPS
====
Below is some of the hot keys when you are doing editing:

Ctrl-A: Select All
Ctrl-F: Find
Ctrl-G: Go to Line
Ctrl-R: Revert
Ctrl-S: Save

F7: Indent Left
F8: Indent Right
F12: Compile


IMPORTANT NOTICE
================
If you are using a previous version of MJE, check and see whether you can 
load you project. If not, please rebuild it. I have changed the format of 
MJE to add in compiler options and modified time for project building.
Sorry for inconvenient.


INSTALLATION
============
Before installation, you must have the latest copy of iss package (obtained
from the same site where you get MJE) installed. The iss package has to
be installed in java directory, or any directory that is listed in classpath.
The java directory should be in classpath too.

Follow the installation guide of each platforms below:


Windows 95/NT
-------------
1. Add the path of mje\classes to classpath in autoexec.bat.
2. Go to View->Options->File Types in the menu bar of any folder and add two
   file types "java" and "project". This step is IMPORTANT! Without doing
   this, you are not able to open and save file with he extension "java" and
   "project".
3. Run the mje.bat file.

Tips: create a shortcut to the mje.bat file and place it on desktop. Change 
the icon to any icon you like. Renamed the shortcut "Mini Java Editor". 
In the shortcut's properties, choose Program Tab, select "Close on exit" and
select "Minimized" in the Run menu. From now on, you can double click on
the new shortcut to open Mini Java Editor.

Note: When enabled the project menu, the menu name is not refresh properly. 
Believed that it is Java JDK bug since it works fine on Solaris 2.4.

Solaris
-------
1. Add the path of mje/classes and iss package to classpath.
2. Type "chmod +x mje".
3. Type "mje" to start the editor. 

Note: Changing font will resize the text window (a documented Solaris JDK bug).
At the same time, since I am developing MJE on Windows 95/NT, when I zipped
the file, some of the file or directory names will be converted to the wrong
case. Check especially the executable file "mje" is uppercase. The compiling
options of the MJE does not always work.


BUGS
====

  - A running program in frame cannot be stop
  - Build not working properly
  - When "save as..." is used, new file is opened when clicking on old name
  - Start a project from command line
  - In some case, Run does not work - it just says "Ready."
  
SPECIAL THANKS
==============
I wanted to thanks all of you who download my software and try it.
Since it is free, distribute it to anyone who needs it! There are a few
friends who I wanted to specially thanks - they help me a lot in giving
opinions and help me in programming:

* Uwe Steinmueller
* Eric Williams

I would also like to thanks whoever has given me feedback and encourage me
to go on. I would love to add any features that you requested if you can
provide me some source codes to work with.


OBTAIN THE LATEST VERSION
=========================
To get the latest version of MJE, go to web page
 
http://panda.iss.nus.sg:8000/alp/java/mje.html
(The server is normally down during weekends. Try it on weekdays.)

or

http://www.iss.nus.sg/RND/cs/ltchean/java/mje.html
(The version in this server is one day later, but the server is up all days.)


CONTACT
=======
email: ltchean@iss.nus.sg
web page: http://www.iss.nus.sg/RND/cs/ltchean
