/*
IDEINFO.EXE

Tries to tell all about all IDE drives, including ATA-2 stuff.

Copyright (c) July 1994 by Raimo Koski - All rights reserved
Postal Address: Uudenmaantie 23 K 3
                20720
                Finland

Compiles with BC++ 3.1
*/


#include <stdlib.h>
#include <ctype.h>
#include <dos.h>
#include <stdio.h>
#include <conio.h>
#include <bios.h>
#include <io.h>
#include <fcntl.h>
#include <string.h>
#include <sys\stat.h>
#include "ideinfo.h"

#define TIME_OUT 600000
/* Was 100 000 but with one 33 MHz 486DX it was too little in about
   haft of the runs. I reasoned that 100 MHz Pentium would be about
   6 times as fast and 600 000 would be on the verge of being too
   little but that is the worst case currently.
   Raise the value if all drives are not found in a very fast machine
*/

#define MAX_FILE 99             // Max number of files, increase if needed,
                                // big value slows down.

char *getascii (unsigned int in_data [], int off_start, int off_end);
void prtinfo(int loop);
void usage(void);
unsigned int htoi(char *s);

unsigned int dd [256]; /* DiskData */
unsigned int dd_off;   /* DiskData offset */
unsigned int bios_cyl [2], bios_head [2], bios_sec [2];  /* Cylinders, Heads, Sectors */
int cntr;               // Number of controllers we try
unsigned int cntl_base[4] = {0x1f0, 0x170, 0xf0, 0x70};  // Try all ususal ports
int stdout_tty;
int no_cntr = 1;
int R_file = 0;


void main (void)
{
  unsigned int loop, extloop;     /* Loop variable */
  int num_drv;           /* Number of BIOS Hard disks */
  int max_cntr = 4;
  int handle, i, j, di;
  int wrote = 0;
  int retry = 0;

  char ext[3];
  char filename[13];
  union REGS registers;  /* Used for Interrupt for BIOS data */

  clrscr ();
  stdout_tty =  isatty(fileno(stdout));

  for (i=0;i < _argc; i++)
     if ((strcmpi(_argv[i], "/H") == 0) || (strcmpi(_argv[i], "-H") == 0) ||
         (strcmpi(_argv[i], "H" ) == 0) || (strcmpi(_argv[i], "/?") == 0) ||
         (strcmpi(_argv[i], "-?") == 0) || (strcmpi(_argv[i], "?" ) == 0))
        usage();

     for (i=0;i < _argc; i++)
// Search for F parameter, if found write drive info to file
        if ((strcmpi(_argv[i], "/F") == 0) || (strcmpi(_argv[i], "-F") == 0) || (strcmpi(_argv[i], "F") == 0))
           R_file = 1;


// If R (Read) parameter is given display all idedrive.* files in current
// directory, then quit.
  for (i=0;i < _argc; i++)
     if ((strcmpi(_argv[i], "/R") == 0) || (strcmpi(_argv[i], "-R") == 0) || (strcmpi(_argv[i], "R") == 0))
     {
        bios_head [0] = 0;
        bios_sec [0] = 0;
        bios_cyl [0] = 0;
        _fmode = O_BINARY;
        loop = 0;
        do
        {
           /* change the default file mode from text to binary */
           itoa(loop, ext, 10);
           strcpy(filename, "idedrive.");
           strcat(filename, ext);
           handle = open(filename, O_RDONLY);
           if (handle == -1)
              continue;
           read(handle, dd, 512);
           close(handle);
           no_cntr = 0;
           prtinfo(0);
        }
// Could be larger but I guess that 100 files is enough for a while
        while (loop++ < MAX_FILE);
        return(0);
     }

  /* How many disk drives & parameters */
// Try even if not defined in BIOS
  num_drv = 2;

//Trust BIOS
//num_drv = peekb (0x40, 0x75);  /* BIOS Data area, Number of Hard disks */
                                 /* Byte at Segment 40H Offset 75H */


  j = 0;
  for (i=0;i < _argc; i++)
     if ((strcmpi(_argv[i], "/P") == 0) || (strcmpi(_argv[i], "-P") == 0) || (strcmpi(_argv[i], "P") == 0))
     {
        cntl_base[j++] = htoi(_argv[i+1]);
//      printf("%3x\n", cntl_base[j]);
        if (cntl_base[cntr] == 0) continue;
// Sanity check, room only for 4 addresses.
        if (j==3) break;
        max_cntr = j;
     };


  for (cntr = 0; cntr < max_cntr; cntr++)
  {
     for (loop = 0; loop < num_drv; loop++)  /* Loop through drives */
     {
        di = 0;
        retry = TIME_OUT;
 /* Wait for controller not busy or timeout */
        while ((di != 0x50) && (--retry))
           di = inp(cntl_base[cntr] + HD_STATUS);
        if (!retry)
        // timed out
        {
           if (!R_file)
           {
              fprintf (stdout, "\nAdapter %1u at %3xh not found\n", cntr, cntl_base[cntr]);
              fprintf (stdout, "Last status %2xh\n", di);
              if (stdout_tty)
              {
                 fprintf (stderr, "Press a key\n");
                 getch ();
              }
           }
        // This adapter is done ie. not existing
           goto outerloop;
        }
        /* Get first/second drive */
        outp (cntl_base[cntr] + HD_CURRENT, (loop == 0 ? 0xA0 : 0xB0));
        /* Get drive info data */
        outp (cntl_base[cntr] + HD_COMMAND, 0xEC);
        retry = TIME_OUT;
        di = 0;
        /* Wait for data ready or time out*/
        while ((di != 0x58) && (--retry))
           di = inp(cntl_base[cntr] + HD_STATUS);
        if (!retry)
        {
        // Timed out
           if  (!R_file)
           {
              fprintf (stdout, "\nAdapter %1u at %3xh Drive %1u not found\n", cntr, cntl_base[cntr], loop);
              fprintf (stdout, "Last status %2xh\n", di);
              if (stdout_tty)
              {
                 fprintf (stderr, "Press a key\n");
                 getch ();
              }
           }
        // reselect drive 0
           if (loop) outp (cntl_base[cntr] + HD_CURRENT, 0xa0);
           continue;
        }

        for (dd_off = 0; dd_off != 256; dd_off++) /* Read "sector" */
           dd [dd_off] = inpw (cntl_base[cntr] + HD_DATA);

        if (R_file)
        {
           extloop = 0;
// Loop file extensions until we find unused one
           do
           {
           /* change the default file mode from text to binary */
              _fmode = O_BINARY;
              itoa(extloop, ext, 10);
              strcpy(filename, "idedrive.");
              strcat(filename, ext);
              handle = open(filename, O_RDONLY);
              close(handle);
           }
           while ((handle != -1) && (extloop++ < MAX_FILE));
// Exit if too many files
           if (extloop > MAX_FILE) return(0);

        /* create a binary file for writing */
           handle = creat(filename, S_IWRITE);
        /* write 512 bytes to the file */
           write(handle, dd, 512);

              /* close the file */
           close(handle);
           wrote = 1;
           fprintf (stdout, "Wrote info for DRIVE %d Adapter %1u at base address %3xh to file %s\n",
              loop, cntr, cntl_base[cntr], filename);
        }
// Trust BIOS only with default primary adapter
        if (cntl_base[cntr] == 0x1f0)
        {
           /* Get BIOS drive info */
           registers.h.ah = 0x8;            /* Get drive info */
           registers.h.dl = 0x80 + loop;    /* Drive is 80H for Disk 0, 81H for Disk 1 */
           int86 (0x13, &registers, &registers);
           if (! registers.x.cflag)   /* All OK if carry not set */
           {
              bios_head [loop] = registers.h.dh + 1; /* Heads are from 0 */
              bios_sec [loop] = registers.h.cl & 0x3F; /* sec is bits 5 - 0 */
              bios_cyl [loop] = ((registers.h.cl & 0xC0) << 2) + registers.h.ch + 2; /* +1 because starts from 0 and +1 for FDISK leaving one out */
           }
        }
        else
        {
           bios_head [loop] = 0;
           bios_sec [loop] = 0;
           bios_cyl [loop] = 0;
        }
        if (wrote==0) prtinfo(loop);
     }
outerloop:
  }
}


void prtinfo(int loop)
{
  clrscr ();
  if (no_cntr) fprintf (stdout, "DRIVE %d Adapter %1u at base address %3xh\n",
        loop, cntr, cntl_base[cntr]);
  fprintf (stdout, "                        Disk Reports    BIOS Reports\n");
  fprintf (stdout, "                    Default     Current\n");
  fprintf (stdout, "# of Cylinders______:%4u\t %4i\t %4u\n",
        dd [1], (dd[53] & 1) ? dd[54] : -1, bios_cyl [loop]);
  fprintf (stdout, "# of Heads__________:%4u\t %4i\t %4u\n",
        dd [3], (dd[53] & 1) ? dd[55] : -1, bios_head [loop]);
  fprintf (stdout, "# of Sectors/Track__:%4u\t %4i\t %4u\n",
        dd [6], (dd[53] & 1) ? dd[56] : -1, bios_sec [loop]);
  fprintf (stdout, "Model Number________: %s\n", getascii (dd, 27, 46));
  fprintf (stdout, "Serial Number_______: %s\n", getascii (dd, 10, 19));
  fprintf (stdout, "Controller Rev. #___: %s\n", getascii (dd, 23, 26));
  fprintf (stdout, "Double Word Transfer: %6s\n",
        (dd [48] == 0 ? "No" : "Yes"));
  fprintf (stdout, "Controller type_____: ");
  if(dd [20]== 0) fprintf (stdout,"Not specified/Unknown\n");
  if(dd [20]== 1) {
     fprintf (stdout,"a single ported single sector buffer which is not capable of\n");
     fprintf (stdout,"\t\t      simultaneous data transfers to or from the host and the disk.");
  }
  if(dd [20]== 2) {
     fprintf (stdout,"a dual ported multi-sector buffer capable of simultaneous\n");
     fprintf (stdout,"\t\t      data transfers to or from the host and the disk.\n");
  }
  if(dd [20]== 3) {
     fprintf (stdout,"a dual ported multi-sector buffer capable of simultaneous\n");
     fprintf (stdout,"\t\t      transfers with a read caching capability.\n");
  }
  if(dd [20] > 3) fprintf (stdout,"Reserved/Unknown\n");
  fprintf (stdout, "Buffer size (kB)____: %6u\n", dd [21] >>1);
  fprintf (stdout, "# of ECC bytes______: %6u\n", dd [22]);
  fprintf (stdout, "# of secs/interrupt_: %6u", 0xff & dd [47]);
  if (dd [59] & 256)
     fprintf (stdout, "\tCurrent setting %3u\n",0xff & dd[59]);
  else fprintf (stdout, "\n");
  fprintf (stdout, "LBA support\t\t %s",(dd [49] & 512) ? "Yes" : " No");
  if (dd [49] & 512){
     fprintf (stdout, "%6.1fMB of LBA addressable",
        (((float)dd[61]* 65536 + (float) dd[60]) / 2048));
     if (dd[53] & 1) fprintf (stdout, " %6.1fMB in CHS mode\n",
        (((float)dd[58]* 65536 + (float) dd[57]) / 2048));
     }
  else fprintf (stdout, "\n");
  fprintf (stdout, "DMA support\t\t %s\n",  (dd [49] & 256) ? "Yes" : " No");
  fprintf (stdout, "IORDY supported\t\t %s\nIORDY can be disabled\t %s\n",
        (dd[49] & 2048) ? "Yes" : " No",(dd [49] & 1024) ? "Yes" : " No");
  fprintf (stdout, "PIO data txfer cycle timing mode:  %6u\n",
        (0xff00 & dd [51]) >> 8);
  if (dd [49] & 256)
     if ((dd[62] + dd[63]) == 0)  // if words 62 and 63 supported ignore 53
        fprintf (stdout, "SW DMA txfer cycle timing mode:    %6u  \n" ,
           (0xff00 & dd [52]) >> 8);
     else
     {
        fprintf (stdout, "SW DMA txfer cycle timing modes:\t");
        switch(0x00ff & dd [62]) {
           case 0x0004 : fprintf(stdout, "2");
           case 0x0002 : fprintf(stdout, "1");
           case 0x0001 : fprintf(stdout, "0");
           default:      fprintf(stdout, " ");
        }
        fprintf (stdout, "    Active ");
        switch(0xff00 & dd [62]) {
           case 0x0400 : fprintf(stdout, "2\n"); break;
           case 0x0200 : fprintf(stdout, "1\n"); break;
           case 0x0100 : fprintf(stdout, "0\n"); break;
           default:      fprintf(stdout, "\n");
        }
        fprintf (stdout, "MW DMA txfer cycle timing modes:\t");
        switch(0x00ff & dd [63]) {
           case 0x0004 : fprintf(stdout, "2");
           case 0x0002 : fprintf(stdout, "1");
           case 0x0001 : fprintf(stdout, "0");
           default:      fprintf(stdout, " ");
        }
        fprintf (stdout, "   Active ");
        switch(0xff00 & dd [63]) {
           case 0x0400 : fprintf(stdout, "2\n"); break;
           case 0x0200 : fprintf(stdout, "1\n"); break;
           case 0x0100 : fprintf(stdout, "0\n"); break;
           default:      fprintf(stdout, "\n");
        }
     }
  if (dd [53] & 2){
     if (stdout_tty)
     {
        fprintf (stdout, "Press a key\n");
        getch ();
     }
     fprintf (stdout, "Congratulations, your drive supports ATA-2\n");
     fprintf (stdout, "Advanced PIO txfer modes supported:\t\t ");
     switch(0x00ff & dd [64]) {
        case 0x0004 : fprintf(stdout, "5");
        case 0x0002 : fprintf(stdout, "4");
        case 0x0001 : fprintf(stdout, "3");
        default:      fprintf(stdout, "\n");
        }
     fprintf (stdout, "Min MW DMA txfer cycle time/word:             %4u ns   %2.1fMB/s\n",
        dd [65], 1/(float)dd[65]*2e3);
     fprintf (stdout, "Mfg Recommended MW DMA txfer Cycle Time       %4u ns   %2.1fMB/s\n",
        dd [66], 1/(float)dd[66]*2e3);
     fprintf (stdout, "Min PIO txfer Cycle Time w/o Flow Control     %4u ns   %2.1fMB/s\n",
        dd [67], 1/(float)dd[67]*2e3);
     fprintf (stdout, "Min PIO txfer Cycle Time w IORDY Flow Control %4u ns   %2.1fMB/s\n",
        dd [68], 1/(float)dd[68]*2e3);
  }
  else fprintf (stdout, "Sorry, no ATA-2 features implemented\n");
  if (stdout_tty)
  {
     fprintf (stdout, "Press a key\n");
     getch ();
  }
}


char *getascii (unsigned int in_data [], int off_start, int off_end)
{
  static char ret_val [255];
  int loop, loop1;

  for (loop = off_start, loop1 = 0; loop <= off_end; loop++)
    {
      ret_val [loop1++] = (char) (in_data [loop] / 256);  /* Get High byte */
      ret_val [loop1++] = (char) (in_data [loop] % 256);  /* Get Low byte */
    }
  ret_val [loop1] = '\0';  /* Make sure it ends in a NULL character */
  return (ret_val);
}

unsigned int htoi(char *s)
{
   unsigned int i, j = 0;

   while (('\0' != *s) && isxdigit(*s))
   {
      i = *s++ - '0';
      if (9 < i)
         i -= 7;
      j <<= 4;
      j |= (i & 0x0f);
   }
   return(j);
}


void usage(void)
{
  fprintf (stderr, "IDEINFO [[H] || [?] || [R]] || [[F]] [P xxx] [P xxx].. ]]\n\n");
  fprintf (stderr, "Version 1.0. Tries to tell all about all IDE drives, including ATA-2 stuff.\n\n");
  fprintf (stderr, "Options may be preceded with -, / or none\n");
  fprintf (stderr, "-H or -? prints this help.\n");
  fprintf (stderr, "-R Reads idedrive.* files from current directory.\n");
  fprintf (stderr, "-F Writes drive identify info to idedrive.* files to current directory.\n");
  fprintf (stderr, "-P xxx looks only adapter at port xxx, xxx in hex format\n\n");
  fprintf (stderr, "File extension is next available number when writing.\n\n");
  fprintf (stderr, "File size is 512 bytes.\n");
  fprintf (stderr, "You may redirect output.\n\n");
  fprintf (stderr, "Example: Look only for adapters at 1F0h (primary) and 170h (normal secondary)\n");
  fprintf (stderr, "and write info to files.\n");
  fprintf (stderr, "IDEINFO P 1f0 P 170 F\n");
  exit(0);
}
