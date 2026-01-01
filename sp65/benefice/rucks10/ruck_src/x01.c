
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "ruckdac.h"

/*
X01.c 28-Feb-94 chh
Load & Play VOC/WAV file
removed C7-specific _ all over the place
*/

/*
The following structures are in ruckdac.h
*/

#pragma pack(1)  /* must have byte-aligned structures for Ruckus */

extern struct DacDataArea pascal DACDATA;

struct SysInfoPack SIP;
struct InitPack IP;
struct XitPack XP;
struct LoadPack LP;
struct SetPack SP;
struct SetProPack SPP;
struct PlaybackPack PBP;
struct GetDataPack GDP;
struct DeallocPack DP;

#pragma pack()

int rez, rez2;      /* result status codes */
char nums[9] = {7}; /* number buffer for _cgets()*/
char filename[81];  /* pathname to load */


int pick_device(int *devID, int *XMSflag)
{

    int td=0;

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
            printf("\n6. Sound Blaster Pro, port %xh",SIP.SD[5].Port);
        if (SIP.SD[4].device)
            printf("\n\n7. Sound Blaster as 5 but use XMS (if applicable)");
        if (SIP.SD[5].device)
            printf("\n8. Sound Blaster Pro as 6 but use XMS (if applicable)\n");

        printf("\nSelection: ");
	td = atoi(cgets(nums));
        td--;   /* since devices are numbered 0 to 5 */

        if (td > 6) {
            *XMSflag = 1;       /* XMS memory selected with SB */
            td-=2;              /* map to appropriate device */
        }

        if ((td >=0) && (td <=5)) { /* validate device selected available */
            if (SIP.SD[td].device == 0)
                td = -1;
        }
        else
            td = -1;
    }

    *devID = td;
    return(rez);
}


int init_device(int devID)
{
    /*
    Initialize RUCKDAC and device and register ExitDac with _atexit
    The IP.port for devices 0 and 3 are set to 0 for low-rez mode,
    or their respective actual ports for hi-rez mode (0x42 and 0x388)
    */

    IP.Func = InitDac;
    IP.DeviceID = devID;
    IP.IOport = SIP.SD[devID].Port;
    IP.IRQline = SIP.SD[devID].IRQ;
    IP.DMAch = SIP.SD[devID].DMA;

    if ((devID == 0) || (devID == 3))   /* use low-rez mode for */
        IP.IOport = 0;                  /* PC speaker and Adlib */

    rez = RUCKDAC(&IP);                 /* Initialize */
    if (rez == 0) {

        XP.Func = AtExitDac;
        rez2 = RUCKDAC(&XP);
        if (rez2 != 0) {
            printf("AtExitDac failed, press Enter to continue");
            getchar();
        }


        /*
        Increase SB Pro main and vol volumes to max
        */

        if (devID == 5) {
            SPP.Func = SetVolMainSBP;
            SPP.Volume = 0x0F0F;
            rez2 = RUCKDAC(&SPP);
            SPP.Func = SetVolVocSBP;
            SPP.VolVoc = 0x0F0F;
            rez2 = RUCKDAC(&SPP);
        }
    }
    return(rez);
}


int main()
{

    int devID=-1, XMSflag = 0;

    printf("X01.C - RUCKUS-DAC play of VOC or WAVE file example. [930228]\n");

    rez = pick_device(&devID, &XMSflag);
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

            printf("\nVOC/WAVE filename: ");
            gets(filename);

            LP.Func = LoadDac;
            LP.FilenamePtr = filename;
            LP.StartPos = 0L;           /* start at first byte */
            LP.LoadSize = 0L;           /* autoload entire file */
            LP.XMMflag = XMSflag;
            rez = RUCKDAC(&LP);
            if (rez == 0) {
                /*
                Immediately after load, but before play (if non-DMA), we can
                peek into the DAC data to get the file's recorded sample rate
                */

                printf(" Sample rate: %u\n",DACDATA.SampleRate);
                printf(" File format: ");
                if (DACDATA.Stereo != 0)
                    printf("stereo ");
                else
                    printf("mono ");
                if (DACDATA.Type == 1)
                    printf("VOC\n");
                else
                    printf("WAV\n");

                /*
                Data is loaded, if device is a Sound Blaster use DMA at
                file sample rate else set rate to either file sample rate or,
                if > 11025 (most ATs can handle 11kHz in non-DMA mode) then
                set to 8000 Hz
                */

                PBP.Func = PlayDac;
                if (devID >= 4)
                    PBP.Mode = 2;
                else {
                    PBP.Mode = 1;

                    /*
                    Non-DMA mode needs to be set to a specific playback rate.

                    To play hal.voc using PCSPKR1 (the hi-rez mode) set
                    SP.IntRate=8463. This results in upsample rate of 17045Hz
                    */

                    if (DACDATA.SampleRate < 11025)
                        SP.IntRate = DACDATA.SampleRate;
                    else
                        SP.IntRate = 8000;

                    SP.Func = SetIntRateDac;
                    rez = RUCKDAC(&SP); /* set the playback rate */
                    /* should check for errors in production code*/
                }

                /*
                Load the file to DOS RAM or XMS
                */

                if (LP.XMMflag == 0) {
                    PBP.XMMhandle = 0;
                    PBP.LoadPtr = LP.LoadPtr;
                }
                else {
                    PBP.XMMhandle = LP.XMMhandle;
                    PBP.LoadPtr = NULL;
                }
                rez = RUCKDAC(&PBP);

                /*
                Playing in the background, wait until down or key pressed.
                To check if data done playing, read DACDATA.End. If non-zero
                then done playing. Note that once play has actually begun,
                the DACDATA.SampleRate is set to the actual playback rate,
                not necessarily the same as the rate at load time.
                */

                if (rez == 0) {
                    printf("   Device ID: %u\n",devID);
                    printf("   Play rate: %u Hz\n",DACDATA.SampleRate);

                    if (LP.XMMflag == 0) {
                        printf(" Memory type: DOS\n");
                        printf("K bytes left: %u\n",DACDATA.MemDOS);
                        printf("K bytes used: %u\n",DACDATA.MemUsed);
                        printf("Load address: %Fp\n",LP.LoadPtr);
                    }
                    else {
                        printf(" Memory type: XMS\n");
                        printf("K bytes left: %u\n",DACDATA.MemXMM);
                        printf("K bytes used: %u\n",DACDATA.MemUsed);
                        printf("  XMS handle: %u\n",LP.XMMhandle);
                    }


                    GDP.Func = GetBytePosDac;
                    do {
                        rez = RUCKDAC(&GDP);
                        if (GDP.BytePos != 0)
                            printf("Current byte: %LX\r",GDP.BytePos);
                    }
                    while (DACDATA.End == 0);
                    puts("");


                    /*
                    End play
                    */

                    XP.Func = EndDac;
                    rez = RUCKDAC(&XP);


                    /*
                    Release memory/handle used by LoadDac
                    (ExitDac would do this, too)
                    */

                    DP.Func = DeallocDac;
                    if (LP.XMMflag == 0) {
			DP.HandSeg = FP_SEG(LP.LoadPtr);
                        DP.TypeFlag = 0;
                    }
                    else {
                        DP.HandSeg = LP.XMMhandle;
                        DP.TypeFlag = 1;
                    }
                    rez = RUCKDAC(&DP);  /* should error check in procode */
                }
                else
                    printf("Play failed, %u\n",rez);
            }
            else
                printf("Load failed, %u\n", rez);
        }
        else
            printf("Initialization failed, %u\n", rez);
    }
    else
        puts("Device pick failed");

XP.Func = ExitDac;
rez = RUCKDAC(&XP);
return(rez);

}
