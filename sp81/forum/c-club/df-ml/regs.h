/* for Aztec C */

typedef struct {
	unsigned AX;
	unsigned BX;
	unsigned CX;
	unsigned DX;
	int SI;
        int DI;
        int DS;
        int ES;
} REGS;

#define TEST_CARRY(x)		(x & 0x1)


