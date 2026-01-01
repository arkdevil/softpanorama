
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "ruckdac.h"

/*
X02.c 27-Feb-94 chh
Load & Play mod file
removed the C7-specific _ all over the place
*/

/*
The following structures are in ruckdac.h
*/

/*
DACDATA is in DGROUP so could probably get away with a __near here dear
*/

#pragma pack(1)  /* must byte-align any Ruckus data structure */

extern struct DacDataArea pascal DACDATA;

struct SysInfoPack SIP;
struct InitPack IP;
struct XitPack XP;
struct LoadPack LP;
struct SetModPack SMP;
struct SetProPack SPP;
struct PlaybackPack PBP;

#pragma pack()

int rez, rez2;      /* result status codes */
char nums[9] = {7}; /* number buffer for _cgets()*/
char filename[81];  /* pathname to load */

/* typedef unsigned int uint; */

int pick_device(int *devID, unsigned int *HighRate)
{

    /*
    Just ask for device to use and return it and that device's effective
    top-end rate (nothing concrete in the returned top-end...)
    */

    int td=0;

    *HighRate = 0;

    SIP.Func = SysInfoDac;
    rez = RUCKDAC(&SIP);
    if (rez == 0) {
        printf("CPU is a %u/%u\n",SIP.CPU,SIP.MHz);

        printf("\n0. End program");
        printf("\n1. PC speaker at port 42h");
        if (SIP.SD[1].device)
            printf("\n2. LPT-DAC on LPT1, port %xh",SIP.SD[1].Port);
        if (SIP.SD[2].device)
            printf("\n3. Disney Sound Source port %xh",SIP.SD[2].Port);
        if (SIP.SD[3].device)
            printf("\n\n4. AdLib Music Synthesizer Card, port %xh",SIP.SD[3].Port);
        if (SIP.SD[4].device)
            printf("\n5. Sound Blaster, port %xh",SIP.SD[4].Port);
        if (SIP.SD[5].device)
            printf("\n6. Sound Blaster Pro, port %xh\n",SIP.SD[5].Port);

        /*
        Can't play mods from XMS (well...)
        BTW, if this code looks familiar, it's because it is (see X01.C)
        */

        printf("\nSelection: ");
	td = atoi(cgets(nums));
        td--;   /* since devices are numbered 0 to 5 */

        if ((td >=0) && (td <=5)) { /* validate device selected available */
            if (SIP.SD[td].device == 0)
                td = -1;
        }
        else
            td = -1;

        switch (td) {
        case 0:                     /* 0 - PC speaker     */
            *HighRate = 18000;      /* 1 - LPT-DAC        */
            break;                  /* 2 - Sound Source   */
        case 1:                     /* 3 - AdLib          */
            *HighRate = 23000;      /* 4 - Sound Blaster  */
            break;                  /* 5 - Sound Blaster Pro ((STEREO)) */
        case 2:
            *HighRate = 7000;
            break;
        case 3:
            *HighRate = 12000;
            break;
        case 4:
            *HighRate = 23000;
            break;
        case 5:
            *HighRate = 22750;  /* ((STEREO)) 2*22750=45500Hz*/
            break;
        default:
            td=-1;
        }
    }

    *devID = td;
    return(rez);
}


int init_device(int devID)
{
    /*
    Initialize RUCKDAC and device and register ExitMod with _atexit.
    Mod play does not have a hi-rez mode for PC speaker & AdLib as does Dac.
    */

    IP.Func = InitDac;
    IP.DeviceID = devID;
    IP.IOport = SIP.SD[devID].Port;
    IP.IRQline = SIP.SD[devID].IRQ;
    IP.DMAch = SIP.SD[devID].DMA;

    rez = RUCKDAC(&IP);                 /* Initialize */
    if (rez == 0) {
        XP.Func = AtExitMod;            /* Try this with based pointers */
        rez2 = RUCKDAC(&XP);            /* in use...could be a C7 bug   */
        if (rez2 != 0) {                /* since _atexit seems to share */
                                        /* (overwrite) memory used by   */
                                        /* the compiler's __based data  */
                                        /* Could just be me...  `       */
            printf("AtExitMod failed, press Enter to continue");
            getchar();
        }
    }
    return(rez);
}


int main()
{

    int devID=-1;
    unsigned int HighRate=5000, SampleRate=5000;

    printf("X02.C - RUCKUS-DAC play of MOD file example. [930228]\n");

    rez = pick_device(&devID, &HighRate);
    if (devID >= 0) {
        printf("Initializing devID %u\n",devID);
        rez = init_device(devID);

        /*
        The following load and play example source is coded inline here
        to simply readability -- but it's so easy to add things that I just
        kept adding stuff, so take it slow if you don't follow at first
        */

        if (rez == 0) {

            /* load file and setup playback parameters */

            printf("\n MOD filename: ");
            gets(filename);
            printf("\n                      (5000-%u)",HighRate);
            printf("\rPlayback rate: ");
	    SampleRate = atoi(cgets(nums));
            if (SampleRate < 5000)
                SampleRate = 5000;
            if (SampleRate > HighRate)
                SampleRate = HighRate;

            LP.Func = LoadMod;
            LP.FilenamePtr = filename;
            LP.StartPos = 0L;           /* start at first byte */
            LP.LoadSize = 0L;           /* autoload entire file */
            LP.XMMflag = 0;             /* LP.XMMflag always=0 */
            rez = RUCKDAC(&LP);
            if (rez == 0) {

               /*
               Increase SB Pro main and vol volumes to max (we bad now)
               */

               if (devID == 5) {
                  SPP.Func = SetVolMainSBP;
                  SPP.Volume = 0x0F0F;
                  rez2 = RUCKDAC(&SPP);
                  SPP.Func = SetVolVocSBP;
                  SPP.VolVoc = 0x0F0F;
                  rez2 = RUCKDAC(&SPP);
               }

                /*
                set mod channel volumes to max
                */

                SMP.VolCh1 = 255;
                SMP.VolCh2 = 255;
                SMP.VolCh3 = 255;
                SMP.VolCh4 = 255;
                SMP.Func = SetVolumeMod;
                rez2 = RUCKDAC(&SMP);  /* always error check! */

                /*
                if SB Pro play in stereo
                */

                if (devID < 5)
                    SMP.Stereo = 0;
                else
                    SMP.Stereo = 1;
                SMP.Func = SetStereoMod;
                rez2 = RUCKDAC(&SMP);

                SMP.IntRate = SampleRate;

                /*
                The SB Pro doubles the sample rate when doing stereo output
                so here we double the requested rate to rate needed by SBPro.
                This should be done _AFTER_ the SetStereoMod call above
                */

                if (SMP.Stereo !=0)
                    /* double rate if stereo */
                    SMP.IntRate = SampleRate + SampleRate;

                SMP.Func = SetIntRateMod;
                rez2 = RUCKDAC(&SMP);

                /*
                SetFastMod can be used to play at higher rates than would
                otherwise be possible. The default is FastMod off and
                SliceAdj=1. On XTs, FastMod=1 may make the difference
                between being able to play mods at all. The SliceAdj is
                the number of bytes processed and stuffed into the DMA
                buffers per timer interrrupt. The default is typically
                sufficient to keep the DMA buffers full on fast machines,
                but on slower CPUs, a higher SliceAdj will make for a
                higher playback rate allowable. Actually, the code below
                doesn't change the defaults so I'll comment it out.
                Play around with the settings if you need to. (SliceAdj
                is relevant for DMA devices only, like the Sound Blasters.)
                */

                SMP.Func = SetFastMod;
                SMP.FastMode = -1;      /* skip fastmode adjust */
                SMP.SliceAdj = 1;       /* default = 1, range 1-4096 */
                /* rez1 = RUCKDAC(&SMP) */


                /*
                if DMA device use DMA foreground processing, else timer-0 FG
                */

                PBP.Func = PlayMod;
                if (devID < 4)
                    PBP.Mode = 0;
                else
                    PBP.Mode = 2;

                /*
                For timer-0 background play set PBP.Mode = 1 and for
                DMA background play set PBP.Mode = 3 -- you must also poll
                DACDATA.EndOfMod and wait until it is non-zero to determine
                if mod playback has completed
                */

                /*
                For complete compatibility mod play is done as a
                foreground task in this example.
                */

                printf("Playing as a foreground ");
                if (devID >= 4)
                    printf("DMA");
                else
                    printf("TIMER-0");

                printf(" task ");
                if (devID == 5)
                    printf("in ((STEREO)) ");

                printf("at %u Hz mix rate\n\n", SampleRate);
                printf("Press CTRL-ALT to end or wait until tune is over.\n");

                /*
                Note that the PC speaker playback may sound better if the
                keyboard pause button is activated, try it
                */

                PBP.XMMhandle = 0;   /* just because */

                /*
                Note that PBP.LoadPtr is not used with mod playback since
                only one mod can be in memory at a time. The BufferSize below
                is allocated for DMA devices only (i.e., it's disreagard if
                PBP.Mode < 2) and 2 buffers are setup. For example, if
                PBP.BufferSize=4096, 2 4K buffers are allocated. 4096 works
                well in most cases (range is 2048 to 65520 bytes) and
                larger buffer size is usually needed only for slow CPUs with
                high playback rates.
                */

                PBP.BufferSize = 4096;
                rez = RUCKDAC(&PBP);

                /*
                Since PBP.Mode is a foreground mode, we don't get here
                until CTRL-ALT is pressed or the tune is over. Since
                that's so, we EndMod. If doing a background mode, then
                we go off and do whatever we want, but must periodically
                check DACDATA.EndOfMod for non-zero, in which case the tune
                is over.
                */

                if (rez==0) {
                    XP.Func = EndMod;
                    rez2 = RUCKDAC(&XP);

                    /*
                    To release memory used by LoadMod use ExitMod
                    */
                }
                else
                    printf("Play failed, %i\n",rez);
            }
            else
                printf("Load failed, %i\n",rez);
        }
        else
            printf("Initialization of device %u failed, %i\n",devID,rez);
    }
    else
        puts("Device pick failed");

XP.Func = ExitMod;
rez = RUCKDAC(&XP);
return(rez);

}
