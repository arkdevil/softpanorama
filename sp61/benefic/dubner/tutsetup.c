#include <stdLib.h>	/* exit			*/
#include <stdIO.h>	/* printf, FILE, ...	*/
#include <string.h>	/* strlen, strncmp	*/

void main(int argc, char* argv[])
{
   FILE* 	tutFile=fopen(argv[1], "rb");
   long		lePtr=0;
   int		leNo=0;
   char		buffer[256];
   char		LESSON[]="=LESSON";

   if (argc != 2) {
      printf("Usage: %s <tutor-file-name>\n", argv[0]);
      exit(1);
   }
   if (tutFile == NULL) {
      printf("Cannot find file '%s'", argv[1]);
      exit(2);
   }
   while (1) {
      if (!fgets(buffer, 256, tutFile))
         if (feof(tutFile)) break;
         else {
            printf("Error reading file '%s'", argv[1]);
            exit(-1);
         }
      if (strncmp(buffer, LESSON, 7) == 0) {
         leNo = atoi(buffer+7);
         printf("\n%s %3d -> %10ld", LESSON, leNo, lePtr);
      }
      lePtr += strlen(buffer);
   }
}