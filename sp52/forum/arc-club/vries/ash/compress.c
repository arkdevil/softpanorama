/*
        Test statistical compression using fixed dictionary
*/


#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>

#include "comp.h"
#include "files.h"

#define COMP_STAT

static char *input_file_name;
static char *output_file_name = "compfile";
static unsigned long expand_size = 0;


static void compress_file (int);
static void print_time (clock_t);
static void print_compression (FILE *);


int main (int argc, char *argv [])

{
        clock_t start_time;

        int max_order;
        char *p;

        if (argc < 3 || argc > 4)
        {
                fprintf (stderr, "Usage: cmp <order> <input file1> [<optional output file2>]\n");
                fprintf (stderr, "Output file name defaults to 'compfile'\n");
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

        input_file_name = argv [2];
        if (argc == 4) output_file_name = argv [3];

        OpenInputFile (input_file_name);
        OpenOutputFile (output_file_name);

        fprintf (stdout, "Input file: %s\n", input_file_name);
        fprintf (stdout, "Order: %d\n", max_order);
        fprintf (stdout, "Dictionary size: %u\n", NDICT);

        start_time = clock ();
        compress_file (max_order);

        print_time (clock () - start_time);
        CloseInputFile ();

        return EXIT_SUCCESS;
}



static void compress_file (int max_order)

{
        int ch;

        InitModel (max_order);

        expand_size = 0;

        ch = ReadInputFile ();
        while (ch != EOF)
        {
                CompressSymbol (ch);
                expand_size ++;

#ifdef COMP_STAT
                if ((expand_size & 0xFF) == 0) print_compression (stderr);
#endif

                ch = ReadInputFile ();
        }

        CompressSymbol (END_OF_FILE);

        CloseModel ();

#ifdef COMP_STAT
        print_compression (stderr);
#endif

        print_compression (stdout);
        fprintf (stdout, "\n");
}


static void print_compression (FILE *fptr)

{
        unsigned long comp_size;
        unsigned long t, t2;
        unsigned x, y;

        comp_size = GetOutputLength ();
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
