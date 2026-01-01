/*
        PRIME is (C)opyright 1995 by Paul Damer and Jawed Karim
        You may distribute the source freely only if it remains
        unchanged and is distributed along with prime.doc. You may 
        also recompile it for whatever platform, and give yourself 
        credit by letting it display your name upon startup of 
        PRIME. Leave the authors display lines unchanged however.

        Jawed Karim <kari0022@gold.tc.umn.edu>
*/

#define INCL_VIO

#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <os2.h>

void main()
{
        double x, y;
        int counter = 0;
        char s[2] = {' ', '\0'};
        /*        clrscr(); */
        VioScrollDn(0,0,-1,-1,-1,(PBYTE)&s,0);
        VioSetCurPos(0,0,0);
        
        puts("PRIME NUMBER GENERATOR v1.3");
        puts("(C) 1996 by Jawed Karim <Jawed.Karim-1@umn.edu> and Paul Damer");
        puts("--------------------------------------------------------------");
        puts("");
        printf("START: ");
        scanf("%lf", &x);

        if ( (x < 0) || ( floor(x) != x ) )
        {
                puts("ERROR: enter positive integers only.");
                exit(1);
        }
        
        if (x < 2)
                printf("2\n3\n"); /* the loop leaves these numbers out.. */
        
        if (x == 2)
                printf("3\n");
        
        while (1)
        {
                x++;                
        
                y = floor ( sqrt ( x ) );

        lbl: ;

                if ( ( (x/y)-(floor (x/y)) ) != 0 )
                {
                        y--;                
                        
                        if ( y<2 )
                        {        
                                if (counter == 24)
                                {
                                        VioSetCurPos(0,0,0);
                                        counter = 0;
                                }

                                printf("%.0lf\n", x);
                                counter++;
                        }
                        
                        else
                                goto lbl;
                }
        }
}
