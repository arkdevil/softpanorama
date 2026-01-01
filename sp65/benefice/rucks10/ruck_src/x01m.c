
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "ruckmidi.h"

/*
X02M.c 27-Feb-94 chh
Load & Play MIDI file
removed C7-specific _ all over the place
*/

/*
The following structures are in ruckmidi.h
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

    printf("\nX01M.C - RUCKUS-MIDI load & play of file example. [930228]\n");

    /*
    Initialize RUCKMIDI and device and register ExitMidi with _atexit
    */

    IMP.Func = InitMidi;
    IMP.DeviceID = 1;           /* OPL-2 percussive mode */
    IMP.IOport = 0x388;

    if (IMP.DeviceID == 1) {
       IMP.ChMask = 0x23F;      /* mask for channels 0-5, 9 */
       IMP.PercCh = 9;
    }
    else {
       IMP.ChMask = 0x1FF;      /* mask for channels 0-8 */
       IMP.PercCh = 0;
    }

    IMP.Flags = 0;
    rez = RUCKMIDI(&IMP);       /* Initialize */
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
        Set patch map to GM or MT-32, here I'll use GM (jazz.mid is GM)
        */

        SMP.Func = SetPatchMidi;
        SMP.PatchMapID = 0;     /* actually, this is the GM is the default */
        SMP.PatchMapPtr = NULL;
        rez2 = RUCKMIDI(&SMP);

        if (SMP.PatchMapID==0)
            puts("Using General MIDI map");
        else
            puts("Using MT-32 MIDI map");

        /*
        Load a single MIDI file and play it
        */

        if (rez == 0) {
            /* load file and setup playback parameters */
            /* rez==0 always in this example */

            printf("\nMIDI filename: ");
            gets(filename);

            LMP.Func = LoadMidi;
            LMP.FilenamePtr = filename;
            LMP.StartPos = 0L;          /* start at first byte */
            LMP.LoadSize = 0L;          /* autoload entire file */
            rez = RUCKMIDI(&LMP);
            if (rez == 0) {

                printf("K bytes left: %u\n",MIDIDATA.MemDOS);
                printf("K bytes used: %u\n",MIDIDATA.MemUsed);

                PBMP.Func = PlayMidi;
                PBMP.Mode = 1;          /* background mode a must */
                PBMP.LoadPtr = LMP.LoadPtr;
                rez = RUCKMIDI(&PBMP);

                if (rez == 0) {
                    do
                       printf("\rCurrent tick: %lx",MIDIDATA.TickCount);
                    while ( MIDIDATA.End == 0);

                    /*
                    End play
                    */

                    XMP.Func = EndMidi;
                    rez2 = RUCKMIDI(&XMP);
                }
                else {
                    printf("Play failed, %u\n",rez);

                /*
                Release memory/handle used by LoadMidi
                (ExitMidi would do this, too)
                */

                DMP.Func = DeallocMidi;
		DMP.HandSeg = FP_SEG(LMP.LoadPtr);
                DMP.TypeFlag = 0;
                rez = RUCKMIDI(&DMP);  /* should error check in procode */
                }
            }
            else
                printf("Load failed, %u\n", rez);
        }  /* rez==0 always if*/
    }
    else
        printf("Initialization failed, %u\n", rez);

XMP.Func = ExitMidi;
rez = RUCKMIDI(&XMP);
return(rez);

}
