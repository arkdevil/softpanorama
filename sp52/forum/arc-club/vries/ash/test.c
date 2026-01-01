#include <stdio.h>
#include <time.h>

static void print_time (clock_t);

int main (void)

{
        unsigned hh, mm, ss, tt;
        long x;

        hh = 15;
        mm = 59;
        ss = 59;
        tt = 9;

        x = hh;
        x *= 60;
        x += mm;
        x *= 60;
        x += ss;
        x *= 10;
        x += tt;

        x *= CLK_TCK;
        x /= 10;

        print_time (x);

        return 0;
}



static void print_time (clock_t t)

{
        long t2;
        unsigned t3;
        unsigned hh, mm, ss;

        t2 = t * 10 / CLK_TCK;
        hh = (unsigned) (t2 / 36000L);
        t3 = (unsigned) (t2 % 36000L);
        mm = t3 / 600;
        t3 %= 600;
        ss = t3 / 10;
        t3 %= 10;

        fprintf (stdout, "Time: ");
        if (hh)
                fprintf (stdout, "%d:%02d:%02d.%01d\n", hh, mm, ss, t3);
        else
                fprintf (stdout, "%d:%02d.%01d\n", mm, ss, t3);
}

