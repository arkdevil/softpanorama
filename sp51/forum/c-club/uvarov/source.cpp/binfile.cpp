/*--------------------------------------------------*
* Файл BINFILE.CPP                                  *
* автор : Ушаров В.В.                               *
* Дата  :    09.1992                                *
* Организация работы с файлом прямого доступа       *
----------------------------------------------------*/

#include<stdio.h>
#include<string.h>
#include <sys\stat.h>
#include <time.h>

#include "binfile.hpp"

long BinFile::GetSize(void)
{
   long curpos;

   curpos = ftell(stream);
   fseek(stream, 0L, SEEK_END);
   length = ftell(stream);
   fseek(stream, curpos, SEEK_SET);
   return length;
}

//--------------------File---------------------//
//member function-------------------------------------------
	int BinFile::OpenFile(char *name ,char *access      )
{
FileName=strdup(name);
FileRegim=strdup(access);
if ((stream=fopen(name , access)) == NULL)
                                                       {
                                                status |=NotOpen;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                               return EOF;
                                                       }
length=FileSize();
status=Open;

return 1;
}

//member function-------------------------------------------
	int BinFile::Close(void)
{
if (fclose(stream) == EOF)
                                                       {
                                                status |=NotClose;
                                                       switch(mask) {
                                               case NoError:  break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                               return EOF;
                                                       }
return 1;
}

//Setting to stream --------------------------------//
        int BinFile::SetPos(long _offset,int _fromwhere)
{
int res;
if ( (res= fseek (stream,_offset,_fromwhere)) != 0)
                                                       {
                                               status |= NotSeek;
                                                       switch(mask) {
                                               case NoError: break;
                                               case PutError:
                                                               Error();
                                               break;
                                                                    }
                                               return EOF;
                                                       }
return 1;
}

//---------- ----------String---------- ---------//
//member function-------------------------------------------
	char *BinFile::ReadString( int size , long int position )
{
char *buf;
buf=new char[(size+1)];
unsigned n;

	if ((fseek(stream,position,0)) != 0)
                                                       {
                                                       switch(mask) {
                                               case NoError:              break;
                                               case PutError:
                                               status |=NotSeek;
                                                          Error();
                                               break;
                                                                    }
                                               return NULL;
                                                      }
 if ( (fgets(buf,size,stream)) == NULL)
                                                       {
                                               status |=NotReadString;
                                                       switch(mask) {
                                               case NoError:              break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return NULL;
                                                       }
return (buf);
}
//member function---------------------------------
	char *BinFile::ReadString( int size )
{
char *buf;
buf=new char[(size+1)];
buf[0]='\0';
 if ( (fgets(buf,size,stream)) == NULL)
                                                       {
                                               status |=NotReadString;
                                                       switch(mask) {
                                               case NoError:              break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return NULL;
                                                       }

return (buf);
}

//member function----------------------------------
	int  BinFile::PutString(  char *string , long int position )
{
	if (fseek(stream,position,0) != 0)
                                                       {
                                               status |=NotSeek;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return EOF;
                                                       }
if (fputs(string,stream) == EOF)
                                                       {
                                               status |=NotPutString;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                               return EOF;
                                                       }
        return 1;
}

//member function--------------------------------------
	int  BinFile::PutString(  char *string )
{
if (fputs(string,stream) == EOF)
                                                       {
                                                       status |=NotPutString;
                                                       switch(mask) {
                                               case NoError:              break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                               return EOF ;
                                                       }
return 1;
}
//--------------------CHAR---------------------//

//member function
	int BinFile::PutChar( char numer ,long int position  )
{
	if ((fseek(stream,position,SEEK_SET)) != 0)
                                                       {
                                               status |=NotSeek;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                               return EOF;
                                                       }
if (fputc(numer,stream) == EOF)
                                                       {
                                               status |=NotPutChar;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return EOF;
                                                       }
return 1;
}


//member function-----------------------------------------------
	int BinFile::PutChar( char _my )
{

if (fputc(_my,stream) == EOF)
                                                       {
                                               status |=NotPutChar;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:

                                                          Error();
                                               break;
                                                                    }
                                                return EOF;
        }
return 1;
}

//member function
	char BinFile::ReadChar(long int position )
{
char num;
	if (fseek(stream,position,SEEK_SET ) != 0)
                                                       {
                                                       status |=NotSeek;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                               return EOF;
                                                       }
 if ((num=fgetc(stream)) == EOF)
                                                       {
                                                       status |=NotReadChar;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return EOF;
                                                       }
return (num);
}
//member function
	char BinFile::ReadChar( void )
{
char num;

 if ((num=fgetc(stream)) == EOF)
                                                       {
                                                       status |=NotReadChar;
                                                       switch(mask) {
					       case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return EOF;
                                                       }
return (num);
}
//-------------------Error---------------------//
long BinFile::FileSize(void)
{
long curpos;
curpos=ftell(stream);
//to end
if ( fseek(stream,0L,SEEK_END) != 0)
                                                       {
                                                       status |=NotSeek;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return EOF;
                                                       }

length=ftell(stream);
//back to old pease
if (fseek(stream,curpos,SEEK_SET) != 0)
                                                       {
                                                       status |=NotSeek;
                                                       switch(mask) {
                                               case NoError:             break;
                                               case PutError:
                                                          Error();
                                               break;
                                                                    }
                                                return EOF;
                                                       }

return(length);

}

//-------------------Error---------------------//
	void BinFile::Error(void)
{
	if (status & NotOpen)
	{
		status ^=NotOpen;
		printf("\nFile not Open");
	}

	if (status & NotClose)
	{
		status ^=NotClose;
		printf("\nFile not close");
	}

	if (status & NotPutString)
	{
		status ^=NotPutString;
		printf("\nFile not put string");
	}


	if (status & NotReadString)
	{
		status ^=NotReadString;
		printf("\nFile not Read string");
	}


	if (status & NotPutChar)
	{
		status ^=NotPutChar;
		printf("\nFile not put char");
	}

	if (status & NotReadChar)
	{
		status ^=NotReadChar;
		printf("\nFile not read char");
	}

	if (status & NotReadData)
	{
		status ^=NotReadData;
		printf("\nFile not read DATE");
	}

	if (status & NotPutData)
	{
		status ^=NotPutData;
		printf("\nFile not put DATE");
	}

}
//         End of class definition                             //


int BinFile::Statistics(void)
{
   struct stat statbuf;


   /* get information about the file */
   fstat(fileno(stream), &statbuf);

   /* display the information returned */
   if (statbuf.st_mode & S_IFCHR)
      printf("Handle refers to a device.\n");
   if (statbuf.st_mode & S_IFREG)
      printf("Handle refers to an ordinary \
	     file.\n");
   if (statbuf.st_mode & S_IREAD)
      printf("User has read permission on \
	     file.\n");
   if (statbuf.st_mode & S_IWRITE)
      printf("User has write permission on \
	      file.\n");

   printf("Drive letter of file: %c\n",
	  'A'+statbuf.st_dev);
   printf("Size of file in bytes: %ld\n",
	  statbuf.st_size);
   printf("Time file last opened: %s\n",
	  ctime(&statbuf.st_ctime));
   return 0;
}
