#include <classlib\time.h>
#include <cstring.h>
#include <dos.h>
#include <iostream.h>
#include <stdio.h>

// FileAge.Exe / Author: David H. Bennett / Date: 5-3-95 / Version: 1.0
//
// Returns the age of a file in Minutes, Hours, or Days as an
// errorlevel.
//
// CIS: 74635,1671
// Internet: bss@bensoft.com

// Error Levels
//    0-119   -  Minutes Old
//  120-166   -  Hours Old-118
//  167-253   -  Days Old-165
//  254       -  More than 88 Days old
//  255       -  ERROR

char *strUsage="Usage: FILEAGE [[drive:][path]filename[ ...]]\n" \
    "\n" \
    "Returns the age of the file in Minutes, Hours, or Days as an\n" \
    "errorlevel.\n" \
    "\n" \
    "Error Levels Returned:\n" \
    "\n" \
    "      0-119   - Minutes Old\n" \
    "    120-166   - Hours Old-118\n" \
    "    167-253   - Days Old-165\n" \
    "        254   - More than 88 Days old\n" \
    "        255   - ERROR\n" \
    "\n" \
    "Author: David H. Bennett / Date: 5-3-95 / Version: 1.0\n";

int main(int argc, char* argv[])
{
	FILE *stream;
	unsigned iFDay, iFMonth, iFYear, iFMin, iFHour;
	unsigned iFDate, iFTime;

	if (argc<=1) {
		cout << strUsage;
		return(255);
	}

	if ((stream = fopen(argv[1], "r")) == NULL)
	{
		return 255;
	}
	_dos_getftime(fileno(stream), &iFDate, &iFTime);
	fclose(stream);

	iFDay=(iFDate & 0x1F);
	iFMonth=((iFDate >> 5) & 0xF);
	iFYear=(((iFDate >> 9) & 0x7F) + 1980);
	iFMin=((iFTime >> 5) & 0x3F);
	iFHour=((iFTime >> 11) & 0x1F);

	{
		unsigned long ulSeconds, ulMinutes, ulHours, ulDays;
		TDate tdFile(iFDay,iFMonth,iFYear);
		TTime ttFile(tdFile,iFHour,iFMin,0);
		TTime ttNow;
		ulSeconds=ttNow.Seconds()-ttFile.Seconds();
		ulMinutes=ulSeconds / 60;
		ulHours=ulMinutes / 60;
		ulDays=ulHours / 24;

		if (ulMinutes <= 101) return (int)ulMinutes;
		if (ulHours <= 48) return (int)((int)ulHours+118);
		if (ulDays <= 88)  return (int)((int)ulDays+165);
	}
  return(254);    // Older than Resolution
}
