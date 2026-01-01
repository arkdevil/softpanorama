//           Многозадачность для Borland C++ 3.1
//              Крупский В.В. СПб 1994

#ifndef __TASK__
#define __TASK__

#include <stdlib.h>
#include "asm_t.h"

class  task;
class  signal;
class  entry;

class sem_sig
{
protected:
        int flag;
        int tsks;
        asm_task* tsk[8];

        sem_sig();
        void link( asm_task* );
        int unlink( asm_task* );
        void __get();
        void __free();
};

class  semaphor : sem_sig
{
public:
        semaphor();
        void free();
        void get();
};

class  signal : sem_sig
{
public:
        signal();
        void  send();
        void  wait();
        int  waited();

        friend signal* wait( signal* s1,
          signal* =NULL, signal* =NULL,
          signal* =NULL, signal* =NULL,
          signal* =NULL, signal* =NULL,
          signal* =NULL, signal* =NULL);
};

class timer : public signal
{
        unsigned t;
        timer* next;
public:
       void start( unsigned n );
       timer();
       ~timer();

       friend void interrupt int8(...);
};



class  task : public asm_task
{
        virtual void  body();

        class entry
        {
                signal accepted;
                signal called;
                semaphor s;
                void  * pointer;
                task* owner;
          public:
                void*  accept();
                void  end_accept();
                void  call(void*);
                int  ready();
                entry();
        };

        signal may_close;
        unsigned* stack;

  public:

        friend void f(void*);
        friend class entry;

         task();
         ~task();
};


#endif
