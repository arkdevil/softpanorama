From ankh.iia.org!babbage.ece.uc.edu!news.kei.com!bloom-beacon.mit.edu!cambridge-news.cygnus.com!news.cygnus.com!tege Thu Nov 24 18:53:50 1994
Newsgroups: comp.sys.intel
Path: ankh.iia.org!babbage.ece.uc.edu!news.kei.com!bloom-beacon.mit.edu!cambridge-news.cygnus.com!news.cygnus.com!tege
From: tege@cygnus.com (Torbjorn Granlund)
Subject: FDIV test program
Message-ID: <CzGBor.8w6@cygnus.com>
Sender: news@cygnus.com
Nntp-Posting-Host: cygnus.com
Organization: Cygnus Support
Date: Fri, 18 Nov 1994 07:05:14 GMT
Lines: 123

In the light of the floating point division problems with a popular chip, I
wrote a little program to evaluate the accuracy of floating point
operations.  Note that the programs uses random numbers as input, and does
not know anything about problems with any specific chips...

People that think the disputed bug is unimportant might want to try this
program and see how long it takes before it barfs.  Oops...!

Torbjorn Granlund



/* Program to test accuracy of floating point arithmetic.  */

#if defined (__svr4__) || defined (__hpux) || defined (__alpha)
#define random mrand48
#endif

#if defined (__i386__) || defined (__vax__) || defined (MIPSEL)
#define WORDS_LITTLE_ENDIAN 1
#else
#define WORDS_LITTLE_ENDIAN 0
#endif

typedef union
{
  double d;
  struct
    {
#if WORDS_LITTLE_ENDIAN
      unsigned int l, h;
#else
      unsigned int h, l;
#endif
    } ii;
} dbl_extract_t;

unsigned int
random_bitstring ()
{
  unsigned int x;
  unsigned int ran, n_bits;
  int tot_bits = 8 * sizeof (int) + 6;

  x = 0;
  for (;;)
    {
      ran = random ();
      n_bits = (ran >> 1) % 16;

      if (n_bits == 0)
	break;

      x <<= n_bits;
      if (ran & 1)
	x |= (1 << n_bits) - 1;

      tot_bits -= n_bits;
      if (tot_bits < 0)
	break;
    }
  return x;
}

main ()
{
  dbl_extract_t x, y;
  unsigned int h;
  int xexp, yexp, qexp;
  unsigned long reps, errs;
  double xd, yd, q, p, res;

  for (reps = 0; reps < 1000000;)
    {
      do
	{
	  do
	    {
	      x.ii.h = h = random_bitstring ();
	      x.ii.l = random_bitstring ();
	      xexp = (h >> 20) & 0x7ff;
	    }
	  while (xexp < 1 || xexp >= 0x7fe);
	  do
	    {
	      y.ii.h = h = random_bitstring ();
	      y.ii.l = random_bitstring ();
	      yexp = (h >> 20) & 0x7ff;
	    }
	  while (yexp < 1 || yexp >= 0x7fe);
	  qexp = xexp - yexp + 0x3ff;
	}
      while (qexp < 1 || qexp >= 0x7ff);
      reps++;
      xd = x.d;
      yd = y.d;
      q = xd / yd;
      p = q * yd;
      res = p / xd - 1.0;
      if (res < -2.22044604925032e-16 || res > 2.22044604925032e-16)
	{
	  printf ("%.10g / %.16g gives error of %.16g (test #%lu)\n",
		  xd, yd, res, reps);
	  errs++;
	}
    }

  if (errs == 0)
    {
      printf ("no errors found after %u iterations\n", reps);
      exit (0);
    }
  else
    {
      printf ("%u error%s found after %u iterations\n",
	      errs, "s"[errs == 1], reps);
      exit (1);
    }
}

-- 
Torbjorn Granlund
(tege@cygnus.com)

From ankh.iia.org!uunet!bloom-beacon.mit.edu!cambridge-news.cygnus.com!news.cygnus.com!nntp!tege Thu Nov 24 18:54:07 1994
Newsgroups: comp.sys.intel
Path: ankh.iia.org!uunet!bloom-beacon.mit.edu!cambridge-news.cygnus.com!news.cygnus.com!nntp!tege
From: tege@cygnus.cygnus.com (Torbjorn Granlund)
Subject: Re: FDIV test program
In-Reply-To: tege@cygnus.com's message of Fri, 18 Nov 1994 07:05:14 GMT
Message-ID: <TEGE.94Nov17235502@cygnus.cygnus.com>
Sender: news@cygnus.com
Nntp-Posting-Host: cygnus.com
Organization: Cygnus Support, Mt View
References: <CzGBor.8w6@cygnus.com>
Date: Fri, 18 Nov 1994 07:55:02 GMT
Lines: 112

There was a little typo in that program.  Here is a new attempt...

/* Program to test accuracy of floating point arithmetic.  */

#if defined (__svr4__) || defined (__hpux) || defined (__alpha)
#define random mrand48
#endif

#if defined (__i386__) || defined (__vax__) || defined (MIPSEL)
#define WORDS_LITTLE_ENDIAN 1
#else
#define WORDS_LITTLE_ENDIAN 0
#endif

typedef union
{
  double d;
  struct
    {
#if WORDS_LITTLE_ENDIAN
      unsigned int l, h;
#else
      unsigned int h, l;
#endif
    } ii;
} dbl_extract_t;

unsigned int
random_bitstring ()
{
  unsigned int x;
  unsigned int ran, n_bits;
  int tot_bits = 8 * sizeof (int) + 6;

  x = 0;
  for (;;)
    {
      ran = random ();
      n_bits = (ran >> 1) % 16;

      if (n_bits == 0)
	break;

      x <<= n_bits;
      if (ran & 1)
	x |= (1 << n_bits) - 1;

      tot_bits -= n_bits;
      if (tot_bits < 0)
	break;
    }
  return x;
}

main ()
{
  dbl_extract_t x, y;
  unsigned int h;
  int xexp, yexp, qexp;
  unsigned long reps, errs;
  double xd, yd, q, p, res;

  for (reps = 0; reps < 1000000;)
    {
      do
	{
	  do
	    {
	      x.ii.h = h = random_bitstring ();
	      x.ii.l = random_bitstring ();
	      xexp = (h >> 20) & 0x7ff;
	    }
	  while (xexp < 1 || xexp >= 0x7fe);
	  do
	    {
	      y.ii.h = h = random_bitstring ();
	      y.ii.l = random_bitstring ();
	      yexp = (h >> 20) & 0x7ff;
	    }
	  while (yexp < 1 || yexp >= 0x7fe);
	  qexp = xexp - yexp + 0x3ff;
	}
      while (qexp < 1 || qexp >= 0x7ff);
      reps++;
      xd = x.d;
      yd = y.d;
      q = xd / yd;
      p = q * yd;
      res = p / xd - 1.0;
      if (res < -2.22044604925032e-16 || res > 2.22044604925032e-16)
	{
	  printf ("%.10g / %.16g gives error of %.16g (test #%lu)\n",
		  xd, yd, res, reps);
	  errs++;
	}
    }

  if (errs == 0)
    {
      printf ("no errors found after %u iterations\n", reps);
      exit (0);
    }
  else
    {
      printf ("%u error%s found after %u iterations\n",
	      errs, "s" + (errs == 1), reps);
      exit (1);
    }
}
--
Torbjorn Granlund
(tege@cygnus.com)

From ankh.iia.org!uunet!usc!bloom-beacon.mit.edu!cambridge-news.cygnus.com!news.cygnus.com!nntp!tege Thu Nov 24 18:54:29 1994
Newsgroups: comp.sys.intel
Path: ankh.iia.org!uunet!usc!bloom-beacon.mit.edu!cambridge-news.cygnus.com!news.cygnus.com!nntp!tege
From: tege@rtl.cygnus.com (Torbjorn Granlund)
Subject: Re: FDIV test program
In-Reply-To: tege@cygnus.cygnus.com's message of Fri, 18 Nov 1994 07:55:02 GMT
Message-ID: <TEGE.94Nov18182132@rtl.cygnus.com>
Sender: news@cygnus.com
Nntp-Posting-Host: rtl.cygnus.com
Organization: Cygnus Support, Mt View
References: <CzGBor.8w6@cygnus.com> <TEGE.94Nov17235502@cygnus.cygnus.com>
Date: Sat, 19 Nov 1994 02:21:32 GMT
Lines: 118


Let me make a final attempt before I get more mail...  The last version had
an uninitialized variable, and therefore would report an incorrect error
count.

Compile this, and see the FPU make 1 error/second with your Pentium chip!


/* Program to test accuracy of floating point arithmetic.  */

#if defined (__svr4__) || defined (__hpux) || defined (__alpha)
#define random mrand48
#endif

#if defined (__i386__) || defined (__vax__) || defined (MIPSEL)
#define WORDS_LITTLE_ENDIAN 1
#else
#define WORDS_LITTLE_ENDIAN 0
#endif

typedef union
{
  double d;
  struct
    {
#if WORDS_LITTLE_ENDIAN
      unsigned int l, h;
#else
      unsigned int h, l;
#endif
    } ii;
} dbl_extract_t;

unsigned int
random_bitstring ()
{
  unsigned int x;
  unsigned int ran, n_bits;
  int tot_bits = 8 * sizeof (int) + 6;

  x = 0;
  for (;;)
    {
      ran = random ();
      n_bits = (ran >> 1) % 16;

      if (n_bits == 0)
	break;

      x <<= n_bits;
      if (ran & 1)
	x |= (1 << n_bits) - 1;

      tot_bits -= n_bits;
      if (tot_bits < 0)
	break;
    }
  return x;
}

main ()
{
  dbl_extract_t x, y;
  unsigned int h;
  int xexp, yexp, qexp;
  unsigned long reps, errs = 0;
  double xd, yd, q, p, res;

  for (reps = 0; reps < 1000000;)
    {
      do
	{
	  do
	    {
	      x.ii.h = h = random_bitstring ();
	      x.ii.l = random_bitstring ();
	      xexp = (h >> 20) & 0x7ff;
	    }
	  while (xexp < 1 || xexp >= 0x7fe);
	  do
	    {
	      y.ii.h = h = random_bitstring ();
	      y.ii.l = random_bitstring ();
	      yexp = (h >> 20) & 0x7ff;
	    }
	  while (yexp < 1 || yexp >= 0x7fe);
	  qexp = xexp - yexp + 0x3ff;
	}
      while (qexp < 1 || qexp >= 0x7ff);
      reps++;
      xd = x.d;
      yd = y.d;
      q = xd / yd;
      p = q * yd;
      res = p / xd - 1.0;
      if (res < -2.22044604925032e-16 || res > 2.22044604925032e-16)
	{
	  printf ("%.10g / %.16g gives error of %.16g (test #%lu)\n",
		  xd, yd, res, reps);
	  errs++;
	}
    }

  if (errs == 0)
    {
      printf ("no errors found after %lu iterations\n", reps);
      exit (0);
    }
  else
    {
      printf ("%lu error%s found after %lu iterations\n",
	      errs, "s" + (errs == 1), reps);
      exit (1);
    }
}
--
Torbjorn Granlund
(tege@cygnus.com)

