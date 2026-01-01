/*--------------------------------------------------*
* Файл TEXTFILE.HPP                                 *
* автор : Ушаров В.В.                               *
* Дата  :    09.1992                                *
* Организация работы с файлом последовательного     *
* доступа                                           *
----------------------------------------------------*/
// very simple 
// just only for learn process

#include <stdio.h>
#include "textfile.hpp"

TextFile::TextFile(char *_name ,
			 char *_access ,
				int _mask) :
					 BinFile(_name,_access,_mask)
		{status = 0;  mask=_mask;Numer =0;}

TextFile::TextFile(FILE *_name,
			 char *_flname,
				char *_access,
					int _mask) :
						BinFile(_name,_flname,_access,_mask)
		{status = 0;  mask=_mask; Numer =0;}

TextFile::TextFile(FILE *_name,
					int _mask) :
						BinFile(_name,"empty","any",_mask)
		{status = 0;  mask=_mask;Numer =0;}


//---------------------------------------------------//
int TextFile::PutLine(char *line)
	{ Numer++;
        return fputs(line,stream);
        }
//---------------------------------------------------//
char *TextFile::ReadLine(char *line)
{  Numer++;
if (fgets(line,MAX_STRING_LENGTH,stream) == NULL) return NULL;
	else return line;
}
//---------------------------------------------------//
char *TextFile::ReadLine(void)
{  Numer++;
char line[MAX_STRING_LENGTH];
*line='\0';
if (fgets(line,MAX_STRING_LENGTH,stream) == NULL) return NULL;
	else return line;
}
