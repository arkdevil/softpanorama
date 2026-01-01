# generate random numbers
# AKW p70

BEGIN { srand()
        for (i = 1; i <= 200; i++)
             print int(100 * rand())
      }
