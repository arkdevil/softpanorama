/***************************************************************/
/*                                                             */
/*                 KIVLIB include file STRUCTS.H               */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/****************************************************************/

#ifndef ___STRUCTS___
#define ___STRUCTS___


typedef struct  {
		void far *   next;
		unsigned int attr;
		unsigned int strateg;
		unsigned int interr;
		union {
		  struct {
		      unsigned char count;
		      unsigned char reserv[7];
		      } block_d;
		      char name[8];
		} head;
		} DriveDescType;

typedef  struct {
		 char typ;
		 unsigned int owner;
		 unsigned int size;
		 unsigned char reserv[11];
		 }  MCBType;

typedef struct {
	       unsigned int mcbseg;
	       void far *   devcb;
	       void far *   filetab;
	       void far *   clockdr;
	       void far *   condr;
	       void far *   maxbtbl;
	       void far *   diskbuf;
	       void far *   drvinfo;
	       void far *   fcbtabl;
	       void far *   fcbsize;
	       void far *   numbdev;
	       unsigned char lastdrive;
	       }  CVTType;


typedef  struct  {
	 unsigned char   drv;
	 unsigned char   sud;
	 unsigned int    sec_siz;
	 unsigned char   sec_per_clu; //на единицу меньше кол-ва секторов в кластере
	 unsigned char   css;         //<>0 => Sec on Cluster = SecPerClu+2**css
	 unsigned int    boot_siz;
	 unsigned char   fat_cnt;
	 unsigned int    max_dir;
	 unsigned int    data_sec;
	 unsigned int    hi_clu;
	 union {
	     struct {
	     unsigned char   fat_sec;
	     unsigned int    root_sec;
	     void far *      drv_addr;
	     unsigned char   media;
	     unsigned char   access;
	     void far *      next;
	     } dos3;
	     struct {
	     unsigned int    fat_sec;
	     unsigned int    root_sec;
	     void far *      drv_addr;
	     unsigned char   media;
	     unsigned char   access;
	     void far *      next;
	     } dos4;
	 } add;
	}  DPBType;





typedef  struct{
		unsigned char jmp[3];
		char oem[8];
		unsigned bps;     //     {Bytes per Sector}
		unsigned char spc;//     {Sector per Cluster}
		unsigned rsc;     //     {Reserved sectors}
		unsigned char fat;
		unsigned rde;
		unsigned sec;
		unsigned char mds;
		unsigned spf;      //     {Sectors per fat}
		unsigned spt;      //     {Sectors per track}
		unsigned hds;      //     {Heads}
		unsigned hssl;     //     {Hidden sectors - loWord}
		unsigned hssh;     //     {Hidden sectors - hiWord}
		unsigned long tots;//    {Total sectors}
		unsigned char pdn; //    {Phys drive number}
		unsigned char res; //    {reserved}
		unsigned char ebs; //    {Extended boot sign - 0x29}
		unsigned long vsn; //    {Volume serial number}
		char lab[11];      //    {label}
		char fsi[8];
		unsigned char bcode[450];
	     } BootRec;


/*   if sec<>0 then x:=sec else x:= tots;
    x mod (hds*spt)<>0 => has hidden sectors !
    tracks = x div (hds*spt)
*/



typedef  struct {
	unsigned signature;
	unsigned part_pag;
	unsigned file_size;
	unsigned rel_item;
	unsigned hdr_size;
	unsigned min_mem;
	unsigned max_mem;
	unsigned ss_reg;
	unsigned sp_reg;
	unsigned chk_summ;
	unsigned ip_reg;
	unsigned cs_reg;
	unsigned relt_off;
	unsigned overlay;
	}  EXE_HDR;


typedef struct _DPT_ {
    unsigned char srt_hut;
    unsigned char dma_hlt;
    unsigned char motor_w;
    unsigned char sec_size;
    unsigned char eot;
    unsigned char gap_rw;
    unsigned char dtl;
    unsigned char gap_f;
    unsigned char fill_char;
    unsigned char hst;
    unsigned char mot_start;
} DPT;


typedef struct {
        int n_floppy;
        int n_hard;
        int t_floppy1;
        int t_floppy2;
        int t_hard1;
        int t_hard2;
        } DISK_CONFIG;

typedef struct {
        unsigned int   max_cyl;
        unsigned char  max_head;
        unsigned int   srwcc;
        unsigned int   swpc;
        unsigned char  max_ecc;
        unsigned char  dstopt;
        unsigned char  st_del;
        unsigned char  fm_del;
        unsigned char  chk_del;
        char reserve[4];
        } HDPT;


typedef  struct {
        unsigned char  flag;
        unsigned char  beg_head;
        unsigned int   beg_sec_cyl;
        unsigned char  sys;
        unsigned char  end_head;
        unsigned int   end_sec_cyl;
        unsigned long  rel_sec;
        unsigned long  size;
        } PART_ENTRY;

typedef struct {
        char          boot_prg[0x1BE];
        PART_ENTRY    part_table[4];
        unsigned char signature[2];
        } MBOOT;

typedef  union {
                    struct {
                      char nam[8];
                      char ext[3];
                    } name;
                    struct {
                      unsigned char first;
                      unsigned char res[10];
                    } res;
                    char fullname[11];
         } EntryName;

typedef struct {
             EntryName name;
             unsigned char atr;
             unsigned char dum[10];
             unsigned int time;
             unsigned int date;
             unsigned int clus;
             unsigned long size;
             } FileEntry;



#endif
