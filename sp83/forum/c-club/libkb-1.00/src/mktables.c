/* mktables.c -- make keyboard tables _kbtable.hh
 * Copyright (C) 1995, 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include <kb.h>
#include "_kb.h"

#if defined(__KB_MSDOS)
#  include <io.h>
#  include <fcntl.h>
#endif



/***********************************************************************
//
************************************************************************/

static unsigned char prefix_scancode[128];
static unsigned char inverse_prefix_scancode[128];

static unsigned short shift_state_table[128];
static unsigned short unshift_state_table[128];


typedef unsigned short table_t;

static table_t alt_table[128];
static table_t control_table[128];


/***********************************************************************
// prefix tables 
************************************************************************/

static void init_prefix_tables(void)
{
	int i;
	unsigned char *t;

	t = prefix_scancode;	/* E0 table */

	/* unknown prefix codes map to scancode 0 */
	for (i = 0; i < 128; i++)
		t[i] = KB_SCAN_UNKNOWN;

	/* prefixed keys which map to keypad */
	t[KB_SCAN_SLASH]     = KB_SCAN_DIVIDE_PAD;
	t[KB_SCAN_ENTER]     = KB_SCAN_ENTER_PAD;

	/* prefixed keys on keypad which map to other keys */
	t[KB_SCAN_MULTIPLY_PAD] = KB_SCAN_PRINT;
	t[KB_SCAN_7_PAD]     = KB_SCAN_HOME;
	t[KB_SCAN_8_PAD]     = KB_SCAN_UP;
	t[KB_SCAN_9_PAD]     = KB_SCAN_PGUP;
	t[KB_SCAN_4_PAD]     = KB_SCAN_LEFT;
	t[KB_SCAN_6_PAD]     = KB_SCAN_RIGHT;
	t[KB_SCAN_1_PAD]     = KB_SCAN_END;
	t[KB_SCAN_2_PAD]     = KB_SCAN_DOWN;
	t[KB_SCAN_3_PAD]     = KB_SCAN_PGDN;
	t[KB_SCAN_0_PAD]     = KB_SCAN_INSERT;
	t[KB_SCAN_PERIOD_PAD] = KB_SCAN_DELETE;

	/* prefixed shift keys */
	t[KB_SCAN_LCONTROL]  = KB_SCAN_RCONTROL;
	t[KB_SCAN_ALT]       = KB_SCAN_ALTGR;
	t[KB_SCAN_LSHIFT]    = KB_SCAN_UNUSED_VIRTUAL;
	t[KB_SCAN_RSHIFT]    = KB_SCAN_UNUSED_VIRTUAL;

	/* prefixed special keys */
	t[KB_SCAN_NUMLOCK]   = KB_SCAN_PAUSE_VIRTUAL;
	t[KB_SCAN_SCRLOCK]   = KB_SCAN_CONTROL_BREAK_VIRTUAL;

	for (i = KB_SCAN_F12 + 1; i < 128; i++)
		assert(prefix_scancode[i] == KB_SCAN_UNKNOWN);

	/* New Microsoft keyboard is rumoured to have
	 * e0 5b (left window button), e0 5c (right window button),
	 * e0 5d (menu button). [or: LBANNER, RBANNER, RMENU]
	 * [or: Windows_L, Windows_R, TaskMan]
	 */
	t[0x5b] = KB_SCAN_LBANNER;
	t[0x5c] = KB_SCAN_RBANNER;
	t[0x5d] = KB_SCAN_RMENU;

	for (i = KB_SCAN_MAX_RAW + 1; i < 128; i++)
		assert(prefix_scancode[i] == KB_SCAN_UNKNOWN);

	t = inverse_prefix_scancode;
	for (i = 0; i < 128; i++)
		t[i] = i;
	for (i = 0; i < 128; i++)
		if (prefix_scancode[i] != KB_SCAN_UNKNOWN)
			t[prefix_scancode[i]] = i;
}


/***********************************************************************
// shift-state tables 
************************************************************************/

static void init_shift_state_tables(void)
{
	int i;
	unsigned short *t;
	const unsigned short virt = KB_SHIFT_VIRTUAL | KB_SHIFT_NO_PRESS;
	const unsigned short unkn = KB_SHIFT_UNKNOWN | KB_SHIFT_NO_PRESS;

	t = shift_state_table;
	for (i = 0; i < 128; i++)
		t[i] = 0;

/* shift keys */
	t[KB_SCAN_LSHIFT]           |= KB_SHIFT_LSHIFT | KB_SHIFT_NO_PRESS;
	t[KB_SCAN_RSHIFT]           |= KB_SHIFT_RSHIFT | KB_SHIFT_NO_PRESS;
	t[KB_SCAN_LCONTROL]         |= KB_SHIFT_LCONTROL | KB_SHIFT_NO_PRESS;
	t[KB_SCAN_RCONTROL]         |= KB_SHIFT_RCONTROL | KB_SHIFT_NO_PRESS;
	t[KB_SCAN_ALT]              |= KB_SHIFT_ALT | KB_SHIFT_NO_PRESS;
	t[KB_SCAN_ALTGR]            |= KB_SHIFT_ALTGR | KB_SHIFT_NO_PRESS;

/* these are toggles and therefore not in the unshift state table */
	t[KB_SCAN_CAPSLOCK]         |= KB_SHIFT_CAPSLOCK | KB_SHIFT_NO_PRESS;
	t[KB_SCAN_NUMLOCK]          |= KB_SHIFT_NUMLOCK | KB_SHIFT_NO_PRESS;
	t[KB_SCAN_SCRLOCK]          |= KB_SHIFT_SCRLOCK | KB_SHIFT_NO_PRESS;

/* these are toggles that DO produce a keypress */
	t[KB_SCAN_INSERT]           |= KB_SHIFT_INSERT;

/* these are toggles for virtual keys */
	t[KB_SCAN_CONTROL_BREAK_VIRTUAL] |= KB_SHIFT_CONTROL_BREAK | virt;
	t[KB_SCAN_PAUSE_VIRTUAL]    |= KB_SHIFT_PAUSE | virt;

/* other virtual keys */
	t[KB_SCAN_UNUSED_VIRTUAL]   |= virt;

/* other keys */
	t[KB_SCAN_LAST_CONSOLE]     |= KB_SHIFT_NO_PRESS;
	t[KB_SCAN_LBANNER]          |= KB_SHIFT_NO_PRESS;
	t[KB_SCAN_RBANNER]          |= KB_SHIFT_NO_PRESS;
	t[KB_SCAN_RMENU]            |= KB_SHIFT_NO_PRESS;
	/* t[KB_SCAN_PRINT] |= KB_SHIFT_NO_PRESS; Ctrl+Print DOES generate a code */

/* unknown keys */
	i = KB_SCAN_UNKNOWN;
	if (t[i] == 0)
		t[i] |= unkn;
	i = 85;
	if (t[i] == 0)
		t[i] |= unkn;
	for (i = 89; i < 96; i++)
		if (t[i] == 0)
			t[i] |= unkn;
	for (i = 112; i < 128; i++)
		if (t[i] == 0)
			t[i] |= unkn;

/* NOT USED */
#if defined(KB_SHIFT_NO_NAME)
	for (i = 0; i < 128; i++)
	{
		const char *p = kb_keyname(i);
		if (p == NULL || *p == 0)
			t[i] |= KB_SHIFT_NO_NAME;
	}
#endif


	t = unshift_state_table;
	for (i = 0; i < 128; i++)
		t[i] = 0;
	t[KB_SCAN_LSHIFT]   = KB_SHIFT_LSHIFT;
	t[KB_SCAN_RSHIFT]   = KB_SHIFT_RSHIFT;
	t[KB_SCAN_LCONTROL] = KB_SHIFT_LCONTROL;
	t[KB_SCAN_RCONTROL] = KB_SHIFT_RCONTROL;
	t[KB_SCAN_ALT]      = KB_SHIFT_ALT;
	t[KB_SCAN_ALTGR]    = KB_SHIFT_ALTGR;

/* negate for use with & (and) */
	for (i = 0; i < 128; i++)
		t[i] = ~t[i];
}



/***********************************************************************
// utility stuff
************************************************************************/

static int no_code(int i)
{
	assert(i >= 0 && i < 128);

	return KB_ANY_MASK(shift_state_table[i],
		(KB_SHIFT_NO_PRESS | KB_SHIFT_UNKNOWN | KB_SHIFT_VIRTUAL));
}


static int default_code(int i)
{
	assert(i >= 0 && i < 128);

	if (no_code(i))
		return 0;

	if (i >= KB_SCAN_F1 && i <= KB_SCAN_F10)
		return 0;
	if (i >= KB_SCAN_F11 && i <= KB_SCAN_F12)
		return 0;
	if (i == KB_SCAN_PRINT)
		return 0;
	
	return inverse_prefix_scancode[i];
}


static void cleanup_table(table_t *t)
{
	int i;

	for (i = 0; i < 128; i++)
		if (no_code(i))
			t[i] = 0;
}


/***********************************************************************
// These tables are hardcoded for American keyboards.
************************************************************************/

/* unshifted ASCII for scan codes */
static table_t plain_table[128] =
{
/*	0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F           */
	0  ,27 ,'1','2','3','4','5','6','7','8','9','0','-','=',8  ,9  ,   /* 0 */
	'q','w','e','r','t','y','u','i','o','p','[',']',13 ,0  ,'a','s',   /* 1 */
	'd','f','g','h','j','k','l',';',39 ,'`',0  ,92 ,'z','x','c','v',   /* 2 */
	'b','n','m',',','.','/',0  ,'*',0  ,' ',0  ,0  ,0  ,0  ,0  ,0  ,   /* 3 */
	0  ,0  ,0  ,0  ,0  ,0  ,0  ,'7','8','9','-','4','5','6','+','1',   /* 4 */
	'2','3','0','.',0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,   /* 5 */
	0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,   /* 6 */
	0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0      /* 7 */
};

/* shifted ASCII for scan codes */
static table_t shift_table[128] =
{
/*	0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F           */
	0  ,27 ,'!','@','#','$','%','^','&','*','(',')','_','+',8  ,9  ,   /* 0 */
	'Q','W','E','R','T','Y','U','I','O','P','{','}',13 ,0  ,'A','S',   /* 1 */
	'D','F','G','H','J','K','L',':',34 ,'~',0  ,'|','Z','X','C','V',   /* 2 */
	'B','N','M','<','>','?',0  ,'*',0  ,' ',0  ,0  ,0  ,0  ,0  ,0  ,   /* 3 */
	0  ,0  ,0  ,0  ,0  ,0  ,0  ,'7','8','9','-','4','5','6','+','1',   /* 4 */
	'2','3','0','.',0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,   /* 5 */
	0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,   /* 6 */
	0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0      /* 7 */
};


static void prepare_table(table_t *t)
{
	int i;

	t[KB_SCAN_ENTER_PAD] = 13;
	t[KB_SCAN_DIVIDE_PAD] = '/';
	if (t[KB_SCAN_LESS] == 0)
		t[KB_SCAN_LESS] = t[KB_SCAN_BACKSLASH];

	for (i = 0; i < 128; i++)
		if (t[i] == 0)
			t[i] = default_code(i);
}


static void init_plain_table(void)
{
	table_t *t = plain_table;
	int i, j;

	prepare_table(t);
	for (i = j = KB_SCAN_F1; i <= KB_SCAN_F10; i++)
		t[i] = i - j + 0x3b;
	for (i = j = KB_SCAN_F11; i <= KB_SCAN_F12; i++)
		t[i] = i - j + 0x85;
	cleanup_table(t);
}


static void init_shift_table(void)
{
	table_t *t = shift_table;
	int i, j;

	prepare_table(t);
	for (i = j = KB_SCAN_F1; i <= KB_SCAN_F10; i++)
		t[i] = i - j + 0x54;
	for (i = j = KB_SCAN_F11; i <= KB_SCAN_F12; i++)
		t[i] = i - j + 0x87;
	cleanup_table(t);
}


/***********************************************************************
// I hope these tables are complete now
************************************************************************/

static void init_alt_table(void)
{
	table_t *t = alt_table;
	int i, j;

	for (i = 0; i < 128; i++)
		t[i] = 0;

	for (i = j = KB_SCAN_F1; i <= KB_SCAN_F10; i++)
		t[i] = i - j + 0x68;
	for (i = j = KB_SCAN_F11; i <= KB_SCAN_F12; i++)
		t[i] = i - j + 0x8b;
	for (i = j = KB_SCAN_1; i <= KB_SCAN_EQUAL; i++)
		if (t[i] == 0)
			t[i] = i - j + 0x78;
	for (i = KB_SCAN_BACKSPACE; i <= KB_SCAN_MULTIPLY_PAD; i++)
		if (t[i] == 0)
			t[i] = i;

	t[KB_SCAN_ESC] = 0x01;
	t[KB_SCAN_SPACE] = 0x20;
	t[KB_SCAN_MINUS_PAD] = 0x4a;
	t[KB_SCAN_PLUS_PAD] = 0x4e;
	t[KB_SCAN_DIVIDE_PAD] = 0xa4;
	t[KB_SCAN_TAB] = 0xa5;
	t[KB_SCAN_ENTER_PAD] = 0xa6;

	for (i = KB_SCAN_HOME; i <= KB_SCAN_DELETE; i++)
		if (t[i] == 0 && default_code(i) > 0)
		{
			t[i] = default_code(i) + 0x50;
			j = inverse_prefix_scancode[i];
			if (t[j] == 0)
				t[j] = t[i];
		}

	t[KB_SCAN_5_PAD] = 0x9c;		/* is this correct ? */
	cleanup_table(t);
}


/* not very much logic in the control table */
static void init_control_table(void)
{
	table_t *t = control_table;
	int i, j;

	for (i = 0; i < 128; i++)
		t[i] = 0;

	for (i = j = KB_SCAN_F1; i <= KB_SCAN_F10; i++)
		t[i] = i - j + 0x5e;
	for (i = j = KB_SCAN_F11; i <= KB_SCAN_F12; i++)
		t[i] = i - j + 0x89;
	/* Ctrl-A to Ctrl-Z */
	for (i = 0; i < 128; i++)
	{
		j = plain_table[i];
		if (j >= 'a' && j <= 'z')
			if (t[i] == 0)
				t[i] = j - 'a' + 1;
	}

	t[KB_SCAN_2] = 0x03;			/* strange */
	t[KB_SCAN_ENTER] = t[KB_SCAN_ENTER_PAD] = 0x0a;
	t[KB_SCAN_ESC] = 0x1b;
	t[KB_SCAN_OPENBRACE] = 0x1b;
	t[KB_SCAN_MINUS] = 0x1c;
	t[KB_SCAN_CLOSEBRACE] = 0x1d;
	t[KB_SCAN_6] = 0x1e;
	t[KB_SCAN_SLASH] = 0x1f;
	t[KB_SCAN_SPACE] = 0x20;
	t[KB_SCAN_BACKSPACE] = 0x7f;	/* 127 */
	t[KB_SCAN_MINUS_PAD] = 0x8e;
	t[KB_SCAN_5_PAD] = 0x8f;
	t[KB_SCAN_PLUS_PAD] = 0x90;
	t[KB_SCAN_TAB] = 0x94;
	t[KB_SCAN_DIVIDE_PAD] = 0x95;
	t[KB_SCAN_MULTIPLY_PAD] = 0x96;

	t[KB_SCAN_HOME] = 0x77; 
	t[KB_SCAN_UP] = 0x8d;  
	t[KB_SCAN_PGUP] = 0x84;
	t[KB_SCAN_LEFT] = 0x73;
	t[KB_SCAN_RIGHT] = 0x74;
	t[KB_SCAN_END] = 0x75;
	t[KB_SCAN_DOWN] = 0x91;
	t[KB_SCAN_PGDN] = 0x76;
	t[KB_SCAN_INSERT] = 0x92;
	t[KB_SCAN_DELETE] = 0x93;
	for (i = KB_SCAN_HOME; i <= KB_SCAN_DELETE; i++)
	{
		j = inverse_prefix_scancode[i];
		if (t[j] == 0)
			t[j] = t[i];
	}

	cleanup_table(t);

	/* must add this after cleanup_table() */
	t[KB_SCAN_PRINT] = 0x72;
}



/***********************************************************************
// convert kb_keypress() to a keycode
//
// notes:
//   NumLock is always assumed to be on
//   CapsLock is ignored
//   AltGr is handled like Alt
//   Alt+keypad generates code in range 0x297 - 0x2a3 
//     (== Alt+cursor keys + 0x100)
************************************************************************/

static unsigned keycode(unsigned k)
{
	unsigned scan = k & 0x7f;
	unsigned code;

	if (KB_ANY_MASK(k, KB_SHIFT_ANY_ALT << 8))
	{
		code = alt_table[scan];
		if (code == 0)
			code = 0;
		else if (scan >= KB_SCAN_7_PAD && scan <= KB_SCAN_PERIOD_PAD &&
			code >= 0x80)
		{
		/* Alt + keypad: */
			/* code = 0; */				/* no code */
			/* code |= 0x100; */		/* map to cursor keys */
			code |= 0x200;				/* mark as keypad */
		}
		else if (scan != KB_SCAN_SPACE)
			code |= 0x100;				
	}
	else if (KB_ANY_MASK(k, KB_SHIFT_ANY_CONTROL << 8))
	{
		code = control_table[scan];
		if (code == 0)
			code = 0;
		else if (scan >= KB_SCAN_HOME)
			code |= 0x200;				
		else if (scan == KB_SCAN_2)		/* strange */
			code |= 0x100;				
		else if (scan != KB_SCAN_BACKSPACE && code > 0x20)
			code |= 0x100;				
	}
	else
	{
		if (KB_ANY_MASK(k, KB_SHIFT_ANY_SHIFT << 8))
		{
			if (scan == KB_SCAN_TAB)
				code = 0x10f;
			else
				code = shift_table[scan];
		}
		else
			code = plain_table[scan];

		if (code == 0)
			code = 0;
		else if (scan >= KB_SCAN_HOME)	
			code |= 0x200;				
		else if (scan >= KB_SCAN_F1 && scan <= KB_SCAN_F10)
			code |= 0x100;				
		else if (scan >= KB_SCAN_F11 && scan <= KB_SCAN_F12)
			code |= 0x100;				
	}

	assert(code < 0x300);
	assert(code == 0 || (code & 0xff) != 0);
	return code;
}



/***********************************************************************
//
************************************************************************/

static void puchar(const unsigned char *t, int s, const char *name)
{
	int i;

	printf("const unsigned char %s [ %d ] = {", name, s);

	for (i = 0; i < s; i++)
	{
		if (i % 8 == 0)
			printf("\n\t");
		printf("0x%02x, ", (int) t[i]);
	}
	printf("\n};\n\n");
}


static void pushort(const unsigned short *t, int s, const char *name)
{
	int i;

	printf("const unsigned short %s [ %d ] = {", name, s);

	for (i = 0; i < s; i++)
	{
		if (i % 8 == 0)
			printf("\n\t");
		printf("0x%04x, ", (int) t[i]);
	}
	printf("\n};\n\n");
}



/***********************************************************************
//
************************************************************************/

int main(int argc, char *argv[])
{
	int i;
	table_t *p;

	if (argc < 0 || argv == NULL)	/* avoid warning about unused args */
		return 0;


	init_prefix_tables();			/* must be initialized first */
	init_shift_state_tables();

	init_control_table();
	init_alt_table();

	init_shift_table();
	init_plain_table();				/* must be last */


	/* precompute all keycodes */
	p = plain_table;
	for (i = 0; i < 128; i++, p++)
		*p = keycode(i);
	p = shift_table;
	for (i = 0; i < 128; i++, p++)
		*p = keycode(i | (KB_SHIFT_ANY_SHIFT << 8));
	p = control_table;
	for (i = 0; i < 128; i++, p++)
		*p = keycode(i | (KB_SHIFT_ANY_CONTROL << 8));
	p = alt_table;
	for (i = 0; i < 128; i++, p++)
		*p = keycode(i | (KB_SHIFT_ANY_ALT << 8));


#if defined(O_BINARY)
	setmode(fileno(stdout),O_BINARY);
#endif

	puts("/* _kbtable.hh -- key tables");
	puts(" * Copyright (C) 1995, 1996 Markus F.X.J. Oberhumer");
	puts(" * For conditions of distribution and use, see copyright notice in kb.h ");
	puts(" */");
	puts("");
	puts("/* WARNING: this file should *not* be used by applications. It is");
	puts("   part of the implementation of the keyboard library and is");
	puts("   subject to change. Applications should only use kb.h.");
	puts(" */");
	puts("");
	puts("");
	puts("/* DO NOT EDIT - this file is automatically generated */");
	puts("");
	puts("");


	puchar(prefix_scancode,128,"_kb_prefix_scancode");
#if 0
	/* not needed anymore */
	puchar(inverse_prefix_scancode,128,"_kb_inverse_prefix_scancode");
#endif

	pushort(shift_state_table,128,"_kb_shift_state_table");
#if 0
	/* not needed anymore */
	pushort(unshift_state_table,128,"_kb_unshift_state_table");
#endif

	printf("static ");
	pushort(plain_table,128,"default_plain_table");
	printf("static ");
	pushort(shift_table,128,"default_shift_table");
	printf("static ");
	pushort(control_table,128,"default_control_table");
	printf("static ");
	pushort(alt_table,128,"default_alt_table");

	puts("");
	puts("/*");
	puts("vi:ts=4");
	puts("*/");

	return 0;
}


/*
vi:ts=4
*/
