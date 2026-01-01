#include<dos.h>
#include<dir.h>
#include<string.h>
#include<stdlib.h>

typedef struct dir
{
	char DirName[14];
	struct dir *Right;
	struct dir *Down;
}
Dir;

char Process[]="\r\n┌────────────────────┐\r\n│ Processed drive A: │";
char HelpText[]=
"\r\n\
  Elisoft File Find Utility. Version 2.2\r\n\
  Copyright (C) Elisoft Computer Group.\r\n\
   Freeware !\r\n\
      Usage: fifi file_spec\r\n\
  Written by Serj I.Evtushenko.\r\n";
char *wildcards;
char *old_path;
char *curr_path;
char *count1;
int  all_files=0;
int  total = 0;
int  all_dirs=0;
int  old_drive;
void puts_dos(char *string);
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
		puts_dos(HelpText);
		return 0;
	 }
	wildcards = malloc(14);
	old_path  = malloc(64);
	curr_path = malloc(64);
	count1    = malloc(8);
	
	strcpy(wildcards,args[1]);
	old_drive=getdisk();
	i=setdisk(old_drive);
	for(j=2;j<i+5;j++)
	 {
		setdisk(j);
		if(getdisk()!=j)
			continue;
		*(strchr(Process,':')-1)='A'+j;
		puts_dos(Process);
		sub_dir_scan();
		total+=all_files;
		all_files = 0;
	 }
	setdisk(old_drive);
	puts_dos("\r\n──────────────────────");
	puts_dos("\r\nTotal subdirs scanned: ");
	puts_dos(itoa(all_dirs,count1,10));
	puts_dos("\r\nTotal files found: ");
	puts_dos(itoa(total,count1,10));
	puts_dos("\r\n");
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
	d=one_dir_scan();
	t=d;
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
		puts_dos("\r\n");
	 	puts_dos(curr_path);
	 	if(curr_path[3])	// if not root dir
			puts_dos("\\");
		puts_dos(ffblk.ff_name);
		all_files++;
		done = findnext(&ffblk);
	 }
	return t;
}
void puts_dos(char *string)
{
        int len;
        
        len = strlen(string);
        string[len]='$';
        bdos(9,(unsigned)string,0);
        string[len]='\0';
}

