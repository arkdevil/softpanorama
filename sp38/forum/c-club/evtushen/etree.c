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

char old_path[64];
char curr_path[64];
int  all_dirs=0;
char total[]="\nTotal directories :$";
Dir  * one_dir_scan(void);
void sub_dir_scan(void);
Dir  * recurser(void);

int main(void)
{
	char buff[10];
	getcurdir(0,old_path);
	chdir("\\");
	recurser();
	chdir(old_path);
	bdos(9,(unsigned)total,0);
	itoa(all_dirs,buff,10);
	strcat(buff,"\n\r$");
	bdos(9,(unsigned)buff,0);
	return 0;
}
Dir * recurser(void)
{
	Dir *d,*t;
	getcurdir(0,curr_path);
	strcat(curr_path,"\n\r$");
	bdos(9,(unsigned)curr_path,0);
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
