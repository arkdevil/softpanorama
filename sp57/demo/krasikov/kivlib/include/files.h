/***************************************************************/
/*                                                             */
/*              KIVLIB include file FILES.H                    */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/

#if !defined( __FILES_H)
#define __FILES_H

#ifndef __cplusplus
#error  Must be in C++ mode !
#endif

#if !defined( ___DEFS_H )
#include <_defs.h>
#endif

#include <_NULL.H>

#if !defined( __IO_H)
#include <io.h>
#endif

#if !defined( __ALLOC_H)
#include <alloc.h>
#endif



_CLASSDEF(file)
_CLASSDEF(written)
_CLASSDEF(dos_file)
_CLASSDEF(xms_file)
_CLASSDEF(data_file)


#define FILE_LINK(name)    inline file& operator << ( file& f, name& n) { return f << Rwritten(n); }; \
                           inline file& operator << ( file& f, name* n) { return f << *(Pwritten(n)); }; \
                           inline file& operator >> ( file& f, name& n) { return f >> Rwritten(n); }; \
                           inline file& operator >> ( file& f, name* n) { return f >> *(Pwritten(n)); };





class _CLASSTYPE written {
      public:
      written(){};
      virtual ~written(){};
      virtual void write(Rfile)=0;
      virtual Pwritten read(Rfile)=0;
};

class _CLASSTYPE file {
    protected:
    int oK;
    public:
    virtual int ok() {return oK;};
    virtual int write(void*,unsigned int)=0;
    virtual int read(void*,unsigned int)=0;
    file() {oK=1;};
    virtual ~file() {};
    virtual long pos()=0;
    virtual long pos(long,int=0)=0;
    inline Rfile operator << (int);
    inline Rfile operator << (char);
    Rfile operator << (unsigned char c) { return (*this)<<(char)c;};
    Rfile operator << (unsigned int j) { return (*this)<<(int)j ;};
    inline Rfile operator << (long);
    Rfile operator << (void far * p) { return (*this)<<(long)p; };
    Rfile writeBytes(void _FAR * buf, unsigned int l);
    Rfile writeStr(char* s);

    inline Rfile operator >> (int&);
    Rfile operator >> (unsigned int& j) { return (*this)>>(int&)j; };
    inline Rfile operator >> (char&);
    Rfile operator >> (unsigned char& c) { return (*this)>>(char&)c; };
    inline Rfile operator >> (long&);
    Rfile operator >> (void far * &p) { return (*this)>>(long&)p; };
    Rfile readBytes(void _FAR * buf, unsigned int l);
    char* readStr();

    Rfile operator << (Rwritten w) { w.write(*this); return *this;};
    Rfile operator >> (Rwritten w) { w.read(*this); return *this;};

};


class _CLASSTYPE dos_file : public file {
    protected:
    int handle;
    public:
    virtual int write(void _FAR * buf, unsigned int len);
    virtual int read(void _FAR * buf, unsigned int len);
    dos_file(){handle=-1; oK=1;};
    dos_file(char * name, int mode);
    int open(char * name, int mode);
    int eof() { return ::eof(handle);};
    int close() { return ::close(handle);};
    virtual void trunc() { ::chsize(handle,pos()); };
    virtual ~dos_file() { close();};
    virtual long pos() { return tell(handle); };
    virtual long pos(long offs, int fromwhere) { return lseek(handle,offs,fromwhere);};
    };


class _CLASSTYPE xms_file : public file {
      protected:
      long Pos;
      long Size;
      unsigned int handle;
      public:
      xms_file(long size);
      virtual ~xms_file();
      virtual int write(void _FAR *,unsigned int);
      virtual int read(void _FAR *,unsigned int);
      virtual long pos() { return Pos; };
      virtual long pos(long,int=0);
      };



class _CLASSTYPE data_file : public dos_file {
             protected:
             long startpos;
             int attr;
             char _FAR * fname;
             public:
             data_file(){handle=-1; attr=0; startpos=0; oK=1; fname=NULL;};
             data_file(char _FAR * name, int mode);
             int open(char _FAR * name, int mode);
             virtual void trunc();
             virtual ~data_file(){ close();};
             virtual void close(){
                 ::close(handle);
                 if (fname) {
                     _chmod(fname,1,attr);
                     free(fname);
                     fname=NULL;
                 };
             };
             virtual long pos();
             virtual long pos(long offs, int fromwhere);

             private:
             void writeHeader();
             };



#endif
