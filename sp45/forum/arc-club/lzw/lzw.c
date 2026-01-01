/***********************************************************\
**  LZW data compression/expansion demonstration program.  **
**  Mark R. Nelson                                         **
**  From Dr.Dobb's Journal (Oct, 1989) by MacSoft          **
\***********************************************************/

#include <stdio.h>

#define BITS 12                   /* setting the number of bits to 12,13 */
#define HASHING_SHIFT BITS-8      /* or 14 affects several constants.    */
#define MAX_VALUE (1<<BITS)-1     /* Note that MS-DOS machines need to   */
#define MAX_CODE MAX_VALUE-1      /* compile their code in large model if*/
                                  /* 14 bits are selectd                 */
#if BITS==14
	#define TABLE_SIZE 18041  /* The string table size needs to be a */
#endif                            /* prime number that is somewhat larger*/
#if BITS==13                      /* than 2**BITS                        */
	#define TABLE_SIZE 9029
#endif
#if BITS==12
	#define TABLE_SIZE 5021
#endif

void *malloc();

int *code_value;                  /* This is code value array            */
unsigned int *prefix_code;        /* This array holds the prefix codes   */
unsigned char *append_character;  /* This array holds the appended chars */
unsigned char decode_stack[4000]; /* This array holds the decoded string */

/*
** This program gets a file name from a command line. It compresses the
** file, placing its output in a file named TEST.LZW. It then expands
** test.lzw into TEST.OUT. Test.out should then be an exact duplicate of
** the input file.
*/
main(int argc,char *argv[])
{
FILE *input_file;
FILE *output_file;
FILE *lzw_file;
char input_file_name[81];

	code_value=malloc(TABLE_SIZE*sizeof(unsigned int));
	prefix_code=malloc(TABLE_SIZE*sizeof(unsigned int));
	append_character=malloc(TABLE_SIZE*sizeof(unsigned char));
	if (code_value==NULL || prefix_code==NULL || append_character==NULL) {
		printf("Fatal error allocating table space!\n");
		exit(1);
	}
/*
** Get the file name, open it up and open up the lzw output file
*/
	if (argc>1)
		strcpy(input_file_name,argv[1]);
	else {
		printf("Input file name? ");
		scanf("%s",input_file_name);
	}
	input_file=fopen(input_file_name,"rb");
	lzw_file=fopen("test.lzw","wb");
	if (input_file==NULL || lzw_file==NULL) {
		printf("Fatal error opening files.\n");
		exit(2);
	}
/*
** Compress the file
*/
	compress(input_file,lzw_file);
	fclose(input_file);
	fclose(lzw_file);
	free(code_value);
/*
** Now open the files for the expansion
*/
	lzw_file=fopen("test.lzw","rb");
	output_file=fopen("test.out","wb");
	if (lzw_file==NULL || output_file==NULL) {
		printf("Fatal error opening files.\n");
		exit(3);
	}
/*
** Expand the file
*/
	expand(lzw_file,output_file);
	fclose(lzw_file);
	fclose(output_file);
	free(prefix_code);
	free(append_character);
	exit(0);
}
/*
** This is the compression routine. The code should be a fairly close
** match to the algorithm accompanying the article.
*/
compress(FILE *input,FILE *output)
{
	unsigned int next_code;
	unsigned int character;
	unsigned int string_code;
	unsigned int index;
	int i;
	next_code=256;                 /* next available string code */
	for(i=0;i<TABLE_SIZE;i++)     /* clear string table */
		code_value[i]=-1;
	i=0;
	printf("Compressing...\n");
	string_code=getc(input);      /* get the first code */
/*
** This is the main loop where it all happens. This loop runs until all of
** the input has been exhausted. Note that it stops adding codes to the
** table after all of the possible codes have been defined.
*/
	while ((character=getc(input))!=(unsigned)(EOF)) {
		if (++i==1000) {
			i=0;
			printf("*"); /* print '*' after every 1000 chars */
		}
		index=find_match(string_code,character);
		if (code_value[index]!=-1)
			string_code=code_value[index];
		else {
			if (next_code<=MAX_CODE) {
				code_value[index]=next_code++;
				prefix_code[index]=string_code;
				append_character[index]=character;
			}
			output_code(output,string_code);
			string_code=character;
		}
	}
	output_code(output,string_code);
	output_code(output,MAX_VALUE);
	output_code(output,0);
	printf("\n");
}
/*
** This is the hashing routine. It tries to find a match for the prefix+char
** string in the string table. If it finds it, the index is returned. If
** the string is not found, the first available index in the string table is
** returned instead.
*/
find_match(int hash_prefix,unsigned int hash_character)
{
	int index,offset;
	index=(hash_character<<HASHING_SHIFT) ^ hash_prefix;
	if (index==0)
		offset=1;
	else
		offset=TABLE_SIZE-index;
	while (1) {
		if (code_value[index]==-1)
			return index;
		if (prefix_code[index]==hash_prefix &&
				append_character[index]==hash_character)
			return index;
		index-=offset;
		if (index<0)
			index+=TABLE_SIZE;
	}
}
/*
** This is expansion routine. It takes an LZW format file, and expands
** it to an output file. The code here should be a faitly close match to
** the algorithm in the accompaning article.
*/
expand(FILE *input,FILE *output)
{
	unsigned int next_code;
	unsigned int new_code;
	unsigned int old_code;
	int character;
	int counter;
	unsigned char *string;
	char *decode_string(unsigned char *buffer,unsigned int code);
	next_code=256;
	counter=0;
	printf("Expanding...\n");
	old_code=input_code(input);
	character=old_code;
	putc(old_code,output);
	while ((new_code=input_code(input)) !=(MAX_VALUE)) {
		if (++counter==1000) {
			counter=0;
			printf("*");
		}
/*
** This code checks for the special STRING+CHARACTER+STRING+CHARACTER+STRING
** case which generates an undefined code. It handles it by decoding
** the last code, adding a single character to the end of the decode string.
*/
		if (new_code>=next_code) {
			*decode_stack=character;
			string=decode_string(decode_stack+1,old_code);
		}
/*
** Otherwise we do a straight decode of the new code.
*/
		else
			string=decode_string(decode_stack,new_code);
		character=*string;
		while (string>=decode_stack)
			putc(*string--,output);
		if (next_code<=MAX_CODE) {
			prefix_code[next_code]=old_code;
			append_character[next_code]=character;
			next_code++;
		}
		old_code=new_code;
	}
	printf("\n");
}
/*
** This routine simply decodes a string from the string table, storing
** it in buffer. The buffer can then be output in reverse order by
** the expansion program.
*/
char *decode_string(unsigned char *buffer,unsigned int code)
{
	int i;
	i=0;
	while (code>255) {
		*buffer++=append_character[code];
		code=prefix_code[code];
		if (i++>4000) {
			printf("Fatal error during code expansion.\n");
			exit(4);
		}
	}
	*buffer=code;
	return buffer;
}
/*
** The following two routines are used to output variable negth
** codes. They are written strivtly for clarity and are not
** particularly efficent.
*/
input_code(FILE *input)
{
	unsigned int return_value;
	static int input_bit_count=0;
	static unsigned long input_bit_buffer=0L;
	while (input_bit_count<=24) {
		input_bit_buffer|=(unsigned long) getc(input) <<
                                  (24-input_bit_count);
		input_bit_count+=8;
	}
	return_value=input_bit_buffer>>(32-BITS);
	input_bit_buffer<<=BITS;
	input_bit_count-=BITS;
	return return_value;
}
output_code(FILE *output,unsigned int code)
{
	static int output_bit_count=0;
	static unsigned long output_bit_buffer=0L;
	output_bit_buffer|=(unsigned long) code << (32-BITS-output_bit_count);
	output_bit_count+=BITS;
	while (output_bit_count>=8) {
		putc(output_bit_buffer>>24,output);
		output_bit_buffer<<=8;
		output_bit_count-=8;
	}
}
