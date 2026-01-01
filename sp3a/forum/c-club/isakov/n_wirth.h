                              /* N_Wirth.H */
/* /////////////////////////////////////////////////////////////////////// */
/*        Definitions to write "C" programs in Modula - like style         */
/*              Distribution freely; no modification please!               */
/*                                                                         */
/*  01-Feb-91 :        Konstantin E. Isakov  (C)1991.        : 03-Feb-91   */
#ifndef __N_WIRTH_H /* /////////////////////////////////////////////////// */
#define __N_WIRTH_H

/*                                EXAMPLE :
 -
 -    VOID ProcName (int a, char b, char SelCode) IS
 -      int x, y = 0;
 -    BEGIN
 -      x = 10;
 -      LOOP
 -        IF (a == x) OR (y == (int) b) THEN
 -          WHILE x > 0 DO
 -            x--;
 -          END;
 -        ELSIF x > a THEN
 -          FOR a = x; a > 0; a-- DO
 -            y++;
 -          END;
 -        ELSE
 -          EXIT;
 -        END_IF;
 -      END_LOOP;
 -      SWITCH SelCode OF
 -        case 'a':     x = 20; break;
 -        case 'b':     x = 30; break;
 -        default:      x = 0;
 -      END_SWITCH;
 -    END_PROC;
 */

#define IS       {
#define WHILE     while(
#define DO        ){
#define THEN      ){
#define ELSE      }else{
#define ELSIF     }else if(
#define LOOP      for (;;){
#define EXIT      break
#define FOR       for(
#define IF        if(
#define SWITCH    switch(
#define OF        ){

#define AND       &&
#define OR        ||
#define NOT       !

#define BEGIN
#define BLOCK     {
#define END        }
#define END_IF     }
#define END_LOOP   }
#define END_FOR    }
#define END_WHILE  }
#define END_BLOCK  }
#define END_PROC   }
#define END_SWITCH }

#endif /* //////////////////////////////////////////////////////////////// */
/*                        End of file "N_Wirth.H"                          */
/* /////////////////////////////////////////////////////////////////////// */
