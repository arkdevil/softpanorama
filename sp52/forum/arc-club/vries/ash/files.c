#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>

#include "files.h"

#define OUT_BUF_MAX     (2 * OUT_BUF_SIZE)


static unsigned long input_file_length = 0;
static unsigned long output_file_length = 0;

static int input_file;
static int output_file;

static unsigned char output_area [OUT_BUF_MAX];
static int output_index;
static int output_max;

static unsigned char input_area [IN_BUF_SIZE];
static int input_index;
static int input_len;


static void read_input_area (void);
static void write_output_area (void);


long OpenInputFile (char *fn)

{
        long filesize;

        input_file = open (fn, O_RDONLY | O_BINARY);
        if (input_file < 0)
        {
                perror ("Error on file open");
                exit (EXIT_FAILURE);
        }

        filesize = lseek (input_file, 0L, SEEK_END);
        lseek (input_file, 0L, SEEK_SET);

        read_input_area ();

        return filesize;
}


int ReadInputFile (void)

{
        if (input_index == input_len)
        {
                read_input_area ();
                if (input_len == 0) return -1;
        }

        return input_area [input_index ++];
}



int ResetOutputPointer (unsigned pos)

{
        output_index -= pos;
        if (output_index < 0)
        {
                output_index += OUT_BUF_MAX;
                output_file_length -= OUT_BUF_MAX;
        }

        return output_area [output_index];
}


void OpenOutputFile (char *fn)

{
        output_file = open (fn, O_RDWR+O_BINARY+O_CREAT+O_TRUNC, S_IREAD+S_IWRITE);
        if (output_file < 0)
        {
                perror ("Error on output file open");
                exit (EXIT_FAILURE);
        }

        output_file_length = 0;
        output_index = 0;
        output_max = OUT_BUF_MAX;
}



void WriteOutputFile (int ch)

{
        output_area [output_index] = ch;

        output_index ++;
        if (output_index == output_max)
                write_output_area ();
        else
        if (output_index == OUT_BUF_MAX)
        {
                output_index = 0;
                output_file_length += OUT_BUF_MAX;
        }
}



void CloseInputFile (void)

{       close (input_file);
}



void CloseOutputFile (void)

{
        if (output_index < output_max)
        {
                write (output_file, &output_area [output_max], OUT_BUF_MAX - output_max);
                output_max = 0;
        }

        write (output_file, &output_area [output_max], output_index - output_max);
        close (output_file);
}



static void read_input_area ()

{
        input_file_length += input_len;
        input_index = 0;
        input_len = read (input_file, input_area, IN_BUF_SIZE);

        if (input_len < 0)
        {
                perror ("Error reading input file");
                exit (EXIT_FAILURE);
        }
}


static void write_output_area (void)

{
        int n;

        if (output_max == OUT_BUF_MAX)
        {
                output_file_length += OUT_BUF_MAX;
                output_max = OUT_BUF_SIZE;
                output_index = 0;
        }
        else
                output_max += OUT_BUF_SIZE;

        n = write (output_file, &output_area [output_index], OUT_BUF_SIZE);
        if (n < 0)
        {
                perror ("\nError writing output file");
                exit (EXIT_FAILURE);
        }
        else
        if (n < OUT_BUF_SIZE)
        {
                printf ("\nDisk full on write\n");
                exit (EXIT_FAILURE);
        }
}


unsigned long GetOutputLength (void)

{       return output_file_length + output_index;
}


unsigned long GetInputLength (void)

{       return input_file_length + input_index;
}
