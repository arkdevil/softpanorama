struct asm_task
{
        unsigned sp;
        unsigned ss;
        asm_task* next;
        int qactive;
        int done;
};

extern pascal asm_task* active_task;

extern "C" void far pascal stop();
extern "C" void far pascal pause();
extern "C" void far pascal build(asm_task*);
extern "C" void far pascal ruin(asm_task*);
extern "C" void far pascal wake(asm_task*);
extern "C" void far pascal activate(asm_task*,void far (*f)(void*),void* parm,
                                    int stack, unsigned stack_len );


