 /*
   TOUCH.C
   
   Author     : Phil Barnett
   
   Written    : 22-Nov-92
   
   Function   : TOUCH() 
   
   Purpose    : A Clipper function that will change the time and date 
                stamp of a file. 

   Syntax     : TOUCH( FILE_NAME, DATE, TIME )
   
   Parameters : FILENAME (as a string)
                DATE     (as date type)
                TIME     (as a time string  HH:MM:SS)
   
   
   Returns    : 0 if successful
   
   Example    : lSuccess := TOUCH( FILE_NAME, DATE(), TIME() ) == 0
                ? lSuccess
   
   Calls      : LLIBCA.LIB
   
   Warnings   : Earliest possible time/date stamp is 01/01/80 00:00:00
    
*/    

#include <fcntl.h>
#include <stdlib.h>
#include <io.h>
#include <dos.h>
#include <extend.h>


CLIPPER touch()   

{

    struct dos_date { unsigned day : 5;
                      unsigned month : 4;
                      unsigned year80 : 7;  };
      
    struct dos_time { unsigned sec2 : 5;
                      unsigned minutes : 6;
                      unsigned hours : 5; };
                      
    union { struct dos_date d_date;
            unsigned date;  } u1;
                              
    union { struct dos_time d_time;
            unsigned time;  } u2;
    
    int handle, result;
    char *f_name, *p_date, *p_time;

    f_name = _parc(1);
    p_date = _pards(2);
    p_time = _parc(3);
    
    u2.d_time.sec2 = (atoi(p_time+6)/2);
    p_time[5] = '\0';
    u2.d_time.minutes = atoi(p_time+3);
    p_time[2] = '\0';
    u2.d_time.hours = atoi(p_time);
    
    u1.d_date.day = atoi(p_date+6);
    p_date[6] = '\0';
    u1.d_date.month = atoi(p_date+4);
    p_date[4] = '\0';
    u1.d_date.year80 = atoi(p_date)-1980;
    
    if ((handle = open(f_name, O_RDWR )) != NULL)
        {
        result = _dos_setftime( handle, u1.date, u2.time );
        close(handle);
        }
	else   /* Failed to open */
	result = 2;
    
    _retni(result);
}

