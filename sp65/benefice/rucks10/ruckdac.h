/*      ruckdac.h

        Defines the RUCKUS library's structs, constants, and prototype

	v1.0d 27-Feb-94

    ***********************************************************************
    * NOTE: RUCKUS is for medium, large, or huge models (do not use tiny, *
    * ---- small, or compact since these allow for only 1 code segment).  *
    ***********************************************************************

    ALL Borland C compilers must use the DACMEMBC.OBJ module patch for
    RUCKDAC.LIB. See the BORLAND.ZIP file for more information.

    Struct types must be standard byte packed; do not special align elements
    ** MS-specific #pragma pack(1) and pack() used in this header file **
*/

#pragma pack(1)

int far pascal RUCKDAC(void far *datapack);

#define SysInfoDac      0
#define InitDac         1
#define ExitDac         2
#define AtExitDac       3
#define LoadDac         4
#define PlayDac         5
#define RecordDac       6
#define StoreDac        7
#define EndDac          8
#define PauseDac        9
#define DeallocDac      10

#define SetAllDac       20
#define SetVolumeDac    21
#define SetIntRateDac   22
#define SetPriorityDac  23
#define GetBufferDataDac 28
#define GetBytePosDac   29

#define SetAllSBP       30
#define SetVolMainSBP   31
#define SetVolVocSBP    32
#define SetLevelMicSBP  33
#define SetLevelCDSBP   34
#define SetLevelLineSBP 35
#define SetFilterOutSBP 36
#define SetFilterInSBP  37
#define SetSourceSBP    38
#define SetStereoSBP    39

#define SetSpeakerSB    40
#define GetMixerRegSBP  48
#define GetDacSB        49

#define ExitMod         50
#define AtExitMod       51
#define LoadMod         52
#define PlayMod         53
#define EndMod          54
#define PauseMod        55
#define SetIntRateMod   56
#define SetSpeedMod     57
#define SetVolumeMod    58
#define SetPositionMod  59
#define SetStereoMod    60
#define SetFastMod      61

/* current highest function is 61 */

struct DeallocPack {    /* DP */
 unsigned Func;
 int Stat;
 unsigned HandSeg;      /* RUCKUS allocates either XMM handle or DOS para */
 unsigned TypeFlag;     /* 0=DOS para, 1=XMS handle */
}; /* 8 */

struct GetDataPack {    /* GDP */
 unsigned Func;
 int Stat;
 unsigned long BytePos; /* current byte relative base ptr (27) */
 char far *BufferPtr; /* far pointer to buffer to fill with data */
 long StartPos;         /* start get at this offset relative BufferPtr */
 unsigned BufferCnt;    /* bytes to fill (2-65520) */
 unsigned MixerReg;     /* SBPro mixer register to get */
}; /* 20 */

struct InitPack {       /* IP */
 unsigned Func;
 int Stat;
 unsigned DeviceID;     /* 0=SPKR,1=LPTDAC,2=DSS,4=SB,5=SBPro */
 unsigned IOport;
 unsigned IRQline;
 unsigned DMAch;
 unsigned Flags;        /* see Appendix D. */
 void far *InfoPtr;     /* ret:far ptr to dac info */
 void far *DacExitPtr;  /* ret:far ptr to dac's ExitDac routine */
 void far *ModExitPtr;  /* ret:far ptr to mod's ExitMod routine */
}; /* 26 */

struct LoadPack {       /* LP */
 unsigned Func;
 int Stat;
 void far *FilenamePtr;/* far ptr to filenameZ to load */
 unsigned long StartPos; /* offset into file to start load at */
 unsigned long LoadSize; /* number of bytes to load (or 0 for autosize) */
 int XMMflag;            /* if <> 0 use XMS for load */
 int XMMhandle;          /* ret:XMS handle, or */
 void far *LoadPtr;    /* ret:DOS seg:offset (offset always 0) */
}; /* 24 */

struct PlaybackPack {   /* PBP */
 unsigned Func;
 int Stat;
 unsigned Mode;         /* mode (0=interrupt FG,1=BG,2=DMA,3=DMA+BG for mod) */
 unsigned XMMhandle;    /* if <> 0 this XMM handle used regardless */
 void far *LoadPtr;   /* seg:off to start of data to play */
 unsigned BufferSize;   /* size of DMA buffer for mod playback */
}; /* 14 */

struct PausePack {      /* PP */
 unsigned Func;
 int Stat;
 unsigned Pause;        /* 0=unpause else pause */
}; /* 6 */

struct RecordPack {     /* RP */
 unsigned Func;
 int Stat;
 unsigned SampleRate;
 int XMMhandle;         /* -1 auto XMS (ret here) else use this handle */
 void far *RecordPtr; /* seg:off of buffer to store (0 for auto-store) */
 unsigned long RecordBytes; /* bytes to record */
 unsigned StereoFlag;   /* stereo flag */
}; /* 18 */

struct SaveDataPack {   /* SDP */
 unsigned Func;
 int Stat;
 void far *FilenamePtr; /* far ptr to filenameZ to save */
 void far *DataPtr;   /* pointer to start of data to save */
 unsigned FileType;     /* 1=VOC,2=WAV */
 unsigned XMMhandle;    /* XMS handle of data to save (0 if DOS data) */
}; /* 16 */

struct SetPack {        /* SP */
 unsigned Func;
 int Stat;              /* (if volume=0 SB speaker off'ed else on'ed) */
 unsigned Volume;       /* volume (left ch=MSB,right=LSB) (0-127,0-127) */
 unsigned IntRate;      /* playback interrupt rate (5000-23000) */
 unsigned Priority;     /* priority level (0-2, default=1) */
}; /* 10 */

struct SetModPack {     /* SMP */
 unsigned Func;
 int Stat;
 unsigned VolCh1;       /* channel volume (0-255) */
 unsigned VolCh2;       /* channel volumes adjustments made only */
 unsigned VolCh3;       /*  if FastMode=0 */
 unsigned VolCh4;
 unsigned Stereo;       /* playback mode (0=mono,stereo 1,2,3) */
 int FastMode;          /* fast playback (0=normal,1 fast,-1 skip) */
 unsigned IntRate;      /* playback interrupt rate (5000-45500) */
 unsigned Position;     /* pattern list position (0-patterns to play) */
 unsigned Speed;        /* overall playback speed (1-15,default=6,15=slow) */
 unsigned SliceAdj;     /* slice adjust (1-4096,default=1) set via FastMod */
}; /* 24 */

struct SetProPack {     /* SPP */
 unsigned Func;
 int Stat;
 unsigned Volume;       /* volume (low=right;0-15, high byte=left;0-15) */
 unsigned VolVoc;
 unsigned VolMic;       /* (mono only, 0-7) input level */
 unsigned VolCD;        /* input level (0-15,0-15) */
 unsigned VolLI;        /* input level (0-15,0-15) */
 unsigned FilterOut;    /* 0=filter off, 1=filter on */
 unsigned FilterIn;     /* 0=filter off, 1=3.2kHz, 2=8.8kHz */
 unsigned SourceIn;     /* 0=mic,1=CD,2=line */
 unsigned StereoIn;     /* 0=mono,1=stereo record */
}; /* 22 */

struct XitPack {        /* XP */
 unsigned Func;
 int Stat;
}; /* 4 */

struct SysDev {         /* SD (used by SysInfoPack below) */
 int device;            /* =1 device available */
 unsigned Port;
 unsigned IRQ;
 unsigned DMA;
 unsigned Flags;        /* bit4=MIDI/3=XMS/2=DMA/1=REC/0=PLAY */
}; /* 10 */

struct SysInfoPack {    /* SIP */
 unsigned Func;
 int Stat;
 unsigned CPU;          /* CPU class (88,286,386,486) */
 unsigned CPUmode;      /* 0=real mode,1=PM,2=PM w/paging */
 unsigned MHz;          /* approx speed (5,20,33) */
 struct SysDev SD[6];
}; /* 70 */


/* dac and mod data area structure */

struct DacDataArea {
 unsigned DeviceID;     /* 0   ;device ID */
 unsigned IOport;       /* 2   ;port of device */
 unsigned IRQ;          /* 4   ;IRQ of device */
 unsigned DMA;          /* 6   ;DMA of device */
 unsigned Flags;        /* 8   ;bit0=1 use DOS UMB memory */
                        /*     ;bit1-3 reserved */
                        /*     ;bit4=1 force SBPro device if SB15 (DSPtype=3) */
                        /*     ;       (but DSPversion remains same) */
                        /*     ;bit5=1 force XMS2 to be used */
                        /*     ;bit6=1 force device speaker on until exit */
                        /*     ;bit7=1 force passed parms to be used */
                        /*     ;       Following values are ret bits */
                        /*     ;bit8=1 paging mechanism in force, no UMBs */
                        /*     ;bit9-15 reserved */
 unsigned End;          /* 10  ;=1 end of play (dac play,does not include mod) */
 unsigned Pause;        /* 12  ;=1 pause play */
 unsigned EndOfMod;     /* 14  ;=1 end of mod play (when dac@end AND dac@endmod */
                        /*     ;   both are 1 then play is done) */
 unsigned MemDOS;       /* 16  ;DOS memory available (in K) */
 unsigned MemXMM;       /* 18  ;XMS memory available (in K) */
 unsigned Type;         /* 20  ;digital file type (1=VOC,2=WAV,3=MOD) */
 unsigned MemUsed;      /* 22  ;memory used for last file load (in K) */
 unsigned SampleRate;   /* 24  ;sample rate currently playing */
 unsigned Stereo;       /* 26  ;stereo playback (data is stereo) */
 unsigned long VocLen;  /* 28  ;length of voc block (only current block) */
 void far *VocPtrPtr; /* 32  ;pointer to pointer->current data */
 unsigned long RecordLen;/*36  ;length of recorded data */
}; /* 40 */


struct ModData {

 void near *chInfoPtr;/* -2  ;near ptr to channel info (not listed) */

 unsigned Type;         /*  0  ;mod type (15 or 31 samples) */
 unsigned Samples;      /*  2  ;number of instrument samples in mod */
 unsigned HeaderSeg;    /*  4  ;header segment (aka sample info) */
 unsigned PatternSeg;   /*  6  ;patterns' segment (1 to pats2play 1K pats) */
 unsigned SampleSeg[31];/*  8 (+62) ;list of sample segments */

 unsigned Stereo;       /* 70  ;=1 then play in stereo (only SBPro can set) */
 unsigned FastMode;     /* 72  ;=1 then channel volume adjusts disabled */

 unsigned PatListPos;   /* 74  ;byte position within mod@patterList (0-127) */
 unsigned NotePatPos;   /* 76  ;note position within pattern 1K area (0-1008) */
                        /*     ;pattern#=patternList(patListPos) */
                        /*     ;note is at offset (pattern#*1024)+notePatPos */
                        /*     ;-- in segment mod@patternSeg */
 unsigned HiPattern;    /* 78  ;highest pattern number to play/+1!/ (0-63) */
 unsigned Pats2play;    /* 80  ;patterns to play (direct DOS file load here) */
 char PatternList[128]; /* 82  (+128) ;pattern positions (to here) */
 char MKoverflow[6];    /*210 (+6)   ;overflow for 31-instr patpos read */

 unsigned MemUsed;      /*216 ;DOS mem needed by mod file loaded (in para) */
 unsigned long VS;      /*218 ;times VS handler entered (50Hz rate) */
}; /* 222 */

#pragma pack()

/* end of ruckdac.h */
