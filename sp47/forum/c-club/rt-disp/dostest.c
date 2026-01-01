#include	<stdio.h>
#include	<dos.h>
#include	"rtdef.h"
#include	<string.h>
#include	<io.h>
 struct PCB  PCB1,PCB2;
 unsigned int stack1[464],stack2[464];
main()
{
  char    *pByt;
  char	str[80];
  int	res;
  void  ini_proc(),write_proc();

  printf("TEST RESIDENT PROGRAMM\n");
  Create_PCB(PCB1,0,Tp_DOS,0,ini_proc,&stack1[464],FP_SEG(&PCB1),0)
  Install(PCB1,res)
  if(res != 0)
		{ printf("install 1 error %x\n",res);
		  exit();
		}
  Create_PCB(PCB2,7,Tp_DOS,0,write_proc,&stack2[464],FP_SEG(&PCB2),0)
  Install(PCB2,res)
  if(res != 0)
		{ printf("install 2 error %x\n",res);
		  exit();
		}
  RunOnTime(PCB1.P_id,100,res)
  if(res != 0)
		{ printf("run on time 1 error %x\n",res);
		  exit();
		}
/*	RunOnFlag(PCB2.P_id,01,res)

        if(res != 0)
		{ printf("run on flag 2 error %x\n",res);
		  exit();
		}*/
  Residentc
  }

  void	ini_proc()
  {  int res;
	printf("proc 1 started\n");
        Suspend(PCB2.P_id,res)
        if(res != 0)
		{ printf("suspend 02 error %x\n",res);
		}
	RunOnTime(PCB1.P_id,2,res)
        if(res != 0)
		{ printf("run on time 01 error %x\n",res);
		}
	Terminate(0,res)
	while(1)
		printf("error Termination\n");
  }

  void	write_proc()
  {  int res,cil;
     char path[20];
     int atr;
	printf("proc 2 started\n");
     path[0]=0;
     atr=0;
	for(cil=1; cil < 50; cil++)
	{if((res=_creat("c:\tmp",atr)) == -1)
		printf("error create file %x\n",res);
		_write(res,path,20);
		_close(res);
	}
/*        SetFlag(02,res)
        if(res != 0)
		{ printf("set flag 02 error %x\n",res);
		}
	RunOnFlag(PCB2.P_id,01,res)
        if(res != 0)
		{ printf("run on flag 01 error %x\n",res);
		}*/
	Terminate(0,res)
	while(1)
		printf("error Termination\n");
  }

