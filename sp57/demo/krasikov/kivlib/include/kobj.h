/***************************************************************/
/*                                                             */
/*                KIVLIB include file  KOBJ.H                  */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/

#if !defined( __KOBJ_H )
#define __KOBJ_H

#if !defined( __cplusplus)
#error Must be in C++ mode !
#endif

#if !defined( ___DEFS_H )
#include <_defs.h>
#endif

#if !defined( __FILES_H)
#include <files.h>
#endif

#if !defined( __DEFINES_H__)
#include <defines.h>
#endif

#include <_NULL.h>



_CLASSDEF(Kobject)
_CLASSDEF(Kcollection)
_CLASSDEF(KScollection)

_CLASSDEF(Kdate)
_CLASSDEF(Ktime)

_CLASSDEF(Kpoint)
_CLASSDEF(Krect)


_CLASSDEF(Kmem)
_CLASSDEF(KWmem)
_CLASSDEF(KWPmem)




typedef void _Cdecl _FAR (*forEachFunc)(void _FAR *, void _FAR *);
typedef int  _Cdecl _FAR (*firstThatFunc)(void _FAR *, void _FAR *);

class _CLASSTYPE Kobject {
      public:
      virtual ~Kobject() {};
      virtual void shutDown()=0;
      static void destroy(Kobject _FAR *);
      };

class _CLASSTYPE Kcollection : public Kobject {
      protected:
      int duplicates;
      int count;
      int size;
      int Delta;
      PKobject _FAR * data;
      public:
      Kcollection(int start, int delta, int dup = 0);
      ~Kcollection();
      virtual int getCount() { return count; };
      virtual void shutDown();
      virtual int  insert(void _FAR * item);
      virtual void remove(void _FAR * item);
      virtual void removeAt(int index);
      virtual int  indexOf(void _FAR * item);
      virtual void free(void _FAR * item);
      virtual void freeAll();
      virtual void error(int code);
      virtual PKobject at(int index);
      virtual void forEach(forEachFunc fef,void _FAR * arg = NULL);
      PKobject firstThat(firstThatFunc ftf, void _FAR * arg = NULL);
      PKobject lastThat(firstThatFunc ftf,  void _FAR * arg = NULL);
      int countThat(firstThatFunc ftf, void _FAR * arg = NULL);
      PKobject operator[](int index) { return at(index);};
      RKcollection operator << (PKobject k) { insert(k); return *this; };
      //Warning !!! Don't return check duplicates!
      int operator +=(PKobject k) { return insert(k);};
};

/****************************************************************
Error codes :
      Out of range   - 1
      No memory      - 2
      Duplicates     - 3
****************************************************************/

class _CLASSTYPE KScollection : public Kcollection {
            protected:
            int keyDuplicates;
            public:
            KScollection(int start, int delta, int keyDup = 1, int dup = 0);
            ~KScollection();
            virtual int  insert(void _FAR * item);
            virtual void _FAR * keyOf(void _FAR * item)=0;
            virtual int compare(void _FAR * key1, void _FAR * key2)=0;
            /****************************************************************
              1 - KEY1 > KEY2  -1 - KEY1 < KEY2  0 - KEY1==KEY2
            ****************************************************************/
            RKScollection operator << (PKobject k) { insert(k); return *this; };
            //Warning !!! Don't return check duplicates!
      };

/****************************************************************
Error codes :
      Out of range   - 1
      No memory      - 2
      Duplicates     - 3
      keyDuplicates  - 4
****************************************************************/



class _CLASSTYPE Kdate : public Kobject {
          protected:
          unsigned long JD;
          public:
          Kdate();
          Kdate(int year, int mon, int day);
          virtual void shutDown(){};
          int year();
          int month();
          int day();
          void setYear(int y);
          void setMonth(int m);
          void setDay(int d);
          void setToday();
          int operator !(); //Day of week, 0 - Sunday

          Kdate& operator += (int days) { JD+=days; return *this; };
          Kdate& operator -= (int days) { JD-=days; return *this; };
          Kdate& operator ++ ()    { JD++; return *this;};
          Kdate& operator ++ (int) { JD++; return *this;};
          Kdate& operator -- ()    { JD--; return *this;};
          Kdate& operator -- (int) { JD--; return *this;};

          friend int operator == (Kdate& d1, Kdate& d2) { return d1.JD==d2.JD; };
          friend int operator != (Kdate& d1, Kdate& d2) { return !(d1==d2); };
          friend long operator -(Kdate& d1, Kdate& d2) { return d1.JD-d2.JD; };
          friend int operator >(RKdate d1, RKdate d2) { return d1.JD>d2.JD;};
          friend int operator <(RKdate d1, RKdate d2) { return d1.JD<d2.JD;};
          friend int operator >=(RKdate d1, RKdate d2){ return !(d1<d2);};
          friend int operator <=(RKdate d1, RKdate d2){ return !(d1>d2);};

          private:
          unsigned long juli(int y, int m, int d);
          void grig(int& y, int&m, int&d);
          };


class _CLASSTYPE Ktime : public Kobject {
                 protected:
                 long counter;
                 public:
                 Ktime();
                 Ktime(int h, int m, int s, int s100=0);
                 virtual void shutDown(){};
                 int hour();
                 int min();
                 int sec();
                 int s100();
                 void setHour(int h);
                 void setMin(int m);
                 void setSec(int s, int s1=0);
                 void setCurTime();


                 Ktime& operator += (int secs) { counter+=long(secs)*100L; return *this; };
                 Ktime& operator -= (int secs) { counter-=long(secs)*100L; return *this; };
                 Ktime& operator ++ ()    { counter+=100; return *this;};
                 Ktime& operator ++ (int) { counter+=100; return *this;};
                 Ktime& operator -- ()    { counter-=100; return *this;};
                 Ktime& operator -- (int) { counter-=100; return *this;};

                 friend int operator == (Ktime& d1, Ktime& d2) { return d1.counter==d2.counter; };
                 friend int operator != (Ktime& d1, Ktime& d2) { return !(d1==d2); };
                 friend long operator -(Ktime& d1, Ktime& d2) { return d1.counter-d2.counter; };
                 friend int operator >(RKtime d1, RKtime d2) { return d1.counter>d2.counter;};
                 friend int operator <(RKtime d1, RKtime d2) { return d1.counter<d2.counter;};
                 friend int operator >=(RKtime d1, RKtime d2){ return !(d1<d2);};
                 friend int operator <=(RKtime d1, RKtime d2){ return !(d1>d2);};

                 };



class _CLASSTYPE Kpoint : public Kobject {
                 public:
                 int x;
                 int y;
                 void set(int X, int Y) { x=X; y=Y;};
                 Kpoint(){ set(0,0);};
                 Kpoint(int X, int Y) { set(X,Y);};
                 virtual void shutDown(){};

                 RKpoint operator += (RKpoint add) { x+=add.x; y+=add.y; return *this; };
                 RKpoint operator -= (RKpoint sub) { x-=sub.x; y-=sub.y; return *this; };


                 friend int operator == (RKpoint one, RKpoint two) { return ((one.x==two.x)&&(one.y==two.y));};
                 friend int operator != (RKpoint one, RKpoint two) { return !(one==two);};
                 friend Kpoint operator +(RKpoint one, RKpoint two) { return Kpoint(one.x+two.x, one.y+two.y);};
                 friend Kpoint operator -(RKpoint one, RKpoint two) { return Kpoint(one.x-two.x, one.y-two.y);};
                 };

_CLASSDEF(Krect)

class _CLASSTYPE Krect : public Kobject {
                 public:
                 Kpoint a;
                 Kpoint b;
                 Krect();
                 Krect(int left, int top, int right, int bottom){a.set(left,top); b.set(right,bottom);};
                 Krect(Kpoint A, Kpoint B):a(A.x,A.y),b(B.x,B.y){};
                 virtual void shutDown(){};
                 int contain(RKpoint p);
                 virtual int empty() { return (!((a.x<=b.x)&&(a.y<=b.y)));};
                 virtual void grow(int dx, int dy);
                 virtual void move(int dx, int dy);
                 virtual void moveTo(int X, int Y);
                 virtual void intersect( RKrect r );
                 virtual void unions( RKrect r );

                 int operator==(RKrect r) { return ((a==r.a)&&(b==r.b));};
                 int operator!=(RKrect r) { return !(*this==r);};

                 };




class _CLASSTYPE Kmem : public Kobject {
             protected:
             void _FAR * addr;
             unsigned int size;
             unsigned int point;
             public:
             Kmem(unsigned int S);
             ~Kmem(){ shutDown(); };
             virtual void shutDown();
             unsigned int count(){ return size;};

             RKmem operator << (void _FAR * from);
             void _FAR * operator &() { return addr; };
             byte& operator [](unsigned int n) { return *((byte*)addr+n);};
             unsigned int operator !() { return size;};

             void rewind() { point=0; };
             };

class _CLASSTYPE KWmem : public written, public Kmem {
             public:
             KWmem(unsigned int S) : written(), Kmem(S) {};
             ~KWmem(){ shutDown();};
             virtual void write(Rfile);
             virtual void shutDown() { Kmem::shutDown();};
             virtual Pwritten read(Rfile);
             };

class _CLASSTYPE KWPmem : public KWmem {
             public:
             KWPmem(unsigned int S) : KWmem(S) {};
             ~KWPmem(){ shutDown(); };
             virtual void write(Rfile);
             virtual Pwritten read(Rfile);
             };




#endif
