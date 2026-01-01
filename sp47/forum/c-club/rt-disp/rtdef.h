/*▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒                                                              ▒
;▒                  Real Time Operation Sistem                  ▒
;▒                         Define file                          ▒
;▒                                                              ▒
;▒ Create: 17-may-90                                            ▒
;▒                                                              ▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒


; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Process Type
*/
#define		Tp_DOS               1
#define		Tp_Driver            2
#define		Tp_Simple            3
#define		Tp_Operation         4
#define		Tp_Dispatcher        5

/*; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Statuses */

#define		St_Passive	     0
#define		St_Run         	     1
#define		St_Ready       	     2
#define		St_Ready_Cont	     3
#define		St_Wait_time   	     4
#define		St_Wait_time_Cont    5
#define		St_Wait_flag   	     6
#define		St_Wait_flag_Cont    7
#define		St_Semaphore	     8

/*; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Error code */

#define		Err_0                0       ; Successfull
#define		Err_1                1       ; Incorrect parameters
#define		Err_2                2       ; Bad process name
#define		Err_3                3       ; Busy process
#define		Err_4                4       ; Overflow processes list
#define		Err_5                5       ; Busy vector
#define		Err_6                6       ; No place
#define		Err_7                7       ; No that process
#define		Err_8                8       ;
#define		Err_9                9       ;
#define		Err_10               10      ; Incorrect timeout
#define		Err_11               11      ; Incorrect flag number
#define		Err_FF               0FFh    ; Fatal error

/*; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Dispatcher functions */

#define		F_Install		0x0000
#define		F_Kill			0x0100
#define		F_Suspend		0x0200
#define		F_Run			0x0300
#define		F_Terminate		0x0400
#define		F_RunOnTime		0x0500
#define		F_RunOnFlag		0x0600
#define		F_SetFlag		0x0700
#define		F_GetDSBaddr		0x0800
#define		F_WaitOnTime		0x0900
#define		F_WaitOnFlag		0x0a00
#define		F_Exit			0x0b00
#define		F_P			0x0c00
#define		F_V			0x0d00
#define		F_StrtCrtSctn		0x0e00
#define		F_EndCrtSctn		0x0f00

#define		Entry_int		0x0032

 struct PCB	{ unsigned char	P_id,
				P_pri,
				P_type,
				P_status;
		  unsigned int	P_flag,
				P_time;
		 		P_ip,
				P_cs,
		 		P_ss,
				P_sp,
				P_ds,
				P_es,
				P_buf[4],
				P_DSB[2];
		 };

extern  int far calldisp(int,int,int,int);

#define Create_PCB(PCB,PRI,TYP,VECTOR,ENTRY,STACK,DS,ES)\
	PCB.P_pri=PRI;					\
	PCB.P_type=TYP;					\
	PCB.P_flag=VECTOR;				\
	PCB.P_cs=_CS;    			\
	PCB.P_ip=(unsigned)ENTRY;    			\
	PCB.P_ss=_DS;    			\
	PCB.P_sp=(unsigned)STACK;    			\
	PCB.P_ds=DS;					\
	PCB.P_es=ES;
/*
#define		calldisp(Rax,Rcx,Res,Rdx)			\
		_CX=Rcx;                                        \
		_ES=Res;                   			\
		_DX=Rdx;			                \
		_AX=Rax;					\
		__int__(Entry_int);
*/
#define 	Install(PCB,RES)				\
		calldisp(F_Install,				\
			 0,                                     \
			 _DS,           			\
			 (unsigned)&PCB)             		\
		RES=_AX&0x00FF;


#define		Kill(Id,RES)				\
		calldisp(F_Kill | (Id),0,0,0)           \
                RES=_AX&0x00FF;

#define		Suspend(Id,RES)				\
		calldisp(F_Suspend | (Id),0,0,0)        \
                RES=_AX&0x00FF;

#define		Activate(Id,RES)			\
		calldisp(F_Suspend | (Id),0,0,0)   	\
                RES=_AX&0x00FF;

#define		Run(Id,RES)				\
		calldisp(F_Run | (Id),0,0,0)            \
                RES=_AX&0x00FF;

#define		Terminate(Id,RES)			\
		calldisp(F_Terminate | (Id),0,0,0)      \
                RES=_AX&0x00FF;

#define		RunOnTime(Id,Delay,RES)			\
		calldisp(F_RunOnTime | (Id),Delay,0,0)	\
                RES=_AX&0x00FF;

#define		RunOnFlag(Id,Flag,RES)			\
		calldisp(F_RunOnFlag | (Id),Flag,0,0)	\
                RES=_AX&0x00FF;

#define		SetFlag(Flag,RES)			\
		calldisp(F_SetFlag,Flag,0,0)		\
                RES=_AX&0x00FF;

#define 	Create_Process(PCB,PRI,TYP,ENTRY,STACK,DS,ES,RES)\
	Create_PCB(PCB,PRI,TYP,0,ENTRY,STACK,DS,ES)		\
	calldisp(F_Install,0,_DS,(unsigned)&PCB)\
	if(!(_AX&0x00FF))then                                    	\
		      {  calldisp(F_Kill | PCB.P_id,0,0,0)	\
			 RES=1;                         	\
		      }                                 	\
		else  {calldisp(F_Suspend | (Id),0,0,0)		\
			RES=_AX&0x00FF;				\
		      }


#define		Exit(RES)				\
		calldisp(F_Exit,0,0,0)			\
		RES=_AX&0x00FF;

#define		Sleep(Delay,RES)			\
		calldisp(F_WaitOnTime,Delay,0,0)	\


#define		Wait_Flag(Flag,RES)			\
		calldisp(F_WaitOnFlag,Flag,0,0)		\
		RES=_AX&0x00FF;

#define		Set_Flag(Flag,RES)			\
		calldisp(F_SetFlag,Flag,0,0)		\
                RES=_AX&0x00FF;

#define		Test_Flag(RES)				\
		RES=*(MK_FP(peek(0,0x61*4+2),peek(0,0x61*4)+26));


#define		Reset_Flag(Flag)			\
		poke(peek(0,0x61*4+2),peek(0,0x61*4)+26, \
		(peek(peek(0,0x61*4+2),peek(0,0x61*4)+26))^(Flag));

#define		_P(Sema)			\
		p_sema(Sema);

#define		_V(Sema)			\
		calldisp(F_V,0,_DS,(unsigned)Sema)

#define		StrtCrtSctn			\
		calldisp(F_StrtCrtSctn,0,_DS,0)

#define		EndCrtSctn			\
		calldisp(F_EndCrtSctn,0,_DS,0)

#define		Resident				\
		keep(0,peek(_psp-1,3));

#define		Residentc				\
		bdos(0x31,peek(_psp-1,3),0);