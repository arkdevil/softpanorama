:h1 res=10010 group=1 x=center y=bottom width=100% height=100%.IPF Beginner's Guide
:lines align=center.
:font facename='Tms Rmn' size=48x24.IPF Beginner's Guide:font facename=default.
:p.
:font facename='Tms Rmn' size=18x14.By Dale Hackemeyer:font facename=default.
:elines.
:p.
A lot of people have asked how I create monthly MMOUG newsletters, so
this month I've put together the first of two articles detailing what I do.
This month I'll talk about the OS/2 tools I use to create the .INF file
you read and next month I'll detail the steps I take in creating the
newsletter, from scanning the internet and Fidonet, to "pasting" it up, and
finally compiling it to get the finished product.
:p.
At the heart of creating the MMOUG newsletter is the Information Presentation
Facility, or IPF. IPF is a tagged format language that allows you to format
text and graphics, and define how a reader may see and access that information.
:p.
All that's needed to create an IPF document is the IBM IPF Compiler
(:font facename=Courier size=12x12.IPFC.EXE:font facename=default.) and a
text editor (I use :font facename=Courier size=12x12.E.EXE:font facename=default.).
You can find the compiler in the Developer's Toolkit, as well as other
third party development tools such as Borland C++ for OS/2.
:p.
The hardest part about using IPF is learning all the various tags to format your text and define
where and how your text appears. So, I've broken things down into 6 sections
that describe some of the more frequently encountered IPF tags, starting
with what exactly a tag is, and leading up to links and graphics.
:lines align=center.
:link reftype=hd res=10011 dependent.The basics:elink.
:link reftype=hd res=10016 dependent.Starting out:elink.
:link reftype=hd res=10012 dependent.Manipulating Text:elink.
:link reftype=hd res=10013 dependent.Creating lists:elink.
:link reftype=hd res=10014 dependent.Linking things together:elink.
:link reftype=hd res=10015 dependent.Adding some graphics:elink.
:elines.
:p.
I've included the IPF file for this guide to help understand what's covered&colon. :font facename=Courier size=12x12.IPFguide.IPF
:font facename=default. which contains the IPF code used to create this guide.
I've also included the IPF file for the newsletter itself, however I haven't
included the additional bitmap and IPF files used to create the newsletter,
so it can't be compiled.

:h2 res=10011 group=2  x=center y=bottom width=90% height=90%.The basics
:font facename=Helv size=30x20.Tags:font facename=default.
:lm margin=5.
:p.
A tag begins with a colon (&colon.) immediately followed by the tag name
and ends with a period (.). For example, the tag for a new paragraph is&colon.
:p.
:font facename=Courier size=12x12.
&colon.p.
:font facename=default.
:p.
Some tags have one or more :hp2.attributes:ehp2., additional fields inside the
tag (after the tag name but before the period) that give more information about
the tag's operation. For example, to set the foreground color to red using the
:hp2.color:ehp2. tag, you would enter&colon.
:p.
:font facename=Courier size=12x12.
&colon.color fc=red.
:font facename=default.
:p.
Some tags have only one possible attribute, others have several attributes. Also,
sometimes an attribute is optional. For instance, the tag to start a simple list
has only one possible attribute, :hp1.compact:ehp1.. If not specified, there will
be a blank line between each item in the list. If specified, each item will be
on it's own line with no blank lines between it and any of the other items.
:p.
Some tags also require an :hp2.end tag:ehp2.. An end tag starts with an :hp2.e:ehp2.
followed by the original tag name. For example, a simple list requires an end tag
to tell the compiler when it's reached the end of the list:
:p.
:font facename=Courier size=12x12.
&colon.esl.
:font facename=default.
:p.
Some tags are known as :hp2.nested tags:ehp2.. These tags appear in between
other tags. An example of this the list item, or :hp2.&colon.li.:ehp2., tag. it
is used with the various list tags to specify a new item in the list.
An example using :hp2.attributes, nested tags,:ehp2. and :hp2.end tags:ehp2.
looks something like this&colon.
:font facename=Courier size=12x12.
:lines align=left.
&colon.sl compact.
&colon.li. first nested tag
&colon.li. second nested tag
&colon.li. third nested tag
&colon.esl.
:elines.
:font facename=default.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Symbols:font facename=default.
:lm margin=5.
:p.
There are also specialized tags called :hp1.symbols:ehp1. that begin with an
ampersand (&amp.) and end with a period (.). Symbols let you display most of
the extended ASCII character set, such as the box drawing characters.
:p.
Symbols also let you display some normal ASCII punctuation characters. For instance,
since all tags begin with a colon, how do you put a colon in some text so it
doesn't trick the IPF compiler into thinking it's another tag? Use the
:hp2.&amp.colon.:ehp2. symbol! OK, since all symbols start with an ampersand,
how do you keep that compiler from confusing single ampersands with symbols?
Use the :hp2.&amp.amp.:ehp2. symbol!
:p.
There are around 140 symbols available in IPF, which is too many to list here.
The only two that I've found absolutely necessary are the colon and ampersand
symbols for the reasons mentioned above.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Files:font facename=default.
:lm margin=5.
:p.
You can create the IPF source file with any text editing tool, so long as you
save it as ASCII text.
:p.
Each line of the source file may be no longer than 255
characters. If any line is longer, the compiler will give an error message.
:p.
You may have more than one IPF source file as well. Using the :hp2..im:ehp2.
directive allows you to imbed additional IPF files at compile time. The 
:hp2..im:ehp2. directive must appear on it's own line in the first column
of the source file. For example, you can include the file SOMEFILE.IPF in  
your document by putting the following line in:
:p.
:font facename=Courier size=12x12.
&period.im SOMEFILE.IPF
:font facename=default.
:p.
This allows you to break a large document into smaller more manageable files, then
compile them into one document by imbedding them in a single master file.
:p.
According to the IPF manual, each file is also limited to a 64K file size as
well, but I've had no problem compiling files >100K.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Using the IPF compiler:font facename=default.
:lm margin=5.
:p.
The IPF compiler, :font facename=Courier size=12x12.IPFC.EXE:font facename=default.,
is a relatively straight-forward affair. Simply enter
:font facename=Courier size=12x12.IPFC.EXE:font facename=default., the name 
of your source file, and the :font facename=Courier size=12x12./INF:font facename=default.
parameter. The :font facename=Courier size=12x12./INF:font facename=default.
parameter tells the compiler you want a stand alone .INF file since the
compiler produces .HLP files by default. For example&colon.
:p.
:font facename=Courier size=12x12.
IPFC Example.IPF /INF
:font facename=default.
:p.
This will produce the file :font facename=Courier size=12x12.Example.INF:font facename=default.. 


:h2 res=10016 group=2  x=center y=bottom width=90% height=90%.Starting out
:font facename=Helv size=30x20.Defining the document:font facename=default.
:lm margin=5.
:p.
It is necessary to tell the IPF compiler the the file it is processing is in fact
an IPF document. The :font facename=Courier size=12x12.&colon.userdoc.:font facename=default.
tag does just this. You must also end your document with the :font facename=Courier size=12x12.&colon.euserdoc.:font facename=default.
tag to tell the compiler when it's reached the end of the document.
:p.
Next you can give the title of the document with the:font facename=Courier size=12x12.
&colon.title.:font facename=default. tag. Simply follow the tag with the name of
the document, and it will appear at the top of the main window when VIEWing
the document. For example&colon.
:p.
:font facename=Courier size=12x12.
&colon.title.An example IPF file
:font facename=default.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Headings (aka windows):font facename=default.
:lm margin=5.
:p.
An IPF document may have up to six levels of headings. Headings are the lines of
text that appear in the Table of Contents window when you first VIEW a document.
The ones initially displayed are :hp2.first level:ehp2. headings. If a first
level tag has a plus next to it, then there is a :hp2.second level:ehp2. heading
"under" the first level heading, and so forth.
:artwork name='TOC.BMP' align=center.
:p.
As you probably know, double-clicking on a heading in the Table of Contents
opens another window, so it's easy to think of defining headings as defining
new windows for the reader of your document.
:p.
Headings are defined using the :font facename=Courier size=12x12.&colon.h1.
:font facename=default. thru :font facename=Courier size=12x12.&colon.h6.
:font facename=default. tags. The heading tags have quite a few possible
attributes. For simplicity here, we will only be discussing a few important ones.
:lm margin=10.
:parml tsize=16 break=none.
:pt.:font facename=Courier size=12x12.res=xxx:font facename=default.
:pd.where xxx is a number between 1 and 64000, and each window must have a
unique number. The number is reference to the window defined by the heading
tag. This number is used by link tags in order to select other windows. 

:pt.:font facename=Courier size=12x12.group=xxx:font facename=default.
:pd.where xxx is a number between 1 and 64000. The number assigns the window
to a particular group. When you select a window with a group number to display,
IPF searches all open windows for a window with the same group number. If no match
is found, the new window is opened. If the group number is matched with an open
window with the same group number, the current window is :hp1.replaced:ehp1.
with the new window. Group numbers are useful in keeping the clutter of open
windows to a minimum.

:pt.:font facename=Courier size=12x12.x=:font facename=default.
:pd.x may be assigned one of the following values&colon. center | left | right.
This attribute defines what the window's postition will be in regard to the
parent (main IPF) window. It will only be noticable to use this attribute with
the height/width attributes below.

:pt.:font facename=Courier size=12x12.y=:font facename=default.
:pd.y may be assigned one of the following values&colon. center | top | bottom.
This attribute defines what the window's postition will be in regard to the
parent window. It will only be noticable to use this attribute with
the height/width attributes below.

:pt.:font facename=Courier size=12x12.width=xx%:font facename=default.
:pd.where xx is percentage up to 100. Defines the windows width relative to
the parent window.

:pt.:font facename=Courier size=12x12.height=xx%:font facename=default.
:pd.where xx is percentage up to 100. Defines the windows height relative to
the parent window.
:eparml.

:artwork name='XYcoordinates.BMP' align=center.
:lines align=center.Figure taken from IPF manual.:elines.
:lm margin=5.:p.
While these attributes are helpful, none are necessary to create a simple
window. For example&colon.
:p.
:font facename=Courier size=12x12.
&colon.h1.A very simple window
:font facename=default.
:p.
This creates a first level heading in the Table of Contents window. For something
more interesting, you could try chenging it to&colon.
:p.
:font facename=Courier size=12x12.
&colon.h1 x=left y=top width=75% height=75%.A slightly more interesting window
:font facename=default.
:p.
This creates a window in a position of our choosing. Now let's try making
a second level heading. It's quite simple&colon.
:p.
:font facename=Courier size=12x12.
&colon.h2 x=right y=bottom width=75% height=75%.Another slightly more interesting window
:font facename=default.
:p.
This creates a second level heading in the Table of Contents beneath the
previous first level heading. Since we haven't been putting group numbers
in these headings, we can only see one window at a time. Let's add some
group numbers to the last two example headings so we can see both at the
same time&colon.
:p.
:font facename=Courier size=12x12.
&colon.h1 group=1 x=left y=top width=75% height=75%.Another window
:font facename=default.
:p.
:font facename=Courier size=12x12.
&colon.h2 group=2 x=right y=bottom width=75% height=75%.A window you can see at the same time
:font facename=default.
:p.
Now, when the :hp1.Another window:ehp1. is displayed, selecting
:hp1.A window you can see at the same time:ehp1. will display it at the same
time.
:p.
So far I haven't discussed what to do with :hp2.res=:ehp2.. It's rather
unnecessary at this point. Later, when we discuss :hp2.links:ehp2., we'll see
just how important :hp2.res:ehp2. numbers can be.

:h2 res=10012 group=2  x=center y=bottom width=90% height=90%.Manipulating Text
:p.
One of the most useful features of IPF is it's text manipulation capabilities.
Without these abilities, we'd only be able to present nice windows of drab
looking text. How boring! Fortunately, with the following information and a
little creativity, you can make your text jump out to the reader.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Highlighted phrases:font facename=default.
:lm margin=5.
:p.
These are the quickest and simplest tags to use to change the way your text
looks. The tags are in the form:font facename=Courier size=12x12.
&colon.hp:hp1.n:ehp1..:hp2.highlighted text:ehp2.&colon.hp:hp1.n:ehp1.
:font facename=default., where :font facename=Courier size=12x12.:hp1.n:ehp1.
:font facename=default. is a number between 1 and 9.
:p.
For example, the following&colon.
:lm margin=10.
:lines align=left.
:font facename=Courier size=12x12.
&colon.hp1.Highlighted phrase 1 is italic&colon.ehp1.
&colon.hp2.Highlighted phrase 2 is bold&colon.ehp2.
&colon.hp3.Highlighted phrase 3 is bold-italic&colon.ehp3.
&colon.hp4.Highlighted phrase 4 is blue&colon.ehp4.
&colon.hp5.Highlighted phrase 5 is underlined&colon.ehp5.
&colon.hp6.Highlighted phrase 6 is underlined-talic&colon.ehp6.
&colon.hp7.Highlighted phrase 7 is underlined-bold&colon.ehp7.
&colon.hp8.Highlighted phrase 8 is red&colon.ehp8.
&colon.hp9.Highlighted phrase 9 is magenta&colon.ehp9.
:font facename=default.
:lm margin=5.
:p.
produces text that looks like this&colon.
:lm margin=10.
:lines align=left.
:hp1.Highlighted phrase 1 is italic:ehp1.
:hp2.Highlighted phrase 2 is bold:ehp2.
:hp3.Highlighted phrase 3 is bold-italic:ehp3.
:hp4.Highlighted phrase 4 is blue:ehp4.
:hp5.Highlighted phrase 5 is underlined:ehp5.
:hp6.Highlighted phrase 6 is underlined-talic:ehp6.
:hp7.Highlighted phrase 7 is underlined-bold:ehp7.
:hp8.Highlighted phrase 8 is red:ehp8.
:hp9.Highlighted phrase 9 is magenta:ehp9.
:elines.
:lm margin=5.
:p.
You cannot nest highlighted phrase
:lm margin=1.
:p.
:font facename=Helv size=30x20.Color:font facename=default.
:lm margin=5.
:p.
While highlighted phrase let you change the color of the text to one of 3 colors,
the color tag let's you change the foreground and backgound colors of your text.
the tag has the form :font facename=Courier size=12x12.&colon.color.
:font facename=default. and must include one or both of the following
attributes&colon.
:lm margin=10.
:parml tsize=10 break=none compact.
:pt.:font facename=Courier size=12x12.fc=:font facename=default.
:pd.changes the foreground color.
:pt.:font facename=Courier size=12x12.bc=:font facename=default.
:pd.changes the background color.
:eparml.
:lm margin=5.
:p.
The choices for both foreground and background colors are&colon.
:color fc=blue.blue:color fc=default., :color fc=cyan.cyan:color fc=default.,
:color fc=green.green:color fc=default., :color fc=neutral.neutral:color fc=default.,
:color fc=red.red:color fc=default., :color fc=default.default:color fc=default.,
and :color fc=yellow.yellow:color fc=default.. 

:p.
Some example tags&colon.
:lm margin=10.
:lines align=left.
:font facename=Courier size=12x12.
&colon.color fc=cyan.Here's some lovely cyan text.
&colon.color fc=red bc=green.Here's some red on green.
&colon.color fc=yellow bc=blue.Here's some yellow on blue.
&colon.color fc=default bc=red.Here's the default foreground on red.
&colon.color bc=default.And now both foreground and background are back to defaults.
:font facename=default.
:lm margin=5.
:p.
and their output&colon.
:lm margin=10.
:lines align=left.
:color fc=cyan.Here's some lovely cyan text.
:color fc=red bc=green.Here's some red on green.
:color fc=yellow bc=blue.Here's some yellow on blue.
:color fc=default bc=red.Here's the default foreground on red.
:color bc=default.And now both foreground and background are back to defaults.
:elines.
:lm margin=5.
:p.
There is no end tag for a color tag. The colors assigned remain in effect until
the end of the current window they are assigned in. To change everything back
to normal, simply use :font facename=Courier size=12x12.&colon.color fc=default
bc=default:font facename=default..

:lm margin=1.
:p.
:font facename=Helv size=30x20.Fonts:font facename=default.
:lm margin=5.
:p.
The :font facename=Courier size=12x12.&colon.font.:font facename=default. tag
allows you to change the font that your text is displayed in. It has two
attributes&colon.
:lm margin=10.
:parml tsize=17 break=none compact.
:pt.:font facename=Courier size=12x12.facename=:font facename=default.
:pd.changes the font to the name specified. There are four possible fonts to
choose from&colon. Courier, Helv, 'Tms Rmn', and default (spelling and
punctuation for each must be as shown). Facename is :hp1.always:ehp1.
a required attribute.
:pt.:font facename=Courier size=12x12.size=:hp1.h:ehp1. x :hp1.w:ehp1.:font facename=default.
:pd.changes the height and width (in :hp2.points:ehp2.) of the font. If size
given is invalid for the font, IPF will choose the nearest match. Size is a
required attribute when :hp2.facename:ehp2. is anything other than default.
:eparml.
:lm margin=5.
:p.
There are four possible fonts that may be used, as this example shows&colon.
:lines align=left.
:font facename=Courier size=12x12.
&colon.font facename=Courier size=12x12.Courier&colon.font facename=default.
&colon.font facename=Helv size=12x12.Helv&colon.font facename=default.
&colon.font facename='Tms Rmn' size=12x12.'Tms Rmn'&colon.font facename=default.
&colon.font facename=default size=12x12.default&colon.font facename=default.
:font facename=default.
:elines.

:lm margin=1.
:p.
:font facename=Helv size=30x20.Margins:font facename=default.
:lm margin=5.
:p.
Margins are helpful in organinzing various sections of text, as this very window
shows. There are two margin tags&colon.:font facename=Courier size=12x12.
&colon.lm margin=:hp1.n:ehp1.:font facename=default. and
:font facename=Courier size=12x12.&colon.rm margin=:hp1.n:ehp1.:font facename=default.,
which control left and right margins, respectively. :hp1.N:ehp1. is the value
of the margin to be assigned. Assigned margins don't take effect until a tag
is used that enters a line feed. :hp2.&colon.p.:ehp2. is used most often.
The assigned margins remain in effect until either
changed or the end of the current window is reached.
:p.
For example, the following&colon.
:font facename=Courier size=12x12.
:p.
&colon.lm margin=25.&colon.rm margin=10.
.br
&colon.p.
.br
This text has the left margin set at 25 and the right margin set at 10. As you
can see, the text is automatically justified between the two margins.
.br
&colon.lm margin=10.&colon.rm margin=25.
.br
&colon.p.
.br
This text has been set exactly opposite, with the left margin set at 10 and the
right margin set at 25. Once again everything's justified to fit the margins. 
:font facename=default.
:lm margin=5.:p.
looks something like this&colon.
:lm margin=25.:rm margin=10.
:p.
This text has the left margin set at 25 and the right margin set at 10. As you
can see, the text is automatically justified between the two margins.
:lm margin=10.:rm margin=25.
:p.
This text has been set exactly opposite, with the left margin set at 10 and the
right margin set at 25. Once again everything's justified to fit the margins. 
:lm margin=5.:rm margin=1.
:p.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Lines:font facename=default.
:lm margin=5.
:p.
Normally the text in an IPF window is dynamically justified. Rather than having
the text scroll of the side of the window, IPF makes sure it all fits. Try
making this window narrower and you'll see what I mean.
:p.
Sometimes, however, you have some text that only makes sense if the appears
as it is formatted in the source file. The:font facename=Courier size=12x12.
&colon.lines.:font facename=default. tag allows you to display lines in IPF
just as they appear in your source file. There is only one attribute&colon.
:lm margin=10.
:parml tsize=10 break=none compact.
:pt.:font facename=Courier size=12x12.align=:font facename=default.
:pd.allows you to select the alignment of the text. May be left, right, or
center. If not specified, text is aligned to the left.
:eparml.
:lm margin=5.
:p.
The end tag is :font facename=Courier size=12x12.&colon.elines.:font facename=default.
:p.
For example&colon.
:lines.:font facename=Courier size=12x12.
&colon.lines align=left.This text is aligned to the left.&colon.elines.
:p.
&colon.lines align=center.This text is centered.&colon.elines.
:p.
&colon.lines align=right.This text is aligned to the right.&colon.elines.
:font facename=default.
:elines.
:p.
ouputs&colon.
:lines.
:lines align=left.This text is aligned to the left.:elines.
:p.
:lines align=center.This text is centered.:elines.
:p.
:lines align=right.This text is aligned to the right.:elines.
:elines.
:p.

:h2 res=10013 group=2  x=center y=bottom width=90% height=90%.Creating lists
:lm margin=5.
:p.
IPF has several ways to display lists of information. The three most common
ways are simple lists, unordered lists, and ordered lists. There is also the
parameter list, which is a more specialized list.
:p.
Lists may be nested together, and when nested the nested lists automatically
indent themselves from their "parent" list, creating an outline form.
:p.
The primary three types of lists (simple, unordered, and ordered) all work
pretty much the same. The only difference between the three is whats in
front of each list item. A simple list has nothing in front, an
unordered list has a bullet (lowercase o) in front, and an ordered list
has each item numbered in order.
:p.
All three list types have only one attribute,:font facename=Courier size=12x12.
compact:font facename=default.. When used compact causes each item in the list
to appear on the line following the previous item, otherwise there is a blank
line between each item.
:p.
All three also have one nested tag,:font facename=Courier size=12x12.
&colon.li.:font facename=default., which is used to identify each item in the
list.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Simple List:font facename=default.
:lm margin=5.
:p.
A simple list begins with :font facename=Courier size=12x12.&colon.sl.:font facename=default.
and ends with :font facename=Courier size=12x12.&colon.esl.:font facename=default..
For example&colon.
:lines.
:font facename=Courier size=12x12.
&colon.sl.
&colon.li.Open mouth
&colon.li.Insert foot
&colon.li.Regret opening mouth
&colon.esl.
:font facename=default.
:elines.
:p.
outputs&colon.
:sl.
:li.Open mouth
:li.Insert foot
:li.Regret opening mouth
:esl.
:lm margin=1.
:p.
:font facename=Helv size=30x20.Unordered List:font facename=default.
:lm margin=5.
:p.
A unordered list begins with :font facename=Courier size=12x12.&colon.ul.:font facename=default.
and ends with :font facename=Courier size=12x12.&colon.eul.:font facename=default..
For example&colon.
:lines.
:font facename=Courier size=12x12.
&colon.ul.
&colon.li.Open mouth
&colon.li.Insert foot
&colon.li.Regret opening mouth
&colon.eul.
:font facename=default.
:elines.
:p.
outputs&colon.
:ul.
:li.Open mouth
:li.Insert foot
:li.Regret opening mouth
:eul.

:lm margin=1.
:p.
:font facename=Helv size=30x20.Ordered List:font facename=default.
:lm margin=5.
:p.
A ordered list begins with :font facename=Courier size=12x12.&colon.ol.:font facename=default.
and ends with :font facename=Courier size=12x12.&colon.eol.:font facename=default..
For example&colon.
:lines.
:font facename=Courier size=12x12.
&colon.ol compact.
&colon.li.Open mouth
&colon.li.Insert foot
&colon.li.Regret opening mouth
&colon.eol.
:font facename=default.
:elines.
:p.
outputs&colon.
:ol compact.
:li.Open mouth
:li.Insert foot
:li.Regret opening mouth
:eol.

:lm margin=1.
:p.
:font facename=Helv size=30x20.Parameter List:font facename=default.
:lm margin=5.
:p.
This type of list allows a two column listing with a term and a definition.
Parameter lists have three optional attributes&colon.
:lm margin=10.
:parml tsize=12 break=none.
:pt.:font facename=Courier size=12x12.tsize=:hp1.n:ehp1.:font facename=default.
:pd.n specifies the space to be allocated for the paramter term. Defaults to 10
:pt.:font facename=Courier size=12x12.break=:font facename=default.
:pd.defines how the parameter term and parameter description are formated. There
are three possible values that may be assigned to this attribute&colon.
:font facename=Courier size=12x12.all:font facename=default.
causes the description to begin on the line following the term, after the space
allocated by :hp2.tsize=:ehp2..
:font facename=Courier size=12x12.fit:font facename=default.
Causes the description to start on the same line as the term if the term has
fewer characters than allocated by :hp2.tsize=:ehp2.. If the term has more characters, the
description begins on the next line.
:font facename=Courier size=12x12.none:font facename=default.
causes the description to begin on the same line as the term. if the term is
longer than that specified by :hp2.tsize=:ehp2., the term continues into the
description and is seperated from the description by one space.
:pt.:font facename=Courier size=12x12.compact:font facename=default.
:pd.works just like it does with the other lists
:eparml.
:lm margin=5.
:p.
Paramter lists have two nested tags. :font facename=Courier size=12x12.&colon.pt.:font facename=default.
defines the paramter term, and :font facename=Courier size=12x12.&colon.pd.:font facename=default.
defines the paramter definition
:p.
The end tag is :font facename=Courier size=12x12.&colon.eparml.:font facename=default.
:p.
For example&colon.
:lines.:font facename=Courier size=12x12.
&colon.parml tsize=8 break=none.
&colon.pt.term
&colon.pd.definition
&colon.pt.RAM
&colon.pd.Random Access Memory
&colon.pt.HPFS
&colon.pd.High Performance File System
&colon.pt.FAT
&colon.pd.File Allocation Table
&colon.eparml
:elines.:font facename=default.
:p.
outputs&colon.
:parml tsize=8 break=none.
:pt.term
:pd.definition
:pt.RAM
:pd.Random Access Memory
:pt.HPFS
:pd.High Performance File System
:pt.FAT
:pd.File Allocation Table
:eparml.

:h2 res=10014 group=2 x=center y=bottom width=90% height=90%.Linking things together
:lm margin=5.
:p.
Links allow the reader of an IPF document much quicker access to information.
With a simple point and click, the reader is able to call up other windows contained
in the document.
:p.
The link tag is used do this&colon. :font facename=Courier size=12x12.&colon.link.:font facename=default..
There are quite a few attributes for the link tag, though some are too advanced for
us to worry about right now. The tags I think are most relevant&colon.
:parml tsize=15 break=none.
:pt.:font facename=Courier size=12x12.reftype=:font facename=default.
:pd.can be assigned one of four values&colon. :hp2.hd, fn, launch,:ehp2. and
:hp2.inform:ehp2.. :hp2.hd:ehp2. tells the compiler that we're creating a link to
a heading, and this is only value you'll need to worry about until you've become
a more advanced IPF writer (I still haven't used any of the other values).
:hp2.fn:ehp2. specifies a link to a footnote, and :hp2.launch:ehp2. and :hp2.inform:ehp2.
are used to launch PM programs and send messages to PM programs. Please refer to the
IPF manual for more info on how to use these attributes.
:pt.:font facename=Courier size=12x12.res=:font facename=default.
:pd.when :hp2.reftype=hd:ehp2., you must use this attribute to give the res number
assigned to the heading you are going to link to. Remember how I said res numbers
weren't impostant yet when I was talking about headings? Well now they are :hp1.very:ehp1.
important. In order to point to a heading you must assign that heading a res number.
:pt.:font facename=Courier size=12x12.auto:font facename=default.
:pd.a link tag with this attribute is automatically opened everytime the window
the link is in is opened.
:pt.:font facename=Courier size=12x12.dependent:font facename=default.
:pd.when this attribute is specified the window opened by the link is dependent
on the window the link appears in. That is, if a window is opened by a dependent link,
and the window where the link appears is closed, the window created by the link is
closed also. 
:eparml.
:p.
Link tags usually have an end tag (:font facename=Courier size=12x12.&colon.elink.:font facename=default.),
but when the :hp2.auto:ehp2. attribute is specified it becomes unneeded.
:p.
Without the :hp2.auto:ehp2. attribute, the text that the reader will actually click on
come between the :hp2.link:ehp2. and :hp2.elink:ehp2. tags. When the :hp2.auto:ehp2.
is specified, there is no text for the link since the link will always be opened
automatically.
:p.
Simple link&colon.
:p.
:font facename=Courier size=12x12.
&colon.link reftype=hd res=123.Click here for more info&colon.elink.
:font facename=default.
:p.
An automatic link&colon.
:p.
:font facename=Courier size=12x12.
&colon.link reftype=hd res=123 auto.
:font facename=default.
:p.
A dependent link&colon.
:p.
:font facename=Courier size=12x12.
&colon.link reftype=hd res=123 dependent.Click here for more info&colon.elink.
:font facename=default.
:p.
An auto and dependent link&colon.
:p.
:font facename=Courier size=12x12.
&colon.link reftype=hd res=123 auto dependent.
:font facename=default.
:p.

:h2 res=10015 group=2 x=center y=bottom width=90% height=90%.Adding some graphics
:font facename=Helv size=30x20.Artwork:font facename=default.
:lm margin=5.
:p.
Adding graphics can make almost any document more lively. With IPF, any Bitmap or
Metafile may be used as pictures both around and in text.
:p.
The :font facename=Courier size=12x12.&colon.artwork.:font facename=default.
tag is used to insert graphics. There
are several attributes&colon.
:parml tsize=20 break=none.
:pt.:font facename=Courier size=12x12.name='filename':font facename=default.
:pd.specifies the name of the bitmap of metafile containing the graphic to be
displayed. The :font facename=Courier size=12x12.filename:font facename=default.
may include drive and path info if the file resides in a directory other than that
of the IPF file.
:pt.:font facename=Courier size=12x12.align=:font facename=default.
:pd.sets the alignment of the image on screen. May be :hp2.left:ehp2., :hp2.right:ehp2.,
or :hp2.center:ehp2..
:pt.:font facename=Courier size=12x12.runin:font facename=default.
:pd.allows a bitmap to be placed on amidst a line of text.
:pt.:font facename=Courier size=12x12.fit:font facename=default.
:pd.causes the bitmap to fill the window that contains it. If the window is resized,
the bitmap is resized.
:eparml.
:p.
Only the :hp2.name=:ehp2. tag is required, and there is no end tag.
:p.
For example&colon.
:font facename=Courier size=12x12.
:lines.
&colon.artwork name='logo_sm.bmp' align=left.
&colon.artwork name='logo_md.bmp' align=center.
&colon.artwork name='logo_lg.bmp' align=right.
:elines.
:font facename=default.
:p.
displays&colon.
:artwork name='logo_sm.bmp' align=left.
:artwork name='logo_md.bmp' align=center.
:artwork name='logo_lg.bmp' align=right.
