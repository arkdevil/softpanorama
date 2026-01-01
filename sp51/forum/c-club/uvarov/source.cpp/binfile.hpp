/*--------------------------------------------------*
* Файл BINFILE.HPP                                  *
* автор : Ушаров В.В.                               *
* Дата  :    09.1992                                *
* Организация работы с файлом прямого доступа       *
----------------------------------------------------*/
#ifndef __BIN___FILE__HPP
#define __BIN___FILE__HPP

#include<stdio.h>

const int Open           =  254;
const int NotOpen        =  2;
const int NotReadChar    =  4;
const int NotPutChar     =  8;
const int NotClose       =  16;
const int NotPutString   =  32;
const int NotReadString  =  64;
const int NotSeek        =  128;
const int NotReadData    =  512;
const int NotPutData     =  1024;
const int NoError        =  2048;
const int PutError       =  4096;
//===========+FILE+WORKING+==========================//

class BinFile {
	int status;
	char *FileName;
	char *FileRegim;
	long length;
	int mask;

public:
	FILE *stream;
//constructors
	BinFile(char *name , char *access ,int _mask=NoError)
		{status = 0; OpenFile(name ,access); mask=_mask;}
	BinFile() {status = 0;}
	BinFile(FILE *name,char *flname,char *access,int _mask=NoError)
		{status = 0;stream=name;
		FileRegim=access;
		FileName=flname;
		mask=_mask;
		}

//destructor
	~BinFile(void) { }

//inline functions
        FILE *GetFile(void)   { return stream;            }
        char *GetName(void)   { return FileName;          }
        char *GetAccess(void) { return FileRegim;         }
        int   GetStatus(void) { return status;            }
        long GetPos(void)     { return ( ftell(stream) ); }

//member functions
	long GetSize(void);
	int  OpenFile(char *name ,char *access);
	int  Close(void);
	long FileSize(void);
	int  SetPos(long _offset=0L,int _fromwhere=SEEK_SET);


	char *ReadString( int siz,long int position );
	char *ReadString( int siz );
	int  PutString(  char *string ,long int position );
        int  PutString(char *_string);

	char ReadChar(long int position );
        int  PutChar( char numer ,long int position  );
	char ReadChar(void);
        int  PutChar(char _my);

	virtual void Error(void);
        int Statistics(void);

};
#endif
