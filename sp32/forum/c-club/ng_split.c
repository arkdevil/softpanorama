/************************************************************************/
/*									*/
/*	ng_split - splits Norton Guides database into components	*/
/*									*/
/************************************************************************/
/*									*/
/*	ng_split, Copyright (C) 1988, by John C. Gordon			*/
/*	Norton Guides Splitter, 12 August 1988, ALL RIGHTS RESERVED	*/
/*									*/
/*	This program is meant for those of us who bought the Norton	*/
/*	Guides and were disappointed by the fact that we couldn't	*/
/*	modify the databases provided for our own purposes (by making	*/
/*	the fatal assumption that "customizing the Guides" included	*/
/*	the ability to customize the published databases).		*/
/*									*/
/*	I have been able to take the databases provided in the Guides,	*/
/*	"un-compile" (split) them into their component parts, and	*/
/*	then re-compile them back into a database using the NGC and	*/
/*	NGML utilities provided with the Guides.  The resulting		*/
/*	database is identical to the original using DOS 'comp'		*/
/*	(except for a six-character difference in the Microsoft C	*/
/*	database, which does not affect execution).			*/
/*									*/
/*	I have tested this program on the Norton Guides for Turbo C	*/
/*	Microsoft C.  Others have tested it on the other published	*/
/*	databases and some public domain ones.  If you find that it	*/
/*	does not work for some database, I will be glad to look at	*/
/*	the code to see if I can get it to work.  I will need a copy	*/
/*	of the database file, however (only for debugging - the		*/
/*	disk(s) will be returned with a copy of the new program).	*/
/*									*/
/*	There are some funny file formats possible which NG_SPLIT	*/
/*	doesn't handle right now.  They will be corrected in V2.0 in	*/
/*	a couple of months.  They do not appear in any of Norton's	*/
/*	databases (as far as I know), but they can be created by the	*/
/*	NG software.  Please send me a copy of anything that NG_SPLIT	*/
/*	can't handle, so I can make sure that everything is covered.	*/
/*	Included in V2 or V3 will be a utility to re-write the funny	*/
/*	source code into something more reasonable, since usually the	*/
/*	strange formats mess up the operation of the grey + key.	*/
/*									*/
/*	If you like this program and would like to see more like	*/
/*	it, please contribute whatever you think this program is	*/
/*	worth to you (recommended $5 or $10).  Thank you.		*/
/*									*/
/*			John C. Gordon					*/
/*			Post Office Box 25107				*/
/*			Alexandria, VA  22313-5107			*/
/*									*/
/*			Home phone : (703) 528-2205			*/
/*									*/
/************************************************************************/

/************************************************************************/
/*									*/
/*	ng_split		Version 1.2		12 August 1988	*/
/*									*/
/*	Purpose:	Split a Norton Guides .ng database into		*/
/*			its original component source files		*/
/*									*/
/*	Syntax:		ng_split db_name				*/
/*	Where:		'db_name' = the name of the Norton Guides	*/
/*			database (with or without the .ng suffix)	*/
/*									*/
/*	Restrictions:	1)  The NG database must be located in your	*/
/*			    current working directory.			*/
/*			2)  The database must not be "active" when	*/
/*			    you run ng_split.  You must either		*/
/*			    uninstall the Guides or copy the database	*/
/*			    to a different (work) directory first.	*/
/*			3)  Due to the intensive character I/O, you	*/
/*			    should run from your RAMdisk, if possible.	*/
/*									*/
/*	Remarks:	ng_split will create several files in your	*/
/*			current working directory :			*/
/*									*/
/*		'db_name':	the menu link control file		*/
/*		'db_name'.bat:	a batch file containing the commands	*/
/*			to re-create the database			*/
/*		'dbxx'_000:	the individual source data files are	*/
/*			named 'dbxx'_000 through 'dbxx'_999, depending	*/
/*			on how many files are needed.  Note : 'dbxx'	*/
/*			is the first four characters of 'db_name'.	*/
/*		temp:	a temporary file which is deleted on exit	*/
/*									*/
/*	For example : if you are splitting the Turbo C database tc.ng,	*/
/*		you would use the command:	ng_split tc		*/
/*		which would create files:	tc			*/
/*						tc.bat			*/
/*						tc_000 through tc_011	*/
/*						temp (deleted)		*/
/*									*/
/*	Change history:							*/
/*		V 1.0 - 17 June 88 - original program			*/
/*		V 1.1 - 18 July 88 - allow databases with names longer	*/
/*				than six characters or with more than	*/
/*				26 source files and update docs		*/
/*		V 1.2 - 12 August 88 - fix bug with !short with no data	*/
/*				following it and !file.  also added	*/
/*				status lines and better error messages	*/
/*									*/
/************************************************************************/

/************************************************************************/
/*									*/
/*	Hints on interpreting error messages :				*/
/*									*/
/*	In general, all error messages indicate that NG_SPLIT was	*/
/*	unable to successfully split your database.  In those cases,	*/
/*	I would appreciate it if you could send me a copy of the	*/
/*	database, so I can correct the program.  There are two error	*/
/*	messages, however, which I can do nothing about :		*/
/*									*/
/*	Write error - possibly out of disk space			*/
/*		- this indicates that either you are out of space	*/
/*		  OR your directory cannot hold any more files.		*/
/*									*/
/*	WARNING - Database error					*/
/*		- this one comes up if there is an error in the		*/
/*		  database itself.  It occurs when it is trying to	*/
/*		  locate a !seealso segment and the database contains	*/
/*		  an illegal address.  You can verify this by looking	*/
/*		  at the output file which contains the error and	*/
/*		  searching for the string :		_???.ngo:	*/
/*		  Make note of the name of the faulty !seealso clause	*/
/*		  ( the name in quotes after the colon ) and the name	*/
/*		  of the !short section which contains it ( backward	*/
/*		  search for !short: ).  Next, look at the menu link	*/
/*		  control file ( same name as the database, but without	*/
/*		  the .ng suffix ) and look for the name of the output	*/
/*		  file which contained the error.  Make note of the	*/
/*		  menu heading and the menu item which corresponds to	*/
/*		  that file.  Now, bring up the database and find the	*/
/*		  menu heading and menu item.  Then, look up the name	*/
/*		  of the !short item you located before.  You will	*/
/*		  notice that it has a !seealso item with the faulty	*/
/*		  clause name.  If you try to select that !seealso	*/
/*		  clause, nothing will happen.  I don't know why this	*/
/*		  happens and have only seen it happen in one database	*/
/*		  If I get several different databases with this	*/
/*		  problem, I may be able to find a pattern and find a	*/
/*		  way to correct the database and the source files.	*/
/*									*/
/*		  Of course, the above instructions to verify the	*/
/*		  database error are a little more complicated if the	*/
/*		  error is in a !file instead of a !short called from	*/
/*		  the menu, but its the same principle - its just a	*/
/*		  little more work to find out which !short the error	*/
/*		  is in.						*/
/*									*/
/************************************************************************/

#include <stdio.h>
#include <io.h>

/* GLOBAL VARIABLES  - declared globally so functions below can get	*/
/*			to them without making them parameters		*/

long i;			/* character count */
FILE *in;		/* input stream to get characters from */
char name_long[9];	/* incoming file name stub */
char temp_name[9];	/* temp area for make_fn to return filename into */

char *make_fn (fnum)	/* creates temp_name from name_long & fnum */
int fnum;
{
	char j_str[4];
	int j;

	strcpy (temp_name, name_long);
	j = strlen (temp_name); if (j > 4) j = 4;
	temp_name[j] = '_'; temp_name[j+1] = '\0';
	if (fnum < 0) strcat (temp_name, "???");
	else
	{
		if (fnum <= 9) strcat (temp_name, "00");
		else if (fnum <= 99) strcat (temp_name, "0");
		itoa (fnum, j_str, 10);
		strcat (temp_name, j_str);
	}

	return (temp_name);
}

get_n (n)		/* get <n> characters */
int n;
{
	while (n-- > 0) { getc (in); i++; }
	return;
}

get_cvt ()		/* get one decoded (XOR 26) character */
{
	int n;

	n = getc (in); i++;
	if ((n % 32) >= 16) n = n - 16; else n = n + 16;
	if ((n % 16) >= 8)  n = n - 8;  else n = n + 8;
	if ((n % 4)  >= 2)  n = n - 2;  else n = n + 2;
	return (n);
}

get_2num ()		/* get decoded two-byte integer */
{
	int n;

	n = get_cvt () + (get_cvt () * 256);
	return (n);
}

long get_4addr ()	/* get decoded four-byte address */
{
	long n;

	n  =  (long) get_cvt ();
	n += ((long) get_cvt () * 256L);
	n += ((long) get_cvt () * 256L * 256L);
	n += ((long) get_cvt () * 256L * 256L * 256L);
	return (n);
}

/* THE MAIN PROCEDURE */

main (argc, argv)
int argc;
char *argv[];
{
	int n, pn, j, name_out_j, ct, items, z, addr_ct, cp, zz_ct;
	int errno, zlen, tlen, see_ct, m, m1, m2, temp_file, temp_ch;
	int save_ch, orig_addr_ct, addr_ct_z, zz_ct_i;
	int zc[500];

	long addr[500], seealso[500], zz[500];

	char name_in[13], name_out[13], name_bat[13];

	FILE *out, *bat, *temp;

/* print credits */

	printf ("\nNG_SPLIT, Copyright (C) 1988, by John C. Gordon\n");
	printf ("Norton Guides Database Splitter, 12 August 1988, ");
	printf ("ALL RIGHTS RESERVED\n\n");

/* check to see if database name was passed in */

	if (argc < 2)
		{ printf ("You must supply a database name !\n"); exit (1); }

/* set up file names */

	j = 0;
	while (*argv[1] != '\0' && *argv[1] != '.')
		name_long [j++] = *argv[1]++;
	name_long [j] = '\0';

	strcpy (name_in,  name_long); strcat (name_in,  ".ng");
	strcpy (name_bat, name_long); strcat (name_bat, ".bat");
	strcpy (name_out, name_long); name_out_j = 0;

	if ((in = fopen (name_in, "rb")) == NULL)
		{ printf ("cannot read '%s'\n", name_in); goto close; }
	if ((bat = fopen (name_bat, "wb")) == NULL)
		{ printf ("cannot write to '%s'\n", name_bat); goto close; }
	if ((out = fopen (name_out, "wb")) == NULL)
		{ printf ("cannot write to '%s'\n", name_out); goto close; }

/* load all addresses */

	rewind (in);
	addr_ct = 0;

	get_n (378);
	i = 377;
	n = get_cvt ();
	while (n == 2)
	{
		get_n (3);
		items = get_2num ();
		get_n (20);
		for (ct = 1; ct < items; ct++) addr[addr_ct++] = get_4addr ();
		get_n (items * 8);
		n = get_cvt ();
		while (n != 0) n = get_cvt ();
		for (ct = 1; ct < items; ct++)
		{
			n = get_cvt ();
			while (n != 0) n = get_cvt ();
		}
		get_n (1);
		n = get_cvt ();
	}

/* now we have the "normal" addr[]s - get the additional ones */

	if (i != addr[0]) { errno = 1; goto error; }

	printf ("    detected %3d original source files\n", addr_ct);
	printf ("    ... searching for additional files\n");

	orig_addr_ct = addr_ct;
	addr[addr_ct] = (long) filelength (fileno (in));

	for (z = 1; z <= addr_ct; z++)
	{
		temp_file = 0;
		while (i < addr[z] && !feof (in))
		{
			if (n == 0)
			{
				get_n (1);
				tlen = get_2num ();
				zlen = get_2num ();
				get_n (20);
				for (zz_ct = 0; zz_ct < zlen; zz_ct++)
					{ get_n (2); zz[zz_ct] = get_4addr (); }
				n = get_cvt ();
				zz_ct = 0;
				if	(zz[zz_ct] < 0L)      zc[zz_ct] = ' ';
				else if (zz[zz_ct] < addr[z]) zc[zz_ct] = '!';
				else
				{
					zc[zz_ct] = '!' + addr_ct;
					addr_ct++;
					addr[addr_ct] = addr[addr_ct - 1];
					addr[addr_ct - 1] = zz[zz_ct];
					printf ("    ... detected file %d\n",
							addr_ct);
				}

	for (ct = zlen * 6; ct < tlen - 1; ct++)
	{
		if (n == 0)
		{
			zz_ct++;
			if	(zz[zz_ct] < 0L)	zc[zz_ct] = ' ';
			else if (zz[zz_ct] < addr[z])	zc[zz_ct] = '!';
			else
			{
				zc[zz_ct] = '!' + addr_ct;
				addr_ct++;
				addr[addr_ct] = addr[addr_ct - 1];
				addr[addr_ct - 1] = zz[zz_ct];
				printf ("    ... detected file %d\n", addr_ct);
			}
		}
		else if (n == 255) { n = get_cvt (); ct++; }
		n = get_cvt ();
	}

				zz_ct_i = 0;
				temp_file = 1;
				n = get_cvt ();
				if (feof (in)) goto tn;
				else if (n != 1) { errno = 2; goto error; }
			}

			else if (n == 1)
			{
tn:
				if (temp_file == 1)
				{
					save_ch = zc[zz_ct_i++];
					if (save_ch == ' ') goto el;
					if (save_ch > '!') goto el;
				}
				get_n (1);
				zlen = get_2num ();
				get_n (2);
				tlen = get_2num ();
				if (tlen == 0) tlen = zlen;
				get_n (18);
				n = get_cvt ();
				for (ct = 0; ct < tlen; ct++)
				{
					if (n == 255)
						{ n = get_cvt (); ct++; }
					n = get_cvt ();
				}
				if (tlen != zlen)
				{
					see_ct = n;
					zlen = zlen - tlen - (see_ct * 4) - 2 - 2;
					get_n (1);
					if (see_ct != 0)
					{
						for (ct = 0; ct < see_ct; ct++)
							get_n (4);
						get_n (zlen + 1);
					}
					get_n (1);
					n = get_cvt ();
				}
el:
				if (temp_file == 1 && zz_ct_i <= zz_ct) goto tn;
			}
			else { errno = 3; goto error; }
		}
		if (z < addr_ct) if (i > addr[z]) { errno = 4; goto error; }
		if (z == addr_ct) if (!feof (in)) { errno = 5; goto error; }
		if (temp_file == 1)
			if (zz_ct_i <= zz_ct) { errno = 6; goto error; }
	}

	rewind (in);	/* reset file for real reads */

/* read the header */

	for (i = 0; i < 8; i++) n = getc (in);
	fprintf (out, "!name: ");
	for (i = 0; i < 40; i++) if ((n = getc (in)) != 0) putc (n, out);
	fprintf (out, "\r\n!credits:\r\n");
	for (j = 0; j < 5; j++)
	{
		for (i = 0; i < 66; i++)
			if ((n = getc (in)) != 0) putc (n, out);
		fprintf (out, "\r\n");
	}

/* read the menu sections */

	i = 377; j = 0;
	n = get_cvt ();
	while (n == 2)
	{
		get_n (1);
		get_n (2);	/* len = get_2num (); */
		items = get_2num ();

		get_n (20);
		for (ct = 1; ct < items; ct++) get_n (4);
		get_n (items * 8);

		fprintf (out, "\r\n!menu: ");
		n = get_cvt ();
		while (n != 0) { putc (n, out); n = get_cvt (); }
		fprintf (out, "\r\n");
		for (ct = 1; ct < items; ct++)
		{
			fprintf (out, "       ");
			cp = 7;
			n = get_cvt ();
			while (n != 0) { putc (n, out); cp++; n = get_cvt (); }
			while (cp++ < 40) putc (' ', out);
			fprintf (out, " %s.ngo", make_fn (j));
			fprintf (bat, "ngc %s\r\n", make_fn (j));
			j++;
			fprintf (out, "\r\n");
		}
		get_n (1);
		n = get_cvt ();
	}

/* now < i > = the address of the byte just read into < n > = first NGO */

	if (i != addr[0]) { errno = 1; goto error; }

	printf ("\nNG_SPLIT detected %d + %d source files ...\n\n",
			orig_addr_ct, addr_ct - orig_addr_ct);
	printf ("    writing batch & menu file...");

	addr_ct_z = orig_addr_ct;		
	for (z = 1; z <= addr_ct; z++)
	{
		fclose (out);
		strcpy (name_out, make_fn (name_out_j));
		if ((out = fopen (name_out, "wb")) == NULL)
		{
			printf ("cannot write to '%s'\n", name_out);
			goto close;
		}
		name_out_j++;
		printf (" %2ld%% complete\n",
			100L * (long) addr[z - 1] / (long) addr[addr_ct]);
		if (z == orig_addr_ct + 1)
			printf ("\n    ***  ADDITIONAL SOURCE FILES  ***\n\n");
		printf ("    writing to file %8s ...", name_out);

		temp_file = 0;

		while (i < addr[z] && !feof (in))
		{

/* the following pages are un-tabbed three tab stops for readability */

if (n == 0)
{
	if ((temp = fopen ("temp", "wb")) == NULL)
	{
		printf ("cannot write to 'temp'\n");
		goto close;
	}
	get_n (1);
	tlen = get_2num ();
	zlen = get_2num ();
	get_n (20);
	for (zz_ct = 0; zz_ct < zlen; zz_ct++)
		{ get_n (2); zz[zz_ct] = get_4addr (); }
	n = get_cvt ();
	zz_ct = 0;
	if	(zz[zz_ct] < 0L)      fprintf (temp, " short:");
	else if (zz[zz_ct] < addr[z]) fprintf (temp, "!short:");
	else
	{
		fprintf (temp, "%cshort:", '!' + addr_ct_z);
		fprintf (bat, "ngc %s\r\n", make_fn (addr_ct_z));
		addr_ct_z++;
	}

	for (ct = zlen * 6; ct < tlen - 1; ct++)
	{
		if (n == 0)
		{
			zz_ct++;
			if	(zz[zz_ct] < 0L)
				fprintf (temp, "\r\n short:");
			else if (zz[zz_ct] < addr[z])
				fprintf (temp, "\r\n!short:");
			else
			{
				fprintf (temp, "\r\n%cshort:", '!' + addr_ct_z);
				fprintf (bat, "ngc %s\r\n", make_fn (addr_ct_z));
				addr_ct_z++;
			}
		}
		else if (n != 255) putc (n, temp);
		else
		{
			n = get_cvt (); ct++;
			while (n-- > 0) putc (' ', temp);
		}
		n = get_cvt ();
	}
	fprintf (temp, "\r\n");
	fclose (temp);
	if ((temp = fopen ("temp", "rb")) == NULL)
	{
		printf ("cannot read 'temp'\n");
		exit (1);
	}
	temp_ch = getc (temp);
	temp_file = 1;
	n = get_cvt ();
	if (feof (in)) goto try_next;
	else if (n != 1) { errno = 2; goto error; }
}

else if (n == 1)
{
try_next:
	if (temp_file == 1)
	{
		save_ch = temp_ch;
		temp_ch = '!';
		while (temp_ch != '\r')
		{
			putc (temp_ch, out);
			temp_ch = getc (temp);
		}
		temp_ch = getc (temp);
		temp_ch = getc (temp);
		fprintf (out, "\r\n");
		if (save_ch == ' ') goto end_loop;
		else if (save_ch > '!')
		{
			save_ch -= '!';
			fprintf (out, "!file: %s.ngo\r\n", make_fn (save_ch));
			goto end_loop;
		}
	}
	get_n (1);
	zlen = get_2num ();
	get_n (2);
	tlen = get_2num ();
	if (tlen == 0) tlen = zlen;
	get_n (18);
	n = get_cvt ();
	pn = 0;
	for (ct = 0; ct < tlen; ct++)
	{
		if (n == 0)
		{
			if (pn == 0) putc (' ', out);
			fprintf (out, "\r\n");
		}
		else if (n != 255) putc (n, out);
		else
		{
			n = get_cvt (); ct++;
			while (n-- > 0) putc (' ', out);
		}
		pn = n; n = get_cvt ();
	}

	if (tlen != zlen)
	{
		see_ct = n;
		zlen = zlen - tlen - (see_ct * 4) - 2 - 2;
		get_n (1);
		fprintf (out, "!seealso: ");
		if (see_ct != 0)
		{
			for (ct = 0; ct < see_ct; ct++)
				seealso[ct] = get_4addr ();
			m1 = 0;
			for (m2 = addr_ct - 1; seealso[m1] < addr[m2]; m2--) ;
			if (m2 < 0)
				printf (" WARNING - Database error ! ...");
			if (name_out_j != m2 + 1)
				fprintf (out, "%s.ngo:", make_fn (m2));
			fprintf (out, "\"");
			n = get_cvt ();
			for (ct = 0; ct < zlen; ct++)
			{
				if (n == 0)
				{
					m1++;
					for (m2 = addr_ct - 1;
						seealso[m1] < addr[m2]; m2--) ;
					fprintf (out, "\" ");
					if (m2 < 0)
					{
						printf (" WARNING - ");
						printf ("Database error ! ...");
					}
					if (name_out_j != m2 + 1)
						fprintf (out, "%s.ngo:",
							make_fn (m2));
					fprintf (out, "\"");
				}
				else putc (n, out);
				n = get_cvt ();
			}
			fprintf (out, "\"");
		}
		fprintf (out, "\r\n");
		get_n (1);
		n = get_cvt ();
	}
end_loop:
	if (temp_file == 1 && !feof (temp)) goto try_next;
}
else { errno = 3; goto error; }

/* normal tabbing resumes on this page */

		}
		if (z < addr_ct) if (i > addr[z]) { errno = 4; goto error; }
		if (z == addr_ct) if (!feof (in)) { errno = 5; goto error; }
		if (temp_file == 1)
		{
			if (!feof (temp)) { errno = 6; goto error; }
			fclose (temp);
		}
	}
	if (ferror (out)) { errno = 7; goto error; }
	printf ("\n\nSUCCESSFUL - Created %d source files !\n", addr_ct);
	goto close;

error:
	printf ("\n\nERROR %d !  ", errno);
	switch (errno)
	{
		case 1:	printf ("Header is ");
			if (i > addr[0])
				printf ("%ld bytes too long",  i - addr[0]);
			else    printf ("%ld bytes too short", addr[0] - i);
			break;
		case 2:	printf ("Section # 0 is not followed by # 1 ( %d )", n);
			break;
		case 3:	printf ("Cannot recognize section # %d", n);
			break;
		case 4:	printf ("Section is ");
			if (i > addr[z])
				printf ("%ld bytes too long",  i - addr[z]);
			else    printf ("%ld bytes too short", addr[z] - i);
			break;
		case 5:	printf ("Did not reach EOF on input database");
			break;
		case 6:	printf ("Did not reach EOF on 'temp' file");
			break;
		case 7:	printf ("Write error - possibly out of disk space");
	}
	printf ("\n\n");
	printf ("    Byte number = %ld\n", i);
	printf ("    EOF = %ld\n\n", addr[addr_ct]);
	for (z = 0; z < addr_ct; z++)
		printf ("    addr[%d] = %ld\n", z, addr[z]);

close:
	printf ("\n");
	fprintf (bat, "ngml %s\r\n", name_long);
	fcloseall ();
	unlink ("temp");
	exit (0);
}
