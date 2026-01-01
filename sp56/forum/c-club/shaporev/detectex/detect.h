/* detect.h	Copyright (c) 1990 Tim Shaporev */

struct	VideoIdent
{
	unsigned char VideoSubsystem;
        unsigned char VideoDisplay;
};
void VideoID ( struct VideoIdent far * );

#define	VSYS_Any	 0
#define	VSYS_MDA	 1
#define	VSYS_CGA	 2
#define	VSYS_EGA	 3
#define VSYS_PGA         4
#define	VSYS_MCGA	 5
#define	VSYS_VGA	 6
#define VSYS_3270	 7
#define	VSYS_HGC	128
#define	VSYS_pHGC	129
#define	VSYS_InC	130
#define VSYS_LCD        0xE0
#define VSYS_Tandy      0xF0

#define VDEV_Any	0
#define VDEV_MDA	1	/* MDA-compatible monochrome */
#define VDEV_CGA	2	/* CGA-compatible color      */
#define VDEV_EGA	3       /* EGA-compatible color      */
#define VDEV_PGA        4       /* IBM professional          */
#define VDEV_mPS	5	/* PS/2-compatible mono      */
#define VDEV_cPS	6	/* PS/2-compatible color     */
#define VDEV_3270	7	/* PC 3270                   */

int CPUname(void);

#define	CPU_8086	0
#define	CPU_8088	1
#define	CPU80186	2
#define CPU80188	3
#define	CPU80286	4
#define	CPU80386	6
#define	CPUSX386	7
#define CPU80486	8
#define	CPUNEC20	128
#define	CPUNEC30	129

int MathUnit(void);

#define MU_NONE		0
#define MU_8087		1
#define MU_80287	2
#define MU_80387	3
#define MU_WEITEK	4
#define MU_WandI	5

int VGAChipset(void);

#define chipUNKNOWN 0 /* Unknown chip set */
#define chipTSENG   1 /* Tseng Labs       */
#define chipPARA    2 /* Paradise         */
#define chipV7      3 /* Video 7          */

int bustype(void);

#define MCAbus   2 /* Micro Channel Architecture */
#define EISAbus  1
#define PCbusISA 0 /* nothing detected */

int MathHere(void);
int FindCMem(void);
int conflags(void);
int Is_486  (void);
int Is_Cache(void);
