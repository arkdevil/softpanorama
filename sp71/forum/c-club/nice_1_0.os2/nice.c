/******************************************************************
 
 NICE.C : This program allows you to run an OS/2 program in the idle 
          time priority. Invoking:
                                                                                             
     NICE /switches MYPROG.EXE program_parameters

Like:

     NICE SEARCH "keyword"  readme.doc > keyword.out

NICE switches:

    /C : runs program in time-critical priority instead of idle priority.
    /S : runs program synchronously with NICE.EXE.
    /D : runs program detached from NICE.EXE (no console I/O possible)

Can be compiled under IBM C/SET 2 compiler.
Programmer can be reached via BITNET:  <TURGUT@FRORS12.BITNET>
                                    or <TURGUT@TREARN.BITNET>
*******************************************************************/
char *copyright = "NICE V1.0 (C)1992 T.Kalfaoglu, 1378 Sok. 8/10, Alsancak,Izmir,Turkey\n";
#define INCL_DOSPROCESS
#include <os2.h>

#include <stdio.h>
#include <conio.h>

#define BUFLEN 512L

/* defining flags for the DosExecPgm call: */
#define SYNCH 0L
#define ASYNCH 2L
#define DETACH 4L

/* flags for DosSetPriority call: */
#define IDLE 1L
#define CRITICAL 3L

void helper(void);

main(int argc, char *argv[])
{
   RESULTCODES result;
   unsigned int i, startfrom = 1;
   ULONG prt=IDLE, rc, dflag = ASYNCH, termPID;  
   LONG delta=-31L, childID; 
   char buffer[BUFLEN], flag, args[BUFLEN], cmdline[BUFLEN], out[128];
   
   fputs(copyright,stderr);
   if (argc<2) helper();
   
   if (*argv[1] == '/' || *argv[1] == '-') { /* parsing run-time options */
      startfrom = 2;
      flag='?';
      for (i=1;flag;i++) {
         flag = toupper(*(argv[1]+i));
         switch (flag) {
            case 'C'  : prt   = CRITICAL;  
                        delta = 31L;
                        break;
            case 'S'  : dflag = SYNCH;
                        break;
            case 'D'  : dflag = DETACH;
                        break;
            case  0   : break; 
            default   : 
                sprintf(out,"Parameter '%c' is not recognised.\n",flag);
                fputs(out,stderr);
                exit(1);
         }
      }
   }
   strcpy(args,"/C \"");  /* parameter to CMD.EXE */
   for (i=startfrom;i  < argc;i++) {
      strcat(args,argv[i]);                                                                         
      strcat(args," ");                  
   }
   strcat(args,"\"");
   strcpy(cmdline,"CMD.EXE");
   strcat(cmdline+8,args);  /* we need to have a \0 after CMD.EXE */

   rc = DosExecPgm(buffer,BUFLEN,dflag,cmdline,0L,&result,"CMD.EXE");
   if (rc) {
      sprintf(out,"Error %lu starting CMD.EXE with these parameters\n",rc);
      fputs(out,stderr);
      fputs(cmdline,stderr);
      fputs("\nReport buffer contents: ",stderr);
      fputs(buffer,stderr);
      fputs("\n",stderr);
   }
   if (dflag == SYNCH) {
      sprintf(out,"DosExecPgm invocation rc=%lu\n",rc);
      fputs(out,stderr);
      sprintf(out,"Termination code: %lu\n",result.codeTerminate);
      fputs(out,stderr);
      sprintf(out,"Result (exit) code: %lu\n",result.codeResult);
      fputs(out,stderr);
   }
   else { /* if asynch.. */
      childID = result.codeTerminate;
      rc = DosSetPriority(1L,prt,delta,childID);
      if (rc) { /* set priority failed */
         sprintf(out,"DosSetPriority call failed with rc=%lu\n",rc);
         fputs(out,stderr);
         fputs("Process execution continues at standard priority level\n",stderr);
      }
      else /* success */
         sprintf(out,"Process %lu started with %s priority\n",result.codeTerminate,
           (prt == 1 ? "idle" : "time-critical"));
          fputs(out,stderr);
   }
   /* If asynch, collect results, and reset priority for new decendants */
   if (dflag == ASYNCH) 
      while (DosCwait(0L,1L,&result,&termPID, childID) == 129) {
         rc = DosSetPriority(1L,prt,delta,childID);
         if (rc) { /* set priority failed */
            sprintf(out,"DosSetPriority call failed with rc=%lu\n",rc);
            fputs(out,stderr);
            fputs("Process execution continues at previous priority level\n",stderr);
         }
         DosSleep(3000);
   }    
   DosExit(0,rc);
}

void helper() {
 int i;
 printf("\nThis program allows you to run an OS/2 program either in idle\n");
 printf("time priority, or time-critical priority levels by invoking a\n");
 printf("command processor (CMD.EXE) with the parameters you specify, \n");
 printf("and then modifying the priority of that CMD.EXE. It periodically\n");
 printf("re-sets the priority of all subprocess of CMD.EXE\n\n");
 printf("Usage:\n");
 printf("    NICE /switches MYPROG.EXE program_parameters \n\n");
 printf("Examples:\n");
 printf("    NICE /cs SEARCH \"keyword\"  *.doc *.txt > keyword.out\n");
 printf("    DETACH NICE ICC /c /Ti+ myfile.c\n");
 printf("    DETACH NICE CL /c /AL myfile.c > compiler_says.out\n\n");
 printf("Optional Switches:\n");
 printf("   /C : runs program in time-critical priority instead of idle priority.\n");
 printf("   /S : runs program synchronously with NICE.\n");
 printf("   /D : runs program detached from NICE (no console I/O possible)\n\n");
 printf("--Hit ENTER for the second page---\n");
 i = getchar();
 printf("Note 1: Due to a limitation, if NICE is invoked without the /D switch,\n");
 printf(" the command prompt will not appear until the execution is completed.\n");
 printf(" To get the command prompt right away, start your command with the DETACH\n");
 printf(" keyword.\n");
 printf("Note 2: If /D is specified, the program is run in the normal-priority mode\n\n");
 printf(" NICE is written in C language with IBM C/SET 2 32-bit compiler and\n");
 printf(" OS/2 2.0 beta 6.177 toolkit.\n\n");
 printf("Things to try: \n");
 printf(" - Open two OS/2 Windows in the workshell.\n");
 printf(" - At one window, type COUNTER to run counter.cmd\n");
 printf(" - At the other window, type: NICE COUNTER so that it runs in idle priority\n");
 printf(" - Let them run for a while. Notice the difference in speed!\n");
 printf(" - Try again by giving one of them time-critical priority:\n");
 printf("   you may lose control of the workshell, until the counter hits 4000\n\n");
 printf("User-Supported Software:\n");
 printf(" A donation of $10 is required if you decide to keep this program.\n");
 printf(" Please send payment to the above address. Thank you!\n");
 exit(1);
 }

