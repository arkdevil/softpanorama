/* structure prototip for MOUSE PRESS function     */
/*            by Zelivianski E.B.02.10.89. v.m.1.0.*/

struct PRESS
{ int l:1; /* left   buttom pressed */
  int r:1; /* middle buttom pressed */
  int m:1; /* right  buttom pressed */
  int dummy:5;
};