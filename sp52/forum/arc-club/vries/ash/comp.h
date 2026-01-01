/*
        Define storage allocation parameters

        FAR_TABLES dynamically allocates dictionary using far pointers
        SPLIT_TABLES allows a dictionary size over 32K
*/

#define FAR_TABLES
#undef SPLIT_TABLES

/*  Define size of dictionary and other useful parameters  */

#define NDICT          28000U   /* Size of circular dictionary */
#define MAX_ORDER      8                /* Maximum order accomodated by the model */
#define MAX_CHAR_CODE  256      /* Number of symbols accepted by model */

#define HTBL1_SIZE     256              /* Hash table size - equals character set size */

#define MIN_STR        3                /* Minimum string length */
#define MAX_STR_CODE   64       /* Maximum code value for string length */

#define MAX_STR        (MIN_STR+MAX_STR_CODE+254)
#define MAX_STR_SAVE   (MIN_STR)
#define MAX_SYM        (MAX_CHAR_CODE + 2)

#define MAX_DICT       (NDICT+MAX_ORDER)
#define NIL_DICT_PTR   0

#define SWITCH_SYM     -1
#define END_OF_FILE    MAX_CHAR_CODE
#define START_STRING   (MAX_CHAR_CODE + 1)


void InitModel (int);
void CompressSymbol (int);
int ExpandSymbol (void);
void CloseModel (void);
