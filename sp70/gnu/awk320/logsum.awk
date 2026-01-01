# LogSum.AWK by S.H. Moody, 09-06-89
# The LOG.COM utility presented in Vol. 7, No. 21 (December 13, 1988) of
# PC Magazine creates a USAGE.LOG file on your disk which contains
# a log of all uses of .COM, .EXE, and .BAT while LOG.COM is installed.
# This program aggregates the data by file name, counting up the number
# of times each executable is run, and the total time it is active.

BEGIN {
   print"Program Name        Times Used   Hours Used"
   print"------------        ----------   ----------"
}

   function timecvt(t, hours)  {
      split(t, hms, ":");
      hours = hms[1] + hms[2] / 60 + hms[3] / 3600;
      return hours
   }


{
   if($4 !~ /^[0-9]/) next

   thistime = timecvt($3)
   program[$5]+= thistime;
   tottime+= thistime;
   nrun[$5]++;
   totrun++;
}

END {
   for (n in program) {
      numprog++;
      printf("%-12s %14d %15.4f\n", n, nrun[n], program[n] );
   }
   printf("\nTotals (%3d progs)%9d %15.4f\n", numprog, totrun, tottime );
}

