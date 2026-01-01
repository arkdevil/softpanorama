/* This is file CONTROL.C */
/*
** Copyright (C) 1991 DJ Delorie, 24 Kirsten Ave, Rochester NH 03867-2954
**
** This file is distributed under the terms listed in the document
** "copying.dj", available from DJ Delorie at the address above.
** A copy of "copying.dj" should accompany this file; if not, a copy
** should be available from where this file was obtained.  This file
** may not be distributed without a verbatim copy of "copying.dj".
**
** This file is distributed WITHOUT ANY WARRANTY; without even the implied
** warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

/* History:87,1 */
#include <dos.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>

#include "build.h"
#include "types.h"
#include "gdt.h"
#include "idt.h"
#include "tss.h"
#include "valloc.h"
#include "utils.h"
#include "syms.h"
#include "graphics.h"
#include "mono.h"

TSS *tss_ptr;
int debug_mode = 0;
int self_contained;
long header_offset = 0;
int use_ansi=0;
int use_mono=0;

static int old_video_mode;

extern near go32();
extern near go_real_mode();
extern int was_exception;
extern near ivec0(), ivec1(), ivec7(), ivec75();
extern near interrupt_common(), page_fault();
extern near test();

extern word32 far *pd;

fillgdt(int sel, word32 limit, word32 base, word8 type, int G)
{
  GDT_S *g;
  g = gdt+sel;
  if (G & 2)
    limit = limit >> 12;
  g->lim0 = limit & 0xffff;
  g->lim1 = (limit>>16) & 0x0f;
  g->base0 = base & 0xffff;
  g->base1 = (base>>16) & 0xff;
  g->base2 = (base>>24) & 0xff;
  g->stype = type;
  g->lim1 |= G * 0x40;
}

word32 ptr2linear(void far *ptr)
{
  return (word32)FP_SEG(ptr) * 16L + (word32)FP_OFF(ptr);
}

setup_tss(TSS *t, int (*eip)())
{
  memset(t, 0, sizeof(TSS));
  t->tss_cs = g_rcode*8;
  t->tss_eip = (long)FP_OFF(eip);
  t->tss_ss = g_rdata*8;
  t->tss_esp = (long)FP_OFF(t->tss_stack);
  t->tss_ds = g_rdata*8;
  t->tss_es = g_rdata*8;
  t->tss_fs = g_rdata*8;
  t->tss_gs = g_rdata*8;
  t->tss_eflags = 0x0200;
  t->tss_iomap = 0xffff; /* no map */
}

exit_func()
{
  int i;
  dalloc_uninit();
  uninit_controllers();
  xms_free();

#if TOPLINEINFO
  for (i=0; i<80; i++)
    poke(screen_seg, i*2, 0x0720);
#endif
}

int ctrl_c_flag = 0;

ctrlbrk_func()
{
#if DEBUGGER
  ctrl_c_flag = 1;
#else
  exit(3);
#endif
}

usage(char *s)
{
  printf("Usage: %s [program [options . . . ]]\n", s);
  _exit(1);
}

int have_80387;
static word32 push32(void *ptr, int len);

main(int argc, char **argv, char **envp)
{
  int i, n, set_brk=0, emu_installed=0;
  struct stat stbuf;
  char *cp, *path, *argv0, *emu_fn=0;
  unsigned short header[3];

  old_video_mode = peekb(0x40, 0x49);

  if (strcmp(argv[1], "!proxy") == 0)
  {
    int oseg, optr, i;
    int far *oargv;
    char far *oargve;
    sscanf(argv[2], "%x", &argc);
    sscanf(argv[3], "%x", &oseg);
    sscanf(argv[4], "%x", &optr);
    oargv = MK_FP(oseg, optr);
    argv = (char **)malloc(sizeof(char *) * (argc+1));
    for (i=0; i<argc+1; i++)
    {
      if (oargv[i] == 0)
      {
        argv[i] = 0;
        break;
      }
      oargve = MK_FP(oseg, oargv[i]);
      for (optr=0; oargve[optr]; optr++);
      argv[i] = (char *)malloc(optr+1);
      for (optr=0; oargve[optr]; optr++)
        argv[i][optr] = oargve[optr];
      argv[i][optr] = 0;
    }
  }

  switch (cputype())
  {
    case 1:
      fprintf(stderr, "CPU must be a 386 to run this program.\n");
      exit(1);
    case 2:
      fprintf(stderr, "CPU must be in REAL mode (not V86 mode) to run this program.\n");
      exit(1);
  }

  if (peekb(0x40,0x49) == 7)
    screen_seg = 0xb000;

  _fmode = O_BINARY;

  cp = getenv("GO32");
  path = 0;
  if (cp)
    while (1)
    {
      char sw[100];
      char val[100];
      if (sscanf(cp, "%s%n", sw, &i) < 1)
        break;
      cp += i;
      if (strcmp(sw, "ansi") == 0)
        use_ansi = 1;
      else if (strcmp(sw, "mono") == 0)
        use_mono = 1;
      else
      {
        val[0] = 0;
        sscanf(cp, "%s%n", val, &i);
        cp += i;
        if (val[0] == 0)
          break;
      }
      if (strcmp(sw, "driver") == 0)
      {
        if (path) free(path);
        path = strdup(val);
      }
      else if (strcmp(sw, "tw") == 0)
        gr_def_tw = atoi(val);
      else if (strcmp(sw, "th") == 0)
        gr_def_th = atoi(val);
      else if (strcmp(sw, "gw") == 0)
        gr_def_gw = atoi(val);
      else if (strcmp(sw, "gh") == 0)
        gr_def_gh = atoi(val);
      else if (strcmp(sw, "emu") == 0)
      {
        if (emu_fn) free(emu_fn);
        emu_fn = strdup(val);
      }
    }
  setup_graphics_driver(path);
  if (path) free(path);
  if (use_mono)
  {
    use_ansi = 0;
    screen_seg = 0xb000;
  }

  setbuf(stdin, 0);
  atexit((atexit_t)exit_func);
  ctrlbrk(ctrlbrk_func);
  n = (int)ivec1-(int)ivec0;
  for (i=0; i<256; i++)
  {
    idt[i].selector = g_rcode*8;
    idt[i].stype = 0x8e00;
    idt[i].offset0 = FP_OFF((int)ivec0+n*i);
    idt[i].offset1 = 0;
  }
  idt[14].selector = g_ptss*8;
  idt[14].stype = 0x8500;
  idt[14].offset0 = 0;
  idt[14].offset1 = 0;

  cp = getenv("387");
  if (cp)
    if (tolower(cp[0]) == 'n')
      have_80387 = 0;
    else if (tolower(cp[0]) == 'y')
      have_80387 = 1;
    else
      have_80387 = detect_80387();
  else
    have_80387 = detect_80387();
  if (have_80387)
  {
    idt[7].offset0 = (int)ivec7;
    idt[7].offset1 = 0;
    idt[0x75].offset0 = (int)ivec75;
    idt[0x75].offset1 = 0;
  }

  if (cp && (tolower(cp[0]) == 'q'))
    if (have_80387)
      printf("An 80387 has been detected.\n");
    else
      printf("No 80387 has been detected.\n");

  fillgdt(g_zero, 0, 0, 0, 0);
  fillgdt(g_gdt, sizeof(gdt), ptr2linear(gdt), 0x92, 0);
  fillgdt(g_idt, sizeof(idt), ptr2linear(idt), 0x92, 0);
  fillgdt(g_rcode, 0xffff, (word32)_CS*16L, 0x9a, 0);
  fillgdt(g_rdata, 0xffff, (word32)_DS*16L, 0x92, 0);
  fillgdt(g_core, 0xffffffffL, 0, 0x92, 3);
  fillgdt(g_acode, 0xefffffffL, 0x10000000L, 0x9a, 3);
  fillgdt(g_adata, 0xefffffffL, 0x10000000L, 0x92, 3);
  fillgdt(g_ctss, sizeof(TSS), ptr2linear(&c_tss), 0x89, 3);
  fillgdt(g_atss, sizeof(TSS), ptr2linear(&a_tss), 0x89, 3);
  fillgdt(g_ptss, sizeof(TSS), ptr2linear(&p_tss), 0x89, 3);
  fillgdt(g_itss, sizeof(TSS), ptr2linear(&i_tss), 0x89, 3);
  fillgdt(g_rc32, 0xffff, (word32)_CS*16L, 0x9a, 3);
  fillgdt(g_grdr, 0xffff, (word32)gr_paging_segment*16L, 0x9a, 0);

  setup_tss(&c_tss, go_real_mode);
  setup_tss(&a_tss, go_real_mode);
  setup_tss(&o_tss, go_real_mode);
  setup_tss(&f_tss, go_real_mode);
  setup_tss(&i_tss, interrupt_common);
  setup_tss(&p_tss, page_fault);
  tss_ptr = &a_tss;

  argv0 = argv[0];
  for (i=0; argv0[i]; i++)
  {
    if (argv0[i] == '\\')
      argv0[i] = '/';
    argv0[i] = tolower(argv0[i]);
  }
  if (strcmp(argv[1], "-nobrk") == 0)
  {
    set_brk=1;
    argv++;
    argc--;
  }

#if TOPLINEINFO
  for (i=0; i<80; i++)
    poke(screen_seg, i*2, 0x0720);
#endif

  self_contained = 0;
  n = open(argv0, O_RDONLY|O_BINARY);
  header[0] = 0;
  read(n, header, sizeof(header));
  if (header[0] == 0x5a4d)
  {
    header_offset = (long)header[1] + (long)header[2]*512L - 512L;
    lseek(n, header_offset, 0);
    header[0] = 0;
    read(n, header, sizeof(header));
    if (header[0] == 0x010b)
      self_contained = 1;
  }

  if (self_contained)
  {
#if DEBUGGER
    debug_mode = 1;
#else
    debug_mode = 0;
#endif
    paging_set_file(argv0);
    emu_installed = emu_install(emu_fn);
    set_command_line(argv, envp);
#if DEBUGGER
    syms_init(argv0);
#endif
  }
  else
  {
    header_offset = 0;
    for (cp=argv0; *cp; cp++)
      if (*cp == '.')
        path = cp;
    *path = 0;
    if (stat(argv0, &stbuf)) /* not found */
    {
      fprintf(stderr, "%s.exe Copyright (C) 1991 DJ Delorie\n", argv0);
      debug_mode = 1;
      if (argv[1] == 0)
        usage(argv0);
      paging_set_file(argv[1]);
      emu_installed = emu_install(emu_fn);
      set_command_line(argv+1, envp);
#if DEBUGGER
      syms_init(argv[1]);
#endif
    }
    else /* found */
    {
      debug_mode = 0;
      paging_set_file(argv0);
      emu_installed = emu_install(emu_fn);
      set_command_line(argv, envp);
#if DEBUGGER
      syms_init(argv0);
#endif
    }
  }

  if (set_brk)
    paging_brk(0x8fffffffL);

  dalloc_init();
  init_controllers();
  if (emu_installed)
  {
    push32(&(a_tss.tss_eip), 4);
    a_tss.tss_eip = 0xb0000020;
  }
#if DEBUGGER
  debugger();
  if (peekb(0x40, 0x49) != old_video_mode)
  {
    _AX = old_video_mode;
    geninterrupt(0x10);
  }
  return 0;
#else
  go_til_stop();
  if (tss_ptr->tss_irqn == 0x79)
    fprintf(stderr, "Ctrl-C Hit!  Stopped at address %lx\n", tss_ptr->tss_eip);
  else
    fprintf(stderr, "Exception %d at eip=%lx\n", tss_ptr->tss_irqn, tss_ptr->tss_eip);
  return 1;
#endif
}

#if !DEBUGGER
gdtprint(i)
{
  printf("0x%02x: base=%02x%02x%04x lim=%02x%04x G=%d type=%02x\n",
    i*8, gdt[i].base2, gdt[i].base1, gdt[i].base0,
    gdt[i].lim1&0x0f, gdt[i].lim0, gdt[i].lim1>>6, gdt[i].stype);
}
#endif

static word32 push32(void *ptr, int len)
{
  if ((a_tss.tss_esp & ~0xFFF) != ((a_tss.tss_esp-len) & ~0xFFF))
  {
    a_tss.tss_cr2 = a_tss.tss_esp - len + ARENA;
    page_in();
  }
  a_tss.tss_esp -= len;
  a_tss.tss_esp = a_tss.tss_esp & (~3);
  memput(a_tss.tss_esp+ARENA, ptr, len);
  return a_tss.tss_esp;
}

static foreach_arg(char **argv, int (*func)())
{
  int i;
  FILE *f;
  char buf[80];
  for (i=0; argv[i]; i++)
  {
    if (argv[i][0] == '@')
    {
      f = fopen(argv[i]+1, "rt");
      while (fscanf(f, "%s", buf) == 1)
      {
        if (strcmp(buf, "\032") != 0)
          func(buf);
      }
      fclose(f);
    }
    else
      func(argv[i]);
  }
}

static int num_actual_args;

static just_incr()
{
  num_actual_args++;
}

static word32 *a;

pusharg(char *ar)
{
  a[num_actual_args] = push32(ar, strlen(ar)+1);
  num_actual_args++;
}

set_command_line(char **argv, char **envv)
{
  unsigned envc;
  word32 *e, v, argp, envp;

  a_tss.tss_cr2 = a_tss.tss_esp + ARENA;
  page_in();

  num_actual_args = 0;
  foreach_arg(argv, just_incr);

  for (envc=0; envv[envc]; envc++);
  e = (word32 *)malloc((envc+1)*sizeof(word32));
  if (e == 0)
  {
    printf("Fatal! no memory to copy environment\n");
    exit(1);
  }
  for (envc=0; envv[envc]; envc++)
  {
    v = push32(envv[envc], strlen(envv[envc])+1);
    e[envc] = v;
  }
  e[envc] = 0;

  a = (word32 *)malloc((num_actual_args+1)*sizeof(word32));
  if (e == 0)
  {
    printf("Fatal! no memory to copy arguments\n");
    exit(1);
  }
  num_actual_args = 0;
  foreach_arg(argv, pusharg);
  a[num_actual_args] = 0;

  envp = push32(e, (envc+1)*sizeof(word32));
  argp = push32(a, (num_actual_args+1)*sizeof(word32));

  push32(&envp, sizeof(word32));
  push32(&argp, sizeof(word32));
  v = num_actual_args;
  push32(&v, sizeof(word32));
}
