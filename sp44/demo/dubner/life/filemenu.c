/***
*  Модуль осуществляет диалог по поводу выбора файла.
*
*	Использованы функции, приведенные как пример
*	использования базисных "менюшных" средств.
*
* Версия	1.5	(C)Copyright InfoScope Inc. 1992
*
***/

#include <stdio.h>
#include <dir.h>
#include <string.h>

#include <wndsay.h>

#include "mn_pop.h"
#include "mn_popup.h"

#include "filemenu.h"

ENTRY MN_ITEM_PTR mn_askGrid(MN_POP_PTR pmenu,int xGrid);
                            /* См. файл askgrid.c */

/*
*  Описание меню для выбора файла.
*/
MN_POP_DEF files_def={
   {DSP_LIGHTGRAY,DSP_BLACK},
   {-1,-1},
   {-1,-1},
   {-1,-1},
   {
    {75,9},            	/* window size              */
    dsp_doAttr(DSP_BLACK,DSP_LIGHTGRAY),   /* default attribute        */
    0,                 	/* cursor                   */
    1,                 	/* no frame                 */
    {WN_DOUBLE_TOPHEAD_CENTER,
    dsp_doAttr(DSP_BLACK,DSP_LIGHTGRAY),
    ' ',
    NULL,
    dsp_doAttr(DSP_BLACK,DSP_LIGHTGRAY)
    }
   }
};

/* Расположение этого окна */
LOC files_loc={3,3};

/*
*  Выбор файла по заданной маске из текущего директория.
*  Параметры - адрес строки-маски,
*              адрес буфера для записи имени выбранного файла.
*  Возвращает 1, если файл выбран, 0 - нажат ESC.
*/
LOCAL int FileMenu(const char *mask,char *name)
{
   int			i=0,	/* идентификаторы пунктов при создании	*/
                        inLine=1,       /* кол-во пунктов в строке меню	*/
                        done=0,		/* условие останова в цикле	*/
                        name_pos,was_name;
   struct ffblk 	fblk;
   MN_POP_ITEM_DEF 	item_def = {{2,1},14,NULL,0};
   MN_POP		*pgrid;
   MN_ITEM_PTR		pitem;
   char			full[MAXPATH];
   char			_name[MAXPATH],*_n,*cur;

   strcpy(name,mask);
   strrev(name);
   for(done=0,_n=_name,cur=name;*cur && !done;) {
      *_n = *cur++;
      if(*_n++ == '.' &&
      		(done=(*cur == '\\' || *cur == '/' || !*cur)) != 0)
        *_n++ = '*';
   }
   while((*_n++=*cur++)!=0);
   strrev(_name);
   strcpy(name,_name);

   pgrid = mn_makePop(&files_def,&files_loc);
   for(done=0;!done;) {
      utl_fname(name,full,&name_pos);
      wnd_SetTitle(mn_HolePane(mn_HoleInPop(pgrid)),full,NULL,NULL,NULL);
      inLine = files_def.hole.size.width/(item_def.width + 2);
      item_def.loc.x = 2;
      item_def.loc.y = 1;

      if(full[name_pos]) {
         strcpy(_name,full+name_pos);
         full[name_pos] = '\0';
         was_name = 1;
      }
      else
         was_name = 0;
      			/* Сначала - директории	*/
      strcat(full,"*.*");
      if (findfirst(full,&fblk,FA_DIREC) == 0)
         do {
           char name[15];
           if(fblk.ff_attrib != FA_DIREC || strcmp(fblk.ff_name,".") == 0)
              continue;
           strcpy(name,fblk.ff_name);
           strcat(name,"\\");
           item_def.name = name;
           mn_addPopItem(pgrid,++i,&item_def,-1);
           item_def.loc.x += item_def.width + 2;
           if(item_def.loc.x+item_def.width + 2 > files_def.hole.size.width) {
              item_def.loc.x = 2;
              item_def.loc.y++;
           }
         } while (findnext(&fblk) == 0);

      			/* Теперь - имена файлов по маске	*/
      if(was_name)
         strcpy(full+name_pos,_name);
      if (findfirst(full,&fblk,0) == 0)
         do {
           if(fblk.ff_attrib == FA_DIREC)
              continue;
           item_def.name = fblk.ff_name;
           mn_addPopItem(pgrid,++i,&item_def,-1);
           item_def.loc.x += item_def.width + 2;
           if(item_def.loc.x+item_def.width + 2 > files_def.hole.size.width) {
              item_def.loc.x = 2;
              item_def.loc.y++;
           }
         } while (findnext(&fblk) == 0);

      			/* Что там выбрал пользователь?	*/
      if((pitem = mn_askGrid(pgrid,inLine)) == NULL)
         done = -1;     /* Нажата клавиша ESC - выход из цикла	*/
      strcpy(name,mn_PopItemName(pitem));
      strcpy(full+name_pos,name);
      strcpy(name,full);
      if(name[strlen(name)-1] == '\\') {
         if(was_name)
            strcat(name,_name);
         mn_ClearHole(mn_HoleInPop(pgrid));
         mn_DisposeItemSet(mn_SetInPop(pgrid),disposePopField);
      }
      else {
         done = 1;
      }
   }
   mn_disposePop(pgrid);

   		/* После выхода из цикла done равняется:	*/
                /*  1, если пользователь выбрал нужный файл,	*/
                /* -1, если была нажата клавиша ESC.		*/
   return done == 1;

}/*FileMenu*/

ENTRY char *getFileName(char *mask, char *name)
{
   char inname[MAXPATH];
   int dummy;

   if (!FileMenu(mask,inname))
      return NULL;
   utl_fname(inname,name,&dummy);

   return name;

}/*gatFileName*/
