/***
*	RPCXLib.ch
*	Definitions for the RPCXLib - library
*
*	Copyright (c) 1993-95  Rolf van Gelder
*
*	Date: 19/04/95
*/

*==========================================================================
*	Codes for SUPERVGA adapters
*==========================================================================

#define	PL_SVGA_UNKNOWN		0

#define	PL_SVGA_TSENG4000	1
#define	PL_SVGA_TRIDENT		2
#define	PL_SVGA_VESA		3
#define	PL_SVGA_TSENG3000	4
#define	PL_SVGA_AHEAD		5
#define	PL_SVGA_ATI		6
#define	PL_SVGA_CHIPSTECH	7
#define	PL_SVGA_EVEREX		8
#define	PL_SVGA_GENOA		9
#define	PL_SVGA_NCR		10
#define	PL_SVGA_OAKTECH		11
#define	PL_SVGA_PARADISE	12
#define	PL_SVGA_VIDEO7		13

* Number of valid SUPERVGA adapters
#define	PL_SVGA_VALID		13

* Names of recognised SUPERVGA adapters
#define	PL_SVGA_NAMES	{ 'Tseng Labs ET4000',;
                          'Trident 8800/8900',;
                          'VESA BIOS extensions',;
                          'Tseng Labs ET3000',;
                          'Ahead Systems A & B',;
                          'ATI Wonder Card',;
                          'Chips & Technologies',;
                          'Everex VGA',;
                          'Genoa GVGA',;
                          'NCR 77C22',;
                          'Oak Technologies OTI-67',;
                          'Paradise VGA',;
                          'Video 7' }

*-- Function to see if there is a supported SUPERVGA adapter
#translate R_IsSVGA () => (R_VGACard() > 0 .and. R_VGACard() <= PL_SVGA_VALID)

*==========================================================================
*	Codes for GRAPHIC adapters
*==========================================================================

#define	PL_EGA			1
#define	PL_VGA			2
#define	PL_SVGA			3


*==========================================================================
*	Return codes for R_ShowPCX () & R_PCXInfo ()
*==========================================================================

#define	PL_OKAY			0
#define	PL_INVALID_PARAMETER	1
#define	PL_OPEN_PCX		2
#define	PL_READ_PCX		3
#define	PL_NO_PCXFILE		4
#define	PL_INVALID_BPP		5
#define	PL_INVALID_DIM		6
#define	PL_UNKNOWN_SVGA		7
#define	PL_OPEN_DRIVER		8
#define	PL_READ_DRIVER		9
#define	PL_SVGA_NOTSUPPORTED	10
#define	PL_BUFFER_MEMORY	11

#define	PL_ERRMSG	{ 'Invalid parameter passed',;
			  'Error OPENING PCX-file',;
                          'Error READING PCX-file',;
                          'File is no valid PCX-file',;
                          'Invalid number of BPP',;
                          'PCX-file has invalid dimensions',;
                          'Unknown SuperVGA-card',;
                          'Error OPENING RPCXLIB.GDR driver',;
                          'Error READING RPCXLIB.GDR driver',;
                          'SuperVGA-card not supported (yet)',;
		          'Not enough memory for buffer' }

*==========================================================================
*	VGA-palette registers for Clipper colours
*==========================================================================

#define	PL_BLACK		0
#define	PL_BLUE			1
#define	PL_GREEN		2
#define	PL_CYAN			3
#define	PL_RED			4
#define	PL_MAGENTA		5
#define	PL_BROWN		6
#define	PL_WHITE		7
#define	PL_GREY			56
#define	PL_BRIGHT_BLUE		57
#define	PL_BRIGHT_GREEN		58
#define	PL_BRIGHT_CYAN		59
#define	PL_BRIGHT_RED		60
#define	PL_BRIGHT_MAGENTA	61
#define	PL_YELLOW		62
#define	PL_BRIGHT_WHITE		63

*--------------------------------------------------------------------------
* Composition of the DEFAULT CLIPPER colours
*				{ Red, Green, Blue } components
*--------------------------------------------------------------------------
#define	PL_DEF_BLACK		{  0,  0,  0 }
#define	PL_DEF_BLUE		{  0,  0, 42 }
#define	PL_DEF_GREEN		{  0, 42,  0 }
#define	PL_DEF_CYAN		{  0, 42, 42 }
#define	PL_DEF_RED		{ 42,  0,  0 }
#define	PL_DEF_MAGENTA		{ 42,  0, 42 }
#define	PL_DEF_BROWN		{ 42, 21,  0 }
#define	PL_DEF_WHITE		{ 42, 42, 42 }
#define	PL_DEF_GREY		{ 21, 21, 21 }
#define	PL_DEF_BRIGHT_BLUE	{ 21, 21, 63 }
#define	PL_DEF_BRIGHT_GREEN	{ 21, 63, 21 }
#define	PL_DEF_BRIGHT_CYAN	{ 21, 63, 63 }
#define	PL_DEF_BRIGHT_RED	{ 63, 21, 21 }
#define	PL_DEF_BRIGHT_MAGENTA	{ 63, 21, 63 }
#define	PL_DEF_YELLOW		{ 63, 63, 21 }
#define	PL_DEF_BRIGHT_WHITE	{ 63, 63, 63 }
*
* Eof RPCXLib.CH