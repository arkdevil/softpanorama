/* tube.h -- grpahics and sound wrapper
 * Copyright (C) 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */


/***********************************************************************
// Sound section
************************************************************************/

/* use the great MikMod soundsystem by Jean-Paul Mikkers */
#if defined(USE_MIKMOD)
#if defined(__DJGPP__) || defined(__WATCOMC__) || defined(__KB_LINUX)
#  define HAVE_SOUND
#  include <mikmod.h>
   static UNIMOD *mod = NULL;
#endif
#if defined(__DJGPP__)
#  include <crt0.h>
   int _crt0_startup_flags = _CRT0_FLAG_NEARPTR | _CRT0_FLAG_LOCK_MEMORY;
#endif

int MikMod_Setup(unsigned sample_rate)
{
/* Initialize soundcard parameters */
	md_mixfreq    = sample_rate;               /* standard mixing freq */
	md_dmabufsize = 16384;                     /* standard dma buf size */
	md_mode       = DMODE_16BITS|DMODE_STEREO; /* standard mixing mode */
	md_device     = 0;                         /* standard device: autodetect */

/* Register the loaders we want to use */
	ML_RegisterLoader(&load_mod);
#if 0
	ML_RegisterLoader(&load_m15);/* if you use m15load, register it as first! */
	ML_RegisterLoader(&load_mtm);
	ML_RegisterLoader(&load_s3m);
	ML_RegisterLoader(&load_stm);
	ML_RegisterLoader(&load_ult);
	ML_RegisterLoader(&load_xm);
	ML_RegisterLoader(&load_uni);
#endif

/* Register the drivers we want to use */
	MD_RegisterDriver(&drv_nos);
#ifdef __WIN32__
	MD_RegisterDriver(&drv_w95);
#else
	MD_RegisterDriver(&drv_sb);
	MD_RegisterDriver(&drv_gus);
#endif

	return 0;
}

int MikMod_PlayMod(UNIMOD *mod)
{
	MD_PlayStop();
	if (mod == NULL)
		return -1;
	/* initialize modplayer to play this module */
	MP_Init(mod);
	/* set the number of voices to use */
	if (md_numchn < mod->numchn)
		md_numchn = mod->numchn;
	/*  start playing the module: */
	MD_PlayStart();
	return 0;
}

#endif


/* use the Sound-Blaster Library v0.5 by Joel H. Hunter */
#if defined(USE_SB_LIB)
#if defined(__DJGPP__) && defined(__KB_MSDOS32)
#  define HAVE_SOUND
#  include <sb_lib.h>
   static sb_mod_file *mod = NULL;
#endif
#endif


/* use Varmint's Audio Tools v0.61 by Eric Jorgensen */
#if defined(USE_VAT)
#if defined(__WATCOMC__) && defined(__KB_MSDOS32)
#  define HAVE_SOUND
#  include <vat.h>				/* note: I renamed this header file */
   static MOD *mod = NULL;
#endif
#endif


/***********************************************************************
// Linux svgalib wrapper
************************************************************************/

#if defined(__KB_LINUX)

#include <vga.h>
#include <vgagl.h>

GraphicsContext physicalscreen;

int setmode13(int x)
{
	int modes[] = { G320x200x256, G320x240x256, G720x348x2, G640x480x256 };
	int m;

	if (x < 0 || x > 3)
		x = 0;
	m = modes[x];

	vga_init();
	if (vga_setmode(m) != 0)		/* <- this does the real init of svgalib */
		return -1;
	if (gl_setcontextvga(m) != 0)
		return -1;
	gl_getcontext(&physicalscreen);
	/* gl_enableclipping(); */		/* not needed */
	return 0;
}

void setmode03(void)
{
	vga_setmode(TEXT);
}

void setcolor(int c, int r, int g, int b)
{
	vga_setpalette(c,r,g,b);
}

__inline__ void setpixel(int x, int y, int c)
{
	vga_setcolor(c);
	vga_drawpixel(x,y);
}

void waitvrt(void)
{
	vga_waitretrace();
}

#endif
    

/***********************************************************************
// MSDOS graphics wrapper (Allegro)
************************************************************************/

#if defined(__KB_MSDOS) && defined(USE_ALLEGRO)

#include <allegro.h>

#define WIDTH	SCREEN_W
#define HEIGHT	SCREEN_H

void setcolor(int c, int r, int g, int b)
{
	RGB rgb;

	rgb.r = r; rgb.g = g; rgb.b = b;
	set_color(c, &rgb);
}

int setmode13(int dummy)
{
	int c, w, h;
	c = GFX_AUTODETECT; w = 320; h = 200;

	allegro_init();
	if (is_win == 0)
		install_mouse();
	install_timer();
	install_keyboard();
	/* initialise_joystick(); */

	if (set_gfx_mode(GFX_VGA, 320, 200, 0, 0) != 0)
	{
		allegro_exit();
		printf("Allegro: error setting graphics mode\n%s\n\n", allegro_error);
		return -1;
	}

	if (is_win == 0)
	{
		/* colors gfx_mode_select() */
		setcolor(0, 0,0,0);
		setcolor(1, 48,48,48);
		setcolor(2, 56,10,10);
		/* colors for mouse cursor */
		setcolor(16, 0,0,0);
		setcolor(255, 63,63,63);
		clear(screen);
		textout_centre(screen,font,"Allegro Setup",SCREEN_W/2,10,2);
		gui_fg_color = 0;
		gui_bg_color = 1;
		if (!gfx_mode_select(&c, &w, &h))
		{
			allegro_exit();
			return -1;
		}
		if (set_gfx_mode(c, w, h, 0, 0) != 0)
		{
			allegro_exit();
			printf("Allegro: error setting graphics mode\n%s\n\n", allegro_error);
			return -1;
		}
	}

	remove_keyboard();
	clear(screen);
	set_clip(screen,0,0,0,0);	/* clipping not needed */
	return 0;
}

void setmode03(void)
{
	allegro_exit();
}

__inline__ void setpixel(int x, int y, int c)
{
	putpixel(screen,x,y,c);
}

void waitvrt(void)
{
	vsync();
}

#endif /* __KB_MSDOS */


/***********************************************************************
// MSDOS mode 13h graphics wrapper 
************************************************************************/

#if defined(__KB_MSDOS) && !defined(USE_ALLEGRO)

#if defined(__DJGPP__) && !defined(_CRT0_FLAG_LOCK_MEMORY)
#  include <crt0.h>
   int _crt0_startup_flags = _CRT0_FLAG_LOCK_MEMORY;
#endif

#define WIDTH	320
#define HEIGHT	200

#if defined(__KB_MSDOS16) && defined(__BORLANDC__)
#  define VIDMEM	((unsigned char far *) 0xa0000000l)
#elif defined(__DJGPP__)
#  include <sys/farptr.h>
#  define VIDMEM	0xa0000
#elif defined(__GO32__)
#  define VIDMEM	((unsigned char *) 0xd0000000)
#elif defined(__EMX__)
   static unsigned char *VIDMEM = NULL;
#elif defined(__WATCOMC__)
#  define VIDMEM	((unsigned char *) 0xa0000)
#endif


#if defined(KB_INT86)
int setmode13(int dummy)
{
	KB_INT86_REGS regs;
	_kb_int86_regs_init_ax(&regs,0x13);

#if defined(__EMX__)
	if (!KB_USE_INT86())
		return -1;			/* _int86() not allowed */
	if (_portaccess(0x3c8, 0x3da) != 0)
		return -1;
	if (VIDMEM == NULL)
		VIDMEM = _memaccess(0xa0000, 0xaffff, 1);
	if (VIDMEM == NULL)
		return -1;
#endif
	KB_INT86(0x10,&regs);
	return 0;
}

void setmode03(void)
{
	KB_INT86_REGS regs;
	_kb_int86_regs_init_ax(&regs,0x03);

#if defined(__EMX__)
	if (!KB_USE_INT86())
		return;				/* _int86() not allowed */
#endif
	KB_INT86(0x10,&regs);
}
#endif


#if defined(__DJGPP__)
__inline__ void setpixel(int x, int y, int c)
{
	_farnspokeb(VIDMEM + y*WIDTH + x, c);
}
#else
__inline__ void setpixel(int x, int y, int c)
{
	*(VIDMEM + y*WIDTH + x) = c;
}
#endif


void setcolor(int c, int r, int g, int b)
{
	/* fprintf(stderr,"%3d %3d %3d %3d\n",c,r,g,b); */
	KB_OUTP8(0x3c8, c);	
	_kb_usleep(5);
	KB_OUTP8(0x3c9, r);
	_kb_usleep(5);
	KB_OUTP8(0x3c9, g);
	_kb_usleep(5);
	KB_OUTP8(0x3c9, b);
	_kb_usleep(5);
}

/* wait for the vertical retrace trailing edge */
void waitvrt(void)
{
	while (!(KB_INP8(0x3da) & 0x8))		/* wait for retrace to end */
		;
	while ((KB_INP8(0x3da) & 0x8))		/* wait for retrace to start again */
		;
}

#endif /* __KB_MSDOS */


/***********************************************************************
// init sound library, load a MOD and play it in the background
************************************************************************/

#if defined(USE_MIKMOD)

static void tickhandler(void)
{
	MP_HandleTick();    /* play 1 tick of the module */
	MD_SetBPM(mp_bpm);
}

#endif


int init_sound(const char *modfile, unsigned sample_rate)
{
	if (modfile == NULL || sample_rate < 5000)
		return -1;

#if defined(USE_MIKMOD)
	MikMod_Setup(sample_rate);
	MD_RegisterPlayer(tickhandler);

/* initialize soundcard */
	if (!MD_Init())
	{
		fprintf(stderr,"MikMod: Driver error: %s\n",myerr);
		return -1;
	}

	printf("MikMod info: Using %s for %d bit %s %s sound at %u Hz\n",
			md_driver->Name,
			(md_mode & DMODE_16BITS) ? 16 : 8,
			(md_mode & DMODE_INTERP) ? "interpolated" : "normal",
			(md_mode & DMODE_STEREO) ? "stereo" : "mono",
			md_mixfreq);

	mod = ML_LoadFN((char *) modfile);
	if (mod == NULL)
	{
		fprintf(stderr,"MikMod: MOD Error: %s\n",myerr);
		return -1;
	}
	printf("Songname: %s\nModtype : %s\nPeriods : %s, %s\n",
		mod->songname, mod->modtype,
		(mod->flags & UF_XMPERIODS) ? "XM type" : "mod type",
		(mod->flags & UF_LINEAR) ? "Linear" : "Log");

/* start the MOD */
	MikMod_PlayMod(mod);
	return 0;

#elif defined(USE_SB_LIB)
	if (sb_install_driver(sample_rate) != SB_SUCCESS)
	{
		fprintf(stderr,"sb_lib: Sound Blaster error: %s\n", sb_driver_error);
		return -1;
	}
   	mod = sb_load_mod_file((char *) modfile);
  	if (mod == NULL)
	{
		sb_uninstall_driver();
    	fprintf(stderr,"sb_lib: MOD Error: %s\n",sb_mod_error);
		return -1;
	}
 	sb_mod_play(mod);
	return 0;

#elif defined(USE_VAT)
	{
	char errstring[100];

	if (!SBSetUp())
	{
		fprintf(stderr,"VAT: SB_Setup returned error: %s\n",errname[sberr]);
		return -1;
	}
    mod = LoadMod(modfile,errstring);
  	if (mod == NULL)
	{
		SBCleanUp();
    	fprintf(stderr,"VAT: error loading MOD: %s\n",errstring);
		return -1;
	}
	SetSampleRate(sample_rate);
	GoVarmint();				/* start up the sound Kernel */
	mod_data = mod;				/* tell VAT which song to play */
	ModCommand(v_play);			/* start the music */
	return 0;
	}

#else
	return -1;
#endif
}


/***********************************************************************
// cleanup - you should deallocate resources in the reverse order 
// you allocated them and prepare for the fact that the cleanup-function 
// can be called more than once
************************************************************************/

void my_silence(void)
{
	if (in_sound)
	{
		in_sound = 0;
#if defined(USE_MIKMOD)
		MD_PlayStop();          /* stop playing */
		MD_Exit();
		if (mod)
			ML_Free(mod);
#elif defined(USE_SB_LIB)
		sb_uninstall_driver();
		if (mod)
			sb_free_mod_file(mod);
#elif defined(USE_VAT)
		DropDeadVarmint();		/* stop the SB interrupt */
		SBCleanUp();			/* clean up sound stuff */
		if (mod)
			FreeMod(mod);		/* free our sond effect */
#endif
	}
}


void my_textmode(void)
{
	if (in_graphics)
	{
		in_graphics = 0;
		setmode03();
	}
	/* _kb_port_debug(); */
}


void my_cleanup(void)
{
	kb_remove();
	my_textmode();
	my_silence();
}

void my_emergency_cleanup(void)
{
	kb_remove();
	my_textmode();
	my_silence();
}


/*
vi:ts=4
*/

