
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "ruckmidi.h"

/*
X02M.c 27-Feb-94 chh
remove C7-specific _ all over the place
OutMsgMidi example
*/

/*
The following structures are in ruckdac.h
*/

#pragma pack(1)  /* ALL Ruckus data structures must be byte-aligned */

extern struct MidiDataArea pascal MIDIDATA;

struct SysInfoMidiPack SIMP;
struct InitMidiPack IMP;
struct XitMidiPack XMP;
struct LoadMidiPack LMP;
struct SetMidiPack SMP;
struct SetFMProPack SFMPP;
struct PlaybackMidiPack PBMP;
struct OutMsgMidiPack OMMP;
struct DeallocMidiPack DMP;

#pragma pack()

int rez, rez2;      /* result status codes */
char nums[9] = {7}; /* number buffer for _cgets()*/
char filename[81];  /* pathname to load */


int main()
{

    int pc=0, sSize=0;
    unsigned i=0;
    unsigned pitchbend=0x2000;  /* mid-value of 0-8192 range */

    printf("\nX02M.C - RUCKUS-MIDI OutMsgMidi example. [930228]\n");

    /*
    Initialize RUCKMIDI and device and register ExitMidi with _atexit
    */

    IMP.Func = InitMidi;
    IMP.DeviceID = 1;           /* OPL-2 percussive mode */
    IMP.IOport = 0x388;
    IMP.ChMask = 0x23F;
    IMP.PercCh = 9;
    IMP.Flags = 0;
    rez = RUCKMIDI(&IMP);                 /* Initialize */
    if (rez == 0) {

        XMP.Func = AtExitMidi;
        rez2 = RUCKMIDI(&XMP);
        if (rez2 != 0) {
            printf("AtExitMidi failed, press Enter to continue");
            getchar();
        }

        /*
        Increase SB Pro main and FM vol volumes to max
        */

        SFMPP.Func = SetAllFMSBP;
        SFMPP.IOport = 0x220;       /* if there it'll respond */
        SFMPP.MasterVol = 0x0F0F;   /* if not, no problem */
        SFMPP.Steer = 0;
        SFMPP.FMvol = 0x0F0F;
        rez2 = RUCKMIDI(&SFMPP);


        /*
        Set patch map to, oh, let's use GM
        */

        SMP.Func = SetPatchMidi;
        SMP.PatchMapID = 0;     /* actually, this is the GM is the default */
        SMP.PatchMapPtr = NULL;
        rez2 = RUCKMIDI(&SMP);

        do {
            printf("\nProgram# to sound (0-127, -1 to end): ");
	    pc = atoi(cgets(nums));
            if ((pc < 0) || (pc > 127))
                break;

            OMMP.Func = OutMsgMidi;
            OMMP.Mstatus = 0xC0;    /* channel 0 program change */
            OMMP.Mdata = pc;
            rez2 = RUCKMIDI(&OMMP);

            printf("\n------------------------------------");
            printf("\nChannel 0 is using program number: %i\n",pc);

            /*
            In NoteOn Mdata is key number (0-127 MIDI, but OPL-2 key
            numbers are valid from 12 to 107, see docs for more)
            in the low byte. Key velocity (0-127) is in the high byte.
            --velocity is essentially the volume desired.
            */

            OMMP.Func = OutMsgMidi; /* really don't need to set it again */
            OMMP.Mstatus = 0x90;    /* NoteOn, channel 0 */
            OMMP.Mdata = 0x7F3C;    /* note=60 = 262Hz, max volume=7F */
            rez2 = RUCKMIDI(&OMMP);

            printf("Playing a note with the NoteOn command\n");
            printf("Press Enter to send NoteOff command...\n");
            printf(" (NoteOn) ");
            printf("Note: %u, Channel: %u, Volume: %u",
                 (OMMP.Mdata & 0x7F),(OMMP.Mstatus & 0x0F),(OMMP.Mdata >>8));

            gets(filename);
            printf(" (NoteOff)\n");

            /*
            Note that sending a NoteOn (above) with velocity=0 has the same
            effect as performing an explicit NoteOff--often in MIDI data
            streams NoteOn with a velocity=0 is used rather than the specfic
            NoteOff message--here the NoteOff message is used (with the
            NoteOn method commented-out.
            */

            OMMP.Func = OutMsgMidi;
            OMMP.Mstatus = 0x80;    /* NoteOff, channel 0 */
            OMMP.Mdata = 0;         /* any data will do */
            rez2 = RUCKMIDI(&OMMP);

            /*
            OMMP.Func = OutMsgMidi;
            OMMP.Mstatus = 0x90;
            OMMP.Mdata = 0x3C;
            rez2 = RUCKMIDI(&OMMP);
            */

            printf("\nPress Enter...");
            gets(filename);

            /*
            Do something a little more exciting than that.
            See OutMsgMidi for more on MIDI channel messages in general.
            */

            printf("Playing the same note but applying +/- pitchbend\n");

            OMMP.Func = OutMsgMidi;
            OMMP.Mstatus = 0x90;    /* NoteOn, channel 0 */
            OMMP.Mdata = 0x7F3C;    /* same note as above */
            rez2 = RUCKMIDI(&OMMP);

            printf(" (NoteOn) ");
            printf("Note: %u, Channel: %u, Volume: %u\n",
                 (OMMP.Mdata & 0x7F),(OMMP.Mstatus & 0x0F),(OMMP.Mdata >>8));

            /*
            Using just pitchbend this alters the frequency of the note being
            played.
            It's best to use a program that remains at the sustain level
            until a NoteOff is sent--programs that have EG=1 will do so
            (a high SL is also desired)(see OutMsgMidi for more).
            */

            OMMP.Func = OutMsgMidi;
            OMMP.Mstatus = 0xE0;    /* Pitchbend, channel 0 */

            sSize = 32;             /* CPU-speed dependent effect */

            for (i=0;i<10;i++) {
                for (pitchbend=0x2000;pitchbend > 0;pitchbend-=sSize) {
                    OMMP.Mdata = pitchbend;
                    rez2 = RUCKMIDI(&OMMP);
                }
                /* might want to put a check_key exit in here */
                for (pitchbend=0;pitchbend < 0x3FFF;pitchbend+=sSize) {
                    OMMP.Mdata = pitchbend;
                    rez2 = RUCKMIDI(&OMMP);
                }
                /* here too */
                for (pitchbend=0x3FFF;pitchbend > 0x2000;pitchbend-=sSize) {
                    OMMP.Mdata = pitchbend;
                    rez2 = RUCKMIDI(&OMMP);
                }
            }

            OMMP.Func = OutMsgMidi;
            OMMP.Mstatus = 0x80;        /* NoteOff, channel 0 */
            OMMP.Mdata = 0;             /* any data */
            rez2 = RUCKMIDI(&OMMP);
            puts(" (NoteOff)");

        }
        while (1);
    }
    else
        printf("\nInitialization failed, %i\n",rez);

XMP.Func = ExitMidi;
rez = RUCKMIDI(&XMP);
return(rez);

}
