typedef struct QueEntry {
	struct QueEntry *Next;
	char   *Body;
	} QUE_ENTRY;

typedef struct QueDef {
	QUE_ENTRY *Head, *Current;
	int       Count;
	} QUE_DEF;

/*
 * Function prototypes for queue functions
 */

void      InitQueue (QUE_DEF *Q);
QUE_ENTRY *Enque (QUE_DEF *Q, void *Body);
char *Deque (QUE_DEF *Q, char *Str);

