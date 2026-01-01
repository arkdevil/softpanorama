#pragma inline
void MySound(int DurationSound,int FreSound){
  asm {		push	dx;
		push	cx;
		push	ax;
		mov	dx,DurationSound;
		in	al,61h;
		and	al,0feh;
      }
	Next:
  asm {		or	al,2;
		out	61h,al;
		mov	cx,FreSound;
      }
	Cyc:
  asm {		loop	Cyc;
		and	al,0fdh;
		out	61h,al;
		mov	cx,FreSound;
      }

	Down:
  asm {		loop	Down;
		dec	dx;
		jnz	Next;
		pop	ax;
		pop	cx;
		pop	dx;
       }
}