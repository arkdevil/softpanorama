#include <wgtsb.h>
#include <wgt.h>
#include <conio.h>

/* WordUp Graphics Toolkit 
   SoundBlaster Routines 
````````````````````````````
This program plays a CMF file in the background,
and plays a VOC file when you click the left and right
mouse button. Hit any key to stop this portion.
Recording will now be tested. It will record and
play back like a parrot, that is, it listens for
a while, and then plays back what you said.
*/


unsigned v;
wgtsong song;
wgtvoice badger;
wgtvoice conanhit;

void main(void)
{
int ok;

sbintnum=7; sbioaddr=0x220;		// set SB ports and interrupts
ok=wfindfm();				// init FM sound
if (ok==-1) {
	printf("You must run SBFMDRV.COM before using this program!");
	exit(1);
	}
ok=winitsb();				// init digital sound
if (ok==-1) {
	    printf("CT-VOICE.DRV not found in directory!");
	    exit(1); // could not load in CT-Voice driver from current 
		    // directory (or library file)
	    }
song=wloadcmf("wsp.cmf");
badger=wloadvoc("badger.voc");
conanhit=wloadvoc("conhit.voc");
vga256();
wplaycmf(song);
minit();
mon();
window(1,1,80,25);

do {
mread();
if (but==1) {
	 wsetcolor(my);
	 wline(0,0,mx,my);
	 wstopvoc();
	 wplayvoc(badger);
	 }
if (but==2) {
	 wsetcolor(my);
	 wline(319,199,mx,my);
	 wstopvoc();
	 wplayvoc(conanhit);
	 }
gotoxy(1,1);
printf("%i",fmstat);
if (fmstat==0) wplaycmf(song);
delay(10);
} while (!kbhit());

getch();
moff();
textmode(C80);
wfmstopmusic();
wfreesong(song);
wfreevoc(badger);
wfreevoc(conanhit);


printf("Talk into the microphone....");
badger=wnewvoice(20000);	// make a new voice data variable
do {
   printf("\nNow recording...");
   wsetspeaker(0);			// turn speaker off
   wsample(badger,20000);
   while (sbstat);			// wait until finished recording
   printf("\nNow playing back...");
   wsetspeaker(1);
   wplayvoc(badger);
   while (sbstat !=0);			// wait until finished playing
  } while (!kbhit());
wfreevoc(badger);
wdeinitsb();	// deinit digital sound
}