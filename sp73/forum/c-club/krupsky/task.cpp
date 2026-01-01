#include <dos.h>
#include <stdlib.h>
#include <conio.h>
#include "task.h"

static timer* timers;


static void interrupt (*oldint8)(...);
static void interrupt int8(...)
{
        timer* tim=timers;
        while( tim!=NULL )
        {
           if(tim->t) if((--(tim->t))==0) tim->send();
           tim=tim->next;
        };
        oldint8();
}

static void interrupt (*oldint28)(...);
static void interrupt int28(...)
{
        pause();
        oldint28();
}

static void  close_task()
{
        setvect(0x28,oldint28);
        setvect(0x8,oldint8);
}


static void  init_task()
{
        oldint28=getvect(0x28);
        setvect(0x28,int28);
        oldint8=getvect(0x8);
        setvect(0x8,int8);
//        atexit(close_task);
}


static task* ent;


static void f(void* ptr)
{
        task* tt=(task*)ptr;
        tt->body();
        tt->may_close.send();
}

task::task()
{
     if( active_task->next == active_task )
     {
       init_task();
     }
     ent=this;
     stack = new unsigned[2048];
     build(this);
     unsigned seg=FP_SEG(stack)+(FP_OFF(stack)+15)/16;
     activate(this,f,this,seg,4000);
}


task::~task()
{
        may_close.wait();
        ruin(this);
        delete stack;
     if( active_task->next == active_task )
     {
       close_task();
     }
}

void  task::body()
{
          cputs("Деструктор задачи не исполнил pause();\n\r");
          exit(1);
}


void sem_sig::sem_sig()
{
        tsks=0;
}

void sem_sig::link(asm_task* t)
{
        if( tsks==8 )
        {
          cputs("Переполнение очереди к семафору или сигналу\n\r");
          exit(1);
        }
        tsk[tsks++]=t;
}

int sem_sig::unlink(asm_task* t)
{
        int i,k;
        int res=0;
        for( i=0, k=0; i<tsks; i++ )
        {
          if( tsk[i] != t ) tsk[k++]=tsk[i];
          else res=1;
        }
        tsks=k;
        return res;
}

void sem_sig::__get()
{
        unsigned f=_FLAGS; disable();
        if(flag)
        {
          flag=0;
          _FLAGS=f;
        }
        else
        {
          link( active_task );
          _FLAGS=f;
          stop();
        }
}

void sem_sig::__free()
{
        unsigned f=_FLAGS; disable();
        if(tsks==0)  flag=1;
        else
        {
          asm_task* t=tsk[0];
          wake(t); unlink(t);
        }
        _FLAGS=f;
}


semaphor::semaphor()  { flag=1; }

void semaphor::free() {  __free(); }

void semaphor::get()  {  __get();  }

void  signal::send()  {  __free(); }
void  signal::wait()  {  __get();  }
int  signal::waited() {  return tsks != 0; }
signal::signal()
{
      flag=0;
}



timer::timer()
{
        t=0;
        unsigned f=_FLAGS; disable();
        next=timers;
        timers=this;
        _FLAGS=f;
}

timer::~timer()
{
        unsigned f=_FLAGS; disable();
        timer* tt=timers;
        if(tt==this)
        {
          timers=this->next;
        }
        else
        {
          while( tt != NULL )
          {
            if( tt->next==this )
            {
              tt->next=this->next;
              break;
            }
          }
        }
        _FLAGS=f;
}

void timer::start( unsigned n )
{
        t=n;
}


signal* wait( signal* s1,
          signal* , signal* ,
          signal* , signal* ,
          signal* , signal* ,
          signal* , signal* )
{
        int i;
        signal**s=&s1;
        unsigned f=_FLAGS; disable();
        for( i=0; s[i]!=NULL; i++)
        {
          if( s[i]->flag )
          {
            s[i]->flag=0; _FLAGS=f; return s[i];
          }
        }
        for( i=0; s[i]!=NULL; i++)
        {
          s[i]->link(active_task);
        }
        _FLAGS=f;
        stop();
        signal* result=NULL;
        for( i=0; s[i]!=NULL; i++)
        {
          if( s[i]->unlink(active_task) == 0 ) result=s[i];
        }
        return result;
}







task::entry::entry()
{
        owner=ent;
}

void  task::entry::call( void* ptr )
{
        if(owner->done)
        {
           cputs(" обращение ко входу завершившейся задачи\r\n");
           exit(1);
        }
        s.get();
        pointer=ptr;
        called.send();
        accepted.wait();
        s.free();
}

void  *  task::entry::accept()
{
        called.wait();
        return pointer;
}

void  task::entry::end_accept()
{
        accepted.send();
}

int  task::entry::ready()
{
        return accepted.waited();
}












