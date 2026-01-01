From: cabanie@lep-philips.fr (Jean-Pierre Cabanié)
Newsgroups: comp.lang.rexx
Subject: Re: Please help with PARSE templates
Date: 30 Sep 1995 14:20:21 GMT

In message <DFpA9I.JBG@physics.purdue.edu> - korty@london.physics.purdue.edu (A
ndrew J. Korty) writes:
:>
:>Could someone post either a summarization of the various features of
:>PARSE templates or a pointer to that information?  Templates are not
:>very well documented in the INF file that comes with OS/2.
:>
:>Thanks ...
:>Andy
:>--
:>Andrew J. Korty
:>Systems Programmer
:>Physics Computer Network
:>Purdue University



The following doesn't speak for Object Rexx that I never tried. I hope you'l
find it usefull however :

PARSE patterns

A great part of this is taken from IBM VM-ESA REXX REFERENCE GUIDE
(SC24-5466) and is hence may still be more or less copyrighted by IBM.

I write this hoping it will help some users to take the best advantage
of the Rexx language richest instruction.
From my experience, using PARSE is generally more efficient than to
write many lines of code. I always had the impression that, for example,
the use of parse in instructions like :
  PARSE VALUE '1 1 0' WITH Var1 Var2 Var3 Var4 was better than
  Var1 = 1; Var2 = 1; Var3 = 0; Var 4 = ''.
As I am a lazy programmer, I got perhaps this impression because it
saves a lot of typing but, even if this is the only reason it is still
usable.

In any template, the decimal point . can be used as a placeholder
meaning 'blackhole' no variable is set but the assiated part of the
input string is 'processed'.

There are three main types of templates :
1/The most simple
  It is the one given above. Each blank separated part of the given
string is stored in the variables given. The last variable will get
all the remaining of the data when the previous ones have been set.
In these types of templates, the use of a trailing decimal point
ensures that the last variable given in the pattern will receive only
one word. (the remaining ones if any are associated to the blackhole).

2/String patterns
  The elements put in quotation marks are used to indicate where the
splitting of the input string is to occur. This can help in separating
arguments and options for example.
  In general, due to the Rexx variables handling, blanks are not
significants but one must keep in mind that the parsing uses ONE blank
as a delimiter and, if more than one blank is used for separating the
elements, some of them can be found at the beginning of a variable
contents (namely for the last parsed variable). This is much more
emphasized with the parse templates containing strings : in that case,
the blanks that surround the delimiter are kept.
given Fullname = 'Jean  Pierre  Cabanié' (2 times 2 blanks)
PARSE VAR FullName v1 v2 v3 will give
   v1 = 'Jean'
   v2 = 'Pierre'
   v3 = ' Cabanié'
while PARSE VAR FullName v1 v2 v3 . (notice the trailing dot) gives
   v1 = 'Jean'
   v2 = 'Pierre'
   v3 = 'Cabanié'

PARSE VALUE 'AAA  BBB  CCC / DDD  EEE' WITH a b c '/' d e gives
   a = 'AAA', b = 'BBB', C = ' CCC ', D = 'DDD', e = ' EEE'  and ...
PARSE VALUE 'AAA  BBB  CCC / DDD' With a b c '/' d gives
   a = 'AAA', b = 'BBB', c = ' CCC ', d = ' DDD'

You can immagine that the last item will receive all what follows the
delimiter (a single space being the default delimiter) while multiple
spaces between two items are conted only as one space and that putting
something into quotes will split the input string into substrings wich
are then parsed using the previous scheme :
  ' CCC ' is the last item of the first substring in both examples
  while ' EEE' is the last item of the second substring in the first ex.
    and ' DDD' is the last in the second example.

PARSE VALUE 'AAA  BBB  CCC . / DDD  EEE' WITH a b c . '/' d e . and
PARSE VALUE 'AAA  BBB  CCC . / DDD'      WITH a b c . '/' d .  will give
  a = 'AAA', b = 'BBB', c = 'CCC' etc. all without any space in them.

3/Using numeric patterns
  A numeric pattern is used to identify the character position at which
the splitting must occur. It can be expressed in two ways :
  - absolute : the numeric value is left alone or preceded by an equal sign
  - relative : the numeric value is preceded by a plus or minus sign.
The absolute positionning is usefull when reading formatted data.
The relative positionning can be used to extract partial character data
form words.

string = 'astronomers'
          123456789.1

parse var string 2 v1  4 1 v2  2 4 v3  5 11 v4    or
parse var string 2 v1 +2 1 v2 +1 4 v3 +1 11 v4
will lead Say string 'study' v1 || v2 || v3 || v4 to display
              astronomers study stars

Note that in such paterns, it is possible to make a backout of the
parsing to exploit twice the same data. this can be usefull when
it is needed to perform multiple assignments :
PARSE VALUE '123' WITH x 1 y  will give the value 123 at x AND at y.

The nicest stuff : variable patterns.
 All the parsing delimiters (string or numeric) can be defined with
variables : then the used variable must be enclosed into parenthesis.
If the parenthesis is preceded by an equal, plus or minus sign, then the
enclosed variable must hold an integer value.
suppose date contains 05/03/95, a way of parsing can be
  parse var date month 3 delim +1 day +2 (delim) year
  making month = 5, day = 3 and year = 95

Notice that word parsing occurs AFTER the language processor divides the
source string into substrings using patterns. Therefore you should use
for example :
  dataline = 12 26 .....Samuel ClemensMark Twain
  parse var dataline pos1 pos2 6 =(pos1) realname =(pos2) pseudonym
in order to assign "Samuel Clemens" to realname and "Mark Twain" to
pseudonym. Without the 6, the =(pos1) would not have been interpreted
as =12 before the parsing of the second part is done...
--- IMHO this is a little bit tricky BTW ---

More tricky : the case where absolute and relative positional patterns
don't give the same results :
A SEQUENCE string pattern - Variable Name - relative positional pattern
DOESN'T SKIP OVER THE MATCHING STRING PATTERN : a relative positional
pattern moves relative to the first character matching a string pattern

string = 'REstructured eXtended eXecutor'
parse var string v1 3 junk 'X' v2 +1 junk 'X' v3 +1 junk
    123
    REstructured eXtended eXecutor
       <--junk---> <-junk-> <-junk
    Say v1 || v2 || v3 will display REXX !!!

(I never used such a construct in any program I remember of... )



Using Parse to supply a default value. I'm quite sure that this is very
efficient :


Say 'Give Start Stop <step>'
Pull start stop step
/* standard way */               !  /* using parse */
if step = '' then step = 1       !  Parse value step '1' With Step .
do i = Start to Stop by Step ...

I'm convinced that in that case, avoiding an IF processing improves
performance.


Hope this was something you asked for...

Jean-Pierre Cabanié


