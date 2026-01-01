#define MIN_RANGE 0x4001
#define MAX_RANGE 0xFFFF

struct coder_state

{
        unsigned low;
        unsigned range;
        int uflow;
        int bits;
        int fpos;
};


void InitCoder (void);
void CloseCoder (void);
void EncodeArith (unsigned, unsigned, unsigned);
void StartDecode (void);
int DecodeArith (unsigned);
void UpdateDecoder (unsigned, unsigned, unsigned);
void SaveCoderState (struct coder_state *);
void RestoreCoderState (struct coder_state *);
int CodeLength (struct coder_state *);
int ResetOutputPointer (int);

