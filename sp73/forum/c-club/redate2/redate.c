/*--------------------------------------------------------------------------*/
/* Yet another semi-useful utility: REDATE *.PAK                            */
/* Sets the file time and date for the output of NoGate's PAK.EXE files to  */
/* the time and date of newest member file in a PAK archive.                */
/*                                                                          */
/* If you break it, you can keep both parts. This just fixes a small hassle */
/* for people converting from SEA ARC format to NoGate's PAK format.        */
/*                                                                          */
/* Copyright 1989, Doug Boone. FidoNet 119/5                                */
/*      bcc -a- -f- -G -K -lt -mt -Z redate.c                               */
/*                                                                          */
/*--------------------------------------------------------------------------*/
/* March 22, 1991  REDATE2.ZIP                                              */
/* Fixed bug in LZH files that were padded with ^Z.                         */
/* Fixed PAK type 12 header to be included                                  */
/*--------------------------------------------------------------------------*/

#include    <stdio.h>
#include    <string.h>
#include    <ctype.h>
#include    <time.h>
#include	<dos.h>
#include	<dir.h>
#include    <io.h>
#include    <fcntl.h>
#include    <dos.h>
#include   <stdlib.h>
#include    <sys\types.h>
#include    <sys\stat.h>
#include	<errno.h>
/* You don't need everything in archdr.h, but I don't want to trim it. */

#include	"archdr.h"


unsigned    int     mbrtime;
unsigned    int     mbrdate;

int checkpak(int arc);		/* list files in archive */
int checkzip(int infile);
int checklzh(int infile);
int checkarj(int fh);		/* list files in archive */

void cdecl main(int argc, char *argv[])
{
    int     i;
    int     done;
    struct  ffblk   ffblk;
	char    name[80];
    int     infile;		/* file handle */
	char    *firstchar;
	char	apath[80];
	char	*result;
    int     success;
	union	REGS	regs;

    if (argc < 2) {
		printf ("\nFixes the date for PAK, ZIP, ARJ and LZH files\n\n");
        exit(1);
		}
	firstchar = (char *) malloc(1);

	for (i=1; i<argc; i++) {
		strcpy(apath,argv[i]);
		result = strrchr(apath,'\\');
		if (result != NULL)
			*++result = '\0';
		else {
			result = strrchr(apath,':');
			if (result !=NULL)
				*++result = '\0';
			else
				apath[0] = '\0';
			}
		if (strncmp(argv[i],".",1)==0)
			strcpy(argv[i],"*.*");
        done = findfirst(argv[i],&ffblk,0);
		while (done == 0) {
			strcpy(name,apath);
			strcat(name,ffblk.ff_name);
			printf("Resetting file date on %s",name);
            infile = open(name,O_RDONLY|O_BINARY);
            if (infile > 0)
				success = read(infile,firstchar,1);
			firstchar[0] = toupper(firstchar[0]);
			mbrtime = 0;
			mbrdate = 0;
           switch(firstchar[0]) {
               case    0x1a:    success = checkpak(infile); break;
               case    'P':     success = checkzip(infile); break;
               case    '`':     success = checkarj(infile); break;
               default:         success = checklzh(infile); break;
               }
            if (success<0)
                printf("\n%s Not an archive file\n\n",name);
			else {
				regs.h.ah = 0x57;
				regs.h.al = 0x01;
				regs.x.bx = infile;
				regs.x.cx = mbrtime;
				regs.x.dx = mbrdate;
				int86(0x21,&regs,&regs);
    			printf(" to %2d/%02d/%02d  %02d:%02d:%02d\n",
				    ((mbrdate >> MONTH_SHIFT) & MONTH_MASK),
                    (mbrdate & DAY_MASK),
				    ((mbrdate >> YEAR_SHIFT) + DOS_EPOCH),
                    ((mbrtime >> 11) & 0x1f),
				    ((mbrtime >> 5) & 0x3f),
                    (mbrtime &0x1f)*2);
				}
            close(infile);
            done = findnext(&ffblk);
            }		/* end of findfirst/findnext loop */
		}		/* end of for loop */
	free(firstchar);
	exit(0);
}


/* ====================================================================
 * start of list arc contents processing
 * ====================================================================
 */
int checkpak(int arc)		/* list files in archive */
{
	struct 	heads *hdr;		/* header data */
	char	*ver = " ";


    hdr = (struct heads *) malloc(sizeof(struct heads));

	lseek(arc,1L,SEEK_SET);
	read(arc,ver,1);
	while (*ver > 0 && *ver < 12) {

		read(arc,hdr,sizeof(struct heads));
        if (mbrdate < hdr->mbrdate) {
            mbrdate = hdr->mbrdate;
            mbrtime = hdr->mbrtime;
			}
        if (mbrdate == hdr->mbrdate &&
            mbrtime < hdr->mbrtime)
            mbrtime = hdr->mbrtime;

		lseek(arc,hdr->mbrsize+1L,SEEK_CUR);
		read(arc,ver,1);
        };		/* End of while loop */
	free(hdr);
    return(0);
}

int checkzip(int infile)
{
    struct  ID_Hdr          *ID;
    struct  Local_Hdr       *local;
	int		check;


    ID = (struct ID_Hdr *) malloc(sizeof(struct ID_Hdr));
	local = (struct Local_Hdr *) malloc(sizeof(struct Local_Hdr));
	lseek(infile,0,SEEK_SET);
    do {
        check = read(infile,(void *)ID,sizeof(struct ID_Hdr));
        if (ID->Head_Type == LOCAL_HEADER) {
			if ((check = read(infile,(void *)local,sizeof(struct Local_Hdr))) != -1) {
                if (mbrdate < local->mod_date) {
                    mbrdate = local->mod_date;
                    mbrtime = local->mod_time;
                    }
                if (mbrdate == local->mod_date &&
					mbrtime < local->mod_time)
                    mbrtime = local->mod_time;

				lseek(infile,local->size_now+((long)(local->name_length + local->Xfield_length)),SEEK_CUR);
                }		/* End of one entry */
			}		/* End of grabbing local directory entries */
		else
			check = 0;
        } while(check >0 && !eof(infile));		/* End of file */
	free(ID);
	free(local);
    return(0);
}

int checklzh(int infile)
{
   struct  Lharc_Hdr   *local;
	int		check;
   long    where;
   unsigned    time;
   unsigned    date;
   struct  tm *tm;

/*--------------------------------------------------------------------------*/
	lseek(infile,0L,SEEK_SET);
   local = (struct Lharc_Hdr *) malloc(sizeof(struct Lharc_Hdr));

	if ((check = read(infile,(void *)local,sizeof(struct Lharc_Hdr))) ==
		sizeof(struct Lharc_Hdr)) {
			if (!((strncmp(local->type,"-lh",3) == 0) &&
				(local->type[4] == '-'))) {
				free(local);
				return(-1);
				}
			}
	else {
		free(local);
		return(-1);
		}
	where = 0L;
	do {
		switch(local->level) {
			case 0: 
			case 1: where += local->size_now + 2L + (local->size_header & 0xff);
				   if (mbrdate < local->orig.dtime.date) {
                       mbrdate = local->orig.dtime.date;
					   mbrtime = local->orig.dtime.time;
                       }
				   else if ((mbrdate == local->orig.dtime.date) &&
                       (mbrtime < local->orig.dtime.time))
                       mbrtime = local->orig.dtime.time;
                   break;

			case 2:     where += local->size_now + local->size_header;
				        tm = localtime(&(local->orig.utc));

					   date =  (tm->tm_year - 80) << 9;
                       date += (tm->tm_mon +1) << 5;
                       date += tm->tm_mday;

                       time =  tm->tm_hour << 11;
					   time += tm->tm_min << 5;
                       time += tm->tm_sec/2;

                   if (mbrdate < date) {
                       mbrdate = date;
                       mbrtime = time;
					   }
                   else if ((mbrdate == date) && (mbrtime < time))
                       mbrtime = time;
				   break;
			}
		where = lseek(infile,where,SEEK_SET);
		check = read(infile,(void *)local,sizeof(struct Lharc_Hdr));
		} while(check >1 && !strncmp(local->type,"-lh",3));		/* End of file */
	free(local);
	return(0);
}

int checkarj(int fh)		/* list files in archive */
{
   struct  _ARJ_main   ahead;
   word    ID;
   word    len;

	lseek(fh,0L,SEEK_SET);
   while ((read(fh,(char *)&ID,sizeof(word))) && (ID == 0xea60)) {
		if (read(fh,(char *)&ahead,sizeof(struct _ARJ_main)) == sizeof(struct _ARJ_main)) {
          len = ahead.base_size - sizeof(struct _ARJ_main);
          lseek(fh,((long)len),SEEK_CUR);
		   if (ahead.c_size > 0L) {
			   if (mbrdate < ahead.stamp.date) {
				   mbrdate = ahead.stamp.date;
				   mbrtime = ahead.stamp.time;
				   }
			   if (mbrdate == ahead.stamp.date && mbrtime < ahead.stamp.time)
				   mbrtime = ahead.stamp.time;
				   }

		   lseek(fh,(8L+ahead.c_size),SEEK_CUR);
		   }
		};		/* End of while loop */
	return(0);
}

