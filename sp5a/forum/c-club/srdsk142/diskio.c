/* ReSizeable RAMDisk - disk I/O
** Copyright (c) 1992 Marko Kohtala
*/

#include "srdisk.h"
#include <assert.h>
#include <dos.h>
#include <string.h>
#include <stdio.h>

/*
**  Read/Write sector from/to disk
**
**  Return 0 for failure, transferred sector count otherwise
*/

static int xfer_sector(char rw, int count, dword start, void far *buffer)
{
  struct config_s far *subconf = conf;
  int sectors = count;

  while(count) {
    asm {
      mov ax,word ptr start
      mov dx,word ptr start+2
      mov cx,count
      mov bh,rw
      les di,buffer
      push ds
      lds si,subconf
      call dword ptr [si+2]   /* !!!! Configuration format dependent */
      pop ds
      jc fail
      sub count,ax
      jbe done
    }
    start -= subconf->sectors;
    if ( !(subconf = conf_ptr(subconf->next)) )
      return 0;
  }
 done:
  return sectors;
 fail:
  fatal("Cannot access disk");
  return 0;
}

/*
**  Read sector from disk
**
**  Return 0 for failure, transferred sector count otherwise
*/

int read_sector(int count, dword start, void *buffer)
{
  return xfer_sector(0, count, start, buffer);
}

/*
**  Write sector to disk
**
**  Return 0 for failure, transferred sector count otherwise
*/

int write_sector(int count, dword start, void *buffer)
{
  return xfer_sector(1, count, start, buffer);
}


/*
** XMS errors
*/

static void XMS_error(byte err)
{
  char *errstr = "Unknown error";
  int e;
  static struct {
    byte err;
    char *str;
  } errs[] = {
    { 0x80, "Function not implemented" },
    { 0x81, "VDISK device is detected" },
    { 0x82, "A20 error occurs" },
    { 0x8E, "General device driver error" },
    { 0x8F, "Unknown device driver error" },
    { 0xA0, "All extended memory is allocated" },
    { 0xA1, "All available handles are in use" },
    { 0xA2, "Handle is invalid" },
    { 0xA9, "Parity error" },
    { 0xAB, "Block is locked" }
  };

  for (e = 0; e < sizeof errs / sizeof errs[0]; e++)
    if (errs[e].err == err) {
      errstr = errs[e].str;
      break;
    }

  printf("\nXMS error: %s\n", errstr);
}

/*
**  Allocate memory on a part of the disk
**
**  Error: Return in any case the number of K there is remaining.
*/

dword disk_alloc(struct config_s far *conf, dword size)
{
  struct dev_hdr _seg *dev = (struct dev_hdr _seg *)FP_SEG(conf);
  byte far *alloc = MK_FP(dev, conf->malloc_off);

  if (!(conf->flags & C_NOALLOC))
    return ((dword (far *)(dword))alloc)(size);

  if (_fstrncmp("XMS ", dev->u.s.memory, 4) == 0) {
    if (size >= 0x10000L) /* Can not allocate over 0xFFFF K */
     fail:
      return conf->size;

    #define XMS_handle 0    /* Dependant on the XMS_alloc structure format */
    #define XMS_entry 2

    if (*(word far *)(alloc+XMS_handle) != 0) {
      /* Has already a handle - reallocate to new size */
      if (size) {
        /* If space wanted and old contents must be preserved */
        asm {
          les si,alloc
          mov dx,es:[si+XMS_handle]
          mov bx,word ptr size
          mov ah,0xF      /* Reallocate */
          call dword ptr es:[si+XMS_entry]
          or ax,ax
          jnz realloc_ok
        }
        XMS_error(_BL);
        return conf->size;
      }
      /* Old contents are to be destroyed, so free the block */
      asm {
        les si,alloc
        mov dx,es:[si+XMS_handle]
        mov ah,0xA  /* Free extended memory block */
        call dword ptr es:[si+XMS_entry]
        or ax,ax
        jnz xms_freed
      }
      XMS_error(_BL);
      goto fail;
     xms_freed:
      asm {
        mov word ptr es:[si+XMS_handle],0   /* No handle anymore */
        jmp alloc_handle
      }
     realloc_ok:;
    }
    else {
      /* Handle 0 is no handle - must allocate */
     alloc_handle:
      if (!newf.size)
        goto alloc_ok;

      asm {
        les si,alloc
        mov dx,word ptr size
        mov ah,0x9      /* Allocate */
        call dword ptr es:[si+XMS_entry]
        or ax,ax
        jz alloc_fail
        mov es:[si+XMS_handle],dx
        jmp alloc_ok
      }
     alloc_fail:
      XMS_error(_BL);
      return 0;
     alloc_ok:;
    }
  }
  else
    fatal("Don't know how to allocate memory");
  return size;
}

