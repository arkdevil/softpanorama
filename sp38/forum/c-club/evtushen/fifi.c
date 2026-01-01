#include<dos.h>
#include<dir.h>
#include<string.h>
#include<stdlib.h>
#include<stdio.h>
#include<conio.h>

typedef struct dir
{
	char DirName[14];
	struct dir *Right;
	struct dir *Down;
}
Dir;

char *Process[]=
{
	"\n\r┌────────────────────┐",
	"\n\r│ Processed drive A: │",
	"\n\r"
};
char HelpText[]=
"\r\n\
  Elisoft File Find Utility. Version 2.0\r\n\
  Copyright (C) Elisoft Computer Group.\r\n\
   Freeware !\r\n\
      Usage: fifi file_spec\r\n\
  Written by Serj I.Evtushenko.\r\n";
char wildcards[14];
char old_path[64];
char curr_path[64];
int  all_files=0;
int  total = 0;
int  all_dirs=0;
int  old_drive;
Dir * one_dir_scan(void);
void sub_dir_scan(void);
Dir * recurser(void);

int main(int count,char **args)
{
	int i;
	int j;
	int k;

	if(count != 2)
	 {
		printf("%s",HelpText);
		return 0;
	 }
	strcpy(wildcards,args[1]);
	old_drive=getdisk();
	i=setdisk(old_drive);
	for(j=2;j<i;j++)
	 {
		setdisk(j);
		if(getdisk()!=j)
		break;
		*(strchr(Process[1],':')-1)='A'+j;
		for(k=0;k<3;k++)
		 {
			cputs(Process[k]);
			clreol();
		 }
		sub_dir_scan();
		printf("\n\r%d files found",all_files);
		total+=all_files;
		all_files = 0;
	 }
	setdisk(old_drive);
	printf("\nTotal subdirs scanned:%d\nTotal files found:%d\n",all_dirs,total);
	return 0;
}
void sub_dir_scan(void)
{
	getcurdir(0,old_path);

	chdir("\\");
	recurser();
	chdir(old_path);
}
Dir * recurser(void)
{
	Dir *d,*t;

	getcwd(curr_path,64);
	cputs(curr_path);
	clreol();
	d=one_dir_scan();
	t=d;
	gotoxy(1,wherey());
	while(d)
	 {
		chdir(d->DirName);
		d->Right=recurser();
		chdir("..");
		d = d->Down;
	 }
	return t;
}
Dir * one_dir_scan(void)
{
	struct ffblk ffblk;
	int done;
	Dir *d,*t;

	d=t=NULL;
	done = findfirst("*.*",&ffblk,0xff);
	while(!done)
	 {
		if(ffblk.ff_name[0] !='.' && (ffblk.ff_attrib & FA_DIREC) == FA_DIREC )
		 {
			if(!d)
			 {
				d = (Dir *)malloc(sizeof(Dir));
				t = d;
			 }
			else
			 {
				d->Down  = (Dir *)malloc(sizeof(Dir));
				d        = d->Down;
			 }
			d->Right = NULL;
			d->Down  = NULL;
			strcpy(d->DirName,ffblk.ff_name);
			all_dirs++;
		 }
		done = findnext(&ffblk);
	 }
	done = findfirst(wildcards,&ffblk,0xff);
	while(!done)
	 {
		cputs("\n\r  ■ ");
		cputs(ffblk.ff_name);
		clreol();
		all_files++;
		done = findnext(&ffblk);
		if(done)
		 {
			cputs("\n\r");
			clreol();
		 }
	 }
	return t;
}

