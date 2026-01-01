/*      ruckmidi.h

        Defines the RUCKUS library's structs, constants, and prototype

	v1.0d 27-Feb-94

    ***********************************************************************
    * NOTE: RUCKUS is for medium, large, or huge models (do not use tiny, *
    * ---- small, or compact since these allow for only 1 code segment).  *
    ***********************************************************************

    ALL Borland C compilers must use the MIDMEMBC.OBJ module patch for
    RUCKMIDI.LIB. See the BORLAND.ZIP file for more information.

    Struct types must be standard byte packed; do not special align elements
    ** MS-specific #pragma pack(1) and pack() used in this header file **
*/

#pragma pack(1)

int far pascal RUCKMIDI(void far *datapack);

#define SysInfoMidi     0
#define InitMidi        1
#define ExitMidi        2
#define AtExitMidi      3
#define LoadMidi        4
#define PlayMidi        5

#define EndMidi         8
#define PauseMidi       9
#define DeallocMidi     10
#define FastFwdMidi     11
#define OutMsgMidi      12

#define SetAllMidi      20
#define SetVolumeMidi   21
#define SetToneMidi     22
#define SetPatchMidi    23
#define SetChMaskMidi   24

#define SetAllFMSBP     30

/* current highest function is 30 */

struct DeallocMidiPack { /* DMP */
 unsigned Func;
 int Stat;
 unsigned HandSeg;      /* RUCKUS allocates DOS memory */
 unsigned TypeFlag;     /* 0=DOS para */
}; /* 8 */

struct FastFwdMidiPack { /* FFMP */
 unsigned Func;
 int Stat;
 long TickCount;
}; /* 8 */

struct GetDataMidiPack { /* GDMP */
 unsigned Func;
 int Stat;
 unsigned long BytePos; /* current byte relative base ptr */
}; /* 8 */

struct InitMidiPack {   /* IMP */
 unsigned Func;
 int Stat;
 unsigned DeviceID;     /* 0=OPL-2 melodic,1=OPL-2 percussive */
 unsigned IOport;
 unsigned PercCh;       /* percussive channel (0-based) */
 unsigned ChMask;       /* bitmapped */
 unsigned Flags;        /* see Appendix D. */
 void far *InfoPtr;     /* ret:far ptr to RUCKMIDI info */
 void far *MidiExitPtr; /* ret:far ptr to ExitMidi routine */
}; /* 22 */

struct LoadMidiPack {   /* LMP */
 unsigned Func;
 int Stat;
 void far *FilenamePtr;/* far ptr to filenameZ to load */
 unsigned long StartPos; /* offset into file to start load at */
 unsigned long LoadSize; /* number of bytes to load (or 0 for autosize) */
 void far *LoadPtr;    /* ret:DOS seg:offset (offset always 0) */
}; /* 20 */

struct OutMsgMidiPack { /* OMMP */
 unsigned Func;
 int Stat;
 unsigned Mstatus;      /* status byte (8n, 9n, ... En) */
 unsigned Mdata;
}; /* 8 */

struct PlaybackMidiPack { /* PBMP */
 unsigned Func;
 int Stat;
 unsigned Mode;         /* mode (0=interrupt FG,1=BG) */
 void far *LoadPtr;   /* seg:off to start of data to play */
}; /* 10 */

struct PauseMidiPack {  /* PMP */
 unsigned Func;
 int Stat;
 unsigned Pause;        /* 0=unpause else pause */
}; /* 6 */

struct SetPack {        /* SP */
 unsigned Func;
 int Stat;              /* (if volume=0 SB speaker off'ed else on'ed) */
 unsigned Volume;       /* volume (left ch=MSB,right=LSB) (0-127,0-127) */
 unsigned IntRate;      /* playback interrupt rate (5000-23000) */
 unsigned Priority;     /* priority level (0-2, default=1) */
}; /* 10 */

struct SetFMProPack {   /* SFMPP */
 unsigned Func;
 int Stat;
 unsigned IOport;       /* base I/O port (0x220, 0x240) */
 int MasterVol;         /* 0x0F0F=max (low byte=right,hi=left,-1=no change) */
 int Steer;             /* 0=none,1=left,2=right,3=mute,-1=no change */
 unsigned FMvol;        /* as MasterVol but cannot skip (i.e., cannot=-1) */
}; /* 12 */

struct SetMidiPack {     /* SMP */
 unsigned Func;
 int Stat;
 unsigned Channel;      /* channel to set (bit mask of channels 0-15) */
 int Volume;            /* volume adjust */
 int Tone;              /* tone adjust */
 unsigned ChMask;       /* if bit=0 then that channel ignored */
 int PatchMapID;        /* patch map ID */
 void far *PatchMapPtr; /* farptr to alt patch map/ret:addr of PatchMapID */
}; /* 18 */

struct SysInfoMidiPack { /* SIMP */
 unsigned Func;
 int Stat;
 unsigned Device0;    /* =1 if OPL-2 melodic mode available */
 unsigned D0port;     /* 0x388 */
 unsigned D0mask;     /* available channel mask for SMP.ChMask */
 unsigned Device1;    /* =1 if OPL-2 percussive mode available */
 unsigned D1port;
 unsigned D1mask;
}; /* 16 */

struct XitMidiPack {    /* XMP */
 unsigned Func;
 int Stat;
}; /* 4 */


/* MIDI data area structure  PUBLIC MIDIDATA in RUCKMIDI.LIB */

struct MidiDataArea {
 unsigned DeviceID;     /*+0    ;0=AdLib melodic, 1=AdLib percussive... */
 unsigned Flags;        /* 2    ;bit0=1 use background processing */
                        /*      ;bit1=1 disable program change event */
                        /*      ;bit2-7 reserved (low byte used to send */
                        /*      ;while high byte used to return info) */
                        /*      ;bit8-13 reserved */
                        /*      ;bit14=1 then CTMF file playing */
                        /*      ;bit15=1 then AdLib ROL-convert */
 unsigned PercChannel;  /* 4    ;<> 0 percussion channel mapped to here */
 unsigned End;          /* 6    ;=1 end of MIDI (not playing) */
 unsigned MemDOS;       /* 8    ;DOS RAM available */
 unsigned MemUsed;      /* 10   ;K used by last load */
 unsigned TypeMIDI;     /* 12   ;MIDI type (0 or 1) */
 unsigned NoTracks;     /* 14   ;number of tracks */
 unsigned TicksQnote;   /* 16   ;ticks/quarter-note */

 unsigned long uSecsQnote;/* 18   ;micro-secs/quarter-note */
 unsigned long TickCount; /* 22   ;current tick count */

 void far *MusicPtr;  /* 26   ;farptr to current MIDI data byte */
 unsigned CurrTrk;      /* 30   ;current MIDI track */
 char TimeSig[4];       /* 32   ;nm,dn,MIDI clocks/beat,32nd notes/beat */
 char ChPrograms[16];   /* 36   ;channel programs */
 char ChVolumes[16];    /* 52   ;channel volume level (0-127) */
 char ChNotes[16];      /* 68   ;channel note values (0-127) */

 unsigned ChRelVolumes[16];/* 84   ;-128 to +127 range (0=no change) */
 unsigned ChRelNotes[16];  /* 116  ;-128 to +127 range (0=no change) */
};

#pragma pack()

/* end of ruckdac.h */
