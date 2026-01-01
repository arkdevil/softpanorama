/*--------------------------------------------------*
* Файл TEXTFILE.CPP                                 *
* автор : Ушаров В.В.                               *
* Дата  :    09.1992                                *
* Организация работы с файлом последовательного     *
* доступа                                           *
----------------------------------------------------*/
#include "binfile.hpp"
const int MAX_STRING_LENGTH = 1228;
#ifndef __TEXT_FILE__
#define __TEXT_FILE__
/*------------------------------------------------------*/
class TextFile : public BinFile {
        int mask; int status;
	long Numer;
public:
//constructors
	TextFile(char *_name , char *_access ,int _mask=NoError);
	TextFile(FILE *_name,char *_flname,char *_access,int _mask=NoError);
	TextFile(FILE *_name , int _mask=NoError);
//inline function
        long GetNumer(void) {return Numer;}
//destructor
	~TextFile() {}
//member functions
	int PutLine(char *line);
        char *ReadLine(char *line);
        char *ReadLine(void);
};
#endif
