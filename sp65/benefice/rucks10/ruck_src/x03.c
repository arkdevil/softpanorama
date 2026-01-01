
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "ruckdac.h"

/*
X03.c 27-Feb-94 chh
Record from device to DOS memory or XMS
removed C7-specific _ all over the place
*/

/*
The following structures are in ruckdac.h
*/

#pragma pack(1)

extern struct DacDataArea pascal DACDATA;

struct SysInfoPack SIP;
struct InitPack IP;
struct XitPack XP;
struct LoadPack LP;
struct SetPack SP;
struct SetProPack SPP;
struct PlaybackPack PBP;
struct RecordPack RP;
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
            *XMSflag = -1;      /* XMS memory selected with SB */
                                /* use -1 so as to auto-alloc below */
            td-=2;              /* map to appropriate device */
        }

        if ((td >=4) && (td <=5)) { /* validate device selected is available */
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
    */

    IP.Func = InitDac;
    IP.DeviceID = devID;
    IP.IOport = SIP.SD[devID].Port;
    IP.IRQline = SIP.SD[devID].IRQ;
    IP.DMAch = SIP.SD[devID].DMA;

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
    unsigned int RecSecs=5, RecRate=12000;


    printf("X03.C - RUCKUS-DAC record to memory example. [930228]\n");

    rez = pick_device(&devID, &XMSflag);
    if (devID >= 0) {
        printf("Initializing devID %u\n",devID);
        rez = init_device(devID);

        /*
        The following record example source is coded inline here
        to simply readability -- but it's so easy to add things that I just
        kept adding stuff, so take it slow if you don't follow at first
        */

        if (rez == 0) {

            /*
            Select input source
            */

            SPP.Func = SetSourceSBP;
            SPP.SourceIn = 0;       /* 0=mic,1=CD,2=line */
            rez = RUCKDAC(&SPP);    /* should always check rez status */
                                    /* (not like I'm doing here!) */

            printf("   Device ID: %u\n",devID);
            printf(" Record from: mic\n");
            printf(" Record time: %u secs\n",RecSecs);
            printf(" Record rate: %u Hz\n",RecRate);

            /*
            Following is memory available for record. We don't use
            it (but should) and just record for 5 secs at 12kHz (~60K)
            */

            if (XMSflag == 0) {
                printf(" Memory type: DOS\n");
                printf("K bytes free: %u\n",DACDATA.MemDOS);
            }
            else {
                printf(" Memory type: XMS\n");
                printf("K bytes free: %u\n",DACDATA.MemXMM);
            }

            /*
            Prepare for record (5 secs at 12000Hz sample rate)
            */

            RP.Func = RecordDac;
            RP.SampleRate = RecRate;
            RP.XMMhandle = XMSflag;   /* if -1 auto-alloc an XMS handle */
            RP.RecordPtr = NULL;      /* if DOS mem then auto-alloc it */
                                      /* also used to return ptr after Rec*/

            /* RecordBytes limit is 16MB (VOC block limit) */

            RP.RecordBytes = ((long)RecRate * (long)RecSecs);
            RP.StereoFlag = 0;  /* recording from mic is mono */

            printf("\nPress Enter to begin recording...");
            gets(filename);

            rez = RUCKDAC(&RP);

            /*
            Since record is done as a background DMA task, we can do just
            about anything we want while the recording is taking place.
            Here, I'll just wait until the recording is over
            */

            do                          /* I don't think DACDATA needs a  */
                ;
            while (DACDATA.End == 0);   /* VOLATILE... CONST... both... ? */

            /*
            Recording over. Play it back.
            */

            printf("Recorded %lu bytes, press Enter to playback recording...",DACDATA.RecordLen);
            gets(filename);

            PBP.Func = PlayDac;
            PBP.Mode = 2;
            if (XMSflag == 0) {
                PBP.XMMhandle = 0;
                PBP.LoadPtr = RP.RecordPtr;
            }
            else {
                PBP.XMMhandle = RP.XMMhandle;
                PBP.LoadPtr = NULL;
            }
            rez = RUCKDAC(&PBP);

            do                          /* hang around until it's done */
                ;
            while (DACDATA.End == 0);

            XP.Func = EndDac;           /* end play */
            rez = RUCKDAC(&XP);

            /*
            Release memory used by RecordDac (ExitDac would do that, too)
            */

            DP.Func = DeallocDac;
            if (XMSflag == 0) {
		DP.HandSeg = FP_SEG(RP.RecordPtr);
                DP.TypeFlag = 0;
            }
            else {
                DP.HandSeg = RP.XMMhandle;
                DP.TypeFlag = 1;
            }
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
