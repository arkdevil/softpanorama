#define IN_BUF_SIZE     512
#define OUT_BUF_SIZE    512

void OpenOutputFile (char *);
long OpenInputFile (char *);
int ReadInputFile (void);
unsigned ReadBinaryInput (void);
void WriteOutputFile (int);
void CloseInputFile (void);
void CloseOutputFile (void);
unsigned long GetOutputLength (void);
unsigned long GetInputLength (void);
