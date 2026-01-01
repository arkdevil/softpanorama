#include<dos.h>
#include<dir.h>
#include<string.h>
#include<keys.h>

#define BeforeName	4
#define BarLen		20

typedef struct dir
{
	char DirName[14];
	struct dir *right;
	struct dir *down;
}
Dir;

Dir  Tree;
int  Level;
char Template[]="                                                          ";
char tmp[80];
char old_path[64];
char curr_path[64];
char selected_path[64];
int  all_dirs=0;
int  allrows;
char far *ScreenPage;
char credits[]=" Esc Quit   Enter Change Directory and Quit                      │ Elisoft,1991 ";
char goodbye[]=" Elisoft Change Directory. Version 1.0                           │ Elisoft,1991 ";
//
int current_row;
int start_col;
int current_name;
int selected_name;
int start_name;
int start_row;
int max_row;
int tree_width;
//
char root[]="A:\\";

void TypeTree(Dir *);
int  GetTree(Dir *);
Dir  *one_dir_scan(void);
void sub_dir_scan(void);
Dir  *recurser(void);
int  set_vid(void);
void write_string_by_len(int x,int y,char *str,int len,int attrib);
void putch(int x,int y,char ch,int attrib,int times);
void goto_xy(char x,char y);
void __int__(int);

int main(void)
{
	set_vid();
	write_string_by_len(allrows/2-2,34,"╔══════════════╗",16,0x30);
	write_string_by_len(allrows/2-1,34,"║   Scanning   ║",16,0x30);
	write_string_by_len(allrows/2  ,34,"║              ║",16,0x30);
	write_string_by_len(allrows/2+1,34,"╚══════════════╝",16,0x30);
	sub_dir_scan();
	putch(0,0,' ',0x07,(allrows+1)*80);// clear screen
	Tree.DirName[0]='\0';
	current_name= 0  ;// internal counters for TypeTree
	current_row = 0  ;// must by ZEROED before call to TypeTree
	start_col   = 0  ;// start left column for output
	start_row   = 1  ;// start top row for output
	tree_width  = 80 ;// width of window to be typed tree
	start_name  = 0  ;// starting name number (to be placed on start_row)
	selected_name = 0;// number of name (from 0 to all_dirs) to be highlighted
	max_row = allrows-1;// bottom row for output
	strcpy(curr_path,"Path ");
	root[0]+=getdisk();
	strcat(curr_path,root);
	*strchr(curr_path,'\\')='\0';
	strcpy(selected_path,curr_path);
	strcat(selected_path,"\\");
	write_string_by_len(0,0,selected_path,80,0x30);
	write_string_by_len(allrows,0,credits,80,0x30);
	TypeTree(&Tree);
	if(!GetTree(&Tree))
		chdir((strchr(selected_path,':')+1));
	putch(0,0,' ',0x07,(allrows+1)*80);
	write_string_by_len(0,0,goodbye,80,0x1b);
	goto_xy(1,0);
	return 0;
}
void sub_dir_scan(void)
{
	getcurdir(0,old_path);

	chdir("\\");
	Level=0;
	Tree.down=recurser();
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
		write_string_by_len(allrows/2,35,"",14,0x30);
		write_string_by_len(allrows/2,41-strlen(d->DirName)/2,d->DirName,strlen(d->DirName),0x30);
		d->right=recurser();
		chdir("..");
		d = d->down;
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
				d->down  = (Dir *)malloc(sizeof(Dir));
				d        = d->down;
			 }
			d->right = NULL;
			d->down  = NULL;
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
	while(d)
	 {
		strcat(curr_path,"\\");
		strcat(curr_path,d->DirName);
		strcpy(tmp,Template);
		tmp[Level*BeforeName]=(d->down) ?'├':'└';
		memset(&tmp[Level*BeforeName+1],'─',BeforeName);
		Template[Level*BeforeName]=(d->down) ?'│':' ';
		strcpy(&tmp[(Level+1)*BeforeName],d->DirName);
		if(current_row+start_row<=max_row && current_name>=start_name)
		 {
			if(current_name!=0)
			 {
				write_string_by_len(current_row+start_row,start_col,tmp,tree_width,0x07);
				if(selected_name == current_name)
				write_string_by_len(current_row+start_row,start_col+Level*BeforeName+2,&tmp[Level*BeforeName+2],BarLen,0x1b);
			 }
			else
				write_string_by_len(current_row+start_row,start_col,root,(selected_name)?tree_width:BarLen,(selected_name)?0x07:0x1b);
			current_row++;
			if(selected_name == current_name)
				strcpy(selected_path,curr_path);
		 }
		current_name++;
		Level++;
		TypeTree(d->right);
		Level--;
		curr_path[strlen(curr_path)-strlen(d->DirName)-1]='\0';
		d = d->down;
	 }
}
int set_vid(void)
{
	int vmode;
	char far *param=(char far *)0x00000449L;
	int  far *offset=(int far *)0x0000044eL;
	vmode = *param;
	if((vmode!=2) && (vmode!=3) && (vmode!=7)) 
		return 1;
	if(vmode==7)
		ScreenPage=(char far *)0xB0000000L;
	else
		ScreenPage=(char far *)0xB8000000L;
	ScreenPage+=*offset;
	param=(char far *)0x00000484L;
	allrows=*param;
	return 0;
}
void write_string_by_len(int x,int y,char *str,int len,int attrib)
{
	int i,k;
	char far *v;
	char *p;
	v=ScreenPage;

	p=str;
	if(p==NULL) k=0;
	else k=strlen(p);

	v += (x*160) + y*2;
	for(i=y; (i-y) < len ; i++)
	 {
		if((i-y)<k)
		 {
			*v++ =*p++;
			*v++ =attrib;
		 }
		else
		 {
			*v++ =' ';
			*v++ =attrib;
		 }
	 }
}
int GetTree(Dir *tree)
{
	int i,j,k;
	j=start_name;
	k=selected_name;
	for(;;)
	 {
		i = bioskey(0);
		if(i == Enter)
			return 0;
		if(i == Esc)
			return -1;
		if(i == Up)
			selected_name--;
		if(i == Down)
			selected_name++;
		if(i == Home)
			selected_name=start_name=0;
		if(i == End)
		 {
			selected_name=all_dirs;
			start_name = all_dirs-(max_row-start_row);
			if(start_name<0)
			start_name=0;
		 }
		if(selected_name<0)
			selected_name = 0;
		if(selected_name>all_dirs)
			selected_name=all_dirs;
		if(selected_name>start_name+(max_row-start_row))
			start_name++;
		if(selected_name<start_name)
			start_name=selected_name;
		current_row = 0;
		current_name= 0;
		if(j-start_name+k-selected_name)
			TypeTree(tree);
		write_string_by_len(0,0,selected_path,80,0x30);
		j=start_name;
		k=selected_name;
	 }
}
void putch(int x,int y,char ch,int attrib,int times)
{
	int i;
	char far *v;

	v=ScreenPage;

	v += (x*160) + y*2;
	for(i=y; (i-y) < times ; i++)
	 {
		*v++ =ch;
		*v++ =attrib;
	 }
}
void goto_xy(char x,char y)
{

	_AH=2;
	_DL=y;
	_DH=x;
	_BH=0;
	__int__(0x10);
}

