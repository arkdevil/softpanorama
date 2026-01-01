#include <stdio.h>

char xlt[256][10];

parse_config(FILE *cfg);
translate(FILE *input,FILE *output);

main(int argc, char **argv)
{
    int  c;
    FILE *in, *out;

    printf("\nCyrillic texts romanizer v1.00\n");
    printf("(C) Michael Bravo 1992\n\n");

    if (argc < 3)
    {
        printf("Usage: romanize <infile> <outfile> [ctlfile]\n");
        exit(1);
    }

    if ((in=fopen("romanize.ctl","rb")) == NULL || argc == 4)
        if ( (in=fopen(argv[3],"rb")) == NULL)
        {
            printf("Unable to find/open any config file, exiting...\n");
            exit(1);
        };

    parse_config(in);

    fclose(in);

    if ((in=fopen(argv[1],"rb")) == NULL)
    {
        printf("Unable to open %s, exiting...\n",argv[1]);
        exit(1);
    }

    if ((out=fopen(argv[2],"wb")) == NULL)
    {
        printf("Can't create %s, exiting...\n",argv[2]);
        exit(1);
    }

    setvbuf(in,NULL,_IOFBF,2048);
    setvbuf(out,NULL,_IOFBF,2048);

    translate(in,out);

    fclose(in);
    fclose(out);

    return 0;
}

parse_config(FILE *cfg)
{
    char aux[2]=" ";
    char buf[81];
    char tmpjunk1[4],tmpjunk2[10];
    int  i;

/* Initialize translation table with default values */

    for (i=0;i<256;i++)
    {
        aux[0]=i;
        strcpy(xlt[i],aux);
    }

/* Read in configuration file */

    fgets(buf,80,cfg);
    do
    {
        if (buf[0] == ';')
            continue;
        strcpy(tmpjunk1,strtok(buf," ,"));
        strcpy(tmpjunk2,strtok(NULL," ,"));
        i=atoi(tmpjunk1);

        if (i<0 || i>255)
        {
            printf("Foolproofer: incorrect character code %d in config file\n",i);
            exit(2);
        }

        strcpy(xlt[i],tmpjunk2);

    } while (fgets(buf,80,cfg) != NULL);

    return 0;
}

translate(FILE *input, FILE *output)
{
    int ch;

    ch=fgetc(input);
    do
    {
        if (strlen(xlt[ch]) == 1)
            fputc(xlt[ch][0],output);
        else
            fprintf(output,"%s",xlt[ch]);
    } while ((ch=fgetc(input)) != EOF);

    return 0;
}
