/*
        Test statistical compression using fixed dictionary
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>


#include "comp.h"
#include "arith.h"
#include "files.h"

#define COMP_STAT


static char *input_file_name = "compfile";
static char *output_file_name = "xpndfile";

static unsigned long expand_size = 0;


static void expand_file (int);
static void print_time (clock_t);
static void print_compression (FILE *);


int main (int argc, char *argv [])

{
        clock_t start_time;
        char *p;
        int max_order;

        if (argc < 2 || argc > 4)
        {
                fprintf (stderr, "Usage: expand <order> [<input file1]> [<optional output file2>]\n");
                fprintf (stderr, "Input file name defaults to 'compfile'\n");
                fprintf (stderr, "Output file name defaults to 'xpndfile'\n");
                return EXIT_FAILURE;
        }

        max_order = 0;
        p = argv [1];
        while (*p)
        {
                if (!isdigit (*p))
                {
                        fprintf (stderr, "Invalid order\n");
                        exit (EXIT_FAILURE);
                }

                max_order *= 10;
                max_order += *p - '0';

                p ++;
        }

        if (max_order > MAX_ORDER) max_order = MAX_ORDER;

        if (argc >= 3) input_file_name = argv [2];
        if (argc == 4) output_file_name = argv [3];

        fprintf (stdout, "Output file: %s\n", output_file_name);
        fprintf (stdout, "Order: %d\n", max_order);
        fprintf (stdout, "Dictionary size: %u\n", NDICT);

        OpenInputFile (input_file_name);
        OpenOutputFile (output_file_name);

        start_time = clock ();
        expand_file (max_order);

        print_time (clock () - start_time);

        CloseInputFile ();
        CloseOutputFile ();

        return EXIT_SUCCESS;
}



static void expand_file (int n)

{
        int ch;

        expand_size = 0;

        InitModel (n);
        StartDecode ();

        ch = ExpandSymbol ();
        while (ch != END_OF_FILE)
        {
                WriteOutputFile (ch);
                expand_size ++;

#ifdef COMP_STAT
                if ((expand_size & 0xFF) == 0) print_compression (stderr);
#endif

                ch = ExpandSymbol ();
        }

#ifdef COMP_STAT
                if ((expand_size & 0xFF) == 0) print_compression (stderr);
#endif

        print_compression (stdout);
        fprintf (stdout, "\n");
}



static void print_compression (FILE *fptr)

{
        unsigned long comp_size;
        unsigned long t, t2;
        unsigned x, y;

        comp_size = GetInputLength ();
        t = 1000 * comp_size;
        t2 = expand_size >> 1;
        x = (unsigned) ((t + t2) / expand_size);
        y = (unsigned) ((8 * t + t2) / expand_size);

        fprintf (fptr, "%ld/%ld    %u.%01u    (%u.%03u) \r", expand_size, comp_size,
                x / 10, x % 10, y / 1000, y % 1000);
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
