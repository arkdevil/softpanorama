		Title	Arcenstone	It Was Created By  E V E L G A R T E N

Inst		Segment

		Assume	Cs: Inst, Ds: Inst, Es: Inst

Br		Equ	Byte Ptr
Wr		Equ	Word Ptr
Of		Equ	Offset

		Org	100h
Start:
		Push	Cs
		Pop	Ds

		Push	Cs
		Pop	Es

		Mov	Cx,E
		Mov	Si,Of E+2
		Mov	Dx,Of Ef
Book:
		Mov	Ax,[Si]
		Mov	Di,Dx

		Call	Roman

		Call	Showf

		Add	Si,2

		Loop	Book

		Mov	Ax,4c00h
		Int	21h
Showf:
		Push	Cx

		Mov	Ah,40h
		Mov	Bx,1
		Mov	Cx,27
		Int	21h

		Mov	Di,Dx
		Mov	Cx,25
		Mov	Al,20h
		Cld

		Rep	Stosb

		Pop	Cx

		Retn

E		Dw	40

		Dw	1,2,3,4,5,6,7,8,9,10
		Dw	11,12,13,14,15,16,17,18,19,20
		Dw	30,40,50,60,70,80,90,100,200,400
		Dw	500,900,1000,0,9000,27,127,1727,3901,8999

Ef		Db	25 Dup (20h),13,10

		Include	Roman.In

Inst		Ends

		End	Start

