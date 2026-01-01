WPTOHTML 1.00 is a macro which converts WordPerfect 5.1/6.0 for
DOS documents to HTML (now in the public domain).  Unlike many
editing tools, this macro allows individuals with no knowledge
of HTML to create full featured documents in a familiar WYSIWYG
environment.  Many documents created without HTML in mind can be
converted and posted on-line without further alteration. 
Features in this release include:

o    Conversion of tables of contents, cross-references(*),
     indices, endnote references, and WordPerfect 6.0 hypertext
     links into HTML hypertext links.

o    Automatic conversion of tables created using either the
     "Tab" key or using WordPerfect Table function.

o    Support for the full ISOLatin1 character set and some non-
     standard extensions.

o    Level n styles, including styles created by the user,
     become level n headings (in 5.1); enlarged and reduced text
     become headings as well.

o    Support for in-line figure references, horizontal lines,
     block quotes, shifts to fixed-width (Courier) fonts(*),
     bold-face, italics, underlining, non-breaking spaces, and
     creation of header and address text.

o    Automatic conversion to an ASCII text file with an .HTM
     extension.

o    An almost single-pass algorithm achieves an acceptable
     speed, despite that fact that the WordPerfect macro
     language is interpreted.

(Features marked with a * do not work perfectly or are
unavailable with the 5.1 macro; use the 6.0 macro if possible.)

Bug reports and suggestions for improvement are welcome.  If the
response is sufficiently positive, future releases will include
a version for WP6.0 for Windows, as well as an HTML toolbox,
instant format-swapping, execution of hypertext links to remote
URLs from within WordPerfect, importing of HTML, and eventual
support for HTML+.  WordPerfect is a trademark of WordPerfect
Corporation.

Hunter Monroe
(hmonroe@imf.org)Documentation for WPTOHTML 1.00

     WPTOHTML 1.00 is a macro for converting WordPerfect 5.1/6.0
documents to the HyperText Markup Language (HTML), the format
used by the Internet's World-Wide Web (WWW).  It will convert
documents which were not created with HTML in mind and by
individuals with no knowledge of HTML.  WPTOHTML 1.00 has now
been placed in the public domain.
     System Requirements: The macro will run on any computer with
WordPerfect 5.1/6.0 for DOS (as well as WordPerfect 5.1 for VAX
VMS); a 486 CPU is recommended but not required.  Note that
WordPerfect 6.0 for Windows (WP4W) is not currently supported. 
However, documents created within WP4W can be imported into
WordPerfect 6.0 for DOS and converted using WPTOHTML.  Also not
supported are WordPerfect for the OS/2 and Unix operating
systems.
     Installation: Make sure that you have the correct version
of WPTOHTML for your version of WordPerfect: WPT60DOS.ZIP for
WordPerfect 6.0 for DOS; and WPT51DOS.ZIP for WordPerfect 5.1 for
DOS.  Copy the file WPTOHTML.WPM to your WordPerfect Macro Files
directory, which (probably \WP60\MACROS) for 6.0).  To be
certain, within WordPerfect type Shift-F1, choose Location of
Files, and look under Macros.  Copy the file with the .PRS to
your Printer Files directory (probably \WP51 or \WPC60DOS), which
you can check by typing Shift F1, Location of Files.
     Running WPTOHTML:  To run WPTOHTML, you must first save your
document to disk.  The filename of the WordPerfect should not
have the file extension .HTM.  Then, type Alt-F10, the letters
WPTOHTML, and then hit the enter key.  The macro will move to the
top of your documents, and then pass through it character-by-
character inserting HTML tags as it goes along, such as "<B>" for
boldspace.  When the macro is done, you will be asked if you want
to save the file to disk with the file extension (the three
letters of the filename after the ".") changed to ".HTM".  Choose
yes unless for some reason you do not want to replace a file by
the same name already on disk.
     WPTOHTML gives your the option to save your document when
it is finished.  If you make further changes, be sure to save
your document as ASCII text rather than in WordPerfect format (in
WordPerfect 5.1, use Ctrl-F5, 1).  
     Viewing the Results:  To view the output of WPTOHTML, you
need a World-Wide Web client such as NCSA Mosaic for Windows, or
Cello for Windows.  NCSA Mosaic may obtained by anonymous FTP
from ftp.ncsa.uiuc.edu.
     Publishing your HTML Document On-line:  To place an HTML
document on-line, you need access to a WWW, Gopher, or ftp server
on a computer connected to the Internet.  If you cannot post
information on someone else's server, you can obtain information
about installing your own WWW server from http://info.cern.ch/
or Gopher server from ftp://boombox.micro.umn.edu
You should carefully consider the security implications before
setting up a server on your computer.  If you use the wrong
software or configure it poorly, outsiders can potentially read
and delete any file on your computer.
     Samples: The following are samples of codes which are
converted by WPTOHTML.
BOLD, ITALC, UND, DBL UND, REDLN, 
EXT LARGE, VRY LARGE, LARGE, SMALL, FINE.
     
     Lft/Rgt Indent (this paragraph becomes a block quote
     in HTML.  That means both sides are indented.

Horizontal line
Here are some unusual characters:
£ìÅäëèïî

     Features Not Supported:  WPTOHMTL does not support all
WordPerfect features, including Equations, Table Boxes, and Text
Boxes.  It does not yet support HTML elements for unordered lists
or ordered lists.

     Tips for Achieving Better Results: 

     Generated Text: When you define a table of contents, list,
or index, leave off the page number.  
     Styles: In WordPerfect 5.1, any "Outline" type style has
<Hn></Hn> tags added to its codes for level n.  In WordPerfect
6.0 for DOS, the styles are left unchanged (an earlier version
of WPTOHTML converted any style with a number in it to a header).
     If you have developed your own custom styles, you may wish
to create an HTML version of those styles to override WPTOHTML's
conversion.  Suppose your existing styles are in a file called
LIBRARY.STY, and you have a style called "Main" that should
becomes a first-level heading.  Edit the codes for the "Main"
style, while leaving the name as it is, and replace the existing
codes with "<H1>[Comment]</H1>".  Do the same for your other
styles.  Then, save the HTML version of your styles to a file
called HTML.STY.
     Then, to convert a document to HTML: (1) load LIBRARY.STY,
(2) run WPTOHTML, (3) load HTML.STY, and (4) save the document
as ASCII text.  It is important that LIBRARY.STY is loaded when
you run WPTOHTML, for instance, so a table of contents is
generated correctly.
     Graphics: WPTOHTML does not convert graphics files from
WordPerfect's graphic format, .WPG, to the formats commonly used
on the Internet, such as .GIF or .JPEG.  Graphics Workshop for
Windows will convert the bitmapped portions of a .WPG file, but
not the object-oriented portions (lines and circles), if these
are present.  Suggestions to the author on how best to convert
graphics from .WPG format are welcome.
     Cross-References:  In WordPerfect 6.0 for DOS, cross-
references and targets are converted to HTML links based upon the
name you specify for the target.  However, in WordPerfect 5.1
WPTOHTML uses the names TARGETn.XXX for the nth target or cross-
reference from the top of the document.  Only if your targets and
cross-references happen to come in the same order will they match
properly, so you will need to edit the HTML version to correct
for this problem.  Upgrade to WordPerfect 6.0 if you want to
avoid this problem.

     Advanced Features: WPTOHTML converts documents with tables
and endnotes to HTML in a slightly different way than documents
without these features.  The macro prints the HTML version to
disk, and then reopens it for you.  On the other hand, for
documents without tables or endnotes, WPTOHTML normally creates
the HTML version within WordPerfect and asks whether you want to
save it.
     If you want to make changes to a document after running
WPTOHTML, for instance, by loading a style file that you have
created, you need to do the following.  Install the .PRS file
that came with WPTOHTML as a new printer.  Edit that printer to
give it a port of other and set it to print to a file call
WPTOHTML.PRN.  Go to the document screen (using Shift-F3) that
has your document with a mixture of WordPerfect codes and HTML
tags.  Make any changes, such as loading HTML.STY.  Then, print
the document to the file WPTOHTML.PRN by selecting the printer
you just installed.  Open WPTOHTML.PRN, and do a global search-
and-replace to eliminate the form feeds.
     Footnotes and Endnotes: Because HTML is not page-oriented,
you should convert footnotes to endnotes by running the macro
FOOTEND.WPM, which is part of the WordPerfect distribution.  Type
Alt-F10, then FOOTEND, and then hit the Enter key.  Then, after
you run WPTOHTML on a document with endnotes, WPTOHTML will print
to a file rather than saving your file to disk with an .HTM
extension.
     Tables: There are two methods for creating tables in
WordPerfect: using the Tab key, and using the WordPerfect table
function.  If you use the first method, WPTOHTML decides that a
line is part of a table if it has a Tab anywhere after a
character.
