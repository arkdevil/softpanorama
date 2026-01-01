#include<dos.h>
#include<dir.h>
#include<string.h>
#include<stdlib.h>
#include<conio.h>

typedef struct dir
{
	char DirName[14];
	struct dir *Right;
	struct dir *Down;
}
Dir;

Dir  * Tree;
int  Level;
char Template[]="                                                          ";
char tmp[80];
void TypeTree(Dir *);
char old_path[64];
char curr_path[64];
int  all_dirs=0;

Dir  * one_dir_scan(void);
void sub_dir_scan(void);
Dir  * recurser(void);

int main(void)
{
	sub_dir_scan();
	cputs("\n\rRoot\n\r");
	clreol();
	TypeTree(Tree);
	return 0;
}
void sub_dir_scan(void)
{
	getcurdir(0,old_path);

	chdir("\\");
	Level=0;
	Tree=recurser();
	chdir(old_path);
}
Dir * recurser(void)
{
	Dir *d,*t;

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
	done = findfirst("*.*",&ffblk,0x10);
	while(!done)
	 {
		if(ffblk.ff_name[0] !='.' && ffblk.ff_attrib == 0x10)
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
	return t;
}
void TypeTree(Dir *tree)
{
	Dir *d;
	d=tree;
	Level++;
	while(d)
	 {
		strcpy(tmp,Template);
		tmp[Level*2]=(d->Down) ?'├':'└';
		tmp[Level*2+1]='─';
		Template[Level*2]=(d->Down) ?'│':' ';
		strcpy(&tmp[(Level+1)*2],d->DirName);
		cputs(tmp);
		clreol();
		cputs("\n\r");
		clreol();
		TypeTree(d->Right);
		d = d->Down;
	 }
	Level--;
}


