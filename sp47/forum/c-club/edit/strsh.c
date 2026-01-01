void stshadow(startx,starty,string_sh,color_no,
	      color_ch,color_sh,number_ch,point_sh)
char *string_sh[];
int  number_ch[];
int  startx, starty;
int  color_no, color_ch, color_sh;
int  point_sh;
{
PrintString(startx,starty,string_sh[point_sh],color_no);
PrintUsingCharY(startx+strlen(string_sh[point_sh]),starty,1,'▄',color_sh);
NegTabX(startx,starty,strlen(string_sh[point_sh]),color_no);
if(number_ch[point_sh]!=-1)
   NegTabX(startx+number_ch[point_sh]+1,starty,1,color_ch);
   PrintUsingCharX(startx+1,starty+1,strlen(string_sh[point_sh]),
		   '▀',color_sh);
}