From ankh.iia.org!uunet!spool.mu.edu!uwm.edu!lll-winken.llnl.gov!trib.apple.com!amd!netcomsv!vitsemi!coe Thu Nov 24 18:13:24 1994
Newsgroups: comp.sys.intel,comp.arch,comp.arch.arithmetic
Path: ankh.iia.org!uunet!spool.mu.edu!uwm.edu!lll-winken.llnl.gov!trib.apple.com!amd!netcomsv!vitsemi!coe
From: coe@vitsemi.com (Tim Coe)
Subject: Re: Glaring FDIV bug in Pentium!
Message-ID: <1994Nov16.195312.10362@vitsemi.com>
Sender: coe@vitsemi.com (Tim Coe)
Organization: Vitesse Semiconductor
Date: Wed, 16 Nov 94 19:53:12 GMT
Lines: 309
Xref: ankh.iia.org comp.sys.intel:9474 comp.arch:6760 comp.arch.arithmetic:196

Much of the following explanation was previously
posted to comp.sys.intel.  A more complete tentative
software model of the Pentium divider that explains
all divide errors that I am aware of is included with
this post.

On a Packard Bell P90 PC I performed the following
calculation using Microsoft Windows Desk Calculator:

(4195835 / 3145727) * 4195835

The result was 4195579.
This represents an error of 256 or one part in ~16000.

ak@ananke.s.bawue.de (Andreas Kaiser) writes
>Usually, the division is correct (what did you expect?). Just a few
>operands are divided wrong. My results (P90) with ~25.000.000.000
>random arguments (within 1..2^46), with even results divided by two
>until odd, to assure unique mantissa patterns (the binary exponent
>doesn't care, of course).
>
>          3221224323
>         12884897291
>        206158356633
>        824633702441
>       1443107810341
>       6597069619549
>       9895574626641
>      13194134824767
>      13194134826115
>      13194134827143
>      13194134827457
>      13194138356107
>      13194139238995
>      26388269649885
>      26388269650425
>      26388269651561
>      26388276711601
>      26388276712811
>      52776539295213
>      52776539301125
>      52776539301653
>      52776539307823
>      52776553426399
>
>      Gruss, Andreas
>      
>--------------------
>-- Andreas Kaiser -- internet: ak@ananke.s.bawue.de
>-------------------- fidonet:  2:246/8506.9

Analysis of these numbers reveals that all but 2 of them are of
the form:

3*(2^(K+30)) - 1149*(2^(K-(2*J))) - delta*(2^(K-(2*J)))

where J and K are integers greater than or equal to 0,
and delta is a real number that has varying ranges depending
on J but can generally be considered to be between 0 and 1.

The 2*J terms in the above equation leads to the conclusion
that the Pentium divider is an iterative divider that computes
2 bits of quotient per cycle.  (This is in agreemnent with
the quoted 39 cycles per extended long division from the
Pentium data book.  The technical name for this type of
divider is radix 4)

The extremely low probability of error (1 in 10^10) implies
that the remainder is being held in carry save format.  (Carry
save format is where a number is represented as the sum of
two numbers.  This format allows next remainder calculation
to occur without propagating carries.  The reason that carry
save format is implied by the error probability is that
it is very difficult but not impossible to build up long
coincident sequences of ones in both the sum word and the
carry word.)

I assumed the digit set was -2, -1, 0, 1, and 2.  (Having
5 possible digits in a radix 4 divider allows a necessarry
margin for error in next digit selection.  When doing long
division by hand the radix 10 and 10 possible digits allow
no margin for error.)

Taking the above into consideration I wrote the tentative
model of Pentium divide hardware included below so that I
might watch what bit patterns developed in the remainder.
After running the numbers that were known to fail and numbers
near them that appeared not to fail I determined the
conditions for failure listed in the program.

Analysis of the precise erroneous results returned on the
bad divides indicates that a bit (or bits) is being subtracted
from the remainder at or near its most significant bit.
A modeling of this process is included in the program.

The program accurately explains all the published
errors and accurately predicted the error listed at the
beginning of the article.

The determination of the quotient from the sequence of digits
is left as an exercise for the reader ;-).

I would like to thank Dr. Nicely for providing this window
into the Pentium architecture.

-Tim Coe     coe@vitsemi.com

An example run of the program (using the first reported
error):

---Enter dividend mantissa in hex: 8 <return>
---Enter divisor  mantissa in hex: bfffffb829 <return>
---next digit 1
---1111000000000000000000000001000111110101101111111111111111111100
---0000000000000000000000000000000000000000000000000000000000000100
---11110000000000000000000000010001 iteration number 1
---.
---.
---.
---next digit -1
---0011111111100100101011110100110000010111010000000000000000000000
---1101111111111111111110110110010010010000000000000000000000000000
---00011111111001001010101010110000 iteration number 14
---next digit 2
---A bug condition has been detected.
---Enter 0 for correct result or 1 for incorrect result: 1 <return>
---0000000001101101010100001000000111110110011111111111111111111100
---1111111100100101010110100110010010010010000000000000000000000100
---11111111100100101010101011100101 iteration number 15
---next digit 0
---1111110100100000001010111001010110010001111111111111111111100000
---0000000100101010100000000000010010010000000000000000000000100000
---11111110010010101010101110011001 iteration number 16
---.
---.
---.

#include <stdio.h>

main()
{
unsigned r0, r1, r2, r3, r4, r5, r6, s0, s1;
unsigned t0, t1, t2, t3, cycle, f, incorrect;
unsigned thr_m2_m1, thr_m1_0, thr_0_1, thr_1_2, positive, errornum;
char line[30], *linepoint;

r0 = 0x0bffffc0;
r1 = 0;
r2 = 0x0800bf60;
r3 = 0;
printf("Enter dividend mantissa in hex: ");
scanf("%s", line);
linepoint = line;
while (*linepoint != '\0') linepoint++;
while (linepoint < line + 15) *linepoint++ = '0';
*(line+15) = '\0';
sscanf(line+7, "%x", &r3);
*(line+7) = '\0';
sscanf(line, "%x", &r2);
printf("Enter divisor  mantissa in hex: ");
scanf("%s", line);
linepoint = line;
while (*linepoint != '\0') linepoint++;
while (linepoint < line + 15) *linepoint++ = '0';
*(line+15) = '\0';
sscanf(line+7, "%x", &r1);
*(line+7) = '\0';
sscanf(line, "%x", &r0);
r4 = 0;
r5 = 0;

    /*  These thresholds are VERY tentative. */
    /*  There may be bugs in them.           */
t0 = r0 >> 22;
    /*  Next threshold is strongly indicated */
    /*  by the failure of 9895574626641      */
if (t0 < 36) thr_0_1 = 3;
    /*  Next threshold is strongly indicated */
    /*  by the failure of 824633702441       */
else if (t0 < 48) thr_0_1 = 4;
else if (t0 < 56) thr_0_1 = 5;
else thr_0_1 = 6;
thr_m1_0 = 254 - thr_0_1;
if (t0 < 33) thr_1_2 = 11;
else if (t0 < 34) {
  printf("This model does not correctly handle\n");
  printf("this divisor.  The Pentium divider\n");
  printf("undoubtly handles this divisor correctly\n");
  printf("by some means that I have no evidence\n");
  printf("upon which speculate.\n");
  exit();
  }
else if (t0 < 36) thr_1_2 = 12;
else if (t0 < 39) thr_1_2 = 13;
    /*  Next threshold is strongly indicated */
    /*  by the failure of 1443107810341      */
else if (t0 < 42) thr_1_2 = 14;
else if (t0 < 44) thr_1_2 = 15;
else if (t0 < 48) thr_1_2 = 16;
else if (t0 < 54) thr_1_2 = 18;
else if (t0 < 60) thr_1_2 = 20;
else thr_1_2 = 23;
thr_m2_m1 = 254 - thr_1_2;

    /*  Further error conditions may exist.  */
    /*  I believe they could be accom-       */
    /*  adated by adding conditions to the   */
    /*  following clause.                    */
if (t0 == 35) errornum = 22;
else if (t0 == 41) errornum = 26;
else if (t0 == 47) errornum = 30;
else errornum = 128;

incorrect = 0;
cycle = 1;
    /*  The cycle count was chosen to keep   */
    /*  the errors on my 60 line screen and  */
    /*  would be 33 or 34 for extended long. */
while (cycle < 27) {
  t0 = 255 & ((r2 >> 24) + (r4 >> 24));
  if ((t0 > thr_m1_0) || (t0 < thr_0_1)) {
    s0 = 0;
    s1 = 0;
    positive = 0;
    printf("next digit 0\n");
    }
  else if (t0 > thr_m2_m1) {
    s0 = r0;
    s1 = r1;
    positive = 0;
    printf("next digit -1\n");
    }
  else if (t0 < thr_1_2) {
    s0 = ~r0;
    s1 = ~r1;
    positive = 4;
    printf("next digit 1\n");
    }
  else if (t0 & 128) {
    s0 = (r0 << 1) | (r1 >> 31);
    s1 = r1 << 1;
    positive = 0;
    printf("next digit -2\n");
    }
  else {
    s0 = ~((r0 << 1) | (r1 >> 31));
    s1 = ~(r1 << 1);
    positive = 4;
    printf("next digit 2\n");
    if ((t0 == errornum) && (((r2 >> 21) & 7) == 7) && (((r4 >> 21) & 7) == 7)) {
      printf("A bug condition has been detected.\n");
      printf("Enter 0 for correct result or 1 for incorrect result: ");
      scanf("%d", &incorrect);
      if (incorrect) {
        if (errornum == 22) s0 = s0 - (3 << 25);
        else s0 = s0 - (4 << 25);
        }
      }
    }

  t0 = s0 ^ r2 ^ r4;
  t1 = s1 ^ r3 ^ r5;
  t2 = (s0 & r2) | (s0 & r4) | (r2 & r4);
  t3 = (s1 & r3) | (s1 & r5) | (r3 & r5);
  r2 = (t0 << 2) | (t1 >> 30);
  r3 = t1 << 2;
  r4 = (t2 << 3) | (t3 >> 29);
  r5 = (t3 << 3) | positive;

  t0 = r2;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  t0 = r3;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  putchar('\n');
  t0 = r4;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  t0 = r5;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  putchar('\n');
  t0 = r2 + r4;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  printf(" iteration number %d\n", cycle++);
  }
}

From ankh.iia.org!ralph.vnet.net!news.sprintlink.net!howland.reston.ans.net!agate!trib.apple.com!amd!netcomsv!vitsemi!coe Thu Nov 24 18:17:16 1994
Newsgroups: comp.sys.intel,comp.arch,comp.arch.arithmetic
Path: ankh.iia.org!ralph.vnet.net!news.sprintlink.net!howland.reston.ans.net!agate!trib.apple.com!amd!netcomsv!vitsemi!coe
From: coe@vitsemi.com (Tim Coe)
Subject: Re: Glaring FDIV bug in Pentium!
Message-ID: <1994Nov21.013703.14756@vitsemi.com>
Sender: coe@vitsemi.com (Tim Coe)
Organization: Vitesse Semiconductor
Date: Mon, 21 Nov 94 01:37:03 GMT
Lines: 330
Xref: ankh.iia.org comp.sys.intel:9729 comp.arch:6832 comp.arch.arithmetic:204

In article <3afuk5$mco@ibm32.perftech.com>, herb@perftech.com (Herb Savage) says:
>In article <CzE242.C4@cwi.nl>, dik@cwi.nl (Dik T. Winter) says:
>>
>>Not seen the original, but:
>> > In article <1994Nov16.195312.10362@vitsemi.com>,
>> > Tim Coe <coe@vitsemi.com> wrote:
>> > >(4195835 / 3145727) * 4195835
                            ^^^^^^^
Oops.  The number I actually entered on the Pentium was 3145727.
I didn't check what I said as I was writing the post.

>> > >
>> > >The result was 4195579.
>> > >This represents an error of 256 or one part in ~16000.
>> > 
>>I would say the error is much larger as the correct result is about 5596491.
>>I think you intended: (4195835 / 3145727) * 3145727.  But in that case the
>>result tends to show 11 digits intermediate precision.
>
>On my Pentium 4195835 / 3145727 is  1.333739068902
>on a 486      4195835 / 3145727 is  1.333820449136
>
>It looks like a lot less than 11 digits of intermediate precision to me.

Since then I performed the following calculations in Microsoft
Windows Desk Calculator on a Pentium machine with the following
results:

(41.999999/35.9999999)*35.9999999 - 41.999999  ==>  (-0.75)*(2^-13)
(48.999999/41.9999999)*41.9999999 - 48.999999  ==>  (-1.0)*(2^-13)
(55.999999/47.9999999)*47.9999999 - 55.999999  ==>  (-1.0)*(2^-13)
(62.999999/53.9999999)*53.9999999 - 62.999999  ==>  (-1.0)*(2^-13)
(54.999999/59.9999999)*59.9999999 - 54.999999  ==>  (-1.0)*(2^-13)
(5244795/3932159)*3932159 - 5244795            ==>  (-1.0)*(2^8)

I chose these calculations in anticipation of them exposing further
Pentium FDIV failure modes.  They did.  The size of the erroneous results
are exactly consistant with the final version of tentive Pentium
divider model included below and in no way can be attributed to
a Desk Calculator bug.  The existance of these results pins
most of the digit selection thresholds included in the model.

I also performed the following calculations that did NOT produce erroneous
results:

(38.499999/32.9999999)*32.9999999 - 38.499999  ==>  0
(45.499999/38.9999999)*38.9999999 - 45.499999  ==>  0

I have been following this thread with great interest.  One misperception
that needs clearing is that this is an extended precision problem.  This
bug hits between 50 and 2000 single precision dividend divisor pairs (out
of a total of 64 trillion.)  Another misperception is related to the magnitude
of the relative error.  I would propose the following table of probabilities
of getting the following relative errors when performing random double
extended precision divides:

relerror = (correct_result - Pentium_result)/correct_result

Error Range                 |   Probability
-------------------------------------------
1e-4 < relerror             |   0
1e-5 < relerror < 1e-4      |   0.3e-11
1e-6 < relerror < 1e-5      |   0.6e-11
1e-7 < relerror < 1e-6      |   0.6e-11
1e-8 < relerror < 1e-7      |   0.6e-11
.
.
1e-18 < relerror < 1e-17    |   0.6e-11
1e-19 < relerror < 1e-18    |   0.6e-11

Examination of the above divide failures reveals that both the dividend
and divisor are integers minus small deltas.  Also notable is the induced
error is roughly delta^(2/3).  The integers in the divisors are actually
restricted to those listed and their binary scalings.  The integers in
the dividends may be much more freely chosen.  This type of dividend
divisor pair actually occurs quite often when forward integrating
trajectories off metastable points.  This is because metastable points
in systems often have certain exactly integral characteristics and as
a path diverges from the metastable point these characteristics slowly diverge
from their integral values.  If the forward integration algorithm
happens to divide these characteristics, and they happen to be for
example 7 and 3, it will get nailed.

The divider model includes support for up to 60 bits of divisor and
up to 64 bits of dividend.  The last four bits of dividend are kludged
in.

Here is a list of failing dividend divisor mantissas in hex.  A dash
between two numbers indicates an inclusive failing range.  Compile
the program and run these numbers through it and watch the bits dance:

800bf6 bffffc
a00ef6 effffc

a808d2 8fffe
e00bd2 bfffe

a7ffd2 8fffe
c3ffd2 a7ffe
dfffd2 bfffe
fbffd2 d7ffe

f9ffdc7 efffe

b9feab7-b9feabf 8fff
b9ffab0e-b9ffab7f 8fffc

-the following double extended pair fails 3 times!!!
c3ffd2eb0d2eb0d2 a7ffe
e00bd229315 bfffe

9fffef5-9fffeff effff4
9ffff21-9ffff3f effff8
9ffff4d-9ffff7f effffc

f008e35-f008e3f 8ffff4
f008e6d-f008e7f 8ffff6
f008ea1-f008ebf 8ffff8
f008ed9-f008eff 8ffffa
f008f0d-f008f3f 8ffffc
f008f45-f008f7f 8ffffe
f008f7e 8ffffff1
f0023e 8fffff8

effff0d 8ffffc

a808d1b-a808d3f 8fffe
a808d67-a808d7f 8fffe4
a808db3-a808dbf 8fffe8
a808dff 8fffec

-Tim Coe  coe@vitsemi.com

#include <stdio.h>

main()
{
unsigned r0, r1, r2, r3, r4, r5, r6, s0, s1;
unsigned t0, t1, t2, t3, cycle, f, incorrect, spup;
unsigned thr_m2_m1, thr_m1_0, thr_0_1, thr_1_2, positive, errornum;
char line[30], *linepoint;

r0 = 0x0bffffc0;
r1 = 0;
r2 = 0x0800bf60;
r3 = 0;
printf("First digit of mantissas must be between 8 and f\n");
printf("Enter dividend mantissa in hex: ");
*(line+15) = '0';
scanf("%s", line);
linepoint = line;
while (*linepoint != '\0') linepoint++;
while (linepoint < line + 15) *linepoint++ = '0';
*(line+16) = '\0';
sscanf(line+15, "%x", &spup);
spup = (spup >> 2) | (12 & (spup << 2));
*(line+15) = '\0';
sscanf(line+7, "%x", &r3);
*(line+7) = '\0';
sscanf(line, "%x", &r2);
printf("Enter divisor  mantissa in hex: ");
scanf("%s", line);
linepoint = line;
while (*linepoint != '\0') linepoint++;
while (linepoint < line + 15) *linepoint++ = '0';
*(line+15) = '\0';
sscanf(line+7, "%x", &r1);
*(line+7) = '\0';
sscanf(line, "%x", &r0);
r4 = 0;
r5 = 0;

t0 = r2;
while (!(t0 & 1)) t0 = t0 >> 1;
printf("%d\n", t0);
t0 = r0;
while (!(t0 & 1)) t0 = t0 >> 1;
printf("%d\n", t0);

    /*  These thresholds are VERY tentative. */
    /*  There may be bugs in them.           */
t0 = r0 >> 22;
    /*  Next threshold is strongly indicated */
    /*  by the failure of 1/9895574626641    */
if (t0 < 36) thr_0_1 = 3;
    /*  Next threshold is strongly indicated */
    /*  by the failure of 1/824633702441     */
else if (t0 < 48) thr_0_1 = 4;
    /*  Next threshold is strongly indicated */
    /*  by the failure of 5244795/3932159    */
else if (t0 < 60) thr_0_1 = 5;
else thr_0_1 = 6;
thr_m1_0 = 254 - thr_0_1;
if (t0 < 33) thr_1_2 = 11;
else if (t0 < 34) {
  printf("This model does not correctly handle\n");
  printf("this divisor.  The Pentium divider\n");
  printf("undoubtly handles this divisor correctly\n");
  printf("by some means that I have no evidence\n");
  printf("upon which speculate.\n");
  exit();
  }
    /*  Next threshold is strongly indicated     */
    /*  by the failure of 41.999999/35.9999999   */
else if (t0 < 36) thr_1_2 = 12;
else if (t0 < 39) thr_1_2 = 13;
    /*  Next threshold is strongly indicated     */
    /*  by the failure of 1/1443107810341 and    */
    /*  by the failure of 48.999999/41.9999999   */
else if (t0 < 42) thr_1_2 = 14;
else if (t0 < 44) thr_1_2 = 15;
    /*  Next threshold is strongly indicated     */
    /*  by the failure of 55.999999/47.9999999   */
else if (t0 < 48) thr_1_2 = 16;
    /*  Next threshold is strongly indicated     */
    /*  by the failure of 62.999999/53.9999999   */
else if (t0 < 54) thr_1_2 = 18;
    /*  Next threshold is strongly indicated     */
    /*  by the failure of 54.999999/59.9999999   */
else if (t0 < 60) thr_1_2 = 20;
else thr_1_2 = 23;
thr_m2_m1 = 254 - thr_1_2;

if (t0 == 35) errornum = 22;
else if (t0 == 41) errornum = 26;
else if (t0 == 47) errornum = 30;
else if (t0 == 53) errornum = 34;
else if (t0 == 59) errornum = 38;
else errornum = 128;

incorrect = 0;
cycle = 1;
    /*  The cycle limit would be ~34 instead of  */
    /*  12 for double extended precision.        */
while (cycle < 12) {
  t0 = 255 & ((r2 >> 24) + (r4 >> 24));
  if ((t0 > thr_m1_0) || (t0 < thr_0_1)) {
    s0 = 0;
    s1 = 0;
    positive = 0;
    printf("next digit 0\n");
    }
  else if (t0 > thr_m2_m1) {
    s0 = r0;
    s1 = r1;
    positive = 0;
    printf("next digit -1\n");
    }
  else if (t0 < thr_1_2) {
    s0 = ~r0;
    s1 = ~r1;
    positive = 4;
    printf("next digit 1\n");
    }
  else if (t0 & 128) {
    s0 = (r0 << 1) | (r1 >> 31);
    s1 = r1 << 1;
    positive = 0;
    printf("next digit -2\n");
    }
  else {
    s0 = ~((r0 << 1) | (r1 >> 31));
    s1 = ~(r1 << 1);
    positive = 4;
    printf("next digit 2\n");
    if ((t0 == errornum) && (((r2 >> 21) & 7) == 7) && (((r4 >> 21) & 7) == 7)) {
      printf("A bug condition has been detected.\n");
      printf("Enter 0 for correct result or 1 for incorrect result: ");
      scanf("%d", &incorrect);
      if (incorrect) {
            /* These amounts that are subtracted from the    */
            /* remainder have NOT been extensively verified. */
        if (errornum == 22) s0 = s0 - (3 << 25);
        else s0 = s0 - (4 << 25);
        }
      }
    }

  t0 = s0 ^ r2 ^ r4;
  t1 = s1 ^ r3 ^ r5;
  t2 = (s0 & r2) | (s0 & r4) | (r2 & r4);
  t3 = (s1 & r3) | (s1 & r5) | (r3 & r5);
  r2 = (t0 << 2) | (t1 >> 30);
  r3 = t1 << 2;
  r4 = (t2 << 3) | (t3 >> 29);
  r5 = (t3 << 3) | positive | (spup & 3);
  spup = spup >> 2;

  t0 = r2;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  t0 = r3;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  putchar('\n');
  t0 = r4;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  t0 = r5;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  putchar('\n');
  t0 = r2 + r4;
  f = 32;
  while (f--) {
    if (t0 & (1 << 31)) putchar('1');
    else putchar('0');
    t0 = t0 << 1;
    }
  printf(" iteration number %d\n", cycle++);

  }
}


