;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
;▒                                                              ▒
;▒                  Real Time Operation Sistem                  ▒
;▒                         Define file                          ▒
;▒                                                              ▒
;▒ Create: 15-Feb-90                                            ▒
;▒ Update:  5-Apr-90                                            ▒
;▒                                                              ▒
;▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒


; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Process Type

Tp_DOS          equ     1
Tp_Driver       equ     2
Tp_Simple       equ     3
Tp_Operation    equ     4
Tp_Dispatcher   equ     5

; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Statuses

St_Passive		equ     0
St_Run         		equ     1
St_Ready_Run    	equ     2
St_Ready_Cont		equ	3
St_Wait_time_Run	equ     4
St_Wait_time_Cont	equ	5
St_Wait_flag_Run	equ     6
St_Wait_flag_Cont	equ	7
St_Semaphore		equ	8

; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Error code

Err_0           equ     0       ; Successfull
Err_1           equ     1       ; Incorrect parameters
Err_2           equ     2       ; Bad process name
Err_3           equ     3       ; Busy process
Err_4           equ     4       ; Overflow processes list
Err_5           equ     5       ; Busy vector
Err_6           equ     6       ; No place
Err_7           equ     7       ; No that process
Err_8           equ     8       ;
Err_9           equ     9       ;
Err_10          equ     10      ; Incorrect timeout
Err_11          equ     11      ; Incorrect flag number
Err_FF          equ     0FFh    ; Fatal error

; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Process Control Block

P_id            equ     0               ; Process name
P_pri           equ     P_id+1          ; Process priority
P_type          equ     P_pri+1         ; Process type
P_status        equ     P_type+1        ; Status
P_flag          equ     P_status+1      ; Flag or vector number
P_Sema          equ     P_status+1      ; Semaphore's adress
P_time          equ     P_flag+2
P_ep            equ     P_time+2
P_SS            equ     P_ep+4
P_SP            equ     P_SS+2
P_DS            equ     P_SP+2
P_ES            equ     P_DS+2
P_Ovo		equ	P_ES+2
P_Ovs		equ	P_Ovo+2
P_ISS		equ	P_Ovs+2
P_ISP		equ	P_ISS+2
P_DSB           equ     P_ISP+2

PCB_len		equ	P_DSB + 4

; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Dispatcher Status Block

.DSB_pt		equ	0		; Process table
.DSB_tq		equ	2		; Timeout queue
.DSB_fq         equ	4		; Flag queue
.DSB_rpq_0      equ	6		; Ready process queue ( prior. 0 )
.DSB_rpq_1      equ	8		; Ready process queue ( prior. 1 )
.DSB_rpq_2      equ	10     	        ; Ready process queue ( prior. 2 )
.DSB_rpq_3	equ	12		; Ready process queue ( prior. 3 )
.DSB_rpq_4	equ	14		; Ready process queue ( prior. 4 )
.DSB_rpq_5	equ	16		; Ready process queue ( prior. 5 )
.DSB_rpq_6	equ	18		; Ready process queue ( prior. 6 )
.DSB_rpq_7	equ	20		; Ready process queue ( prior. 7 )
.DSB_rpq_8	equ	22		; Ready process queue ( prior. 8 )
.DSB_f          equ	24		; Flags
.DSB_ct         equ	26		; Current time
.DSB_cpid       equ	28		; Current process name
.DSB_cppri	equ	29		; Current process priority
.DSB_SP_ips     equ	30		; SP of interrupted process stack
.DSB_SS_ips     equ	32		; SS of interrupted process stack
.DSB_sq         equ	34		; Semaphore queue

; ▒▒▒▒▒▒▒▒▒▒▒▒▒ Dispatcher functions

F_Install	equ	0
F_Kill		equ	1
F_Suspend	equ	2
F_Run		equ	3
F_Terminate	equ	4
F_RunOnTime	equ	5
F_RunOnFlag	equ	6
F_SetFlag	equ	7
F_GetDSBaddr	equ	8
F_WaitOnTime	equ	9
F_WaitOnFlag	equ	10
F_Exit		equ	11
F_P		equ	12
F_V		equ	13
F_StrtCrtSctn	equ	14
F_EndCrtSctn	equ	15

Entry_int	equ	32h
Short_flag	equ	1	;number of flags:1-16,0-32

; ************* Macro ******************************

.Create_PCB	MACRO	Name,Id,Pri,PType,Vector
Name		db	Id,Pri,PType,St_Passive
		IFNB	<Vector>
		dw	Vector
		ELSE
		dw	0
		ENDIF
		db	PCB_len - 6 dup (0)
		ENDM

.Install	MACRO	Name,Name_seg,P_off,P_seg,_SS,_SP,_DS,_ES

		push	bx
		push	dx
		push	es

		lea	bx,Name
		mov	ax,Name_seg
		mov	es,ax
		mov	ax,P_off
		mov	es:P_ep[bx],ax
		mov	ax,P_seg
		mov	es:P_ep[bx+2],ax
		mov	ax,_SS
		mov	es:P_SS[bx],ax
		mov	ax,_SP
		mov	es:P_SP[bx],ax
		mov	ax,_DS
		mov	es:P_DS[bx],ax
		mov	ax,_ES
		mov	es:P_ES[bx],ax
		mov	al,es:P_id[bx]
		mov	ah,F_Install
		lea	dx,Name
		int	Entry_int

		pop	es
		pop	dx
		pop	bx

		ENDM

.Kill		MACRO	Id

		IFNB	<Id>
		mov	al,Id
		ELSE
		xor 	al,al
		ENDIF
		mov	ah,F_Kill
		int	Entry_int

		ENDM

.Suspend	MACRO	Id

		mov	ah,F_Suspend
		mov	al,Id
		int	Entry_int

		ENDM

.Run		MACRO	Id

		mov	ah,F_Run
		mov	al,Id
		int	Entry_int

		ENDM

.Terminate	MACRO	Id

		IFNB	<Id>
		mov	al,Id
		ELSE
		xor 	al,al
		ENDIF
		mov	ah,F_Terminate
		int	Entry_int

		ENDM

.RunOnTime	MACRO	Id,Delay

		push	cx
		mov	ah,F_RunOnTime
		mov	al,Id
		mov	cx,Delay
		int	Entry_int
		pop	cx

		ENDM

.RunOnFlag	MACRO	Id,Flag

		push	cx
		mov	ah,F_RunOnFlag
		mov	al,Id
		mov	cx,Flag
		int	Entry_int
		pop	cx

		ENDM

.SetFlag	MACRO	Flag

		push	cx
		mov	ah,F_SetFlag
		mov	cx,Flag
		int	Entry_int
		pop	cx

		ENDM

.Create_Process	MACRO	Name,Name_seg,P_off,P_seg,_SS,_SP
		Local	?l
		.Install	Name,Name_seg,P_off,P_seg,_SS,_SP,DS,ES
		or	al,al
	 	jne	?l
?l:
		push	bx
		push	es
		lea	bx,Name
		mov	ax,Name_seg
		mov	es,ax
		.Suspend	es:P_id[bx]
		pop	es
		pop	bx

		ENDM


.Exit		MACRO	

		mov	ah,F_Exit
		int	Entry_int

		ENDM

.Sleep	MACRO	Delay
		push	cx
		mov	ah,F_WaitOnTime
		mov	cx,Delay
		int	Entry_int
		pop	cx

		ENDM

.Wait_Flag	MACRO	Flag

		push	cx
		mov	ah,F_WaitOnFlag
		mov	cx,Flag
		int	Entry_int
		pop	cx

		ENDM

.Set_Flag	MACRO	Flag

		push	cx
		mov	ah,F_SetFlag
		mov	cx,Flag
		int	Entry_int
		pop	cx

		ENDM

.Test_Flag	MACRO	

		push	es
		push	di
		mov	di,0
		mov	es,di
		mov	di,61h*4
		les	di,es:[di]
		mov	ax,es:.DSB_f[di]
		pop	di
		pop	es

		ENDM

.Reset_Flag	MACRO	Flag

		push	es
		push	di
		mov	di,0
		mov	es,di
		mov	di,61h*4
		les	di,es:[di]
		push	cx
		mov	cx,Flag
		xor	es:.DSB_f[di],cx
		pop	cx
		pop	di
		pop	es

		ENDM

get_disp_time   MACRO   reg
;; reg != DI or ES
		push	es
		push	di
                xor     di,di
		mov	es,di
		mov	di,61h*4
		les	di,es:[di]
                mov     reg,es:.DSB_ct[di]
		pop	di
		pop	es

		ENDM

.P		MACRO	Sema_off,Sema_seg
		.Local	?l,?m

		push	es
		push	bx
		push	dx
		mov	bx,Sema_seg
		mov	es,bx
		mov	bx,Sema_off
		cli
		cmp	es:[bx],0
		je	?l
		dec	es:[bx]
		sti	
		jmp	?m
?l:
		sti
		mov	dx,bx
		mov	ah,F_P
		int	Entry_int
?m:
		pop	dx
		pop	bx
		pop	es

		ENDM

.V		MACRO	Sema_off,Sema_seg

		push	es
		push	dx
		mov	dx,Sema_seg
		mov	es,dx
		mov	dx,Sema_off
		mov	ah,F_V
		int	Entry_int
		pop	dx
		pop	es

		ENDM

.StrtCrtSctn	MACRO	

		mov	ah,F_StrtCrtSctn
		int	Entry_int

		ENDM

.EndCrtSctn	MACRO	

		mov	ah,F_EndCrtSctn
		int	Entry_int

		ENDM

.Prt_str	MACRO	Msg
		push	si
		mov	si,offset msg
		call	prt_msg
		pop	si
		ENDM
